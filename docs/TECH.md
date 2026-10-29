# BreezeDeploy Free · scrubbed tech notes

## Platform (verified 2026-10-29 Asia/Shanghai)

- Product: BreezeDeploy PaaS ([breezedeploy.dev](https://breezedeploy.dev)), control plane [panel.breezedeploy.dev](https://panel.breezedeploy.dev).
- Free: **1 always-on app**, no credit card, EU hosted, auto TLS on `*.apps.breezedeploy.dev`.
- Deploy modes: public Docker image (`deploy_app`), git/Nixpacks (`deploy_from_git`), local folder (`deploy_source`), local image push. This skill prefers **public image** (no GH App sudo).
- Ingress (USE): `https://<app>.apps.breezedeploy.dev` — A records observed as **OVH Frankfurt DIRECT** (not Cloudflare).
- Ingress (DON'T USE for client): panel host, marketing site, `app-*.breezedeploy.dev` — may sit on CF. Client SNI/Host must be the **apps** hostname only.
- Auth: signup shows API key once (`hk_…`). MCP env `CONTROL_PLANE_API_KEY` + optional `CONTROL_PLANE_URL` (default panel). REST uses `x-api-key` header.
- MCP package: `npx -y breezedeploy-mcp` — tools include `deploy_app`, `deploy_from_git`, `deploy_source`, `get_deployment_job`, `list_apps`, `delete_app`, `whoami`, …

## Image / cover lesson

BreezeDeploy readiness defaults to `/` expecting 2xx/3xx. Plain xray WS on `$PORT` often returns non-200 on `/` → flaky Ready. Cover pattern:

- Public: `edgerelay2610/edge-ws-cover:staxa`
- Or rebuild: `deploy/Dockerfile` + `dual-entry.sh` + `cover.py`
  - cover listens on `$PORT`, returns `ok` on `/`, raw-tunnels WS upgrades for `$WSPATH` to xray on `127.0.0.1:8081`

Do **not** bake live `UUID` / `WSPATH` into the image; set at deploy time.

## Env

| Key | Typical | Notes |
|---|---|---|
| `UUID` | UUIDv4 | rotate per deploy |
| `PORT` | `8080` | listen / readiness |
| `WSPATH` | `/…` | must start with `/` |

## Client

- Port **443**, `security=tls`, `type=ws`, `sni` = `host` = **apps** subdomain.
- Suggested: `fp=chrome`, `alpn=http/1.1`.
- Inside container: plaintext WS to xray (edge already terminated TLS).

## DNS DIRECT gate

Before delivery, resolve apps host via public DoH. Reject CF anycast ranges (`104.x`, `172.64–67.x`, `162.158–159.x`, …). If A flips to CF → stop; **no** preferred-IP / Worker / mid-transit CDN (user policy for PaaS nodes).

## E2E (box, 2026-10-29 Asia/Shanghai)

Pattern verified: `generate_204=204`, exit OVH FRA class AS16276, apps A == exit IP (DIRECT). Live host / UUID / path **omitted** from this repo.

## Ops hygiene

- Save `hk_…` + UUID + WSPATH to local `*.env` **600** before deploy (gitignored).
- Never publish Vault ids, bot emails, or decodeable live `vless://`.
- Free = one app; recreate carefully.
