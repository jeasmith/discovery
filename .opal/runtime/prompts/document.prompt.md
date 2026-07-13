# Prompt: Document

First read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/document-instructions.md`, and follow them for this request.

Write or update a developer guide at:

```text
.opal/docs/<topic>.md
```

Topic is optional. If omitted, infer from the active spec and existing docs, then confirm with me.

Rules:

- Read the active spec's requirements/design/tasks and any existing `.opal/docs/<topic>.md`.
- Read the relevant implementation files so the doc reflects shipped code.
- Write or update `.opal/docs/<topic>.md` per the required structure (What this is, How it fits together, Key flows, Extending or changing this area, Related specs). Add the active spec to Related specs. Stamp the YYYY-MM-DD update marker at the bottom.
- Audience is humans — plain language, concrete examples, file paths.
- Do not restate the spec verbatim. Do not silently restructure an existing topic doc; propose first. Do not implement code.
