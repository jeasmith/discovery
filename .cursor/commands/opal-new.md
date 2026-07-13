# OpalSpec New

Start a new OpalSpec spec.

Input: `<feature-name>` and `<description>` (both optional — agent will gather what's missing).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/new-instructions.md`, and `.opal/runtime/askme-instructions.md`.
2. Resolve the feature name (infer from description if not given) and description (ask if missing).
3. Confirm the kebab-case name with the user.
4. Ask: "Generate a draft requirements doc, or ask questions to clarify direction first?".
5. **Generate** → write `.opal/specs/<feature-name>/requirements.md` in one pass (define mode).
6. **Ask questions** → run askme mode per `askme-instructions.md`.
7. When requirements settle, suggest `/opal:design`.

Guardrails:

- Do not skip the style question.
- Do not write before the name is confirmed.
- Do not create design.md or tasks.md.
- Do not implement code.
