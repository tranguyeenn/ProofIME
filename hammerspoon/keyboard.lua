-- Keyboard event adapter. It translates Hammerspoon key events into engine input.
local keyboard = {}

local function hasCommandModifier(flags)
  return flags.cmd or flags.ctrl or flags.alt or flags.fn
end

local function isModifierOnly(text)
  return not text or text == ""
end

local function applicationIdentifier(app)
  if not app then
    return nil
  end

  return app:bundleID() or app:name()
end

function keyboard.new(options)
  local instance = {
    enabled = options.enabled,
    engine = options.engine,
    log = options.log,
    ignoredApplications = options.ignoredApplications or {},
    toggleHotkey = options.toggleHotkey,
    eventtap = nil,
    hotkey = nil,
  }

  function instance:setEnabled(enabled)
    self.enabled = enabled
    self.engine:clear()
    self.log:i("ProofIME " .. (enabled and "enabled" or "disabled"))
  end

  function instance:toggle()
    self:setEnabled(not self.enabled)
  end

  function instance:isIgnoredApplication()
    local identifier = applicationIdentifier(hs.application.frontmostApplication())
    if not identifier then
      return false
    end

    for _, ignored in ipairs(self.ignoredApplications) do
      if identifier == ignored then
        return true
      end
    end

    return false
  end

  function instance:handleKey(event)
    if not self.enabled or self.engine:isReplacing() or self:isIgnoredApplication() then
      return false
    end

    local flags = event:getFlags()
    local keyCode = event:getKeyCode()
    local text = event:getCharacters()

    if keyCode == hs.keycodes.map.delete then
      self.engine:handleDelete()
      return false
    end

    if isModifierOnly(text) then
      return false
    end

    if hasCommandModifier(flags) then
      self.engine:clear()
      return false
    end

    if #text == 1 and text:match("[%w]") then
      self.engine:handleCharacter(text)
    else
      self.engine:clear()
    end

    return false
  end

  function instance:start()
    self.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
      return self:handleKey(event)
    end)

    self.eventtap:start()

    if self.toggleHotkey then
      self.hotkey = hs.hotkey.bind(self.toggleHotkey.mods, self.toggleHotkey.key, function()
        self:toggle()
      end)
    end

    self.log:i("ProofIME keyboard watcher started")
  end

  function instance:stop()
    if self.eventtap then
      self.eventtap:stop()
      self.eventtap = nil
    end

    if self.hotkey then
      self.hotkey:delete()
      self.hotkey = nil
    end
  end

  return instance
end

return keyboard
