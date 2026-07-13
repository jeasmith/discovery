---
name: "OpalSpec: Tasks"
description: Create an OpalSpec tasks.md implementation plan from requirements and design
category: Workflow
tags: [workflow, sdd, OpalSpec, tasks]
---

Create the implementation task plan for an existing OpalSpec spec.

**Input**: The argument after `/opal:tasks` is the spec name in kebab-case. The argument is optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md` and confirm with the user when more than one spec exists.

**Steps**

1. Read `.opal/runtime/spec-authoring-instructions.md`.
2. Read `.opal/specs/<change-name>/requirements.md`.
3. Read `.opal/specs/<change-name>/design.md`.
4. If needed, read `.opal/runtime/templates/tasks.md`.
5. Create `.opal/specs/<change-name>/tasks.md`.

**Guardrails**

- Do not implement code.
- Make tasks incremental, dependency-aware, and verifiable.
- Name concrete files/modules in task details.
- Trace tasks to requirement numbers with `_Requirements: ..._`.
- Add checkpoint tasks only after cohesive groups of work or major layers, not after every small task.
- For each checkpoint, name the relevant verification command or check when known.
- Mark optional property tests or extra checks with `[ ]*`.
