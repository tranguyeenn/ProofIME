-- Keyboard event adapter. It translates Hammerspoon key events into engine input.
local keyboard = {}

local function hasCommandModifier(flags)
  return flags.cmd or flags.ctrl or flags.alt or flags.fn
end

local function isModifierOnly(text)
  return not text or text == ""
end

local function applicationIdentifiers(app)
  if not app then
    return nil, nil
  end

  return app:name(), app:bundleID()
end

function keyboard.new(options)
  local instance = {
    enabled = options.enabled,
    engine = options.engine,
    log = options.log,
    ignoredApplications = options.ignoredApplications or {},
    ignoredBundleIDs = options.ignoredBundleIDs or {},
    toggleHotkey = options.toggleHotkey,
    reloadHotkey = options.reloadHotkey,
    cheatSheetHotkey = options.cheatSheetHotkey,
    cheatSheet = options.cheatSheet,
    triggerPrefix = options.triggerPrefix or "",
    eventtap = nil,
    hotkey = nil,
    reloadHotkeyBinding = nil,
    cheatSheetHotkeyBinding = nil,
  }

  function instance:setEnabled(enabled)
    self.enabled = enabled
    self.engine:clear()
    self.log:i("ProofIME " .. (enabled and "enabled" or "disabled"))
  end

  function instance:toggle()
    self:setEnabled(not self.enabled)
  end

  function instance:showReloadSuccess(ruleCount)
    hs.alert.show("ProofIME: Reloaded " .. tostring(ruleCount) .. " rules", 1.5)
  end

  function instance:showReloadFailure()
    hs.alert.show("ProofIME: Reload failed", 2)
  end

  function instance:reloadRules()
    self.log:i("Rule reload started from keyboard hotkey")
    local result = self.engine:reloadRules()

    if result and result.ok then
      self.engine:clear()
      self.log:i("Rule reload succeeded from keyboard hotkey")
      self.log:i("Rule reload count from keyboard hotkey: " .. tostring(result.ruleCount))
      self:showReloadSuccess(result.ruleCount)
    else
      local errorMessage = result and result.error or "unknown reload error"
      self.log:e("Rule reload failed from keyboard hotkey: " .. tostring(errorMessage))
      self:showReloadFailure()
    end
  end

  function instance:isIgnoredApplication()
    local appName, bundleID = applicationIdentifiers(hs.application.frontmostApplication())

    if not appName and not bundleID then
      return false
    end

    for _, ignored in ipairs(self.ignoredApplications) do
      if appName == ignored then
        self.log:d("Ignoring application by name: " .. tostring(appName))
        return true
      end
    end

    for _, ignored in ipairs(self.ignoredBundleIDs) do
      if bundleID == ignored then
        self.log:d("Ignoring application by bundle ID: " .. tostring(bundleID))
        return true
      end
    end

    return false
  end

  function instance:handleKey(event)
    if not self.enabled or self.engine:isReplacing() then
      return false
    end

    if self:isIgnoredApplication() then
      self.engine:clear()
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

    if #text == 1 and (text:match("[%w]") or text == self.triggerPrefix) then
      self.engine:handleCharacter(text)
    else
      self.engine:clear()
    end

    return false
  end

  function instance:start()
    if self.eventtap then
      self.log:w("ProofIME keyboard watcher already started")
      return
    end

    self.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
      return self:handleKey(event)
    end)

    self.eventtap:start()

    if self.toggleHotkey then
      self.hotkey = hs.hotkey.bind(self.toggleHotkey.mods, self.toggleHotkey.key, function()
        self:toggle()
      end)
    end

    if self.reloadHotkey then
      self.reloadHotkeyBinding = hs.hotkey.bind(self.reloadHotkey.mods, self.reloadHotkey.key, function()
        self:reloadRules()
      end)
    end

    if self.cheatSheetHotkey and self.cheatSheet then
      self.cheatSheetHotkeyBinding = hs.hotkey.bind(self.cheatSheetHotkey.mods, self.cheatSheetHotkey.key, function()
        self.cheatSheet:show()
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

    if self.reloadHotkeyBinding then
      self.reloadHotkeyBinding:delete()
      self.reloadHotkeyBinding = nil
    end

    if self.cheatSheetHotkeyBinding then
      self.cheatSheetHotkeyBinding:delete()
      self.cheatSheetHotkeyBinding = nil
    end
  end

  return instance
end

return keyboard
