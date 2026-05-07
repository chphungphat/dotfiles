#!/bin/bash

set -euo pipefail

NEOVIM_DIR="$HOME/Applications/neovim"
APPIMAGE_NAME="nvim-linux-x86_64.appimage"
GITHUB_API="https://api.github.com/repos/neovim/neovim/releases/latest"

## FETCH VERSION

echo "Fetching latest neovim release info..."

LATEST_TAG=$(curl -s "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

echo "Latest version: $LATEST_VERSION"

CURRENT_VERSION=""
if [[ -x "$NEOVIM_DIR/AppRun" ]]; then
  CURRENT_VERSION=$("$NEOVIM_DIR/AppRun" --version 2>/dev/null | head -1 | awk '{print $2}' | tr -d 'v')
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## ARCHIVE CURRNET VERSION

if [[ -x "$NEOVIM_DIR/AppRun" ]]; then
  ARCHIVE_DIR="$NEOVIM_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  find "$NEOVIM_DIR" -maxdepth 1 \
    ! -name "$CURRENT_VERSION" \
    ! -path "$NEOVIM_DIR" \
    ! -name '[0-9]*' \
    ! -name '.*' \
    -exec mv {} "$ARCHIVE_DIR/" \;
fi

## DOWNLOAD NEW VERSION

echo "Downloading Neovim $LATEST_VERSION..."

curl -L \
  --output "$NEOVIM_DIR/$APPIMAGE_NAME" \
  "https://github.com/neovim/neovim/releases/latest/download/$APPIMAGE_NAME"

## EXTRACT APPIMAGE

echo "Extracting AppImage..." 

cd "$NEOVIM_DIR"
chmod u+x "$APPIMAGE_NAME"
"./$APPIMAGE_NAME" --appimage-extract > /dev/null

## INSTALLING

echo "Installing..."

cp -a squashfs-root/. .
rm -rf squashfs-root
rm -f "$APPIMAGE_NAME"

SYMLINK="/usr/local/bin/nvim"
if [[ ! -L "$SYMLINK" ]]; then
  echo "Creating symlink $SYMLINK..."
  sudo ln -s "$NEOVIM_DIR/AppRun" "$SYMLINK"
else
  echo "Symlink $SYMLINK already exists. Skipping"
fi

DESKTOP_SRC="$NEOVIM_DIR/nvim.desktop"
DESKTOP_DEST="$HOME/.local/share/applications/nvim.desktop"
if [[ -f "$DESKTOP_SRC" ]]; then
  echo "Installing desktop entry..."
  cp "$DESKTOP_SRC" "$DESKTOP_DEST"
fi

ICON_SRC="$NEOVIM_DIR/usr/share/icons/hicolor/128x128/apps/nvim.png"
ICON_DEST="$HOME/.local/share/icons/hicolor/128x128/apps/nvim.png"
if [[ -f "$ICON_SRC" ]]; then
  echo "Installing icon..."
  mkdir -p "$(dirname "$ICON_DEST")"
  cp "$ICON_SRC" "$ICON_DEST"
fi

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$HOME/.local/share/applications"
fi

if command -v gtk-update-icon-cache &>/dev/null; then
  gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor"
fi

echo "DONE. Neovim $LATEST_VERSION installed."
