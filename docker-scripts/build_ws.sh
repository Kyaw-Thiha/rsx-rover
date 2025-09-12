#!/usr/bin/env bash
set -euo pipefail
cd "${WS_DIR:-/workspaces/rsx-rover}"

# Source ROS and build
source "/opt/ros/${ROS_DISTRO}/setup.bash"
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo

# Overlay for current shell
if [ -f install/setup.bash ]; then
  source install/setup.bash
fi

echo "Build complete."
