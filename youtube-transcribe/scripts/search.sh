#!/usr/bin/env bash
# Find YouTube videos for a topic — FREE, no API key (uses yt-dlp's own search).
# Usage:
#   search.sh "<query>" [count] [--date] [--urls]
#     count   how many results (default 15)
#     --date  sort by upload date (newest) instead of relevance
#     --urls  print bare watch URLs (one per line) for piping into a batch
# Default output: "<id>\t<duration>\t<channel>\t<title>" — one video per line.
set -euo pipefail
Q="${1:?usage: search.sh \"<query>\" [count] [--date] [--urls]}"
shift || true
N=15
URLS=0
DATE=0
for a in "$@"; do
  case "$a" in
    --date) DATE=1 ;;
    --urls) URLS=1 ;;
    ''|*[!0-9]*) : ;;   # ignore non-numeric
    *) N="$a" ;;
  esac
done
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
. "$ROOT/.venv/bin/activate"

if [ "$DATE" -eq 1 ]; then
  # yt-dlp dropped the "ytsearchdate" scheme; the results page sorted by upload date
  # (sp=CAISAhAB: sort=upload date, type=video) gives the same list.
  ENC="$(python -c 'import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))' "$Q")"
  SRC=("https://www.youtube.com/results?search_query=${ENC}&sp=CAISAhAB" --playlist-end "$N")
else
  SRC=("ytsearch${N}:${Q}")
fi

if [ "$URLS" -eq 1 ]; then
  yt-dlp "${SRC[@]}" --flat-playlist --no-warnings --print "https://www.youtube.com/watch?v=%(id)s"
else
  TAB=$'\t'
  yt-dlp "${SRC[@]}" --flat-playlist --no-warnings \
    --print "%(id)s${TAB}%(duration>%H:%M:%S)s${TAB}%(channel)s${TAB}%(title)s"
fi
