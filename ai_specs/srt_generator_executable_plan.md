# Plan: Compile srt_generator to Native Binary

## Task
Compile the slovenian_srt tool to a standalone native macOS binary (`~/.local/bin/slovenian-srt`).

## Steps

### 1. Create ~/.local/bin directory
- [x] Create `~/.local/bin` directory

### 2. Compile Dart source to native binary
- [x] Compile to native binary at `~/.local/bin/slovenian-srt`

### 3. Update README with build instructions
- [x] Update `srt_generator/README.md` with build instructions

### 4. Verify
- [x] Binary exists at `~/.local/bin/slovenian-srt`
- [x] Binary runs successfully with `~/.local/bin/slovenian-srt examples/example`
- [x] All tests pass (`dart test`)

## Done When
- [x] Binary compiled to `~/.local/bin/slovenian-srt`
- [x] Binary runs without Dart runtime
- [x] README updated with build instructions
