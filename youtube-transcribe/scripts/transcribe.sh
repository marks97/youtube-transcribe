#!/usr/bin/env bash
# Wrapper: load the ElevenLabs key, activate the venv, run transcribe.py.
# Usage: transcribe.sh <audio_file> <outdir> [--no-diarize] [--lang xxx] [--keyterms a,b,c]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$DIR/load-keys.sh"
# shellcheck disable=SC1091
. "$ROOT/.venv/bin/activate"
python "$DIR/transcribe.py" "$@"
