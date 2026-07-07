-- Hammerspoon entrypoint. It wires modules together and starts listeners.
local config = require("config")
local logger = require("logger")
local buffer = require("buffer")
local matcher = require("matcher")
local replacer = require("replacer")
local engine = require("engine")
local keyboard = require("keyboard")

local log = logger.new({
  name = "ProofIME",
  debug = config.debug,
})

local ruleMatcher = matcher.new({
  rulesPath = config.rulesPath,
  log = log,
  triggerPrefix = config.triggerPrefix,
  requireTriggerPrefix = config.requireTriggerPrefix,
})

local typedBuffer = buffer.new({
  maxLength = math.max(config.maxBufferLength, ruleMatcher.maxTriggerLength),
})

local textReplacer = replacer.new({
  log = log,
  mode = config.replacementMode,
})

local proofEngine = engine.new({
  buffer = typedBuffer,
  matcher = ruleMatcher,
  replacer = textReplacer,
  log = log,
})

local keyboardListener = keyboard.new({
  enabled = config.enabled,
  engine = proofEngine,
  log = log,
  ignoredApplications = config.ignoredApplications,
  toggleHotkey = config.toggleHotkey,
  reloadHotkey = config.reloadHotkey,
  triggerPrefix = config.triggerPrefix,
  ignoredBundleIDs = config.ignoredBundleIDs,
})

keyboardListener:start()

log:i("ProofIME Hammerspoon backend loaded")
