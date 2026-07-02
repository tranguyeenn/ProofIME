# Input method specification

## Status

**Planned.** This document defines the intended contract for a future macOS InputMethodKit integration. The repository currently contains no InputMethodKit target or system-wide input source. Current editor behavior is documented separately below as a reference baseline.

## Goals

- Reuse deterministic replacement and template logic across the reference app and IME.
- Convert configured triggers at explicit boundaries without losing host text or keystrokes.
- Preserve selection, cursor, marked-text, pass-through, and undo expectations.
- Keep host integration outside the rule and template engines.

## Current reference behavior

Within `ProofTextView` only:

- Space, Tab, and Return are intercepted as triggers.
- The token is the maximal non-whitespace substring immediately before the cursor.
- A matching template is checked before a matching replacement rule.
- On match, the token is replaced and the boundary is appended.
- On no match, normal `NSTextView` handling inserts the key.
- Matching is exact and case-sensitive.
- Punctuation does not trigger processing and remains part of the live token.

This is implemented behavior, not yet the complete IME contract.

## Planned processing contract

An IME event adapter should provide the core with:

```text
surrounding text needed for tokenization
selection/cursor range with an explicitly named offset unit
typed event or commit boundary
active output mode
active rules and templates
```

The core should return one of:

- `passThrough`: the host handles the original event unchanged.
- `replace`: replace an explicit range with committed text and set the resulting selection.
- `compose`: update marked text and optionally expose candidates.
- `cancel`: clear ProofIME composition without altering unrelated host text.

The concrete Swift API is intentionally undecided. It should not reuse ambiguous `Int` cursor offsets without naming their encoding.

## Boundaries and matching

Before IME implementation, one boundary definition must replace the current split behavior between `Tokenizer` (whitespace/newline/punctuation) and `LiveReplacementController` (whitespace only). The selected policy must cover:

- Space, Tab, Return, punctuation, and end-of-composition.
- Whether the boundary is committed after expansion.
- Exact matching, case sensitivity, aliases, and priority.
- Template versus symbol precedence.
- Mode-specific rules and the meaning of `requiresBoundary`.

No host text outside the returned replacement range may be changed.

## Composition and candidates

### First IME phase

Use direct boundary-triggered commits for unambiguous exact matches. Pass through unmatched input. Do not require a candidate window for initial integration.

### Later phase

A candidate window may present ambiguous symbols, templates, or proof-aware completions. It must support keyboard navigation, commit, dismissal, Escape cancellation, focus changes, and accessibility. Candidate ranking must be deterministic or documented when contextual.

## Configuration lifecycle

The IME and reference app should consume the same validated configuration snapshot. Reload must not expose a partially decoded file. On failure, retain the last known-good snapshot and report a useful error. See [SYMBOL_SPEC.md](SYMBOL_SPEC.md), [TEMPLATE_SPEC.md](TEMPLATE_SPEC.md), and [docs/adr/001-rule-storage.md](docs/adr/001-rule-storage.md).

## Privacy and context

The initial IME should request only the surrounding text required for tokenization and replacement. Planned context-aware proof features need an explicit privacy design before implementation: what text is read, how much is retained, whether processing leaves the device, and how the user disables it.

## Compatibility and acceptance

No named host is supported until tested. The acceptance matrix should cover, at minimum:

- Plain and rich text clients.
- Cursor and selection replacement.
- Non-ASCII text and UTF-16 range conversion.
- Undo/redo, copy/paste, and line breaks.
- Secure text fields and clients that provide limited surrounding text.
- Focus changes, app switching, input-source switching, and IME restart.
- Candidate positioning across displays when candidates exist.

A host-specific failure must pass input through safely rather than corrupt text.
