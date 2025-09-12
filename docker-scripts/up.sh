#!/usr/bin/env bash
set -euo pipefail
PROFILE="${1:-base}" # base|hyprland|x11|mac|windows

export UID="$(id -u)" GID="$(id -g)"
# For Wayland profile, you usually need these exported:
# export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
# export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

case "$PROFILE" in
hyprland) svc="rsxrover-wayland" ;;
x11) svc="rsxrover-x11" ;;
mac) svc="rsxrover-mac" ;;
windows) svc="rsxrover-win" ;;
*) svc="rsxrover" ;;
esac

docker compose up -d "$svc"
echo "Container up with profile: $PROFILE"
