# Roadmap

This roadmap records capability stages, not delivery dates. A feature moves to Implemented only when code and proportionate tests exist in the repository.

## Implemented

- [x] Standalone macOS SwiftUI reference/testing application.
- [x] Built-in Unicode symbol dictionary and built-in LaTeX preview mappings.
- [x] Exact replacement rules with priority sorting and aliases at engine level.
- [x] Space, Tab, and Return live replacement in the app editor.
- [x] Built-in proof template loading, trigger expansion, search, favorites, and cursor insertion.
- [x] Symbol reference search and cursor insertion.
- [x] User symbol file import/reload/delete controls.
- [x] Clipboard copy and `.txt`/`.tex` export.

## In progress: stabilize the core

- [ ] Make `Tokenizer`, `TokenProcessor`, and `LiveReplacementController` share one boundary contract.
- [ ] Make Unicode/LaTeX mode behavior consistent between live replacement and preview conversion.
- [ ] Define or remove currently inactive rule fields (`mode`, `requiresBoundary`).
- [ ] Validate imported configuration and surface errors in the UI.
- [ ] Decide and implement user template override semantics.
- [ ] Define cursor offsets safely for Unicode and AppKit UTF-16 ranges.
- [ ] Replace the placeholder test and repair the stale live-replacement test call.
- [ ] Add unit coverage for loaders, precedence, aliases, token boundaries, templates, and cursor updates.

## Planned: native input method foundation

- [ ] Add a separate InputMethodKit input-source target and required bundle metadata.
- [ ] Adapt host-client text and cursor operations to the core processor.
- [ ] Define composition, commit, cancellation, and pass-through behavior.
- [ ] Add deterministic logging and a reference-host test matrix.
- [ ] Package, install, enable, disable, and uninstall a development input source safely.

This phase must be complete before claiming system-wide IME support or compatibility with any host application.

## Planned: interaction and configuration

- [ ] Candidate window with keyboard selection and dismissal behavior.
- [ ] Preferences UI for modes, mappings, templates, and conflict handling.
- [ ] Versioned configuration schema, migration, validation, and recovery.
- [ ] Import/export for both symbols and templates.

## Planned: proof-aware assistance

- [ ] Proof-aware completion candidates.
- [ ] Context-aware theorem and proof templates.
- [ ] Structured template fields and keyboard navigation.
- [ ] User-controlled context scope with documented privacy behavior.

## Explicitly uncommitted

Cross-platform implementations, editor plugins, cloud synchronization, and compatibility with named third-party applications are not implemented and have no committed release. Host support should be documented only after direct testing of the native IME.
