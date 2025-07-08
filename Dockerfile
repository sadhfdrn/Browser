FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
  wget gnupg ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 \
  libatk1.0-0 libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 \
  libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 xdg-utils --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Add Google Chrome repo and install latest stable
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
  apt-get update && apt-get install -y google-chrome-stable --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

# Run full Chrome in headless mode with debugging port
CMD ["google-chrome-stable", \
     "--headless=new", \
     "--disable-gpu", \
     "--no-sandbox", \
     "--remote-debugging-address=0.0.0.0", \
     "--remote-debugging-port=9222", \
     "--disable-dev-shm-usage", \
     "about:blank"]

EXPOSE 9222
