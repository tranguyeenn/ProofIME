# Changelog

This changelog is reconstructed from repository tags and commit history. Dates are omitted where the repository history alone does not establish a release date. The project is pre-1.0; behavior and configuration may change.

## Unreleased

### Added

- Senior-engineer documentation set covering architecture, product direction, testing, formats, contribution workflow, and proposed IME integration.
- Shared `TokenProcessor` for current-token checks and live trigger delegation.

### Known limitations

- The product is a standalone macOS app, not an InputMethodKit input method.
- User template loading is not implemented.
- Live editor replacement and output-preview mode semantics differ.
- Automated tests are minimal, and the current live-replacement test call is stale.

## v0.3

- Added searchable built-in proof templates.
- Added template favorites.
- Added the proof-specific template library.

## v0.2-editor-workflows

- Added cursor-aware symbol and template insertion.
- Added live replacement on editor boundary keys.

## v0.1-live-replacement

- Added initial live symbol replacement in the reference editor.
- Added tokenizer and rule-based replacement foundations.

## Earlier work

- Added Unicode and LaTeX output preview modes.
- Added configurable symbol mappings, config-folder actions, copy, and text/TeX export.
- Added the SwiftUI reference interface and screenshots.
