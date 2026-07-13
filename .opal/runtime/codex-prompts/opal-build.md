# OpalSpec Build

First read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/change-protocol.md`, and follow them for this request.

The spec name argument is optional; if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Read `.opal/specs/<change-name>/requirements.md` and `.opal/specs/<change-name>/design.md`. Check for `tasks.md`.

Rules:

- If `tasks.md` is present: treat it as the persistent resume ledger. Implement pending tasks in order, and update each completed task, subtask, or checkpoint checkbox in `tasks.md` immediately after it completes. Do not wait until the end of the build or rely only on chat-plan state.
- If `tasks.md` is absent: work directly from `design.md`. Plan a short ordered checklist and implement in dependency order. Do not create `tasks.md`.
- Keep edits scoped to the spec.
- Preserve existing user changes.
- Run relevant verification commands at checkpoint tasks and at the end.
- After build, ask the user: "Want me to write or update a dev doc for this with `/opal:document <topic>`?". If yes, run the document flow per `.opal/runtime/document-instructions.md`.
- If building reveals a design or requirement problem, stop and run the change protocol: report the discovery, propose spec edits, wait for explicit user acceptance, update the affected docs (requirements → design → tasks if present) preserving traceability, then resume. Do not edit specs unilaterally.
- Report completed work, verification results, and any checks that could not be run.
