#!/bin/bash
# Watchdog: checks if Docker inside colima is responsive.
# If not, restarts colima. Run via LaunchDaemon every 5 min.
set -u
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
PROFILE="headless-mac-server"
LOG="/var/log/cz.pupca.docker-watchdog.log"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

# Check if colima is running
if ! colima status --profile "$PROFILE" >/dev/null 2>&1; then
    echo "[$(ts)] colima not running, starting..." >> "$LOG"
    colima start --profile "$PROFILE" >> "$LOG" 2>&1
    sleep 30
fi

# Check if docker responds
if docker info >/dev/null 2>&1; then
    exit 0
fi

echo "[$(ts)] docker unresponsive, restarting colima..." >> "$LOG"
colima stop --profile "$PROFILE" >> "$LOG" 2>&1
sleep 5
colima start --profile "$PROFILE" >> "$LOG" 2>&1
sleep 30

# Bring containers up
cd /Users/pupca/projects/homelab/mini/docker && docker compose up -d >> "$LOG" 2>&1
echo "[$(ts)] recovery complete" >> "$LOG"
