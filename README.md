# ProofIME

ProofIME is an experimental macOS typing backend for Telex-style math and proof symbol expansion.

ProofIME is no longer using InputMethodKit. The failed native IME implementation has been moved to `legacy/imk/` so the repository can pivot toward a smaller Hammerspoon-based backend.

## Direction

The current goal is a Hammerspoon prototype that watches typed text, keeps a small rolling buffer, and expands exact triggers into proof-writing symbols across macOS apps where Hammerspoon can inject keystrokes.

Examples:

```text
fa  -> ∀
ex  -> ∃
imp -> →
iff -> ↔
and -> ∧
or  -> ∨
not -> ¬
in  -> ∈
```

Rules are data-driven through JSON now, with YAML as a planned format once the backend needs richer configuration.

## Project Layout

```text
rules/
└── symbols.json

hammerspoon/
├── init.lua
├── engine.lua
├── keyboard.lua
└── config.lua

legacy/
└── imk/
```

The older Swift reference app and replacement/rules code are still present in `ProofIME/` and `ProofIMETests/`. They have not been deleted, because they contain reusable replacement behavior and tests.

The requested lowercase `proofime/` directory cannot coexist with the existing `ProofIME/` app directory on the default case-insensitive macOS filesystem, so the Hammerspoon backend lives at root-level `hammerspoon/`, `rules/`, and `legacy/` paths.

## Run the Hammerspoon Prototype

Install Hammerspoon, then load the prototype from `~/.hammerspoon/init.lua`:

```lua
package.path = package.path .. ";/Users/trangnguyen/dev/ProofIME/hammerspoon/?.lua"
dofile("/Users/trangnguyen/dev/ProofIME/hammerspoon/init.lua")
```

Reload Hammerspoon. Type a trigger such as `fa`; the backend sends backspaces for the trigger and inserts `∀`.

The default toggle hotkey is `ctrl` + `alt` + `cmd` + `p`. Logs are written through Hammerspoon's console under the `ProofIME` logger.

## Configuration

Symbol rules live in `rules/symbols.json`:

```json
{
  "fa": "∀",
  "imp": "→"
}
```

Edit that file and reload Hammerspoon to change the active rules.

## Legacy IMK Material

InputMethodKit-specific source, plist files, install scripts, scheme files, and IMK design notes are quarantined under `legacy/imk/`. They are retained only as historical reference and are not part of the active backend direction.

Do not add a new Xcode input-method target for the Hammerspoon prototype.
