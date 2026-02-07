# MynetworK (Home Assistant Add-on)

UI uniquement via **Ingress** (sidebar), **aucun sensor**.

## Prérequis
- MynetworK image: `ghcr.io/erreur32/mynetwork:0.5.6`
- Droits réseau : `NET_RAW` + `NET_ADMIN` (scan réseau)

## Stockage / Persistance
Le volume data de l'add-on est monté sur **/app/data** (aligné avec l'image upstream).

## Configuration
- `jwt_secret` : recommandé (obligatoire en prod)
- `default_admin_*` : compte admin créé au premier démarrage si aucun utilisateur
- `freebox_host` : optionnel

## Dépannage
- Si le scan réseau est incomplet, activer `host_network: true` dans `config.yaml` et retester.
