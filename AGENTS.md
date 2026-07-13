<!-- OPALSPEC-INSTRUCTIONS-START -->
﻿# Project Agent Instructions

When a user prompt mentions the OpalSpec workflow, `.opal`, or spec-driven development for this repo, first read `.opal/runtime/spec-authoring-instructions.md` and follow it for that request.

OpalSpec requests are stage-based. Create or edit only the requested stage unless the user explicitly asks to continue:

- New spec stage (`/opal:new`): unified entry that gathers a kebab-case feature name and a description, then asks "Generate a draft requirements doc, or ask questions to clarify direction first?". Read `.opal/runtime/new-instructions.md` and follow it. Branch on the user's answer:
  - **Generate** → define mode: write `.opal/specs/<change-name>/requirements.md` in one pass following `spec-authoring-instructions.md`.
  - **Ask questions** → askme mode: follow `.opal/runtime/askme-instructions.md` to interview the user one question at a time, writing `requirements.md` inline.
- Design stage: read requirements first, then create or edit `.opal/specs/<change-name>/design.md`. After it is settled, ask: "Want to play back the design with `/opal:playback`, generate tasks with `/opal:tasks`, or run `/opal:build` directly?".
- Optional Preflight stage (after design, user-invoked): run a read-only second-agent review of `design.md` for issues, risks, red flags, missing checks, and key improvements. Read `.opal/runtime/preflight-instructions.md` and follow it. Do not edit specs or implement code. Trigger phrases: `/opal:preflight`, "preflight this design".
- Optional Playback stage (after design): walk the user through `design.md` section by section with Understood/Question/Don't-understand/Stop prompts. Read `.opal/runtime/playback-instructions.md` and follow it. Trigger phrases: `/opal:playback`, "play back the design".
- Tasks stage (optional): read requirements and design first, then create or edit `.opal/specs/<change-name>/tasks.md`.
- Build stage: read requirements, design, and `.opal/runtime/change-protocol.md` first. If `tasks.md` is present, treat it as the persistent resume ledger: implement tasks in order and update each completed task, subtask, or checkpoint checkbox immediately as work completes. If `tasks.md` is absent, build directly from `design.md` in dependency order. If reality diverges from the spec, follow the change protocol — stop, report, propose, get user agreement, update the affected docs, then resume. After build, offer `/opal:document <topic>` to write or update a dev guide.
- Optional Document stage (after build): write or update `.opal/docs/<topic>.md` per `.opal/runtime/document-instructions.md`. Multiple specs can update the same topic. Trigger phrases: `/opal:document`, "document this".

For all stages after `/opal:new` (`design`, `preflight`, `tasks`, `build`, `playback`, `document`), the spec name is optional — when omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Do not implement code while authoring requirements, design, or tasks unless the user explicitly asks for implementation.
<!-- OPALSPEC-INSTRUCTIONS-END -->
