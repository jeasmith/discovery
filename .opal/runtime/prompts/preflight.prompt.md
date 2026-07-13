# Prompt: Preflight

First read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/preflight-instructions.md`, and follow them for this request.

Run a read-only preflight review for:

```text
.opal/specs/<change-name>/
```

The spec name is optional. If omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`.

Rules:

- Confirm the spec is at least at design stage: `requirements.md` and `design.md` must exist.
- Read requirements, design, tasks if present, and relevant source files before reviewing.
- Review design against the codebase for issues or red flags and gaps in the plan. Review requirement coverage, architecture fit, interface/data risks, error handling, testing gaps, sequencing, security/privacy, and maintainability.
- Return findings, key improvements, questions for the original agent, checks performed, and residual risk.
- Do not edit specs or source files. Do not create `tasks.md`. Do not implement code.
