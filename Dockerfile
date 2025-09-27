FROM browserless/chrome

ENV PORT=$PORT
EXPOSE $PORT
ENV PREBOOT_CHROME=true
ENV KEEP_ALIVE=true
ENV PREBOOT_QUANTITY=1

# Create writable dirs for crashpad
RUN mkdir -p /tmp/.config /tmp/.cache /tmp/crashpad \
    && chmod -R 777 /tmp/.config /tmp/.cache /tmp/crashpad

# Point Chrome/XDG to writable locations
ENV XDG_CONFIG_HOME=/tmp/.config
ENV XDG_CACHE_HOME=/tmp/.cache

# One-line JSON for launch args
ENV DEFAULT_LAUNCH_ARGS='["--no-sandbox","--disable-setuid-sandbox","--disable-dev-shm-usage","--disable-gpu","--no-zygote","--no-first-run","--disable-background-networking","--disable-extensions","--disable-component-update","--disable-sync","--disable-breakpad","--disable-crash-reporter","--disable-crashpad-for-testing","--disable-features=TranslateUI,ChromeCrashpadPipeSupport","--crash-dumps-dir=/tmp/crashpad","--hide-scrollbars","--mute-audio"]'
