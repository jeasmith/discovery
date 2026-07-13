# OpalSpec Spec Authoring Instructions

These instructions describe OpalSpec's requirements, design, and tasks flow.

## Core Rules

- Write specs before implementation.
- Keep each spec in `.opal/specs/<kebab-case-name>/`.
- Create documents in this order: `requirements.md`, then `design.md`, then (optionally) `tasks.md`.
- `requirements.md` and `design.md` are mandatory. `tasks.md` is **optional** — `/opal:build` can work directly from `design.md` when no `tasks.md` exists. Generating tasks is recommended for non-trivial work but skippable for small/well-scoped changes.
- Do not let later documents invent behavior that is absent from earlier documents. If design or tasks reveal missing behavior, update requirements first.
- During implementation, if reality diverges from the spec, follow the change protocol in `.opal/runtime/change-protocol.md`: stop, report, propose, get user acceptance, update the affected docs in order (requirements → design → tasks if present), then resume.
- An optional **preflight** stage can run after `design.md` exists. It is a read-only second-agent review of the plan for issues, risks, red flags, missing checks, and key improvements. Do not have the design-authoring agent automatically offer it; users invoke `/opal:preflight` deliberately in another agent context. Follow `.opal/runtime/preflight-instructions.md`.
- An optional **playback** stage sits between design and tasks. When the user invokes it, follow `.opal/runtime/playback-instructions.md` to walk `design.md` section by section with Understood / Question / Don't-understand / Stop prompts. Questions that result in real changes are routed through the change protocol.
- After build, the agent should offer the optional **`/opal:document`** stage, which writes or updates a developer guide at `.opal/docs/<topic>.md`. Multiple specs can update the same topic. Follow `.opal/runtime/document-instructions.md` when running it.
- Prefer precise, testable statements over broad product prose.
- Preserve traceability: every design property and implementation task should reference requirement numbers.
- Read the relevant codebase before writing design or tasks.
- Use existing project architecture, naming, libraries, and testing conventions.
- Keep generated docs pragmatic. They are implementation contracts, not marketing documents.

## Resolving The Active Spec

Some commands (`design`, `preflight`, `tasks`, `build`, `playback`, `document`) operate on an existing spec. The spec name is optional — when omitted, infer the active spec using this rule:

1. If `.opal/specs/` does not exist or is empty, prompt the user for a spec name (or, for `/opal:new`, a name and description).
2. If exactly one spec folder exists under `.opal/specs/`, use it without confirming.
3. If multiple spec folders exist, pick the most-recently-modified one (use the latest `mtime` of any file inside the folder, recursively) and **confirm with the user** before proceeding: "Resuming `<name>` — was that the right one?".
4. An explicit name argument always wins over inference.

The `/opal:new` command always requires (or infers + confirms) a name because it creates the spec folder. See `.opal/runtime/new-instructions.md` for the gather-name-then-fork flow.

## Authoring Modes

The requirements stage has two authoring modes. Both produce the same `requirements.md` shape; only the interaction differs.

- **Define mode** (default): the user provides a description and the agent writes `requirements.md` in one pass following the rules below.
- **AskMe mode**: the agent interviews the user one question at a time, proposing recommended answers and writing `requirements.md` inline as decisions crystallise. Use when the idea is fuzzy, terms are contested, or the user wants to surface unstated constraints. The full askme protocol lives in `.opal/runtime/askme-instructions.md` — read it before asking.

Downstream stages (design, tasks, implementation) are mode-agnostic.

## `requirements.md` Rules

Purpose: define what the system must do without over-specifying implementation.

Required structure:

```markdown
# Requirements Document

## Introduction

## Why

## Glossary

## Requirements

### Requirement 1: <Capability>

**User Story:** As a <role>, I want <capability>, so that <benefit>.

#### Acceptance Criteria

1. WHEN <condition>, THE <system/component> SHALL <observable behavior>
2. IF <condition>, THEN THE <system/component> SHALL <observable behavior>
3. THE <system/component> SHALL <invariant or static requirement>
```

`Why` rules:

- Capture the **business / product motivation** for the change: why now, what came before, where it fits in the bigger plan.
- Reference the surrounding context that EARS criteria can't carry — completed work that this builds on, gaps that block users today, the PRD or roadmap entry this satisfies.
- Two to four sentences usually. Concrete and specific, not generic ("we want to improve UX").
- Best populated with full conversational context. In **askme mode**, write `Why` during convergence, after all questions are answered. In **define mode**, write the best `Why` the description supports; if the description is sparse, leave a one-line placeholder and note that the user can rerun in askme mode for richer context.

Example:

```markdown
## Why

The landing page and signpost page are complete. The content page — the full reading view for an individual article or guide at `/tracks/{track-slug}/{article-id}` — is the final page type needed to make the app usable end-to-end. Without it, users can navigate to a track and see what to read, but cannot actually read anything. This is the next planned page type in the PRD.
```

Style rules:

- Use EARS-like criteria with `WHEN`, `IF`, `THEN`, and `SHALL`.
- Number every acceptance criterion.
- Write each criterion so it can become a test, property, or manual check.
- Use exact domain names from the codebase.
- Define important terms in `Glossary`, especially domain objects, UI screens, events, APIs, storage records, and generated types.
- Separate independent behaviors into separate requirements.
- Include constraints as requirements when they affect implementation, such as "pure component", "OpenAPI-first", "no external assets", "backward compatibility", or "non-blocking failure".
- Avoid implementation details unless they are project constraints or externally visible contracts.

Common requirement categories:

- Data model or schema changes
- Domain behavior
- Server or persistence behavior
- API contract behavior
- UI rendering and interaction behavior
- Error, empty, loading, and fallback states
- Backward compatibility and non-regression behavior
- Determinism, serialization, and round-trip behavior
- File/export structure when consistency matters

## `design.md` Rules

Purpose: translate approved requirements into an implementable architecture.

Required structure:

```markdown
# Design Document: <Feature Name>

## Overview

## Goals / Non-Goals

**Goals:**
- ...

**Non-Goals:**
- ...

## Decisions

### Decision 1: <Short title>

**Outcome**: ...

**Reasoning**: ...

**Alternative Options**: ...

## Architecture

## Components and Interfaces

## Data Models

## Correctness Properties

## Error Handling

## Testing Strategy
```

`Goals / Non-Goals` rules:

- **Goals** state what this design must achieve — the capabilities, behaviours, and constraints the change is on the hook for.
- **Non-Goals** state what this design deliberately does **not** address — work moved to a follow-up spec, behaviour handled elsewhere, or scope explicitly rejected. Non-goals are as important as goals; they prevent scope creep and tell future readers why this design did not solve some adjacent problem.
- Use bullets, one item per line. Concrete and specific.
- Three to seven goals and three to seven non-goals is typical. If you have many more, the change probably needs to be split.

`Decisions` rules:

- One entry per non-trivial design choice. Skip `Decisions` for trivial work that has no real tradeoffs.
- Use the structured format: numbered heading, `**Outcome**`, `**Reasoning**`, `**Alternative Options**`.
  - **Outcome**: one sentence stating what was decided.
  - **Reasoning**: two to four sentences on why this is the right call here. Reference the requirements it satisfies, the constraints it respects, or the existing patterns it aligns with.
  - **Alternative Options**: one to three sentences naming the leading option you did not pick and why. List multiple alternatives as separate bullets if useful.
- Cover cross-layer or architectural calls, not local refactors. The bar is "a future reader will wonder why we did this".

Design content rules:

- Begin with a short overview of the chosen approach.
- State architectural boundaries explicitly: domain, server, persistence, API, generated code, UI, Storybook, tests.
- Include diagrams or flow lists when data crosses layers.
- Name concrete files and modules where changes belong.
- Include TypeScript interfaces, function signatures, OpenAPI fragments, SQL schema, or component props when useful.
- Explain important tradeoffs in `Decisions`, not scattered throughout the doc.
- Keep design aligned with existing code patterns and the repo's current architecture.
- Include `Data Models` for any new or changed domain types, API schemas, database rows, serialized state, or UI data structures.
- Include `Error Handling` even if the answer is "no runtime error handling needed".
- Include `Testing Strategy` with unit, property-based, integration, contract, UI, or Storybook checks as applicable.

`Architecture` diagram rules (Runtime Component Flow):

When the design has multiple runtime components that interact across deployment boundaries (Client, Server, External, etc.) and you need to show **what talks to what, where it runs, and how data and control move**, draw a Runtime Component Flow Diagram in the `Architecture` section. Skip the diagram for single-layer or purely internal designs, or when a sequence / data-flow diagram fits better. When you do include one, follow these rules so diagrams stay consistent across specs:

- Use Mermaid `flowchart TD` (top-down).
- Group components into `subgraph` blocks by deployment boundary (`Client`, `Server`, `External`, etc.). Each subgraph contains only the components that run in that boundary.
- Stay at one abstraction level — runtime components, not classes or individual functions.
- Use standard shapes: **rectangles** for services/modules (`H[Handler]`), **cylinders** for databases (`DB[(Database)]`), **rounded rectangles** for UI (`UI(Screen)`).
- Use short node IDs with readable labels: `AE[Achievement Engine]`.
- Use **solid arrows** (`-->`) for current flow, **dashed arrows** (`-.->`) for planned or future flow.
- Label every arrow with the data type or event name: `|run_complete|`, `|persist unlocks|`, `|response + data|`. Arrow direction must match the control-flow / data-push direction.
- Layout: handlers and entry points at the top of `Server`, domain / business logic in the middle, persistence at the bottom. `Client` components stay separate, connected via response arrows from handlers.
- Aim for 8–12 nodes. If you need more, split into multiple diagrams.
- Every component must have at least one incoming or outgoing arrow — no orphans.
- No colors or custom styling. Plain Mermaid only.

See `.opal/runtime/templates/design.md` for a worked skeleton.

Correctness property rules:

- Use numbered properties: `### Property 1: <name>`.
- Write properties as universal statements using forms like `For any ... SHALL ...`.
- Add a validation trace after each property:

```markdown
**Validates: Requirements 1.1, 2.3**
```

- Prefer properties for deterministic logic, filtering, serialization, bounds, idempotence, data mapping, event triggering, and render invariants.
- For TypeScript projects, prefer fast-check for property tests when the codebase already uses or can support it.

## `tasks.md` Rules

Purpose: convert design into an incremental implementation checklist.

Required structure:

```markdown
# Implementation Plan: <Feature Name>

## Overview

## Tasks

- [ ] 1. <Milestone>
  - [ ] 1.1 <Concrete task>
    - <Specific implementation detail>
    - _Requirements: 1.1, 1.2_

## Notes
```

Task rules:

- Use checkbox tasks.
- Group work into numbered milestones and subtasks.
- Put dependency-sensitive work earlier. For API-first work: OpenAPI change, codegen, server, client/UI, tests.
- Each implementation task should identify concrete files or modules.
- Every task or subtask should trace to requirement numbers with `_Requirements: ..._`.
- Add checkpoint tasks only at natural boundaries after a cohesive group of work, such as domain, server/API, UI, or final verification. Do not add a checkpoint after every small task.
- Checkpoint tasks should name the relevant verification command or check when it is known, such as unit tests, typecheck, lint, build, UI/visual checks, or a focused manual check.
- Optional tasks use `[ ]*` or `[x]*`.
- Optional tasks are usually property tests, extra edge tests, or non-essential refinements.
- Include notes for dependencies, ordering constraints, test conventions, and MVP shortcuts.
- Do not include vague tasks like "polish UI" unless paired with specific acceptance criteria.
- During implementation, treat `tasks.md` as the persistent resume ledger. Update checkboxes from `[ ]` to `[x]` in the file immediately after each task, subtask, or checkpoint is completed; do not wait until the end of the build or rely only on chat-plan state.
- If work stops mid-task, leave the task unchecked so the next agent can resume from the last checked item.

## Bugfix Variant

For narrow fixes, a bug-focused requirements document can replace feature requirements.

Recommended bugfix structure:

```markdown
# Bugfix Requirements Document

## Introduction

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN <bug condition> THEN the system <wrong behavior>

### Expected Behavior (Correct)

2.1 WHEN <condition> THEN the system SHALL <correct behavior>

### Unchanged Behavior (Regression Prevention)

3.1 WHEN <condition> THEN the system SHALL CONTINUE TO <existing behavior>
```

Bugfix design should include:

- Bug condition
- Examples or reproduction notes
- Expected behavior
- Preservation requirements
- Hypothesized root cause
- Correctness properties
- Fix implementation
- Testing strategy

## Codex Operating Rules

When Codex uses this workflow:

- Create only the requested stage unless the user asks to proceed.
- Before `requirements.md`, inspect existing specs only if asked or useful for style.
- Before `design.md`, inspect relevant source files and current architecture.
- Before `tasks.md`, read both requirements and design.
- Before implementation, read `tasks.md` if present and update it as the durable progress record while work completes.
- Do not implement while authoring requirements/design/tasks unless explicitly asked.
- If a stage exposes missing or contradictory requirements, stop and propose the requirement change first.
