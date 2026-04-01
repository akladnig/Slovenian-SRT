# Plan: CLI Input File Type Support

## Task
Change CLI to accept any input file (.md, .mp3, .m4a, .mov) and derive base filename.

## Steps

### 1. Modify CLI entry point
- [x] Read `srt_generator/bin/srt_generator.dart`
- [ ] Add extension validation for .md, .mp3, .m4a, .mov
- [ ] Extract base path by stripping extension
- [ ] Update usage message
- [ ] Handle unsupported extension error

### 2. Test all file types
- [ ] Test: `slovenian-srt examples/example.md`
- [ ] Test: `slovenian-srt examples/example.mp3`
- [ ] Test: `slovenian-srt examples/example.m4a`
- [ ] Test: `slovenian-srt examples/example.txt` (should error)

### 3. Run existing tests
- [ ] `cd srt_generator && dart test`

## Done When
- [ ] CLI accepts any of: .md, .mp3, .m4a, .mov
- [ ] Unsupported extensions show error
- [ ] All existing tests pass
