#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## NPM LSP SERVERS

echo "Installing npm LSP servers..."
npm install -g \
  vscode-langservers-extracted \
  bash-language-server \
  yaml-language-server \
  dockerfile-language-server-nodejs \
  @astrojs/language-server \
  @microsoft/compose-language-service

## CARGO LSP SERVERS

echo "Installing cargo LSP servers..."
cargo install taplo-cli --features lsp
cargo install gitlab-ci-ls

## BINARY LSP SERVERS (GitHub releases — no crates.io binary)

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# tinymist (Typst LSP) — crates.io crate is a library, binary is in GitHub releases
echo "Installing tinymist..."
TINYMIST_VERSION=$(curl -fsSL "https://api.github.com/repos/Myriad-Dreamin/tinymist/releases/latest" | jq -r '.tag_name')
curl -fL "https://github.com/Myriad-Dreamin/tinymist/releases/download/${TINYMIST_VERSION}/tinymist-linux-x64" \
  -o "$BIN_DIR/tinymist"
chmod +x "$BIN_DIR/tinymist"
echo "Installed tinymist $TINYMIST_VERSION"

# marksman (Markdown LSP) — crates.io crate v0.0.1 is a stub with no targets
echo "Installing marksman..."
MARKSMAN_VERSION=$(curl -fsSL "https://api.github.com/repos/artempyanykh/marksman/releases/latest" | jq -r '.tag_name')
curl -fL "https://github.com/artempyanykh/marksman/releases/download/${MARKSMAN_VERSION}/marksman-linux-x64" \
  -o "$BIN_DIR/marksman"
chmod +x "$BIN_DIR/marksman"
echo "Installed marksman $MARKSMAN_VERSION"

## MISE TOOLS

echo "Installing mise tools..."
# lua-language-server: LSP for Lua/Neovim config
mise use -g lua-language-server@latest
# dotnet 10: required by roslyn.nvim (config enforces >= 9, comment confirms DOTNET_ROOT=10)
mise use -g dotnet@10

## SYSTEM PACKAGES

echo "Installing system LSP packages..."
sudo apt install -y clangd

## ROSLYN (C# LSP)

echo "Installing Roslyn language server..."
bash "$SCRIPT_DIR/update-roslyn.sh"

echo ""
echo "Done. Restart Neovim and open a file to verify each LSP attaches."
