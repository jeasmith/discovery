---
name: opalspec
description: Use the OpalSpec spec-driven development workflow in this repo. Use when the user mentions OpalSpec, .opal, /opal:new, requirements/design/tasks workflow, or asks to create/build an OpalSpec spec.
license: MIT
compatibility: Local repo workflow, no external CLI required.
metadata:
  author: local
  version: "3.4.0"
---

# OpalSpec

OpalSpec is this repo's local spec-driven development workflow.

Always start by reading `.opal/runtime/spec-authoring-instructions.md`.

## Stages

1. **New** (`/opal:new`): unified entry that gathers a feature name and description, then asks "Generate a draft requirements doc, or ask questions to clarify direction first?". Read `.opal/runtime/new-instructions.md`. Branches into define mode (one-shot) or askme mode (`.opal/runtime/askme-instructions.md`, interactive).
2. **Design**: read requirements first, then create or edit `.opal/specs/<change-name>/design.md`. After it settles, ask the user whether to play back, generate tasks, or build directly.
3. **Optional Preflight**: run a read-only second-agent review of `design.md` for issues, risks, red flags, missing checks, and key improvements. Read `.opal/runtime/preflight-instructions.md`. Do not edit specs or implement code. Trigger: `$opalspec preflight <name>` or "preflight this design".
4. **Optional Playback**: walk the user through `design.md` section by section with Understood/Question/Don't-understand/Stop prompts. Read `.opal/runtime/playback-instructions.md`. Trigger: `$opalspec play back design for <name>` or "play back the design".
5. **Optional Tasks**: read requirements and design first, then create or edit `.opal/specs/<change-name>/tasks.md`. Skippable when the design is small/well-scoped.
6. **Build**: read requirements, design, and `.opal/runtime/change-protocol.md`. If `tasks.md` is present, treat it as the persistent resume ledger: implement tasks in order and update each completed task, subtask, or checkpoint checkbox immediately as work completes. If absent, build directly from `design.md` in dependency order. After it finishes, offer `/opal:document`.
7. **Optional Document**: write or update `.opal/docs/<topic>.md` per `.opal/runtime/document-instructions.md`. Multiple specs can update the same topic.

For stages 2 onwards, the spec name is optional — if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

## Guardrails

- Do not implement while authoring requirements, design, or tasks unless explicitly asked.
- Do not create downstream artifacts unless the user asks for that stage.
- Preserve traceability from design properties and tasks to requirement numbers.
- If a later stage reveals missing behavior, update or ask to update requirements first.
- Keep implementation edits scoped to the active OpalSpec spec.

## Invocation Examples

```text
$opalspec new <change-name>: <description>
$opalspec create design for <change-name>
$opalspec preflight <change-name>
$opalspec play back design for <change-name>
$opalspec create tasks for <change-name>
$opalspec build <change-name>
$opalspec document <topic>
```
