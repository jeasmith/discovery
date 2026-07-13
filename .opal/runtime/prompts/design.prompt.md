# Prompt: Create Design

First read `.opal/runtime/spec-authoring-instructions.md` and follow it for this request.

The spec name is optional. If omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Create `.opal/specs/<change-name>/design.md` from:

```text
.opal/specs/<change-name>/requirements.md
```

Rules:

- Read `.opal/specs/<change-name>/requirements.md` before writing.
- Read the relevant codebase files before writing the design.
- Do not implement code.
- Create only `design.md`; do not create `tasks.md`.
- Include `Overview`, `Goals / Non-Goals`, `Architecture`, `Components and Interfaces`, `Data Models`, `Correctness Properties`, `Error Handling`, and `Testing Strategy`.
- Include `Decisions` (using the `**Outcome** / **Reasoning** / **Alternative Options**` format) when the work has non-trivial cross-layer or architectural tradeoffs. Skip the section for trivial designs.
- When the design has multiple runtime components across deployment boundaries, include a Runtime Component Flow Diagram in `Architecture` following the rules in `spec-authoring-instructions.md` (TD flowchart, deployment-boundary subgraphs, labelled arrows, solid for current / dashed for future, 8–12 nodes, plain Mermaid). Skip the diagram for single-layer or purely internal designs.
- Name concrete files/modules that should change.
- Include signatures, schema fragments, SQL, or prop shapes where useful.
- Number correctness properties and add `Validates: Requirements ...` traces.
- After the design is settled, ask: "Want to play back the design with `/opal:playback`, generate tasks with `/opal:tasks`, or run `/opal:build` directly?". `/opal:tasks` is optional — `/opal:build` works directly from `design.md` when no `tasks.md` exists.
- Stop after creating `design.md` and asking the next-stage question.
