#!/bin/bash
# Watchdog: checks if Docker (OrbStack) is responsive.
# Handles both crashes AND hangs via 10s timeout.
# Runs every 5 min via LaunchDaemon.
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export HOME=/Users/pupca

LOG="/Users/pupca/projects/homelab/mini/logs/docker-watchdog.log"
COMPOSE_DIR="/Users/pupca/projects/homelab/mini/docker"

mkdir -p "$(dirname "$LOG")"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

# Check docker with 10s timeout (catches both dead AND hung daemon)
check_docker() {
    docker info >/dev/null 2>&1 &
    local pid=$!
    ( sleep 10; kill $pid 2>/dev/null ) &
    local timer=$!
    if wait $pid 2>/dev/null; then
        kill $timer 2>/dev/null
        wait $timer 2>/dev/null
        return 0
    else
        kill $timer 2>/dev/null
        wait $timer 2>/dev/null
        return 1
    fi
}

# Quick check — if Docker responds within 10s, everything is fine
if check_docker; then
    exit 0
fi

echo "[$(ts)] Docker unresponsive. Attempting OrbStack recovery..." >> "$LOG"

# Restart OrbStack
echo "[$(ts)] Restarting OrbStack..." >> "$LOG"
orbctl stop >> "$LOG" 2>&1
sleep 5
orbctl start >> "$LOG" 2>&1
sleep 20

# Verify Docker is back
if ! check_docker; then
    echo "[$(ts)] CRITICAL: Docker still not responding after OrbStack restart!" >> "$LOG"
    exit 1
fi

echo "[$(ts)] Docker is back. Ensuring containers are up..." >> "$LOG"

# Recreate external network if needed
docker network inspect homelab >/dev/null 2>&1 || docker network create homelab >> "$LOG" 2>&1

cd "$COMPOSE_DIR" && docker compose up -d >> "$LOG" 2>&1

echo "[$(ts)] Recovery complete. $(docker ps -q | wc -l | tr -d ' ') containers running." >> "$LOG"
