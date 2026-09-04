#!/usr/bin/env bash
set -euo pipefail

if [ ! -f .env ]; then
  cp .env.example .env
  echo ".env created from .env.example. Set VNC_PASSWORD, then run this script again."
  exit 0
fi

if grep -q '^VNC_PASSWORD=ChangeThisPassword123$' .env; then
  echo "Please change VNC_PASSWORD in .env before starting."
  exit 1
fi

docker compose up -d --build

echo "Browser Linux is starting."
echo "Local URL: http://127.0.0.1:6080/vnc.html"
