<#
.SYNOPSIS
Install pp.ps1 as a global command.
#>

param(
    [string]$InstallDir = "$HOME\bin"
)

# Crée le dossier si nécessaire
if (-not (Test-Path $InstallDir)) {
    Write-Output "📂 Creating install directory: $InstallDir"
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Copie pp.ps1
$Source = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "pp.ps1"
$Target = Join-Path $InstallDir "pp.ps1"

if (-not (Test-Path $Source)) {
    Write-Error "pp.ps1 not found in $Source"
    exit 1
}

Copy-Item -Path $Source -Destination $Target -Force
Write-Output "✔️  pp.ps1 copied to $Target"

# Ajoute le dossier au PATH si nécessaire
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $InstallDir })) {
    [Environment]::SetEnvironmentVariable("Path", "$env:Path;$InstallDir", [EnvironmentVariableTarget]::User)
    Write-Output "🔗 Added $InstallDir to PATH. Restart PowerShell to apply."
}

# Crée un alias permanent
$Profile = $PROFILE
if (-not (Test-Path $Profile)) { New-Item -ItemType File -Path $Profile -Force | Out-Null }
$aliasCmd = "Set-Alias pp `"$Target`""
if (-not (Select-String -Path $Profile -Pattern "Set-Alias pp")) {
    Add-Content -Path $Profile -Value $aliasCmd
    Write-Output "🔹 Alias 'pp' created. Restart PowerShell to use 'pp'."
}

Write-Output "✅ Installation complete."
