#!/bin/bash
# Mounts the TrueNAS media share at /Users/pupca/media.
# Invoked by /Library/LaunchDaemons/cz.pupca.mount-media.plist at boot.
# Retries for ~60s in case the network is not yet up when launchd fires.
set -u

MOUNT_POINT="/Users/pupca/media"
NFS_SOURCE="192.168.20.14:/mnt/nas/media"
MOUNT_OPTS="nolock,nosuid,resvport"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

if mount | grep -q " on ${MOUNT_POINT} "; then
    echo "[$(ts)] already mounted at ${MOUNT_POINT}, nothing to do"
    exit 0
fi

mkdir -p "${MOUNT_POINT}"

for attempt in $(seq 1 30); do
    if /sbin/mount_nfs -o "${MOUNT_OPTS}" "${NFS_SOURCE}" "${MOUNT_POINT}"; then
        echo "[$(ts)] mounted ${NFS_SOURCE} at ${MOUNT_POINT} on attempt ${attempt}"
        exit 0
    fi
    echo "[$(ts)] mount attempt ${attempt} failed, retrying in 2s"
    sleep 2
done

echo "[$(ts)] giving up after 30 attempts"
exit 1
