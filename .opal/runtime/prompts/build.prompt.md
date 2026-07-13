# Prompt: Build

First read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/change-protocol.md`, and follow them for this request.

The spec name is optional. If omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Build from the spec at:

```text
.opal/specs/<change-name>/
```

Rules:

- Read `requirements.md` and `design.md` before editing. Check for `tasks.md`.
- If `tasks.md` is present: treat it as the persistent resume ledger. Implement pending tasks in order unless a dependency requires a small reorder, and update each completed task, subtask, or checkpoint checkbox in `tasks.md` immediately after it completes. Do not wait until the end of the build or rely only on chat-plan state.
- If `tasks.md` is absent: work directly from `design.md`. Plan a short ordered checklist and implement in dependency order. Do not create `tasks.md`.
- Keep edits scoped to the spec.
- Preserve existing user changes.
- Run relevant verification commands at checkpoint tasks and at the end.
- After build, ask: "Want me to write or update a dev doc for this with `/opal:document <topic>`?". If yes, follow `.opal/runtime/document-instructions.md`.
- If building reveals a design or requirement problem, stop and run the change protocol: report the discovery, propose spec edits, wait for explicit user acceptance, update the affected docs (requirements → design → tasks if present) preserving traceability, then resume. Do not edit specs unilaterally.
- Report completed work, verification results, and any checks that could not be run.
