# MynetworK — App Home Assistant

![MynetworK](https://raw.githubusercontent.com/Erreur32/HA_mynetwork/main/mynetwork/icon.png)

**Dashboard Réseau Multi-Sources** pour Home Assistant.

**Version :** `0.1.15`


Dashboard unifié pour gérer et surveiller vos équipements réseau :

- **Freebox**    gestion complète (Ultra, Delta, Pop) : WiFi, LAN, téléchargements, VMs, TV, téléphone.
- **UniFi Controller**   monitoring APs, clients, trafic, multi-sites (local + cloud).
- **Scan réseau**  découverte automatique des appareils (IP, MAC, hostname, fabricant via Wireshark DB).

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

 
