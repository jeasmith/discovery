# OpalSpec Design

First read `.opal/runtime/spec-authoring-instructions.md` and follow it for this request.

The spec name argument is optional; if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Read `.opal/specs/<change-name>/requirements.md`, then read relevant source files to understand current architecture.

Create only `.opal/specs/<change-name>/design.md`.

Rules:

- Do not implement code.
- Do not create `tasks.md`.
- Include `Overview`, `Goals / Non-Goals`, `Architecture`, `Components and Interfaces`, `Data Models`, `Correctness Properties`, `Error Handling`, and `Testing Strategy`.
- Include `Decisions` (using the `**Outcome** / **Reasoning** / **Alternative Options**` format) when the work has non-trivial cross-layer or architectural tradeoffs. Skip the section for trivial designs.
- When the design has multiple runtime components across deployment boundaries, include a Runtime Component Flow Diagram in `Architecture` following the rules in `spec-authoring-instructions.md` (TD flowchart, deployment-boundary subgraphs, labelled arrows, solid for current / dashed for future, 8–12 nodes, plain Mermaid). Use `.opal/runtime/templates/design.md` as the worked skeleton. Skip the diagram for single-layer or purely internal designs.
- Name concrete files/modules that should change.
- Number correctness properties and add `Validates: Requirements ...` traces.
- After the design is settled, ask: "Want to play back the design with `/opal:playback`, generate tasks with `/opal:tasks`, or run `/opal:build` directly?". `/opal:tasks` is optional — `/opal:build` works directly from `design.md` when no `tasks.md` exists.
