# ProofIME

ProofIME is an experimental macOS helper for typing mathematical logic, set theory, relation, arrow, Greek, and proof symbols from short text triggers.

The active user-facing path is the Hammerspoon backend. After it is loaded, typing a trigger such as `:fa` in a supported macOS text field expands it to `∀`.

```text
:fa      -> ∀
:ex      -> ∃
:imp     -> →
:iff     -> ↔
:and     -> ∧
:or      -> ∨
:not     -> ¬
:in      -> ∈
:lambda  -> λ
:qed     -> ∎
```

ProofIME also includes a SwiftUI reference app for experimenting with symbol and proof-template replacement inside one app window. It is not currently a system input method.

## Current Status

- Active backend: Hammerspoon scripts in `hammerspoon/`.
- Active rule data: categorized JSON files in `rules/`.
- Reference app: SwiftUI project in `ProofIME/` and `ProofIME.xcodeproj`.
- Legacy native IME material: archived under `legacy/imk/`.

ProofIME previously explored InputMethodKit, but that implementation is no longer active. Do not expect this repository to install a macOS input source.

## Quick Start

1. Install [Hammerspoon](https://www.hammerspoon.org/).
2. Grant Hammerspoon Accessibility permission in macOS System Settings.
3. Add this to `~/.hammerspoon/init.lua`, replacing the path if your checkout lives somewhere else:

   ```lua
   package.path = package.path .. ";/Users/trangnguyen/dev/ProofIME/hammerspoon/?.lua"
   dofile("/Users/trangnguyen/dev/ProofIME/hammerspoon/init.lua")
   ```

4. Reload Hammerspoon.
5. Type `:fa` in a normal text field. It should become `∀`.

See [docs/INSTALL.md](docs/INSTALL.md) for full setup details.

## Daily Use

- Toggle ProofIME on or off: `cmd` + `alt` + `ctrl` + `p`
- Reload symbol rules: `cmd` + `ctrl` + `alt` + `r`
- Open the searchable cheat sheet: `cmd` + `ctrl` + `alt` + `/`

The default trigger prefix is `:`. This keeps normal words from expanding accidentally, so `:or` expands to `∨` while `or` remains ordinary text.

See [docs/USAGE.md](docs/USAGE.md) for common workflows, hotkeys, and supported rule categories.

## Custom Symbols

Rules are loaded from `rules/index.json`, which enables category files such as `rules/logic.json`, `rules/sets.json`, and `rules/greek.json`.

To add a simple local rule:

1. Create or edit a category file under `rules/`.
2. Add the category name to `rules/index.json`.
3. Press `cmd` + `ctrl` + `alt` + `r` to reload rules.

Rules can use either a compact object format:

```json
{
  "therefore": "∴"
}
```

or a metadata-rich array format:

```json
[
  {
    "trigger": "fa",
    "replacement": "∀",
    "description": "for all",
    "keywords": ["forall", "universal", "logic"],
    "category": "logic"
  }
]
```

See [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) before changing shared rule files.

## SwiftUI Reference App

The Xcode app is useful for trying the replacement engine, proof templates, symbol search, copy/save output, and user config files under `~/Library/Application Support/ProofIME/`.

Open `ProofIME.xcodeproj` in Xcode and run the `ProofIME` scheme. The app works inside its own editor window only; it does not expand text system-wide.

## Repository Map

```text
hammerspoon/          Hammerspoon backend modules
rules/                Categorized symbol rules used by Hammerspoon
ProofIME/             SwiftUI reference app
ProofIMETests/        Swift test target
docs/                 User docs and architecture decisions
legacy/imk/           Archived InputMethodKit experiment
scripts/              Development and sanity-check scripts
```

## Troubleshooting

If nothing expands, first check that Hammerspoon has Accessibility permission, ProofIME is enabled, and the target app is not ignored. Terminal apps and password managers are ignored by default.

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more checks.

## Development

- Architecture notes: [ARCHITECTURE.md](ARCHITECTURE.md)
- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Testing notes: [TESTING.md](TESTING.md)
- Product direction: [PRODUCT_VISION.md](PRODUCT_VISION.md)
- Roadmap: [ROADMAP.md](ROADMAP.md)
