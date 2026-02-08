# MynetworK — Home Assistant App

![MynetworK](https://raw.githubusercontent.com/Erreur32/HA_mynetwork/main/mynetwork/icon.png)

**Multi-Source Network Dashboard** for Home Assistant.

**Version:** `0.1.17`

**[Documentation en français](https://github.com/Erreur32/HA_mynetwork/blob/main/mynetwork/DOCS_FR.md)**

A unified dashboard to manage and monitor your network devices:

- **Freebox**  full management (Ultra, Delta, Pop): WiFi, LAN, downloads, VMs, TV, phone.
- **UniFi Controller**  AP monitoring, clients, traffic, multi-site (local + cloud).
- **Network Scan**   automatic device discovery (IP, MAC, hostname, vendor via Wireshark DB).

### Features

- JWT authentication (admin, user, viewer)
- Modular plugin system
- Real-time dashboard (charts, stats, WebSocket)
- Full activity logging
- User management (admin)
- Internationalization (EN / FR)

---

## Installation

1. **Settings** → **Apps** → **App store** → **⋮** menu → **Repositories**.
2. Add: `https://github.com/Erreur32/HA_mynetwork`
3. Install **MynetworK** from the store.
4. Configure options (see below).
5. **Start** the app → open via the **MynetworK** panel in the sidebar.

> The app is available via **Ingress** (HA sidebar) and via **direct access** at `http://YOUR_HA:7505`.
> If Ingress shows a blank page (upstream does not yet support relative URLs), use the direct port instead.

## Configuration

| Option | Description | Default |
|---|---|---|
| **log_level** | Log level (debug, info, warning, error) | `info` |
| **jwt_secret** | JWT secret to secure sessions (required in production) | empty |
| **default_admin_username** | Initial admin username | `admin` |
| **default_admin_password** | Initial admin password | empty |
| **default_admin_email** | Initial admin email | `admin@localhost` |
| **freebox_host** | Freebox host (optional) | empty |

### First launch

1. The app automatically creates an **admin** account using the credentials from the options.
2. **Change the password** immediately after first login.
3. Configure plugins (Freebox, UniFi, Network Scan) in the MynetworK UI → **Plugins**.

 
 

---

## Icon and logo

- **icon.png** — app icon (PNG, 128x128), displayed in the HA app store and sidebar.
- **logo_mynetwork.svg** — full SVG logo (source file for the icon).
