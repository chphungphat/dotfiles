#!/usr/bin/env bash
set -euo pipefail

HELPER_DIR="/usr/share/doc/git/contrib/credential/libsecret"
HELPER_BIN="$HELPER_DIR/git-credential-libsecret"

echo "==> Installing packages..."
sudo apt-get install -y \
    git \
    make \
    gcc \
    pkg-config \
    libsecret-1-dev \
    libglib2.0-dev

echo "==> Building git-credential-libsecret..."
sudo make -C "$HELPER_DIR"

echo "==> Configuring git..."
git config --global credential.helper "$HELPER_BIN"

echo "==> Done. Credential helper: $(git config --global credential.helper)"
