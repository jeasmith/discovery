# OpalSpec Document

Write or update a developer guide at `.opal/docs/<topic>.md`.

Input: `<topic>` (optional — if omitted, recommend one based on the active spec and existing docs).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/document-instructions.md`.
2. Resolve the active spec.
3. Read the spec's requirements/design/tasks docs and any existing `.opal/docs/<topic>.md`.
4. Read the relevant implementation files so the doc reflects shipped code.
5. Write/update `.opal/docs/<topic>.md` per the required structure. Add the active spec to `Related specs` and stamp the update marker.
6. Summarise what was added or changed.

Guardrails:

- Audience is humans, not agents — plain language, concrete examples, file paths.
- Do not restate the spec verbatim.
- Do not silently restructure an existing topic doc; propose first.
- Do not implement code.
