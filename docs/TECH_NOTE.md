# BreezeDeploy Free 部署技术总结（已脱敏）

- 日期：2026-10-29 Asia/Shanghai（箱内 E2E 跑通并验收）
- 平台：BreezeDeploy Free（1 常驻应用、免卡、EU）
- 协议：VLESS + WebSocket + TLS；cover 负责 `/` = 200
- 客户端主机：**仅** `*.apps.breezedeploy.dev`（DIRECT / OVH FRA 类）
- **禁止**：CF 中转、优选 IP、Worker 前门；勿把 panel / `app-*` 当客户端域名
- 镜像：公共 `edgerelay2610/edge-ws-cover:staxa`（或本仓 `deploy/` 自建）
- 状态：箱内 `generate_204=204`，出口与 apps A 一致（DIRECT）。**真实 UUID / path / host / hk_ / 邮箱 / Vault id 未写入本仓库。**

## 1. 平台侦察

- Free：1 always-on、免卡、自动 TLS。
- 部署：优先 public Docker + MCP `deploy_app`（免 GH App sudo）。
- 控制面：`https://panel.breezedeploy.dev`；密钥一次性展示。
- apps 子域 A = 欧陆机房直连；panel/营销域可能走 CF —— 客户端绝不用。

## 2. 镜像

cover+xray：公网健康检查要 `/` 200；WS 路径隧道到本地 xray。不要把真 UUID/WSPATH 写进 Dockerfile `ENV`。

## 3. 部署流程（脱敏）

1. 注册 panel → 邮箱确认 → Vault 存密码 → 复制 `hk_…` 到本地 secrets。
2. `deploy_app`：image=`edgerelay2610/edge-ws-cover:staxa`，env `UUID` / `WSPATH` / `PORT=8080`。
3. 记下 `https://<app>.apps.breezedeploy.dev`。
4. DoH 查 A：必须非 CF。
5. 组 VLESS URL（占位符）→ SOCKS → `generate_204=204` 且出口=A。

## 4. 验收

- cover `/` → HTTP 200
- 客户端 generate_204 → 204
- 出口 IP == apps A（DIRECT）
- 面板 Ready alone 不算过

## 5. 已知缺陷 / 限制

- Free 仅 1 应用；出口是机房 IP，不是真家宽。
- DNS 可能变更；每次交付重做 DoH。
- WS 在新 Xray 标废弃；本路径因边缘 HTTP 仍用 WS。

## 6. 可复用经验

- PaaS 健康检查要 cover，别裸 xray 顶 `/`。
- 客户端主机与 DNS 证据绑死；CF 就停，不破墙加前门。
- 公共镜像路径避开 GH App sudo 摩擦。
