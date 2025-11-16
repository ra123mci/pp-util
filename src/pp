#!/usr/bin/env bash
# pp - Port Process Utility
# Version 1.0.0

VERSION="1.0.0"

print_help() {
  cat <<'EOF'
pp - Port Process Utility

Usage:
  pp <port>                 : show basic info for the port
  pp -i|--info <port>       : show detailed process info
  pp -k|--kill <port>       : kill process using the port
  pp -h|--help              : show this help
  pp -v|--version           : show version

Examples:
  pp 3000
  pp -i 3000
  pp -k 3000
EOF
}

if [ $# -eq 0 ]; then
  print_help
  exit 1
fi

ACTION=""
PORT=""

# parse args (simple)
while [ $# -gt 0 ]; do
  case "$1" in
    -i|--info) ACTION="info"; shift ;;
    -k|--kill) ACTION="kill"; shift ;;
    -h|--help) print_help; exit 0 ;;
    -v|--version) echo "pp version $VERSION"; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; print_help; exit 2 ;;
    *) PORT="$1"; shift ;;
  esac
done

if [ -z "$PORT" ]; then
  echo "Error: no port provided"
  print_help
  exit 2
fi

# Find PID(s) using the port (works on macOS & Linux)
# Prefer lsof, fallback to ss or netstat
PID=""
# try lsof
if command -v lsof >/dev/null 2>&1; then
  PID=$(lsof -ti :"$PORT" 2>/dev/null || true)
fi

# fallback to ss (linux)
if [ -z "$PID" ] && command -v ss >/dev/null 2>&1; then
  PID=$(ss -ltnp "sport = :$PORT" 2>/dev/null | awk -F',' '/users:/ {print $2}' | sed -E 's/.*pid=([0-9]+).*/\1/' | tr '\n' ' ')
fi

# fallback netstat
if [ -z "$PID" ] && command -v netstat >/dev/null 2>&1; then
  PID=$(netstat -nlp 2>/dev/null | awk -v port=":$PORT" '$4~port {print $7}' | sed -E 's/\/.*//' | tr '\n' ' ')
fi

if [ -z "$PID" ]; then
  echo "⚠️  No process found on port $PORT"
  exit 0
fi

case "$ACTION" in
  info)
    echo "ℹ️  Detailed info for port $PORT (PIDs: $PID):"
    if command -v lsof >/dev/null 2>&1; then
      lsof -i :"$PORT"
    fi
    for p in $PID; do
      if command -v ps >/dev/null 2>&1; then
      
        ps -fp "$p"
      fi
    done
    ;;
  kill)
    echo "🛑 Killing process(es) on port $PORT (PIDs: $PID)..."
    for p in $PID; do
      kill -9 "$p" 2>/dev/null && echo "✔️  Killed $p" || echo "⚠️  Failed to kill $p"
    done
    ;;
  *)
    echo "🔍 Process(es) using port $PORT: PIDs=$PID"
    if command -v lsof >/dev/null 2>&1; then
      lsof -i :"$PORT"
    fi
    ;;
esac
