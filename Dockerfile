docker pull chromedp/headless-shell:latest

docker run -d -p 9222:9222 \
  --shm-size=2G \
  --name chromium \
  chromedp/headless-shell:latest \
  --no-sandbox \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222
