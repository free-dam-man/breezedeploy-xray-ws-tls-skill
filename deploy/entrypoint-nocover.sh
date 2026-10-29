#!/bin/sh
# Minimal VLESS+WS (no cover). Prefer cover image on BreezeDeploy.
set -eu
UUID="${UUID:-00000000-0000-0000-0000-000000000000}"
PORT="${PORT:-8080}"
WSPATH="${WSPATH:-/ws}"
if [ "$UUID" = "00000000-0000-0000-0000-000000000000" ] || [ "$UUID" = "CHANGE_ME" ]; then
  echo "WARNING: set a real UUID env before handing out client links" >&2
fi
case "$WSPATH" in /*) ;; *) WSPATH="/$WSPATH" ;; esac
CFG=/tmp/xray-config.json
cat > "$CFG" <<JSON
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}", "encryption": "none" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WSPATH}" }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
JSON
echo "starting xray on port ${PORT} path ${WSPATH}"
exec /usr/local/bin/xray run -c "$CFG"
