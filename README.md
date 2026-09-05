# Browser Linux Desktop

Ubuntu 24.04 + XFCE desktop running in Docker and accessible from a web browser through noVNC.

## Architecture

Browser → noVNC → websockify → x11vnc → Xvfb → XFCE

## Quick start

```bash
cp .env.example .env
# Edit .env and set a strong VNC_PASSWORD (minimum 6 characters)
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
- `.env.example` — environment template
- `start.sh` — convenience launcher

## Security

Do not expose the noVNC port directly to the public internet. Use a reverse proxy with HTTPS and a strong VNC password. The example Compose file binds 6080 to `127.0.0.1` only.

The Nginx example includes WebSocket forwarding required by noVNC. Replace `linux.example.com` with your real hostname and configure TLS before exposing it publicly.

## Persistence

The `browser_linux_home` volume persists `/home/linuxuser` between container recreations.

## Firefox

Firefox is installed from Mozilla's official APT repository rather than Ubuntu's Snap package. This keeps the browser available in the container without requiring Snap/systemd.

## CI

GitHub Actions builds the image and runs a runtime smoke test that starts the container, verifies noVNC responds, and waits for the Docker health check to become healthy.
