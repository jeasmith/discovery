# OpalSpec New

First read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/new-instructions.md`, and `.opal/runtime/askme-instructions.md`, and follow them for this request.

Start a new OpalSpec spec. Inputs `<feature-name>` and `<description>` are both optional.

Rules:

- Resolve the feature name and description per `new-instructions.md`. Infer the kebab-case name from the description if missing. Ask for the description if missing. Confirm the name with the user before creating files.
- Ask: **Would you like me to generate a draft requirements doc, or ask you questions to clarify direction first?**
- Generate / draft → write `.opal/specs/<feature-name>/requirements.md` in one pass following `spec-authoring-instructions.md`.
- Ask questions / askme → follow `askme-instructions.md` to interview the user one question at a time, writing `requirements.md` inline.
- When the requirements doc is settled, suggest `/opal:design`.
- Do not skip the style question. Do not create `design.md` or `tasks.md`. Do not implement code.
