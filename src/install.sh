#!/usr/bin/env bash
set -euo pipefail

BINARY_NAME="pp"
TARGET_DIR="/usr/local/bin"
SRC_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$BINARY_NAME"
TARGET_PATH="$TARGET_DIR/$BINARY_NAME"

if [ ! -f "$SRC_PATH" ]; then
  echo "Error: $SRC_PATH not found. Run this script from the repo root."
  exit 1
fi

echo "Installing $BINARY_NAME to $TARGET_PATH ..."
if [ ! -w "$TARGET_DIR" ]; then
  echo "Requires sudo to write to $TARGET_DIR"
  sudo cp "$SRC_PATH" "$TARGET_PATH"
  sudo chmod 755 "$TARGET_PATH"
else
  cp "$SRC_PATH" "$TARGET_PATH"
  chmod 755 "$TARGET_PATH"
fi

echo "Done. You can run 'pp -h' now."
