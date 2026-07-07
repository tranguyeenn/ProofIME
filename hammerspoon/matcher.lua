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
    rules = {},
    maxTriggerLength = 0,
  }

  function instance:updateMaxTriggerLength()
    self.maxTriggerLength = 0

    for trigger, _ in pairs(self.rules) do
      self.maxTriggerLength = math.max(self.maxTriggerLength, #trigger)
    end
  end

  function instance:loadLegacyRules()
    -- TODO: Remove symbols.json fallback after categorized rules are the only supported format.
    local rawRules, errorMessage = utils.readJson(self.rulesPath)

    if not rawRules then
      self.log:e("Could not load rules from " .. self.rulesPath .. ": " .. tostring(errorMessage))
      self.rules = {}
      self.maxTriggerLength = 0
      return false
    end

    local normalizedRules = normalizeRules(rawRules)
    if not normalizedRules then
      self.log:e("Legacy rules file at " .. self.rulesPath .. " is not a valid rule object")
      self.rules = {}
      self.maxTriggerLength = 0
      return false
    end

    self.rules = normalizedRules
    self:updateMaxTriggerLength()

    self.log:i("Loaded " .. tostring(utils.countTable(self.rules)) .. " ProofIME rules from legacy symbols.json")
    return true
  end

  function instance:loadCategory(category)
    local path = categoryPath(self.rulesDirectory, category)
    local rawRules, errorMessage = utils.readJson(path)

    if not rawRules then
      self.log:w("Skipping rule category '" .. category .. "' at " .. path .. ": " .. tostring(errorMessage))
      return nil
    end

    local normalizedRules = normalizeRules(rawRules)
    if not normalizedRules then
      self.log:w("Skipping rule category '" .. category .. "' at " .. path .. ": expected a JSON object")
      return nil
    end

    return normalizedRules
  end

  function instance:loadRules()
    if not utils.fileExists(self.indexPath) then
      self.log:w("Rules index not found at " .. self.indexPath .. "; falling back to legacy symbols.json")
      return self:loadLegacyRules()
    end

    local index, errorMessage = utils.readJson(self.indexPath)

    if not index then
      self.log:w("Rules index at " .. self.indexPath .. " is invalid: " .. tostring(errorMessage))
      self.rules = {}
      self.maxTriggerLength = 0
      return false
    end

    local categories = enabledCategories(index)
    if not categories then
      self.log:w("Rules index at " .. self.indexPath .. " has no valid enabled category list")
      self.rules = {}
      self.maxTriggerLength = 0
      return false
    end

    local mergedRules = {}
    local loadedCategories = {}

    for _, category in ipairs(categories) do
      local categoryRules = self:loadCategory(category)

      if categoryRules then
        for trigger, replacement in pairs(categoryRules) do
          mergedRules[trigger] = replacement
        end

        table.insert(loadedCategories, category)
      end
    end

    self.rules = mergedRules
    self:updateMaxTriggerLength()

    self.log:i(
      "Loaded "
        .. tostring(utils.countTable(self.rules))
        .. " ProofIME rules from categories: "
        .. table.concat(loadedCategories, ", ")
    )

    return true
  end

  function instance:findMatch(bufferValue)
    local bestTrigger = nil
    local bestReplacement = nil

    for trigger, replacement in pairs(self.rules) do
      if utils.endsWith(bufferValue, trigger) and (not bestTrigger or #trigger > #bestTrigger) then
        bestTrigger = trigger
        bestReplacement = replacement
      end
    end

    if not bestTrigger then
      return nil
    end

    return {
      trigger = bestTrigger,
      replacement = bestReplacement,
    }
  end

  function instance:reload()
    return self:loadRules()
  end

  instance:loadRules()
  return instance
end

return matcher
