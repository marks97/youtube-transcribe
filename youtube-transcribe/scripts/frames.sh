#!/usr/bin/env bash
# Extract still frames from a downloaded video for visual inspection (slides,
# charts, code on screen, product shots). Read the JPGs back with the Read tool.
#
# Usage:
#   frames.sh <video> <outdir> every <seconds>          one frame every N seconds
#   frames.sh <video> <outdir> at 00:01:23,00:04:10      frames at exact timestamps
set -euo pipefail
V="${1:?video file}"
OUT="${2:?outdir}"
MODE="${3:-every}"
ARG="${4:-30}"
mkdir -p "$OUT"

case "$MODE" in
  every)
    ffmpeg -nostdin -loglevel error -i "$V" -vf "fps=1/${ARG}" -q:v 3 "$OUT/frame_%04d.jpg"
    echo "Extracted a frame every ${ARG}s into $OUT"
    ;;
  at)
    IFS=',' read -ra TS <<< "$ARG"
    i=0
    for t in "${TS[@]}"; do
      i=$((i + 1))
      ffmpeg -nostdin -loglevel error -ss "$t" -i "$V" -frames:v 1 -q:v 3 \
        "$OUT/at_$(printf '%02d' "$i")_${t//:/-}.jpg"
    done
    echo "Extracted ${#TS[@]} frame(s) into $OUT"
    ;;
  *)
    echo "mode must be 'every' or 'at'" >&2; exit 1 ;;
esac
ls "$OUT"
