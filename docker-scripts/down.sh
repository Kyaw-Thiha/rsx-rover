#!/usr/bin/env bash
set -euo pipefail
# Bring down JUST THIS PROJECT (compose in current dir) and clean local artifacts.
# Removes containers, anonymous volumes, and images built by this compose file.

docker compose down -v --remove-orphans --rmi local || true
echo "[project] compose down complete."

# Optional: prune dangling stuff left behind
docker builder prune -f || true
docker image prune -f || true
docker volume prune -f || true
docker network prune -f || true
echo "[project] pruned dangling builder cache/images/volumes/networks."
