#!/bin/bash

set -euo pipefail

REPO="Crashdummyy/roslynLanguageServer"
ASSET_NAME="microsoft.codeanalysis.languageserver.linux-x64.zip"
INSTALL_DIR="$HOME/.local/share/roslyn"
BINARY="$INSTALL_DIR/Microsoft.CodeAnalysis.LanguageServer"
VERSION_FILE="$INSTALL_DIR/RoslynVersion.txt"
TMP_ZIP="/tmp/roslyn.zip"

REINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --reinstall) REINSTALL=1 ;;
    *) echo "error: unknown option: $arg" >&2; exit 1 ;;
  esac
done

trap 'rm -f "$TMP_ZIP"' EXIT

# 1. Fetch latest release metadata
RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")

ROSLYN_VERSION=$(printf '%s' "$RELEASE_JSON" | jq -r '.tag_name')
DOWNLOAD_URL=$(printf '%s' "$RELEASE_JSON" \
  | jq -r ".assets[] | select(.name == \"${ASSET_NAME}\") | .browser_download_url")

if [[ -z "$ROSLYN_VERSION" || "$ROSLYN_VERSION" == "null" ]]; then
  echo "error: could not parse version from GitHub API response" >&2
  exit 1
fi

if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
  echo "error: asset '${ASSET_NAME}' not found in release ${ROSLYN_VERSION}" >&2
  exit 1
fi

# 2. Skip if already on this version (unless --reinstall)
if [[ "$REINSTALL" -eq 0 ]] \
   && [[ -f "$VERSION_FILE" ]] \
   && [[ "$(cat "$VERSION_FILE")" == "$ROSLYN_VERSION" ]]; then
  echo "Roslyn $ROSLYN_VERSION already installed, nothing to do"
  exit 0
fi

if [[ "$REINSTALL" -eq 1 ]] && [[ -d "$INSTALL_DIR" ]]; then
  echo "Removing existing install at $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"
fi

echo "Installing Roslyn $ROSLYN_VERSION..."

# 3. Download the zip
echo "Downloading ${ASSET_NAME}..."
curl -fL --progress-bar "$DOWNLOAD_URL" -o "$TMP_ZIP"

# 4. Extract directly into install dir (files are at zip root, no libexec/ prefix)
mkdir -p "$INSTALL_DIR"
echo "Extracting..."
unzip -o "$TMP_ZIP" -d "$INSTALL_DIR"

# 5. Make the server binary executable (zip stores it as 644)
chmod +x "$BINARY"

# 6. Write the GitHub tag as the canonical version (the zip's RoslynVersion.txt contains
#    an internal build label that differs from the release tag, breaking the skip check).
echo "$ROSLYN_VERSION" > "$VERSION_FILE"

# 7. Newer releases ship razor files at the zip root instead of in a .razorExtension/
#    subdirectory. Create a symlink so roslyn.nvim's config can still find them.
RAZOR_EXT="$INSTALL_DIR/.razorExtension"
if [[ ! -d "$RAZOR_EXT" ]] && [[ -f "$INSTALL_DIR/Microsoft.VisualStudioCode.RazorExtension.dll" ]]; then
  ln -sf "$INSTALL_DIR" "$RAZOR_EXT"
fi

# 8. Verify
echo "Installed Roslyn $ROSLYN_VERSION"
if [[ -d "$RAZOR_EXT" ]]; then
  echo "Razor extension: present"
else
  echo "WARNING: .razorExtension not found — Razor/CSHTML support will be unavailable" >&2
fi
