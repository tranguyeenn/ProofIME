local config = {}

config.enabled = true
config.bufferMaxLength = 16
config.logLevel = "info"

config.toggleHotkey = {
  mods = { "cmd", "alt", "ctrl" },
  key = "p",
}

local source = debug.getinfo(1, "S").source
local directory = source:sub(1, 1) == "@" and source:sub(2):match("(.*/)")
  or hs.configdir .. "/proofime/hammerspoon/"

config.rulesPath = directory .. "../rules/symbols.json"

return config
