---
name: "OpalSpec: Build"
description: Build an OpalSpec spec — from tasks.md if present, otherwise from design.md directly
category: Workflow
tags: [workflow, sdd, OpalSpec, implementation]
---

Build an OpalSpec spec.

**Input**: The argument after `/opal:build` is the spec name in kebab-case. The argument is optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md` and confirm with the user when more than one spec exists.

**Steps**

1. Read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/change-protocol.md`.
2. Read `.opal/specs/<change-name>/requirements.md` and `.opal/specs/<change-name>/design.md`.
3. Check for `.opal/specs/<change-name>/tasks.md`:
   - **Present**: treat `tasks.md` as the persistent resume ledger. Implement pending tasks in order unless a dependency requires a small reorder. Update each completed task, subtask, or checkpoint checkbox from `[ ]` to `[x]` in `tasks.md` immediately after it completes; do not wait until the end or rely only on chat-plan state.
   - **Absent**: work directly from `design.md`. Plan a short ordered checklist in your head (or briefly state it to the user before starting), implement step by step in dependency order, and report each layer as you finish it. No `tasks.md` is created.
4. Run relevant verification commands at checkpoint tasks and at the end.
5. After build, ask the user: "Want me to write or update a dev doc for this with `/opal:document <topic>`?". Recommend a topic if appropriate. If the user accepts, run the document flow per `.opal/runtime/document-instructions.md`.

**Guardrails**

- Keep edits scoped to the spec.
- Preserve existing user changes.
- If building reveals a design or requirement problem, **stop and run the change protocol in `.opal/runtime/change-protocol.md`**: report the discovery, propose a concrete way forward with spec edits listed, wait for explicit user acceptance, update the affected docs (requirements → design → tasks if present), then resume. Do not edit specs or diverge from the agreed plan without user agreement.
- Report completed work, verification results, and any checks that could not be run.
