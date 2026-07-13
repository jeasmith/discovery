---
name: "OpalSpec: Playback"
description: Walk the user through design.md section by section with Understood/Question/Don't-understand/Stop prompts
category: Workflow
tags: [workflow, sdd, OpalSpec, design, playback]
---

Run a guided playback of an OpalSpec spec's `design.md`.

**Input**: The argument after `/opal:playback` is the spec name in kebab-case. The argument is optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md` to resolve the active spec, and confirm with the user when more than one exists.

**Steps**

1. Read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/playback-instructions.md`, and `.opal/runtime/change-protocol.md`.
2. Resolve the active spec name.
3. Read `.opal/specs/<change-name>/requirements.md` and `.opal/specs/<change-name>/design.md`.
4. Identify the top-level sections to walk in order; skip empty or "N/A" sections.
5. For each non-trivial section, synthesise *what was decided, why, and how* (citing requirement numbers), then prompt with **Understood / Question (please say what) / Don't understand (please say which part) / Stop**.
6. Branch on the response per `playback-instructions.md`:
   - **Understood**: move to the next section.
   - **Question**: fork into resolution — the user may want to probe the reasoning, challenge the decision, or surface an alternative. If the discussion concludes a real change is needed, invoke the change protocol; otherwise return to the main track once settled.
   - **Don't understand**: fork into clarification (lower abstraction, jargon broken down, concrete examples); re-prompt the same section after the user confirms understanding.
   - **Stop**: end the section walk and jump straight to the questions sub-conversation below.
7. After the section walk (whether all sections were covered or the user picked Stop), open the questions sub-conversation: ask "Any questions before we move on?". Answer each question (search the codebase if needed; invoke the change protocol if an answer reveals a real change), then ask "Anything else?" until the user has no more questions.
8. Once questions are done, append `> Played back via OpalSpec playback on YYYY-MM-DD.` to `design.md` (note any sections skipped via Stop), then ask the user: "Generate `/opal:tasks` first, or run `/opal:build` directly from the design?". Suggest tasks for non-trivial work; suggest direct build for small/well-scoped changes.

**Guardrails**

- Do not read sections verbatim — synthesise.
- Do not move past a section without an explicit Understood / Question / Don't-understand / Stop signal.
- Do not skip the questions sub-conversation at exit — always ask "any questions?" before asking about tasks vs build, even when the user picked Stop.
- Do not edit `design.md`, `requirements.md`, or `tasks.md` without explicit user agreement; for behaviour-affecting changes follow `.opal/runtime/change-protocol.md`.
- Do not implement code.
- Do not create `tasks.md`.
