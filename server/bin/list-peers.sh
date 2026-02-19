#!/usr/bin/env sh
set -e
cd "$(dirname "$0")/.."
docker compose exec wireguard /app/show-peer
