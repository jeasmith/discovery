---
name: "OpalSpec: Design"
description: Create an OpalSpec design.md document from approved requirements
category: Workflow
tags: [workflow, sdd, OpalSpec, design]
---

Create the design stage for an existing OpalSpec spec.

**Input**: The argument after `/opal:design` is the spec name in kebab-case. The argument is optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md` and confirm with the user when more than one spec exists.

**Steps**

1. Read `.opal/runtime/spec-authoring-instructions.md`.
2. Read `.opal/specs/<change-name>/requirements.md`.
3. Read relevant source files to understand current architecture.
4. If needed, read `.opal/runtime/templates/design.md`.
5. Create `.opal/specs/<change-name>/design.md`.
6. After the design is settled, ask the user: "Want to play back the design with `/opal:playback`, generate tasks with `/opal:tasks`, or run `/opal:build` directly?". `/opal:tasks` is optional — `/opal:build` works directly from `design.md` when no `tasks.md` exists.

**Guardrails**

- Do not create `tasks.md`.
- Do not implement code.
- Do not invent behavior absent from requirements. If design reveals missing behavior, recommend a requirements update first.
- Include `Overview`, `Goals / Non-Goals`, `Architecture`, `Components and Interfaces`, `Data Models`, `Correctness Properties`, `Error Handling`, and `Testing Strategy`.
- Include `Decisions` using `**Outcome**`, `**Reasoning**`, and `**Alternative Options**` when the work has non-trivial cross-layer or architectural tradeoffs. Skip it for trivial designs.
- When the design has multiple runtime components across deployment boundaries, include a Runtime Component Flow Diagram in `Architecture` following `.opal/runtime/spec-authoring-instructions.md`.
- Trace correctness properties to requirement numbers.
