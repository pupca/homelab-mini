# homelab-mini

Configuration for the Mac mini homelab server (`pupcas-Mac-mini.local`, 192.168.20.20), replacing the old Ubuntu/KVM server (`olaf-portainer`, 192.168.20.8).

## Layout

- `launchd/` — macOS LaunchDaemon plists (installed to `/Library/LaunchDaemons/`)
- `scripts/` — helper scripts invoked by launchd or manually
- `docker/` — docker-compose stacks (to be added)

## Current state

- **NAS media mount**: `192.168.20.14:/mnt/nas/media` mounted at `/Users/pupca/media` via `cz.pupca.mount-media` LaunchDaemon at boot. Colima auto-exposes `$HOME` to the VM, so containers see it for free.
- **Container runtime**: colima profile `headless-mac-server` (managed by the [headless-mac-server](https://github.com/...) framework elsewhere on the machine).

## Install a LaunchDaemon

```bash
sudo cp launchd/<name>.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/<name>.plist
sudo chmod 644 /Library/LaunchDaemons/<name>.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/<name>.plist
```
