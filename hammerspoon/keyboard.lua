local keyboard = {}

local function hasCommandModifier(flags)
  return flags.cmd or flags.ctrl or flags.alt or flags.fn
end

local function trimBuffer(buffer, maxLength)
  if #buffer <= maxLength then
    return buffer
  end

  return buffer:sub(-maxLength)
end

function keyboard.new(options)
  local instance = {
    enabled = options.enabled,
    engine = options.engine,
    log = options.log,
    buffer = "",
    bufferMaxLength = options.bufferMaxLength,
    eventtap = nil,
    replacing = false,
  }

  function instance:setEnabled(enabled)
    self.enabled = enabled
    self.buffer = ""
    self.log.i("ProofIME " .. (enabled and "enabled" or "disabled"))
  end

  function instance:toggle()
    self:setEnabled(not self.enabled)
  end

  function instance:replace(match)
    self.replacing = true

    hs.timer.doAfter(0, function()
      for _ = 1, #match.trigger do
        hs.eventtap.keyStroke({}, "delete", 0)
      end

      hs.eventtap.keyStrokes(match.replacement)
      self.buffer = ""
      self.log.d("Expanded '" .. match.trigger .. "' to '" .. match.replacement .. "'")

      hs.timer.doAfter(0.05, function()
        self.replacing = false
      end)
    end)
  end

  function instance:handleKey(event)
    if not self.enabled or self.replacing then
      return false
    end

    local flags = event:getFlags()
    local keyCode = event:getKeyCode()
    local text = event:getCharacters()

    if keyCode == hs.keycodes.map.delete then
      self.buffer = self.buffer:sub(1, -2)
      return false
    end

    if hasCommandModifier(flags) or not text or #text ~= 1 then
      self.buffer = ""
      return false
    end

    if text:match("[%w]") then
      self.buffer = trimBuffer(self.buffer .. text, self.bufferMaxLength)
      local match = self.engine:match(self.buffer)

      if match then
        self:replace(match)
      end
    else
      self.buffer = ""
    end

    return false
  end

  function instance:start()
    self.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
      return self:handleKey(event)
    end)

    self.eventtap:start()
    self.log.i("ProofIME keyboard watcher started")
  end

  return instance
end

return keyboard
