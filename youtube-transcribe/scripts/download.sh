#!/usr/bin/env bash
# Download a video's AUDIO (for transcription) and/or VIDEO (for frames / Gemini).
# Usage: download.sh <url> <outdir> [audio|video|both]   (default: audio)
set -euo pipefail
URL="${1:?usage: download.sh <url> <outdir> [audio|video|both]}"
OUT="${2:?outdir required}"
WHAT="${3:-audio}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
. "$ROOT/.venv/bin/activate"
mkdir -p "$OUT"

# Metadata (title/channel/duration/chapters) — cheap and always useful.
yt-dlp --no-warnings --skip-download --dump-json "$URL" > "$OUT/metadata.json" 2>/dev/null || true

case "$WHAT" in
  audio|both)
    # bestaudio -> mp3 keeps the upload to ElevenLabs small.
    yt-dlp --no-warnings -f bestaudio -x --audio-format mp3 --audio-quality 0 \
      -o "$OUT/audio.%(ext)s" "$URL"
    ;;
esac
case "$WHAT" in
  video|both)
    # Cap at 720p: plenty for reading slides/on-screen text, far smaller to handle.
    yt-dlp --no-warnings -f "bv*[height<=720]+ba/b[height<=720]/b" --merge-output-format mp4 \
      -o "$OUT/video.%(ext)s" "$URL"
    ;;
esac
echo "Downloaded ($WHAT) to $OUT"
ls -la "$OUT"
