# Optional rebuild of a cover+WS image similar to edgerelay2610/edge-ws-cover:staxa.
# Prefer the public image on Free (no local Docker / no GH App sudo).
# Base ships xray; this layer adds a Python cover on $PORT that:
#   - returns HTTP 200 "ok" on /  (BreezeDeploy readiness default)
#   - raw-tunnels WebSocket upgrades on $WSPATH to local xray
FROM edgerelay2610/edge-ws:latest
USER root
RUN apk add --no-cache python3
COPY dual-entry.sh /dual-entry.sh
COPY cover.py /cover.py
RUN chmod +x /dual-entry.sh /cover.py
# Do NOT bake real UUID/WSPATH — set them at deploy time via env.
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/dual-entry.sh"]
