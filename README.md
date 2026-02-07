# MynetworK Apps — Home Assistant

[![HA add-on version](https://img.shields.io/badge/HA_mynetwork-0.0.1-blue)](https://github.com/Erreur32/HA_mynetwork)
[![Based on MynetworK](https://img.shields.io/badge/based%20on-MynetworK-orange)](https://github.com/Erreur32/MynetworK)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-App%20(Supervisor)-41BDF5)](https://www.home-assistant.io/)

Home Assistant (Supervisor) app repository for **MynetworK**. The MynetworK app is **Ingress only**: UI via the sidebar only, no sensors exposed to Home Assistant.

**Version:** This repository provides the **HA_mynetwork** add-on **v0.0.1**. The add-on wraps the official **[MynetworK](https://github.com/Erreur32/MynetworK)** application (multi-source network dashboard: Freebox, UniFi, network scan). Check the [official MynetworK repo](https://github.com/Erreur32/MynetworK) for upstream releases and features.

App presentation follows [Home Assistant "Presenting your app"](https://developers.home-assistant.io/docs/apps/presentation): **intro** (short app store summary) is in [mynetwork/README.md](mynetwork/README.md), full **documentation** in [mynetwork/DOCS.md](mynetwork/DOCS.md), and version history in [CHANGELOG.md](CHANGELOG.md). Structure matches the [Making your first app](https://developers.home-assistant.io/docs/apps/tutorial) tutorial: `Dockerfile`, `config.yaml`, and `run.sh` in each app folder.

## Prerequisites

- Home Assistant with Supervisor.
- Multi-arch MynetworK Docker image published: `ghcr.io/erreur32/mynetwork` (tags aligned with add-on version, e.g. `0.0.1`), for **amd64**, **aarch64**, **armv7**.

## Installation

**One-click links (My Home Assistant):**

1. Open your Home Assistant instance and show the **App store**, then add the repository URL below.
2. Or add this repository directly (opens the "Add repository" dialog with this repo pre-filled).

| Action | Link |
|--------|------|
| **Open App Store** | [![Open your Home Assistant instance and show the App store.](https://my.home-assistant.io/badges/supervisor_store.svg)](https://my.home-assistant.io/redirect/supervisor_store/) |
| **Add this repository** | [![Add repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FErreur32%2FHA_mynetwork) |

**Manual steps:**

1. In Home Assistant: **Settings** → **Apps** → **Repositories** (or **Supervisor** → **Add-on store** → **Repositories**).
2. Add this repository with URL:
   ```text
   https://github.com/Erreur32/HA_mynetwork
   ```
3. Reload repositories if prompted.
4. Install **MynetworK** from the add-on list.
5. Configure options (admin password, `jwt_secret` recommended), then **Start**.
6. Open MynetworK from the **sidebar** (Ingress panel).

## Repository structure

```text
HA_mynetwork/
├── repository.yaml          # Repository definition (name, URL, maintainer)
├── README.md                # This file
├── CHANGELOG.md             # Version history
└── mynetwork/               # MynetworK app
    ├── config.yaml          # Supervisor config (Ingress, watchdog, options)
    ├── Dockerfile           # Wrapper over ghcr.io/erreur32/mynetwork image
    ├── run.sh               # Startup script (options → env → upstream entrypoint)
    ├── apparmor.txt         # Custom AppArmor profile (security, see HA presentation doc)
    ├── DOCS.md              # Full documentation (install, UI, persistence, security)
    ├── README.md            # App intro (app store)
    ├── icon.png             # App icon
    └── translations/
        ├── en.yaml
        └── fr.yaml
```

## Documentation

- **Installation, configuration, persistence, security and troubleshooting**: see [mynetwork/DOCS.md](mynetwork/DOCS.md).

## Maintainer

Erreur32
