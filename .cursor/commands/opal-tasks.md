# OpalSpec Tasks

Create the implementation task plan for an existing OpalSpec spec.

Input: spec name in kebab-case (optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md`.
2. Read `.opal/specs/<change-name>/requirements.md`.
3. Read `.opal/specs/<change-name>/design.md`.
4. Create only `.opal/specs/<change-name>/tasks.md`.

Guardrails:

- Do not implement code.
- Make tasks incremental and requirement-traced.
- Add checkpoint tasks only after cohesive groups of work or major layers, not after every small task.
- For each checkpoint, name the relevant verification command or check when known.
- Mark optional tests or extra checks with `[ ]*`.
