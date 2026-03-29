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

- [ ] Analyze diff between generated and expected
- [ ] Determine timing algorithm in expected file
- [ ] Fix `srt_generator.dart` timing logic
- [ ] Verify: `dart test` passes

### Phase 2: Validate Against Test File

- [ ] Run generator on example.md
- [ ] Compare output to example_for_testing.srt
- [ ] Fix any remaining mismatches
- [ ] Verify: diff shows no differences

## Risks / Out of scope

- **Risks**: Timing algorithm may be undocumented
- **Out of scope**: Adding new features, only fixing timing
