FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  gnupg \
  ca-certificates \
  fonts-liberation \
  libappindicator3-1 \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libcups2 \
  libdbus-1-3 \
  libgdk-pixbuf2.0-0 \
  libnspr4 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  xdg-utils \
  unzip \
  --no-install-recommends && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Chrome (Stable)
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  apt install -y ./google-chrome-stable_current_amd64.deb && \
  rm google-chrome-stable_current_amd64.deb

# Setup user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome && \
    mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

# Set workdir
WORKDIR /app
COPY . .

# Install Node (for puppeteer or your app)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Optional: install puppeteer or your app deps
COPY package*.json ./
RUN npm install

# Expose the port
EXPOSE 3000

# Set env to disable sandbox
ENV CHROME_BIN="/usr/bin/google-chrome"
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome"

# Default CMD (replace with your app script if needed)
CMD ["google-chrome", "--headless", "--disable-gpu", "--no-sandbox", "--remote-debugging-port=3000", "--disable-dev-shm-usage"]
