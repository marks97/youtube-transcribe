#!/usr/bin/env bash
# Resolve ELEVENLABS_API_KEY (required) and GEMINI_API_KEY (optional, for the
# visual-understanding fallback) into the environment. SOURCE this, do not run it.
#
# Public behaviour: read the keys from the environment.
# Private override: if scripts/load-keys.local.sh exists (gitignored), it is
# sourced first and may populate the vars from anywhere (e.g. a secrets manager).
_LK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$_LK_DIR/load-keys.local.sh" ] && . "$_LK_DIR/load-keys.local.sh"

if [ -z "${ELEVENLABS_API_KEY:-}" ]; then
  echo "ELEVENLABS_API_KEY is not set. Export it (get one at https://elevenlabs.io)," >&2
  echo "or create scripts/load-keys.local.sh to resolve it privately." >&2
  return 1 2>/dev/null || exit 1
fi
