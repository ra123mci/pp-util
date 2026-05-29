# 🟢 pp — Port Process Utility

`pp` est un utilitaire léger pour **lister**, **inspecter** et **tuer** les processus liés à un port réseau. Il fournit une version **Bash** pour Linux/macOS et une version **PowerShell** pour Windows.

---

## Contenu du dépôt

```
.
├─ src/
│  ├─ pp                  # script Bash (Linux / macOS)
│  ├─ install.sh          # installe pp dans /usr/local/bin
│  ├─ uninstall.sh        # désinstalle pp
│  ├─ pp.ps1              # script PowerShell (Windows)
│  ├─ install.ps1         # installe pp.ps1 (user scope)
│  └─ uninstall.ps1       # désinstalle pp.ps1
├─ package.json        # (optionnel) pour publication npm
├─ README.md           # ce fichier
└─ LICENSE             # MIT License
```

---

# Installation

## Linux / macOS (Bash)

### Pré-requis

- `bash`, `lsof` (recommandé) ou `ss` / `netstat` en fallback
- droits sudo pour une installation globale

### Installer (global)

```bash
git clone <URL_DU_REPO>
cd pp-util
sudo bash src/install.sh
```

### Installer (local, sans sudo)

```bash
mkdir -p "$HOME/bin"
cp src/pp "$HOME/bin/pp"
chmod +x "$HOME/bin/pp"
# ajoute $HOME/bin dans ton PATH si nécessaire
# echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

### Désinstaller

```bash
sudo bash src/uninstall.sh
# ou si installé localement
rm "$HOME/bin/pp"
```

---

## Windows (PowerShell)

### Pré-requis

- Windows 10/11 ou PowerShell Core 7+
- Permission d'exécution de scripts (voir remarque Execution Policy ci-dessous)

### Installer (user-scope)

Ouvre PowerShell, place-toi dans le repo, puis :

```powershell
.\src\install.ps1
```

`install.ps1` copie `pp.ps1` dans `"$HOME\bin"` (par défaut), ajoute ce dossier au `PATH` utilisateur et crée un alias permanent `pp` dans ton profil PowerShell.

### Désinstaller

```powershell
.\src\uninstall.ps1
```

---

## Remarques sur PowerShell Execution Policy

Si l'exécution de scripts est bloquée, lance dans PowerShell (en tant qu'utilisateur) :

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

Ou débloque le fichier avant de l'exécuter :

```powershell
Unblock-File .\src\pp.ps1
```

---

# Usage

> Les deux versions exposent les mêmes options et comportement :
> `pp 3000`, `pp -i 3000`, `pp -i -f 3000`, `pp -k 3000`, `pp -h`, `pp -v`

## Options

```
-i, --info              : Affiche les détails du(es) process(es) et les bindings réseau
-i, --info -f, --follow : Affiche les détails + suit les logs en temps réel
-k, --kill              : Tue le(s) process(es) utilisant le port
-h, --help              : Affiche l'aide
-v, --version           : Affiche la version
```

## Exemples (Linux/macOS)

```bash
# quick info - affiche juste les PIDs
pp 3000

# detailed info - infos détaillées du process
pp -i 3000
pp --info 3000

# detailed info + follow logs - infos + logs en temps réel
pp -i --follow 3000
pp -i -f 3000

# kill processes on port
pp -k 3000
pp --kill 3000

# help / version
pp -h
pp -v
```

### Output exemple (Linux/macOS) - `pp -i 3000`

```
ℹ️  Detailed info for port 3000 (PIDs: 12345):

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PID: 12345
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Process Info:
12345   root     node     node /app/server.js

📁 Working Directory:
/app

🔧 Command Line:
node /app/server.js

💾 Resource Usage:
  CPU: 0.5% | Memory: 2.3% (45600 KB)

📂 Open Files:
  Total: 156

🌐 Network Binding:
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
node    12345   root   18u  IPv4   0x123      0t0  TCP *:3000 (LISTEN)
```

### Output exemple (Linux/macOS) - `pp -i --follow 3000`

```
ℹ️  Detailed info for port 3000 (PIDs: 12345):
[... detailed info ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 Following process logs (Ctrl+C to stop)...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Following: /app/app.log
[2026-05-29 16:18:23] INFO: Server started on port 3000
[2026-05-29 16:18:24] INFO: Connected to database
[2026-05-29 16:18:25] DEBUG: Request received: GET /api/users
...
```

## Exemples (Windows / PowerShell)

```powershell
# quick info
pp 3000

# detailed info
pp -i 3000

# detailed info + follow logs
pp -i -f 3000

# kill
pp -k 3000

# help / version
pp -h
pp -v
```

### Output exemple (Windows) - `pp -i 3000`

```
ℹ️  Detailed info for port 3000 (PIDs: 5678)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PID: 5678
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Process Info:
  Name: node
  User: DESKTOP-ABC123\User
  Handle Count: 156

📁 Working Directory:
  C:\Users\User\project

🔧 Full Path:
  C:\Program Files\nodejs\node.exe

🔧 Command Line:
  C:\Program Files\nodejs\node.exe C:\Users\User\project\server.js

💾 Resource Usage:
  Memory: 45.32 MB
  Threads: 12

⏱️ Process Times:
  Started: 2026-05-29 16:15:00
  CPU Time: 00:00:15.6234567

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 Network Binding:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LocalAddress LocalPort RemoteAddress RemotePort State OwningProcess
127.0.0.1    3000      0.0.0.0       0          Listen 5678
```

---

# Comportement & implémentation

- Le script détecte les PID(s) liés au port en priorité via `lsof` (Linux/macOS) ou `Get-NetTCPConnection` (Windows). Des fallbacks (`ss`, `netstat`) sont utilisés si nécessaire.
- `pp` gère le cas où plusieurs PID seraient retournés (rare, mais possible).
- `--kill` utilise `kill -9` (Bash) / `Stop-Process -Force` (PowerShell) pour s'assurer d'arrêter le process ; adapte si tu préfères un signal plus doux.
- L'installation globale met le binaire dans `/usr/local/bin` (Linux/macOS) ou copie `pp.ps1` dans `"$HOME\bin"` et crée un alias (Windows).
- **Nouveau v1.1.0** : L'option `--follow` / `-f` combine les infos détaillées avec un suivi des logs en temps réel (tail -f sur Linux/macOS, Get-Content -Wait sur Windows).

## Détails des informations affichées par `-i/--info`

### Bash (Linux/macOS)
- **Infos process** : PID, utilisateur, commande, arguments
- **Working directory** : répertoire de travail du process
- **Command line** : ligne de commande complète extraite de `/proc/[pid]/cmdline`
- **Resource usage** : CPU %, mémoire %, RSS en KB
- **Open files** : nombre de fichiers ouverts
- **Network binding** : adresses et ports écoutés

### PowerShell (Windows)
- **Infos process** : nom, utilisateur propriétaire, nombre de handles
- **Working directory** : répertoire de travail
- **Full path** : chemin complet de l'exécutable
- **Command line** : ligne de commande complète via WMI
- **Resource usage** : mémoire en MB, nombre de threads
- **Process times** : heure de démarrage, temps CPU
- **Network binding** : adresses et ports écoutés

---

# Sécurité & bonnes pratiques

- **Ne pipe pas** de code non audité dans `bash` ou `pwsh` depuis Internet (`curl | bash`) sauf si tu fais confiance au repo.
- L'option `--kill` force l'arrêt : vérifie le PID et le process avant de l'utiliser en production.
- Si tu souhaites une suppression plus propre, remplace `kill -9` par `kill` (SIGTERM) d'abord, puis escalade si nécessaire.
- Pour une installation multi-utilisateur sur Windows (tous les utilisateurs), installe dans `C:\Program Files\pp` et ajoute au PATH système (nécessite élévation/admin).
- Les logs suivis avec `--follow` dépendent de la configuration du process ; il peut ne pas toujours être possible de taller les logs si le process ne les enregistre pas dans des fichiers standards.

---

# Publication & installation alternative

### Via npm (optionnel)

Si tu veux distribuer via npm, le `package.json` contient :

```json
{
  "name": "pp-port-util",
  "version": "1.1.0",
  "bin": { "pp": "./src/pp" },
  "preferGlobal": true
}
```

Publie sur npm puis :

```bash
npm i -g pp-port-util
# ou installer directement depuis GitHub
npm i -g github:<TON_ORG>/<REPO>
```

### One-liner (raw GitHub) — **attention sécurité**

```bash
sudo curl -sL "https://raw.githubusercontent.com/<TON_ORG>/<REPO>/feature/enhanced-info/src/pp" -o /usr/local/bin/pp \
  && sudo chmod +x /usr/local/bin/pp
```

Préconisé : télécharger, auditer, puis installer manuellement.

---

# Développement & contribution

- Fork → clone → ouvre un PR
- Tests manuels : vérifie `pp` sur Linux/macOS avec `lsof`, et `pp.ps1` sur PowerShell en local
- Ajoute des tests CI si tu veux (GitHub Actions) pour lint & basic smoke tests
- Les versions doivent être synchronisées entre Bash et PowerShell

---

# Fichiers importants (rapide rappel)

- `src/pp` : script Bash — donne `pp` CLI sur Linux/macOS
- `src/install.sh` / `src/uninstall.sh` : installer/désinstaller bash version
- `src/pp.ps1` : script PowerShell — donne `pp` CLI sur Windows
- `src/install.ps1` / `src/uninstall.ps1` : installer/désinstaller ps1 version
- `package.json` : pour publication npm (optionnel)

---

# Licence

Ce projet est fourni sous licence **MIT**. Voir le fichier `LICENSE` pour plus de détails.

---

# Changelog

- **1.1.0** — Nouvelle fonctionnalité `-f/--follow` pour suivre les logs en temps réel + affichage détaillé des infos process (working directory, command line, ressources)
- **1.0.0** — Version initiale : Bash + PowerShell, options `-i/-k/-h/-v`, install/uninstall scripts.

---

_Fin du README_
