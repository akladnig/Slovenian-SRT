## Overview

Implement and verify SRT generator per `ai_specs/srt_generator_spec.md`. Phase 1: add missing tests and verify end-to-end output against `example_for_testing.srt`. Phase 2: ensure CLI handles edge cases per spec.

**Spec**: `ai_specs/srt_generator_spec.md`

## Context

- **Structure**: Layer-first (lib contains one class per file)
- **State management**: None (pure functions/DTOs)
- **Reference implementations**: `lib/srt_generator.dart`, `lib/markdown_parser.dart`, `test/example_for_testing.srt`
- **Assumptions/Gaps**:
  - Integration test comparing generated output with `test/example_for_testing.srt` is missing
  - `MarkdownParser` does not strip HTML header tags; logic lives in `SrtGenerator`
  - `SrtFormatter` is tested indirectly via `SrtGenerator`

## Plan

### Phase 1: Add missing unit tests + integration test

- **Goal**: Fill spec gaps, verify correct output
- [ ] `test/srt_generator_test.dart` - Add: multiple dots preserved (`"Hello... World."` → `["Hello...", "World."]`)
- [ ] `test/srt_generator_test.dart` - Add: dash stripping from split segments
- [ ] `test/srt_generator_test.dart` - Add: line joining logic (no terminator + no header tag → join)
- [ ] `test/srt_generator_test.dart` - Add: header tag detection (`<h1>Title</h1>` prevents joining with next)
- [ ] `test/srt_generator_test.dart` - Add: header tag stripping from text
- [ ] `test/srt_generator_test.dart` - Add: character-count proportional timing (30 + 10 chars in 4000ms → 3000 + 1000ms)
- [ ] `test/srt_generator_test.dart` - Add: 0 total chars → skip (avoid division by zero)
- [ ] `test/srt_generator_test.dart` - Add integration test: run `SrtGenerator` on `../examples/example`, compare output with `test/example_for_testing.srt`
- [ ] Verify: `dart analyze` && `dart test`

### Phase 2: Verify CLI + edge cases

- **Goal**: CLI error handling per spec
- [ ] `bin/srt_generator.dart` - Verify error message format matches spec (e.g., "Audio file not found: {path}.mp3, {path}.m4a, or {path}.mov")
- [ ] Run tool with missing files and verify error messages + exit code 1
- [ ] Verify: `dart analyze` && `dart test`

## Risks / Out of scope

- **Risks**: None
- **Out of scope**: Refactoring core logic (already implemented); MOV extraction tests (requires MOV file setup)
