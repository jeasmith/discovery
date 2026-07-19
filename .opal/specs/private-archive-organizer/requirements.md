# Requirements Document

## Introduction

Private Archive Organizer is a native macOS application that organises a personal archive of highly sensitive documents — bank and credit-card statements, payslips, hospital letters, passport and identity scans — with local extraction and an Apple-only semantic-processing boundary. It inventories a user-selected archive folder, detects exact and possible near-duplicates, extracts text locally (including OCR for scans), classifies each document into an approved category using Apple Foundation Models, proposes consistent filenames, moves approved files into category folders, generates concise local summaries, and surfaces deletion candidates that are never acted on without explicit human approval.

The first release supports PDFs with text layers, scanned PDFs, PNG/JPEG/HEIC images, and Supported Office Documents. It defaults to the On-Device Model and may use Apple's Private Cloud Compute Model only after the user enables the Apple Private Cloud Allowed Processing Policy and the app confirms platform, entitlement, network, and quota availability. Explicit exclusions: no general-purpose autonomous agent behaviour, no automatic permanent deletion, no third-party model such as Claude, OpenAI, Gemini, or an extension model, no silent activation of Private Cloud Compute, no guarantee of every language or handwriting style, no replacement of professional records systems, no cross-platform support, no editing of the Category Taxonomy (fixed in the first release), and a single Archive Root only (multi-root support deferred to a later spec).

## Why

The archive owner has years of unorganised sensitive documents and no acceptable tool for the job: ordinary cloud-connected consumer agents can retain or process local file contents under provider-controlled policies, so pointing one at this archive introduces material disclosure risk. Apple's on-device model remains the lowest-risk default, while Private Cloud Compute adds a distinct Apple-operated option with stateless processing, attested software, no privileged runtime access, and verifiable transparency for cases that need a larger context window or stronger reasoning. This founding spec therefore defines a local-first, Apple-only pipeline in which cloud use is explicitly authorised and auditable, and probabilistic recommendations remain strictly separated from deterministic, validated, reversible filesystem actions.

## Glossary

- **App**: The Private Archive Organizer macOS application as a whole; the actor for behaviour that spans components (approval flows, mode detection, UI presentation).
- **Inventory Scanner**: The component that enumerates files under the Archive Root and creates and maintains Inventory Records. Read-only with respect to archive files.
- **Duplicate Detector**: The component that groups Exact Duplicates by Content Hash and flags Near-Duplicate Candidates by deterministic local similarity.
- **Extraction Engine**: The component that produces Extracted Text from documents via PDF text layers, on-device OCR, or local office-document parsing.
- **Classification Service**: The component that obtains Classification Recommendations from an Approved Apple Model through the Model Router and routes low-confidence results to the Review Queue.
- **Naming Engine**: The component that deterministically proposes and validates filenames.
- **Operation Executor**: The component that executes approved filesystem operations (renames, moves, quarantine moves, rollbacks) with hash verification and journaling.
- **Summarisation Service**: The component that generates document summaries via an Approved Apple Model and stores them locally.
- **Archive Root**: The user-selected folder the App has been granted access to via the macOS open panel and a persisted security-scoped bookmark. The first release supports exactly one Archive Root. All scanning and file operations on archive documents are confined to the Archive Root.
- **Security-Scoped Bookmark**: The macOS mechanism for persisting sandboxed access to a user-selected folder across app launches, used instead of Full Disk Access.
- **Inventory Record**: The locally stored metadata for one file: path, size, creation and modification dates, content type, Content Hash, and processing status.
- **Content Hash**: The SHA-256 digest of a file's bytes, used for exact-duplicate detection and move/rollback validation.
- **Exact Duplicate**: Two or more files whose Content Hashes are identical.
- **Near-Duplicate Candidate**: A pair or group of files the Duplicate Detector flags as *possibly* the same document (for example a rescan or re-export); always advisory, never treated as confirmed duplicates. Pair identity is the unordered pair of the two files' Content Hashes.
- **Extracted Text**: The locally produced text content of a document, obtained from a PDF text layer, on-device OCR, or local office-document parsing.
- **Insufficient Extraction**: An extraction result containing fewer than 25 non-whitespace characters of Extracted Text after whitespace normalisation. The threshold is a single named constant, configurable in app settings.
- **Supported Office Document**: A file in one of the office formats supported for local extraction in the first release: DOCX, XLSX, RTF, TXT, or CSV.
- **Category Taxonomy**: The approved list of document categories, each mapped to exactly one destination folder. Fixed in the first release: Financial, Medical, Employment, Identity, Other.
- **Classification Recommendation**: An Approved Apple Model's proposed category for a document, together with a Confidence Score and Model Execution Record. A recommendation is advisory input to the pipeline, never a direct trigger of filesystem changes.
- **Confidence Score**: A numeric score attached to each Classification Recommendation, compared against a configurable review threshold.
- **Proposed Action**: A concrete, deterministic, validated filesystem operation (rename, move, quarantine) awaiting explicit user approval.
- **Operation Journal**: The persistent local log of every executed filesystem operation, recording before/after paths, Content Hashes, timestamps, and outcomes; the source of truth for Rollback.
- **Rollback**: Restoring files to their journaled prior paths and names, driven entirely by the Operation Journal.
- **Review Queue**: The list of documents requiring a human decision — low-confidence or "Unknown" classifications, extraction failures, Near-Duplicate Candidates, naming-field gaps, aborted operations, and documents awaiting manual classification in Degraded Mode — presented with supporting evidence.
- **Deletion Candidate**: A file the App proposes for removal (for example a redundant exact duplicate), with a stated reason. Approval moves it to the Quarantine Folder; nothing is permanently erased by the App.
- **Quarantine Folder**: An App-managed folder inside the Archive Root where approved Deletion Candidates are moved, reversibly, instead of being permanently deleted.
- **On-Device Model**: The Apple Foundation Models framework system language model running locally on the Mac. It is the App's default semantic model.
- **Private Cloud Compute Model**: Apple's foundation model exposed through `PrivateCloudComputeLanguageModel` on supported OS versions to eligible apps holding the PCC entitlement. Requests are processed on Apple's attested Private Cloud Compute infrastructure and require a network connection and available user quota.
- **Approved Apple Model**: Either the On-Device Model or, when permitted by the current Processing Policy, the Private Cloud Compute Model. No third-party or extension model is an Approved Apple Model.
- **Processing Policy**: The user-selected semantic-processing mode: `Local Only` or `Apple Private Cloud Allowed`. `Local Only` is the default. Enabling PCC is a persistent, revocable consent for deterministic routing; it is not permission for arbitrary networking or third-party processing.
- **Model Router**: The component that selects an Approved Apple Model according to Processing Policy, capability, request size, visual-input needs, availability, and quota.
- **Model Execution Record**: Non-content provenance stored with each recommendation or summary: execution tier (on-device or PCC), OS version, model availability/version where exposed, prompt version, timestamp, and input modality. It excludes prompts, document text, images, paths, names, and summaries.
- **Visual Evidence**: Locally derived OCR text, barcode observations, image-classification labels, and bounded page/image representations used to support classification. Vision observations are task-specific signals, not a guarantee of general document comprehension.
- **Degraded Mode**: The App's operating mode when no Approved Apple Model is both permitted and available: deterministic processing and manual review remain; classification and summarisation are paused rather than delegated to a third-party model.
- **Synthetic Fixture**: A fabricated test document (fake statement, fake payslip, fake identity scan, or text-free image) used for development and testing in place of any real personal document.

## Requirements

### Requirement 1: Least-Privilege Folder Access

**User Story:** As the archive owner, I want the app to access only the folder I explicitly select, so that it can never read anything else on my Mac.

#### Acceptance Criteria

1. THE App SHALL obtain filesystem access exclusively through the folder the user selects in the macOS open panel, persisted as a Security-Scoped Bookmark.
2. THE App SHALL support exactly one Archive Root in the first release; selecting a new one replaces the old after explicit user confirmation.
3. THE App SHALL operate without requesting or requiring Full Disk Access.
4. WHEN the persisted Security-Scoped Bookmark fails to resolve at launch, THE App SHALL mark the Archive Root unavailable and prompt the user to re-select it, without escalating privileges.
5. WHEN the user removes the Archive Root, THE App SHALL stop reading files under it and mark its Inventory Records as unavailable.
6. THE App SHALL confine every write to archive documents (creating, renaming, moving, or quarantining files) to paths inside the Archive Root, and SHALL write app metadata — Inventory Records, the Operation Journal, and summaries — only to the App's own container.

---

### Requirement 2: Archive Inventory

**User Story:** As the archive owner, I want a complete inventory of the files in my selected folders, so that every later step operates on known, hashed, typed records rather than loose files.

#### Acceptance Criteria

1. WHEN the user starts a scan, THE Inventory Scanner SHALL enumerate every file under the Archive Root and record an Inventory Record for each, including path, size, creation and modification dates, content type, and Content Hash.
2. THE Inventory Scanner SHALL mark each file as supported (text PDF, scanned PDF, PNG/JPEG/HEIC image, or Supported Office Document) or unsupported.
3. WHEN a file is unsupported, THE Inventory Scanner SHALL retain its Inventory Record with an "unsupported" status and exclude it from extraction and classification.
4. WHILE scanning, THE Inventory Scanner SHALL NOT modify, move, rename, or write to any file under the Archive Root.
5. WHEN a scan is re-run, THE Inventory Scanner SHALL update existing Inventory Records (matched by path) rather than creating duplicate records.
6. IF a re-scanned file's Content Hash differs from its Inventory Record, THEN THE Inventory Scanner SHALL update the record's Content Hash and reset its extraction, classification, and summary statuses to pending.
7. IF a file cannot be read during scanning, THEN THE Inventory Scanner SHALL record it with an "unreadable" status and continue the scan.

---

### Requirement 3: Duplicate Detection

**User Story:** As the archive owner, I want exact duplicates found reliably and possible near-duplicates flagged for my review, so that I can reclaim space without ever losing a unique document.

#### Acceptance Criteria

1. WHEN two or more Inventory Records share an identical Content Hash, THE Duplicate Detector SHALL group them as Exact Duplicates.
2. WHEN the same set of Inventory Records is analysed twice, THE Duplicate Detector SHALL produce the same set of Near-Duplicate Candidates, computed locally with no model involvement.
3. THE Duplicate Detector SHALL NOT flag two files already grouped as Exact Duplicates of each other as a Near-Duplicate Candidate.
4. WHEN two documents are derived from the same source and differ only in scan artefacts or re-export (as represented by designated Synthetic Fixture pairs in the test suite), THE Duplicate Detector SHALL flag them as a Near-Duplicate Candidate.
5. THE Duplicate Detector SHALL present every Near-Duplicate Candidate in the Review Queue as advisory, and SHALL NOT treat any near-duplicate as a confirmed duplicate.
6. WHEN an Exact Duplicate group is found, THE Duplicate Detector SHALL nominate all but one copy as Deletion Candidates, with the group's evidence attached, without deleting anything.

---

### Requirement 4: Local Content Extraction and Visual Evidence

**User Story:** As the archive owner, I want document content extracted and visual evidence prepared locally, so that classification has useful evidence before any optional cloud processing is considered.

#### Acceptance Criteria

1. WHEN a PDF page contains a sufficient text layer, THE Extraction Engine SHALL extract that text directly without performing OCR on that page.
2. WHEN a PDF page lacks sufficient text or a PNG/JPEG/HEIC image is processed, THE Extraction Engine SHALL attempt on-device Vision OCR.
3. WHEN an image may contain a barcode or machine-readable code relevant to identification, THE Extraction Engine SHALL perform the applicable on-device Vision recognition and record only the minimally required result.
4. WHEN a document is a Supported Office Document, THE Extraction Engine SHALL extract its text using local parsing only.
5. THE Extraction Engine SHALL perform text extraction, OCR, barcode recognition, image rendering, and basic Vision classification on-device with no network access.
6. THE App SHALL treat generic Vision image-classification labels as advisory Visual Evidence and SHALL NOT treat them as equivalent to free-form visual understanding.
7. IF OCR and local parsing fail or produce an Insufficient Extraction, THEN THE Extraction Engine SHALL preserve any Visual Evidence and mark the document as requiring visual classification or Review Queue handling rather than inventing text.
8. ON macOS 27 or later, WHEN an image or rendered page requires semantic visual understanding, THE App SHALL prepare a bounded multimodal request for the Model Router; on earlier systems or when no permitted multimodal model is available, THE App SHALL route the document to the Review Queue.
9. THE App SHALL NOT store decoded identity numbers, full barcode payloads, signatures, or other unnecessary sensitive visual fields merely because Vision can detect them.

---

### Requirement 5: Privacy-Preserving Classification

**User Story:** As the archive owner, I want each document classified by an Approved Apple Model under my chosen Processing Policy, so that organisation is semantic while third-party disclosure is excluded and PCC use remains visible and controlled.

#### Acceptance Criteria

1. THE Classification Service SHALL classify each document with sufficient Extracted Text or Visual Evidence into exactly one category from the Category Taxonomy, or "Unknown".
2. THE Model Router SHALL select only an Approved Apple Model and SHALL default to the On-Device Model.
3. WHEN the Processing Policy is `Local Only`, THE App SHALL NOT construct, queue, or send any PCC request.
4. WHEN the Processing Policy is `Apple Private Cloud Allowed`, THE Model Router MAY use the Private Cloud Compute Model for requests that exceed the on-device context budget, need supported multimodal reasoning, fail locally for a retryable capability reason, or are explicitly retried with PCC by the user.
5. THE Classification Service SHALL attach a Confidence Score and Model Execution Record to every Classification Recommendation.
6. IF a Classification Recommendation's Confidence Score is below the review threshold, or its category is "Unknown", THEN THE Classification Service SHALL route the document to the Review Queue instead of feeding downstream automation.
7. THE App SHALL treat every Classification Recommendation as advisory: no filesystem operation SHALL be constructed from model output without deterministic validation and, for execution, explicit user approval.
8. THE App SHALL NOT send document content, Extracted Text, Visual Evidence, images, or derived features to Claude, OpenAI, Gemini, an extension model, or any other third-party AI service.

---

### Requirement 6: Filename Proposal

**User Story:** As the archive owner, I want consistent, validated filename proposals, so that organised documents follow one predictable convention I approve.

#### Acceptance Criteria

1. WHEN a document has a category assigned by user override or by a Classification Recommendation whose Confidence Score is at or above the review threshold, THE Naming Engine SHALL propose a filename following a single deterministic convention combining document date, category, and issuer/subject, preserving the original file extension.
2. THE Naming Engine SHALL validate every proposed filename deterministically — allowed characters, length limits, and uniqueness within the destination folder — before it becomes a Proposed Action.
3. IF a proposed filename collides with an existing file in the destination, THEN THE Naming Engine SHALL apply a deterministic disambiguation suffix and re-validate.
4. IF fields required by the naming convention cannot be determined, THEN THE Naming Engine SHALL route the document to the Review Queue with the partial proposal rather than inventing values.

---

### Requirement 7: Approved, Validated File Moves

**User Story:** As the archive owner, I want every rename and move to be explicitly approved, verified, and logged, so that no file is ever silently altered or lost.

#### Acceptance Criteria

1. THE App SHALL execute rename and move operations only after the user approves the corresponding Proposed Actions, individually or as a reviewed batch.
2. WHEN executing a move, THE Operation Executor SHALL verify the source file's Content Hash matches its Inventory Record before the move and verify the destination file's Content Hash matches after the move.
3. IF a pre-move or post-move hash verification fails, THEN THE Operation Executor SHALL abort that operation, leave the source untouched (or restore it), journal the failure, and route the document to the Review Queue.
4. THE Operation Executor SHALL never overwrite an existing file; IF a destination path exists at execution time, THEN THE Operation Executor SHALL abort that operation and route it to the Review Queue.
5. WHEN an operation executes, THE Operation Executor SHALL write an Operation Journal entry recording the operation type, before/after paths, Content Hash, timestamp, and outcome.
6. THE Operation Executor SHALL only move files to destinations inside the Archive Root.

---

### Requirement 8: Rollback

**User Story:** As the archive owner, I want any executed operation or batch reversible, so that a bad organising pass can be undone completely.

#### Acceptance Criteria

1. WHEN the user requests rollback of an operation or batch, THE Operation Executor SHALL restore the affected files to their journaled prior paths and names using the Operation Journal.
2. WHEN rolling back a file, THE Operation Executor SHALL verify the file's Content Hash matches its journaled hash before restoring it.
3. IF a rollback target is missing or its Content Hash no longer matches the journal, THEN THE Operation Executor SHALL report the discrepancy for that file, skip it, and continue rolling back the remaining files.
4. THE Operation Journal SHALL persist locally across app restarts.
5. THE App SHALL present the Operation Journal in the UI as a reviewable history of all executed operations and rollbacks.

---

### Requirement 9: Local Summaries

**User Story:** As the archive owner, I want a concise local summary of each document, so that I can identify documents later without reopening them.

#### Acceptance Criteria

1. WHEN a document is assigned a category — by a Classification Recommendation at or above the review threshold or by user override in the Review Queue — THE Summarisation Service SHALL generate a summary of at most 500 characters using an Approved Apple Model selected by the Model Router and store the result only in local app storage.
2. THE App SHALL never transmit a stored summary to any external service; any PCC request SHALL be constructed from the minimum source evidence required for that request, not from the accumulated local summary database.
3. IF no Approved Apple Model is permitted and available, THEN THE Summarisation Service SHALL mark the document's summary as pending and SHALL NOT generate it through a third-party service.
4. THE Summarisation Service SHALL store a Model Execution Record with every generated summary.

---

### Requirement 10: Human-Gated Deletion Candidates

**User Story:** As the archive owner, I want the app to propose deletions with reasons but never delete anything itself, so that I stay in control of destructive decisions.

#### Acceptance Criteria

1. THE App SHALL present Deletion Candidates with a stated reason and supporting evidence, without deleting any file automatically.
2. WHEN the user approves a Deletion Candidate, THE Operation Executor SHALL move the file to the Quarantine Folder as a journaled, reversible operation.
3. THE App SHALL NOT permanently erase any file; emptying the Quarantine Folder is left to the user acting outside the App.
4. WHEN a quarantine move executes, THE Operation Executor SHALL journal it with the same validation and rollback support as any other move (per Requirements 7 and 8).

---

### Requirement 11: Privacy Boundary

**User Story:** As the archive owner, I want local operations kept on my Mac and optional cloud processing restricted to Apple's Private Cloud Compute under my explicit policy, so that incremental disclosure risk is lowest reasonably achievable and residual cloud risk remains visible.

#### Acceptance Criteria

1. THE App SHALL perform inventory, hashing, duplicate detection, local parsing, OCR, barcode recognition, naming, filesystem mutation, journaling, rollback, persistence, and local search on-device.
2. WHEN the Processing Policy is `Local Only`, THE App SHALL function fully offline once the On-Device Model is installed and SHALL make no semantic-processing network request.
3. WHEN the Processing Policy is `Apple Private Cloud Allowed`, THE App SHALL transmit only the bounded text and/or image evidence required for the current PCC request through Apple's Foundation Models PCC API.
4. THE App SHALL NOT contain an arbitrary provider API key, generic third-party model integration, analytics SDK, or telemetry path capable of transmitting document content.
5. THE App SHALL NOT silently change Processing Policy, and disabling PCC SHALL prevent new PCC requests immediately without deleting local results already produced.
6. BEFORE the user first enables PCC, THE App SHALL explain that selected document evidence leaves the Mac for stateless processing on Apple infrastructure, that a network connection and quota are required, and that residual implementation, endpoint, account, legal-compulsion, and availability risks remain.
7. THE App SHALL keep Extracted Text, Visual Evidence caches, Classification Recommendations, Confidence Scores, summaries, Model Execution Records, and the summary index in protected local app storage, subject to explicit retention and purge controls.
8. IF diagnostics, logs, or bug reports are exported, THEN THE App SHALL include only processing statuses, error codes, timestamps, counts, Content Hashes, and non-content Model Execution Records, and SHALL exclude document contents, images, Visual Evidence, summaries, file names, and file paths.

---

### Requirement 12: Degraded Mode Without an Available Approved Apple Model

**User Story:** As the archive owner, I want the app to stay useful when no permitted Apple model is available, so that organising work can continue deterministically without a third-party substitute.

#### Acceptance Criteria

1. WHEN no Approved Apple Model is both permitted and available because of hardware, OS, Apple Intelligence state, model readiness, network state, PCC entitlement, regional availability, or PCC quota, THE App SHALL display the current availability status and reason.
2. WHILE in Degraded Mode, THE App SHALL keep inventory, hashing, exact-duplicate detection, near-duplicate detection, text extraction, Visual Evidence extraction, deterministic validation, manual classification via the Review Queue, filename proposal for user-assigned categories, approved moves, journaling, and rollback fully available.
3. WHILE in Degraded Mode, THE App SHALL NOT route classification or summarisation to a third-party or extension model.
4. WHEN an Approved Apple Model becomes available again, THE App SHALL resume model-backed classification and summarisation only after the user confirms, only for pending documents, and only under the current Processing Policy.
5. IF PCC is unavailable or its quota is exhausted while the On-Device Model remains available, THEN THE Model Router SHALL fall back to the On-Device Model when the request fits its capabilities; otherwise it SHALL route the document to the Review Queue.

---

### Requirement 13: Review Queue

**User Story:** As the archive owner, I want one place to resolve everything ambiguous, so that human judgment covers exactly the cases automation cannot.

#### Acceptance Criteria

1. THE Review Queue SHALL list every document requiring a human decision — low-confidence or "Unknown" classifications, extraction failures, Near-Duplicate Candidates, naming-field gaps, aborted operations, and documents awaiting manual classification in Degraded Mode — with its supporting evidence (proposed category, Confidence Score, extracted-text snippet, and file preview where available).
2. WHEN the user assigns or overrides a category in the Review Queue, THE App SHALL record the override, treat it as authoritative over any Classification Recommendation, and proceed with deterministic naming and move proposal.
3. WHEN the user rejects a Near-Duplicate Candidate, THE App SHALL record the decision and SHALL NOT re-flag the same pair (identified by the two files' Content Hashes) in later scans; a change to either file's Content Hash makes the pair eligible for re-flagging.
4. THE Review Queue SHALL support acting on multiple items in one reviewed batch, with each resulting operation individually validated and journaled.

---

### Requirement 14: Synthetic Fixtures Only

**User Story:** As the developer, I want all development and testing to run on fabricated documents, so that no real sensitive document ever enters source control, test artifacts, or reports.

#### Acceptance Criteria

1. THE repository SHALL contain only Synthetic Fixtures as test documents and SHALL NOT contain any real personal document.
2. THE automated test suite SHALL run entirely against Synthetic Fixtures, covering text PDFs, scanned PDFs, hybrid PDFs, ordinary images with no text, image-only document pages with no usable OCR text, barcodes containing fake values, and Supported Office Documents.
3. THE App's development and verification workflow SHALL NOT require real sensitive documents in source control, telemetry, bug reports, PCC requests, or test artifacts.
4. Live On-Device Model and PCC verification SHALL use Synthetic Fixtures only and SHALL be separately gated by platform and model availability.

---

### Requirement 15: Category Taxonomy

**User Story:** As the archive owner, I want a fixed, well-defined set of categories each mapped to a destination folder, so that classification output and the resulting folder structure are predictable.

#### Acceptance Criteria

1. THE App SHALL ship the Category Taxonomy with exactly these categories: Financial, Medical, Employment, Identity, Other.
2. THE App SHALL map each category to exactly one destination folder under the Archive Root.
3. THE App SHALL define the Category Taxonomy and its folder mapping in a single local configuration, so a later release can make it editable without changing pipeline behaviour.
4. THE Category Taxonomy SHALL NOT be editable in the first release.


---

### Requirement 16: PCC Consent, Routing, and Provenance

**User Story:** As the archive owner, I want to enable Apple's Private Cloud Compute once and then let the app route eligible work autonomously within clear limits, so that I gain stronger model capability without approving every request or losing visibility.

#### Acceptance Criteria

1. THE App SHALL default the Processing Policy to `Local Only`.
2. WHEN the user enables `Apple Private Cloud Allowed`, THE App SHALL persist the consent version, timestamp, and policy locally and SHALL display the active policy in Settings and during processing.
3. AFTER PCC is enabled, THE Model Router MAY route eligible requests autonomously according to deterministic, documented routing rules without prompting for every document.
4. THE App SHALL show whether each completed or failed model operation used the On-Device Model or the Private Cloud Compute Model without exposing the operation's sensitive input in logs.
5. THE App SHALL check `PrivateCloudComputeLanguageModel` availability and quota before routing and SHALL handle daily-limit and approaching-limit states without losing or corrupting pending work.
6. THE App SHALL require the Apple PCC entitlement and eligible distribution conditions before exposing the PCC setting; builds without the capability SHALL remain usable in `Local Only` mode.
7. THE App SHALL provide a single control to disable PCC for future requests and SHALL not interpret prior consent as permission to use any non-Apple cloud model.
8. THE App SHALL document that PCC materially reduces provider-side access and retention risk through Apple's technical architecture but does not eliminate all residual cloud-processing risk.
