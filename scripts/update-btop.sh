#!/bin/bash

set -euo pipefail

BTOP_DIR="$HOME/Applications/btop"
GITHUB_API="https://api.github.com/repos/aristocratos/btop/releases/latest"
TMP_TARBALL="/tmp/btop.tar.gz"
TMP_EXTRACT="/tmp/btop-extract"

trap 'rm -f "$TMP_TARBALL"; rm -rf "$TMP_EXTRACT"' EXIT

## FETCH VERSION

echo "Fetching latest btop release info..."

LATEST_TAG=$(curl -fsSL "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
  echo "error: could not parse btop version from GitHub API" >&2
  exit 1
fi

echo "Latest version: $LATEST_VERSION"

## CHECK CURRENT VERSION

CURRENT_VERSION=""
if [[ -x "$BTOP_DIR/bin/btop" ]]; then
  CURRENT_VERSION=$("$BTOP_DIR/bin/btop" --version 2>/dev/null | awk '{print $NF}')
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## ARCHIVE CURRENT VERSION

if [[ -x "$BTOP_DIR/bin/btop" ]]; then
  ARCHIVE_DIR="$BTOP_DIR/$CURRENT_VERSION"
  echo "Archiving current version to $ARCHIVE_DIR..."
  mkdir -p "$ARCHIVE_DIR"
  mv "$BTOP_DIR/bin/btop" "$ARCHIVE_DIR/"
fi

## DOWNLOAD

echo "Downloading btop $LATEST_VERSION..."

mkdir -p "$BTOP_DIR/bin"
rm -rf "$TMP_EXTRACT"
mkdir -p "$TMP_EXTRACT"

curl -fL --progress-bar \
  "https://github.com/aristocratos/btop/releases/download/${LATEST_TAG}/btop-x86_64-unknown-linux-musl.tar.gz" \
  -o "$TMP_TARBALL"

## EXTRACT

echo "Extracting..."
tar -xzf "$TMP_TARBALL" -C "$TMP_EXTRACT"

## INSTALL

echo "Installing..."
cp "$TMP_EXTRACT/btop/bin/btop" "$BTOP_DIR/bin/btop"
chmod u+x "$BTOP_DIR/bin/btop"

SYMLINK="/usr/local/bin/btop"
if [[ ! -L "$SYMLINK" ]]; then
  echo "Creating symlink $SYMLINK..."
  sudo ln -s "$BTOP_DIR/bin/btop" "$SYMLINK"
else
  echo "Symlink $SYMLINK already exists. Skipping"
fi

echo "DONE. btop $LATEST_VERSION installed."
