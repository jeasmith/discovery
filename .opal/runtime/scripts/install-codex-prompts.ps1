param(
  [string]$CodexHome = $env:CODEX_HOME
)

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
  $CodexHome = Join-Path $env:USERPROFILE ".codex"
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$source = Join-Path $repoRoot ".opal\runtime\codex-prompts"
$target = Join-Path $CodexHome "prompts"

if (-not (Test-Path -LiteralPath $source)) {
  throw "Missing OpalSpec Codex prompt source: $source"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -LiteralPath (Join-Path $source "opal-new.md") -Destination (Join-Path $target "opal-new.md") -Force
Copy-Item -LiteralPath (Join-Path $source "opal-design.md") -Destination (Join-Path $target "opal-design.md") -Force
Copy-Item -LiteralPath (Join-Path $source "opal-preflight.md") -Destination (Join-Path $target "opal-preflight.md") -Force
Copy-Item -LiteralPath (Join-Path $source "opal-playback.md") -Destination (Join-Path $target "opal-playback.md") -Force
Copy-Item -LiteralPath (Join-Path $source "opal-tasks.md") -Destination (Join-Path $target "opal-tasks.md") -Force
Copy-Item -LiteralPath (Join-Path $source "opal-build.md") -Destination (Join-Path $target "opal-build.md") -Force
Copy-Item -LiteralPath (Join-Path $source "opal-document.md") -Destination (Join-Path $target "opal-document.md") -Force

Write-Host "Installed OpalSpec Codex prompts to $target"
