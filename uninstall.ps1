<#
.SYNOPSIS
Uninstall pp.ps1 command.
#>

param(
    [string]$InstallDir = "$HOME\bin"
)

$Target = Join-Path $InstallDir "pp.ps1"

# Supprime le fichier
if (Test-Path $Target) {
    Remove-Item $Target -Force
    Write-Output "🗑 Removed $Target"
} else {
    Write-Output "⚠️  $Target not found"
}

# Supprime alias du profil
$Profile = $PROFILE
if (Test-Path $Profile) {
    (Get-Content $Profile) | Where-Object { $_ -notmatch "Set-Alias pp" } | Set-Content $Profile
    Write-Output "🔹 Alias removed from profile. Restart PowerShell to apply changes."
}

# (optionnel) retirer le dossier du PATH — mais attention aux autres binaires
# Pas automatique pour éviter de casser autre chose
Write-Output "⚠️  $InstallDir still in PATH if added manually. You can remove it from User PATH if needed."
Write-Output "✅ Uninstall complete."
