# 📋 Changelog MynetworK Add-on

## [v0.5.6] - 2026-02-05
### 🔧 Changed
- Version bump to trigger Home Assistant add-on update.

## [v0.5.5] - 2026-02-05
### ✅ Fixed
- `s6-overlay-suexec: fatal: can only run as pid 1` → `exec npx tsx server/index.ts`
- Add-on HA Supervisor compatible (`init: false`)
- Protection mode support (`docker_api:ro`)

### ✨ Added
- Documentation complète (DOCS.md)
- Ingress UI port 3000
- Host network + privileged NET_ADMIN/RAW

## [v0.5.0] - 2026-01-XX
### ✨ Added
- Scan réseau complet (IP/MAC/hostname/ports)
- Freebox API intégration (token/host)
- UI web responsive
- better-sqlite3 natif optimisé

### 🔧 Changed
- Node.js 22 Alpine multi-stage build
- tsx runtime TypeScript production

## [v0.1.0] - 2025-12-XX
### ✨ Initial
- Port depuis Docker standalone
- Configuration bashio
