#!/usr/bin/env bash
# Download + transcribe many videos. One folder per video id, plus a manifest.
# Usage: batch.sh <outdir> <urls-file>     (urls-file: one URL or video id per line; blank lines / # comments ignored)
#        ... or pipe URLs on stdin:  search.sh "q" 20 --urls | batch.sh <outdir> -
set -euo pipefail
OUT="${1:?usage: batch.sh <outdir> <urls-file|->}"
SRC="${2:?urls file (or - for stdin)}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$OUT"
MANIFEST="$OUT/manifest.tsv"
: > "$MANIFEST"

read_urls() { if [ "$SRC" = "-" ]; then cat; else cat "$SRC"; fi; }

i=0
while IFS= read -r url; do
  url="${url%%#*}"; url="$(echo "$url" | xargs)"
  [ -z "$url" ] && continue
  i=$((i + 1))
  id="$(echo "$url" | sed -E 's#.*[?&]v=##; s#&.*##; s#.*/##')"
  vdir="$OUT/$id"
  echo "=== [$i] $id ==="
  if [ -f "$vdir/transcript.txt" ]; then
    echo "  already transcribed, skipping"
  else
    bash "$DIR/download.sh" "$url" "$vdir" audio >/dev/null 2>&1 || { echo "  download failed"; echo -e "$id\tDOWNLOAD_FAILED\t$url" >> "$MANIFEST"; continue; }
    bash "$DIR/transcribe.sh" "$vdir/audio.mp3" "$vdir" >/dev/null 2>&1 || { echo "  transcribe failed"; echo -e "$id\tTRANSCRIBE_FAILED\t$url" >> "$MANIFEST"; continue; }
    # audio can be large; drop it once transcribed
    rm -f "$vdir/audio.mp3"
  fi
  title="$(python3 -c "import json,sys;print(json.load(open('$vdir/metadata.json')).get('title',''))" 2>/dev/null || true)"
  words="$(wc -w < "$vdir/transcript.txt" 2>/dev/null | xargs || echo 0)"
  echo -e "$id\t${words}w\t${title}" >> "$MANIFEST"
done < <(read_urls)

echo
echo "Done: $i video(s). Manifest: $MANIFEST"
cat "$MANIFEST"
