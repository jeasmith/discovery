# OpalSpec /opal:new Instructions

`/opal:new` is the unified entry point for starting a new spec. It gathers a feature name and description, then asks the user which authoring style they want.

## Inputs

```text
/opal:new "<feature-name>" "<description of what to build>"
```

Both arguments are optional. The agent must end this stage with a feature name (kebab-case) and a description in hand before proceeding.

## Step 1 — Resolve the feature name and description

1. **Description present, name present** → use both as supplied; if the name is not kebab-case, normalise it (`Per User Rate Limits` → `per-user-rate-limits`) and confirm.
2. **Description present, name missing** → infer the name from the description. Pick the shortest kebab-case label that captures the change (e.g. "I want to add per-user rate limits to the API" → `per-user-rate-limits`). Confirm with the user before continuing: "I'll call this `<name>`. OK, or want a different name?".
3. **Description missing** → ask: "What are we building?". Wait for an answer. Then re-enter step 1 or 2 with the result.
4. **Both missing** → ask for the description first. Don't ask for the name as a separate question if the description will let you infer it.

If a spec folder with the resolved name already exists at `.opal/specs/<feature-name>/`, surface that and ask whether to use a new name, extend the existing spec, or replace it.

## Step 2 — Pick an authoring style

Once the name and description are settled, ask the user this exact question:

> Would you like me to generate a draft requirements doc, or ask you questions to clarify direction first?

The two answers route to two different protocols:

- **Generate / draft / write it / one-shot** → Define mode. Use the rules in `.opal/runtime/spec-authoring-instructions.md` to write `.opal/specs/<feature-name>/requirements.md` in one pass from the description.
- **Ask me questions / clarify / interview / askme** → AskMe mode. Use the rules in `.opal/runtime/askme-instructions.md`. Capture the description into the `Introduction` of `requirements.md`, then interview the user one question at a time, writing the file inline as decisions land.

If the user is unsure, recommend **define** when the description sounds clear and well-scoped, and **askme** when the description is fuzzy, the domain language is contested, or there are obvious unstated constraints. Recommend, then let them pick.

## Step 3 — Author requirements

Run the chosen protocol. Both modes produce the same `requirements.md` shape (Introduction, Why, Glossary, numbered Requirements with EARS acceptance criteria).

The `Why` section captures the business / product motivation: what this builds on, the gap it closes, where it sits in the bigger plan. It is best populated with full context:

- **AskMe mode**: leave `Why` blank during the interview. At convergence (after all questions are answered) write it from the accumulated context, and confirm the wording with the user before saving. See `askme-instructions.md`.
- **Define mode**: write the best `Why` the description supports. If the description is sparse on motivation, leave a one-line placeholder and tell the user they can rerun in askme mode for richer context.

If askme mode is chosen, end with the `> Authored via OpalSpec askme mode on YYYY-MM-DD.` marker and the standard convergence prompt from `askme-instructions.md`.

If define mode is chosen, no marker is needed.

## Step 4 — Suggest the next stage

Once `requirements.md` exists and the user is happy:

> Ready for `/opal:design`?

## Anti-patterns

- **Asking for the name when the description makes it obvious.** Infer and confirm; don't make the user repeat themselves.
- **Skipping the style question.** The fork point between define and askme is the whole reason `/opal:new` exists. Always ask.
- **Mixing the two modes.** Once the user picks define, write the doc in one pass; once they pick askme, never dump the full spec preemptively.
- **Starting work before the name is settled.** Don't write to disk until you have a confirmed kebab-case name. The folder path depends on it.
- **Treating "I'll think about it" as `Stop`.** If the user is unsure between define and askme, restate the recommendation; don't pick silently.
