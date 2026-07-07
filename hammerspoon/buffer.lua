-- Rolling typed buffer used for suffix-based trigger matching.
local utils = require("utils")

local buffer = {}

function buffer.new(options)
  local maxLength = options.maxLength

  local instance = {
    value = "",
    maxLength = maxLength,
    configuredMaxLength = maxLength,
  }

  function instance:append(char)
    self.value = self.value .. char
    self:trim()
  end

  function instance:clear()
    self.value = ""
  end

  function instance:get()
    return self.value
  end

  function instance:set(value)
    self.value = value or ""
    self:trim()
  end

  function instance:setMaxLength(max)
    self.maxLength = max
  end

  function instance:trim()
    self.value = utils.trimToLength(self.value, self.maxLength)
  end

  return instance
end

return buffer
