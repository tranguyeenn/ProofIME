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
├── config.lua
├── keyboard.lua
├── engine.lua
├── buffer.lua
├── matcher.lua
├── replacer.lua
├── logger.lua
├── utils.lua
└── ui.lua

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

Symbol rules are split into category files under `rules/`:

```text
rules/
├── index.json
├── logic.json
├── sets.json
├── relations.json
├── arrows.json
├── greek.json
└── calculus.json
```

`rules/index.json` controls which categories are loaded:

```json
{
  "enabled": [
    "logic",
    "sets",
    "relations",
    "arrows",
    "greek",
    "calculus"
  ]
}
```

Remove a category name from `enabled` to disable it, then reload Hammerspoon. To add a new category, create `rules/<category>.json` with trigger-to-symbol mappings and add `<category>` to the enabled list:

```json
{
  "therefore": "∴"
}
```

`rules/symbols.json` is still kept temporarily as a legacy fallback if `rules/index.json` is missing.

The Hammerspoon backend is split into small modules:

- `init.lua` wires modules together and starts keyboard listeners.
- `config.lua` owns runtime knobs such as enabled state, debug logging, buffer length, ignored apps, replacement mode, and the toggle hotkey.
- `keyboard.lua` adapts Hammerspoon key events into engine input.
- `engine.lua` coordinates the buffer, matcher, and replacer.
- `buffer.lua` maintains the rolling typed buffer.
- `matcher.lua` loads enabled rule categories and finds the longest suffix match.
- `replacer.lua` sends backspaces and inserts the replacement text.
- `logger.lua` wraps Hammerspoon logging.
- `utils.lua` contains shared string, JSON, and file helpers.
- `ui.lua` is a placeholder for future candidate-window work.

## Legacy IMK Material

InputMethodKit-specific source, plist files, install scripts, scheme files, and IMK design notes are quarantined under `legacy/imk/`. They are retained only as historical reference and are not part of the active backend direction.

Do not add a new Xcode input-method target for the Hammerspoon prototype.
