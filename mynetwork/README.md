<div align="center">

<img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/src/icons/logo_mynetwork.svg" alt="MynetworK" width="80" height="80" />

# MynetworK

[![Add-on version](https://img.shields.io/badge/version-0.0.7-blue)](https://github.com/Erreur32/HA_mynetwork)
[![MynetworK upstream](https://img.shields.io/badge/MynetworK-official-orange)](https://github.com/Erreur32/MynetworK)
[![Ingress only](https://img.shields.io/badge/Ingress-only-41BDF5)](https://www.home-assistant.io/)
[![Docker](https://img.shields.io/badge/GHCR-mynetwork-0ea5e9?logo=docker&logoColor=white)](https://github.com/Erreur32/MynetworK/pkgs/container/mynetwork)

---

<p align="center">
  <sub>Powered by</sub><br/>
  <img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/img-capture/free-sas.png" alt="Freebox" height="32" />
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/img-capture/ubiquiti-networks.svg" alt="Ubiquiti Unifi" height="32" />
</p>

**A multi-source network dashboard for Freebox, UniFi and your networks — as a Home Assistant add-on (Ingress only).**

[Quick Start](#quick-start) | [Features](#features) | [Installation](#installation) | [Configuration](#configuration) | [Documentation](mynetwork/DOCS.md)

</div>

---

## About

**MynetworK** is a multi-source network dashboard (Freebox, UniFi, network scan). This add-on runs it inside Home Assistant with **Ingress only**: no exposed port, no sensors. Open the **MynetworK** panel from the sidebar to access the full UI.

- **Freebox** — Manage your Freebox (Ultra, Delta, Pop)
- **UniFi** — Monitor and manage your UniFi infrastructure
- **Network scan** — Discover devices (IP, MAC, hostnames, vendors) on your LAN
- **Single panel** — Dashboard, plugins, users and logs in one interface  
 
---

## Features

✔️ Multi-source network dashboard (Freebox, UniFi, network scan)  
✔️ Ingress only — no port exposure, UI in sidebar  
✔️ Persistence in `/data` (database, config, tokens)  
✔️ Watchdog and custom AppArmor profile  
✔️ Compatible with Home Assistant 2025.x / 2026.x (Supervisor, Settings → Apps)  
✔️ Options: `jwt_secret`, admin account, `freebox_host`, log level  

---

## Installation
 

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FErreur32%2FHA_mynetwork)

1. Click the button above
2. Click **ADD** and **RESTART** Home Assistant (if prompted)
3. Go to **Settings** → **Apps** (or [Add-on Store](https://my.home-assistant.io/redirect/supervisor_store/))
4. Search for **"MynetworK"**
5. Click **Install**, then **Start**
6. Open MynetworK from the **sidebar** (Ingress panel)

---

## Configuration

| Option | Description |
|--------|-------------|
| **jwt_secret** | **Required in production** — secures sessions. Set a strong random value. |
| **default_admin_username** | Username of the initial admin account (created on first run if DB is empty). |
| **default_admin_password** | Password for the initial admin account. Set a strong password. |
| **default_admin_email** | Email for the initial admin account. |
| **log_level** | `debug` \| `info` \| `warning` \| `error`. Use **debug** for extra startup diagnostics and Node stack traces in the add-on Log. |
| **freebox_host** | Optional. Freebox host (e.g. `mafreebox.freebox.fr`). |

**Security (Settings → Apps → MynetworK → Information or Configuration → Security):** The app declares `hassio_role: admin` so the **"Protected mode"** toggle can appear. Disable **"Protected mode"** so the app can start and use network scanning (`NET_RAW`/`NET_ADMIN`); with it on, the Supervisor may block the app.

---

## Usage

- **UI**: Open **MynetworK** from the Home Assistant **sidebar** (Ingress panel). No URL or port to configure.
- **First run**: If the database is empty, an admin account is created from the options above. Log in and change the password if needed; ensure **jwt_secret** is set before production use.
- **Data**: Stored in `/data` (database, config, Freebox token). Data persists across restarts and updates.

---

## Troubleshooting

| Problem | Solution |
|--------|----------|
| Add-on does not start | In **Configuration** → **Security**, turn **off** "Protected mode". The add-on needs `NET_RAW`/`NET_ADMIN` for network scanning. |
| App starts then closes immediately | Open the **Log** tab: look for `[MynetworK add-on]` lines and any **ERROR** or Node/TS message. Often: Protected mode still on, or app crash (set **log_level** to `debug` and restart). See [DOCS.md](DOCS.md). |
| Incomplete network scan | If needed, a custom build with `host_network: true` can be used (see [DOCS.md](DOCS.md)). |
| 502 Bad Gateway / no Ingress | Ensure the add-on is **Started** and Protected mode is **off**. Check the **Log** tab for errors. |

---

## Documentation

- **Full add-on documentation**: [DOCS.md](DOCS.md) — installation, persistence, security, troubleshooting, AppArmor.
- **Upstream app**: [MynetworK](https://github.com/Erreur32/MynetworK) — features, Docker, development.

---

## License

This add-on is part of the [HA_mynetwork](https://github.com/Erreur32/HA_mynetwork) repository. See the repository for license details.
