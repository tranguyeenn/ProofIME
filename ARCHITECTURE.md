# Architecture

## Status and scope

The repository currently builds one macOS application target (`ProofIME`) and one test target (`ProofIMETests`). The application is a SwiftUI reference/testing interface backed by `NSTextView`; there is no active InputMethodKit target, input-source bundle, candidate window, or system-wide event path.

## Runtime data flow

```text
bundled/user symbols.json ─> SymbolLoader ─> ReplacementEngine
                                      └───> SymbolEngine ─> output preview

bundled proof_templates.json ─> ProofTemplateLoader ─> TemplateEngine
                                                        │
keyboard boundary ─> ProofTextView ─> TokenProcessor ─> LiveReplacementController
                                                        │
                                                        └─> updated text/cursor
```

`ContentView` composes these paths and also owns search, favorites, import/export, clipboard, and config actions.

## Components

### App and UI

- `ProofIMEApp` creates the application window.
- `ContentView` is the composition root. Computed properties reconstruct loaders and engines as SwiftUI state changes.
- `LiveReplacementTextView` bridges SwiftUI state to `ProofTextView`, an `NSTextView` subclass.
- `ProofTextView.keyDown` intercepts Space, Tab, and Return. Other input follows normal `NSTextView` handling.

### Processing

- `LiveReplacementController` finds the non-whitespace token immediately before the cursor. It gives templates precedence over replacement rules, appends the typed boundary, and returns text plus a cursor offset.
- `TokenProcessor` exposes current-token checks and delegates trigger processing to the controller.
- `ReplacementEngine` sorts rules by descending priority and performs exact trigger or alias matching after trimming surrounding whitespace/newlines.
- `SymbolEngine` performs a separate batch transformation by splitting only on literal spaces. It powers the output preview, not editor keystroke handling.
- `Tokenizer` defines whitespace, newline, and punctuation boundaries, but the live controller currently uses whitespace-only scanning. These are not yet one canonical tokenizer.
- `TemplateEngine` performs exact, first-match trigger lookup.

### Models and persistence

- `ReplacementRule` describes trigger, output, output mode, boundary requirement, priority, and aliases.
- `ProofTemplate` describes a stable ID, trigger, title, and body.
- `SymbolMapping` is a UI row model.
- `OutputMode` has Unicode and LaTeX cases.
- `SymbolLoader` prefers the user symbol file, then falls back to the bundled file only when the user file is absent. A malformed user file produces an empty result rather than falling back.
- `ProofTemplateLoader` loads only the bundled template file.
- `AppConfig` manages paths under `~/Library/Application Support/ProofIME/`.
- Template favorite IDs are stored as a comma-separated `@AppStorage` string.

## Important behavioral boundaries

- String cursor positions are expressed as Swift `String.count` offsets in processing code, while `NSTextView.selectedRange()` is an `NSRange` using UTF-16 units. They coincide for current ASCII triggers and most simple outputs but are not a safe general cursor contract.
- The live editor always constructs Unicode rules. Changing the Unicode/LaTeX picker changes batch preview mappings; it does not change live replacement output.
- `requiresBoundary` and `mode` decode successfully but are not consulted by `ReplacementEngine` or `LiveReplacementController`.
- Rule aliases work in `ReplacementEngine`; `SymbolLoader.loadMappings()` drops aliases when converting a rule array to a dictionary.
- Template placeholders such as `<#work#>` are plain text. There is no field navigation or structured placeholder model.
- Import replaces the user symbol file without schema validation or atomic rollback.

## Dependency direction

Processing engines depend on Foundation and model types, not SwiftUI. UI code depends on engines and loaders. This separation is suitable for reuse by the Hammerspoon backend, but host event translation and text-client operations should remain outside the core engines.

The failed InputMethodKit design notes are retained only as legacy material under `legacy/imk/`.

## Intended evolution

### In progress

- Establish one token/boundary definition and one mode-aware replacement pipeline.
- Add validation and explicit error reporting for configuration.
- Raise test coverage for cursor, boundary, rule, template, and loader behavior.

### Planned

- Extract a host-independent composition layer shared by the reference app and the Hammerspoon backend.
- Keep keyboard watching, backspace insertion, and host-specific behavior outside rule storage.
- Introduce versioned configuration migration if schemas evolve.
