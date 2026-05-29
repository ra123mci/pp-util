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
├─ package.json           # (optionnel) pour publication npm
├─ README.md              # ce fichier
└─ LICENSE                # MIT License
```

---

# Installation

## Linux / macOS (Bash)

### Pré-requis

- `bash`, `lsof` (recommandé) ou `ss` / `netstat` en fallback
- droits sudo pour une installation globale

### Installer (global)

```bash
git clone https://github.com/ra123mci/pp-util.git
cd pp-util
sudo bash src/install.sh
```

### Installer (local, sans sudo)

```bash
mkdir -p "$HOME/bin"
cp src/pp "$HOME/bin/pp"
chmod +x "$HOME/bin/pp"
# ajoute $HOME/bin dans ton PATH si nécessaire
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Installer via curl (one-liner)

```bash
sudo curl -sL "https://raw.githubusercontent.com/ra123mci/pp-util/main/src/pp" -o /usr/local/bin/pp \
  && sudo chmod +x /usr/local/bin/pp
```

### Désinstaller

```bash
sudo rm /usr/local/bin/pp
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

### Installer via PowerShell (one-liner)

```powershell
$ProgressPreference = 'SilentlyContinue'; `
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ra123mci/pp-util/main/src/pp.ps1" -OutFile "$HOME\pp.ps1" -UseBasicParsing; `
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force; `
& "$HOME\pp.ps1" -h
```

Ou créer un alias permanent dans ton profil PowerShell :

```powershell
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
Add-Content -Path $PROFILE -Value @"
`nSet-Alias -Name pp -Value "$HOME\pp.ps1" -Force
"@
```

### Désinstaller

```powershell
.\src\uninstall.ps1
# ou manuellement
Remove-Item "$HOME\pp.ps1" -Force
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
-i -f, -i --follow      : Affiche les détails + suit les logs en temps réel (Ctrl+C pour arrêter)
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
[2026-05-29 16:18:26] INFO: Response sent: 200
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

### Output exemple (Windows) - `pp -i -f 3000`

```
ℹ️  Detailed info for port 3000 (PIDs: 5678):
[... detailed info ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 Following process output (Ctrl+C to stop)...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Tailing: C:\Users\User\project\logs\app.log
[2026-05-29 16:18:23] INFO: Server started on port 3000
[2026-05-29 16:18:24] INFO: Connected to database
[2026-05-29 16:18:25] DEBUG: Request received: GET /api/users
[2026-05-29 16:18:26] INFO: Response sent: 200
```

---

# Comportement & implémentation

- Le script détecte les PID(s) liés au port en priorité via `lsof` (Linux/macOS) ou `Get-NetTCPConnection` (Windows). Des fallbacks (`ss`, `netstat`) sont utilisés si nécessaire.
- `pp` gère le cas où plusieurs PID seraient retournés (rare, mais possible).
- `--kill` utilise `kill -9` (Bash) / `Stop-Process -Force` (PowerShell) pour s'assurer d'arrêter le process ; adapte si tu préfères un signal plus doux.
- L'installation globale met le binaire dans `/usr/local/bin` (Linux/macOS) ou crée un alias PowerShell (Windows).
- **v1.1.0** : L'option `--follow` / `-f` combine les infos détaillées avec un suivi des logs en temps réel :
  - **Bash** : cherche `app.log`, `error.log`, `/logs/` directory, puis fallback sur stdout (tail -f)
  - **PowerShell** : cherche les fichiers `.log` dans le répertoire du process, `ProgramData`, `AppData`, puis affiche les 20 dernières lignes avec `-Wait`

## Détails des informations affichées par `-i/--info`

### Bash (Linux/macOS)
- **Infos process** : PID, utilisateur, commande, arguments
- **Working directory** : répertoire de travail du process (depuis `/proc/[pid]/cwd`)
- **Command line** : ligne de commande complète (depuis `/proc/[pid]/cmdline`)
- **Resource usage** : CPU %, mémoire %, RSS en KB
- **Open files** : nombre total de fichiers ouverts (depuis `/proc/[pid]/fd`)
- **Network binding** : adresses et ports écoutés (via `lsof`)

### PowerShell (Windows)
- **Infos process** : nom, utilisateur propriétaire, nombre de handles
- **Working directory** : répertoire de travail (extrait du chemin de l'exécutable)
- **Full path** : chemin complet de l'exécutable
- **Command line** : ligne de commande complète (via WMI Win32_Process)
- **Resource usage** : mémoire en MB, nombre de threads
- **Process times** : heure de démarrage, temps CPU total
- **Network binding** : adresses et ports écoutés (via Get-NetTCPConnection)

---

# Sécurité & bonnes pratiques

- **Ne pipe pas** de code non audité dans `bash` ou `pwsh` depuis Internet (`curl | bash`) sauf si tu fais confiance au repo.
- L'option `--kill` force l'arrêt : vérifie le PID et le process avant de l'utiliser en production.
- Si tu souhaites une suppression plus propre, remplace `kill -9` par `kill` (SIGTERM) d'abord, puis escalade si nécessaire.
- Pour une installation multi-utilisateur sur Windows (tous les utilisateurs), installe dans `C:\Program Files\pp` et ajoute au PATH système (nécessite élévation/admin).
- Les logs suivis avec `--follow` dépendent de la configuration du process ; il peut ne pas toujours être possible de taller les logs si le process ne les enregistre pas dans des fichiers standards.
- **Toujours auditer** les scripts avant de les exécuter via curl ou téléchargement.

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
npm i -g github:ra123mci/pp-util
```

---

# Développement & contribution

- Fork → clone → ouvre un PR
- Tests manuels : vérifie `pp` sur Linux/macOS avec `lsof`, et `pp.ps1` sur PowerShell en local
- Ajoute des tests CI si tu veux (GitHub Actions) pour lint & basic smoke tests
- Les versions doivent être synchronisées entre Bash et PowerShell

## Comment contribuer

1. Clone le repo :
   ```bash
   git clone https://github.com/ra123mci/pp-util.git
   cd pp-util
   ```

2. Crée une branche feature :
   ```bash
   git checkout -b feature/ma-feature
   ```

3. Teste tes modifications :
   - Bash : `bash src/pp -h` et `bash src/pp -i 3000`
   - PowerShell : `.\src\pp.ps1 -h` et `.\src\pp.ps1 -i 3000`

4. Committe et push :
   ```bash
   git add .
   git commit -m "feat: description courte"
   git push origin feature/ma-feature
   ```

5. Ouvre une Pull Request sur GitHub

---

# Fichiers importants (rapide rappel)

- `src/pp` : script Bash — donne `pp` CLI sur Linux/macOS
- `src/install.sh` / `src/uninstall.sh` : installer/désinstaller bash version
- `src/pp.ps1` : script PowerShell — donne `pp` CLI sur Windows
- `src/install.ps1` / `src/uninstall.ps1` : installer/désinstaller ps1 version
- `package.json` : pour publication npm (optionnel)
- `LICENSE` : licence MIT

---

# Licence

Ce projet est fourni sous licence **MIT**. Voir le fichier `LICENSE` pour plus de détails.

```
MIT License

Copyright (c) 2026 ra123mci

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

# Changelog

- **1.1.0** — Nouvelle fonctionnalité `-f/--follow` pour suivre les logs en temps réel + affichage détaillé des infos process (working directory, command line, ressources, open files). Amélioration de l'installation via one-liner.
- **1.0.0** — Version initiale : Bash + PowerShell, options `-i/-k/-h/-v`, install/uninstall scripts.

---

# Troubleshooting

### "No process found on port X"
- Vérifiez que le port est bien utilisé : `lsof -i :X` (Linux/macOS) ou `netstat -ano | findstr :X` (Windows)
- Le process peut nécessiter `sudo` pour être visible

### "Permission denied" lors de l'installation
- Assurez-vous d'utiliser `sudo` pour une installation globale
- Ou installez localement dans `$HOME/bin` sans sudo

### Logs not following (-f flag)
- Vérifiez que le process enregistre ses logs dans un fichier
- Cherchez les fichiers `.log` manuellement dans le répertoire de travail du process
- Utilisez `pp -i 3000` (sans `-f`) pour voir le working directory

### PowerShell Execution Policy error
- Exécutez : `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force`

---

_Fin du README_
