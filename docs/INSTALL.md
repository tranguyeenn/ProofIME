# Installation

This guide sets up the active Hammerspoon backend.

## Requirements

- macOS
- Hammerspoon
- A local checkout of this repository

The SwiftUI reference app additionally requires a compatible local Xcode installation.

## Install Hammerspoon

Install Hammerspoon from <https://www.hammerspoon.org/> or with Homebrew:

```sh
brew install --cask hammerspoon
```

Launch Hammerspoon once before continuing.

## Grant Accessibility Permission

ProofIME needs Hammerspoon to observe keystrokes and insert replacement text.

1. Open macOS System Settings.
2. Go to Privacy & Security > Accessibility.
3. Enable Hammerspoon.
4. If Hammerspoon was already running, reload it or quit and reopen it.

## Load ProofIME

Open `~/.hammerspoon/init.lua`. Create the file if it does not exist.

Add these lines, using the path to your local checkout:

```lua
package.path = package.path .. ";/Users/trangnguyen/dev/ProofIME/hammerspoon/?.lua"
dofile("/Users/trangnguyen/dev/ProofIME/hammerspoon/init.lua")
```

Reload Hammerspoon from the menu bar icon or the Hammerspoon console.

## Verify Setup

In a normal macOS text field, type:

```text
:fa
```

The text should become:

```text
∀
```

Then press `cmd` + `ctrl` + `alt` + `/` to open the ProofIME cheat sheet.

## Optional: Run the SwiftUI Reference App

1. Open `ProofIME.xcodeproj` in Xcode.
2. Select the `ProofIME` scheme.
3. Run the app.

The app is a standalone editor and reference surface. It does not install a system-wide input method.
