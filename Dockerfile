FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    HOME=/home/linuxuser \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    xvfb \
    x11-utils \
    supervisor \
    dbus-x11 \
    xterm \
    thunar \
    mousepad \
    sudo \
    curl \
    wget \
    ca-certificates \
    locales \
    fonts-dejavu \
    fonts-liberation \
    novnc \
    websockify \
    netcat-openbsd \
    && locale-gen C.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install a standalone Mozilla Firefox build instead of Ubuntu's Snap package.
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) firefox_arch="linux64" ;; \
      arm64) firefox_arch="linux-aarch64" ;; \
      *) echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac; \
    mkdir -p /opt/firefox; \
    curl -fsSL "https://download.mozilla.org/?product=firefox-latest&os=${firefox_arch}&lang=en-US" -o /tmp/firefox.tar.bz2; \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt; \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox; \
    rm -f /tmp/firefox.tar.bz2

RUN useradd -m -s /bin/bash linuxuser \
    && echo 'linuxuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/linuxuser \
    && chmod 0440 /etc/sudoers.d/linuxuser \
    && mkdir -p /etc/x11vnc /var/log/supervisor \
    && chown -R linuxuser:linuxuser /home/linuxuser

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:6080/vnc.html >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
