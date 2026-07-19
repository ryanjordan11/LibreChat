#!/usr/bin/env bash
# Start OneHub daemon (if needed) so LibreChat MCP can talk to it.
# Does not modify OneHub source. Run from anywhere.

set -euo pipefail

NODE24="${HOME}/.nvm/versions/node/v24.18.0/bin/node"
ONEHUB="/Users/ryanjordan/IdeaProjects/onehub14"
OD_BIN="${ONEHUB}/apps/daemon/bin/od.mjs"
DAEMON_URL="${OD_DAEMON_URL:-http://127.0.0.1:7456}"

if [[ ! -x "$NODE24" ]]; then
  echo "Need Node 24 at: $NODE24"
  echo "Install with nvm, or update NODE24 in this script."
  exit 1
fi

if curl -sf -m 2 "${DAEMON_URL}/api/health" >/dev/null 2>&1; then
  echo "OneHub daemon already running at ${DAEMON_URL}"
else
  echo "Starting OneHub daemon..."
  # background; logs to onehub-daemon.log in LibreChat folder
  nohup "$NODE24" "$OD_BIN" --no-open >>/Users/ryanjordan/librenew/logs/onehub-daemon.log 2>&1 &
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -sf -m 1 "${DAEMON_URL}/api/health" >/dev/null 2>&1; then
      echo "OneHub daemon is up."
      break
    fi
    sleep 1
  done
  if ! curl -sf -m 2 "${DAEMON_URL}/api/health" >/dev/null 2>&1; then
    echo "Daemon did not start. Check logs/onehub-daemon.log"
    echo "Or open the OneHub / Open Design app yourself."
    exit 1
  fi
fi

echo "Health: $(curl -sf "${DAEMON_URL}/api/health")"
echo ""
echo "LibreChat:  http://localhost:3080"
echo "OneHub API: ${DAEMON_URL}"
echo ""
echo "In OneHub Chat: use an Agent, enable the OneHub MCP tools, then ask"
echo "  e.g. \"List my OneHub projects\""
