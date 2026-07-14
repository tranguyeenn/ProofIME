# Customization

ProofIME's active Hammerspoon backend loads symbol rules from `rules/`.

## Enable or Disable Categories

`rules/index.json` controls which categories are loaded:

```json
{
  "enabled": [
    "logic",
    "sets",
    "relations",
    "arrows",
    "greek",
    "calc+proof"
  ]
}
```

Remove a category name to disable it. Add a category name to load `rules/<category>.json`.

After changing rules, press `cmd` + `ctrl` + `alt` + `r` to reload without restarting Hammerspoon.

## Rule Formats

ProofIME accepts two JSON formats.

Compact object format:

```json
{
  "qed": "∎",
  "there": "∴"
}
```

Metadata array format:

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

The metadata format gives the cheat sheet better search text and category labels.

## Rule Requirements

- `trigger` must be a non-empty string.
- `replacement` must be a string.
- `description`, if present, must be a string.
- `keywords`, if present, must be an array of strings.
- `category`, if present, must be a string.
- Triggers must be unique across all enabled categories.

If reload fails, ProofIME keeps the previous working rule set active and writes the detailed error to the Hammerspoon log.

## Trigger Prefix

The default configuration requires `:` before every trigger:

```lua
config.triggerPrefix = ":"
config.requireTriggerPrefix = true
```

With this setting, `:or` expands to `∨`, but `or` does not.

To allow bare triggers, edit `hammerspoon/config.lua`:

```lua
config.requireTriggerPrefix = false
```

Bare triggers are easier to type but more likely to collide with normal prose.

## Hotkeys and Ignored Apps

Edit `hammerspoon/config.lua` to change hotkeys or ignored apps.

Relevant settings:

```lua
config.toggleHotkey = {
  mods = { "cmd", "alt", "ctrl" },
  key = "p",
}

config.reloadHotkey = {
  mods = { "cmd", "ctrl", "alt" },
  key = "r",
}

config.cheatSheetHotkey = {
  mods = { "cmd", "ctrl", "alt" },
  key = "/",
}
```

Reload Hammerspoon after editing `config.lua`.

## SwiftUI Reference App Config

The SwiftUI app stores optional user files under:

```text
~/Library/Application Support/ProofIME/
```

Supported filenames:

```text
symbols.json
proof_templates.json
```

Use the app's Config menu to open the folder, import custom symbol JSON, reload config, or delete custom files.
