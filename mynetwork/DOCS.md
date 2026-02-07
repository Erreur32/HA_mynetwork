# MynetworK — Home Assistant App

![MynetworK](icon.png)

**Multi-Source Network Dashboard** for Home Assistant.

A unified dashboard to manage and monitor your network devices:

- **Freebox** — full management (Ultra, Delta, Pop): WiFi, LAN, downloads, VMs, TV, phone.
- **UniFi Controller** — AP monitoring, clients, traffic, multi-site (local + cloud).
- **Network Scan** — automatic device discovery (IP, MAC, hostname, vendor via Wireshark DB).

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

> The app is accessible **only via Ingress** (HA sidebar). No port configuration needed — everything is managed by the Supervisor.

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

## Disable protected mode (NET_RAW / NET_ADMIN)

MynetworK requires **NET_RAW** and **NET_ADMIN** for network scanning. The Supervisor blocks these capabilities while **protected mode** is enabled (default).

### Method 1 — UI

Settings → Apps → MynetworK → Information or Configuration tab → Security section → **Protected mode OFF**.

### Method 2 — API (if the toggle does not appear)

1. Create a **Long-Lived Access Token**: `http://YOUR_HA:8123/profile` → tokens section → create.
2. Run (from anywhere):

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"protected": false}' \
  http://YOUR_HA:8123/api/hassio/addons/local_mynetwork/security
```

3. **Restart** the MynetworK app.

---

## Troubleshooting

- **Blank page via Ingress**: the app must use relative URLs. The wrapper exports `ADDON_INGRESS=1` and `INGRESS_MODE=1`.
- **su-exec: setgroups: Operation not permitted**: fixed since v0.1.7 (`ENTRYPOINT []` in the Dockerfile).
- **App does not start**: check that protected mode is disabled (see above).
- **Incomplete network scan**: enable `host_network: true` in `config.yaml` (rebuild required).

---

## Icon and logo

- **icon.png** — app icon (PNG, 128x128), displayed in the HA app store and sidebar.
- **logo_mynetwork.svg** — full SVG logo (source file for the icon).
