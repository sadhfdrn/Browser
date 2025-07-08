#!/bin/bash

# Start virtual X display
Xvfb :99 -screen 0 1920x1080x24 &

# Start window manager
fluxbox &

# Start VNC server
x11vnc -display :99 -nopw -forever -shared &

# Start Chrome with remote debugging
google-chrome-stable \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222 \
  --user-data-dir=/home/chromeuser/chrome-data \
  --display=:99 \
  about:blank
