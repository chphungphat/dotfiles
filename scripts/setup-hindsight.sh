#!/bin/bash
# Installs systemd --user units that:
#   - hindsight.service      : `docker compose up -d` at boot/login, `down` on stop
#   - hindsight-logs-db.service / hindsight-logs-app.service : follow each
#     container's log stream (`docker logs -f`, via the docker group + socket,
#     since the raw json-file files under /var/lib/docker are root-only) into
#     a stable host path so logs survive container recreation.
#
# Requires: docker compose stack config at docker/hindsight/.env (see .env.example).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$REPO_DIR/docker/hindsight"
LOG_DIR="$COMPOSE_DIR/logs"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
DOCKER_BIN="$(command -v docker)"

## PREFLIGHT

if [[ ! -f "$COMPOSE_DIR/.env" ]]; then
  echo "Missing $COMPOSE_DIR/.env — copy .env.example to .env and fill it in first." >&2
  exit 1
fi

if ! id -nG "$USER" | grep -qw docker; then
  echo "User $USER is not in the 'docker' group; 'docker compose'/'docker logs' calls will fail without sudo." >&2
  exit 1
fi

mkdir -p "$USER_SYSTEMD_DIR" "$LOG_DIR"

## INSTALL UNITS

echo "Writing hindsight.service..."
cat > "$USER_SYSTEMD_DIR/hindsight.service" << EOF
[Unit]
Description=Hindsight memory server (docker compose)
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$COMPOSE_DIR
# User systemd manager cannot depend on the system docker.service unit directly
# (separate manager instance), so poll the socket instead of Requires=/After=.
ExecStartPre=/bin/sh -c 'for i in \$(seq 1 30); do $DOCKER_BIN info >/dev/null 2>&1 && exit 0; sleep 1; done; echo "docker daemon not reachable after 30s" >&2; exit 1'
ExecStart=$DOCKER_BIN compose up -d
ExecStop=$DOCKER_BIN compose down
TimeoutStartSec=300

[Install]
WantedBy=default.target
EOF

echo "Writing hindsight-logs-db.service..."
cat > "$USER_SYSTEMD_DIR/hindsight-logs-db.service" << EOF
[Unit]
Description=Hindsight db container log follower
After=hindsight.service
BindsTo=hindsight.service

[Service]
ExecStart=$DOCKER_BIN logs -f --timestamps hindsight-db
StandardOutput=append:$LOG_DIR/db.log
StandardError=append:$LOG_DIR/db.log
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

echo "Writing hindsight-logs-app.service..."
cat > "$USER_SYSTEMD_DIR/hindsight-logs-app.service" << EOF
[Unit]
Description=Hindsight app container log follower
After=hindsight.service
BindsTo=hindsight.service

[Service]
ExecStart=$DOCKER_BIN logs -f --timestamps hindsight-app
StandardOutput=append:$LOG_DIR/app.log
StandardError=append:$LOG_DIR/app.log
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

## ENABLE LINGER (so user units start at boot without an active login session)

echo "Enabling linger for $USER..."
loginctl enable-linger "$USER" 2>/dev/null || sudo loginctl enable-linger "$USER"

## ENABLE AND START

echo "Reloading systemd user daemon..."
systemctl --user daemon-reload

for unit in hindsight.service hindsight-logs-db.service hindsight-logs-app.service; do
  echo "Enabling $unit..."
  systemctl --user enable "$unit"
done

echo "Starting hindsight.service..."
systemctl --user start hindsight.service

echo "Waiting for containers to become healthy..."
sleep 5
systemctl --user start hindsight-logs-db.service hindsight-logs-app.service

## VERIFY

sleep 2
if systemctl --user is-active --quiet hindsight.service; then
  echo "DONE. Hindsight stack is up."
  echo "  API:           http://localhost:8888"
  echo "  Control Plane: http://localhost:9999"
  echo "  Logs:          $LOG_DIR/{db,app}.log"
else
  echo "WARNING: hindsight.service did not become active. Check: systemctl --user status hindsight.service"
fi
