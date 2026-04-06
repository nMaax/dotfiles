# utils.sh

# --- Color Definitions ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Helper Logging Functions ---
info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1"; }

# --- Persistent Note Handling ---
# We use a temp file to share notes across different script processes
NOTES_FILE="/tmp/dotfiles_install_notes.txt"

add_note() {
  echo -e "$1\n" >>"$NOTES_FILE"
}

show_notes() {
  if [[ -f "$NOTES_FILE" ]]; then
    info "Post-Install Summary:"
    cat "$NOTES_FILE"
    rm -f "$NOTES_FILE"
  fi
}

clean_notes() {
  if [[ -f "$NOTES_FILE" ]]; then
    info "Cleaning up notes:"
    : >"$NOTES_FILE"
  fi
}
