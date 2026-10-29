# BreezeDeploy · VLESS + WS + TLS 一键复刻（Free / 免卡 / DIRECT IP）

> BreezeDeploy（[breezedeploy.dev](https://breezedeploy.dev) / [panel.breezedeploy.dev](https://panel.breezedeploy.dev)）Free：平台边缘终止 TLS，容器内跑 **VLESS + WebSocket（明文）+ HTTP cover**。  
> 客户端侧：`security=tls` + `type=ws` + **`*.apps.breezedeploy.dev:443` only**。

**English:** Free plan = **1 always-on app**, no card, no cold start. Prefer **public Docker image** via MCP `deploy_app` / REST (`x-api-key`) — **no GitHub App sudo**. Verified **2026-10-29 Asia/Shanghai**: E2E `generate_204=204`, exit **OVH Frankfurt datacenter** (DIRECT A, **not** Cloudflare). Live UUID / path / host / API keys are **not** published here — placeholders only.

Sibling skills:

- [pxxl-xray-ws-tls-skill](https://github.com/free-dam-man/pxxl-xray-ws-tls-skill) — Pxxl · WS + TLS (GH App Node)
- [hubfly-xray-ws-tls-skill](https://github.com/free-dam-man/hubfly-xray-ws-tls-skill) — Hubfly · WS + TLS
- [wispbyte-xray-ws-skill](https://github.com/free-dam-man/wispbyte-xray-ws-skill) — Pterodactyl 明文 WS 备用
- [zoho-catalyst-appsail-xhttp-skill](https://github.com/free-dam-man/zoho-catalyst-appsail-xhttp-skill) — Zoho AppSail · XHTTP + TLS
- [light-cloud-xhttp-skill](https://github.com/free-dam-man/light-cloud-xhttp-skill) — Light Cloud · XHTTP

---

## 为什么选 BreezeDeploy Free / Why this Free path

| Free trait | Consequence |
|---|---|
| 1 always-on app, no card | One spare DIRECT node; don't promise multi-app |
| Public Docker / MCP `deploy_app` | **No** GitHub App install / sudo OTP |
| Edge TLS on `*.apps.breezedeploy.dev` | Client `security=tls` on `:443`; inside = plain WS on `$PORT` |
| Apps A = EU DC (OVH FRA class) | **DIRECT** — do **not** put CF / preferred-IP / Worker mid-transit |
| Panel / marketing may be on CF | **Don't use** panel or `app-*` hostnames as client SNI/Host |

Xray 新版本已标 WS 废弃；本技能保留 WS 是因为 Free 边缘是 HTTP→容器。日常中国入口仍可优先 Zoho / Light Cloud **XHTTP+TLS**；Breeze 当 **DIRECT 备用**。

---

## 架构 / Architecture

```text
Shadowrocket / v2rayN / sing-box / Xray
   │  VLESS + WS + TLS   sni=host=<*.apps.breezedeploy.dev>   :443
   ▼
BreezeDeploy edge (TLS on apps hostname)     ← A must be DIRECT (non-CF)
   │  plain HTTP/WS → container :$PORT
   ▼
cover+xray container (edgerelay2610/edge-ws-cover:staxa or deploy/)
   ├─ cover.py  → HTTP 200 on /  (readiness); tunnel WS on $WSPATH
   └─ xray      → VLESS/WS listen 127.0.0.1:8081  path=$WSPATH
        └─ exit = EU datacenter IP (OVH FRA class — not 真家宽)
```

---

## Do / Don't

### Do
1. Signup [panel.breezedeploy.dev/signup](https://panel.breezedeploy.dev/signup); confirm email; Vault-store password.
2. Panel → **Get my key** once (`hk_…`). Save to local secrets `600` — never commit / never paste in public issues.
3. Deploy public image `edgerelay2610/edge-ws-cover:staxa` with env `UUID` + `WSPATH` + `PORT=8080` (MCP `deploy_app` or REST).
4. Client host = **`<app>.apps.breezedeploy.dev` only**.
5. **DNS check (mandatory):** Google DoH A for that host must be **non-CF** (not `104.x` / `172.64–67.x` / `162.158–159.x`). Expect OVH / EU DC.
6. E2E: real client → SOCKS → `generate_204=204` and exit IP == apps A.

### Don't
- Don't use `app-*.breezedeploy.dev`, bare `*.breezedeploy.dev`, or panel URLs for the client — those can be **CF**.
- Don't 破CF / preferred-IP / Worker 前门 / mid-transit CDN for this PaaS node.
- Don't require GitHub App sudo when the public image path works.
- Don't commit `api.key`, live UUID/path/host, or decodeable live `vless://`.
- Don't treat panel Online alone as success without E2E + DNS DIRECT proof.
- Don't call OVH Frankfurt exit 真家宽.

---

## 快速复刻 / Reproduce

1. **Register / login** [panel.breezedeploy.dev](https://panel.breezedeploy.dev); confirm email; copy API key once.
2. **Wire MCP** (optional):

```bash
# CONTROL_PLANE_API_KEY=<your hk_…>   # never commit
# CONTROL_PLANE_URL=https://panel.breezedeploy.dev
npx -y breezedeploy-mcp
# chat: deploy_app image=edgerelay2610/edge-ws-cover:staxa app=<name> project=<proj> port=8080
#       env UUID=<fresh> WSPATH=/<path> PORT=8080
```

REST equivalent: `x-api-key` header against `https://panel.breezedeploy.dev` (see `docs/API.md`).

3. Env (**never commit live values**):

| Env | Example | Notes |
|---|---|---|
| `UUID` | fresh UUIDv4 | **required** |
| `WSPATH` | `/your-rail` | must start with `/` |
| `PORT` | `8080` | platform default / readiness |

4. Wait Ready. Note `https://<app>.apps.breezedeploy.dev`.
5. **DoH A check** — must be DIRECT (non-CF). If A is CF anycast → **stop** (do not add CF front).
6. **Client URL**（占位符）:

```text
vless://<UUID>@<HOST>:443?encryption=none&security=tls&type=ws&host=<HOST>&path=<urlencoded WSPATH>&sni=<HOST>&fp=chrome&alpn=http%2F1.1#Breeze-DE
```

Helper: `scripts/make_vless_url.sh`

7. **Verify**：真实客户端 → SOCKS → `https://www.gstatic.com/generate_204` 期望 **204**；出口 IP = apps A；cover `/` = HTTP 200。面板 Ready alone **不算**验收。

Optional rebuild from `deploy/` if you need your own registry tag (see `deploy/README.md`).

---

## 仓库内容 / Layout

```text
deploy/Dockerfile              # optional cover+WS rebuild (no baked secrets)
deploy/dual-entry.sh + cover.py
deploy/Dockerfile.alpine-nocover  # plain xray fallback (not preferred)
scripts/make_vless_url.sh
docs/TECH.md / TECH_NOTE.md / API.md
SKILL.md                       # agent brief
SKILL.for-bot.md               # bot skill frontmatter + 口令
LICENSE                        # MIT
```

Defaults use **placeholders** (`<UUID>` `<WSPATH>` `<HOST>`). Never publish live UUID、path、host、`hk_` keys、email、Vault ids、or decodeable live subscriptions.

---

## 诚实限制 / Honest limits

- **Free = 1 always-on app** — spare / backup, not a fleet.
- **出口 = EU 机房** — verified OVH FRA class; not 真家宽; IP may change on recreate.
- **WS 在新 Xray 已标废弃** — 日常中国入口仍可优先 XHTTP+TLS 兄弟技能。
- **条款** — 自用复刻；勿公开滥发开放中继。
- **DNS 会变** — 每次交付前重做 DoH A；A 变 CF 就停，不要硬破。

---

## One-liner 口令 / Agent prompt

```text
照 https://github.com/free-dam-man/breezedeploy-xray-ws-tls-skill ：panel 注册+邮箱确认+Vault 密码+取 hk_ → MCP/REST deploy_app 公共镜像 edgerelay2610/edge-ws-cover:staxa（禁 GH sudo）→ UUID+WSPATH+PORT=8080 → 只用 <app>.apps.breezedeploy.dev → DoH A 非 CF（OVH 直连）→ SOCKS generate_204=204 且出口=A → 交付 scrub；禁 CF 中转/优选/Worker 前门；勿提交真 UUID/path/hk_。
```

---

## License

MIT — copy, fork, teach. Freedom / no-walls.
