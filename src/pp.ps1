#!/usr/bin/env pwsh
<#
.SYNOPSIS
  pp - Port Process Utility (PowerShell version)
  Version 1.1.0
#>

param(
    [Parameter(Position=0)]
    [string]$Port,

    [Alias("i")]
    [switch]$Info,

    [Alias("k")]
    [switch]$Kill,

    [Alias("f")]
    [switch]$Follow,

    [Alias("h")]
    [switch]$Help,

    [Alias("v")]
    [switch]$Version
)

$VERSION = "1.1.0"

function Show-Help {
    @"
pp - Port Process Utility

Usage:
  pp <port>                : show basic info for the port
  pp -i <port>             : detailed process info
  pp -i -f <port>          : detailed info + follow logs
  pp -k <port>             : kill process using this port
  pp -h                     : show help
  pp -v                     : version

Examples:
  pp 3000
  pp -i 5173
  pp -i -f 8000
  pp -k 3000
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

# Find processes listening on the specified port
$connections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -eq [int]$Port }

if (-not $connections) {
    Write-Output "[WARNING] No process found on port $Port"
    exit 0
}

$PIDs = $connections.OwningProcess | Sort-Object -Unique

if (-not $PIDs -or $PIDs.Count -eq 0) {
    Write-Output "[WARNING] No process found on port $Port"
    exit 0
}

# --- ACTION ---

if ($Info) {
    Write-Output "[INFO] Detailed info for port $Port (PIDs: $($PIDs -join ', '))"

    foreach ($pid in $PIDs) {
        Write-Output ""
        Write-Output "=================================================="
        Write-Output "PID: $pid"
        Write-Output "=================================================="
        
        try {
            $proc = Get-Process -Id $pid -ErrorAction Stop
            
            Write-Output ""
            Write-Output "[PROCESS INFO]"
            Write-Output "  Name: $($proc.Name)"
            Write-Output "  User: $(((Get-Process -Id $pid -IncludeUserName -ErrorAction SilentlyContinue).UserName) -join ', ')"
            Write-Output "  Handle Count: $($proc.HandleCount)"
            
            Write-Output ""
            Write-Output "[WORKING DIRECTORY]"
            Write-Output "  $($proc.Path -replace '\\[^\\]*$', '')"
            
            Write-Output ""
            Write-Output "[FULL PATH]"
            Write-Output "  $($proc.Path)"
            
            Write-Output ""
            Write-Output "[COMMAND LINE]"
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $pid" -ErrorAction SilentlyContinue).CommandLine
                if ($cmdLine) {
                    Write-Output "  $cmdLine"
                } else {
                    Write-Output "  N/A"
                }
            } catch {
                Write-Output "  N/A"
            }
            
            Write-Output ""
            Write-Output "[RESOURCE USAGE]"
            Write-Output "  Memory: $([math]::Round($proc.WorkingSet / 1MB, 2)) MB"
            Write-Output "  Threads: $($proc.Threads.Count)"
            
            Write-Output ""
            Write-Output "[PROCESS TIMES]"
            Write-Output "  Started: $($proc.StartTime)"
            Write-Output "  CPU Time: $($proc.TotalProcessorTime)"
            
        } catch {
            Write-Output "[WARNING] Process $pid not accessible: $_"
        }
    }

    # Show network binding
    Write-Output ""
    Write-Output "=================================================="
    Write-Output "[NETWORK BINDING]"
    Write-Output "=================================================="
    $connections | Format-Table LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess -AutoSize

    # Follow logs if requested
    if ($Follow) {
        Write-Output ""
        Write-Output "=================================================="
        Write-Output "[FOLLOWING PROCESS OUTPUT] (Ctrl+C to stop)"
        Write-Output "=================================================="
        Write-Output ""
        
        foreach ($pid in $PIDs) {
            try {
                $proc = Get-Process -Id $pid -ErrorAction Stop
                
                # Try to find and tail application logs
                $potentialLogPaths = @(
                    "$($proc.Path -replace '\\[^\\]*$', '')\logs\*",
                    "$($proc.Path -replace '\\[^\\]*$', '')\*.log",
                    "C:\ProgramData\*\logs\*",
                    "$env:APPDATA\*\logs\*",
                    "$env:TEMP\*$pid*.log"
                )
                
                $logFiles = @()
                foreach ($pattern in $potentialLogPaths) {
                    try {
                        $found = Get-ChildItem -Path $pattern -File -ErrorAction SilentlyContinue -Filter "*.log" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
                        if ($found) {
                            $logFiles += $found
                        }
                    } catch { }
                }
                
                if ($logFiles.Count -gt 0) {
                    $latestLog = $logFiles[0]
                    Write-Output "[LOG] Tailing: $($latestLog.FullName)"
                    Write-Output ""
                    Get-Content -Path $latestLog.FullName -Tail 20 -Wait -ErrorAction SilentlyContinue
                } else {
                    Write-Output "[WARNING] No log files found for PID $pid"
                    Write-Output "    Consider checking application logs manually in:"
                    Write-Output "    - $($proc.Path -replace '\\[^\\]*$', '')\logs"
                    Write-Output "    - Event Viewer (Applications and Services Logs)"
                }
            } catch {
                Write-Output "[ERROR] Error accessing process logs: $_"
            }
        }
    }

    exit
}

elseif ($Kill) {
    Write-Output "[ACTION] Killing processes on port $Port ..."

    foreach ($pid in $PIDs) {
        try {
            Stop-Process -Id $pid -Force -ErrorAction Stop
            Write-Output "[OK] Killed PID $pid"
        } catch {
            Write-Output "[ERROR] Could not kill PID $pid: $_"
        }
    }

    exit
}

else {
    Write-Output "[PROCESSES] Using port $Port : $($PIDs -join ', ')"
    $connections | Format-Table LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess
}
