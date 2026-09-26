#!/usr/bin/env ruby

require "json"
require "fileutils"
require "socket"
require "uri"

LOG_DIR = "logs"
BUILD_DIR = "build"
CADDYFILE = "#{LOG_DIR}/Caddyfile"

FileUtils.mkdir_p(LOG_DIR)
FileUtils.mkdir_p(BUILD_DIR)

pids = []

def start_process(pids, log_path, *command, env: {})
  File.write(log_path, "")
  pid = Process.spawn(env, *command, out: log_path, err: [:child, :out])
  pids << pid
  pid
end

def alive?(pid)
  Process.kill(0, pid)
  true
rescue Errno::ESRCH
  false
rescue Errno::EPERM
  true
end

def wait_until(timeout:, interval: 0.5)
  deadline = Time.now + timeout

  loop do
    return true if yield
    return false if Time.now >= deadline

    sleep interval
  end
end

def http_ok?(url)
  system(
    "curl",
    "-fsS",
    "--max-time", "2",
    url,
    out: File::NULL,
    err: File::NULL
  )
end

def tcp_open?(host, port)
  Socket.tcp(host, port, connect_timeout: 1).close
  true
rescue SystemCallError, IO::TimeoutError
  false
end

at_exit do
  pids.each do |pid|
    Process.kill("TERM", pid)
  rescue Errno::ESRCH
  end

  pids.each do |pid|
    Process.wait(pid)
  rescue Errno::ECHILD
  end
end

# Build the web client (must match the server's network protocol)
puts "Building web client..."
build_pid = Process.spawn(
  "godot",
  "--headless",
  "--export-release", "Web",
  File.expand_path("#{BUILD_DIR}/index.html"),
  out: "#{LOG_DIR}/build-log.txt",
  err: "#{LOG_DIR}/build-log.txt"
)
Process.wait(build_pid)
unless $?.exitstatus == 0
  abort "Web client build failed (see #{LOG_DIR}/build-log.txt)."
end
unless File.exist?("#{BUILD_DIR}/index.html")
  abort "Build did not produce #{BUILD_DIR}/index.html."
end

# Start Godot server
server_pid = start_process(
  pids,
  "#{LOG_DIR}/server-log.txt",
  "godot",
  "--headless",
  env: { "TANKIO_SERVER" => "1" }
)

puts "Waiting for Godot server..."

unless wait_until(timeout: 15) { alive?(server_pid) && tcp_open?("127.0.0.1", 4242) }
  abort "Godot server never became available (see #{LOG_DIR}/server-log.txt)."
end

# Generate Caddy configuration
caddyfile = <<~CADDY
  :8080 {
      header {
          Cross-Origin-Opener-Policy "same-origin"
          Cross-Origin-Embedder-Policy "require-corp"
          Cache-Control "public, max-age=0, must-revalidate"
      }

      @ws header Upgrade websocket
      handle @ws {
          reverse_proxy 127.0.0.1:4242
      }

      handle {
          encode gzip
          root * "#{File.expand_path(BUILD_DIR)}"
          file_server {
              precompressed gzip
          }
      }
  }
CADDY
File.write(CADDYFILE, caddyfile)

# Start Caddy
caddy_pid = start_process(
  pids,
  "#{LOG_DIR}/caddy-log.txt",
  "caddy",
  "run",
  "--config", CADDYFILE,
  "--adapter", "caddyfile"
)

puts "Waiting for Caddy..."

unless wait_until(timeout: 15) { alive?(caddy_pid) && http_ok?("http://127.0.0.1:8080") }
  abort "Caddy never became available (see #{LOG_DIR}/caddy-log.txt)."
end

# Start Cloudflare tunnel
cloudflared_log = "#{LOG_DIR}/cloudflared-log.txt"
cloudflared_pid = start_process(
  pids,
  cloudflared_log,
  "cloudflared",
  "tunnel",
  "--url", "http://127.0.0.1:8080"
)

puts "Waiting for Cloudflare tunnel..."

web_url = nil

unless wait_until(timeout: 60) do
  break false unless alive?(cloudflared_pid)

  cloudflared_output = File.read(cloudflared_log)
  web_url = cloudflared_output[/https:\/\/[a-z0-9-]+\.trycloudflare\.com/]
  web_url && cloudflared_output.include?("Registered tunnel connection")
end
  abort "Cloudflare tunnel failed to connect (see #{cloudflared_log})."
end

# Avoid caching an NXDOMAIN response while Cloudflare publishes the quick-tunnel DNS record.
sleep 10

unless wait_until(timeout: 60) { alive?(cloudflared_pid) && http_ok?(web_url) }
  abort "Cloudflare tunnel never became publicly available (see #{cloudflared_log})."
end

# Configure the exported Godot client with build-time connection params.
# The web loader seeds these into the Emscripten environment, which
# OS.get_environment() reads on the web target.
WEB_HOST = URI(web_url).host
WEB_PORT = 443
WEB_PROTO = "wss"

js_path = "#{BUILD_DIR}/index.js"
js = File.read(js_path)

env = {
  "TANKIO_HOST" => WEB_HOST,
  "TANKIO_PORT" => WEB_PORT.to_s,
  "TANKIO_PROTO" => WEB_PROTO
}

json_env = env.map { |k, v| %("#{k}":#{v.to_json}) }.join(",")

unless js.sub!(/var ENV=\{\};/, "var ENV={#{json_env}};")
  abort 'Could not find "var ENV={};" in build/index.js'
end

File.write(js_path, js)

# Precompress the largest assets at max level so Caddy can serve them
# precompressed (no per-request CPU cost, better ratio than on-the-fly).
# Must run AFTER the ENV injection above so index.js.gz carries the injected
# host/port/proto instead of the empty placeholder.
PRECOMPRESS_TARGETS = %w[index.wasm index.pck index.js]
PRECOMPRESS_TARGETS.each do |name|
  path = File.join(BUILD_DIR, name)
  next unless File.exist?(path)

  system("gzip", "-9", "-f", "-k", path, exception: true)
end

open_url = web_url

puts "------------------------------------------------------------"
puts "Open this link (client auto-connects to the game server):"
puts "  #{open_url}"
puts "------------------------------------------------------------"

Process.wait
