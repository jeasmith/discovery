#!/usr/bin/env bash
# Install OpalSpec Codex prompts into Codex home on macOS and Linux.
# Mirrors install-codex-prompts.ps1.
#
# Honours $CODEX_HOME when set; otherwise installs to ~/.codex/prompts.

set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../codex-prompts"
TARGET_DIR="$CODEX_HOME/prompts"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Missing OpalSpec Codex prompt source: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

for name in opal-new.md opal-design.md opal-preflight.md opal-playback.md opal-tasks.md opal-build.md opal-document.md; do
  cp -f "$SOURCE_DIR/$name" "$TARGET_DIR/$name"
done

echo "Installed OpalSpec Codex prompts to $TARGET_DIR"
