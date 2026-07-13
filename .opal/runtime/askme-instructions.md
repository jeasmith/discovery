# OpalSpec AskMe Mode Instructions

AskMe mode is the interactive alternative to default define mode at the requirements stage. Instead of producing `requirements.md` from a single user description, you interview the user until you reach shared understanding, writing the file inline as answers land.

The output is the same `requirements.md` shape define mode produces, following the rules in `.opal/runtime/spec-authoring-instructions.md`. Once asking converges, the user runs `/opal:design` (or the equivalent) and the rest of the OpalSpec pipeline is unchanged.

## When To Enter AskMe Mode

AskMe mode is reached via `/opal:new`. After the agent gathers a feature name and description, it asks the user "Would you like me to generate a draft requirements doc, or ask you questions to clarify direction first?". Picking **ask questions / interview / askme** routes here.

Recommend askme mode (when the user is unsure between modes, or when this protocol is invoked directly) if the user:

- says "let's figure out what to build for <change-name>" or "I'm not sure what I want yet",
- gives a description that is fuzzy, contains contested domain terms, or has obvious unstated constraints,
- asks for help shaping a feature they have not fully thought through.

If the user already has a clear, well-scoped description, recommend define mode instead — asking questions adds friction that pays off only when the design tree has unresolved branches.

## The Protocol

### Ask one question at a time

Never dump a list. Ask the single highest-leverage question, wait for the answer, then pick the next one based on what you just learned.

For each question, **propose your recommended answer** with one short sentence on why. The user can confirm, redirect, or reject. A blank-page question ("what should this do?") wastes the user's time; a question with a recommendation gives them something to react to.

### Walk the design tree depth-first

Resolve dependencies between decisions before broadening. If decision B only matters once A is settled, finish A first. Don't jump to edge cases while the core shape is still fluid.

### Search the codebase before asking

If a question is answerable by reading the code, read the code. Only ask the user when:

- the answer involves intent, priorities, or constraints not visible in the code,
- the codebase contradicts itself and you need a tiebreaker,
- the question is about behaviour the codebase does not yet have.

### Cross-reference statements with the code

When the user states how something works today, verify against the code. If you find a contradiction, surface it immediately:

> "You said cancellations are always full-order, but `OrderService.cancelLine` exists and is called from the admin route — which is right?"

### Sharpen fuzzy language

When the user uses an overloaded or vague term, propose a canonical name and pin it down before continuing:

> "You're saying 'account' — do you mean Customer or User? Those are different in this repo."

If the spec already has a glossary, challenge new terms against it. Conflicts get resolved before they propagate into acceptance criteria.

### Stress-test with concrete scenarios

When relationships or boundaries are being discussed, invent specific edge-case scenarios that force precision:

> "Customer has two open orders, cancels one mid-shipment, then the other ships — does the second order still get the bundled discount that depended on both?"

### Update requirements.md inline

Write to `.opal/specs/<change-name>/requirements.md` as decisions crystallise. Don't batch. The file should grow during the conversation, not appear in one block at the end.

Order of capture:

1. `Introduction` — capture the change's purpose from the seed idea before the first question.
2. `Glossary` — pin domain terms the moment they're resolved.
3. `Requirements` — append numbered requirements with EARS-style acceptance criteria (`WHEN ... THEN ... SHALL ...`, `IF ... THEN ...`) as each user story is settled.
4. `Why` — **leave blank during the interview**. Populate it during convergence (below), once the full picture is in hand.

If the file does not yet exist, create it on the first decision. Use `.opal/runtime/templates/requirements.md` as the structural reference. Don't pre-create scaffolding.

### Convergence and exit

Stop asking when **all** are true:

- Every user story has at least one acceptance criterion.
- Glossary terms used in acceptance criteria are pinned.
- You ask "anything else worth nailing down before design?" and the user has nothing new.

Before exiting, **write the `Why` section** using the full conversation context. This is the highest-value moment to capture motivation: you have just discussed everything the user cares about, and you can synthesise it. Capture:

- What this builds on or depends on (completed work, prior page types, existing infrastructure).
- The gap or pain that exists today without this change.
- Where this sits in the bigger plan (PRD entry, roadmap milestone, blocker for X).

Two to four sentences. Show it to the user and confirm before writing it to disk — this is the one section where their wording matters more than yours.

When you exit, write a one-line note at the top of `requirements.md` (under the heading):

```text
> Authored via OpalSpec askme mode on YYYY-MM-DD.
```

Then suggest the next stage:

> "Requirements look settled. Ready for `/opal:design <change-name>`?"

## Anti-patterns

- **Question dumps.** One at a time, always.
- **Blank-page questions.** Always propose a recommended answer.
- **Asking what the code can answer.** Search first.
- **Letting fuzzy terms pass.** Pin them on first use.
- **Batching writes.** Update `requirements.md` as you go — partial > nothing if the session is abandoned.
- **Drifting into design.** AskMe mode produces requirements only. Architecture, file layout, and interfaces belong in `design.md`.
- **Implementing during asking.** No code changes during this stage.

## Relationship To Define Mode

Both modes are entered via `/opal:new`. After the agent gathers the feature name and description, it asks "generate a draft, or ask questions to clarify direction first?" and routes accordingly.

| | Define mode | AskMe mode |
|---|---|---|
| User picks | "generate" / "draft" | "ask questions" / "askme" |
| Input | Full description | One-line description (or seed) |
| Interaction | One-shot | Iterative interview |
| Output | `requirements.md` | `requirements.md` (same shape) |
| `Why` quality | Whatever the description supports | Rich — written at convergence with full context |
| Best for | Clear, well-scoped features | Fuzzy ideas, contested terminology, unfamiliar domain |

Both modes produce the same artefact. The pipeline downstream of requirements does not care which mode authored it.
