# Youtube Transcribe

> A [Claude Code](https://code.claude.com/docs/en/skills) skill.

Absorb the knowledge in YouTube videos — find them, transcribe them with ElevenLabs Scribe v2, inspect their visuals, and digest what they actually teach. Use this whenever someone wants a video's content as text or knowledge rather than just a link: "transcribe this YouTube video", "what does this video say", "summarize/explain this talk", "pull the transcript", "get subtitles", "turn this lecture into notes", or research-style asks like "find 10-20 videos about <topic> and tell me everything", "research <topic> on YouTube", "what are people saying about <X>". Also use it when a question needs what is shown on screen (slides, charts, code, UI, product) and not only what is said — it extracts frames and, as a last resort, asks Google Gemini to describe the video. Works on any yt-dlp-supported URL. Trigger it even when the words "transcribe" or "skill" never appear but the goal is to learn from video.

## Install

Via [skills.sh](https://skills.sh):

```bash
npx skills add marks97/youtube-transcribe
```

Or manually — copy the `youtube-transcribe/` folder into your `.claude/skills/` directory.

## Usage

Once installed, Claude invokes this skill automatically when your request matches
what it does (see the triggers in [`youtube-transcribe/SKILL.md`](youtube-transcribe/SKILL.md)). You can
also ask for it by name.

See [`youtube-transcribe/SKILL.md`](youtube-transcribe/SKILL.md) for the full workflow, scripts, and options.

## License

MIT © Marc Amoros

