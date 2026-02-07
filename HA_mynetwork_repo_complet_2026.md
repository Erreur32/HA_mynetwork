# HA_mynetwork — Repo complet (Apps/Add-on Supervisor 2026) — supposant image MynetworK multi-arch OK

Hypothèse : `ghcr.io/erreur32/mynetwork:<version>` est publié en multi-arch **au moins** pour `amd64 + arm64 + arm/v7`.
Objectif : wrapper Home Assistant Supervisor :
- UI **Ingress only**
- port interne 3000
- watchdog `/api/health`
- persistance via volume Supervisor mappé sur **/app/data** (important : l’entrypoint upstream gère chown)
- scan réseau : `NET_RAW` + `NET_ADMIN`
- options via `/data/options.json` (Supervisor)

---

## 1) Arborescence repo

```
HA_mynetwork_repo/
├── repository.yaml
└── mynetwork/
    ├── config.yaml
    ├── Dockerfile
    ├── run.sh
    ├── DOCS.md
    ├── icon.png
    └── translations/
        ├── en.yaml
        └── fr.yaml
```

---

## 2) `repository.yaml` (racine)

```yaml
name: MynetworK
url: https://github.com/Erreur32/HA_mynetwork
maintainer: Erreur32
```

---

## 3) `mynetwork/config.yaml`

⚠️ Ingress only : **ne pas** définir `ports:`.

- `aarch64` correspond à Docker `arm64`
- `armv7` correspond à Docker `arm/v7`
- `armhf` (arm/v6) uniquement si tu publies aussi `linux/arm/v6`

```yaml
name: "MynetworK"
slug: "mynetwork"
version: "0.5.6"   # aligner avec le tag image publié
description: "MynetworK dans Home Assistant (Ingress, aucun sensor)"
arch:
  - amd64
  - aarch64
  - armv7
  # - armhf  # optionnel si image linux/arm/v6 publiée

startup: application
init: false

ingress: true
ingress_port: 3000
ingress_entry: /
panel_title: "MynetworK"
panel_icon: "mdi:network"
panel_admin: false

watchdog: "http://[HOST]:[PORT:3000]/api/health"

privileged:
  - NET_RAW
  - NET_ADMIN

# host_network: true  # activer uniquement si scan incomplet (à documenter)

# IMPORTANT : on mappe le volume Supervisor sur /app/data (aligné avec l'entrypoint upstream)
map:
  - type: data
    path: /app/data
    read_only: false

options:
  log_level: "info"
  jwt_secret: ""
  default_admin_username: "admin"
  default_admin_password: ""
  default_admin_email: "admin@localhost"
  freebox_host: ""
schema:
  log_level: list(debug|info|warning|error)
  jwt_secret: password
  default_admin_username: str
  default_admin_password: password
  default_admin_email: str
  freebox_host: str?
```

---

## 4) `mynetwork/Dockerfile` (wrapper minimal)

L’image upstream est Alpine => `apk` OK.

```dockerfile
ARG BUILD_FROM=ghcr.io/erreur32/mynetwork:0.5.6
FROM ${BUILD_FROM}

RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
```

---

## 5) `mynetwork/run.sh` (jq -> env -> start)

Règles :
- lire `/data/options.json` (Supervisor) via jq
- exporter env
- ne jamais logguer les secrets
- ne pas définir PUBLIC_URL par défaut (Ingress)
- lancer via l’entrypoint upstream (gère /app/data permissions + su-exec node)

```sh
#!/usr/bin/env sh
set -e

OPTS="/data/options.json"

# Defaults
LOG_LEVEL="info"
JWT_SECRET=""
DEFAULT_ADMIN_USERNAME="admin"
DEFAULT_ADMIN_PASSWORD=""
DEFAULT_ADMIN_EMAIL="admin@localhost"
FREEBOX_HOST=""

if [ -f "$OPTS" ]; then
  LOG_LEVEL="$(jq -r '.log_level // "info"' "$OPTS")"
  JWT_SECRET="$(jq -r '.jwt_secret // ""' "$OPTS")"
  DEFAULT_ADMIN_USERNAME="$(jq -r '.default_admin_username // "admin"' "$OPTS")"
  DEFAULT_ADMIN_PASSWORD="$(jq -r '.default_admin_password // ""' "$OPTS")"
  DEFAULT_ADMIN_EMAIL="$(jq -r '.default_admin_email // "admin@localhost"' "$OPTS")"
  FREEBOX_HOST="$(jq -r '.freebox_host // ""' "$OPTS")"
fi

export PORT=3000
export NODE_ENV=production
export DOCKER=true

# Persistance (IMPORTANT : /app/data)
export DATABASE_PATH="/app/data/dashboard.db"
export CONFIG_FILE_PATH="/app/data/mynetwork.conf"
export FREEBOX_TOKEN_FILE="/app/data/freebox_token.json"

# Secrets / auth
export JWT_SECRET
export DEFAULT_ADMIN_USERNAME
export DEFAULT_ADMIN_PASSWORD
export DEFAULT_ADMIN_EMAIL

# Optionnel
[ -n "$FREEBOX_HOST" ] && export FREEBOX_HOST

# PUBLIC_URL : ne pas set en Ingress par défaut
unset PUBLIC_URL || true

# Démarrage upstream (confirmé par docker inspect)
exec /app/docker-entrypoint.sh node_modules/.bin/tsx server/index.ts
```

---

## 6) `mynetwork/DOCS.md` (minimum)

À inclure :
- installation via dépôt custom
- UI via sidebar (Ingress)
- scan réseau nécessite NET_RAW/NET_ADMIN
- persistance dans /app/data
- first-run : admin auto-créé si DB vide
- sécurité : définir un mot de passe admin
- option host_network (si scan incomplet)

---

## 7) `translations/fr.yaml` (exemple minimal)

```yaml
configuration:
  log_level:
    name: Niveau de logs
    description: debug/info/warning/error
  jwt_secret:
    name: Secret JWT
    description: Obligatoire pour sécuriser les sessions
  default_admin_username:
    name: Admin (username)
  default_admin_password:
    name: Admin (mot de passe)
  default_admin_email:
    name: Admin (email)
  freebox_host:
    name: Freebox host
    description: Optionnel (ex: mafreebox.freebox.fr)
```

Même structure pour `en.yaml`.

---

## 8) Points de test après installation

- ouverture UI via Ingress (panel)
- health watchdog stable
- création DB dans /app/data
- redémarrage add-on => données conservées
- scan réseau OK
- WebSockets OK (logs)

Fin.
