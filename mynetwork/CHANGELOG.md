# Changelog

All notable changes to the MynetworK add-on are documented here.

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.8]

### Added

- **build.yaml**: Supervisor now builds from the correct base image (`ghcr.io/erreur32/mynetwork`) so the add-on includes the full MynetworK app.

### Fixed

- **Dockerfile**: Build step `apk add jq` now runs as root (fixes "Permission denied" when building from the MynetworK base image).

---

## [0.0.6]

### Added

- Documentation aligned with Home Assistant 2025.x / 2026.x (Settings → Apps, persistence `/data`).

### Fixed

- **Add-on not starting / "Server file not found"**: Data volume is now mapped at `/data` instead of `/app/data`, so `/app` (server, node_modules) is no longer overwritten. Reinstall or update the add-on for the fix.
- **Dockerfile**: Build fails with a clear message if the base image is missing the app.

### Changed

- **config.yaml**: `map` path `/app/data` → `/data`.
- **run.sh**: Options and persistence use `/data` (options.json, dashboard.db, etc.).
- **apparmor.txt**: Read/write on `/data/**`.

---

## [0.0.4]

### Added

- Security hardening (configuration, documentation, runtime behaviour).

---

## [0.0.3]

### Added

- Add-on icon: official MynetworK logo (PNG).

### Changed

- **run.sh**: Robust startup when upstream entrypoint is missing (fallback to su-exec node or direct tsx).

---

## [0.0.2]

### Added

- Root and add-on README with logo, badges, feature list, options summary.

### Changed

- App description in config cleaned up.

---

## [0.0.1]

- Initial release.
- MynetworK app for Home Assistant Supervisor.
- Ingress only (sidebar, port 3000).
- Watchdog at `/api/health`.
- Persistence, options (log_level, jwt_secret, default_admin_*, freebox_host).
- NET_RAW, NET_ADMIN for network scanning.
- Translations (en, fr), DOCS.md, README.md.
