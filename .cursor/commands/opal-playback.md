# OpalSpec Playback

Walk the user through an OpalSpec spec's `design.md` section by section.

Input: spec name in kebab-case (optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/playback-instructions.md`, and `.opal/runtime/change-protocol.md`.
2. Resolve the active spec.
3. Read `.opal/specs/<change-name>/requirements.md` and `design.md`.
4. For each non-trivial top-level section: synthesise what was decided, why, and how (cite requirement numbers), then prompt **Understood / Question / Don't understand / Stop**.
5. Questions fork into resolution — probe, challenge, or surface alternatives. Invoke `.opal/runtime/change-protocol.md` if the discussion concludes a real change is needed. Confusions fork into clarification, then re-prompt the same section. Stop ends the section walk and jumps to step 6.
6. After the section walk, ask "Any questions before we move on?". Answer questions (loop with "Anything else?") until the user has none.
7. Append `> Played back via OpalSpec playback on YYYY-MM-DD.` to `design.md` (note any skipped sections), then ask: "Generate tasks with `/opal:tasks`, or run `/opal:build` directly from the design?". Tasks is optional.

Guardrails:

- Do not read sections verbatim.
- Do not move on without an explicit Understood / Question / Don't understand / Stop signal.
- Do not skip the questions step at exit, even after Stop.
- Do not edit specs without explicit user agreement.
- Do not implement code.
