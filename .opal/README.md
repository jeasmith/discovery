# OpalSpec In This Repo

OpalSpec is a lightweight spec-driven development workflow for AI coding agents. This repo carries everything the agent needs under `.opal/`:

```text
.opal/
  specs/<change-name>/   per-change requirements / design / (optional) tasks
  docs/<topic>.md        optional dev guides written after build
  runtime/               protocols and prompts the agent reads (upstream-owned)
  README.md              this file
  VERSION                installed OpalSpec version
```

## The Flow

1. **`/opal:new "<feature-name>" "<description>"`** — agent gathers a kebab-case name and a description (asking for whichever is missing), then asks "Generate a draft requirements doc, or ask questions to clarify direction first?". Branches into define mode (one-shot) or askme mode (`runtime/askme-instructions.md`, interactive).
2. **`/opal:design`** — write `design.md` from approved requirements and current codebase context. After it settles, the agent asks whether to play back, generate tasks, or build directly.
3. **`/opal:preflight`** *(optional, user-invoked)* — run a read-only second-agent review of `design.md` for issues, risks, red flags, missing checks, and key improvements. It does not edit the spec or implement code.
4. **`/opal:playback`** *(optional)* — walk `design.md` section by section with **Understood / Question / Don't understand / Stop**. Questions fork into resolution (and may update the spec via `runtime/change-protocol.md`); confusions fork into clarification; Stop ends the walk early. After the walk the agent asks for any final questions before suggesting the next stage.
5. **`/opal:tasks`** *(optional)* — turn the design into a numbered task plan. Skip it for small/well-scoped work; `/opal:build` works directly from `design.md` when there's no `tasks.md`. Include checkpoint tasks only after cohesive groups of work, with the relevant verification command or check when known.
6. **`/opal:build`** — implement from `tasks.md` if present, else from `design.md`. When present, `tasks.md` is the resume ledger and completed task/checkpoint checkboxes are updated as work progresses. If reality diverges from the spec, follow `runtime/change-protocol.md`. After it finishes, the agent offers `/opal:document`.
7. **`/opal:document <topic>`** *(optional)* — write or update a developer guide at `.opal/docs/<topic>.md`. Multiple specs can update the same topic.

The spec name is optional for any stage after `/opal:new` — when omitted, the agent infers the active spec via the rule in `runtime/spec-authoring-instructions.md`.

## Reliable Codex Usage

Codex does not automatically know what "OpalSpec workflow" means. The prompt must explicitly tell Codex to read the workflow rules before creating or editing spec files.

Use this bootstrap line at the start of every OpalSpec prompt:

```text
First read .opal/runtime/spec-authoring-instructions.md and follow it for this request.
```

For interactive prompts, also read the relevant protocol:

```text
First read .opal/runtime/new-instructions.md, .opal/runtime/askme-instructions.md,
or .opal/runtime/playback-instructions.md (whichever applies).
```

For the most consistent results, also tell Codex which stage it is in and which files it may create or edit. OpalSpec works best when one prompt performs one stage only.

## Slash Commands And Prompt Files

OpalSpec follows the OpenSpec-style pattern of installing tool-specific command files. These are plain instruction files that AI IDEs can expose as slash commands or reusable prompts.

Installed command locations (whatever was selected via `-Tool` at install time):

```text
.claude/commands/opal/{new,design,preflight,playback,tasks,build,document}.md
.cursor/commands/opal-{new,design,preflight,playback,tasks,build,document}.md
.gemini/commands/opal/{new,design,preflight,playback,tasks,build,document}.toml
.github/prompts/opal-{new,design,preflight,playback,tasks,build,document}.prompt.md
```

Claude command names resolve from the directory structure as:

```text
/opal:new <change-name>: <description>
/opal:design [<change-name>]
/opal:preflight [<change-name>]
/opal:playback [<change-name>]
/opal:tasks [<change-name>]
/opal:build [<change-name>]
/opal:document [<topic>]
```

Cursor, Gemini, and GitHub Copilot expose prompt or command files differently by product version, but the files contain the same stage rules and can be invoked from their command/prompt UI.

Claude has an OpalSpec skill at `.claude/skills/opalspec/SKILL.md` for agents that support skill discovery.

Codex uses a different pattern — project skills plus global Codex prompt files:

```text
.codex/skills/opalspec/SKILL.md
.opal/runtime/codex-prompts/opal-{new,design,preflight,playback,tasks,build,document}.md
AGENTS.md
```

Install the Codex prompt files into Codex home using the OpalSpec CLI:

```bash
opalspec install-codex-prompts
```

Or run the platform script directly — `.opal/runtime/scripts/install-codex-prompts.sh` on macOS / Linux, `.opal/runtime/scripts/install-codex-prompts.ps1` on Windows.

There is also an experimental local plugin at `plugins/opalspec/`, but the `.codex/skills` plus Codex home prompts setup is the OpenSpec-aligned path. `AGENTS.md` remains the repo-level fallback for sessions where skills/prompts are not loaded.

## Files In `.opal/runtime/`

- `spec-authoring-instructions.md`: the core rules for creating spec documents, plus the spec inference rule and stage ordering.
- `new-instructions.md`: the protocol for `/opal:new` (gather name + description, then fork between define and askme).
- `askme-instructions.md`: the protocol for the interactive askme-mode authoring of `requirements.md`.
- `preflight-instructions.md`: the protocol for the optional read-only second-agent design review.
- `playback-instructions.md`: the protocol for the optional design playback walkthrough.
- `change-protocol.md`: the stop / report / propose / accept / update / resume loop for when reality diverges from the spec mid-implementation.
- `document-instructions.md`: the protocol for writing dev guides at `.opal/docs/<topic>.md`.
- `templates/{requirements,design,tasks}.md`: document skeletons.
- `prompts/*.prompt.md`: copyable prompts for each stage.
- `codex-prompts/opal-*.md`: the same prompts adapted for `$CODEX_HOME/prompts/`.
- `command-manifest.md`: index of installed slash command files.

## Naming

Use lowercase kebab-case for spec and topic names:

```text
.opal/specs/weather-system-ui/
.opal/specs/openapi-first-workflow/
.opal/docs/auth-flow.md
.opal/docs/data-pipeline.md
```

Use feature specs for planned functionality. For narrow bug fixes, either use the same flow or replace `requirements.md` with a bug-focused defect document following the bugfix rules in `runtime/spec-authoring-instructions.md`.
