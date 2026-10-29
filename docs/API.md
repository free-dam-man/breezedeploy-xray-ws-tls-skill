# BreezeDeploy control plane · short notes (no secrets)

## Env for MCP / CLI

| Var | Meaning |
|---|---|
| `CONTROL_PLANE_API_KEY` | API key from panel signup / “Get my key” (`hk_…`). **Never commit.** |
| `CONTROL_PLANE_URL` | Default `https://panel.breezedeploy.dev` |

Install / run: `npx -y breezedeploy-mcp`

## Useful MCP tools

| Tool | Use |
|---|---|
| `deploy_app` | Deploy a Docker image → HTTPS URL (creates project if needed) |
| `get_deployment_job` | Poll accepted job until URL ready |
| `list_apps` | Status + URL for a project |
| `delete_app` | Stop by name |
| `whoami` | Connection / tenant debug |
| `deploy_from_git` / `deploy_source` | Alt paths (this skill prefers public image) |

## REST sketch

- Base: `CONTROL_PLANE_URL`
- Auth: header `x-api-key: <hk_…>`
- Deploy image into a project (exact paths follow current panel OpenAPI / MCP client). Prefer MCP when available so job polling (`jobId` / `pollAfterMs`) is handled consistently.

## Client hostname rule

Returned live URL must be of the form `https://<app>.apps.breezedeploy.dev`. Do not substitute panel or `app-*` hostnames into the VLESS `host` / `sni`.
