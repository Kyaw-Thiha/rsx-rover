#!/usr/bin/env bash
set -Eeuo pipefail

WS_DIR="${WS_DIR:-/workspaces/rsx-rover}"
: "${ROS_DISTRO:=humble}"

cd "$WS_DIR"

# Source a file with nounset turned off, then restore prior state
source_relaxed() {
  local f="$1"
  [ -f "$f" ] || return 0
  local had_nounset=0
  if [[ -o nounset ]]; then
    had_nounset=1
    set +u
  fi
  . "$f"
  if ((had_nounset)); then set -u; fi
}

# Source ROS 2 env and build
source_relaxed "/opt/ros/${ROS_DISTRO}/setup.sh"
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo

# Overlay (for this subshell)
source_relaxed "install/setup.sh"

echo "Build complete."
echo "Tip: open a new shell (or 'source install/setup.sh') to overlay your current session."
