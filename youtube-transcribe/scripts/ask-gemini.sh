#!/usr/bin/env bash
# Wrapper: load the Gemini key, activate the venv, run ask-gemini.py.
# Usage: ask-gemini.sh <youtube_url | local_video_file> "<question>" [--model ...]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$DIR/load-keys.sh"
if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "GEMINI_API_KEY is not set — the Gemini visual fallback is unavailable." >&2
  echo "Export GEMINI_API_KEY (https://aistudio.google.com/apikey) to enable it." >&2
  exit 1
fi
# shellcheck disable=SC1091
. "$ROOT/.venv/bin/activate"
python "$DIR/ask-gemini.py" "$@"
