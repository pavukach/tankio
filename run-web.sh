#!/usr/bin/env bash

pids=()

cleanup() {
  echo "Stopping server..."
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null
  done
}

trap cleanup EXIT INT TERM

mkdir -p logs

godot --server --headless &> logs/game-server-log.txt &
pids+=($!)

python3 -m http.server 8080 &> logs/file-server-log.txt &
pids+=($!)

npx local-ssl-proxy --source 3000 --target 8080 &> logs/ssl-proxy-log.txt &
pids+=($!)

wait
