#!/usr/bin/env bash
# Sets up headroom as a persistent (boot/login-surviving) proxy in front of
# Claude Code, running in cache-optimization mode.
set -euo pipefail

PRESET="persistent-service"
TARGET="claude"
MODE="token"
PORT="8787"

if ! command -v headroom >/dev/null 2>&1; then
    echo "headroom CLI not found. Install it first with:"
    echo '  uv tool install "headroom-ai[all]"'
    exit 1
fi

echo "==> headroom version: $(headroom --version)"

echo "==> Installing persistent proxy service (mode=${MODE}, port=${PORT}, target=${TARGET})"
headroom install apply \
    --preset "$PRESET" \
    --providers manual \
    --target "$TARGET" \
    --mode "$MODE" \
    --port "$PORT"

echo "==> Deployment status:"
headroom install status

echo "==> Done. Open a NEW terminal/Claude Code session for the routing change to take effect."
