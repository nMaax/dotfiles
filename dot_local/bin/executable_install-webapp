#!/bin/bash
# Usage: install-webapp "App Name" "https://example.com" "[Icon URL or System Name]"

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 \"<App Name>\" \"<URL>\" [\"<Icon URL or local name>\"]"
  echo "  Tip: You can find great high-res icons at https://dashboardicons.com"
  exit 1
fi

APP_NAME="$1"
APP_URL="$2"
ICON_ARG="$3"

# Safe filename generation (replace spaces with hyphens)
SAFE_NAME="${APP_NAME// /-}"

ICON_DIR="$HOME/.local/share/icons/webapps"
DESKTOP_DIR="$HOME/.local/share/applications"
DOWNLOADED_ICON="$ICON_DIR/${SAFE_NAME}.png"
DESKTOP_FILE="$DESKTOP_DIR/${SAFE_NAME}.desktop"

# Ensure directories exist
mkdir -p "$ICON_DIR" "$DESKTOP_DIR"

# Prepend https:// if the user forgot it
if [[ ! "$APP_URL" =~ ^https?:// ]]; then
  APP_URL="https://$APP_URL"
fi

# --- ICON HANDLING LOGIC ---
if [ -n "$ICON_ARG" ]; then
  if [[ "$ICON_ARG" =~ ^https?:// ]]; then
    echo "Fetching custom icon from URL..."
    if curl -fsSL -o "$DOWNLOADED_ICON" "$ICON_ARG" && [[ -s "$DOWNLOADED_ICON" ]]; then
      echo "Custom icon downloaded successfully."
      ICON_PATH="$DOWNLOADED_ICON"
    else
      echo "Warning: Could not download custom icon. Falling back to default system icon."
      ICON_PATH="web-browser"
    fi
  else
    echo "Using provided local icon path or name: $ICON_ARG"
    ICON_PATH="$ICON_ARG"
  fi
else
  echo "No icon provided. Fetching default website favicon..."
  echo "(Tip: For a much sharper icon, pass an image URL as the 3rd argument. Great source: https://dashboardicons.com)"

  FAVICON_URL="https://www.google.com/s2/favicons?domain=${APP_URL}&sz=128"
  if curl -fsSL -o "$DOWNLOADED_ICON" "$FAVICON_URL" && [[ -s "$DOWNLOADED_ICON" ]]; then
    echo "Favicon downloaded successfully."
    ICON_PATH="$DOWNLOADED_ICON"
  else
    echo "Warning: Could not fetch favicon. Using fallback."
    ICON_PATH="web-browser"
  fi
fi

# --- DESKTOP FILE GENERATION ---
echo "Creating desktop entry..."
cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME Web App
Exec=$HOME/.local/bin/launch-webapp.sh "$APP_URL"
Terminal=false
Type=Application
Icon=$ICON_PATH
Categories=Network;WebBrowser;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

# Tell the desktop environment to update its database
update-desktop-database "$DESKTOP_DIR" &>/dev/null

echo -e "\nSuccess! '$APP_NAME' has been installed."
