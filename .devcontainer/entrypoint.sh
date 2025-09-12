#!/usr/bin/env bash
set -e

# Always source ROS first
if [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi

# Overlay workspace if present
WS_DIR="${WS_DIR:-/workspaces/rsx-rover}"
if [ -f "${WS_DIR}/install/setup.bash" ]; then
  source "${WS_DIR}/install/setup.bash"
fi

exec "$@"
