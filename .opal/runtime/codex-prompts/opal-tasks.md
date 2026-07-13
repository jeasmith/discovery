# OpalSpec Tasks

First read `.opal/runtime/spec-authoring-instructions.md` and follow it for this request.

The spec name argument is optional; if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Read `.opal/specs/<change-name>/requirements.md` and `.opal/specs/<change-name>/design.md`.

Create only `.opal/specs/<change-name>/tasks.md`.

Rules:

- Do not implement code.
- Use `# Implementation Plan: <Feature Name>`.
- Include `Overview`, `Tasks`, and `Notes`.
- Make tasks incremental and dependency-aware.
- Name concrete files/modules in task details.
- Trace each task to requirement numbers with `_Requirements: ..._`.
- Add checkpoint tasks only after cohesive groups of work or major layers, not after every small task.
- For each checkpoint, name the relevant verification command or check when known.
- Mark optional property tests or extra tests with `[ ]*`.
- Note that `tasks.md` is updated during build as the resume ledger.
