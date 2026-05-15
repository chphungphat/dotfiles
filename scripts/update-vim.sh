#!/bin/bash

set -euo pipefail

VIM_DIR="$HOME/Applications/vim"
GITHUB_API="https://api.github.com/repos/vim/vim-appimage/releases/latest"
VERSION_FILE="$VIM_DIR/.installed-version"

## FETCH VERSION

echo "Fetching latest vim release info..."

RELEASE_JSON=$(curl -s "$GITHUB_API")
LATEST_TAG=$(echo "$RELEASE_JSON" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

echo "Latest version: $LATEST_VERSION"

CURRENT_VERSION=""
if [[ -f "$VERSION_FILE" ]]; then
  CURRENT_VERSION=$(cat "$VERSION_FILE")
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## ARCHIVE CURRENT VERSION

if [[ -x "$VIM_DIR/AppRun" ]] && [[ -n "$CURRENT_VERSION" ]]; then
  ARCHIVE_DIR="$VIM_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  find "$VIM_DIR" -maxdepth 1 \
    ! -name "$CURRENT_VERSION" \
    ! -path "$VIM_DIR" \
    ! -name '[0-9]*' \
    ! -name '.*' \
    -exec mv {} "$ARCHIVE_DIR/" \;
fi

## DOWNLOAD NEW VERSION

DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("^Vim-.*x86_64\\.AppImage$")) | .browser_download_url' | head -1)

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "Error: Could not find Vim AppImage asset in release"
  exit 1
fi

APPIMAGE_NAME="vim-linux-x86_64.appimage"

echo "Downloading Vim $LATEST_VERSION..."
mkdir -p "$VIM_DIR"
curl -L \
  --output "$VIM_DIR/$APPIMAGE_NAME" \
  "$DOWNLOAD_URL"

## EXTRACT APPIMAGE

echo "Extracting AppImage..."

cd "$VIM_DIR"
chmod u+x "$APPIMAGE_NAME"
"./$APPIMAGE_NAME" --appimage-extract > /dev/null

## INSTALLING

echo "Installing..."

cp -a squashfs-root/. .
rm -rf squashfs-root
rm -f "$APPIMAGE_NAME"

echo "$LATEST_VERSION" > "$VERSION_FILE"

SYMLINK="/usr/local/bin/vim"
if [[ ! -L "$SYMLINK" ]]; then
  echo "Creating symlink $SYMLINK..."
  sudo ln -s "$VIM_DIR/AppRun" "$SYMLINK"
else
  echo "Symlink $SYMLINK already exists. Skipping"
fi

DESKTOP_SRC="$VIM_DIR/vim.desktop"
DESKTOP_DEST="$HOME/.local/share/applications/vim.desktop"
if [[ -f "$DESKTOP_SRC" ]]; then
  echo "Installing desktop entry..."
  cp "$DESKTOP_SRC" "$DESKTOP_DEST"
fi

ICON_SRC="$VIM_DIR/usr/share/icons/hicolor/128x128/apps/vim.png"
ICON_DEST="$HOME/.local/share/icons/hicolor/128x128/apps/vim.png"
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

echo "DONE. Vim $LATEST_VERSION installed."
