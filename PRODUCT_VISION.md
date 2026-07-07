# Product vision

## Purpose

ProofIME aims to reduce the mechanical cost of writing mathematical proofs on macOS. A writer should be able to use memorable shorthand for notation and recurring proof structure without repeatedly opening symbol palettes or copying boilerplate.

The Telex inspiration is interactional: short sequences become intended text through predictable typing rules. It is not a goal to infer or rewrite mathematical meaning without the writer's control.

## Product principles

- **Predictable:** exact triggers, visible candidates where ambiguity exists, and an obvious pass-through/cancel path.
- **Fast:** common symbol entry should require few keystrokes and no pointer interaction.
- **Configurable:** notation and templates belong to the writer, with validated and recoverable files.
- **Local-first:** proof text processing should remain on-device unless a future network feature is separately designed and consented to.
- **Host-respectful:** preserve application text, selection, undo, and composition conventions.
- **Honest about semantics:** templates assist structure; they do not establish correctness of a proof.

## Users and jobs

Primary users are students, instructors, and proof-heavy writers who work on macOS. Core jobs are entering mathematical symbols, expanding repeatable proof skeletons, and moving the result into the writer's chosen document workflow.

## Current product

Implemented today is a standalone reference/testing application. It demonstrates symbol mappings, replacement rules, token processing, built-in templates, reference lists, output preview, configuration import for symbols, copy, and file export. This validates core interactions but does not provide system-wide input.

Work in progress is core semantic consistency, configuration reliability, and sufficient tests to support reuse outside the app.

## Intended product

The planned product direction is a Hammerspoon-based macOS backend, sharing deterministic rule and replacement semantics with the reference app where practical. Later phases may add preferences, proof-aware completions, and context-aware theorem/proof templates.

Context-aware features require a separate design for data scope, privacy, latency, confidence, and user override. They are planned concepts, not current capabilities.

## Non-goals for the current phase

- Automated proof verification or theorem proving.
- Silent semantic correction.
- Cloud accounts or synchronization.
- Cross-platform parity.
- Editor-specific integrations or claims of compatibility with VS Code, Pages, Notes, Safari, Obsidian, or other hosts before the Hammerspoon backend is tested there.

## Success criteria

Near-term success means the same input, rule set, mode, boundary, and cursor state produce the same deterministic result in tests, in the reference app, and in the Hammerspoon backend where host constraints allow it.
