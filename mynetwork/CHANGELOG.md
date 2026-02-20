# Changelog

All notable changes to the MynetworK add-on are documented here.

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.19]

### Changed

- **Documentation: First run section** — Both READMEs (root + mynetwork) now have a dedicated "First run" section with a clear table showing default credentials (`admin` / `admin123`) and step-by-step instructions. Removed stale "admin account" references from Features lists.
- **Documentation: FR links** — Added links to `DOCS_FR.md` in both READMEs (navigation bar, repository structure, configuration section). Added back-link from `DOCS_FR.md` to the English `DOCS.md`.
- **`update-version.sh`** — Script now generates `COMMIT-MESSAGE.txt` (plain text) for use with `git commit -F COMMIT-MESSAGE.txt`. Replaces the old heredoc approach and removed `COMMIT_MESSAGES.md`.
- **`.gitignore`** — Replaced `COMMIT_MESSAGES.md` with `COMMIT-MESSAGE.txt`.

---

## [0.1.18]

### Changed

- **Architecture: admin credentials removed from HA config** — `default_admin_username`, `default_admin_password`, and `default_admin_email` have been removed from `config.yaml` options, `run.sh` environment exports, and translation files. Admin account creation is now handled entirely by the MynetworK app itself (default credentials on first launch when the database is empty). This prevents HA add-on options from overwriting credentials changed in-app after a restart. Only infrastructure options remain in the HA config: `log_level`, `jwt_secret`, `freebox_host`.

---

## [0.1.15]

### Added

- **Upstream version scraping** : `scripts/update-version.sh` récupère automatiquement la dernière version de [MynetworK](https://github.com/Erreur32/MynetworK) depuis le CHANGELOG GitHub (via `curl`) et met à jour les badges upstream dans `README.md` et `mynetwork/README.md`.
- **Badge upstream MynetworK** : affiché dans `README.md` (root) et `mynetwork/README.md` avec la version courante de l'app upstream (ex. `v0.7.3`).
- **Texte "Based on MynetworK"** : ajout de `**Based on MynetworK:** \`vX.Y.Z\`` dans le README root pour indiquer la version de l'app embarquée.

### Changed

- **scripts/update-version.sh** : URLs upstream centralisées dans des variables (pas de `curl` avec URL en dur). Affiche les deux versions (add-on + upstream) quand lancé sans argument. Fail gracieux si pas d'internet.
- **README.md** : badge `[mynetwork-shield]` maintenant affiché (était défini mais jamais utilisé).
- **mynetwork/README.md** : badge upstream passe de "official" à la version réelle (ex. `MynetworK-v0.7.3-orange`).

---

## [0.1.14]

### Added

- **Version dans DOCS.md / DOCS_FR.md** : ajout d'une ligne `**Version:** \`X.Y.Z\`` (EN) et `**Version :** \`X.Y.Z\`` (FR) pour que le script de bump mette à jour ces fichiers.
- **DOCS_FR.md** : ajouté dans la section "Repository Structure" du README root.

### Changed

- **scripts/update-version.sh** : réécriture complète du script (anciennement `bump-version.sh` à la racine). Corrige `REPO_ROOT` (qui pointait sur `scripts/` au lieu de la racine), supprime l'étape Dockerfile (utilise `:latest`), ajoute une fonction `sedi()` portable macOS/Linux, regex générique pour `mynetwork/README.md` (rattrape les badges désynchronisés), vérification `NEW == CURRENT`.
- **README.md** : section "Repository Structure" mise à jour (`scripts/update-version.sh` au lieu de `bump-version.sh`, ajout `DOCS_FR.md`). Versions synchronisées à `0.1.14` dans tous les badges et liens.
- **mynetwork/README.md** : badge version synchronisé (était resté à `0.1.2`).

---

## [0.1.13]

### Fixed

- **`EACCES: permission denied, open '/app/data/oui.txt'`** : le code upstream écrit dans `/app/data/` (layer Docker en lecture seule). **run.sh** crée maintenant un symlink `/app/data` → `/data` (volume persistant Supervisor) au démarrage, après avoir copié les éventuels fichiers par défaut de l'image.
- **Ingress shim** (suite 0.1.12) : le shim `fetch/XHR/WebSocket/pushState` est maintenant injecté de manière fiable grâce au `chmod u+w /app/dist` dans le Dockerfile.

### Changed

- **run.sh** : ajout du bloc symlink `/app/data` → `/data` avant le lancement de l'app.

---

## [0.1.12]

### Fixed

- **Ingress page blanche (fix définitif)** : le simple remplacement `/assets/` → `./assets/` ne suffisait pas. Le JavaScript de l'app fait des appels API (`fetch("/api/...")`) et WebSocket (`new WebSocket("/ws/...")`) en chemin absolu, qui passent à côté du proxy Ingress.
  - **Shim Ingress** : un script `<script data-ingress-shim>` est injecté automatiquement dans `index.html` au démarrage. Il intercepte `fetch()`, `XMLHttpRequest.open()`, `WebSocket()`, `history.pushState()` et `history.replaceState()` pour préfixer transparemment toute URL commençant par `/` avec le chemin Ingress (`/api/hassio_ingress/<token>`). Hors Ingress, le shim est un no-op.
  - **Dockerfile** : `chmod -R u+w /app/dist` pour rendre le répertoire front-end accessible en écriture (élimine les erreurs `Permission denied` du patch).

### Changed

- **run.sh** : le bloc de patch `index.html` a été réécrit : fix assets (sed) + injection du shim JS (via `node`), idempotent.
- **Dockerfile** : ajout `RUN chmod -R u+w /app/dist` avant ENTRYPOINT.

---

## [0.1.11]

### Fixed

- **Page blanche Ingress** : le build Vite upstream utilise des chemins absolus (`/assets/...`) dans `index.html`. Le Supervisor Ingress préfixe les URLs avec `/api/hassio_ingress/<token>/`, donc les chemins absolus cassent (404). **run.sh** patche maintenant `index.html` au démarrage : `/assets/` → `./assets/` (chemins relatifs).

### Changed

- **run.sh** : ajout du patch `sed` sur `/app/dist/index.html` avant le lancement de l'app.

---

## [0.1.10]

### Changed

- **config.yaml** : suppression de l'option `network.server_port` (port fixe 3000, géré par le Supervisor via `ingress_port`). L'utilisateur n'a plus de section "Réseau" dans la configuration.
- **run.sh** : port 3000 en dur, ne lit plus `network.server_port` depuis les options.
- **translations en/fr** : suppression de la section Réseau (network).
- **DOCS.md / DOCS_FR.md** : version anglaise par défaut + version française séparée. Ajout icône/logo, suppression section port.

---

## [0.1.9]

### Added

- **Port direct 7505** : `ports: 3000/tcp: 7505` ajouté dans `config.yaml` pour accéder à l'app depuis `http://homeassistant:7505` (contournement page blanche Ingress en attendant le fix upstream).

### Changed

- **config.yaml** : Ingress + port exposé en parallèle.
- **DOCS.md / DOCS_FR.md** : accès via Ingress (sidebar) et via port direct.

---

## [0.1.8]

### Added

- **DOCS.md** : réécriture complète — présentation de l'app (Freebox, UniFi, Scan réseau, fonctionnalités), tableau des options, premier lancement, désactivation mode protégé (UI + API Long-Lived Token), troubleshooting.
- **DOCS_FR.md** : version française de la documentation.

### Changed

- **DOCS.md** : suppression de la section token Supervisor (inutile pour l'utilisateur). Ajout de la méthode Long-Lived Access Token + proxy API HA Core pour désactiver le mode protégé.

---

## [0.1.7]

### Fixed

- **su-exec: setgroups: Operation not permitted** : `ENTRYPOINT []` dans le Dockerfile pour écraser l'entrypoint de l'image de base (`docker-entrypoint.sh` utilise `su-exec`). Le bloc add-on (`ADDON_INGRESS=1`) dans `run.sh` est maintenant exécuté **avant** le fallback `docker-entrypoint.sh`.
- **Duplicate "Réseau" dans l'UI** : suppression de `ports:` / `ports_description:` dans `config.yaml` (Ingress only, pas de port exposé sur l'hôte).
- **Warning `Unknown option 'show_ports'`** : option supprimée du schéma (déjà retirée des options, restait dans les données sauvegardées).

### Changed

- **Dockerfile** : ajout `ENTRYPOINT []` pour garantir que `/run.sh` est le seul point d'entrée (pas de `su-exec` en contexte add-on).
- **run.sh** : le bypass add-on (lancement direct sans `su-exec` / `docker-entrypoint.sh`) est maintenant **avant** le fallback entrypoint upstream.
- **config.yaml** : `ports:` et `ports_description:` supprimés (Ingress only).
- **DOCS.md** : réécriture complète — token Supervisor (variable d'environnement uniquement), désactivation du mode protégé via Long-Lived Access Token + proxy API HA Core, ce qui ne marche pas (403 avec SUPERVISOR_TOKEN).

---

## [0.1.1]

### Added

- **Section Réseau (Network)** dans les options : `network.server_port`, `network.show_ports` (toggle afficher/masquer les ports dans la bannière). Traductions en/fr pour la catégorie Réseau.
- **Variables Ingress** : `ADDON_INGRESS=1`, `INGRESS_MODE=1`, `SHOW_PORTS` exportées par run.sh pour que l'app MynetworK utilise des URL relatives (éviter la page blanche via Ingress).
- **INSTRUCTIONS_MYNETWORK_UPSTREAM.md** : instructions pour adapter le repo MynetworK principal (URLs relatives, X-Ingress-Path).

### Changed

- **build.yaml** et **Dockerfile** : image de base MynetworK en `:latest` (chaque build add-on utilise la dernière release MynetworK ; version add-on indépendante de la version MynetworK).
- **config.yaml** : options regroupées avec catégorie `network` (server_port, show_ports). Compatibilité ascendante : run.sh lit aussi l'ancien `server_port` en racine.
- **DOCS.md** : deux catégories (Options générales, Réseau), réinitialisation des options, port actuel (onglet Information), troubleshooting « Page blanche via Ingress ».

---

## [0.1.0]

### Added

- **Option server_port**: configurable port d'écoute (défaut 3000) dans l'onglet Configuration. Traductions en/fr (Server port / Port du serveur). Garder 3000 pour Ingress et le watchdog.
- **run.sh**: export de `DASHBOARD_PORT` en plus de `PORT` pour que l'app serve HTTP et frontend sur le même port (compatibilité Ingress).

### Changed

- **run.sh**: lecture de l'option `server_port` depuis `options.json` ; `PORT` et `DASHBOARD_PORT` utilisent cette valeur.
- **DOCS.md**: section Configuration mise à jour avec la description de `server_port`.

---

## [0.0.9]

### Added

- **DOCS.md**: Official docs reference (Home Assistant Developer Docs, Developing an app) and explicit links to [App security → Protection](https://developers.home-assistant.io/docs/apps/security#protection) and [API role](https://developers.home-assistant.io/docs/apps/security#api-role) for protected mode integration.

### Changed

- **DOCS.md**: All documentation links updated from `/docs/add-ons/` to `/docs/apps/` (configuration, security). Security section expanded with official quotes and step-by-step for enabling the Protected mode toggle.
- **config.yaml**: Comments for `hassio_api` / `hassio_role` updated to cite [App security](https://developers.home-assistant.io/docs/apps/security) and clarify that only `hassio_role: admin` allows the protection mode toggle for this app.

---

## [0.0.8]

### Added

- **build.yaml**: Supervisor now builds from the correct base image (`ghcr.io/erreur32/mynetwork`) so the add-on includes the full MynetworK app.

### Fixed

- **Dockerfile**: Build step `apk add jq` now runs as root (fixes "Permission denied" when building from the MynetworK base image).

---

## [0.0.6]

### Added

- Documentation aligned with Home Assistant 2025.x / 2026.x (Settings → Apps, persistence `/data`).

### Fixed

- **Add-on not starting / "Server file not found"**: Data volume is now mapped at `/data` instead of `/app/data`, so `/app` (server, node_modules) is no longer overwritten. Reinstall or update the add-on for the fix.
- **Dockerfile**: Build fails with a clear message if the base image is missing the app.

### Changed

- **config.yaml**: `map` path `/app/data` → `/data`.
- **run.sh**: Options and persistence use `/data` (options.json, dashboard.db, etc.).
- **apparmor.txt**: Read/write on `/data/**`.

---

## [0.0.4]

### Added

- Security hardening (configuration, documentation, runtime behaviour).

---

## [0.0.3]

### Added

- Add-on icon: official MynetworK logo (PNG).

### Changed

- **run.sh**: Robust startup when upstream entrypoint is missing (fallback to su-exec node or direct tsx).

---

## [0.0.2]

### Added

- Root and add-on README with logo, badges, feature list, options summary.

### Changed

- App description in config cleaned up.

---

## [0.0.1]

- Initial release.
- MynetworK app for Home Assistant Supervisor.
- Ingress only (sidebar, port 3000).
- Watchdog at `/api/health`.
- Persistence, options (log_level, jwt_secret, default_admin_*, freebox_host).
- NET_RAW, NET_ADMIN for network scanning.
- Translations (en, fr), DOCS.md, README.md.
