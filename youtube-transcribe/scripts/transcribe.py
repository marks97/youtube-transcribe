#!/usr/bin/env python3
"""Transcribe an audio/video file with ElevenLabs Scribe v2.

Usage: transcribe.py <audio_file> <outdir> [--no-diarize] [--lang xxx] [--keyterms a,b,c]

Writes into <outdir>:
  transcript.txt           full plain text
  transcript.diarized.txt  speaker-grouped, timestamped lines of ~30-60 s (read this to absorb the talk)
  transcript.json          raw ElevenLabs response (words + timings + speakers)
"""
import os
import sys
import json
import argparse
from elevenlabs import ElevenLabs


def _get(w, k, default=None):
    return w.get(k, default) if isinstance(w, dict) else getattr(w, k, default)


# A single-speaker talk would otherwise be one huge line with one timestamp, which makes
# "what was said at 12:40" impossible to find. Start a new line at the first sentence end
# after SOFT_BREAK seconds, and unconditionally after HARD_BREAK seconds.
SOFT_BREAK = 30
HARD_BREAK = 60
SENTENCE_END = (".", "?", "!", "…")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("audio")
    ap.add_argument("outdir")
    ap.add_argument("--no-diarize", action="store_true")
    ap.add_argument("--lang", default=None, help="ISO-639 hint; omit to auto-detect")
    ap.add_argument("--keyterms", default=None, help="comma-separated terms to spell correctly")
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)

    client = ElevenLabs()  # reads ELEVENLABS_API_KEY from env
    kw = dict(model_id="scribe_v2", diarize=not a.no_diarize, timestamps_granularity="word")
    if a.lang:
        kw["language_code"] = a.lang
    if a.keyterms:
        kw["keyterms"] = [k.strip() for k in a.keyterms.split(",") if k.strip()]

    with open(a.audio, "rb") as f:
        res = client.speech_to_text.convert(file=f, **kw)

    data = res.model_dump() if hasattr(res, "model_dump") else dict(res.__dict__)
    with open(os.path.join(a.outdir, "transcript.json"), "w") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, default=str)

    text = (_get(res, "text", "") or data.get("text", "") or "").strip()
    with open(os.path.join(a.outdir, "transcript.txt"), "w") as f:
        f.write(text + "\n")

    # Group consecutive words by speaker into readable, timestamped lines.
    words = _get(res, "words", None) or data.get("words") or []
    lines, buf, cur_spk, seg_start = [], [], None, None

    def flush():
        if buf and seg_start is not None:
            ts = f"[{int(seg_start // 60):02d}:{int(seg_start % 60):02d}]"
            spk = f" {cur_spk}" if cur_spk else ""
            lines.append(f"{ts}{spk}: {''.join(buf).strip()}")

    for w in words:
        spk = _get(w, "speaker_id")
        st = _get(w, "start")
        txt = _get(w, "text", "")
        if cur_spk is None:
            cur_spk, seg_start = spk, st
        if spk != cur_spk:
            flush()
            buf, cur_spk, seg_start = [], spk, st
        if seg_start is None and st is not None:
            seg_start = st
        buf.append(txt)
        elapsed = (st - seg_start) if (st is not None and seg_start is not None) else 0
        if elapsed >= HARD_BREAK or (elapsed >= SOFT_BREAK and txt.rstrip().endswith(SENTENCE_END)):
            flush()
            buf, seg_start = [], None
    flush()

    with open(os.path.join(a.outdir, "transcript.diarized.txt"), "w") as f:
        f.write("\n".join(lines) + "\n")

    lang = data.get("language_code")
    prob = data.get("language_probability")
    n_spk = len({_get(w, "speaker_id") for w in words if _get(w, "speaker_id")})
    print(f"Transcribed: {len(text)} chars, {len(words)} words, lang={lang} "
          f"({prob}), speakers={n_spk or 'n/a'}")
    print(f"  {os.path.join(a.outdir, 'transcript.txt')}")
    print(f"  {os.path.join(a.outdir, 'transcript.diarized.txt')}")


if __name__ == "__main__":
    main()
