# MynetworK (Home Assistant Add-on)

**Ingress only** (sidebar) — no exposed port, no Home Assistant sensors.

## Prerequisites

- MynetworK multi-arch image: `ghcr.io/erreur32/mynetwork:0.0.5` (amd64, aarch64, armv7).
- Network capabilities: **NET_RAW** and **NET_ADMIN** are required for network scanning.

## Installation

1. In Home Assistant: **Settings** → **Apps** → **Repositories** (or **Supervisor** → **Add-on store** → **Repositories**).
2. Add the custom repository:
   - **URL**: `https://github.com/Erreur32/HA_mynetwork`
3. Reload repositories if needed.
4. Install the **MynetworK** app from the available add-ons list.
5. Configure options (see below). In **Configuration** → **Security**, **disable "Protected mode"** so the add-on can use `NET_RAW`/`NET_ADMIN` for network scanning (otherwise it may not start). Then **Start**.

## UI access (Ingress)

- The app is available **only via Ingress**: open the **MynetworK** panel from the Home Assistant sidebar.
- No port is exposed on the host; all traffic goes through the Supervisor reverse proxy.
- **Compliance**: [Presenting your app](https://developers.home-assistant.io/docs/apps/presentation#ingress) — we set `ingress: true` and `ingress_port: 3000`. For full compliance, the upstream server should allow only connections from `172.30.32.2` (Ingress proxy); check the [official MynetworK](https://github.com/Erreur32/MynetworK) app if you need to enforce this.

## Network and scanning

- Network scanning requires **NET_RAW** and **NET_ADMIN** (already set in the add-on).
- If scanning is incomplete (networks or devices not detected), you can enable **host_network** mode: in the add-on source, uncomment `host_network: true` in `config.yaml`, then rebuild/reinstall. Use with caution (host network access).

## Storage and persistence

- The Supervisor data volume is mounted at **/app/data** (aligned with the upstream image).
- Database, config and tokens (e.g. Freebox) are stored in this volume:
  - `dashboard.db`, `mynetwork.conf`, `freebox_token.json`, etc.
- Data is kept across restarts and add-on updates.

## First run

- On first start, if the database is empty, an **admin** account is created automatically from options:
  - `default_admin_username`, `default_admin_password`, `default_admin_email`.
- Set a strong password and a `jwt_secret` before using in production.

## Configuration (options)

- **log_level**: log level (debug, info, warning, error). When set to **debug**, the add-on wrapper prints extra diagnostics (env, paths, `/app` and `/app/data` listing) and enables Node.js `--trace-warnings` and `--trace-uncaught` so crashes show full stack traces in the add-on Log tab. The MynetworK app’s own debug (HTTP request logs, etc.) is controlled inside the app (Administration → configuration) and stored in the database, not by this option.
- **jwt_secret**: JWT secret for session security — **recommended (required in production)**.
- **default_admin_username**: initial admin account username.
- **default_admin_password**: initial admin account password.
- **default_admin_email**: initial admin account email.
- **freebox_host**: optional (e.g. `mafreebox.freebox.fr`).

## Security

- Set a strong **admin password** in options.
- Set a non-empty **jwt_secret** to secure sessions.
- Do not expose the UI outside Ingress without proper authentication.
- **AppArmor**: a custom [apparmor.txt](https://developers.home-assistant.io/docs/apps/presentation#apparmor) profile is included (same folder as `config.yaml`). It restricts the add-on to the minimum required paths (e.g. `/app/data`, wrapper script, upstream entrypoint) and contributes to the app’s security rating after installation.

- **Protected mode toggle**: The add-on sets `hassio_api: true` and `hassio_role: admin` in `config.yaml` so that the **"Protected mode"** toggle is visible in the add-on **Configuration** → **Security** tab. Only add-ons with the admin API role get this toggle; without it, users cannot disable protection and the add-on cannot start with `NET_RAW`/`NET_ADMIN`. This choice lowers the Supervisor security rating by 2 points but is required for the add-on to be usable; see [App security](https://developers.home-assistant.io/docs/add-ons/security).

## Troubleshooting

- **Add-on does not start / nothing starts**: This add-on uses **privileged** capabilities (`NET_RAW`, `NET_ADMIN`) for network scanning. In the add-on **Configuration** tab, open the **Security** section and **disable "Protected mode"** (toggle off “Protect the app from having full system access”). With protected mode on, the Supervisor can block the required privileges and the container may fail to start. Disabling it allows the add-on to run with the configured capabilities; only do this for this add-on and on a trusted system.
- **App starts then closes immediately**: Open the add-on **Log** tab and look for the last lines before the container exits. The wrapper script logs lines starting with `[MynetworK add-on]` so you can see which step ran. Common causes: (1) **Protected mode still on** — disable it in Configuration → Security and restart. (2) **Missing tsx or server** — log will show `ERROR: tsx not found` or `ERROR: Server file not found`; this can happen if the upstream image layout changed (check [MynetworK](https://github.com/Erreur32/MynetworK) and the image version in the Dockerfile). (3) **App crash on startup** — after the "Starting via..." line you may see a Node/TS error (e.g. missing env, database error); set **log_level** to `debug` in options and restart to get more detail. (4) **Invalid options.json** — the script now tolerates missing or invalid options; if you edited the add-on data manually, ensure the JSON is valid.
- **Incomplete network scan**: enable `host_network: true` in `config.yaml` (requires a modified add-on build), then test again. Warning: this gives the add-on access to the host network.
- **Watchdog**: the add-on exposes `/api/health` on internal port 3000; the Supervisor uses it to monitor the app.
- **Persistence**: if in doubt, check that the volume is mounted at `/app/data` and that files (e.g. `dashboard.db`) exist after a restart.
- **AppArmor**: if the add-on fails to start and Supervisor logs point to AppArmor, you can set `apparmor: false` in `config.yaml` (custom build) to use the default profile (this lowers the app security rating by 1; see [App configuration](https://developers.home-assistant.io/docs/add-ons/configuration)).

## Post-install checks

- Open the UI via the Ingress panel (sidebar).
- Watchdog stable (add-on reported as "running").
- Files created under `/app/data` on first run.
- Add-on restart: data is preserved.
- Network scan works.
- WebSockets / real-time logs work if the app uses them.

## Icon and logo

- **Icon**: The add-on uses the **official MynetworK logo** as `icon.png` (PNG, 1:1, 128×128 px). Home Assistant requires PNG ([recommendations](https://developers.home-assistant.io/docs/apps/presentation#app-icon--logo)). To refresh the icon from the [MynetworK repo](https://github.com/Erreur32/MynetworK/tree/main/src/icons), run from the HA_mynetwork repo root: `./update-addon-icon.sh` (requires curl/wget and rsvg-convert or ImageMagick).
- **Logo** (optional): a `logo.png` file in PNG format, recommended size about 250×100 px, can be added to improve presentation in the Supervisor.

## License

The license under which this app is published is defined at the repository level. See the LICENSE file or the repository page (e.g. [Erreur32/HA_mynetwork](https://github.com/Erreur32/HA_mynetwork)) for the exact terms.
