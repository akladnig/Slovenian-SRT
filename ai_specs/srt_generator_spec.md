<goal>
Create a Dart CLI tool that generates SubRip (.srt) subtitle files from MP3, M4A, or MOV audio and markdown transcript input. The tool takes a base filename, reads the corresponding audio and .md files, and outputs a .srt file with properly timed subtitles.
</goal>

<background>
Dart CLI tool for generating subtitle files. Uses the dart-create skill to scaffold the project in the `./srt_generator` subfolder.

**Input files:**
- `filename.mp3` or `filename.m4a` - Audio file to extract duration
- `filename.mov` - Video file (if no MP3/M4A exists, audio is extracted to filename.m4a)
- `filename.md` - Markdown transcript with timestamps in format `MM:SS - text`

**Output files:**
- `filename.srt` - SubRip subtitle file
- `filename.m4a` - Extracted audio (created only when MOV file is used as source)

**Reference files examined:**
- @../examples/example.md - Input markdown format
- @../srt_generator/test/example_for_testing.srt - Expected SRT output format
</background>

<user_flows>
Primary flow:
1. User runs CLI with base filename: `dart run srt_generator myfile`
2. Tool checks for audio files:
   - If `myfile.mp3` or `myfile.m4a` exists:
     - Check if `myfile.mov` is newer than the existing audio file
     - If MOV is newer, extract audio from MOV to `myfile.m4a`
       - If existing audio is MP3, delete the MP3 file first
     - Use the resulting MP3/M4A for duration extraction
   - If only `myfile.mov` exists:
     - Extract audio to `myfile.m4a` using ffmpeg
   - If no audio files exist, display error "Audio file not found"
3. Tool reads `myfile.md` and parses timestamps and text
4. Tool processes lines: joins incomplete sentences, splits by punctuation
5. Tool calculates timestamps for each sentence
6. Tool outputs `myfile.srt` in SubRip format

Error flows:
- Missing audio file (.mp3, .m4a, or .mov): Display error "Audio file not found: {path}.mp3, {path}.m4a, or {path}.mov"
- Missing .md file: Display error "Transcript file not found: {path}.md"
- Invalid timestamp format: Skip malformed line, continue processing with warning
- Audio duration read failure: Display error and exit with code 1
- Audio extraction from MOV failure: Display error and exit with code 1
</user_flows>

<requirements>
**Functional:**
1. CLI accepts a single argument: base filename (path with no extension)
2. Audio file detection with timestamp comparison:
   - If MP3 or M4A exists AND MOV exists:
     - Compare file modification timestamps
     - If MOV is newer, extract audio from MOV to `filename.m4a`
     - If existing audio was MP3, delete the MP3 file
   - If only MP3 or M4A exists:
     - Use existing audio file
   - If only MOV exists:
     - Extract audio to `filename.m4a` using ffmpeg
   - If no audio files exist, exit with error
3. Reads MP3, M4A, or MOV file and extracts duration in milliseconds
4. Reads markdown file line by line, parsing timestamps in `MM:SS` format
5. Joins current line with next line when current line does NOT end with `.!?` AND does NOT contain HTML header tags. Header tags are stripped from output, keeping only inner content.
6. Splits joined text into individual sentences by `.!?` punctuation, but preserves multiple consecutive dots (e.g., "e.g.", "Mr.", "...") and only splits on the last dot in a sequence
7. Strips leading dashes (`-`) from text after splitting by punctuation
8. Calculates timestamp for each sentence proportionally by character count within its line's time range - sentence duration is proportional to the number of characters (e.g., 30 chars and 10 chars in a 4-second span = 3 seconds and 1 second)
9. Converts all timestamps to SubRip format: `HH:MM:SS,mmm --> HH:MM:SS,mmm`
10. Strips HTML header tags (<h1>-<h6>) from text, preserving inner content (e.g., "<h1>Title</h1>" → "Title")
11. Outputs properly formatted SRT file with sequential numbering

**Error Handling:**
12. Missing input files: Exit with descriptive error message
13. Malformed timestamps: Skip line, log warning, continue processing
14. Audio read failure: Exit with error code 1

**Edge Cases:**
15. Single line transcript: Process normally
16. Line with no timestamp: Skip with warning
17. Empty lines: Ignore
18. Timestamp exceeds audio duration: Cap at audio duration
19. Last line without subsequent timestamp: Use audio duration as end time
</requirements>

<boundaries>
Edge cases:
- Empty input file: Output empty SRT (only basic structure, no subtitle entries)
- Very long audio (>1 hour): Ensure timestamp format handles hours correctly (HH:MM:SS,mmm)
- Non-UTF8 characters in transcript: Preserve original encoding in output

Error scenarios:
- File not found: Display clear error with filename, exit code 1
- Permission denied: Display "Cannot read file: {path}", exit code 1
- Invalid audio format: Display "Unable to read audio duration", exit code 1
</boundaries>

<implementation>
**Files created:**
- `./srt_generator/` - Dart project scaffolded via dart-create skill
- `./srt_generator/bin/srt_generator.dart` - Entry point with argument parsing
- `./srt_generator/lib/srt_generator.dart` - Core SRT generation logic
- `./srt_generator/lib/audio_reader.dart` - Audio duration extraction (MP3/M4A)
- `./srt_generator/lib/video_audio_extractor.dart` - Extract audio from MOV to M4A using ffmpeg
- `./srt_generator/lib/markdown_parser.dart` - Markdown transcript parsing
- `./srt_generator/lib/timestamp_calculator.dart` - Timestamp calculation logic
- `./srt_generator/lib/srt_formatter.dart` - SRT file formatting

**Patterns/Libraries:**
- Use `ffprobe` (from ffmpeg) for MP3/M4A duration extraction via `Process.runSync`
  - Required because `mp3_info` package does not support VBR (Variable Bit Rate) MP3s
- Use `ffmpeg` for audio extraction from MOV files: `ffmpeg -i input.mov -vn -acodec copy output.m4a`
- Note: `mp3_info` package is listed in pubspec.yaml but NOT used
- Use Dart's `File` class for file I/O
- Use `RegExp` for timestamp parsing
- Follow dart-create conventions for CLI structure

**What to avoid:**
- Using Flutter-specific packages (this is a pure Dart CLI)
- Hardcoding paths - use relative to input base filename
</implementation>

<validation>
Unit tests for:
- Timestamp parsing: `00:06` → 6000ms
- Timestamp conversion: 6000ms → `00:06,000`
- Sentence splitting: `"Hello. World!"` → `["Hello.", "World!"]`
- Multiple dots preserved: `"Hello... World."` → `["Hello...", "World."]`
- Dash stripping: `"Hello. -World."` → `["Hello.", "World."]`
- Line joining: `"Hello"` + `"World"` → `"Hello World"` (no ending punctuation)
- Header tag stripping: `<h1>Title</h1>` + `Next line` → `["Title"]`, `["Next line"]` (not joined, tags stripped)
- Header tags stripped from text: `"<h1>Hello</h1>"` → `"Hello"`
- Line NOT joining: `"Hello."` + `"World"` → `["Hello."]`, next starts fresh
- Line with header tag not joined: `"<h1>Title"</h1>` + `"Next line"` → two separate entries (header detected)
- Character-count timing: 30 chars + 10 chars in 4-second span → 3 seconds + 1 second
- Character-count timing edge case: 0 total chars → skip (avoid division by zero)

Integration test:
- Run `dart run srt_generator ../examples/example` from `srt_generator/` directory
- Generated `../examples/example.srt` must match `test/example_for_testing.srt` byte-for-byte
- Audio duration of `../examples/example.mp3` is exactly 52352ms

MOV extraction test:
- Case 1: Given `myfile.mov` exists but no `myfile.mp3` or `myfile.m4a`
  - When tool runs with `myfile` argument
  - Then audio is extracted to `myfile.m4a` and SRT is generated successfully
- Case 2: Given `myfile.mov` is newer than `myfile.mp3`
  - When tool runs with `myfile` argument
  - Then `myfile.mp3` is deleted, audio is extracted to `myfile.m4a`, and SRT is generated
- Case 3: Given `myfile.mov` is newer than `myfile.m4a`
  - When tool runs with `myfile` argument
  - Then audio is extracted to `myfile.m4a` (overwrite) and SRT is generated
</validation>

<done_when>
1. CLI successfully generates .srt file from MP3/M4A/MOV and .md inputs
2. Output SRT matches SubRip specification format
3. Timestamps correctly converted from MM:SS to HH:MM:SS,mmm
4. Sentences properly split by .!? punctuation
5. Leading dashes stripped from split sentence segments
6. Incomplete sentences (no ending punctuation) joined with next line
7. Unit tests pass for core parsing and calculation logic
8. Error handling works for missing files and invalid input
9. MOV file audio extraction works when no MP3/M4A exists or when MOV is newer
10. MP3 files are deleted and replaced with M4A when MOV is newer
</done_when>
