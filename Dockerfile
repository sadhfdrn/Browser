# Chrome Headless Dockerfile for Render with WebSocket Access
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CHROME_BIN=/usr/bin/google-chrome
ENV DISPLAY=:99
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV CHROME_DEVEL_SANDBOX=/usr/lib/chromium-browser/chrome-sandbox

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    curl \
    unzip \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# Add Google Chrome repository
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

# Install Google Chrome
RUN apt-get update && apt-get install -y \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

# Set working directory
WORKDIR /home/chrome

# Copy startup script
COPY <<EOF /home/chrome/start-chrome.sh
#!/bin/bash
# Start Xvfb in the background
Xvfb :99 -screen 0 1920x1080x24 &

# Wait for Xvfb to start
sleep 2

# Start Chrome with remote debugging
exec google-chrome \
    --headless \
    --no-sandbox \
    --disable-setuid-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-extensions \
    --disable-plugins \
    --disable-images \
    --disable-javascript \
    --virtual-time-budget=5000 \
    --run-all-compositor-stages-before-draw \
    --disable-background-networking \
    --disable-background-networking \
    --disable-default-apps \
    --disable-extensions \
    --disable-sync \
    --disable-translate \
    --hide-scrollbars \
    --metrics-recording-only \
    --mute-audio \
    --no-first-run \
    --safebrowsing-disable-auto-update \
    --ignore-certificate-errors \
    --ignore-ssl-errors \
    --ignore-certificate-errors-spki-list \
    --remote-debugging-port=9222 \
    --remote-debugging-address=0.0.0.0 \
    --window-size=1920,1080 \
    --user-data-dir=/tmp/chrome-user-data \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --about:blank
EOF

# Make the script executable
RUN chmod +x /home/chrome/start-chrome.sh

# Alternative simplified startup script
COPY <<EOF /home/chrome/simple-start.sh
#!/bin/bash

# Create temp directory for Chrome
mkdir -p /tmp/chrome-user-data
chmod 777 /tmp/chrome-user-data

# Start Chrome with full headless configuration
exec google-chrome \
    --headless=new \
    --no-sandbox \
    --disable-setuid-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-gpu-sandbox \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI,VizDisplayCompositor,AudioServiceOutOfProcess,VizDisplayCompositor \
    --disable-extensions \
    --disable-plugins \
    --disable-default-apps \
    --disable-sync \
    --disable-translate \
    --hide-scrollbars \
    --mute-audio \
    --no-first-run \
    --no-default-browser-check \
    --no-zygote \
    --single-process \
    --disable-logging \
    --disable-gpu-logging \
    --silent \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --use-gl=swiftshader \
    --disable-software-rasterizer \
    --disable-background-networking \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-field-trial-config \
    --disable-ipc-flooding-protection \
    --enable-features=NetworkService,NetworkServiceInProcess \
    --force-color-profile=srgb \
    --metrics-recording-only \
    --no-crash-upload \
    --no-default-browser-check \
    --no-first-run \
    --no-pings \
    --no-service-autorun \
    --password-store=basic \
    --use-mock-keychain \
    --remote-debugging-port=9222 \
    --remote-debugging-address=0.0.0.0 \
    --window-size=1920,1080 \
    --user-data-dir=/tmp/chrome-user-data \
    --virtual-time-budget=5000 \
    --run-all-compositor-stages-before-draw \
    --about:blank
EOF

RUN chmod +x /home/chrome/simple-start.sh

# Change ownership of files
RUN chown -R chrome:chrome /home/chrome

# Switch to chrome user
USER chrome

# Expose the remote debugging port
EXPOSE 9222

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9222/json/version || exit 1

# Start Chrome
CMD ["/home/chrome/simple-start.sh"]
