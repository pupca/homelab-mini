#!/bin/bash
# Watchdog: checks if Docker inside colima is responsive.
# If not, restarts colima and brings compose up.
# Runs every 5 min via LaunchDaemon.
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export HOME=/Users/pupca
export DOCKER_HOST="unix:///Users/pupca/.colima/headless-mac-server/docker.sock"

PROFILE="headless-mac-server"
LOG="/Users/pupca/projects/homelab/mini/logs/docker-watchdog.log"
COMPOSE_DIR="/Users/pupca/projects/homelab/mini/docker"

mkdir -p "$(dirname "$LOG")"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

# Quick check — if Docker responds, everything is fine
if docker info >/dev/null 2>&1; then
    exit 0
fi

echo "[$(ts)] Docker unresponsive. Attempting recovery..." >> "$LOG"

# Check if colima VM is running
if colima status --profile "$PROFILE" >/dev/null 2>&1; then
    echo "[$(ts)] Colima VM is up but Docker is dead. Restarting colima..." >> "$LOG"
    colima stop --profile "$PROFILE" >> "$LOG" 2>&1
    sleep 5
fi

echo "[$(ts)] Starting colima..." >> "$LOG"
colima start --profile "$PROFILE" >> "$LOG" 2>&1
sleep 20

# Verify Docker is back
if ! docker info >/dev/null 2>&1; then
    echo "[$(ts)] CRITICAL: Docker still not responding after colima restart!" >> "$LOG"
    exit 1
fi

echo "[$(ts)] Docker is back. Bringing containers up..." >> "$LOG"
cd "$COMPOSE_DIR" && docker compose up -d >> "$LOG" 2>&1

echo "[$(ts)] Recovery complete. $(docker ps -q | wc -l | tr -d ' ') containers running." >> "$LOG"
