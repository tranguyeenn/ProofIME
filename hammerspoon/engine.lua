-- Coordinates typed input, rule matching, and text replacement.
-- This module intentionally knows little about Hammerspoon event details.
local engine = {}

function engine.new(options)
  local instance = {
    buffer = options.buffer,
    matcher = options.matcher,
    replacer = options.replacer,
    log = options.log,
  }

  function instance:clear()
    self.buffer:clear()
  end

  function instance:isReplacing()
    return self.replacer:isReplacing()
  end

  function instance:handleCharacter(char)
    self.buffer:append(char)

    local match = self.matcher:findMatch(self.buffer:get())
    if not match then
      return false
    end

    self.replacer:replace(match, function()
      self.buffer:clear()
    end)

    return true
  end

  function instance:handleDelete()
    local current = self.buffer:get()
    self.buffer:set(current:sub(1, -2))
  end

  function instance:reloadRules()
    local result = self.matcher:reload()

    if result and result.ok then
      self.buffer:setMaxLength(math.max(self.buffer.configuredMaxLength, self.matcher.maxTriggerLength))
      self.buffer:trim()
    end

    return result
  end

  return instance
end

return engine
