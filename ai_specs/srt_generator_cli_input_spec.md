<goal>
Change the CLI argument handling to accept any input file (.md, .mp3, .m4a, or .mov) and derive the base filename automatically, rather than requiring the user to provide a base name without extension.
</goal>

<background>
Dart CLI tool for generating SRT subtitle files.

**Current behavior:**
- `slovenian-srt <base_filename>` → looks for `<base_filename>.mp3/m4a/mov` and `<base_filename>.md`

**Target behavior:**
- `slovenian-srt <file.ext>` where ext is .md, .mp3, .m4a, or .mov
- Tool derives base path from provided file, looks for matching files

**Files to examine:**
- @srt_generator/bin/srt_generator.dart - CLI entry point
- @srt_generator/lib/srt_generator.dart - Core generation logic
</background>

<user_flows>
Primary flow:
1. User runs `slovenian-srt video.mov`
2. Tool extracts base path "video" from "video.mov"
3. Tool looks for video.mp3, video.m4a, video.mov (with timestamp comparison)
4. Tool looks for video.md
5. Tool generates video.srt

Alternative flows:
- User provides .md: `slovenian-srt transcript.md` → derives "transcript", looks for transcript.mp3/m4a/mov
- User provides .mp3: `slovenian-srt audio.mp3` → derives "audio", looks for audio.md
- User provides .m4a: `slovenian-srt audio.m4a` → derives "audio", looks for audio.md

Error flows:
- Unsupported extension: Display error "Unsupported file type: .xyz. Use .md, .mp3, .m4a, or .mov"
- File not found: Display existing error messages unchanged
</user_flows>

<requirements>
**Functional:**
1. CLI accepts any file with extension .md, .mp3, .m4a, or .mov
2. Tool strips the extension to derive base path
3. Tool uses derived base path to find all required files (audio and markdown)
4. Tool preserves existing audio file detection logic (timestamp comparison, MOV extraction)
5. Usage message updated to reflect new argument format

**Validation:**
6. Test with .md input: `slovenian-srt examples/example.md`
7. Test with .mp3 input: `slovenian-srt examples/example.mp3`
8. Test with unsupported extension shows appropriate error
</requirements>

<boundaries>
Edge cases:
- File with multiple extensions (e.g., file.tar.gz): Only strip one extension from known types

Error scenarios:
- Unsupported extension: Exit with code 1, show error message
- File does not exist: Existing error handling (unchanged)
</boundaries>

<implementation>
**Files to modify:**
- `srt_generator/bin/srt_generator.dart`:
  - Parse input path to extract base name
  - Validate file extension
  - Update usage message

**Approach:**
1. Get the input path
2. Check extension is one of: .md, .mp3, .m4a, .mov
3. If invalid, print error and exit
4. If valid, extract base path (remove extension) and pass to SrtGenerator.generate()
5. Update usage: `Usage: slovenian-srt <file.md|file.mp3|file.m4a|file.mov>`

**What to avoid:**
- Modifying SrtGenerator class (no changes needed there)
- Breaking existing functionality
</implementation>

<validation>
Unit test updates:
- No new unit tests needed (this is CLI argument parsing)

Integration tests:
- Run: `slovenian-srt examples/example.md` → should generate examples/example.srt
- Run: `slovenian-srt examples/example.mp3` → should generate examples/example.srt
- Run: `slovenian-srt examples/example.mov` → should extract audio and generate examples/example.srt
- Run: `slovenian-srt examples/example.m4a` → should generate examples/example.srt
- Run: `slovenian-srt examples/example.txt` → should show unsupported extension error
</validation>

<done_when>
1. CLI accepts any of: .md, .mp3, .m4a, .mov
2. Unsupported extensions show error message
3. Base path correctly derived from input file
4. Existing functionality unchanged (audio detection, timestamp comparison)
5. All existing tests pass
6. New integration tests pass for all file types
</done_when>
