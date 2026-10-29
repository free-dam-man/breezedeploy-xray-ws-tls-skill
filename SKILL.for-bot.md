---
name: breezedeploy-one-line-node
description: >-
  Use when the user wants a one-sentence / Agent 一句话 zero-card Free VLESS+WS+TLS
  node on BreezeDeploy (breezedeploy.dev / panel.breezedeploy.dev) via public
  Docker image or MCP deploy_app — no GitHub App sudo, E2E generate_204,
  scrubbed vless:// delivery. Also when they say BreezeDeploy Free,
  *.apps.breezedeploy.dev, or ask to publish/replicate the
  breezedeploy-xray-ws-tls-skill pack.
---
# BreezeDeploy One-Line Node (Free · VLESS + WS + TLS · DIRECT IP)

Deploy a **zero-card** spare **VLESS + WebSocket + TLS** node on [BreezeDeploy](https://breezedeploy.dev) / [panel](https://panel.breezedeploy.dev) from one sentence. Free = **1 always-on app**, no cold start, no card. Prefer **public Docker image** via `deploy_app` / MCP — **no GitHub App sudo**.

Upstream pack: https://github.com/free-dam-man/breezedeploy-xray-ws-tls-skill (MIT). Local copy of `deploy/` may also live under `/workspace/oss/breezedeploy-xray-ws-tls-skill/deploy/` on this box.

Verified pattern (2026-10-29 Asia/Shanghai): `*.apps.breezedeploy.dev` A → **OVH Frankfurt DIRECT** (not Cloudflare). Client must use **apps** hostname only.

## When to use
- User:「Agent 一句话 BreezeDeploy 出节点」「Breeze Free 免卡」「*.apps.breezedeploy.dev」
- Need Free EU PaaS with **direct IP** edge TLS (no CF transit / 优选 IP / Worker 前门)

## Do
1. **Signup** [panel.breezedeploy.dev/signup](https://panel.breezedeploy.dev/signup) with a durable bot email. Vault-generate password end-to-end. Confirm email before deploy.
2. Panel → **Get my key** (`hk_…`). Save once to secrets `600` (never chat, never commit). Panel / marketing hostnames may sit on CF — **ignore for client traffic**.
3. Pick image path (preferred Free, no GH sudo):
   - Public image: `edgerelay2610/edge-ws-cover:staxa` (or rebuild from pack `deploy/`).
   - Or MCP `deploy_app` / REST with `x-api-key`.
4. Create/choose project + app names (app → subdomain). Env:
   - `UUID` = fresh UUIDv4
   - `WSPATH` = `/…` (leading `/`)
   - `PORT=8080` (platform default)
5. Wait Ready. Client host = `https://<app>.apps.breezedeploy.dev` only.
6. **DNS check (mandatory):** Google DoH A for that host must be **non-CF**. Expect OVH / EU DC. If A is CF anycast → **stop**; do not 破CF / preferred-IP / Worker front.
7. Build URL:
   `vless://<UUID>@<HOST>:443?encryption=none&security=tls&type=ws&host=<HOST>&path=<urlencoded WSPATH>&sni=<HOST>&fp=chrome&alpn=http%2F1.1#Breeze-DE`
8. E2E: real client → SOCKS → `https://www.gstatic.com/generate_204` = **204**; exit IP must match apps A (DIRECT). Cover `/` should be HTTP 200.
9. Deliver scrubbed link + QR. Append registry if this bot keeps one. Never commit live UUID/path/key/`hk_`.

### MCP one-liner (after key in env)
```bash
# CONTROL_PLANE_API_KEY=hk_… CONTROL_PLANE_URL=https://panel.breezedeploy.dev
# In agent chat / MCP: deploy_app image=edgerelay2610/edge-ws-cover:staxa app=<name> project=<proj> port=8080 env={UUID,WSPATH,PORT}
```
Or wire MCP: `npx -y breezedeploy-mcp` with those env vars.

## Don't
- Don't use `app-*.breezedeploy.dev`, bare `*.breezedeploy.dev`, or panel hostnames for the client — those can be **CF**.
- Don't 破CF / preferred-IP / Worker 前门 / mid-transit CDN. User forbids CF transit for PaaS nodes.
- Don't require GitHub App install / sudo OTP when Docker image path works.
- Don't commit `api.key`, live UUID/path/host, or decodeable live `vless://`.
- Don't treat panel Online alone as success without E2E 204 + DNS DIRECT proof.
- Don't call OVH Frankfurt exit 真家宽.
- Don't promise multi-app Free (Free = **1** always-on app).

## Limits (honest)
- Free forever: 1 app, always-on, EU hosted, auto TLS on `*.apps.breezedeploy.dev`.
- Exit = EU datacenter IP (verified OVH FRA class) — spare / backup, not residential.
- China reachability: verify on phone; direct-IP platforms have worked when CF-hostname ones timed out.

## Launch 口令
```text
BreezeDeploy 免卡：panel 注册+邮箱确认+Vault 密码+取 hk_ → deploy_app 公共镜像 edgerelay2610/edge-ws-cover:staxa（禁 GH sudo）→ UUID+WSPATH+PORT=8080 → 只用 <app>.apps.breezedeploy.dev → DoH A 非 CF（OVH 直连）→ SOCKS generate_204=204 且出口=A → 交付 scrub；禁 CF 中转/优选/Worker 前门。
```
