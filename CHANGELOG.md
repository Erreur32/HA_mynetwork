# Changelog

All notable changes to this repository are documented here. Minor changes (typos, variable renames, cosmetic tweaks) are not listed.

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres [Semantic Versioning](https://semver.org/spec/v2.0.0.html) for app versions.

## [0.0.1] — Initial release

- **MynetworK** app for Home Assistant Supervisor.
- **Ingress only** UI (sidebar, internal port 3000, no exposed port).
- Watchdog at `http://[HOST]:[PORT:3000]/api/health`.
- Persistence via Supervisor volume mapped to **/app/data** (aligned with upstream entrypoint).
- Supervisor options and schema: `log_level`, `jwt_secret`, `default_admin_*`, `freebox_host`.
- Network capabilities for scanning: `NET_RAW`, `NET_ADMIN`.
- Translations: `en.yaml`, `fr.yaml`.
- Documentation: DOCS.md (install, UI, persistence, first run, security, troubleshooting), root README and add-on README.
