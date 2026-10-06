#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="$HOME/.local/bin"
TARGET="$BIN_DIR/start"
if [[ -e "$TARGET" ]] && ! grep -q '^# Truck Manager terminal launcher$' "$TARGET"; then
  printf 'Cannot install: %s already belongs to another program.\n' "$TARGET" >&2
  exit 1
fi
EXISTING="$(command -v start || true)"
if [[ -n "$EXISTING" && "$EXISTING" != "$TARGET" ]]; then
  printf 'Cannot install: an existing start command is at %s.\n' "$EXISTING" >&2
  exit 1
fi
mkdir -p "$BIN_DIR"
{
 printf '%s\n' '#!/usr/bin/env bash' '# Truck Manager terminal launcher' 'set -Eeuo pipefail'
 printf 'RUN_SCRIPT=%q\n' "$PROJECT_DIR/scripts/run-truck-manager.sh"
 cat <<'WRAPPER'
if [[ "$#" != 2 || "$1" != trucking || "$2" != game ]]; then
  printf 'Usage: start trucking game\n' >&2
  exit 2
fi
exec bash "$RUN_SCRIPT" --built
WRAPPER
} > "$TARGET"
chmod +x "$TARGET"
# Kali uses zsh; Ubuntu commonly uses bash. Both receive the same PATH setup.
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
 if ! grep -q '^# Truck Manager command path$' "$RC" 2>/dev/null; then
  printf '\n%s\n%s\n' '# Truck Manager command path' 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
 fi
done
printf 'Installed. Open a new terminal, then type: start trucking game\n'
printf 'For this terminal, first run: export PATH="$HOME/.local/bin:$PATH"\n'
