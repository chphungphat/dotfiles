#!/bin/bash

set -euo pipefail

GODOT_DIR="$HOME/Applications/godot"
GITHUB_API="https://api.github.com/repos/godotengine/godot/releases/latest"

echo "Fetching latest Godot release info..."
AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: token $GITHUB_TOKEN")
fi
LATEST_TAG=$(curl "${AUTH_HEADER[@]}" -fsSL "$GITHUB_API" | jq -r '.tag_name')
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

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading Godot $LATEST_VERSION..."
ZIP_NAME="Godot_v${LATEST_VERSION}_linux.x86_64.zip"
DOWNLOAD_URL="https://github.com/godotengine/godot/releases/latest/download/$ZIP_NAME"

curl -fsSL -o "$TMP_DIR/$ZIP_NAME" "$DOWNLOAD_URL"

echo "Extracting binary..."
unzip -q -o "$TMP_DIR/$ZIP_NAME" -d "$TMP_DIR"
EXTRACTED_BIN="$TMP_DIR/Godot_v${LATEST_VERSION}_linux.x86_64"
chmod +x "$EXTRACTED_BIN"

if [[ -x "$GODOT_DIR/godot" && -n "$CURRENT_VERSION" ]]; then
  ARCHIVE_DIR="$GODOT_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$GODOT_DIR/godot" "$ARCHIVE_DIR/"
fi

mkdir -p "$GODOT_DIR"
mv "$EXTRACTED_BIN" "$GODOT_DIR/godot"

echo "Downloading desktop file and icon..."
curl -fsSL -o "$GODOT_DIR/org.godotengine.Godot.desktop" "https://raw.githubusercontent.com/godotengine/godot/${LATEST_TAG}/misc/dist/linux/org.godotengine.Godot.desktop"
curl -fsSL -o "$GODOT_DIR/godot.svg" "https://raw.githubusercontent.com/godotengine/godot/${LATEST_TAG}/misc/logo/icon.svg" || curl -fsSL -o "$GODOT_DIR/godot.svg" "https://raw.githubusercontent.com/godotengine/godot/${LATEST_TAG}/misc/dist/linux/godot.svg" || curl -fsSL -o "$GODOT_DIR/godot.svg" "https://raw.githubusercontent.com/godotengine/godot/${LATEST_TAG}/icon.svg"

echo "Creating symlinks..."

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
ln -sf "$GODOT_DIR/godot" "$BIN_DIR/godot"

APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
ln -sf "$GODOT_DIR/org.godotengine.Godot.desktop" "$APP_DIR/org.godotengine.Godot.desktop"

ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$ICON_DIR"
ln -sf "$GODOT_DIR/godot.svg" "$ICON_DIR/godot.svg"

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$APP_DIR"
fi

if command -v gtk-update-icon-cache &>/dev/null; then
  gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor"
fi

echo "DONE. Godot $LATEST_VERSION installed."
