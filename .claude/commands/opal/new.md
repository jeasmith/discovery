---
name: "OpalSpec: New"
description: Start a new OpalSpec spec — gather name + description, then pick generate-or-askme
category: Workflow
tags: [workflow, sdd, opal, new]
---

Start a new OpalSpec spec.

**Input**: `/opal:new "<feature-name>" "<description>"`. Both arguments are optional.

**Steps**

1. Read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/new-instructions.md`, and `.opal/runtime/askme-instructions.md`.
2. Resolve the feature name and description per `new-instructions.md` (infer name from description if missing; ask for description if missing).
3. Confirm the kebab-case name with the user before creating any files.
4. Ask: "Would you like me to generate a draft requirements doc, or ask you questions to clarify direction first?".
5. Branch on the answer:
   - **Generate / draft** → Define mode. Write `.opal/specs/<feature-name>/requirements.md` in one pass following `spec-authoring-instructions.md`.
   - **Ask questions / askme** → AskMe mode. Follow `.opal/runtime/askme-instructions.md` to interview the user one question at a time, writing `requirements.md` inline.
6. When the requirements doc is settled, suggest `/opal:design`.

**Guardrails**

- Do not skip the style question — define vs askme is the fork that `/opal:new` exists for.
- Do not write to disk until the kebab-case name is confirmed.
- Do not create `design.md` or `tasks.md`.
- Do not implement code.
