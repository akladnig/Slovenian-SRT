# Slovenian SRT Generator

A command-line tool that generates SubRip (.srt) subtitle files from MP3, M4A, or MOV audio files and markdown transcripts with timestamps.

## Installation

### Build from Source

```bash
# Create the bin directory
mkdir -p ~/.local/bin

# Compile to native executable
dart compile exe bin/srt_generator.dart -o ~/.local/bin/slovenian-srt

# Add to PATH (add this line to your ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"

# Reload your shell
source ~/.zshrc  # or source ~/.bashrc for bash
```

### Verify Installation

```bash
slovenian-srt --help
```

## Usage

```bash
slovenian-srt <base_filename>
```

The tool looks for:
- `<base_filename>.mp3`, `<base_filename>.m4a`, or `<base_filename>.mov` - Audio/video file
- `<base_filename>.md` - Markdown transcript with timestamps

And generates:
- `<base_filename>.srt` - SubRip subtitle file

### Example

```bash
slovenian-srt examples/example
```

### Transcript Format

The markdown file should contain timestamps in `MM:SS` format:

```markdown
00:00 - Welcome to the video
00:05 - Today we'll discuss Slovenian grammar
00:12 - Let's start with the basics
```

## Rebuilding

After making changes to the source code, rebuild with:

```bash
dart compile exe bin/srt_generator.dart -o ~/.local/bin/slovenian-srt
```

## Development

Run with `dart run`:

```bash
dart run srt_generator examples/example
```

Run tests:

```bash
dart test
```
