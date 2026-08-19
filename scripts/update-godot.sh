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
  # godot --version outputs something like "4.7.1.stable.official.a13da4feb" or "4.3.stable.official.77dcf97d0"
  CURRENT_VERSION=$("$GODOT_DIR/godot" --version 2>/dev/null | awk -F'.stable' 'NF>1 {print $1"-stable"}' || true)
  if [[ -n "$CURRENT_VERSION" ]]; then
    echo "Current version: $CURRENT_VERSION"
  fi
fi

if [[ -n "$CURRENT_VERSION" && "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

if [[ -x "$GODOT_DIR/godot" && -n "$CURRENT_VERSION" ]]; then
  ARCHIVE_DIR="$GODOT_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$GODOT_DIR/godot" "$ARCHIVE_DIR/"
fi

echo "Downloading Godot $LATEST_VERSION..."
ZIP_NAME="Godot_v${LATEST_VERSION}_linux.x86_64.zip"
DOWNLOAD_URL="https://github.com/godotengine/godot/releases/latest/download/$ZIP_NAME"

mkdir -p "$GODOT_DIR"
cd "$GODOT_DIR"
curl -fsSL -o "$ZIP_NAME" "$DOWNLOAD_URL"

echo "Extracting binary..."
unzip -q -o "$ZIP_NAME"
mv "Godot_v${LATEST_VERSION}_linux.x86_64" "godot"
chmod +x "godot"
rm -f "$ZIP_NAME"

echo "Downloading desktop file and icon..."
curl -fsSL -o org.godotengine.Godot.desktop "https://raw.githubusercontent.com/godotengine/godot/master/misc/dist/linux/org.godotengine.Godot.desktop"
curl -fsSL -o godot.svg "https://raw.githubusercontent.com/godotengine/godot/master/misc/logo/icon.svg" || curl -fsSL -o godot.svg "https://raw.githubusercontent.com/godotengine/godot/master/misc/dist/linux/godot.svg"

