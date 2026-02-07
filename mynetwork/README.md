<div align="center">

<img src="https://raw.githubusercontent.com/Erreur32/MynetworK/main/src/icons/logo_mynetwork.svg" alt="MynetworK" width="80" height="80" />

# MynetworK

[![Add-on version](https://img.shields.io/badge/version-0.0.3-blue)](https://github.com/Erreur32/HA_mynetwork)
[![MynetworK upstream](https://img.shields.io/badge/MynetworK-official-orange)](https://github.com/Erreur32/MynetworK)
[![Ingress only](https://img.shields.io/badge/Ingress-only-41BDF5)](https://www.home-assistant.io/)
[![Docker](https://img.shields.io/badge/GHCR-mynetwork-0ea5e9?logo=docker&logoColor=white)](https://github.com/Erreur32/MynetworK/pkgs/container/mynetwork)

<p align="center">
  <strong>Unified Freebox + UniFi + network scan</strong> — in your Home Assistant sidebar.
</p>

</div>

---

## What this add-on does

**MynetworK** is a multi-source network dashboard. This add-on runs it inside Home Assistant with **Ingress only**: no exposed port, no sensors. Open the **MynetworK** panel from the sidebar to access the full UI.

- **Freebox** — Manage your Freebox (Ultra, Delta, Pop) from one place  
- **UniFi** — Monitor and manage your UniFi infrastructure  
- **Network scan** — Discover devices (IP, MAC, hostnames, vendors) on your LAN  
- **Single panel** — Dashboard, plugins, users and logs in one interface  

Data (database, config, Freebox token) is stored in the add-on data volume and persists across restarts and updates.

---

## Access

- **UI**: Open **MynetworK** from the Home Assistant **sidebar** (Ingress panel). No URL or port to configure.
- **First run**: An admin account is created from the add-on options. Set a strong **password** and **jwt_secret** in the Configuration tab before production use.

---

## Main options

| Option | Description |
|--------|-------------|
| `jwt_secret` | **Required in production** — secures sessions |
| `default_admin_username` / `_password` / `_email` | Initial admin account |
| `log_level` | debug / info / warning / error |
| `freebox_host` | Optional (e.g. `mafreebox.freebox.fr`) |

---

## Documentation

- **Full add-on docs**: [DOCS.md](DOCS.md) — installation, persistence, security, troubleshooting  
- **Upstream app**: [MynetworK](https://github.com/Erreur32/MynetworK) — features, Docker, development  
