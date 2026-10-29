# deploy/

## Preferred (Free · no GH App sudo)

Use the public cover image directly:

```text
edgerelay2610/edge-ws-cover:staxa
```

Env at deploy time (never bake into the image / never commit):

| Env | Required | Notes |
|---|---|---|
| `UUID` | yes | fresh UUIDv4 |
| `WSPATH` | yes | must start with `/` |
| `PORT` | yes | `8080` (platform default) |

BreezeDeploy MCP: `deploy_app` with that image + env. Client host = `<app>.apps.breezedeploy.dev` only.

## Optional local rebuild

```bash
docker buildx build --platform linux/amd64 -t YOUR_REGISTRY/edge-ws-cover:local --push .
```

`Dockerfile` + `dual-entry.sh` + `cover.py` recreate the cover+WS pattern (HTTP 200 on `/`, WS tunnel on `$WSPATH`).

`Dockerfile.alpine-nocover` + `entrypoint-nocover.sh` = plain xray only (no `/` 200). Not recommended on BreezeDeploy Free readiness default.
