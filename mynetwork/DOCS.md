# 📖 Documentation MynetworK Add-on

## 🔧 Configuration

### Options
| Option | Type | Description | Exemple |
|--------|------|-------------|---------|
| jwt_secret | string | Secret JWT API | monsecret123 |
| freebox_host | string | Freebox server | mafreebox.freebox.fr |

Save → Restart après changements.

### Permissions (config.yaml)
- host_network: true
- privileged: ["NET_ADMIN", "NET_RAW"]
- map:
  - type: homeassistant_config
    read_only: false

## 🛠️ Installation

1. HA > Add-ons > ☰ > Repositories : https://github.com/Erreur32/HA_mynetwork

2. MynetworK > Install > Start > Ingress ON

3. Configurer :

```
jwt_secret: votre_secret
freebox_host: mafreebox.freebox.fr
```


## 🎯 Utilisation

**Accès UI** :
- Sidebar HA > MynetworK (port 3000)
- Direct : http://IP_HA:3000

**Fonctions** :
- Scan réseau IP/MAC/ports
- Freebox API
- Export CSV/JSON

## 🔍 Healthcheck
```
GET http://IP:3000/api/health
→ {"status":"ok"}
```


## ❌ Dépannage

| Erreur | Solution |
|--------|----------|
| s6-overlay-suexec PID 1 | config.yaml: "init": false<br>Protection mode: OFF |
| tsx not found | Rebuild Dockerfile |
| Port 3000 occupé | netstat -tlnp \| grep 3000 |

**Logs** :

HA > Add-on > Logs MynetworK


## ⚡ Spécifications
- Node.js 22 Alpine
- Scan /24 : <3s
- RAM : 80MB idle

## 💬 Support
[GitHub Issues](https://github.com/Erreur32/HA_mynetwork/issues)

---
MynetworK v0.5.6 - 2026

