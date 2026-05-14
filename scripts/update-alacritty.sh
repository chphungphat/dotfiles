#!/bin/bash

set -euo pipefail

ALACRITTY_DIR="$HOME/Applications/alacritty"
BUILD_DIR="/tmp/alacritty-build"
GITHUB_API="https://api.github.com/repos/alacritty/alacritty/releases/latest"

## FETCH VERSION

echo "Fetching latest alacritty release info..."

LATEST_TAG=$(curl -fsSL "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
  echo "error: could not parse alacritty version from GitHub API" >&2
  exit 1
fi

echo "Latest version: $LATEST_VERSION"

CURRENT_VERSION=""
if [[ -x "$ALACRITTY_DIR/alacritty" ]]; then
  CURRENT_VERSION=$("$ALACRITTY_DIR/alacritty" --version 2>/dev/null | awk '{print $2}' | tr -d 'v')
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## CHECK DEPS

if ! command -v cargo &>/dev/null; then
  echo "error: cargo not found. Install rustup and ensure it is on PATH." >&2
  exit 1
fi

## ARCHIVE CURRENT VERSION

if [[ -x "$ALACRITTY_DIR/alacritty" ]]; then
  ARCHIVE_DIR="$ALACRITTY_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$ALACRITTY_DIR/alacritty" "$ARCHIVE_DIR/"
fi

## BUILD

echo "Cloning alacritty $LATEST_TAG..."
rm -rf "$BUILD_DIR"
git clone --depth 1 --branch "$LATEST_TAG" https://github.com/alacritty/alacritty.git "$BUILD_DIR"

cd "$BUILD_DIR"

rustup override set stable
rustup update stable

echo "Building alacritty $LATEST_VERSION (this will take a few minutes)..."
cargo build --release

## INSTALL BINARY

echo "Installing..."

mkdir -p "$ALACRITTY_DIR"
cp "target/release/alacritty" "$ALACRITTY_DIR/alacritty"

SYMLINK="/usr/local/bin/alacritty"
if [[ ! -L "$SYMLINK" ]]; then
  echo "Creating symlink $SYMLINK..."
  sudo ln -s "$ALACRITTY_DIR/alacritty" "$SYMLINK"
else
  echo "Symlink $SYMLINK already exists. Skipping"
fi

## TERMINFO

echo "Installing terminfo..."
mkdir -p "$HOME/.terminfo"
tic -xe alacritty,alacritty-direct extra/alacritty.info -o "$HOME/.terminfo"

## DESKTOP ENTRY

DESKTOP_SRC="$BUILD_DIR/extra/linux/Alacritty.desktop"
DESKTOP_DEST="$HOME/.local/share/applications/Alacritty.desktop"
if [[ -f "$DESKTOP_SRC" ]]; then
  echo "Installing desktop entry..."
  cp "$DESKTOP_SRC" "$DESKTOP_DEST"
fi

## ICON

ICON_SRC="$BUILD_DIR/extra/logo/alacritty-term.svg"
ICON_DEST="$HOME/.local/share/icons/hicolor/scalable/apps/Alacritty.svg"
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

## CLEANUP

echo "Cleaning up build directory..."
rm -rf "$BUILD_DIR"

echo "DONE. Alacritty $LATEST_VERSION installed."
