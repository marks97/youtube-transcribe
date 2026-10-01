#!/usr/bin/env python3
"""Ask Google Gemini about a video — visual understanding, last-resort fallback
for things the transcript cannot answer (what is drawn/shown, on-screen text,
charts, UI, who appears, scene description).

Usage:
  ask-gemini.py <youtube_url | local_video_file> "<question>" [--model gemini-2.5-flash]

For a URL, Gemini ingests it directly (no download). For a local file, it is
uploaded via the Files API first. Prints Gemini's answer to stdout.
"""
import os
import sys
import time
import argparse
from google import genai
from google.genai import types


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source", help="YouTube URL or local video path")
    ap.add_argument("question")
    # Rolling alias: always the current Gemini Flash, so this never goes stale as
    # pinned versions get retired. Override with --model for pro/other.
    ap.add_argument("--model", default="gemini-flash-latest")
    a = ap.parse_args()

    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        sys.exit("GEMINI_API_KEY is not set.")
    client = genai.Client(api_key=key)

    if a.source.startswith(("http://", "https://")):
        part = types.Part(file_data=types.FileData(file_uri=a.source))
    else:
        up = client.files.upload(file=a.source)
        while getattr(up, "state", None) and up.state.name == "PROCESSING":
            time.sleep(3)
            up = client.files.get(name=up.name)
        if getattr(up, "state", None) and up.state.name == "FAILED":
            sys.exit("Gemini failed to process the uploaded file.")
        part = types.Part(file_data=types.FileData(file_uri=up.uri, mime_type=up.mime_type))

    resp = client.models.generate_content(
        model=a.model,
        contents=types.Content(parts=[part, types.Part(text=a.question)]),
    )
    print(resp.text)


if __name__ == "__main__":
    main()
