# OpalSpec Document

First read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/document-instructions.md`, and follow them for this request.

Write or update a developer guide at `.opal/docs/<topic>.md`. The topic argument is optional — if omitted, recommend one based on the active spec and existing docs.

Rules:

- Resolve the active spec via the spec inference rule.
- Resolve the topic. Topics are kebab-case. Confirm with the user before writing if it was inferred.
- Read the spec's requirements/design/tasks and any existing `.opal/docs/<topic>.md`.
- Read the relevant implementation files so the doc reflects shipped code.
- Write or update `.opal/docs/<topic>.md` per the required structure. Add the active spec to `Related specs`. Stamp the YYYY-MM-DD update marker at the bottom.
- Audience is humans, not agents — plain language, concrete examples, file paths.
- Do not restate the spec verbatim. Do not silently restructure an existing topic doc; propose first. Do not implement code.
