package.path = "hammerspoon/?.lua;" .. package.path

local originalHs = hs

local function run()
  hs = {
    json = {
      read = function(path)
        if path:match("symbols%.json$") then
          return {
            fa = "∀",
            ["in"] = "∈",
            le = "≤",
            neq = "≠",
            lambda = "λ",
            int = "∫",
            or = "∨",
          }
        end

        return nil, "not found"
      end,
    },
  }

  local matcher = require("matcher")

  local log = {
    d = function() end,
    i = function() end,
    w = function() end,
    e = function() end,
  }

  local function assertEqual(actual, expected, message)
    if actual ~= expected then
      error(message .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
  end

  local function assertNil(actual, message)
    if actual ~= nil then
      error(message .. ": expected nil, got " .. tostring(actual), 2)
    end
  end

  local prefixed = matcher.new({
    rulesPath = "/tmp/proofime-matcher-sanity/symbols.json",
    log = log,
    triggerPrefix = ":",
    requireTriggerPrefix = true,
  })

  local match = prefixed:findMatch("Let x :fa")
  assertEqual(prefixed.maxTriggerLength, 7, "prefixed max trigger length includes the prefix")
  assertEqual(match.trigger, ":fa", "prefixed match deletes the full typed trigger")
  assertEqual(match.ruleTrigger, "fa", "prefixed match strips the prefix before rule lookup")
  assertEqual(match.replacement, "∀", "prefixed match returns the replacement")
  assertEqual(prefixed:findMatch(":fa").replacement, "∀", "prefixed forall trigger matches")
  assertEqual(prefixed:findMatch(":le").replacement, "≤", "prefixed relation trigger matches")
  assertEqual(prefixed:findMatch(":neq").replacement, "≠", "prefixed not-equal trigger matches")
  assertEqual(prefixed:findMatch(":lambda").replacement, "λ", "prefixed lambda trigger matches")
  assertEqual(prefixed:findMatch(":int").replacement, "∫", "prefixed integral trigger matches")
  assertEqual(prefixed:findMatch(":or").replacement, "∨", "prefixed logic trigger matches")
  assertNil(prefixed:findMatch("fa"), "bare trigger is ignored when prefix is required")
  assertNil(prefixed:findMatch("hello"), "plain word hello is ignored")
  assertNil(prefixed:findMatch("rules"), "plain word rules is ignored")
  assertNil(prefixed:findMatch("categories"), "plain word categories is ignored")
  assertNil(prefixed:findMatch("color"), "plain word color is ignored")

  local legacy = matcher.new({
    rulesPath = "/tmp/proofime-matcher-sanity/symbols.json",
    log = log,
    triggerPrefix = ":",
    requireTriggerPrefix = false,
  })

  match = legacy:findMatch("fa")
  assertEqual(legacy.maxTriggerLength, 6, "legacy max trigger length excludes the prefix")
  assertEqual(match.trigger, "fa", "legacy mode deletes only the bare trigger")
  assertEqual(match.ruleTrigger, "fa", "legacy mode uses the bare rule trigger")
  assertEqual(legacy:findMatch("categor").replacement, "∨", "legacy mode preserves bare suffix matching")

  print("matcher sanity checks passed")
end

local ok, errorMessage = xpcall(run, debug.traceback)
hs = originalHs

if not ok then
  error(errorMessage)
end
