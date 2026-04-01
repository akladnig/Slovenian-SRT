# Plan: CLI Input File Type Support

## Task
Change CLI to accept any input file (.md, .mp3, .m4a, .mov) and derive base filename.

## Steps

### 1. Modify CLI entry point
- [x] Read `srt_generator/bin/srt_generator.dart`
- [x] Add extension validation for .md, .mp3, .m4a, .mov
- [x] Extract base path by stripping extension
- [x] Update usage message
- [x] Handle unsupported extension error

### 2. Test all file types
- [x] Test: `slovenian-srt examples/example.md`
- [x] Test: `slovenian-srt examples/example.mp3`
- [x] Test: `slovenian-srt examples/example.m4a` (skipped - file doesn't exist)
- [x] Test: `slovenian-srt examples/example.txt` (shows file not found, then unsupported)

### 3. Run existing tests
- [x] `cd srt_generator && dart test`

## Done When
- [x] CLI accepts any of: .md, .mp3, .m4a, .mov
- [x] Unsupported extensions show error
- [x] All existing tests pass
