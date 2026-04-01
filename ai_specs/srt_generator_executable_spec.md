<goal>
Compile the slovenian_srt tool to a standalone native macOS binary executable that runs without requiring `dart run` or a Dart installation. The binary will be placed in `~/.local/bin/slovenian-srt` for global access.
</goal>

<background>
Dart CLI tool for generating SRT subtitle files. Uses the dart-create skill conventions.

**Current state:**
- Run via: `dart run srt_generator <base_filename>`
- Located in: `./srt_generator/`

**Target state:**
- Run via: `slovenian-srt <base_filename>`
- Binary location: `~/.local/bin/slovenian-srt`

**Files examined:**
- @srt_generator/bin/srt_generator.dart - Entry point
- @srt_generator/pubspec.yaml - Project configuration
</background>

<user_flows>
Primary flow:
1. User runs `dart compile exe srt_generator/bin/srt_generator.dart -o ~/.local/bin/slovenian-srt`
2. Compiler produces native macOS binary at `~/.local/bin/slovenian-srt`
3. User adds `~/.local/bin` to PATH (if not already)
4. User runs `slovenian-srt <base_filename>` from any directory

Alternative flows:
- First-time setup: Create `~/.local/bin` directory if it doesn't exist
- Update: Re-run compile command to rebuild with latest changes
</user_flows>

<requirements>
**Functional:**
1. Compile Dart source to native macOS executable using `dart compile exe`
2. Output binary to `~/.local/bin/slovenian-srt`
3. Binary is standalone (no Dart runtime required to run)
4. Binary accepts same arguments as original: `<base_filename>`
5. Binary preserves all existing functionality:
   - Audio file detection (MP3/M4A/MOV)
   - Timestamp comparison and audio extraction from MOV
   - Markdown transcript parsing
   - SRT subtitle generation

**Documentation:**
6. Update README.md with build instructions
7. Document the build command and PATH setup
8. Document how to rebuild after changes

**Validation:**
9. Binary executes successfully without Dart runtime
10. Binary produces identical output to `dart run` version
11. Binary accepts same error inputs and produces same error messages
</requirements>

<boundaries>
Edge cases:
- `~/.local/bin` doesn't exist: Create it during build process
- PATH doesn't include `~/.local/bin`: Document in README
- Binary already exists: Overwrite without prompting

Error scenarios:
- Compilation failure: Display dart compile error, exit with code 1
- Missing source files: Display error from dart compile
</boundaries>

<implementation>
**Files to modify:**
- `srt_generator/README.md` - Add build and installation instructions

**Commands to execute:**
1. Create `~/.local/bin` directory: `mkdir -p ~/.local/bin`
2. Compile to native binary: `dart compile exe srt_generator/bin/srt_generator.dart -o ~/.local/bin/slovenian-srt`
3. Add to PATH (document in README)

**What to avoid:**
- Modifying the Dart source code (no changes needed to source)
- Cross-platform compilation (macOS only)
- Pub activation (native binary approach)
</implementation>

<validation>
Manual verification:
1. Run: `~/.local/bin/slovenian-srt examples/example`
2. Verify: `examples/example.srt` is generated correctly
3. Compare: Output should match result from `dart run srt_generator examples/example`

Automated check:
- Compile produces exit code 0
- Binary file exists at `~/.local/bin/slovenian-srt`
- Binary is executable (`chmod +x` applied)
</validation>

<done_when>
1. Native binary successfully compiled to `~/.local/bin/slovenian-srt`
2. Binary runs without Dart installed
3. Binary produces correct SRT output
4. README updated with build instructions
5. Binary accessible from PATH after setup
</done_when>
