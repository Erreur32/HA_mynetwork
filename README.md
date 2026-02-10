# Home Assistant Add-on Repository: MynetworK

<div align="center">

<img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/src/icons/logo_mynetwork.svg" alt="MynetworK" width="96" height="96" />

![MynetworK](https://img.shields.io/badge/MynetworK-HA%20Add--on-111827?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-stable-374151?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Ready-1f2937?style=for-the-badge&logo=docker&logoColor=38bdf8)
[![Docker Image](https://img.shields.io/badge/GHCR-ghcr.io%2Ferreur32%2Fmynetwork-1f2937?style=for-the-badge&logo=docker&logoColor=38bdf8)](https://github.com/Erreur32/MynetworK/pkgs/container/mynetwork)
[![Release][release-shield]][release]
[![MynetworK][mynetwork-shield]][mynetwork-upstream]
[![Home Assistant][ha-shield]][ha]
[![License][license-shield]][license]
[![Issues][issues-shield]][issue]
[![Stargazers][stars-shield]][stars]

<h1 align="center">MynetworK</h1>
<p align="center">
  Unified Freebox + UniFi management in Home Assistant.
</p>

![Screen dashboard](https://github.com/Erreur32/MynetworK/raw/main/img-capture/dashboard.png?raw=true)

---

<p align="center">
  <sub>Powered by</sub><br/>
  <img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/img-capture/free-sas.png" alt="Freebox" height="32" />
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/img-capture/ubiquiti-networks.svg" alt="Ubiquiti Unifi" height="32" />
</p>

**A multi-source network dashboard for Freebox, UniFi support and Network Scanner devices  your entires networks as a Home Assistant add-on (Ingress).**

[Quick Start](#quick-start) | [Features](#features) | [Installation](#installation) | [Configuration](#configuration) | [Documentation](mynetwork/DOCS.md) | [Documentation FR](mynetwork/DOCS_FR.md)

</div>

---

## About

This repository contains the **MynetworK** app (add-on) for Home Assistant.

**Current version:** `0.1.19` | **Based on MynetworK:** `v0.7.5`

[MynetworK](https://github.com/Erreur32/MynetworK) is a multi-source network dashboard (Freebox, UniFi, network scan).

This add-on runs MynetworK inside Home Assistant with **Ingress** and  exposed port, no sensors; the UI is available from the sidebar panel.

 

---

## Quick Start

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FErreur32%2FHA_mynetwork)

1. Click the button above
2. Click **ADD** and **RESTART** Home Assistant (if prompted)
3. Go to **Settings** → **Apps** (or [Add-on Store](https://my.home-assistant.io/redirect/supervisor_store/))
4. Search for **"MynetworK"**
5. Click **Install**, then **Start**
6. Open MynetworK from the **sidebar** (Ingress panel)

---

## Repository Structure

```
HA_mynetwork/
├── repository.yaml              # Repository metadata
├── README.md                    # This file
├── scripts/
│   └── update-version.sh       # Bump version across the repo before push
└── mynetwork/                   # MynetworK add-on
    ├── config.yaml
    ├── Dockerfile
    ├── run.sh
    ├── apparmor.txt
    ├── build.yaml
    ├── CHANGELOG.md             # Changelog (visible in HA app)
    ├── DOCS.md
    ├── DOCS_FR.md
    ├── README.md
    ├── icon.png
    └── translations/
        ├── en.yaml
        └── fr.yaml
```

For detailed add-on documentation, see [mynetwork/DOCS.md](mynetwork/DOCS.md) | [DOCS_FR.md](mynetwork/DOCS_FR.md) and [mynetwork/README.md](mynetwork/README.md).

---

## Features

✔️ Multi-source network dashboard (Freebox, UniFi, network scan)  
✔️ Ingress only — no port exposure, UI in sidebar  
✔️ Persistence in `/data` (database, config, tokens)  
✔️ Watchdog and custom AppArmor profile  
✔️ Compatible with Home Assistant 2025.x / 2026.x (Supervisor, Settings → Apps)  
✔️ Options: `jwt_secret`, `freebox_host`, log level  

---

## Installation

1. **Open the Home Assistant Add-on Store**  
   [Access the Store](https://my.home-assistant.io/redirect/supervisor_store/)

2. **Add this repository**
   ```
   https://github.com/Erreur32/HA_mynetwork
   ```

3. **Search for "MynetworK"** in the Add-on Store

4. **Install** the add-on and **Start** it

5. Open **MynetworK** from the sidebar (Ingress panel)

---

## Configuration

Configure the add-on in the **Configuration** tab. Main options:

| Option | Description |
|--------|-------------|
| `log_level` | debug / info / warning / error |
| `jwt_secret` | **Required in production** — secures sessions |
| `freebox_host` | Optional (e.g. `mafreebox.freebox.fr`) |

> **Note:** Admin credentials (username, password, email) are managed by the MynetworK app itself, not in the HA add-on config. See "First run" below.

See [mynetwork/DOCS.md](mynetwork/DOCS.md) for full documentation — [Version française](mynetwork/DOCS_FR.md).

---

## Usage

- **UI**: Open the **MynetworK** panel from the Home Assistant sidebar. No URL or port to remember.
- **Data**: Stored in the app data volume (`/data`): database, config, Freebox token. Data persists across restarts and updates.

### First run

On first launch (empty database), the app automatically creates a default admin account:

| | |
|---|---|
| **Username** | `admin` |
| **Password** | `admin123` |

1. Log in with these default credentials.
2. **Change the password immediately** via the MynetworK UI (user settings).
3. Configure your plugins (Freebox, UniFi, Network Scan) in **Plugins**.
4. Set a strong `jwt_secret` in the add-on Configuration tab.

> Credentials are stored in the app database and managed entirely via the MynetworK UI. They are **never** overwritten by the add-on configuration on restart.

---
 

## Support

Questions or issues? Open an issue: [issue tracker][issue].

## Contributing

This is an open-source project. Contributions are welcome.

## Authors & contributors

The original setup of this repository is by [Erreur32][erreur32].

For a full list of contributors, see [the contributor's page][contributors].

## License

MIT License — see the [LICENSE][license] file for details.

[contributors]: https://github.com/Erreur32/HA_mynetwork/graphs/contributors
[erreur32]: https://github.com/Erreur32
[issue]: https://github.com/Erreur32/HA_mynetwork/issues
[license]: https://github.com/Erreur32/HA_mynetwork/blob/main/LICENSE
[maintenance-shield]: https://img.shields.io/maintenance/yes/2026.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[release-shield]: https://img.shields.io/badge/version-v0.1.19-blue.svg
[release]: https://github.com/Erreur32/HA_mynetwork/releases/tag/v0.1.19
[license-shield]: https://img.shields.io/badge/license-MIT-blue.svg
[mynetwork-shield]: https://img.shields.io/badge/MynetworK%20v0.7.5-orange.svg
[mynetwork-upstream]: https://github.com/Erreur32/MynetworK
[ha-shield]: https://img.shields.io/badge/Home%20Assistant-App%20(Supervisor)-41BDF5.svg
[ha]: https://www.home-assistant.io/
[issues-shield]: https://img.shields.io/github/issues/Erreur32/HA_mynetwork.svg
[stars-shield]: https://img.shields.io/github/stars/Erreur32/HA_mynetwork.svg
[stars]: https://github.com/Erreur32/HA_mynetwork/stargazers
