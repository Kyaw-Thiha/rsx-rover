#!/usr/bin/env bash
set -euo pipefail
cd "${WS_DIR:-/workspaces/rsx-rover}"
rm -rf build install log
echo "Workspace cleaned."
