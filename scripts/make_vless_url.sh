#!/usr/bin/env bash
# Usage:
#   UUID=... HOST=your-app.apps.breezedeploy.dev WSPATH=/your-path NAME=Breeze-DE ./scripts/make_vless_url.sh
# HOST must be *.apps.breezedeploy.dev (DIRECT). Do NOT use panel / app-* hostnames.
set -euo pipefail
UUID="${UUID:?set UUID}"
HOST="${HOST:?set HOST (*.apps.breezedeploy.dev only)}"
PORT="${PORT:-443}"
WSPATH="${WSPATH:-/ws}"
NAME="${NAME:-BreezeDeploy}"
case "$HOST" in
  *.apps.breezedeploy.dev) ;;
  *) echo "WARNING: HOST should be *.apps.breezedeploy.dev (DIRECT). Panel/app-* hosts may be CF." >&2 ;;
esac
ENC=$(WSPATH="$WSPATH" python3 -c "import urllib.parse,os; print(urllib.parse.quote(os.environ['WSPATH'], safe=''))")
echo "vless://${UUID}@${HOST}:${PORT}?encryption=none&security=tls&type=ws&host=${HOST}&path=${ENC}&sni=${HOST}&fp=chrome&alpn=http%2F1.1#${NAME}"
