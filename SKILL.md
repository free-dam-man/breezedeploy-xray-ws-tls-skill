# breezedeploy-xray-ws-tls-skill

## When to use
**Agent 一句话 / one-sentence:** deploy a **zero-card Free** **VLESS + WS + TLS** spare node on **BreezeDeploy** ([breezedeploy.dev](https://breezedeploy.dev) / [panel.breezedeploy.dev](https://panel.breezedeploy.dev)) via **public Docker image** / MCP `deploy_app` (not GitHub App sudo). Client host **must** be `*.apps.breezedeploy.dev` (DIRECT).

## Do
1. Signup panel → confirm email → Vault password → copy `hk_…` once to secrets `600`.
2. Prefer image `edgerelay2610/edge-ws-cover:staxa` (or rebuild scrubbed `deploy/`).
3. MCP `deploy_app` / REST with `CONTROL_PLANE_API_KEY` + `CONTROL_PLANE_URL=https://panel.breezedeploy.dev`. Env: fresh `UUID`, `WSPATH` (leading `/`), `PORT=8080`.
4. Client: `type=ws&security=tls&sni=<HOST>&host=<HOST>&path=<WSPATH>&fp=chrome&alpn=http/1.1` on `:443` where `HOST=<app>.apps.breezedeploy.dev`.
5. Mandatory DoH A: non-CF (expect OVH / EU DC). If CF → stop; no preferred-IP / Worker front.
6. E2E: real client → SOCKS → `generate_204=204` + exit IP == apps A. Scrub before any public commit.

## Don't
- Don't use panel / `app-*` / non-apps hostnames for the client (may be CF).
- Don't 破CF / preferred-IP / Worker 前门 / mid-transit CDN.
- Don't require GH App sudo when public image works.
- Don't commit `api.key`, live UUID/path/host, emails, Vault ids, or decodeable live `vless://`.
- Don't treat panel Ready as success without E2E + DNS DIRECT.
- Don't call OVH FRA exit 真家宽; Free = **1** always-on app only.

## Workflow (口令)
```text
panel signup+confirm+Vault+hk_ → deploy_app edgerelay2610/edge-ws-cover:staxa → UUID+WSPATH+PORT=8080 → *.apps.breezedeploy.dev only → DoH A non-CF → SOCKS generate_204=204 + exit=A → deliver; scrub; no CF front
```
