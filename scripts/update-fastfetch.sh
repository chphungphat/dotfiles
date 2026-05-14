#!/bin/bash

set -euo pipefail

GITHUB_API="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"
TMP_DEB="/tmp/fastfetch.deb"

trap 'rm -f "$TMP_DEB"' EXIT

## FETCH VERSION

echo "Fetching latest fastfetch release info..."

LATEST_TAG=$(curl -fsSL "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
  echo "error: could not parse fastfetch version from GitHub API" >&2
  exit 1
fi

echo "Latest version: $LATEST_VERSION"

## CHECK CURRENT VERSION

CURRENT_VERSION=""
if command -v fastfetch &>/dev/null; then
  CURRENT_VERSION=$(fastfetch --version 2>/dev/null | awk '{print $2}')
  echo "Current version: $CURRENT_VERSION"
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already on latest version: $LATEST_VERSION. Exiting"
  exit 0
fi

## DOWNLOAD

echo "Downloading fastfetch $LATEST_VERSION..."

curl -fL --progress-bar \
  "https://github.com/fastfetch-cli/fastfetch/releases/download/${LATEST_TAG}/fastfetch-linux-amd64.deb" \
  -o "$TMP_DEB"

## INSTALL

echo "Installing..."
sudo dpkg -i "$TMP_DEB"

echo "DONE. fastfetch $LATEST_VERSION installed."
