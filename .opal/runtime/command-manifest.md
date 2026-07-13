# OpalSpec Command Manifest

This repo installs OpalSpec commands in the same style as OpenSpec: each supported AI tool gets its own command or prompt files. Tools to install are picked at install time via `-Tool`.

## Commands

| Stage | Claude | Cursor | Gemini | GitHub Copilot |
|-------|--------|--------|--------|----------------|
| New | `/opal:new` | `opal-new` | `opal/new` | `opal-new.prompt.md` |
| Design | `/opal:design` | `opal-design` | `opal/design` | `opal-design.prompt.md` |
| Preflight (optional) | `/opal:preflight` | `opal-preflight` | `opal/preflight` | `opal-preflight.prompt.md` |
| Playback (optional) | `/opal:playback` | `opal-playback` | `opal/playback` | `opal-playback.prompt.md` |
| Tasks (optional) | `/opal:tasks` | `opal-tasks` | `opal/tasks` | `opal-tasks.prompt.md` |
| Build | `/opal:build` | `opal-build` | `opal/build` | `opal-build.prompt.md` |
| Document (optional) | `/opal:document` | `opal-document` | `opal/document` | `opal-document.prompt.md` |

The `new` wrappers read `.opal/runtime/new-instructions.md`, `.opal/runtime/askme-instructions.md`, and `.opal/runtime/spec-authoring-instructions.md`. The `preflight` wrappers read `.opal/runtime/preflight-instructions.md`. The `playback` wrappers read `.opal/runtime/playback-instructions.md` and `.opal/runtime/change-protocol.md`. The `build` wrappers read `.opal/runtime/change-protocol.md` and (when offering a follow-up doc) `.opal/runtime/document-instructions.md`. The `document` wrappers read `.opal/runtime/document-instructions.md`. All wrappers read `.opal/runtime/spec-authoring-instructions.md`.

For all stages after `/opal:new`, the spec name argument is optional — when omitted, the agent infers the active spec via the rule in `.opal/runtime/spec-authoring-instructions.md`.

## Codex

Codex does not consume the Claude `.claude/commands` slash-command files directly. OpenSpec's documented Codex pattern is:

```text
.codex/skills/<skill-name>/SKILL.md
$CODEX_HOME/prompts/<prompt-name>.md
```

OpalSpec mirrors that pattern:

```text
.codex/skills/opalspec/SKILL.md
.opal/runtime/codex-prompts/opal-new.md
.opal/runtime/codex-prompts/opal-design.md
.opal/runtime/codex-prompts/opal-preflight.md
.opal/runtime/codex-prompts/opal-playback.md
.opal/runtime/codex-prompts/opal-tasks.md
.opal/runtime/codex-prompts/opal-build.md
.opal/runtime/codex-prompts/opal-document.md
```

The prompt files are source-controlled under `.opal/runtime/codex-prompts/`. Install them into Codex home using the OpalSpec CLI:

```bash
opalspec install-codex-prompts
```

Or run the platform script directly — `.opal/runtime/scripts/install-codex-prompts.sh` on macOS / Linux, `.opal/runtime/scripts/install-codex-prompts.ps1` on Windows. Either route copies them to `$CODEX_HOME/prompts/` when `CODEX_HOME` is set, otherwise to `~/.codex/prompts/`.

The repo also contains an experimental local plugin at `plugins/opalspec/`, but the `.codex/skills` plus `$CODEX_HOME/prompts` layout is the OpenSpec-aligned Codex path.

## Installed Files

```text
.claude/commands/opal/
.claude/skills/opalspec/
.cursor/commands/
.gemini/commands/opal/
.github/prompts/
.codex/skills/opalspec/
.opal/runtime/codex-prompts/
.opal/runtime/scripts/install-codex-prompts.sh
.opal/runtime/scripts/install-codex-prompts.ps1
plugins/opalspec/
.agents/plugins/marketplace.json
```

Which of these land in a target repo depends on the `-Tool` values passed to `install.ps1`.
