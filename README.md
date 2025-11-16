# 🟢 pp — Port Process Utility

`pp` est un utilitaire léger pour **lister**, **inspecter** et **tuer** les processus liés à un port réseau. Il fournit une version **Bash** pour Linux/macOS et une version **PowerShell** pour Windows. Utile pour les développeurs qui veulent rapidement identifier et arrêter un service écoutant sur un port (ex. 3000, 5173, 8080).

---

## Contenu du dépôt

```
.
├─ pp                  # script Bash (Linux / macOS)
├─ install.sh          # installe pp dans /usr/local/bin
├─ uninstall.sh        # désinstalle pp
├─ pp.ps1              # script PowerShell (Windows)
├─ install.ps1         # installe pp.ps1 (user scope)
├─ uninstall.ps1       # désinstalle pp.ps1
├─ package.json        # (optionnel) pour publication npm
└─ README.md           # ce fichier
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
cd pp
sudo ./install.sh
```

### Installer (local, sans sudo)

```bash
mkdir -p "$HOME/bin"
cp pp "$HOME/bin/pp"
chmod +x "$HOME/bin/pp"
# ajoute $HOME/bin dans ton PATH si nécessaire
# echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

### Désinstaller

```bash
sudo ./uninstall.sh
# ou si installé localement
rm "$HOME/bin/pp"
```

---

## Windows (PowerShell)

### Pré-requis

- Windows 10/11 ou PowerShell Core 7+
- Permission d’exécution de scripts (voir remarque Execution Policy ci-dessous)

### Installer (user-scope)

Ouvre PowerShell, place-toi dans le repo, puis :

```powershell
.\install.ps1
```

`install.ps1` copie `pp.ps1` dans `"$HOME\bin"` (par défaut), ajoute ce dossier au `PATH` utilisateur et crée un alias permanent `pp` dans ton profil PowerShell.

### Désinstaller

```powershell
.\uninstall.ps1
```

---

## Remarques sur PowerShell Execution Policy

Si l'exécution de scripts est bloquée, lance dans PowerShell (en tant qu'utilisateur) :

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

Ou débloque le fichier avant de l’exécuter :

```powershell
Unblock-File .\pp.ps1
```

---

# Usage

> Les deux versions exposent les mêmes options et comportement :
> `pp 3000`, `pp -i 3000`, `pp -k 3000`, `pp -h`, `pp -v`

## Options

```
-i, --info    : Affiche les détails du(es) process(es) et les bindings réseau
-k, --kill    : Tue le(s) process(es) utilisant le port
-h, --help    : Affiche l'aide
-v, --version : Affiche la version
```

## Exemples (Linux/macOS)

```bash
# quick info
pp 3000

# detailed info
pp -i 3000
pp --info 3000

# kill processes on port
pp -k 3000
pp --kill 3000

# help / version
pp -h
pp -v
```

## Exemples (Windows / PowerShell)

```powershell
# quick info
pp 3000

# detailed info
pp -i 3000

# kill
pp -k 3000

# help / version
pp -h
pp -v
```

---

# Comportement & implémentation

- Le script détecte les PID(s) liés au port en priorité via `lsof` (Linux/macOS) ou `Get-NetTCPConnection` (Windows). Des fallbacks (`ss`, `netstat`) sont utilisés si nécessaire.
- `pp` gère le cas où plusieurs PID seraient retournés (rare, mais possible).
- `--kill` utilise `kill -9` (Bash) / `Stop-Process -Force` (PowerShell) pour s'assurer d'arrêter le process ; adapte si tu préfères un signal plus doux.
- L'installation globale met le binaire dans `/usr/local/bin` (Linux/macOS) ou copie `pp.ps1` dans `"$HOME\bin"` et crée un alias (Windows).

---

# Sécurité & bonnes pratiques

- **Ne pipe pas** de code non audité dans `bash` ou `pwsh` depuis Internet (`curl | bash`) sauf si tu fais confiance au repo.
- L'option `--kill` force l'arrêt : vérifie le PID et le process avant de l'utiliser en production.
- Si tu souhaites une suppression plus propre, remplace `kill -9` par `kill` (SIGTERM) d’abord, puis escalate si nécessaire.
- Pour une installation multi-utilisateur sur Windows (tous les utilisateurs), installe dans `C:\Program Files\pp` et ajoute au PATH système (nécessite élévation/admin). Je peux t'aider à générer une version installatrice si tu veux.

---

# Publication & installation alternative

### Via npm (optionnel)

Si tu veux distribuer via npm, le `package.json` contient :

```json
{
  "name": "pp-port-util",
  "version": "1.0.0",
  "bin": { "pp": "./pp" },
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
sudo curl -sL "https://raw.githubusercontent.com/<TON_ORG>/<REPO>/main/pp" -o /usr/local/bin/pp \
  && sudo chmod +x /usr/local/bin/pp
```

Préconisé : télécharger, auditer, puis installer manuellement.

---

# Développement & contribution

- Fork → clone → ouvre un PR
- Tests manuels : vérifie `pp` sur Linux/macOS avec `lsof`, et `pp.ps1` sur PowerShell en local
- Ajoute des tests CI si tu veux (GitHub Actions) pour lint & basic smoke tests

---

# Fichiers importants (rapide rappel)

- `pp` : script Bash — donne `pp` CLI sur Linux/macOS
- `install.sh` / `uninstall.sh` : installer/désinstaller bash version
- `pp.ps1` : script PowerShell — donne `pp` CLI sur Windows
- `install.ps1` / `uninstall.ps1` : installer/désinstaller ps1 version
- `package.json` : pour publication npm (optionnel)

---

# Licence

Ce projet est fourni sous licence **MIT**. Ajoute un fichier `LICENSE` si tu veux publier.

---

# Changelog

- **1.0.0** — Version initiale : Bash + PowerShell, options `-i/-k/-h/-v`, install/uninstall scripts.

---

_Fin du README_
