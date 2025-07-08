# Option 1: femtopixel/google-chrome-headless (RECOMMENDED)
# This uses actual Google Chrome, not Chromium
FROM femtopixel/google-chrome-headless:latest

# Expose the remote debugging port
EXPOSE 9222

# Override the default entrypoint to ensure proper binding
ENTRYPOINT ["google-chrome"]
CMD ["--headless", "--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage", "--disable-setuid-sandbox", "--remote-debugging-port=9222", "--remote-debugging-address=0.0.0.0", "--window-size=1920,1080", "--user-data-dir=/tmp/chrome-user-data", "--about:blank"]

 
