# Prompt: Start A New Spec

First read `.opal/runtime/spec-authoring-instructions.md`, `.opal/runtime/new-instructions.md`, and `.opal/runtime/askme-instructions.md`, and follow them for this request.

Start a new OpalSpec spec.

```text
Feature name (optional): <kebab-case name or blank>
Description: <what we are building>
```

Rules:

- If the feature name is missing, infer it from the description and confirm with me.
- If the description is missing, ask for it.
- Once the name and description are settled, ask: **Generate a draft requirements doc, or ask questions to clarify direction first?**
- Generate / draft → write `.opal/specs/<feature-name>/requirements.md` in one pass following `spec-authoring-instructions.md`.
- Ask questions / askme → follow `askme-instructions.md` to interview me one question at a time, writing `requirements.md` inline.
- When the requirements doc is settled, suggest `/opal:design`.
- Do not skip the style question. Do not create `design.md` or `tasks.md`. Do not implement code.
