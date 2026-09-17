#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUN_SCRIPT="$PROJECT_DIR/scripts/run-truck-manager.sh"
ICON_FILE="$PROJECT_DIR/assets/truck-manager.svg"
APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
APPLICATION_FILE="$APPLICATIONS_DIR/truck-manager.desktop"
DESKTOP_FILE="$DESKTOP_DIR/Truck Manager.desktop"

if [[ ! -f "$RUN_SCRIPT" || ! -f "$ICON_FILE" ]]; then
  printf 'Required Truck Manager launcher files are missing.\n' >&2
  exit 1
fi

mkdir -p "$APPLICATIONS_DIR" "$DESKTOP_DIR"
chmod +x "$RUN_SCRIPT"

write_launcher() {
  local target="$1"
  printf '%s\n' \
    '[Desktop Entry]' \
    'Version=1.0' \
    'Type=Application' \
    'Name=Truck Manager' \
    'Comment=Run your nationwide trucking company' \
    "Exec=$RUN_SCRIPT" \
    "Icon=$ICON_FILE" \
    "Path=$PROJECT_DIR" \
    'Terminal=true' \
    'Categories=Game;Simulation;' \
    'StartupNotify=true' > "$target"
  chmod +x "$target"
}

write_launcher "$APPLICATION_FILE"
write_launcher "$DESKTOP_FILE"

# Mark the desktop copy trusted when the desktop environment supports it.
if command -v gio >/dev/null 2>&1; then
  gio set "$DESKTOP_FILE" metadata::trusted true >/dev/null 2>&1 || true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
fi

printf 'Truck Manager launcher installed.\n'
printf 'Desktop icon: %s\n' "$DESKTOP_FILE"
printf 'You can also open Truck Manager from the applications menu.\n'
