# OpalSpec Change Protocol

Specs are authored before implementation, but reality changes once you start building. When building reveals that the existing spec is wrong, incomplete, or no longer the best path, the agent must **stop, surface the change, get user agreement, and update the affected docs before resuming work**.

This protocol applies primarily to the build stage but the same loop is appropriate any time a downstream stage exposes a problem with an upstream one.

## When To Trigger

Pause and run this protocol when, mid-implementation, any of the following becomes true:

- A task as written would produce wrong, incomplete, or inconsistent behaviour.
- The design assumed something that turns out not to hold (a missing API, a different library, a different file layout, a constraint that didn't exist before).
- A requirement is now ambiguous given what you've learned from the code.
- A new constraint surfaces (performance, compatibility, dependency, security) that the spec did not account for.
- You see a materially better approach than the planned one — simpler, safer, more aligned with existing patterns.
- A task in `tasks.md` references a file, module, or interface that does not exist or works differently than described.

If you can complete the task as written without compromising correctness, do not trigger this protocol — finish the task and continue.

## The Loop

### 1. Stop

Stop before making any change that diverges from `tasks.md`, `design.md`, or `requirements.md`. Do not "just adjust" the implementation silently. Do not edit the spec docs unilaterally.

### 2. Report

Tell the user, in this order:

- **What you found** — one or two sentences. Concrete, not abstract.
- **Which spec elements are affected** — name them by number where possible, e.g. "Requirement 2.1, Design Property 3, Task 4.2".
- **Why the existing plan no longer fits** — the specific failure mode if you continued.

Cite file paths and line numbers when referring to code. Do not paraphrase the spec — quote the relevant lines if there is any chance of disagreement about what the spec says.

### 3. Propose

Offer a concrete way forward:

- **The new approach** in enough detail that the user can evaluate it.
- **Tradeoffs** versus the original plan — what gets better, what gets worse, what stays the same.
- **The exact spec edits required**, listed by file and section. For example:
  - "Update `requirements.md` Requirement 2.1: change 'system SHALL retry on 5xx' to '... up to 3 times with exponential backoff'."
  - "Update `design.md` Components and Interfaces: replace the `RetryQueue` interface with `BackoffScheduler`."
  - "Update `tasks.md` Task 4.2 and add Task 4.3 for the backoff schedule unit tests."
- **Whether this is a behaviour change** (touches `requirements.md`) or a plan change only (touches `design.md` and/or `tasks.md`).

If you have more than one viable option, propose the one you recommend and briefly note the alternatives. Don't ask open-ended "what should we do?" questions when you can ask "should we do X or Y, and I recommend X because Z?".

### 4. Wait For Acceptance

Do not proceed without explicit user agreement. Silence is not consent. The user may:

- **Accept** the proposal as written → go to step 5.
- **Modify** the proposal → revise and re-propose; do not start step 5 until agreement is reached.
- **Reject** the proposal and tell you to continue with the original plan → resume implementation, but flag the contradiction in your output and add a `// TODO` or note in the affected file if the original plan is genuinely problematic.
- **Defer** ("park this, work on something else") → leave the partially-completed task as-is, mark it in `tasks.md` with a note, and pick up the next unblocked task.

### 5. Update Specs

Update the affected docs in the correct order. Preserve traceability throughout.

1. **Requirements first** if behaviour is changing. Edit `requirements.md` so the new behaviour is captured as numbered EARS-style criteria. If a criterion is removed, leave a one-line note explaining why; do not just delete it.
2. **Design next** if architecture, interfaces, data models, or correctness properties change. Update the affected sections of `design.md`. Re-check the `**Validates: Requirements ...**` traces — they must still resolve to real requirement numbers.
3. **Tasks last**. Update `tasks.md` to match the new design. Tick checkboxes for work already completed; rewrite or add tasks for the new path. Every task must still trace to requirement numbers via `_Requirements: ..._`.

Keep the edits minimal and scoped. Do not rewrite sections that are not affected by the change.

### 6. Resume

Continue implementing from the updated `tasks.md`. State explicitly which task you are resuming and confirm the current state of the work-in-progress before continuing.

## Anti-patterns

- **Silent drift.** Editing implementation in a way that contradicts the spec without surfacing it. The spec is the source of truth; if it's wrong, fix the spec, don't pretend it isn't.
- **Unilateral spec edits.** Updating `requirements.md`, `design.md`, or `tasks.md` mid-implementation without user agreement.
- **Vague reports.** "Some things have changed" is useless. Name the specific spec elements and the specific code reality.
- **Open-ended proposals.** "What should we do?" forces the user to do your thinking. Recommend something concrete.
- **Skipping requirements when behaviour changed.** If the user-observable behaviour is different from `requirements.md`, that file must be updated — even if the change feels small.
- **Forgetting traceability.** New tasks without `_Requirements: ..._`, or design properties without `**Validates: Requirements ...**`, break the chain that makes OpalSpec useful.
- **Continuing past disagreement.** If the user has not explicitly accepted, do not proceed.

## Quick Template For The Report

When you pause mid-implementation, structure your message like this:

```text
Pausing per OpalSpec change protocol.

Found: <one or two sentence concrete description, with file paths>
Affects: <Requirement X.Y, Design Property Z, Task A.B>
Original plan fails because: <specific failure mode>

Proposed new approach: <concrete description>
Tradeoffs: <better / worse / same>
Spec edits required:
  - requirements.md: <which sections, what change>
  - design.md: <which sections, what change>
  - tasks.md: <which tasks change, which are added>

This is a <behaviour | plan-only> change.

OK to update specs and resume?
```

The user can then accept, modify, or reject. Once agreed, proceed to step 5.
