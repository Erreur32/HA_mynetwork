# MynetworK — App Home Assistant

![MynetworK](https://raw.githubusercontent.com/Erreur32/HA_mynetwork/main/mynetwork/icon.png)

**Dashboard Réseau Multi-Sources** pour Home Assistant.

**Version :** `0.1.20`

**[English documentation](https://github.com/Erreur32/HA_mynetwork/blob/main/mynetwork/DOCS.md)**

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
| **freebox_host** | Hôte Freebox (optionnel) | vide |

> **Note :** Les identifiants admin (username, mot de passe, email) ne sont **pas** configurés ici.
> L'app MynetworK gère les comptes utilisateurs via sa propre interface — voir « Premier lancement » ci-dessous.

### Premier lancement

1. Ouvrir le panneau **MynetworK** dans la sidebar (ou utiliser le port direct).
2. Au premier lancement (base de données vide), l'app crée automatiquement un compte admin par défaut :
   - **Username :** `admin`
   - **Mot de passe :** `admin123`
3. Connectez-vous avec ces identifiants par défaut.
4. **Changez le mot de passe immédiatement** via l'interface MynetworK (paramètres utilisateur).
5. Configurez les plugins (Freebox, UniFi, Scan réseau) dans l'interface MynetworK → **Plugins**.
6. Les identifiants sont stockés dans la base de données de l'app et sont gérés uniquement via l'interface MynetworK (pas dans la configuration de l'add-on HA).

 
