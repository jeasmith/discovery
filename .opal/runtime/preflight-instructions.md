# OpalSpec /opal:preflight Instructions

`/opal:preflight` is an optional read-only review stage after `design.md` exists and before implementation starts. It is intended for a different agent context than the one that authored the design.

The preflight agent reviews the plan for issues, risks, red flags, missing checks, and key improvements. It does not edit the spec and does not implement code. The user can paste the feedback back to the original design-authoring agent, which can then reason over it and update the design through the normal conversation.

## When To Run

Run preflight after `/opal:design` has produced `.opal/specs/<change-name>/design.md`.

Do not have the design-authoring agent automatically offer preflight. Preflight is a user-initiated cross-check, usually run in another agent session.

Good times to run it:

- Before implementation for medium or large changes.
- Before skipping `tasks.md` on work that still crosses layers.
- When the design includes non-trivial tradeoffs, migrations, persistence, security, concurrency, external APIs, data loss risk, or unclear test coverage.
- When the user wants a second opinion before asking the original agent to revise the design.

Skip it for small mechanical changes where a second review adds little.

## Inputs

```text
/opal:preflight "<change-name>"
```

The spec name is optional. If omitted, resolve the active spec via `.opal/runtime/spec-authoring-instructions.md`.

## What To Read

Before reviewing:

1. `.opal/runtime/spec-authoring-instructions.md`
2. `.opal/runtime/preflight-instructions.md`
3. `.opal/specs/<change-name>/requirements.md`
4. `.opal/specs/<change-name>/design.md`
5. `.opal/specs/<change-name>/tasks.md` if it already exists
6. Relevant source files, tests, schemas, configs, docs, and existing specs needed to judge whether the plan fits the codebase

The review must be grounded in the actual codebase. Do not review the design as an isolated essay.

## Stage Gate

Before continuing, confirm the spec is ready for preflight:

- `requirements.md` exists.
- `design.md` exists.
- `design.md` is not empty and has at least `Overview`, `Architecture`, `Components and Interfaces`, `Error Handling`, and `Testing Strategy` sections.

If the spec has not reached design stage, stop and say exactly what is missing. Do not create the missing docs.

If `tasks.md` is present, include it in the review, but do not require it.

## Review Focus

Look for:

- **Requirement coverage:** requirements that are missing from the design, contradicted by the design, or only partially addressed.
- **Scope creep:** design work that introduces behavior absent from requirements.
- **Architecture fit:** conflicts with existing module boundaries, naming, patterns, dependency direction, build setup, or tool conventions.
- **Interface risks:** unclear contracts, missing types, schema gaps, API compatibility problems, serialization or migration concerns.
- **Data and state risks:** data loss, duplicate state, stale caches, race conditions, concurrency issues, idempotency gaps, persistence failure modes.
- **Error and edge cases:** missing empty/loading/error states, fallback paths, retries, partial failure handling, validation, permissions, or recovery behavior.
- **Testing gaps:** missing unit, integration, property, UI, contract, migration, regression, or manual checks.
- **Implementation sequencing:** dependency order problems, hidden blockers, risky big-bang steps, missing rollout/backout considerations.
- **Security and privacy:** secrets, PII, authz/authn, injection, unsafe file/network access, excessive logging, or data retention issues.
- **Maintainability:** unnecessary abstractions, duplicated logic, unclear ownership, brittle coupling, poor naming, or unclear extension paths.

## Output Format

Return feedback only. Do not edit files.

Use this structure:

```markdown
## Preflight Review: <change-name>

### Verdict

<Ready / Ready with reservations / Not ready>

### Findings

1. **Severity: <High|Medium|Low> - <short title>**
   - **Where:** <design section, requirement number, file path, or module>
   - **Issue:** <what is wrong or risky>
   - **Why it matters:** <impact>
   - **Suggested revision:** <specific change the original agent should consider>

### Key Improvements

- <improvement that would materially strengthen the plan>

### Questions For The Original Agent

- <question the design-authoring agent should answer before implementation>

### Checks Performed

- <files/docs/source areas read>

### Residual Risk

<what remains uncertain after this review>
```

Ordering rules:

- Findings first, highest severity first.
- Prefer concrete findings over broad advice.
- If there are no findings, say that explicitly and list residual risks or test gaps.
- Do not bury a blocking issue in `Key Improvements`.

## Guardrails

- Do not modify `requirements.md`, `design.md`, `tasks.md`, or source files.
- Do not implement code.
- Do not create `tasks.md`.
- Do not run destructive commands.
- Do not turn the review into a new design. Give actionable feedback the original agent can incorporate.
- Do not assume the original design is wrong just because another option exists. Flag alternatives only when they reduce real risk or better fit the requirements/codebase.
- Cite concrete requirement numbers, design sections, file paths, or code symbols whenever possible.
