# Changelog

All notable changes to this repository are documented here. Minor changes (typos, variable renames, cosmetic tweaks) are not listed.

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres [Semantic Versioning](https://semver.org/spec/v2.0.0.html) for app versions.

## [0.0.6] — (unreleased)

### Added

- **Compatibility**: Documentation aligned with Home Assistant 2025.x / 2026.x (terminology “Apps”, Settings → Apps, persistence `/data`, [App configuration](https://developers.home-assistant.io/docs/add-ons/configuration) and [App security](https://developers.home-assistant.io/docs/add-ons/security)).

### Fixed

- **Add-on not starting / "Server file not found"**: Supervisor data volume was mapped at `/app/data`, which could leave `/app` without the image content (server/, node_modules/). Data volume is now mapped at **/data**; options and persistence use `/data` (options.json, dashboard.db, etc.) so **/app** stays from the base image. Requires reinstall or rebuild of the add-on.
- **Dockerfile**: build-time check that base image has `/app/server/index.ts` and `tsx`; build fails with a clear message if the base image is wrong.

### Changed

- **config.yaml**: `map` path changed from `/app/data` to `/data`.
- **run.sh**: reads `/data/options.json`, sets `DATABASE_PATH`, `CONFIG_FILE_PATH`, `FREEBOX_TOKEN_FILE` to `/data/...`.
- **apparmor.txt**: allow read/write on `/data/**` instead of `/app/data/**`.

---

## [0.0.4] — (current)

### Added

- **Security hardening**: reinforcement of the add-on security (configuration, documentation, and runtime behaviour improvements to reduce exposure and follow best practices).  

---

## [0.0.3] — 2026-02-07

### Added

- **update-addon-icon.sh**: download official MynetworK logo (SVG) and convert to `mynetwork/icon.png` (128×128) for the add-on; DOCS and README updated.
- **update-version.sh** (local): version bump script with `chown debian32:debian32` when run as root; when run without argument, displays current version and exact command to type for next version.
- Add-on icon: use official MynetworK logo (PNG generated from upstream SVG).

### Changed

- **run.sh**: robust startup when `/app/docker-entrypoint.sh` is missing — fix `/app/data` permissions, then try entrypoint, else `su-exec node`, else run tsx directly.
- **.gitignore**: ignore `update-version.sh` (local script).

---

## [0.0.2] — 2026-02-07

### Added

- **bump-version.sh**: script to bump version across config, Dockerfile, READMEs, DOCS; prints one-liner for commit and push.
- **.gitignore**: ignore internal spec (`HA_mynetwork_repo_complet_2026.md`), backups, OS/IDE files.
- Root README: official MynetworK logo (from upstream `src/icons/logo_mynetwork.svg`), "Powered by" (Freebox, Ubiquiti), for-the-badge style badges, anchor links.
- Add-on README: logo, badges (version, upstream, Ingress, GHCR), feature list, access and options summary, doc links.

### Changed

- App description in `config.yaml`: removed "(Ingress only, no sensors)" for a cleaner store description.
- bump-version.sh: reminder to update CHANGELOG and suggested git one-liner at end of run.

---

## [0.0.1] — Initial release

- **MynetworK** app for Home Assistant Supervisor.
- **Ingress only** UI (sidebar, internal port 3000, no exposed port).
- Watchdog at `http://[HOST]:[PORT:3000]/api/health`.
- Persistence via Supervisor volume mapped to **/app/data** (aligned with upstream entrypoint).
- Supervisor options and schema: `log_level`, `jwt_secret`, `default_admin_*`, `freebox_host`.
- Network capabilities for scanning: `NET_RAW`, `NET_ADMIN`.
- Translations: `en.yaml`, `fr.yaml`.
- Documentation: DOCS.md (install, UI, persistence, first run, security, troubleshooting), root README and add-on README.
