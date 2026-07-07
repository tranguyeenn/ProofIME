-- Applies matched replacements by deleting the trigger and inserting Unicode text.
local replacer = {}

function replacer.new(options)
  local instance = {
    log = options.log,
    mode = options.mode or "unicode",
    replacing = false,
  }

  function instance:isReplacing()
    return self.replacing
  end

  function instance:replace(match, onComplete)
    self.replacing = true

    -- TODO: Use replacementMode when alternate output modes are introduced.
    hs.timer.doAfter(0, function()
      local backspaceCount = #match.trigger
      self.log:d("Replacement backspaces sent: " .. tostring(backspaceCount))

      for _ = 1, backspaceCount do
        hs.eventtap.keyStroke({}, "delete", 0)
      end

      hs.eventtap.keyStrokes(match.replacement)
      self.log:d("Expanded '" .. match.trigger .. "' to '" .. match.replacement .. "'")

      if onComplete then
        onComplete()
      end

      hs.timer.doAfter(0.05, function()
        self.replacing = false
      end)
    end)
  end

  return instance
end

return replacer
