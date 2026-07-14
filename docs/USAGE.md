# Usage

ProofIME expands short typed triggers into symbols.

## Basic Typing

Type the trigger prefix `:` followed by a trigger:

```text
:fa      -> ∀
:ex      -> ∃
:and     -> ∧
:or      -> ∨
:in      -> ∈
:le      -> ≤
:lambda  -> λ
```

Expansion happens immediately after the full trigger is typed. ProofIME deletes the typed trigger and inserts the replacement symbol.

## Hotkeys

| Action | Hotkey |
| --- | --- |
| Toggle ProofIME on/off | `cmd` + `alt` + `ctrl` + `p` |
| Reload rules | `cmd` + `ctrl` + `alt` + `r` |
| Open cheat sheet | `cmd` + `ctrl` + `alt` + `/` |

The cheat sheet is searchable, resizable, and remembers its last position.

## Rule Categories

The default rule set is grouped into these categories:

- Logic
- Sets
- Relations
- Arrows
- Greek
- Calculus and proof symbols

Open the cheat sheet for the current list loaded in your local checkout.

## Ignored Apps

ProofIME intentionally ignores terminal apps and password managers by default. This lowers the risk of changing shell commands, secrets, or password fields.

Ignored app names and bundle IDs are configured in `hammerspoon/config.lua`.

## SwiftUI Reference App

The reference app has its own editor and output preview.

Common actions:

- Type triggers in the editor and use Space, Tab, or Return to commit live replacements.
- Switch between Unicode and LaTeX preview modes.
- Search symbols and templates.
- Insert a symbol or proof template from the reference panels.
- Favorite proof templates.
- Copy output or save it as `.txt` or `.tex`.
- Import custom symbol JSON from the Config menu.

The reference app is separate from the Hammerspoon backend. Its live replacement only affects text inside the app window.
