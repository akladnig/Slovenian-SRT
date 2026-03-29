## Overview

Fix SRT generator timing mismatch. Generated timestamps don't match expected test file.

**Spec**: `ai_specs/srt_generator_spec.md`

## Context

- **Status**: Implementation exists, tests pass, but output mismatch
- **Issue**: Generated timestamps differ from `example_for_testing.srt`
- **Expected**: Specific timing per test file
- **Actual**: Character-count proportional within line duration

## Plan

### Phase 1: Debug Timing Mismatch

- [x] Analyze diff between generated and expected
- [x] Determine timing algorithm in expected file
- [x] Fix `srt_generator.dart` timing logic
- [x] Verify: `dart test` passes

### Phase 2: Validate Against Test File

- [x] Run generator on example.md
- [x] Compare output to example_for_testing.srt
- [x] Fix any remaining mismatches
- [x] Verify: diff shows no differences

## Risks / Out of scope

- **Risks**: Timing algorithm may be undocumented
- **Out of scope**: Adding new features, only fixing timing
