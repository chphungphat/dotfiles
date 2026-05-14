#!/bin/bash

set -euo pipefail

LAZYGIT_DIR="$HOME/Applications/lazygit"
GITHUB_API="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
TMP_TARBALL="/tmp/lazygit.tar.gz"
TMP_EXTRACT="/tmp/lazygit-extract"

trap 'rm -f "$TMP_TARBALL"; rm -rf "$TMP_EXTRACT"' EXIT

## FETCH VERSION

echo "Fetching latest lazygit release info..."

LATEST_TAG=$(curl -fsSL "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
  echo "error: could not parse lazygit version from GitHub API" >&2
  exit 1
fi

echo "Latest version: $LATEST_VERSION"

## CHECK CURRENT VERSION

CURRENT_VERSION=""
if [[ -x "$LAZYGIT_DIR/lazygit" ]]; then
  CURRENT_VERSION=$("$LAZYGIT_DIR/lazygit" --version 2>/dev/null \
    | awk -F'version=' '{print $2}' | cut -d',' -f1)
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## ARCHIVE CURRENT VERSION

if [[ -x "$LAZYGIT_DIR/lazygit" ]]; then
  ARCHIVE_DIR="$LAZYGIT_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$LAZYGIT_DIR/lazygit" "$ARCHIVE_DIR/"
fi

## DOWNLOAD

echo "Downloading lazygit $LATEST_VERSION..."

mkdir -p "$LAZYGIT_DIR"
rm -rf "$TMP_EXTRACT"
mkdir -p "$TMP_EXTRACT"

curl -fL --progress-bar \
  "https://github.com/jesseduffield/lazygit/releases/download/${LATEST_TAG}/lazygit_${LATEST_VERSION}_Linux_x86_64.tar.gz" \
  -o "$TMP_TARBALL"

## EXTRACT

echo "Extracting..."
tar -xzf "$TMP_TARBALL" -C "$TMP_EXTRACT"

## INSTALL

echo "Installing..."
cp "$TMP_EXTRACT/lazygit" "$LAZYGIT_DIR/lazygit"
chmod u+x "$LAZYGIT_DIR/lazygit"

SYMLINK="/usr/local/bin/lazygit"
if [[ ! -L "$SYMLINK" ]]; then
  echo "Creating symlink $SYMLINK..."
  sudo ln -s "$LAZYGIT_DIR/lazygit" "$SYMLINK"
else
  echo "Symlink $SYMLINK already exists. Skipping"
fi

echo "DONE. lazygit $LATEST_VERSION installed."
