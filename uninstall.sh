#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="/usr/local/bin"
TARGET_PATH="$TARGET_DIR/pp"

if [ -f "$TARGET_PATH" ]; then
  if [ ! -w "$TARGET_DIR" ]; then
    sudo rm -f "$TARGET_PATH"
  else
    rm -f "$TARGET_PATH"
  fi
  echo "pp removed from $TARGET_PATH"
else
  echo "pp not found at $TARGET_PATH"
fi
