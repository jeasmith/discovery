---
name: "OpalSpec: Document"
description: Write or update a developer guide at .opal/docs/<topic>.md based on what was just built
category: Workflow
tags: [workflow, sdd, opal, document]
---

Write or update a developer-facing guide for an area of the codebase.

**Input**: `/opal:document "<topic>"`. The topic is optional — if omitted, recommend one based on the active spec and the existing `.opal/docs/` files.

**Steps**

1. Read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/document-instructions.md`.
2. Resolve the active spec per the spec inference rule.
3. Read `.opal/specs/<active-spec>/requirements.md`, `design.md`, and `tasks.md` (if present).
4. Resolve the topic — use the supplied argument, or recommend an existing/new topic and confirm with the user. Topics are kebab-case.
5. Read `.opal/docs/<topic>.md` if it exists.
6. Read the relevant implementation files so the doc reflects shipped code.
7. Write or update `.opal/docs/<topic>.md` per the structure in `document-instructions.md`. Add the active spec to `Related specs` and stamp the YYYY-MM-DD update marker at the bottom.
8. Tell the user what was added or changed.

**Guardrails**

- Audience is humans, not agents — plain language, concrete examples, file paths.
- Do not restate the spec verbatim; synthesise the system view.
- Do not silently restructure an existing topic doc; propose first.
- Do not implement code.
