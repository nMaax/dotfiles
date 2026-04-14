#!/bin/bash
# Usage: launch-webapp "https://example.com"

if [ -z "$1" ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

URL="$1"

# Check for available Chromium-based browsers in order of preference
if command -v chromium &>/dev/null; then
  BROWSER="chromium"
elif command -v google-chrome-stable &>/dev/null; then
  BROWSER="google-chrome-stable"
elif command -v brave &>/dev/null; then
  BROWSER="brave"
elif command -v microsoft-edge-stable &>/dev/null; then
  BROWSER="microsoft-edge-stable"
elif command -v vivaldi-stable &>/dev/null; then
  BROWSER="vivaldi-stable"
else
  echo "Error: No Chromium-based browser found. Please install Chromium, Chrome, or Brave."
  exit 1
fi

# Launch the browser in standalone app mode
exec "$BROWSER" --app="$URL"
