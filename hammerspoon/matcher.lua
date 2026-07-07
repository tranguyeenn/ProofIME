-- Loads categorized symbol rules and finds the longest trigger matching the buffer suffix.
local utils = require("utils")

local matcher = {}

local function trim(value)
  return value:match("^%s*(.-)%s*$")
end

local function isArray(values)
  if type(values) ~= "table" then
    return false
  end

  return values[1] ~= nil
end

local function isStringArray(values)
  if type(values) ~= "table" then
    return false
  end

  local length = #values

  for key, value in pairs(values) do
    if type(key) ~= "number" or key < 1 or key > length or key % 1 ~= 0 then
      return false
    end

    if type(value) ~= "string" then
      return false
    end
  end

  return true
end

local function normalizeLegacyRule(trigger, replacement, sourceName, defaultCategory, errors, rules)
  if type(trigger) ~= "string" then
    table.insert(errors, sourceName .. ": trigger must be a string")
    return
  end

  local normalizedTrigger = trim(trigger)

  if normalizedTrigger == "" then
    table.insert(errors, sourceName .. ": trigger cannot be empty")
  elseif type(replacement) ~= "string" then
    table.insert(errors, sourceName .. ": replacement for '" .. trigger .. "' must be a string")
  else
    table.insert(rules, {
      trigger = normalizedTrigger,
      replacement = replacement,
      description = nil,
      keywords = {},
      category = defaultCategory,
      source = sourceName,
    })
  end
end

local function normalizeMetadataRule(rawRule, index, sourceName, defaultCategory, errors, rules)
  local label = sourceName .. "[" .. tostring(index) .. "]"
  local initialErrorCount = #errors

  if type(rawRule) ~= "table" then
    table.insert(errors, label .. ": rule must be an object")
    return
  end

  local trigger = rawRule.trigger
  local replacement = rawRule.replacement
  local description = rawRule.description
  local keywords = rawRule.keywords
  local category = rawRule.category

  if type(trigger) ~= "string" then
    table.insert(errors, label .. ": trigger must be a string")
  elseif trim(trigger) == "" then
    table.insert(errors, label .. ": trigger cannot be empty")
  end

  if type(replacement) ~= "string" then
    table.insert(errors, label .. ": replacement must be a string")
  end

  if description ~= nil and type(description) ~= "string" then
    table.insert(errors, label .. ": description must be a string")
  end

  if keywords ~= nil and not isStringArray(keywords) then
    table.insert(errors, label .. ": keywords must be an array of strings")
  end

  if category ~= nil and type(category) ~= "string" then
    table.insert(errors, label .. ": category must be a string")
  end

  if #errors > initialErrorCount then
    return
  end

  table.insert(rules, {
    trigger = trim(trigger),
    replacement = replacement,
    description = description,
    keywords = keywords or {},
    category = category or defaultCategory,
    source = sourceName,
  })
end

local function normalizeRules(rawRules, sourceName, defaultCategory)
  if type(rawRules) ~= "table" then
    return nil, sourceName .. " is not a valid rule object or rule array"
  end

  local rules = {}
  local errors = {}

  if isArray(rawRules) then
    for index, rawRule in ipairs(rawRules) do
      normalizeMetadataRule(rawRule, index, sourceName, defaultCategory, errors, rules)
    end
  else
    for trigger, replacement in pairs(rawRules or {}) do
      normalizeLegacyRule(trigger, replacement, sourceName, defaultCategory, errors, rules)
    end
  end

  if #errors > 0 then
    return nil, table.concat(errors, "\n")
  end

  return rules, nil
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

local function lower(value)
  return string.lower(value or "")
end

local function contains(value, needle)
  return type(value) == "string" and needle ~= "" and lower(value):find(needle, 1, true) ~= nil
end

local function fuzzyContains(value, needle)
  if type(value) ~= "string" or needle == "" then
    return false
  end

  local haystack = lower(value)
  local needleIndex = 1

  for index = 1, #haystack do
    if haystack:sub(index, index) == needle:sub(needleIndex, needleIndex) then
      needleIndex = needleIndex + 1

      if needleIndex > #needle then
        return true
      end
    end
  end

  return false
end

local function candidateFromRule(rule, score, rankReason)
  return {
    trigger = rule.trigger,
    replacement = rule.replacement,
    description = rule.description,
    keywords = rule.keywords,
    category = rule.category,
    score = score,
    rankReason = rankReason,
  }
end

local function candidateQuery(bufferValue, triggerPrefix, requireTriggerPrefix)
  if type(bufferValue) ~= "string" then
    return nil
  end

  if requireTriggerPrefix then
    local prefixStart = lastPlainMatch(bufferValue, triggerPrefix)

    if not prefixStart then
      return nil
    end

    return trim(bufferValue:sub(prefixStart + #triggerPrefix))
  end

  if triggerPrefix ~= "" then
    local prefixStart = lastPlainMatch(bufferValue, triggerPrefix)

    if prefixStart then
      return trim(bufferValue:sub(prefixStart + #triggerPrefix))
    end
  end

  return trim(bufferValue)
end

local function rankRule(rule, query)
  if query == "" then
    return nil
  end

  local normalizedQuery = lower(query)
  local normalizedTrigger = lower(rule.trigger)

  if normalizedTrigger == normalizedQuery then
    return 1000, "exact"
  end

  if normalizedTrigger:sub(1, #normalizedQuery) == normalizedQuery then
    return 800 - (#normalizedTrigger - #normalizedQuery), "trigger-prefix"
  end

  if contains(rule.description, normalizedQuery) then
    return 600, "description"
  end

  for _, keyword in ipairs(rule.keywords or {}) do
    if contains(keyword, normalizedQuery) then
      return 600, "keyword"
    end
  end

  if fuzzyContains(rule.trigger, normalizedQuery) then
    return 400 - (#rule.trigger - #normalizedQuery), "fuzzy"
  end

  if fuzzyContains(rule.description, normalizedQuery) then
    return 350, "fuzzy-description"
  end

  for _, keyword in ipairs(rule.keywords or {}) do
    if fuzzyContains(keyword, normalizedQuery) then
      return 350, "fuzzy-keyword"
    end
  end

  return nil
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

  instance.log:i("Matcher rulesPath: " .. tostring(instance.rulesPath))
  instance.log:i("Matcher rulesDirectory: " .. tostring(instance.rulesDirectory))
  instance.log:i("Matcher indexPath: " .. tostring(instance.indexPath))

  function instance:updateMaxTriggerLength()
    self.maxTriggerLength = 0

    for _, rule in ipairs(self.rules) do
      self.maxTriggerLength = math.max(self.maxTriggerLength, #rule.trigger)
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
    self.log:i("Loading legacy rules from " .. tostring(self.rulesPath))

    local rawRules, errorMessage = utils.readJson(self.rulesPath)

    if not rawRules then
      return nil, "Could not load rules from " .. self.rulesPath .. ": " .. tostring(errorMessage)
    end

    local normalizedRules, validationError = normalizeRules(rawRules, "Legacy rules file at " .. self.rulesPath, nil)

    if not normalizedRules then
      return nil, validationError
    end

    return normalizedRules, nil, {}
  end

  function instance:loadCategory(category)
    local path = categoryPath(self.rulesDirectory, category)

    self.log:i("Loading rule category '" .. category .. "' from " .. path)

    local rawRules, errorMessage = utils.readJson(path)

    if not rawRules then
      return nil, "Could not load rule category '" .. category .. "' at " .. path .. ": " .. tostring(errorMessage)
    end

    local normalizedRules, validationError = normalizeRules(rawRules, "Rule category '" .. category .. "' at " .. path, category)

    if not normalizedRules then
      return nil, validationError
    end

    return normalizedRules
  end

  function instance:buildRules()
    self.log:i("Checking rules index at " .. tostring(self.indexPath))

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

    self.log:i("Enabled rule categories to load: " .. table.concat(categories, ", "))

    local mergedRules = {}
    local loadedCategories = {}

    for _, category in ipairs(categories) do
      local categoryRules, categoryError = self:loadCategory(category)

      if not categoryRules then
        return nil, categoryError
      end

      for _, rule in ipairs(categoryRules) do
        if mergedRules[rule.trigger] ~= nil then
          return nil, "Duplicate trigger '" .. rule.trigger .. "' found while loading category '" .. category .. "'"
        end

        mergedRules[rule.trigger] = rule
      end

      table.insert(loadedCategories, category)
    end

    self.log:i("Enabled rule categories loaded: " .. table.concat(loadedCategories, ", "))
    local rules = {}
    for _, rule in pairs(mergedRules) do
      table.insert(rules, rule)
    end

    return rules, nil, loadedCategories
  end

  function instance:loadRules()
    local rules, errorMessage, loadedCategories = self:buildRules()

    if not rules then
      self.log:e("Rule load failed: " .. tostring(errorMessage))

      return {
        ok = false,
        ruleCount = utils.countTable(self.rules),
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
    local bestRule = nil
    local bestTypedTrigger = nil

    for _, rule in ipairs(self.rules) do
      local trigger = rule.trigger

      if utils.endsWith(matchBuffer, trigger) and (not bestTrigger or #trigger > #bestTrigger) then
        bestTrigger = trigger
        bestRule = rule
        bestTypedTrigger = typedPrefix .. trigger
      end
    end

    if not bestTrigger then
      self.log:d("Matcher rule matched: nil")
      return nil
    end

    self.log:d("Matcher rule matched: '" .. bestTrigger .. "' -> '" .. bestRule.replacement .. "'")

    return {
      trigger = bestTypedTrigger,
      ruleTrigger = bestTrigger,
      replacement = bestRule.replacement,
      description = bestRule.description,
      keywords = bestRule.keywords,
      category = bestRule.category,
      source = bestRule.source,
    }
  end

  function instance:getCandidates(bufferValue, candidateConfig, limit)
    local effectiveConfig = candidateConfig or {}
    local triggerPrefix = effectiveConfig.triggerPrefix

    if triggerPrefix == nil then
      triggerPrefix = self.triggerPrefix
    end

    local requireTriggerPrefix = self.requireTriggerPrefix
    if effectiveConfig.requireTriggerPrefix ~= nil then
      requireTriggerPrefix = effectiveConfig.requireTriggerPrefix == true
    end

    local query = candidateQuery(bufferValue, triggerPrefix or "", requireTriggerPrefix)
    if not query or query == "" then
      return {}
    end

    local candidates = {}

    for _, rule in ipairs(self.rules) do
      local score, rankReason = rankRule(rule, query)

      if score then
        table.insert(candidates, candidateFromRule(rule, score, rankReason))
      end
    end

    table.sort(candidates, function(left, right)
      if left.score ~= right.score then
        return left.score > right.score
      end

      if #left.trigger ~= #right.trigger then
        return #left.trigger < #right.trigger
      end

      return left.trigger < right.trigger
    end)

    local maxResults = tonumber(limit) or #candidates
    local limitedCandidates = {}

    for index = 1, math.min(maxResults, #candidates) do
      table.insert(limitedCandidates, candidates[index])
    end

    return limitedCandidates
  end

  function instance:reload()
    self.log:i("Rule reload started")
    self.log:i("Reload using rulesDirectory: " .. tostring(self.rulesDirectory))
    self.log:i("Reload using indexPath: " .. tostring(self.indexPath))

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
