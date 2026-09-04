#!/usr/bin/env bash
set -euo pipefail

: "${VNC_PASSWORD:?VNC_PASSWORD is required}"

if [ "${#VNC_PASSWORD}" -lt 6 ]; then
  echo "VNC_PASSWORD must be at least 6 characters." >&2
  exit 1
fi

mkdir -p /etc/x11vnc
x11vnc -storepasswd "$VNC_PASSWORD" /etc/x11vnc/passwd >/dev/null
chmod 600 /etc/x11vnc/passwd
chown root:root /etc/x11vnc/passwd

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
