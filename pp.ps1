#!/usr/bin/env pwsh
<#
.SYNOPSIS
  pp - Port Process Utility (PowerShell version)
  Version 1.0.0
#>

param(
    [Parameter(Position=0)]
    [string]$Port,

    [Alias("i")]
    [switch]$Info,

    [Alias("k")]
    [switch]$Kill,

    [Alias("h")]
    [switch]$Help,

    [Alias("v")]
    [switch]$Version
)

$VERSION = "1.0.0"

function Show-Help {
    @"
pp.ps1 - Port Process Utility

Usage:
  pp.ps1 <port>            : show basic info for the port
  pp.ps1 -i <port>         : detailed process info
  pp.ps1 -k <port>         : kill process using this port
  pp.ps1 -h                : show help
  pp.ps1 -v                : version

Examples:
  pp.ps1 3000
  pp.ps1 -i 5173
  pp.ps1 -k 8000
"@
}

# --- handle -h and -v ---
if ($Help)  { Show-Help; exit }
if ($Version) { Write-Output "pp version $VERSION"; exit }

if (-not $Port) {
    Write-Output "Error: No port provided."
    Show-Help
    exit 1
}

# ---------------------------------------------
# Find processes listening on the specified port
# ---------------------------------------------

$connections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -eq [int]$Port }

if (-not $connections) {
    Write-Output "⚠️  No process found on port $Port"
    exit 0
}

$PIDs = $connections.OwningProcess | Sort-Object -Unique

if (-not $PIDs -or $PIDs.Count -eq 0) {
    Write-Output "⚠️  No process found on port $Port"
    exit 0
}

# ---------------------------------------------
# ACTION
# ---------------------------------------------

if ($Info) {
    Write-Output "ℹ️  Detailed info for port $Port (PIDs: $($PIDs -join ', '))"

    foreach ($pid in $PIDs) {
        Write-Output "`n------ PID $pid ------"
        try {
            Get-Process -Id $pid -ErrorAction Stop | Format-List *
        } catch {
            Write-Output "Process $pid not accessible: $_"
        }
    }

    # Show which program binds the port
    Write-Output "`n🔍 Network binding:"
    $connections | Format-Table LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess

    exit
}

elseif ($Kill) {
    Write-Output "🛑 Killing processes on port $Port ..."

    foreach ($pid in $PIDs) {
        try {
            Stop-Process -Id $pid -Force -ErrorAction Stop
            Write-Output "✔️  Killed PID $pid"
        } catch {
            Write-Output "⚠️  Could not kill PID $pid: $_"
        }
    }

    exit
}

else {
    Write-Output "🔍 Processes using port $Port: $($PIDs -join ', ')"
    $connections | Format-Table LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess
}
