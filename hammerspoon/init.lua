local config = require("config")

local log = hs.logger.new("ProofIME", config.logLevel)
local engine = require("engine").new({
  rulesPath = config.rulesPath,
  log = log,
})

local keyboard = require("keyboard").new({
  enabled = config.enabled,
  engine = engine,
  log = log,
  bufferMaxLength = math.max(config.bufferMaxLength, engine.maxTriggerLength),
})

keyboard:start()

hs.hotkey.bind(config.toggleHotkey.mods, config.toggleHotkey.key, function()
  keyboard:toggle()
end)

log.i("ProofIME Hammerspoon backend loaded")
