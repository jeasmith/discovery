# Implementation Plan: <Feature Name>

## Overview

<Summarize the implementation order and major dependencies. Mention whether this follows API-first, domain-first, UI-first, or another sequence.>

## Tasks

- [ ] 1. <First milestone>
  - [ ] 1.1 <Concrete implementation task>
    - Update `<path>` to <specific change>
    - Add <type/function/component/schema>
    - _Requirements: 1.1, 1.2_

  - [ ]* 1.2 Write property/unit tests for <behavior>
    - **Property 1: <property name>**
    - **Validates: Requirements 1.1, 1.2**

- [ ] 2. <Second milestone>
  - [ ] 2.1 <Concrete implementation task>
    - Update `<path>` to <specific change>
    - _Requirements: 2.1, 2.2_

- [ ] 3. Checkpoint - Verify <layer or milestone>
  - Run <specific focused test, typecheck, lint, build, visual, or manual check>
  - Resolve failures before continuing

- [ ] 4. <Final integration milestone>
  - [ ] 4.1 <Concrete implementation task>
    - Wire <source> to <destination>
    - _Requirements: 3.1, 3.2_

- [ ] 5. Final checkpoint - Ensure verification passes
  - Run the relevant test, typecheck, lint, build, or visual verification commands
  - Record any checks that could not be run

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP.
- Keep requirement references on implementation tasks.
- Update checkboxes immediately as implementation progresses so this file is the resume ledger.
- Add checkpoints only after cohesive groups of work, and name the verification command or check when known.
- Add ordering constraints here, such as codegen before handler work or domain work before UI wiring.
