#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BUILT_GAME="$PROJECT_DIR/build/linux/x64/release/bundle/truck_manager"

cd "$PROJECT_DIR"

if [[ -x "$BUILT_GAME" ]]; then
  exec "$BUILT_GAME"
fi

if ! command -v flutter >/dev/null 2>&1; then
  printf 'Truck Manager needs Flutter, but flutter was not found in PATH.\n'
  printf 'Install Flutter, then run this launcher again.\n'
  read -r -p 'Press Enter to close...'
  exit 1
fi

# The repository may be checked out before Linux platform files are generated.
if [[ ! -d linux ]]; then
  printf 'Preparing Truck Manager for Linux desktop (first launch only)...\n'
  flutter create --platforms=linux .
fi

flutter pub get
exec flutter run -d linux
