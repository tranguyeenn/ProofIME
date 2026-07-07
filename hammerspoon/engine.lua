local engine = {}

local function normalizeRules(rawRules)
  local rules = {}

  for trigger, replacement in pairs(rawRules or {}) do
    if type(trigger) == "string" and type(replacement) == "string" then
      rules[trigger] = replacement
    end
  end

  return rules
end

function engine.new(options)
  local instance = {
    rulesPath = options.rulesPath,
    log = options.log,
    rules = {},
    maxTriggerLength = 0,
  }

  function instance:load()
    local rawRules, errorMessage = hs.json.read(self.rulesPath)

    if not rawRules then
      self.log.e("Could not load rules from " .. self.rulesPath .. ": " .. tostring(errorMessage))
      self.rules = {}
      self.maxTriggerLength = 0
      return false
    end

    self.rules = normalizeRules(rawRules)
    self.maxTriggerLength = 0

    for trigger, _ in pairs(self.rules) do
      self.maxTriggerLength = math.max(self.maxTriggerLength, #trigger)
    end

    self.log.i("Loaded " .. tostring(self:count()) .. " ProofIME rules")
    return true
  end

  function instance:count()
    local count = 0

    for _, _ in pairs(self.rules) do
      count = count + 1
    end

    return count
  end

  function instance:match(buffer)
    local bestTrigger = nil
    local bestReplacement = nil

    for trigger, replacement in pairs(self.rules) do
      if buffer:sub(-#trigger) == trigger and (not bestTrigger or #trigger > #bestTrigger) then
        bestTrigger = trigger
        bestReplacement = replacement
      end
    end

    if bestTrigger then
      return {
        trigger = bestTrigger,
        replacement = bestReplacement,
      }
    end

    return nil
  end

  instance:load()
  return instance
end

return engine
