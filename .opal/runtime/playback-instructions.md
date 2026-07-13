# OpalSpec Playback Mode Instructions

Playback is an optional stage between **design** and **tasks**. The agent steps the user through `design.md` section by section, explaining the reasoning, the *how*, and the design choices behind each decision. After every section the user signals **Understood**, **Question**, **Don't understand**, or **Stop**. Questions and confusions fork into resolution sub-conversations that return to the main track once settled. Stop jumps straight to the end-of-flow questions prompt.

The point is to surface misunderstandings, hidden disagreements, and unspoken concerns *before* they become bugs in `tasks.md` or wrong code at implementation time. **Question** is intentionally broader than "disagree" — it covers probing the reasoning, challenging a decision, or just asking why before deciding whether to disagree.

## When To Run Playback

Run playback when:

- The design touches multiple layers, has non-obvious tradeoffs, or introduces new patterns.
- The user wants to sanity-check the design before committing to a task plan.
- The design was largely AI-authored and the user wants a guided review.

Skip playback when the design is short, mechanical, or the user already feels confident — it is intentionally optional.

## Resolving The Active Spec

If the user did not provide a spec name, follow the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`. Do not start the walkthrough until the active spec is confirmed.

## Loading The Design

Before starting:

1. Read `.opal/specs/<change-name>/requirements.md` (so you can cite the requirements that drove each decision).
2. Read `.opal/specs/<change-name>/design.md` (the document you will walk through).
3. Read `.opal/runtime/change-protocol.md` (in case a question reveals a real change is needed in the design or upstream docs).
4. Identify the top-level sections to walk. Default order:
   - `Overview`
   - `Goals / Non-Goals`
   - `Decisions` (if present)
   - `Architecture`
   - `Components and Interfaces`
   - `Data Models`
   - `Correctness Properties`
   - `Error Handling`
   - `Testing Strategy`
5. Skip any section that is empty or contains only "N/A".

## The Walkthrough Loop

For each section, in order:

### 1. Synthesise

Tell the user, in plain language, **what the section decides, why, and how**. Cite the requirements that drove it where possible. Do **not** read the section verbatim — synthesise.

If the section is trivial (under three lines, no real design choices), give a one-line summary and move on without prompting. Reserve the four-option prompt for sections with real content.

Example for a non-trivial section:

> **Architecture.** The flow is: user input → island component → pure reducer → state. We picked a pure reducer here (rather than scattered setState calls) so the state transitions are testable in isolation — that maps directly to Requirement 3.2 (deterministic todo lifecycle). The `useTodoStorage` effect is the single I/O boundary, which keeps `localStorage` failures from corrupting in-memory state.

### 2. Prompt

After the synthesis, ask explicitly:

> Understood / Question (please say what) / Don't understand (please say which part) / Stop?

Do not move on until the user picks one.

### 3. Branch on the response

#### Understood

Mark the section covered (track in conversation state — do not write a state file). Move to the next section.

#### Question (+ comment)

The user wants to probe the reasoning, challenge a decision, or surface an alternative they think is better. Treat it broadly — Question covers anything from "why this and not X?" to "I think this is wrong because…". Fork into a resolution sub-conversation:

1. Acknowledge the question and quote the user's concern back so it is unambiguous.
2. Explore: ask any clarifying questions needed to understand what the user is actually asking or proposing. Search the codebase if the question is about how something currently works.
3. Reach one of three outcomes:
   - **The original design is correct after discussion** — explain why, get the user's "OK", and return to the main track.
   - **The user is right and the design needs to change** — invoke `.opal/runtime/change-protocol.md`. Report the discovery, propose specific edits to `design.md` (and to `requirements.md` or `tasks.md` if behaviour changes ripple upstream), wait for explicit user agreement, then update the affected docs preserving traceability. Once docs are updated, return to the main track and **re-walk the affected section** before continuing.
   - **The question is about scope or priority, not the design itself** — note it as a follow-up (e.g., add a `> Open question:` line to the relevant `design.md` section), confirm with the user, and return.
4. Return to the main track at the section after the one that was forked from. If the design changed in step 3, adjust the section list to reflect the edits.

#### Don't understand (+ which part)

Fork into a clarification sub-conversation:

1. Ask the user which part of the synthesis was unclear, if they have not already said.
2. Re-explain at a lower level of abstraction:
   - Break down jargon. ("Pure reducer" → "a function that takes the current state and an action, and returns the new state without changing anything else.")
   - Use a concrete example. Walk through what happens when the user adds a todo, edits it, then refreshes the page.
   - Reference the codebase. ("This is similar to the pattern at `src/foo.ts:42`.")
3. Ask the user if the explanation landed: "Does that make sense, or do you want me to go deeper on a specific part?"
4. Once the user confirms understanding, **re-prompt** with the original four options (Understood / Question / Don't understand / Stop) for the same section. The user may now mark the section understood, or surface a question that was hiding under the confusion.

If clarification reveals that the design is genuinely under-explained in `design.md` itself, propose a small edit to add the missing rationale. This is a non-behavioural edit — it does not need the full change protocol; just propose, get user agreement, apply.

#### Stop

The user wants to leave the section walk early — perhaps they have seen enough, want to ask broader questions, or are time-boxed. Skip any remaining sections without prompting and jump straight to **Convergence and Exit** below. Note in your closing message which sections were not walked, so the user knows what was skipped.

### 4. Continue

After resolution, move to the next unvisited section. Track which sections have been covered, which were forked, and the outcome of each fork.

## Convergence and Exit

The section walk ends when **either**:

- Every non-trivial section has been covered and all forks are resolved, **or**
- The user picks **Stop** at any section.

Once the section walk is over, **do not immediately suggest the next stage**. Instead, open a questions sub-conversation so the user can ask anything that did not fit the per-section structure (cross-cutting questions, "what about X scenario", "why didn't we go with Y", etc.).

### Questions sub-conversation

Ask:

> Any questions before we move on? If not, I'll suggest the next stage.

If the user has questions:

1. Answer the question, citing the relevant `design.md` / `requirements.md` sections and code paths where useful. Search the codebase if the answer is not already in the docs.
2. If a question reveals a real change is needed (a missing decision, a wrong assumption), invoke `.opal/runtime/change-protocol.md`.
3. If a question reveals that `design.md` itself is missing rationale, propose a small clarification edit (non-behavioural, no change protocol needed; just propose, get agreement, apply).
4. After answering, ask:

   > Anything else, or shall we move on?

   Loop until the user signals they are done.

If the user has no questions, proceed to the exit step.

### Exit

When the questions sub-conversation is closed (or the user said "no questions" up front), append the following line to `design.md` (under the top heading, after any existing trailing notes):

```text
> Played back via OpalSpec playback on YYYY-MM-DD.
```

If the user stopped early, also note which sections were skipped, e.g.:

```text
> Played back via OpalSpec playback on YYYY-MM-DD. Sections skipped at user request: Error Handling, Testing Strategy.
```

Then suggest the next stage:

> "Design review wrapped. Generate tasks with `/opal:tasks`, or run `/opal:build` directly from the design? (`/opal:tasks` is optional — `/opal:build` works directly from `design.md` when there's no `tasks.md`.)"

If playback resulted in any spec edits, those should already be reflected in `design.md` (and `requirements.md` / `tasks.md` if affected) per the change protocol. Note in your closing message which docs were edited.

## Anti-patterns

- **Reading the section verbatim.** Synthesise. The user can already read.
- **Skipping the prompt.** The four-option choice is the whole point — don't slide into the next section without a signal.
- **Combining sections.** One section per loop. Walking three sections then asking a single Understood/Question forces the user to evaluate too much at once.
- **Auto-resolving questions.** Never silently change `design.md` to match the user's view without explicit agreement on the proposed edits.
- **Treating "don't understand" as failure.** It is a signal that the design is unclear, the docs are missing rationale, or the user is new to the area. Treat it as useful information.
- **Forgetting to re-prompt after clarification.** After explaining, the user must still pick one of the four options for the same section. Otherwise you lose the signal.
- **Forking without returning.** After every fork, explicitly hand back to the main track ("OK, returning to the walkthrough — next section is …"). Exception: **Stop** ends the section walk on purpose; jump to the questions prompt instead of returning.
- **Skipping the questions prompt at exit.** Always ask "any questions?" before asking about tasks vs build — even if the user picked Stop. The questions step often surfaces cross-cutting concerns the per-section walk missed.
- **Treating Stop as cancel.** Stop ends the section walk, not the playback session. Still run the questions prompt and write the exit marker.
- **Triggering the change protocol for cosmetic edits.** Adding missing rationale to `design.md` is a clarification edit, not a design change. Save the protocol for actual decisions.

## Quick Template Per Section

```text
**<Section name>.**
<Two to four sentences synthesising what was decided, why, and how. Cite requirement numbers.>

Understood / Question (please say what) / Don't understand (please say which part) / Stop?
```

For trivial sections:

```text
**<Section name>.** <One-line summary.> Moving on.
```

## End-of-flow template

After the section walk (whether reached naturally or via Stop):

```text
That's the end of the section walk.

Any questions before we move on? If not, I'll suggest the next stage.
```

If the user asks a question, answer it, then:

```text
Anything else, or shall we move on?
```

When the user has no more questions:

```text
Design review wrapped. Generate tasks with `/opal:tasks`, or run `/opal:build` directly?
```
