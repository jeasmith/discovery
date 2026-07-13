# OpalSpec /opal:document Instructions

`/opal:document` writes a developer-facing guide describing what was built and how it works, in language a developer of any level can follow. The output lives in `.opal/docs/<topic>.md` — a stable, topic-scoped file that **multiple specs can update over time**.

Where `requirements.md`, `design.md`, and `tasks.md` describe a single change in detail for the authoring agent, `.opal/docs/<topic>.md` describes the resulting system for a future reader who has to understand or modify it.

## When To Run

`/opal:document` is **optional** and runs after `/opal:build` finishes. After build completes, the agent should ask:

> Want me to write or update a dev doc for this change with `/opal:document <topic>`?

The user can:

- **Yes, with topic** — proceed with the named topic.
- **Yes, no topic given** — recommend a topic name based on the spec, then confirm.
- **Skip** — end the session.

The user can also invoke `/opal:document` at any other time, including for prior work that was never documented.

## Inputs

```text
/opal:document "<topic>"
```

`<topic>` is a kebab-case label that scopes the doc — e.g. `auth-flow`, `data-pipeline`, `todo-storage`. Multiple specs can target the same topic, and successive runs append to or refine the existing topic doc rather than overwriting it.

If no topic is supplied, the agent should:

1. Look at the active spec (per the spec inference rule in `.opal/runtime/spec-authoring-instructions.md`).
2. Inspect existing `.opal/docs/*.md` files to see whether one of them naturally extends to cover the spec.
3. Recommend either an existing topic or a new one, and confirm with the user before writing.

## What To Read

Before writing, read:

1. `.opal/runtime/spec-authoring-instructions.md` and these instructions.
2. `.opal/specs/<active-spec>/requirements.md`, `design.md`, and `tasks.md` (if present).
3. `.opal/docs/<topic>.md` if it already exists.
4. The relevant implementation files in the codebase, so the doc reflects what is actually shipped, not just what was specced.

## Style And Audience

The reader is a developer who joined the project this week and needs to understand the area without reading the whole codebase. Treat it like a dev guide, not API reference and not marketing copy.

- Write in plain language. Define jargon on first use, then use it freely.
- Lead with **what the area does** and **why it exists**, before any structural detail.
- Use concrete examples — a real input flowing through, a real failure case — instead of abstract descriptions.
- Show file paths and key function/component names so the reader can jump into the code.
- Include "how to extend this" or "common changes" guidance where it applies.
- Keep it skimmable: short sections, active voice, no walls of text.

Things to **avoid**:

- Restating the spec verbatim. Specs are change-scoped; the doc is system-scoped.
- Leaking implementation details that may change. Anchor on stable interfaces and intent.
- Long change-history sections. The doc is current state, not a changelog.

## Required Structure

```markdown
# <Topic title>

## What this is

<One paragraph: what the area does and why it exists.>

## How it fits together

<Short explanation of the moving parts and how they connect. File paths and key names.>

## Key flows

### <Flow 1 name>

<Walk through a concrete example, step by step, with file/function references.>

### <Flow 2 name>

<...>

## Extending or changing this area

<What kinds of changes are easy, what is risky, what to watch out for. Reference correctness properties from related design docs where useful.>

## Related specs

- `.opal/specs/<spec-1>/` — <one-line summary>
- `.opal/specs/<spec-2>/` — <one-line summary>
```

Sections may be added, but `What this is`, `How it fits together`, and at least one `Key flows` entry are required.

## Updating An Existing Topic Doc

When `<topic>.md` already exists:

1. Read it carefully and identify which sections the new spec touches.
2. Update only those sections. Don't rewrite the whole doc.
3. Add the spec to the `Related specs` list.
4. If the new work fundamentally changes how the area works, propose a small restructure to the user before applying it — don't silently rewrite the doc.

If the new spec doesn't really fit the existing topic, recommend a new topic instead of stretching the doc to cover both.

## Convergence and Exit

When the doc is settled:

- Write `.opal/docs/<topic>.md`.
- Tell the user what was added or changed (one-line summary per section touched).
- Append a `> Updated via OpalSpec document on YYYY-MM-DD for spec <active-spec>.` marker to the bottom of the doc, replacing any previous marker.

## Anti-patterns

- **Copy-pasting the spec.** Synthesise; don't re-emit `design.md` paragraphs.
- **Writing for AI agents.** The audience is humans. Avoid agent-procedural prose.
- **Always creating a new topic.** Default to extending an existing topic when one fits.
- **Over-wide topics.** A topic that covers "the whole backend" is useless — split it. A topic that covers a single function is too narrow — fold it in.
- **Skipping the codebase read.** A doc that drifts from shipped code is worse than no doc.
