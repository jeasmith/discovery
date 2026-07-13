# Requirements Document

## Introduction

Private Archive Organizer is a native macOS application that organises a personal archive of highly sensitive documents — bank and credit-card statements, payslips, hospital letters, passport and identity scans — entirely on-device. It inventories a user-selected archive folder, detects exact and possible near-duplicates, extracts text locally (including OCR for scans), classifies each document into an approved category using Apple's on-device Foundation Models framework, proposes consistent filenames, moves approved files into category folders, generates concise local summaries, and surfaces deletion candidates that are never acted on without explicit human approval.

The scope of this spec is the first release: supported inputs are PDFs with text layers, scanned PDFs, PNG/JPEG/HEIC images, and Supported Office Documents. Explicit exclusions: no general-purpose autonomous agent behaviour, no automatic permanent deletion, no uploading of documents to third-party models, no silent fallback to Private Cloud Compute, no guarantee of every language or handwriting style, no replacement of professional records systems, no cross-platform support, no editing of the Category Taxonomy (fixed in the first release), and a single Archive Root only (multi-root support deferred to a later spec).

## Why

The archive owner has years of unorganised sensitive documents and no acceptable tool for the job: cloud-connected consumer agents can route local file contents through provider-side processing, so pointing one at this archive would disclose financial, medical, and identity records to a third party. Apple's on-device Foundation Models framework now makes semantic classification and summarisation practical without any network round-trip, which removes the last reason this pipeline needed a cloud model. This is the founding spec for the repository: it defines the complete on-device pipeline — probabilistic recommendations strictly separated from deterministic, validated, reversible filesystem actions — that later specs will build on.

## Glossary

- **App**: The Private Archive Organizer macOS application as a whole; the actor for behaviour that spans components (approval flows, mode detection, UI presentation).
- **Inventory Scanner**: The component that enumerates files under the Archive Root and creates and maintains Inventory Records. Read-only with respect to archive files.
- **Duplicate Detector**: The component that groups Exact Duplicates by Content Hash and flags Near-Duplicate Candidates by deterministic local similarity.
- **Extraction Engine**: The component that produces Extracted Text from documents via PDF text layers, on-device OCR, or local office-document parsing.
- **Classification Service**: The component that obtains Classification Recommendations from the On-Device Model and routes low-confidence results to the Review Queue.
- **Naming Engine**: The component that deterministically proposes and validates filenames.
- **Operation Executor**: The component that executes approved filesystem operations (renames, moves, quarantine moves, rollbacks) with hash verification and journaling.
- **Summarisation Service**: The component that generates document summaries via the On-Device Model and stores them locally.
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
- **Classification Recommendation**: The On-Device Model's proposed category for a document, together with a Confidence Score. A recommendation is advisory input to the pipeline, never a direct trigger of filesystem changes.
- **Confidence Score**: A numeric score attached to each Classification Recommendation, compared against a configurable review threshold.
- **Proposed Action**: A concrete, deterministic, validated filesystem operation (rename, move, quarantine) awaiting explicit user approval.
- **Operation Journal**: The persistent local log of every executed filesystem operation, recording before/after paths, Content Hashes, timestamps, and outcomes; the source of truth for Rollback.
- **Rollback**: Restoring files to their journaled prior paths and names, driven entirely by the Operation Journal.
- **Review Queue**: The list of documents requiring a human decision — low-confidence or "Unknown" classifications, extraction failures, Near-Duplicate Candidates, naming-field gaps, aborted operations, and documents awaiting manual classification in Degraded Mode — presented with supporting evidence.
- **Deletion Candidate**: A file the App proposes for removal (for example a redundant exact duplicate), with a stated reason. Approval moves it to the Quarantine Folder; nothing is permanently erased by the App.
- **Quarantine Folder**: An App-managed folder inside the Archive Root where approved Deletion Candidates are moved, reversibly, instead of being permanently deleted.
- **On-Device Model**: The Apple Foundation Models framework system language model running locally on the Mac. The only model the App uses.
- **Degraded Mode**: The App's operating mode when the On-Device Model is unavailable: deterministic processing and manual review remain; classification and summarisation are paused, never delegated to a network model.
- **Synthetic Fixture**: A fabricated test document (fake statement, fake payslip, fake identity scan) used for development and testing in place of any real personal document.

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

### Requirement 4: On-Device Content Extraction

**User Story:** As the archive owner, I want each document's text extracted locally, so that classification and naming have enough content to work with while nothing leaves the machine.

#### Acceptance Criteria

1. WHEN a PDF contains a text layer, THE Extraction Engine SHALL extract that text directly without performing OCR.
2. WHEN a document is a scanned PDF without a text layer or a PNG/JPEG/HEIC image, THE Extraction Engine SHALL produce Extracted Text using on-device OCR.
3. WHEN a document is a Supported Office Document, THE Extraction Engine SHALL extract its text using local parsing only.
4. THE Extraction Engine SHALL perform all extraction on-device with no network access.
5. IF extraction fails or the result is an Insufficient Extraction, THEN THE Extraction Engine SHALL mark the Inventory Record "extraction-failed" and route the document to the Review Queue.

---

### Requirement 5: On-Device Classification

**User Story:** As the archive owner, I want each document classified into an approved category by an on-device model, so that organisation is semantic without any content disclosure.

#### Acceptance Criteria

1. THE Classification Service SHALL classify each successfully extracted document into exactly one category from the Category Taxonomy, or "Unknown".
2. THE Classification Service SHALL use only the On-Device Model for classification and SHALL NOT send document content, Extracted Text, or derived features to any remote service, including Private Cloud Compute.
3. THE Classification Service SHALL attach a Confidence Score to every Classification Recommendation.
4. IF a Classification Recommendation's Confidence Score is below the review threshold, or its category is "Unknown", THEN THE Classification Service SHALL route the document to the Review Queue instead of feeding downstream automation.
5. THE App SHALL treat every Classification Recommendation as advisory: no filesystem operation SHALL be constructed from model output without deterministic validation and, for execution, explicit user approval.

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

1. WHEN a document is assigned a category — by a Classification Recommendation at or above the review threshold or by user override in the Review Queue — THE Summarisation Service SHALL generate a summary of at most 500 characters using the On-Device Model and store it only in local app storage.
2. THE App SHALL never transmit summaries off the device.
3. IF the On-Device Model is unavailable, THEN THE Summarisation Service SHALL mark the document's summary as pending and SHALL NOT generate it by any other means.

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

**User Story:** As the archive owner, I want a hard guarantee that document content never leaves my Mac, so that using the app adds zero disclosure risk.

#### Acceptance Criteria

1. THE App SHALL perform all document processing — inventory, hashing, extraction, classification, naming, moving, summarisation — on-device.
2. THE App SHALL NOT transmit file contents, Extracted Text, Classification Recommendations, Confidence Scores, summaries, or document-derived metadata over any network.
3. THE App SHALL function fully offline once the On-Device Model is installed.
4. THE App SHALL NOT use Private Cloud Compute, extension models, or any third-party AI service, and SHALL NOT fall back to them silently under any condition.
5. IF diagnostics, logs, or bug reports are exported, THEN THE App SHALL include only processing statuses, error codes, timestamps, counts, and Content Hashes, and SHALL exclude document contents, Extracted Text, summaries, file names, and file paths.

---

### Requirement 12: Degraded Mode Without the On-Device Model

**User Story:** As the archive owner, I want the app to stay useful when Apple's model is unavailable, so that organising work can continue deterministically without any cloud substitute.

#### Acceptance Criteria

1. WHEN the On-Device Model is unavailable (unsupported hardware, Apple Intelligence disabled, or model not downloaded), THE App SHALL detect this and display the current availability status and reason.
2. WHILE in Degraded Mode, THE App SHALL keep inventory, hashing, exact-duplicate detection, near-duplicate detection, text extraction, deterministic validation, manual classification via the Review Queue, filename proposal for user-assigned categories, approved moves, journaling, and rollback fully available.
3. WHILE in Degraded Mode, THE App SHALL NOT route classification or summarisation to any network model.
4. WHEN the On-Device Model becomes available again, THE App SHALL resume model-backed classification and summarisation only after the user confirms, and only for documents whose classification or summary is still marked pending.

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
2. THE automated test suite SHALL run entirely against Synthetic Fixtures, covering text PDFs, scanned PDFs, images, and Supported Office Documents.
3. THE App's development and verification workflow SHALL NOT require real sensitive documents in source control, telemetry, bug reports, or test artifacts.

---

### Requirement 15: Category Taxonomy

**User Story:** As the archive owner, I want a fixed, well-defined set of categories each mapped to a destination folder, so that classification output and the resulting folder structure are predictable.

#### Acceptance Criteria

1. THE App SHALL ship the Category Taxonomy with exactly these categories: Financial, Medical, Employment, Identity, Other.
2. THE App SHALL map each category to exactly one destination folder under the Archive Root.
3. THE App SHALL define the Category Taxonomy and its folder mapping in a single local configuration, so a later release can make it editable without changing pipeline behaviour.
4. THE Category Taxonomy SHALL NOT be editable in the first release.
