<goal>
Create a Dart CLI tool that generates SubRip (.srt) subtitle files from MP3 audio and markdown transcript input. The tool takes a base filename, reads the corresponding .mp3 and .md files, and outputs a .srt file with properly timed subtitles.
</goal>

<background>
Dart CLI tool for generating subtitle files. Uses the dart-create skill to scaffold the project in the `./srt_generator` subfolder.

**Input files:**
- `filename.mp3` - Audio file to extract duration
- `filename.md` - Markdown transcript with timestamps in format `MM:SS - text`

**Output files:**
- `filename.srt` - SubRip subtitle file

**Reference files examined:**
- @../examples/example.md - Input markdown format
- @../examples/example.srt - Expected SRT output format
</background>

<user_flows>
Primary flow:
1. User runs CLI with base filename: `dart run srt_generator myfile`
2. Tool reads `myfile.mp3` and extracts audio duration
3. Tool reads `myfile.md` and parses timestamps and text
4. Tool processes lines: joins incomplete sentences, splits by punctuation
5. Tool calculates timestamps for each sentence
6. Tool outputs `myfile.srt` in SubRip format

Error flows:
- Missing .mp3 file: Display error "Audio file not found: {path}.mp3"
- Missing .md file: Display error "Transcript file not found: {path}.md"
- Invalid timestamp format: Skip malformed line, continue processing with warning
- Audio duration read failure: Display error and exit with code 1
</user_flows>

<requirements>
**Functional:**
1. CLI accepts a single argument: base filename (path with no extension)
2. Reads MP3 file and extracts duration in milliseconds
3. Reads markdown file line by line, parsing timestamps in `MM:SS` format
4. Joins current line with next line when current line does NOT end with `.!?`
5. Splits joined text into individual sentences by `.!?` punctuation, but preserves multiple consecutive dots (e.g., "e.g.", "Mr.", "...") and only splits on the last dot in a sequence
6. Strips leading dashes (`-`) from text after splitting by punctuation
7. Calculates timestamp for each sentence within its line's time range - each sentence in a multi-sentence line shares the line's duration equally (e.g., 2 sentences in a 4-second span = 2 seconds each)
8. Converts all timestamps to SubRip format: `HH:MM:SS,mmm --> HH:MM:SS,mmm`
9. Outputs properly formatted SRT file with sequential numbering

**Error Handling:**
10. Missing input files: Exit with descriptive error message
11. Malformed timestamps: Skip line, log warning, continue processing
12. Audio read failure: Exit with error code 1

**Edge Cases:**
13. Single line transcript: Process normally
14. Line with no timestamp: Skip with warning
15. Empty lines: Ignore
16. Timestamp exceeds audio duration: Cap at audio duration
17. Last line without subsequent timestamp: Use audio duration as end time
</requirements>

<boundaries>
Edge cases:
- Empty input file: Output empty SRT (only basic structure, no subtitle entries)
- Very long audio (>1 hour): Ensure timestamp format handles hours correctly (HH:MM:SS,mmm)
- Non-UTF8 characters in transcript: Preserve original encoding in output

Error scenarios:
- File not found: Display clear error with filename, exit code 1
- Permission denied: Display "Cannot read file: {path}", exit code 1
- Invalid MP3 format: Display "Unable to read audio duration", exit code 1
</boundaries>

<implementation>
**Files to create:**
- `./srt_generator/` - Dart project scaffolded via dart-create skill
- `./srt_generator/bin/srt_generator.dart` - Entry point with argument parsing
- `./cli/lib/srt_generator.dart` - Core SRT generation logic
- `./cli/lib/audio_reader.dart` - MP3 duration extraction
- `./cli/lib/markdown_parser.dart` - Markdown transcript parsing
- `./cli/lib/timestamp_calculator.dart` - Timestamp calculation logic
- `./cli/lib/srt_formatter.dart` - SRT file formatting

**Patterns/Libraries:**
- Use `mp3_info` or `audio_metadata_extractor` package for MP3 duration
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
- Line NOT joining: `"Hello."` + `"World"` → `["Hello."]`, next starts fresh

Integration test:
- Run tool on `../examples/` files and verify output matches expected format
- Compare generated SRT with `../examples/example.srt` for correctness
</validation>

<done_when>
1. CLI successfully generates .srt file from .mp3 and .md inputs
2. Output SRT matches SubRip specification format
3. Timestamps correctly converted from MM:SS to HH:MM:SS,mmm
4. Sentences properly split by .!? punctuation
5. Leading dashes stripped from split sentence segments
6. Incomplete sentences (no ending punctuation) joined with next line
7. Unit tests pass for core parsing and calculation logic
7. Error handling works for missing files and invalid input
</done_when>
