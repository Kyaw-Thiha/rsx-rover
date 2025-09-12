#!/usr/bin/env bash
set -euo pipefail
SHELL_FLAVOR="${1:-zsh}"   # zsh|bash
EDITOR_FLAVOR="${2:-nvim}" # nvim|vscode

export SHELL_FLAVOR EDITOR_FLAVOR
export UID="$(id -u)" GID="$(id -g)"

docker compose build rsxrover
echo "Built image with SHELL=${SHELL_FLAVOR}, EDITOR=${EDITOR_FLAVOR}"
