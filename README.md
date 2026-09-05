# Browser Linux Desktop

Ubuntu 24.04 + XFCE desktop running in Docker and accessible from a web browser through noVNC.

## Architecture

Browser → HTTPS reverse proxy → noVNC → websockify → x11vnc → Xvfb → XFCE

## Quick start

```bash
cp .env.example .env
# Edit .env and set a unique VNC_PASSWORD (minimum 12 characters)
docker compose up -d --build
```

Open `http://127.0.0.1:6080/vnc.html` and enter the VNC password.

For a VPS, keep port 6080 bound to localhost and put Nginx/Caddy in front with HTTPS.

## Files

- `Dockerfile` — Ubuntu/XFCE/noVNC image
- `docker-compose.yml` — runtime, persistence and resource limits
- `entrypoint.sh` — validates the VNC password and starts Supervisor
- `supervisord.conf` — starts Xvfb, D-Bus, XFCE, x11vnc and noVNC
- `nginx/default.conf` — example reverse-proxy configuration
- `.env.example` — safe environment template
- `start.sh` — convenience launcher

## Security

- Do **not** expose port 6080 directly to the public internet.
- Use a reverse proxy with HTTPS when deploying on a VPS.
- Use a unique VNC password of at least 12 characters.
- Keep `.env` private; never commit your real password to Git.
- The example Compose file binds 6080 to `127.0.0.1` only.
- The container uses Docker `no-new-privileges`.
- The desktop user runs without `sudo`/root escalation.
- The VNC password file is created with permission `600`.

The Nginx example includes the WebSocket forwarding required by noVNC. Replace `linux.example.com` with your real hostname and configure TLS before exposing it publicly.

## Persistence

The `browser_linux_home` volume persists `/home/linuxuser` between container recreations.

## Firefox

Firefox is installed from Mozilla's official APT repository rather than Ubuntu's Snap package. This keeps the browser available in the container without requiring Snap/systemd.

## CI

GitHub Actions builds the image and runs a runtime smoke test covering noVNC, container health, Supervisor, XFCE/X11, VNC, Firefox, localhost-only binding, no-new-privileges, absence of Snap and sudo, non-root desktop execution, and VNC password-file permissions.
