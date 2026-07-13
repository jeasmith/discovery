# Implementation Plan: Private Archive Organizer

## Overview

Build order follows the pipeline's dependency chain: project scaffold → domain types and persistence → folder access → deterministic pipeline stages (scan, hash, duplicates, extraction) → model services → naming → execution/journal/rollback → review queue and UI → degraded mode and diagnostics → test hardening. Every stage lands with its tests; checkpoints run the same commands CI runs (`xcodebuild … -project Discovery.xcodeproj -scheme Discovery`). Filesystem-mutating code (Milestone 8) must not be started before its journal models (Milestone 2) and hash service (Milestone 4) are merged.

## Tasks

- [ ] 0. Toolchain and CI reality check
  - [ ] 0.1 Verify the local toolchain can build a macOS 26 target (`xcodebuild -showsdks`, `swift --version`); record versions in the task ledger
    - _Requirements: 14.3_
  - [ ] 0.2 Push a trivial branch build to CI and check whether `macos-latest` carries the macOS 26 SDK; if not, apply the design's CI contingency (pin an Xcode version step if one exists, else document local `xcodebuild test` as the interim gate and mark CI expected-red in `ci.yml` comments) — never lower the deployment target to make CI pass
    - _Requirements: 14.3_

- [ ] 1. Project scaffold
  - [ ] 1.1 **Update the existing committed `Discovery.xcodeproj`** (template project, Swift 5.0 mode, `MACOSX_DEPLOYMENT_TARGET = 26.5`, no shared scheme): set Swift 6 language mode with strict concurrency, keep the 26.5 deployment target, confirm targets `Discovery`, `DiscoveryTests` (Swift Testing), `DiscoveryUITests` (XCUITest) match `.github/workflows/ci.yml`, and check in a shared `Discovery` scheme under `Discovery.xcodeproj/xcshareddata/xcschemes/` (CI fails without it)
    - Keep `Discovery/DiscoveryApp.swift` as `@main`; replace template `ContentView.swift` with placeholder `MainWindow`
    - _Requirements: 14.3_
  - [ ] 1.2 Add `Discovery/Entitlements/Discovery.entitlements`: `com.apple.security.app-sandbox = true`, `com.apple.security.files.user-selected.read-write = true`, `com.apple.security.files.bookmarks.app-scope = true`; verify NO `com.apple.security.network.*` key; wire into build settings
    - _Requirements: 1.1, 1.3, 11.3, 11.4_
  - [ ] 1.3 Add ZIPFoundation via SPM pinned to an exact version (used only by `OfficeExtractor` and `FixtureFactory`)
    - _Requirements: 4.3_
  - [ ] 1.4 Add `Discovery/Config/Taxonomy.json` with the five fixed categories and folder names per design Decision/Data Models, plus `TaxonomyConfig` decoding in `Discovery/Domain/Types.swift`
    - _Requirements: 15.1, 15.2, 15.3, 15.4_
  - [ ] 1.5 Checkpoint: `xcodebuild build -project Discovery.xcodeproj -scheme Discovery -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO` succeeds; a first unit test parses the entitlements file and asserts sandbox-on / no-network (Property 10)
    - _Requirements: 11.4_

- [ ] 2. Domain types and persistence
  - [ ] 2.1 Implement `Discovery/Domain/Types.swift`: `Category`, `DocumentStatus`, `SupportKind`, error enums — exactly the cases named in design
    - _Requirements: 2.2, 5.1_
  - [ ] 2.2 Implement `Discovery/Persistence/Models.swift` (SwiftData): `ArchiveRootRecord`, `InventoryRecord`, `NearDuplicatePair`, `ProposedAction`, `JournalEntry`, `ReviewItem` with all fields from design Data Models
    - _Requirements: 2.1, 3.2, 7.5, 8.4, 13.1_
  - [ ] 2.3 Implement `Discovery/Persistence/Store.swift`: ModelContainer in Application Support inside the sandbox container; helper queries by status (pull-based pipeline)
    - _Requirements: 1.6, 8.4_

- [ ] 3. Least-privilege folder access
  - [ ] 3.1 Implement `Discovery/Domain/ArchiveAccess.swift`: `ArchiveRoot` Sendable snapshot struct + `ArchiveAccessManager` with `selectRoot()` (NSOpenPanel → bookmark persisted to the single `ArchiveRootRecord`, replace-after-confirmation), `resolveRoot()` marking failure unavailable, `removeRoot()`, and the **async** `withAccess` overload as the primary API (scoped access must span awaited I/O — see design)
    - _Requirements: 1.1, 1.2, 1.4, 1.5_
  - [ ] 3.2 Implement `Discovery/UI/OnboardingView.swift`: select the single Archive Root (destination category folders + `_Quarantine` live under it), re-selection prompt for unresolvable bookmarks
    - _Requirements: 1.4, 15.2_

- [ ] 4. Inventory
  - [ ] 4.1 Implement `Discovery/Domain/HashService.swift`: streaming SHA-256 (CryptoKit) over file handles; unit tests with known vectors
    - _Requirements: 2.1_
  - [ ] 4.2 Implement `Discovery/Domain/InventoryScanner.swift` (actor): enumerate roots, upsert-by-path, hash-diff resets downstream statuses, `supported`/`unsupported`/`unreadable` marking via UTType; never writes under roots
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
  - [ ] 4.3 Integration tests in `DiscoveryTests/InventoryScannerTests.swift` over temp-dir trees: read-only guarantee (snapshot mtimes/bytes before/after), re-scan stability, content-change reset (Property 9)
    - _Requirements: 2.4, 2.5, 2.6_

- [ ] 5. Duplicate detection
  - [ ] 5.1 Implement `Discovery/Domain/DuplicateDetector.swift`: exact groups by Content Hash; near-duplicates via Jaccard ≥ 0.70 over 4-char shingles of normalized text and 64-bit dHash ≤ 10 for image-bearing docs; exclusion of exact-dup pairs; deletion-candidate nomination (all but one per exact group)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  - [ ] 5.2 Persist `NearDuplicatePair` keyed by unordered hash pair with `dismissed` suppression surviving re-scan; eligibility reset on hash change
    - _Requirements: 13.3_
  - [ ] 5.3 Unit tests: determinism (same input twice → identical output), exact-dup exclusion, fixture-pair flagging, dismissal stickiness (Properties 4, 12)
    - _Requirements: 3.2, 3.3, 3.4, 13.3_

- [ ] 6. Extraction
  - [ ] 6.1 Implement `Discovery/Domain/Extraction/PDFExtractor.swift`: PDFKit **per-page** text-layer extraction — a page "has a text layer" iff that page's extraction alone is not an Insufficient Extraction (< 25 non-whitespace chars); pages failing the bar are handed to OCR and results merge in page order (hybrid PDFs must not silently drop scanned pages)
    - _Requirements: 4.1, 4.2, 4.5_
  - [ ] 6.2 Implement `Discovery/Domain/Extraction/OCRExtractor.swift`: Vision `RecognizeTextRequest` (accurate) on images and on 300-DPI renders of text-layer-less PDF pages — verify exact Vision API names against the macOS 26 SDK before writing code
    - _Requirements: 4.2, 4.4_
  - [ ] 6.3 Implement `Discovery/Domain/Extraction/OfficeExtractor.swift`: DOCX via `NSAttributedString(.officeOpenXML)`, RTF/TXT/CSV via AppKit/Foundation, XLSX via ZIPFoundation + XMLParser (sharedStrings + sheet cells)
    - _Requirements: 4.3_
  - [ ] 6.4 Implement `Discovery/Domain/Extraction/ExtractionEngine.swift` (actor): dispatch by SupportKind, apply Insufficient Extraction rule, set `extracted`/`extractionFailed`, create ReviewItems
    - _Requirements: 4.5, 13.1_
  - [ ] 6.5 Checkpoint: `xcodebuild test -project Discovery.xcodeproj -scheme Discovery -destination 'platform=macOS' -only-testing:DiscoveryTests CODE_SIGNING_ALLOWED=NO` green — includes extraction tests across all fixture types and the insufficient/failed routing boundary (Property 6)
    - _Requirements: 4.1, 4.2, 4.3, 4.5_

- [ ] 7. Model services (Foundation Models)
  - [ ] 7.1 Implement `Discovery/Domain/ModelServices/ModelAvailability.swift` wrapping `SystemLanguageModel.default.availability` with a reason surface for the UI; re-check on app-foreground and before every model call — verify exact Foundation Models API names against the macOS 26 SDK before writing code
    - _Requirements: 12.1_
  - [ ] 7.2 Implement `Discovery/Domain/ModelServices/ClassificationService.swift`: `GenerableCategory` enum and `@Generable CategoryRecommendation` exactly as declared in design (mapping rule: `.unknown` → `recommendedCategory = nil` → Review Queue; other cases → `Category(rawValue:)`), 2,000-char input cap, threshold routing (default 0.7, settings-backed), one retry at half cap on model error
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  - [ ] 7.3 Implement `Discovery/Domain/ModelServices/SummarisationService.swift`: 3,000-char input cap, deterministic sentence-boundary truncation to ≤ 500 chars before storing; trigger on threshold-passing recommendation or user override; `summaryPending` when model unavailable
    - _Requirements: 9.1, 9.2, 9.3_
  - [ ] 7.4 Tests: routing/threshold/truncation logic with a mocked model protocol (runs on CI); live-model tests gated `@Test(.enabled(if: ModelAvailability.isAvailable))` (Properties 7, 11)
    - _Requirements: 5.4, 9.1_

- [ ] 8. Naming, proposals, execution, rollback
  - [ ] 8.1 Implement `Discovery/Domain/NamingEngine.swift`: `YYYY-MM-DD_<Category>_<IssuerSlug>.<ext>` pure proposer + validator (charset `[A-Za-z0-9-_.]`, ≤ 80 chars before extension, uniqueness, `_2`/`_3` suffixing, `.gap` on missing fields)
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  - [ ] 8.2 Implement ProposedAction drafting, both sources: (a) rename/move — category (override wins; only needs the `overriddenCategory` field from Milestone 2, not the Milestone-9 UI) → destination folder from Taxonomy → validated name → `awaitingApproval`; never drafted from below-threshold/unknown recommendations; (b) quarantine — Exact Duplicate nominations construct `_Quarantine/<original-filename>` actions directly, bypassing NamingEngine
    - _Requirements: 3.6, 5.5, 6.1, 10.1, 13.2_
  - [ ] 8.3 Implement `Discovery/Domain/Execution/OperationExecutor.swift` (actor): write-ahead `pending` JournalEntry → pre-move hash verify → move (never overwrite; abort if destination exists) → post-move hash verify → `committed`/`failed`; per-action isolation within batches; quarantine moves to `_Quarantine` use the same path
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 10.2, 10.4_
  - [ ] 8.4 Implement rollback in `OperationExecutor` + `Discovery/Domain/Execution/JournalReconciler.swift`: batch rollback with hash verification, skip-and-report on mismatch; launch-time reconciliation of `pending` entries → `interrupted` + ReviewItems
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 13.1_
  - [ ] 8.5 Integration tests over temp dirs: Properties 1, 2, 3, 8 (hash round-trip, no-overwrite, rollback restore + tamper-skip, write confinement via directory snapshot diff); crash simulation by aborting between WAL states; concurrency-race test driving multiple pipeline actors against the shared store simultaneously
    - _Requirements: 7.2, 7.3, 7.4, 8.1, 8.2, 8.3, 1.6_
  - [ ]* 8.6 Property-style randomized tests for NamingEngine over generated (date, category, issuer, existing-set) inputs, seeded and reported (Property 5)
    - _Requirements: 6.1, 6.2, 6.3_
  - [ ] 8.7 Checkpoint: full unit suite green — `xcodebuild test … -only-testing:DiscoveryTests`; this closes the deterministic pipeline
    - _Requirements: 7.1–8.4_

- [ ] 9. Review Queue, approval UI, journal UI
  - [ ] 9.1 Implement `Discovery/UI/ReviewQueueView.swift`: all six reason types with evidence (proposed category, confidence, text snippet, QuickLook preview where available); category assign/override resumes naming+proposal; near-duplicate dismiss
    - _Requirements: 13.1, 13.2, 13.3_
  - [ ] 9.2 Implement `Discovery/UI/ProposedActionsView.swift`: batch review with per-action checkboxes, explicit Approve action invoking the executor; deletion candidates presented with reason and quarantine explanation
    - _Requirements: 7.1, 10.1, 10.2, 10.3, 13.4_
  - [ ] 9.3 Implement `Discovery/UI/JournalView.swift` (history + rollback triggers), `DocumentsView.swift`, `DuplicatesView.swift`, `MainWindow.swift` navigation, `SettingsView.swift` (review threshold, insufficient-extraction threshold)
    - _Requirements: 8.5, 5.4_
  - [ ] 9.4 UI smoke tests in `DiscoveryUITests/SmokeTests.swift`: launch, onboarding, Review Queue and Journal render with seeded store — keep runnable headless on CI
    - _Requirements: 14.2_

- [ ] 10. Degraded mode and diagnostics
  - [ ] 10.1 Wire Degraded Mode: model stages stop pulling when unavailable; status banner with reason; `classificationPending`/`summaryPending` set; resume prompt on availability return (user confirms; pending-only)
    - _Requirements: 12.1, 12.2, 12.3, 12.4_
  - [ ] 10.2 Implement `DiagnosticsExporter` from a projection struct containing only statuses, error codes, timestamps, counts, Content Hashes; test asserts export schema has no path/filename/text/summary keys
    - _Requirements: 11.5_
  - [ ] 10.3 Degraded-mode tests with mocked availability: deterministic capabilities all function; no model calls attempted (Property: 12.2/12.3)
    - _Requirements: 12.2, 12.3_

- [ ] 11. Fixtures and final verification
  - [ ] 11.1 Implement `DiscoveryTests/Fixtures/FixtureFactory.swift`: deterministic synthetic text PDF, scanned PDF (image-only), **hybrid PDF (one text page + one image-only page, asserting per-page OCR merge)**, PNG/JPEG/HEIC, DOCX/XLSX/RTF/TXT/CSV, near-duplicate variants, edge cases (0-byte, 10-char, unreadable, unsupported) — generated at test time, nothing checked in
    - _Requirements: 14.1, 14.2, 14.3_
  - [ ] 11.2 Repo-hygiene test: assert no binary document files exist under the repository's test directories
    - _Requirements: 14.1_
  - [ ] 11.3 Final checkpoint: full CI parity locally — build, `DiscoveryTests`, `DiscoveryUITests` all green with the exact `ci.yml` commands; manually verify on eligible hardware: onboard → scan fixtures folder → classify → approve batch → rollback batch → quarantine a duplicate
    - _Requirements: all_

## Notes

- **Dependency spine**: 0 → 1 → 2 → {3, 4} → 5 → 6 → {7, 8} → 9 → 10 → 11. Tasks 7 and 8 are independent of each other; everything UI (9) needs 8's executor.
- **Concurrency contract**: never pass SwiftData `@Model` instances across actors — use `PersistentIdentifier`s or the Sendable snapshot structs from design (e.g. `ArchiveRoot`); each pipeline actor is a `@ModelActor` with its own `ModelContext`. Security-scoped access must use the async `withAccess` overload so the scope spans the awaited I/O.
- **Filename charsets**: `[A-Za-z0-9-]` applies to the issuer slug component; the assembled-filename validator accepts `[A-Za-z0-9-_.]` (separators + extension dot). Not a contradiction — different scopes.
- **For Sonnet-class implementing agents**: the design doc (`design.md`) contains the exact interfaces, thresholds, naming convention, journal state machine, and data models — implement to those signatures. Where the design flags "verify against the macOS 26 SDK" (Foundation Models, Vision), read the SDK/docs first and adapt names only, not semantics. Never substitute a network or third-party model under any circumstance (Requirements 11, 12.3).
- **Model-gated tests**: anything needing the live model must skip cleanly when `SystemLanguageModel` is unavailable — CI runners have no Apple Intelligence. All routing logic is testable via the mocked model protocol.
- **tasks.md is the resume ledger**: update checkboxes immediately as tasks complete; leave a task unchecked if work stops midway.
- **MVP shortcut permitted**: HEIC fixture generation may fall back to PNG re-encoded via ImageIO if HEIC encoding is unavailable on the CI runner; note it in the test.
