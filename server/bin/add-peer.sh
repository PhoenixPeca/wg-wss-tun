#!/usr/bin/env sh
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <peer-name>" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
docker compose exec wireguard /app/add-peer "$1"
