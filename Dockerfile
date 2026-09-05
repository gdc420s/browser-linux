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
    gnupg \
    && locale-gen C.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Firefox from Mozilla's official APT repository instead of Ubuntu's Snap package.
# This follows Mozilla's recommended Debian/Ubuntu installation method.
RUN set -eux; \
    install -d -m 0755 /etc/apt/keyrings; \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc; \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list; \
    printf '%s\n' \
      'Package: *' \
      'Pin: origin packages.mozilla.org' \
      'Pin-Priority: 1000' \
      > /etc/apt/preferences.d/mozilla; \
    printf '%s\n' \
      'Package: firefox' \
      'Pin: release o=Ubuntu' \
      'Pin-Priority: -1' \
      > /etc/apt/preferences.d/firefox; \
    apt-get update; \
    apt-get install -y --no-install-recommends firefox; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

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
