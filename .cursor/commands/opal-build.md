# OpalSpec Build

Build from an OpalSpec spec.

Input: spec name in kebab-case (optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/change-protocol.md`.
2. Read `.opal/specs/<change-name>/requirements.md` and `.opal/specs/<change-name>/design.md`.
3. Check for `.opal/specs/<change-name>/tasks.md`:
   - **Present**: treat `tasks.md` as the persistent resume ledger. Implement pending tasks in order, and update each completed task, subtask, or checkpoint checkbox in `tasks.md` immediately after it completes. Do not wait until the end or rely only on chat-plan state.
   - **Absent**: work directly from `design.md`; plan a short ordered checklist and implement step by step in dependency order.
4. Run relevant verification commands at checkpoint tasks and at the end.
5. After build, ask the user: "Want me to write or update a dev doc for this with `/opal:document <topic>`?". If yes, run the document flow per `.opal/runtime/document-instructions.md`.

Guardrails:

- Preserve user changes.
- Keep edits scoped to the spec.
- If building reveals a design or requirement problem, stop and run the change protocol: report, propose spec edits, wait for user acceptance, update docs (requirements → design → tasks if present), then resume. Do not edit specs unilaterally.
