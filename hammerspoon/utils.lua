-- Shared helpers for strings, JSON, and filesystem path handling.
local utils = {}

function utils.endsWith(value, suffix)
  if not value or not suffix or suffix == "" then
    return false
  end

  return value:sub(-#suffix) == suffix
end

function utils.trimToLength(value, maxLength)
  if not value or not maxLength or #value <= maxLength then
    return value or ""
  end

  return value:sub(-maxLength)
end

function utils.countTable(values)
  local count = 0

  for _, _ in pairs(values or {}) do
    count = count + 1
  end

  return count
end

function utils.dirnameFromSource(source)
  if type(source) ~= "string" or source:sub(1, 1) ~= "@" then
    return nil
  end

  return source:sub(2):match("(.*/)")
end

function utils.fileExists(path)
  local file = io.open(path, "r")

  if file then
    file:close()
    return true
  end

  return false
end

function utils.readJson(path)
  local ok, result, errorMessage = pcall(hs.json.read, path)

  if not ok then
    return nil, result
  end

  return result, errorMessage
end

return utils
