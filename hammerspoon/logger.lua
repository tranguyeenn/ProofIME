-- Small timestamped logging wrapper around hs.logger.
local logger = {}

local function formatMessage(message)
  return os.date("%Y-%m-%d %H:%M:%S") .. " " .. tostring(message)
end

function logger.new(options)
  local debugEnabled = options.debug == true
  local hsLogger = hs.logger.new(options.name or "ProofIME", debugEnabled and "debug" or "info")

  local instance = {
    debugEnabled = debugEnabled,
    raw = hsLogger,
  }

  function instance:setDebug(enabled)
    self.debugEnabled = enabled == true
    self.raw.setLogLevel(self.debugEnabled and "debug" or "info")
  end

  function instance:d(message)
    if self.debugEnabled then
      self.raw.d(formatMessage(message))
    end
  end

  function instance:i(message)
    self.raw.i(formatMessage(message))
  end

  function instance:w(message)
    self.raw.w(formatMessage(message))
  end

  function instance:e(message)
    self.raw.e(formatMessage(message))
  end

  return instance
end

return logger
