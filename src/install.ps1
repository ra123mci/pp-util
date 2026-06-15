<#
.SYNOPSIS
Install pp.ps1 as a global command.
#>

param(
    [string]$InstallDir = "$HOME\bin"
)

# Create the install directory if needed
if (-not (Test-Path $InstallDir)) {
    Write-Output "[+] Creating install directory: $InstallDir"
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Copy pp.ps1
$Source = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "pp.ps1"
$Target = Join-Path $InstallDir "pp.ps1"

if (-not (Test-Path $Source)) {
    Write-Error "pp.ps1 not found in $Source"
    exit 1
}

Copy-Item -Path $Source -Destination $Target -Force
Write-Output "[OK] pp.ps1 copied to $Target"

# Add directory to PATH if needed
$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($currentPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$InstallDir", [EnvironmentVariableTarget]::User)
    Write-Output "[+] Added $InstallDir to PATH. Restart PowerShell to apply."
}

# Create permanent alias
$ProfileDir = Split-Path $PROFILE
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$aliasCmd = "Set-Alias pp `"$Target`" -Force"
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*Set-Alias pp*") {
    Add-Content -Path $PROFILE -Value "`n$aliasCmd"
    Write-Output "[+] Alias 'pp' created. Restart PowerShell to use 'pp'."
}

Write-Output "[DONE] Installation complete."
