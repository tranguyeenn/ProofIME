# ADR 003: Isolate InputMethodKit behind a host adapter

- Status: Proposed
- Date: 2026-07-02

## Context

ProofIME currently has a standard macOS application target. `ProofTextView` supplies an in-process reference host for keyboard events and cursor insertion. There is no input-method bundle, `IMKInputController`, candidate window, installation workflow, or host compatibility suite.

InputMethodKit has lifecycle, marked-text, client-range, and pass-through concerns that should not leak into replacement rules or template storage. Conversely, core processing should not depend on SwiftUI or a particular text view.

## Decision

Add the native input method as a separate target and implement InputMethodKit interaction through a thin host adapter.

The adapter will:

- Translate client text, selection, and keyboard events into a host-independent processing request.
- Convert explicit core replacement ranges back to client operations.
- Own composition/marked-text state, lifecycle, candidate placement, and safe pass-through.
- Consume immutable, validated configuration snapshots.
- Avoid retaining host text beyond the active operation unless a later privacy-reviewed feature requires it.

The existing SwiftUI application remains a reference/configuration surface and test host. It must not be the runtime dependency through which the IME processes keystrokes.

## Consequences

- Core engines can be tested without launching an input source.
- InputMethodKit-specific failures are contained at the adapter boundary.
- The project gains packaging, signing, installation, activation, and process-lifecycle work.
- Candidate UI should be added only after direct commit/pass-through behavior is reliable.
- Host compatibility claims require a recorded matrix; framework integration alone is insufficient.
- No part of this ADR is currently implemented.
