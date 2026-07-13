# OpalSpec Preflight

Run a read-only preflight review for an existing OpalSpec spec.

Input: spec name in kebab-case (optional - if omitted, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`).

Steps:

1. Read `.opal/runtime/spec-authoring-instructions.md` and `.opal/runtime/preflight-instructions.md`.
2. Resolve the active spec.
3. Confirm `.opal/specs/<change-name>/requirements.md` and `.opal/specs/<change-name>/design.md` exist. Stop if the spec is not at design stage.
4. Read requirements, design, `tasks.md` if present, and relevant source files.
5. Review design against the codebase for issues or red flags and gaps in the plan. Review requirement coverage, architecture fit, interface/data risks, error handling, testing gaps, sequencing, security/privacy, and maintainability.
6. Return findings, key improvements, questions for the original agent, checks performed, and residual risk.

Guardrails:

- Do not edit specs or source files.
- Do not create `tasks.md`.
- Do not implement code.
