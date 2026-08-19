#!/bin/bash

set -euo pipefail

GODOT_DIR="$HOME/Applications/godot"
GITHUB_API="https://api.github.com/repos/godotengine/godot/releases/latest"

echo "Fetching latest Godot release info..."
LATEST_TAG=$(curl -fsSL "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

echo "Latest version: $LATEST_VERSION"

CURRENT_VERSION=""
if [[ -x "$GODOT_DIR/godot" ]]; then
  # godot --version outputs something like "4.7.1.stable.official.a13da4feb"
  CURRENT_VERSION=$("$GODOT_DIR/godot" --version 2>/dev/null | awk -F'.' '{print $1"."$2"."$3"-"$4}')
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

if [[ -x "$GODOT_DIR/godot" ]]; then
  ARCHIVE_DIR="$GODOT_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$GODOT_DIR/godot" "$ARCHIVE_DIR/"
fi
