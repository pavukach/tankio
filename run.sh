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

TANKIO_SERVER=1 godot --headless &>> logs/run.log &
pids+=($!)

godot &>> logs/run.log &
pids+=($!)

godot &>> logs/run.log &
pids+=($!)

wait