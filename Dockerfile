# Base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    wget gnupg curl x11vnc xvfb fluxbox wmctrl \
    fonts-ipafont-gothic fonts-wqy-zenhei \
    libxss1 libappindicator1 libindicator7 libdbus-glib-1-2 \
    libasound2 libatk-bridge2.0-0 libgtk-3-0 libnss3 libx11-xcb1 \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m chromeuser && mkdir -p /home/chromeuser && chown -R chromeuser:chromeuser /home/chromeuser
USER chromeuser
WORKDIR /home/chromeuser

# Add startup script
COPY --chown=chromeuser:chromeuser startup.sh .
RUN chmod +x startup.sh

# Expose ports:
# 5900 - VNC GUI
# 9222 - Chrome DevTools Protocol endpoint
EXPOSE 5900 9222

CMD ["./startup.sh"] 
