#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BUILT_GAME="$PROJECT_DIR/build/linux/x64/release/bundle/truck_manager"

find_flutter() {
  local candidate

  if [[ -n "${FLUTTER_BIN:-}" && -x "$FLUTTER_BIN" ]]; then
    printf '%s\n' "$FLUTTER_BIN"
    return 0
  fi

  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
    return 0
  fi

  # Desktop launchers often do not inherit the Flutter PATH from the shell.
  for candidate in \
    "$HOME/development/flutter/bin/flutter" \
    "$HOME/flutter/bin/flutter" \
    "$HOME/.local/share/flutter/bin/flutter" \
    "$HOME/fvm/default/bin/flutter" \
    "/opt/flutter/bin/flutter" \
    "/usr/local/flutter/bin/flutter" \
    "/snap/bin/flutter"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

cd "$PROJECT_DIR"

if [[ "${1:-}" == "--built" && -x "$BUILT_GAME" ]]; then
  exec "$BUILT_GAME"
fi

if ! FLUTTER="$(find_flutter)"; then
  printf 'Truck Manager could not find Flutter.\n'
  printf 'Expected Kali location: %s\n' "$HOME/development/flutter/bin/flutter"
  printf 'You can also set FLUTTER_BIN to the full Flutter executable path.\n'
  read -r -p 'Press Enter to close...'
  exit 1
fi

export PATH="$(dirname -- "$FLUTTER"):$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/snap/bin:${PATH:-}"
printf 'Starting Truck Manager with Flutter: %s\n' "$FLUTTER"

# The repository may be checked out before Linux platform files are generated.
if [[ ! -d linux ]]; then
  printf 'Preparing Truck Manager for Linux desktop (first launch only)...\n'
  "$FLUTTER" create --platforms=linux .
fi

"$FLUTTER" pub get
exec "$FLUTTER" run -d linux
