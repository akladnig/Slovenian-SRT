---
title: SRT Generator CLI - Dart
date: 2026-03-29
work_type: feature
tags: [dart, cli, subtitle, srt, mp3]
confidence: high
references: [srt_generator/lib/srt_generator.dart, srt_generator/lib/audio_reader.dart, srt_generator/test/srt_generator_test.dart]
---

## Summary

Built a Dart CLI tool that generates SubRip (.srt) subtitle files from MP3 audio and markdown transcript input. The tool parses timestamps in `MM:SS - text` format, joins incomplete sentences, splits by punctuation (.!?), and calculates character-proportional timestamps.

## Reusable Insights

### Timing Algorithm
- For lines with multiple sentences, use **next unparsed line's timestamp** as end time, not the immediately next line (which may have been joined)
- Track `joinedUntilIdx` separately from loop index to find correct boundary
- Clamp negative durations when markdown timestamps exceed actual audio length

### Audio Duration
- `mp3_info` Dart package returns incorrect duration for some MP3 files
- Use `ffprobe` (from FFmpeg) for accurate duration: `ffprobe -v error -show_entries format=duration -of csv=p=0 <file>`

### Key Code Patterns
```dart
// Loop with line joining
int i = 0;
while (i < parsedLines.length) {
  int joinedUntilIdx = i;
  int nextIdx = i + 1;
  while (nextIdx < parsedLines.length && 
         !_endsWithSentenceTerminator(parsedLines[joinedUntilIdx].text)) {
    nextIdx++;
  }
  // Use nextIdx for end timestamp, not i+1
  i = nextIdx;
}
```

## Pitfalls

- **Index confusion after joining**: When lines are joined, the next timestamp should come from the first line that was NOT joined, not the loop's next index
- **Negative durations**: When markdown timestamps exceed audio duration, use `clamp(0, ...)` to prevent invalid timestamps
- **Library bugs**: Always verify duration with external tool (ffprobe) when precision matters

## Validation

- Unit tests for timestamp parsing, formatting, sentence splitting, dash stripping
- Integration test comparing generated output against expected `example_for_testing.srt`
- Run: `dart analyze && dart test`

## Follow-ups

- Consider supporting VBR MP3s if current approach has issues
- Add error handling for missing ffprobe
