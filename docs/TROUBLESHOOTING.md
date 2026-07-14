# Troubleshooting

## Nothing Expands

Check these first:

1. Hammerspoon is running.
2. Hammerspoon has Accessibility permission in macOS System Settings.
3. ProofIME was loaded from `~/.hammerspoon/init.lua`.
4. ProofIME is enabled. Press `cmd` + `alt` + `ctrl` + `p` once and try again.
5. You are typing the `:` prefix, such as `:fa`.
6. The current app is not in the ignored app list.

Terminal apps and password managers are ignored by default.

## The Cheat Sheet Does Not Open

Press `cmd` + `ctrl` + `alt` + `/`.

If nothing happens:

- Reload Hammerspoon.
- Open the Hammerspoon console and look for `ProofIME` log messages.
- Check that the hotkey is not already captured by another app.

## Rule Reload Fails

When `cmd` + `ctrl` + `alt` + `r` reports a reload failure, ProofIME keeps the last working rules active.

Common causes:

- Invalid JSON syntax.
- A category listed in `rules/index.json` has no matching `rules/<category>.json` file.
- A rule object is missing `trigger` or `replacement`.
- Two enabled categories define the same trigger.

Open the Hammerspoon console for the detailed validation error.

## Some Apps Do Not Work Reliably

ProofIME uses Hammerspoon event observation and text insertion. Behavior can vary by host app, especially apps with custom editors or strict security behavior.

Try a basic macOS text field first, such as TextEdit. If it works there but not in another app, the host app may handle keyboard events or text insertion differently.

## A Trigger Expands When You Do Not Want It To

Keep `config.requireTriggerPrefix = true` in `hammerspoon/config.lua`.

If a prefixed trigger still collides with your writing, rename or remove that trigger from the relevant file in `rules/`, then reload rules.

## SwiftUI App Does Not Affect Other Apps

That is expected. The SwiftUI app is a standalone reference editor. Use the Hammerspoon backend for system-wide typing assistance.
