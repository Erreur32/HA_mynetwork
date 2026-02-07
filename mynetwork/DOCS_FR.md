# MynetworK — App Home Assistant

![MynetworK](https://raw.githubusercontent.com/Erreur32/HA_mynetwork/main/mynetwork/icon.png)

**Dashboard Réseau Multi-Sources** pour Home Assistant.


Dashboard unifié pour gérer et surveiller vos équipements réseau :

- **Freebox** — gestion complète (Ultra, Delta, Pop) : WiFi, LAN, téléchargements, VMs, TV, téléphone.
- **UniFi Controller** — monitoring APs, clients, trafic, multi-sites (local + cloud).
- **Scan réseau** — découverte automatique des appareils (IP, MAC, hostname, fabricant via Wireshark DB).

### Fonctionnalités

- Authentification JWT (admin, user, viewer)
- Système de plugins modulaire
- Dashboard temps réel (graphiques, stats, WebSocket)
- Logs d'activité complets
- Gestion des utilisateurs (admin)
- Internationalisation (EN / FR)

---

## Installation

1. **Paramètres** → **Apps** → **App store** → menu **⋮** → **Dépôts**.
2. Ajouter : `https://github.com/Erreur32/HA_mynetwork`
3. Installer **MynetworK** depuis le store.
4. Configurer les options (voir ci-dessous).
5. **Démarrer** l'app → ouvrir via le panneau **MynetworK** dans la sidebar.

> L'app est disponible via **Ingress** (sidebar HA) et en **accès direct** sur `http://VOTRE_HA:7505`.
> Si Ingress affiche une page blanche (l'upstream ne supporte pas encore les URLs relatives), utiliser le port direct.

## Configuration

| Option | Description | Défaut |
|---|---|---|
| **log_level** | Niveau de log (debug, info, warning, error) | `info` |
| **jwt_secret** | Secret JWT pour sécuriser les sessions (obligatoire en prod) | vide |
| **default_admin_username** | Nom d'utilisateur admin initial | `admin` |
| **default_admin_password** | Mot de passe admin initial | vide |
| **default_admin_email** | Email admin initial | `admin@localhost` |
| **freebox_host** | Hôte Freebox (optionnel) | vide |

### Premier lancement

1. L'app crée automatiquement un compte **admin** avec les identifiants des options.
2. **Changer le mot de passe** immédiatement après la première connexion.
3. Configurer les plugins (Freebox, UniFi, Scan réseau) dans l'interface MynetworK → **Plugins**.

---

## Désactiver le mode protégé (NET_RAW / NET_ADMIN)

MynetworK a besoin de **NET_RAW** et **NET_ADMIN** pour le scan réseau. Le Supervisor bloque ces droits tant que le **mode protégé** est activé (défaut).

### Méthode 1 — UI

Paramètres → Apps → MynetworK → onglet Information ou Configuration → section Sécurité → **Protected mode OFF**.

### Méthode 2 — API (si le toggle n'apparaît pas)

1. Créer un **Long-Lived Access Token** : `http://VOTRE_HA:8123/profile` → section tokens → créer.
2. Exécuter (depuis n'importe où) :

```bash
curl -X POST \
  -H "Authorization: Bearer VOTRE_LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"protected": false}' \
  http://VOTRE_HA:8123/api/hassio/addons/local_mynetwork/security
```

3. **Redémarrer** l'app MynetworK.

---

## Dépannage

- **Page blanche Ingress** : l'app doit utiliser des URLs relatives. Les variables `ADDON_INGRESS=1` et `INGRESS_MODE=1` sont exportées par le wrapper.
- **su-exec: setgroups: Operation not permitted** : corrigé depuis v0.1.7 (`ENTRYPOINT []` dans le Dockerfile).
- **App ne démarre pas** : vérifier que le mode protégé est désactivé (voir ci-dessus).
- **Scan réseau incomplet** : activer `host_network: true` dans `config.yaml` (rebuild nécessaire).

---

## Icône et logo

- **icon.png** — icône de l'app (PNG, 128x128), affichée dans le store HA et la sidebar.
- **logo_mynetwork.svg** — logo SVG complet (fichier source de l'icône).
