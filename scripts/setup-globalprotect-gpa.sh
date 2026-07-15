#!/bin/bash

set -euo pipefail

GPA_SERVICE_SRC="/opt/paloaltonetworks/globalprotect/gpa.service"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
GPA_SERVICE_DEST="$USER_SYSTEMD_DIR/gpa.service"

## PREFLIGHT

if [[ ! -f "$GPA_SERVICE_SRC" ]]; then
  echo "GlobalProtect not installed (missing $GPA_SERVICE_SRC). Exiting."
  exit 1
fi

## INSTALL USER SERVICE

echo "Installing gpa.service to $USER_SYSTEMD_DIR..."

mkdir -p "$USER_SYSTEMD_DIR"
cp "$GPA_SERVICE_SRC" "$GPA_SERVICE_DEST"

# Fix PanGPA exiting with code 0 on boot before GUI is ready
echo "Creating systemd override to ensure PanGPA restarts if GUI is not ready..."
mkdir -p "$USER_SYSTEMD_DIR/gpa.service.d"
cat > "$USER_SYSTEMD_DIR/gpa.service.d/override.conf" << 'EOF'
[Service]
Restart=always
RestartSec=2
EOF
## ENABLE AND START

echo "Reloading systemd user daemon..."
systemctl --user daemon-reload

echo "Enabling gpa.service..."
systemctl --user enable gpa.service

echo "Starting gpa.service..."
systemctl --user start gpa.service

## VERIFY

sleep 1
if systemctl --user is-active --quiet gpa.service; then
  echo "DONE. PanGPA is running."
else
  echo "WARNING: gpa.service started but may not be active. Check: systemctl --user status gpa.service"
fi
