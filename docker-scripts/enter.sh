#!/usr/bin/env bash
set -euo pipefail
# Choose which running service to enter; defaults to 'rsxrover'
SVC="${1:-rsxrover}"

# Pick the preferred interactive shell based on build arg
SHELL_BIN="${SHELL_BIN:-/bin/bash}"
if docker inspect "$SVC" >/dev/null 2>&1; then
  # Probe if zsh exists
  if docker compose exec "$SVC" test -x /bin/zsh; then
    SHELL_BIN="/bin/zsh"
  fi
  docker compose exec "$SVC" "$SHELL_BIN" -i
else
  echo "Service '$SVC' is not running."
  exit 1
fi
