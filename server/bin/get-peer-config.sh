#!/usr/bin/env sh
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <peer-name>" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
CONF_PATH="config/peer_${1}/peer_${1}.conf"
if [ ! -f "$CONF_PATH" ]; then
  echo "Config not found: $CONF_PATH" >&2
  exit 2
fi
cat "$CONF_PATH"
