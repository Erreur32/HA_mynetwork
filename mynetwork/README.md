<div align="center">

<img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/src/icons/logo_mynetwork.svg" alt="MynetworK" width="80" height="80" />

# MynetworK

[![Add-on version](https://img.shields.io/badge/version-0.0.6-blue)](https://github.com/Erreur32/HA_mynetwork)
[![MynetworK upstream](https://img.shields.io/badge/MynetworK-official-orange)](https://github.com/Erreur32/MynetworK)
[![Ingress only](https://img.shields.io/badge/Ingress-only-41BDF5)](https://www.home-assistant.io/)
[![Docker](https://img.shields.io/badge/GHCR-mynetwork-0ea5e9?logo=docker&logoColor=white)](https://github.com/Erreur32/MynetworK/pkgs/container/mynetwork)

<p align="center">
  <strong>Unified Freebox + UniFi + network scan</strong> — in your Home Assistant sidebar.
</p>

</div>

---

## About

**MynetworK** is a multi-source network dashboard (Freebox, UniFi, network scan). This add-on runs it inside Home Assistant with **Ingress only**: no exposed port, no sensors. Open the **MynetworK** panel from the sidebar to access the full UI.

- **Freebox** — Manage your Freebox (Ultra, Delta, Pop)
- **UniFi** — Monitor and manage your UniFi infrastructure
- **Network scan** — Discover devices (IP, MAC, hostnames, vendors) on your LAN
- **Single panel** — Dashboard, plugins, users and logs in one interface  

Data (database, config, Freebox token) is stored in the add-on data volume and persists across restarts and updates.

---

## Quick Start

1. Add the repository: **Settings** → **Apps** → **Repositories** → add `https://github.com/Erreur32/HA_mynetwork`
2. **Refresh** the store, then **Install** the **MynetworK** add-on.
3. Open the add-on **Configuration** tab:
   - Set **jwt_secret** (required in production) and **default_admin_password**.
   - In **Security**, **turn off "Protected mode"** so the add-on can use network capabilities (`NET_RAW`/`NET_ADMIN`) — otherwise it may not start.
4. Click **Start**, then open **MynetworK** from the Home Assistant **sidebar** (Ingress panel).

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
