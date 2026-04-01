# Plan: Compile srt_generator to Native Binary

## Task
Compile the slovenian_srt tool to a standalone native macOS binary (`~/.local/bin/slovenian-srt`).

## Steps

### 1. Create ~/.local/bin directory
```bash
mkdir -p ~/.local/bin
```

### 2. Compile Dart source to native binary
```bash
dart compile exe srt_generator/bin/srt_generator.dart -o ~/.local/bin/slovenian-srt
```

### 3. Update README with build instructions
Add section to `srt_generator/README.md`:
- Build command
- PATH setup
- How to rebuild after changes

### 4. Verify
- Binary exists at `~/.local/bin/slovenian-srt`
- Run `slovenian-srt examples/example` (if PATH includes it) or `~/.local/bin/slovenian-srt examples/example`
- Compare output with `dart run srt_generator examples/example`

## Done When
- [ ] Binary compiled to `~/.local/bin/slovenian-srt`
- [ ] Binary runs without Dart runtime
- [ ] README updated with build instructions
