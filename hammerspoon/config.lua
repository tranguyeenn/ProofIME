-- Central configuration for the Hammerspoon backend.
-- Keep runtime knobs here so the other modules can stay small and focused.
local utils = require("utils")

local config = {}

config.enabled = true
config.debug = false
config.maxBufferLength = 16
config.triggerPrefix = ":"
config.requireTriggerPrefix = true
config.ignoredApplications = {}
config.replacementMode = "unicode"

config.toggleHotkey = {
  mods = { "cmd", "alt", "ctrl" },
  key = "p",
}

local source = debug.getinfo(1, "S").source
local directory = utils.dirnameFromSource(source) or (hs.configdir .. "/proofime/hammerspoon/")

config.rulesPath = directory .. "../rules/symbols.json"

return config
