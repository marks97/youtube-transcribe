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
KIND="ytsearch"
for a in "$@"; do
  case "$a" in
    --date) KIND="ytsearchdate" ;;
    --urls) URLS=1 ;;
    ''|*[!0-9]*) : ;;   # ignore non-numeric
    *) N="$a" ;;
  esac
done
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
. "$ROOT/.venv/bin/activate"

if [ "$URLS" -eq 1 ]; then
  yt-dlp "${KIND}${N}:${Q}" --flat-playlist --no-warnings --print "https://www.youtube.com/watch?v=%(id)s"
else
  yt-dlp "${KIND}${N}:${Q}" --flat-playlist --no-warnings \
    --print "%(id)s\t%(duration>%H:%M:%S)s\t%(channel)s\t%(title)s"
fi
