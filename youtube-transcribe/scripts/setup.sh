#!/usr/bin/env bash
# Create the skill's self-contained venv and install dependencies.
# Idempotent: safe to run every time; it only installs what is missing.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$ROOT/.venv"

if [ ! -x "$VENV/bin/python" ]; then
  # Some Debian/Ubuntu boxes ship python3 without ensurepip; install python3-venv if so.
  python3 -m venv "$VENV" 2>/dev/null || {
    echo "venv creation failed. On Debian/Ubuntu run: sudo apt-get install -y python3-venv" >&2
    exit 1
  }
fi
# shellcheck disable=SC1091
. "$VENV/bin/activate"
pip install -q --upgrade pip >/dev/null 2>&1 || true
# yt-dlp: download. elevenlabs: Scribe v2 transcription. google-genai: Gemini video understanding.
pip install -q yt-dlp elevenlabs google-genai
echo "youtube-transcribe ready: yt-dlp $(yt-dlp --version), $( python -c 'import elevenlabs,google.genai;print("elevenlabs+google-genai ok")' )"
