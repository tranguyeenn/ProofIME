-- Loads categorized symbol rules and finds the longest trigger matching the buffer suffix.
local utils = require("utils")

local matcher = {}

local function normalizeRules(rawRules)
  if type(rawRules) ~= "table" then
    return nil
  end

  local rules = {}

  for trigger, replacement in pairs(rawRules or {}) do
    if type(trigger) == "string" and type(replacement) == "string" then
      rules[trigger] = replacement
    end
  end

  return rules
end

local function directoryForPath(path)
  return path:match("(.*/)")
end

local function categoryPath(rulesDirectory, category)
  return rulesDirectory .. category .. ".json"
end

local function lastPlainMatch(value, needle)
  if type(value) ~= "string" or type(needle) ~= "string" or needle == "" then
    return nil
  end

  local lastStart = nil
  local startIndex = 1

  while true do
    local matchStart = value:find(needle, startIndex, true)
    if not matchStart then
      return lastStart
    end

    lastStart = matchStart
    startIndex = matchStart + #needle
  end
end

local function enabledCategories(index)
  if type(index) ~= "table" or type(index.enabled) ~= "table" then
    return nil
  end

  local categories = {}

  for _, category in ipairs(index.enabled) do
    if type(category) == "string" and category ~= "" then
      table.insert(categories, category)
    end
  end

  return categories
end

function matcher.new(options)
  local instance = {
    rulesPath = options.rulesPath,
    rulesDirectory = directoryForPath(options.rulesPath) or "",
    indexPath = (directoryForPath(options.rulesPath) or "") .. "index.json",
    log = options.log,
    triggerPrefix = options.triggerPrefix or "",
    requireTriggerPrefix = options.requireTriggerPrefix == true,
    rules = {},
    maxTriggerLength = 0,
  }

  function instance:updateMaxTriggerLength()
    self.maxTriggerLength = 0

    for trigger, _ in pairs(self.rules) do
      self.maxTriggerLength = math.max(self.maxTriggerLength, #trigger)
    end

    if self.requireTriggerPrefix then
      self.maxTriggerLength = self.maxTriggerLength + #self.triggerPrefix
    end
  end

  function instance:applyRules(rules)
    self.rules = rules or {}
    self:updateMaxTriggerLength()
  end

  function instance:buildLegacyRules()
    -- TODO: Remove symbols.json fallback after categorized rules are the only supported format.
    local rawRules, errorMessage = utils.readJson(self.rulesPath)

    if not rawRules then
      return nil, "Could not load rules from " .. self.rulesPath .. ": " .. tostring(errorMessage)
    end

    local normalizedRules = normalizeRules(rawRules)
    if not normalizedRules then
      return nil, "Legacy rules file at " .. self.rulesPath .. " is not a valid rule object"
    end

    return normalizedRules, nil, {}
  end

  function instance:loadCategory(category)
    local path = categoryPath(self.rulesDirectory, category)
    local rawRules, errorMessage = utils.readJson(path)

    if not rawRules then
      return nil, "Could not load rule category '" .. category .. "' at " .. path .. ": " .. tostring(errorMessage)
    end

    local normalizedRules = normalizeRules(rawRules)
    if not normalizedRules then
      return nil, "Rule category '" .. category .. "' at " .. path .. " is not a valid rule object"
    end

    return normalizedRules
  end

  function instance:buildRules()
    if not utils.fileExists(self.indexPath) then
      self.log:w("Rules index not found at " .. self.indexPath .. "; falling back to legacy symbols.json")
      return self:buildLegacyRules()
    end

    local index, errorMessage = utils.readJson(self.indexPath)

    if not index then
      return nil, "Rules index at " .. self.indexPath .. " is invalid: " .. tostring(errorMessage)
    end

    self.log:i("Rules index loaded from " .. self.indexPath)

    local categories = enabledCategories(index)
    if not categories then
      return nil, "Rules index at " .. self.indexPath .. " has no valid enabled category list"
    end

    local mergedRules = {}
    local loadedCategories = {}

    for _, category in ipairs(categories) do
      local categoryRules, categoryError = self:loadCategory(category)

      if not categoryRules then
        return nil, categoryError
      end

      for trigger, replacement in pairs(categoryRules) do
        mergedRules[trigger] = replacement
      end

      table.insert(loadedCategories, category)
    end

    self.log:i("Enabled rule categories loaded: " .. table.concat(loadedCategories, ", "))
    return mergedRules, nil, loadedCategories
  end

  function instance:loadRules()
    local rules, errorMessage, loadedCategories = self:buildRules()

    if not rules then
      self.log:e("Rule load failed: " .. tostring(errorMessage))
      self:applyRules({})
      return {
        ok = false,
        ruleCount = 0,
        error = errorMessage,
      }
    end

    self:applyRules(rules)

    self.log:i(
      "Loaded "
        .. tostring(utils.countTable(self.rules))
        .. " ProofIME rules from categories: "
        .. table.concat(loadedCategories or {}, ", ")
    )
    self.log:i("Active rule count: " .. tostring(utils.countTable(self.rules)))

    return {
      ok = true,
      ruleCount = utils.countTable(self.rules),
      error = nil,
    }
  end

  function instance:findMatch(bufferValue)
    self.log:d("Matcher raw buffer: '" .. tostring(bufferValue) .. "'")

    local matchBuffer = bufferValue
    local typedPrefix = ""

    if self.requireTriggerPrefix then
      local prefixStart = lastPlainMatch(bufferValue, self.triggerPrefix)

      if not prefixStart then
        self.log:d("Matcher prefix detection: missing prefix '" .. tostring(self.triggerPrefix) .. "'")
        self.log:d("Matcher buffer after stripping prefix: nil")
        self.log:d("Matcher rule matched: nil")
        return nil
      end

      typedPrefix = self.triggerPrefix
      matchBuffer = bufferValue:sub(prefixStart + #self.triggerPrefix)
      self.log:d(
        "Matcher prefix detection: found prefix '"
          .. tostring(self.triggerPrefix)
          .. "' at buffer index "
          .. tostring(prefixStart)
      )
      self.log:d("Matcher buffer after stripping prefix: '" .. tostring(matchBuffer) .. "'")
    else
      self.log:d("Matcher prefix detection: disabled")
      self.log:d("Matcher buffer after stripping prefix: '" .. tostring(matchBuffer) .. "'")
    end

    local bestTrigger = nil
    local bestReplacement = nil
    local bestTypedTrigger = nil

    for trigger, replacement in pairs(self.rules) do
      if utils.endsWith(matchBuffer, trigger) and (not bestTrigger or #trigger > #bestTrigger) then
        bestTrigger = trigger
        bestReplacement = replacement
        bestTypedTrigger = typedPrefix .. trigger
      end
    end

    if not bestTrigger then
      self.log:d("Matcher rule matched: nil")
      return nil
    end

    self.log:d("Matcher rule matched: '" .. bestTrigger .. "' -> '" .. bestReplacement .. "'")

    return {
      trigger = bestTypedTrigger,
      ruleTrigger = bestTrigger,
      replacement = bestReplacement,
    }
  end

  function instance:reload()
    self.log:i("Rule reload started")
    local rules, errorMessage, loadedCategories = self:buildRules()

    if not rules then
      self.log:e("Rule reload failed: " .. tostring(errorMessage))
      self.log:i("Keeping previous active rule set with " .. tostring(utils.countTable(self.rules)) .. " rules")
      return {
        ok = false,
        ruleCount = utils.countTable(self.rules),
        error = errorMessage,
      }
    end

    self:applyRules(rules)

    self.log:i("Rule reload categories: " .. table.concat(loadedCategories or {}, ", "))
    self.log:i("Rule reload count: " .. tostring(utils.countTable(self.rules)))
    self.log:i("Rule reload succeeded")

    return {
      ok = true,
      ruleCount = utils.countTable(self.rules),
      error = nil,
    }
  end

  instance:loadRules()
  return instance
end

return matcher
