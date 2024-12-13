#!/bin/bash

# Check if was run with sudo or root
if [ "$(id -u)" != 0 ]; then
  echo "This script must be run with sudo privileges"
  exit 1
fi

check_status() {
  echo "Checking Containerd status..."
  systemctl is-active --quiet containerd
  containerd_status=$?

  echo "Checking Docker status"
  systemctl is-active --quiet docker
  docker_status=$?

  if [ $containerd_status -eq 0 ]; then
    echo "containerd service is running"
  else
    echo "containerd service is not running"
  fi

  if [ $docker_status -eq 0 ]; then
    echo "docker service is running"
  else
    echo "docker service is not running"
  fi

  [ $containerd_status -eq 0 ] && [ $docker_status -eq 0 ]
  return $?
}

start_services() {
  echo "Starting containerd service..."
  systemctl start containerd
  containerd_status=$?

  if [ $containerd_status -eq 0 ]; then
    echo "containerd start successfully"
    echo "Starting docker service..."

    systemctl start docker
    docker_status=$?

    if [ $docker_status -eq 0 ]; then
      echo "docker start successfully"
      return 0
    else
      echo "Failed to start docker service"
      return 1
    fi
  else
    echo "Failed to start containerd service"
    return 1
  fi
}

stop_services() {
  echo "Stopping docker service..."
  systemctl stop docker
  docker_status=$?

  echo "Stopping containerd service..."
  systemctl stop containerd
  containerd_status=$?

  if [ $docker_status -eq 0 ] && [ $containerd_status -eq 0 ]; then
    echo "Services stop successfully"
    return 0
  else
    echo "Failed to stop services"
    return 1
  fi
}

restart_services() {
  echo "Restarting services"
  stop_services
  sleep 2
  start_services
  return $?
}

case "$1" in
  start)
    start_services
    ;;
  stop)
    stop_services
    ;;
  status)
    check_status
    ;;
  restart)
    restart_services
    ;;
  *)
    echo "Usage: $0 (start | stop | status | restart)"
    exit 1
    ;;
esac

exit $?
