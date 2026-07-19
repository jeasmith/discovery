# Implementation Plan: Private Archive Organizer

## Overview

Build order follows the pipeline's dependency chain: project scaffold → domain types and persistence → folder access → deterministic pipeline stages (scan, hash, duplicates, extraction and visual evidence) → Processing Policy and Apple Model Router → naming → execution/journal/rollback → review queue and UI → degraded mode and diagnostics → test hardening. The macOS 26.5 Local Only path is the stable baseline; macOS 27 multimodal and PCC work is availability-gated and uses the same typed proposal boundary. Every stage lands with tests. Filesystem-mutating code (Milestone 8) must not start before its journal models (Milestone 2) and hash service (Milestone 4) are merged.

## Tasks

- [ ] 0. Toolchain and CI reality check
  - [ ] 0.1 Verify the local toolchain can build the macOS 26.5 baseline and record Xcode/Swift/SDK versions; separately record whether Xcode 27 beta and a macOS 27 test environment are installed
    - _Requirements: 14.3, 16.6_
  - [ ] 0.2 Confirm Apple Developer Program and App Store Small Business Program eligibility, request the Private Cloud Compute entitlement, and record the entitlement/application status without blocking Local Only work
    - _Requirements: 16.5, 16.6_
  - [ ] 0.3 Keep CI's stable gate on the macOS 26.5 Local Only build; add or document a conditional Xcode 27 job when a suitable runner exists, with no live PCC calls in hosted CI
    - _Requirements: 14.3, 14.4, 16.6_

- [ ] 1. Project scaffold
  - [ ] 1.1 **Update the existing committed `Discovery.xcodeproj`** (template project, Swift 5.0 mode, `MACOSX_DEPLOYMENT_TARGET = 26.5`, no shared scheme): set Swift 6 language mode with strict concurrency, keep the 26.5 deployment target, confirm targets `Discovery`, `DiscoveryTests` (Swift Testing), `DiscoveryUITests` (XCUITest) match `.github/workflows/ci.yml`, and check in a shared `Discovery` scheme under `Discovery.xcodeproj/xcshareddata/xcschemes/` (CI fails without it)
    - Keep `Discovery/DiscoveryApp.swift` as `@main`; replace template `ContentView.swift` with placeholder `MainWindow`
    - _Requirements: 14.3_
  - [ ] 1.2 Add `Discovery/Entitlements/Discovery.entitlements`: App Sandbox, user-selected read/write, and app-scoped bookmarks. Add the Apple PCC capability only to the eligible macOS 27 configuration after verifying its exact SDK entitlement; do not add provider SDKs, API keys, analytics, or an arbitrary HTTP client. Verify whether a generic sandbox network-client entitlement is required by PCC's system service before changing it
    - _Requirements: 1.1, 1.3, 11.1, 11.4, 16.6_
  - [ ] 1.3 Add ZIPFoundation via SPM pinned to an exact version (used only by `OfficeExtractor` and `FixtureFactory`)
    - _Requirements: 4.3_
  - [ ] 1.4 Add `Discovery/Config/Taxonomy.json` with the five fixed categories and folder names per design Decision/Data Models, plus `TaxonomyConfig` decoding in `Discovery/Domain/Types.swift`
    - _Requirements: 15.1, 15.2, 15.3, 15.4_
  - [ ] 1.5 Checkpoint: the macOS 26.5 Local Only build succeeds; static tests assert sandbox/folder scope and the absence of third-party provider or analytics capability. The optional macOS 27 configuration either builds with the assigned PCC capability or clearly reports that the capability is unavailable
    - _Requirements: 11.1, 11.4, 16.6_

- [ ] 2. Domain types and persistence
  - [ ] 2.1 Implement `Discovery/Domain/Types.swift`: `Category`, `DocumentStatus`, `SupportKind`, `ProcessingPolicy`, `ModelExecutionTier`, visual-evidence and error enums exactly as named in design
    - _Requirements: 2.2, 4.7, 5.1, 16.1_
  - [ ] 2.2 Implement `Discovery/Persistence/Models.swift` (SwiftData): `ArchiveRootRecord`, `InventoryRecord` including content-free model provenance, `NearDuplicatePair`, `ProposedAction`, `JournalEntry`, `ReviewItem`, and locally persisted PCC consent version/timestamp
    - _Requirements: 2.1, 3.2, 5.5, 7.5, 8.4, 9.4, 13.1, 16.2, 16.4_
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
  - [ ] 6.2 Implement `Discovery/Domain/Extraction/OCRExtractor.swift`: on-device Vision text recognition on images and 300-DPI renders of sparse PDF pages; verify exact API names against the installed macOS 26 SDK
    - _Requirements: 4.2, 4.5_
  - [ ] 6.3 Implement `Discovery/Domain/Extraction/VisualEvidenceExtractor.swift`: applicable local barcode/MRZ recognition, generic image classification as advisory labels, bounded ephemeral `PreparedImage` generation, and payload minimisation/redaction
    - _Requirements: 4.3, 4.5, 4.6, 4.7, 4.9_
  - [ ] 6.4 Implement `Discovery/Domain/Extraction/OfficeExtractor.swift`: DOCX via `NSAttributedString(.officeOpenXML)`, RTF/TXT/CSV via AppKit/Foundation, XLSX via ZIPFoundation + XMLParser
    - _Requirements: 4.4_
  - [ ] 6.5 Implement `ExtractionEngine` outcomes `.text`, `.visualOnly`, and `.failed`; preserve evidence provenance, never invent text, and route text-free files to the Model Router only on supported macOS 27 paths or otherwise to Review Queue
    - _Requirements: 4.7, 4.8, 13.1_
  - [ ] 6.6 Checkpoint: extraction tests cover text, scanned/hybrid PDFs, fake barcodes, text-free ordinary photos, and image-only documents; assert that Vision labels alone do not create a category proposal (Properties 6 and 13)
    - _Requirements: 4.1–4.9, 14.2_

- [ ] 7. Apple model services and Processing Policy
  - [ ] 7.1 Implement `ProcessingPolicy.swift`: default `.localOnly`; persist versioned, revocable PCC consent and expose active policy as observable state
    - _Requirements: 5.3, 11.5, 11.6, 16.1, 16.2, 16.7_
  - [ ] 7.2 Implement `ModelAvailability.swift`: on-device availability for macOS 26+ and, under `@available(macOS 27.0, *)`, PCC capability, entitlement, network, regional availability, and quota snapshots; re-check before calls and on app foreground
    - _Requirements: 12.1, 12.5, 16.5, 16.6_
  - [ ] 7.3 Implement `ModelRouter.swift`: on-device-first deterministic routing using Processing Policy, reported context size, modality, retryable capability failures, and explicit PCC retry; construct `PrivateCloudComputeLanguageModel` only when policy and availability pass
    - _Requirements: 5.2, 5.3, 5.4, 11.2, 11.3, 16.3, 16.5_
  - [ ] 7.4 Implement bounded `SemanticRequest` selection: minimise text/image evidence, reserve output headroom, target at most 75% of chosen model context, and never read the accumulated summary database into PCC requests
    - _Requirements: 9.2, 11.3, 11.7_
  - [ ] 7.5 Implement `ClassificationService.swift` with guided generation, fixed taxonomy + unknown, threshold routing, multimodal input on macOS 27, and a content-free `ModelExecutionRecord`
    - _Requirements: 5.1, 5.5, 5.6, 5.7, 5.8, 16.4_
  - [ ] 7.6 Implement `SummarisationService.swift`: router-selected Approved Apple Model, deterministic ≤500-character local result, local-only storage, and provenance
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  - [ ] 7.7 Unit tests with mock adapters: complete policy/routing matrix, no PCC construction under Local Only, local fallback on PCC quota exhaustion, text-free handling, dynamic context budgets, provenance redaction, and policy change while requests are queued (Properties 7, 10, 13, 14)
    - _Requirements: 5.3–5.8, 11.2–11.8, 12.5, 16.1–16.7_
  - [ ]* 7.8 Live synthetic verification on eligible hardware: macOS 26 on-device text, macOS 27 on-device multimodal, and PCC text/image requests with quota states; never use real archive files
    - _Requirements: 4.8, 14.4, 16.5_

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
  - [ ] 9.3 Implement `JournalView.swift`, `DocumentsView.swift`, `DuplicatesView.swift`, `MainWindow.swift`, and `SettingsView.swift`: review/extraction thresholds, Local Only vs Apple Private Cloud Allowed control, first-enable disclosure/consent, current availability/quota state, disable control, and per-result execution-tier badges
    - _Requirements: 5.6, 8.5, 11.5, 11.6, 12.1, 16.1–16.7_
  - [ ] 9.4 UI smoke tests in `DiscoveryUITests/SmokeTests.swift`: launch, onboarding, Review Queue and Journal render with seeded store — keep runnable headless on CI
    - _Requirements: 14.2_

- [ ] 10. Degraded mode and diagnostics
  - [ ] 10.1 Wire Degraded Mode across both Apple tiers: persistent reason banner; pending flags; local fallback when PCC alone is unavailable; user-confirmed resume for pending-only work under the current policy
    - _Requirements: 12.1–12.5_
  - [ ] 10.2 Implement `DiagnosticsExporter` from a content-free projection containing statuses, error codes, timestamps, counts, Content Hashes, and Model Execution Records; exclude paths, names, text, images, Visual Evidence, barcode payloads, and summaries
    - _Requirements: 11.8, 16.4_
  - [ ] 10.3 Tests: no Approved Apple Model, PCC-only outage, quota exhausted, policy revoked mid-queue, and on-device recovery; deterministic capabilities remain available and no third-party call path exists
    - _Requirements: 12.1–12.5, 16.5, 16.7_

- [ ] 11. Fixtures and final verification
  - [ ] 11.1 Implement `FixtureFactory.swift`: deterministic text/scanned/hybrid PDFs, PNG/JPEG/HEIC, office formats, near-duplicates, text-free photo, image-only synthetic document with no usable OCR text, fake barcode/MRZ, and edge cases — generated at test time, nothing checked in
    - _Requirements: 14.1, 14.2, 14.3, 14.4_
  - [ ] 11.2 Repo-hygiene test: assert no binary document files exist under the repository's test directories
    - _Requirements: 14.1_
  - [ ] 11.3 Final checkpoint: stable Local Only CI parity plus conditional macOS 27 build; manually verify with synthetic fixtures: local text classification, local multimodal image classification, explicit PCC enablement and disclosure, PCC provenance, quota/unavailable fallback, approve/rollback batch, and duplicate quarantine
    - _Requirements: all_

## Notes

- **Dependency spine**: 0 → 1 → 2 → {3, 4} → 5 → 6 → {7, 8} → 9 → 10 → 11. Tasks 7 and 8 are independent of each other; everything UI (9) needs 8's executor.
- **Concurrency contract**: never pass SwiftData `@Model` instances across actors — use `PersistentIdentifier`s or the Sendable snapshot structs from design (e.g. `ArchiveRoot`); each pipeline actor is a `@ModelActor` with its own `ModelContext`. Security-scoped access must use the async `withAccess` overload so the scope spans the awaited I/O.
- **Filename charsets**: `[A-Za-z0-9-]` applies to the issuer slug component; the assembled-filename validator accepts `[A-Za-z0-9-_.]` (separators + extension dot). Not a contradiction — different scopes.
- **For implementing agents**: verify macOS 26 and beta macOS 27 Foundation Models/Vision API names, entitlement requirements, availability annotations, and sandbox behaviour against the installed SDK. Adapt names only; preserve Processing Policy semantics. PCC is allowed only through `PrivateCloudComputeLanguageModel`; never substitute a third-party model.
- **Model-gated tests**: live on-device and PCC tests skip cleanly when unavailable and use Synthetic Fixtures only. Hosted CI uses mocked adapters and must not make PCC requests.
- **tasks.md is the resume ledger**: update checkboxes immediately as tasks complete; leave a task unchecked if work stops midway.
- **MVP shortcut permitted**: HEIC fixture generation may fall back to PNG re-encoded via ImageIO if HEIC encoding is unavailable on the CI runner; note it in the test.
