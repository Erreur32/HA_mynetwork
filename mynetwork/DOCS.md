# MynetworK — dev / dépannage

## Tokens — résumé

### SUPERVISOR_TOKEN (printenv)

`printenv SUPERVISOR_TOKEN` depuis Terminal & SSH ou le CLI HA affiche le **token interne Supervisor**. Ce token est utilisable **uniquement pour les appels internes** entre add-ons et le Supervisor (`http://supervisor/...`). Il ne fonctionne **PAS** pour l'endpoint `/addons/<slug>/security` car Terminal & SSH n'a pas le rôle `admin` → **403 Forbidden**.

### Long-Lived Access Token (token utilisateur HA)

C'est le token qu'il faut pour désactiver le mode protégé. Il passe par le **proxy API de Home Assistant Core** qui, lui, a les droits admin sur le Supervisor.

Création : **http://192.168.32.200:8123/profile** → section **Long-Lived Access Tokens** → Créer un token → copier la valeur.

## Désactiver le mode protégé (privileged NET_RAW / NET_ADMIN)

### Méthode 1 — UI (si le toggle existe)

Paramètres → Apps → MynetworK → onglet Information ou Configuration → section Sécurité → **Protected mode OFF**.

### Méthode 2 — API via le proxy HA Core (fonctionne toujours)

```bash
curl -X POST \
  -H "Authorization: Bearer LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"protected": false}' \
  http://192.168.32.200:8123/api/hassio/addons/local_mynetwork/security
```

Remplacer `LONG_LIVED_TOKEN` par le token créé dans le profil HA. Adapter le slug (`local_mynetwork`) si besoin.

Puis **redémarrer** l'app MynetworK.

