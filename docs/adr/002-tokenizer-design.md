# ADR 002: Use cursor-local, boundary-aware tokenization

- Status: Proposed
- Date: 2026-07-02

## Context

The code currently has three related definitions:

- `Tokenizer` splits on whitespace, newlines, and punctuation.
- `TokenProcessor.currentToken` uses the same broad `CharacterSet` split.
- `LiveReplacementController.findTokenRange` scans backward to whitespace only.

The output-preview `SymbolEngine` has a fourth behavior: it splits only on literal spaces. These differences make punctuation and cursor behavior dependent on the entry path. Cursor offsets are also represented as Swift `String.count`, while AppKit selections are UTF-16 `NSRange` values.

## Decision

Introduce one tokenizer contract that operates at the cursor and returns a replacement range plus token, rather than token text alone.

The contract must:

- Define boundaries centrally and make the triggering boundary available to policy code.
- Preserve the exact source range to replace.
- Use a named offset representation at API boundaries and tested conversions for AppKit UTF-16 ranges.
- Support local scanning without tokenizing an entire document on each keystroke.
- Keep token extraction separate from rule/template precedence and output mode.

Punctuation policy remains to be selected through tests against intended proof notation. Until selected, current live behavior must not be described as punctuation-aware.

## Consequences

- Reference app and future IME can share range-safe behavior.
- Existing `Tokenizer`, `TokenProcessor`, controller scanning, and preview conversion will need consolidation.
- Tests must cover composed Unicode, emoji, punctuation, selection replacement, and cursor positions.
- Some current behavior may change; that change must be recorded in specs and changelog.
- This ADR is a design direction, not an implemented tokenizer rewrite.
