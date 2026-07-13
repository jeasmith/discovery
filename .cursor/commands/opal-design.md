# OpalSpec Design

Create the design stage for an existing OpalSpec spec.

Input: spec name in kebab-case (optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md`.
2. Read `.opal/specs/<change-name>/requirements.md`.
3. Read relevant source files.
4. Create only `.opal/specs/<change-name>/design.md`.
5. Include `Overview`, `Goals / Non-Goals`, `Architecture`, `Components and Interfaces`, `Data Models`, `Correctness Properties`, `Error Handling`, and `Testing Strategy`.
6. Include `Decisions` using `**Outcome**`, `**Reasoning**`, and `**Alternative Options**` when the work has non-trivial cross-layer or architectural tradeoffs. Skip it for trivial designs.
7. When the design has multiple runtime components across deployment boundaries, include a Runtime Component Flow Diagram in `Architecture` following `.opal/runtime/spec-authoring-instructions.md`.
8. After the design is settled, ask: "Want to play back the design with `/opal:playback`, generate tasks with `/opal:tasks`, or run `/opal:build` directly?". `/opal:tasks` is optional — `/opal:build` works directly from `design.md` when no `tasks.md` exists.

Guardrails:

- Do not create `tasks.md`.
- Do not implement code.
- Trace correctness properties to requirement numbers.
