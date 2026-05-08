#!/usr/bin/env bash

pids=()

cleanup() {
  echo "Stopping Godot instances..."
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null
  done
}

trap cleanup EXIT INT TERM

mkdir -p logs

godot --server --headless &> logs/server-log.txt &
pids+=($!)

godot &> logs/client1-log.txt &
pids+=($!)

godot &> logs/client2-log.txt &
pids+=($!)

wait
