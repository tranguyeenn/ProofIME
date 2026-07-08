-- Central configuration for the Hammerspoon backend.
-- Keep runtime knobs here so the other modules can stay small and focused.
local utils = require("utils")

local config = {}

config.enabled = true
config.debug = false
config.maxBufferLength = 16
config.triggerPrefix = ":"
config.requireTriggerPrefix = true
config.ignoredApplications = {
  "Terminal",
  "iTerm2",
  "Warp",
  "Ghostty",
  "Alacritty",
  "kitty",
  "1Password",
  "KeePassXC",
  "Bitwarden"
}
config.ignoredBundleIDs = {
  "com.apple.Terminal",
  "com.googlecode.iterm2",
  "dev.warp.Warp-Stable",
  "com.mitchellh.ghostty",
  "org.alacritty",
  "net.kovidgoyal.kitty",
  "com.1password.1password",
  "org.keepassxc.keepassxc",
  "com.bitwarden.desktop"
}
config.replacementMode = "unicode"
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

local source = debug.getinfo(1, "S").source
local directory = utils.dirnameFromSource(source) or (hs.configdir .. "/proofime/hammerspoon/")

config.rulesPath = directory .. "../rules/symbols.json"

return config
