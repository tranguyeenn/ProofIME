# ADR 001: Store replacement rules as versionable JSON

- Status: Proposed
- Date: 2026-07-02

## Context

ProofIME currently accepts either a `[String: String]` JSON dictionary or an array of `ReplacementRule`. The dictionary is simple and is used by the bundle, while the rule model can represent aliases, priority, mode, and boundary requirements. User files replace rather than merge with bundled rules, imports are not validated, and some rule fields are decoded but inactive.

A native IME will need stable, validated snapshots and safe reload behavior because a malformed file must not disable typing or crash a host process.

## Decision

Adopt a versioned JSON document as the long-term storage format, while retaining the dictionary and bare rule-array formats as legacy import formats.

The future document should contain a schema version and a `rules` array. Loading should:

1. Decode and validate the complete candidate document off the active path.
2. Reject duplicate primary triggers and invalid mode/boundary combinations.
3. Define alias conflicts deterministically.
4. Publish an immutable rule snapshot only after successful validation.
5. Retain the last known-good snapshot on reload failure.

Bundled defaults and user rules should have an explicit merge/replace policy selected before implementation; file existence alone should not define policy.

## Consequences

- Configuration can evolve through explicit migrations.
- The app and future IME can share the same validated snapshot.
- Import and reload require actionable error reporting and atomic file handling.
- Legacy formats remain readable but cannot express document-level metadata.
- This ADR does not claim the versioned document or migration path is implemented.
