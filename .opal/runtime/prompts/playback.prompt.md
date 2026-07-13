# Prompt: Playback

First read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/playback-instructions.md`, and `.opal/runtime/change-protocol.md`, and follow them for this request.

Run a guided playback of:

```text
.opal/specs/<change-name>/design.md
```

The spec name is optional. If omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Rules:

- Read `requirements.md` so you can cite the requirements that drove each decision.
- For each non-trivial top-level section in `design.md`, synthesise what was decided, why, and how (do not read verbatim).
- After every section, prompt: **Understood / Question (please say what) / Don't understand (please say which part) / Stop**. Wait for the signal before moving on.
- Question → fork into resolution (probe reasoning, challenge the decision, or surface an alternative); if the discussion concludes a real change is needed, invoke the change protocol; return to the main track once settled.
- Don't understand → fork into clarification at a lower abstraction; re-prompt the same section after the user confirms understanding.
- Stop → end the section walk and jump straight to the questions step below.
- Skip trivial sections with a one-line summary instead of prompting.
- After the section walk (whether all sections were covered or the user stopped early), ask "Any questions before we move on?". Answer each question; loop with "Anything else?" until the user has none.
- Once questions are done, append `> Played back via OpalSpec playback on YYYY-MM-DD.` to `design.md` (noting any sections skipped via Stop), then ask: "Generate tasks with `/opal:tasks`, or run `/opal:build` directly from the design?". Tasks is optional.
- Do not skip the questions step at exit, even after Stop.
- Do not edit specs without explicit user agreement. Do not implement code.
