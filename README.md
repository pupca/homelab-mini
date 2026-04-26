# homelab-mini

Configuration for the Mac mini homelab server (`pupcas-Mac-mini.local`, 192.168.20.20), replacing the old Ubuntu/KVM server (`olaf-portainer`, 192.168.20.8).

## Layout

- `launchd/` — macOS LaunchDaemon plists (installed to `/Library/LaunchDaemons/`)
- `scripts/` — helper scripts invoked by launchd or manually
- `docker/` — docker-compose stacks (to be added)

## Current state

- **NAS media mount**: `192.168.20.14:/mnt/nas/media` mounted at `/Users/pupca/media` via `cz.pupca.mount-media` LaunchDaemon at boot. Colima auto-exposes `$HOME` to the VM, so containers see it for free.
- **Container runtime**: OrbStack (replaced colima — more stable, native LAN networking without socket_vmnet). Auto-starts at login. Containers reach LAN hosts natively.
- **Native apps**: Plex Media Server (HW transcoding via VideoToolbox). Auto-starts via Login Items + auto-login for `pupca`.
- **Docker stacks**:
  - `docker/media/` — transmission, prowlarr, sonarr, radarr, bazarr. Shared external `homelab` network.
  - `docker/home/` — homeassistant (pinned at 2024.6.4 during migration; points at ubuntu for MQTT/InfluxDB until those are migrated too).

## Docker network

All Docker compose stacks share a single external bridge network named `homelab`. Create it once with:

```bash
docker network create homelab
```

## Running in parallel with ubuntu (migration period)

HA runs in parallel with the existing ubuntu HA. To avoid automation double-fires during testing, rename `data/homeassistant/config/automations.yaml` → `.parallel-disabled`. Current state: automations ARE enabled (needed for Shelly announcements); expect some double-fires.

## Install a LaunchDaemon

```bash
sudo cp launchd/<name>.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/<name>.plist
sudo chmod 644 /Library/LaunchDaemons/<name>.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/<name>.plist
```
