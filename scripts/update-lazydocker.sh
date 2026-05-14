#!/bin/bash

set -euo pipefail

LAZYDOCKER_DIR="$HOME/Applications/lazydocker"
GITHUB_API="https://api.github.com/repos/jesseduffield/lazydocker/releases/latest"
TMP_TARBALL="/tmp/lazydocker.tar.gz"
TMP_EXTRACT="/tmp/lazydocker-extract"

trap 'rm -f "$TMP_TARBALL"; rm -rf "$TMP_EXTRACT"' EXIT

## FETCH VERSION

echo "Fetching latest lazydocker release info..."

LATEST_TAG=$(curl -fsSL "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
  echo "error: could not parse lazydocker version from GitHub API" >&2
  exit 1
fi

echo "Latest version: $LATEST_VERSION"

## CHECK CURRENT VERSION

CURRENT_VERSION=""
if [[ -x "$LAZYDOCKER_DIR/lazydocker" ]]; then
  CURRENT_VERSION=$("$LAZYDOCKER_DIR/lazydocker" --version 2>/dev/null \
    | awk -F'version=' '{print $2}' | cut -d',' -f1)
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## ARCHIVE CURRENT VERSION

if [[ -x "$LAZYDOCKER_DIR/lazydocker" ]]; then
  ARCHIVE_DIR="$LAZYDOCKER_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$LAZYDOCKER_DIR/lazydocker" "$ARCHIVE_DIR/"
fi

## DOWNLOAD

echo "Downloading lazydocker $LATEST_VERSION..."

mkdir -p "$LAZYDOCKER_DIR"
rm -rf "$TMP_EXTRACT"
mkdir -p "$TMP_EXTRACT"

curl -fL --progress-bar \
  "https://github.com/jesseduffield/lazydocker/releases/download/${LATEST_TAG}/lazydocker_${LATEST_VERSION}_Linux_x86_64.tar.gz" \
  -o "$TMP_TARBALL"

## EXTRACT

echo "Extracting..."
tar -xzf "$TMP_TARBALL" -C "$TMP_EXTRACT"

## INSTALL

echo "Installing..."
cp "$TMP_EXTRACT/lazydocker" "$LAZYDOCKER_DIR/lazydocker"
chmod u+x "$LAZYDOCKER_DIR/lazydocker"

SYMLINK="/usr/local/bin/lazydocker"
if [[ ! -L "$SYMLINK" ]]; then
  echo "Creating symlink $SYMLINK..."
  sudo ln -s "$LAZYDOCKER_DIR/lazydocker" "$SYMLINK"
else
  echo "Symlink $SYMLINK already exists. Skipping"
fi

echo "DONE. lazydocker $LATEST_VERSION installed."
