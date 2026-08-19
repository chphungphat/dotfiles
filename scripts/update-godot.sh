#!/bin/bash

set -euo pipefail

GODOT_DIR="$HOME/Applications/godot"
GITHUB_API="https://api.github.com/repos/godotengine/godot/releases/latest"

echo "Fetching latest Godot release info..."
LATEST_TAG=$(curl -s "$GITHUB_API" | jq -r '.tag_name')
LATEST_VERSION="${LATEST_TAG#v}"

echo "Latest version: $LATEST_VERSION"
