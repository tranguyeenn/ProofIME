package.path = "hammerspoon/?.lua;" .. package.path

local originalHs = hs

local function run()
  local legacyDirectory = "/tmp/proofime-matcher-sanity-legacy/"
  local tempDirectory = "/tmp/proofime-matcher-sanity-indexed/"
  os.execute("mkdir -p " .. legacyDirectory)
  os.execute("mkdir -p " .. tempDirectory)
  os.remove(legacyDirectory .. "index.json")

  local indexFile = io.open(tempDirectory .. "index.json", "w")
  if indexFile then
    indexFile:write("{}")
    indexFile:close()
  end

  local state = {
    index = {
      enabled = { "logic", "relations" },
    },
    categories = {
      logic = {
        fa = "∀",
        or = "∨",
      },
      relations = {
        le = "≤",
        neq = "≠",
      },
    },
  }

  hs = {
    json = {
      read = function(path)
        if path == tempDirectory .. "index.json" then
          return state.index
        end

        local category = path:match("/([^/]+)%.json$")
        if category and state.categories[category] then
          return state.categories[category]
        end

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
    rulesPath = legacyDirectory .. "symbols.json",
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
    rulesPath = legacyDirectory .. "symbols.json",
    log = log,
    triggerPrefix = ":",
    requireTriggerPrefix = false,
  })

  match = legacy:findMatch("fa")
  assertEqual(legacy.maxTriggerLength, 6, "legacy max trigger length excludes the prefix")
  assertEqual(match.trigger, "fa", "legacy mode deletes only the bare trigger")
  assertEqual(match.ruleTrigger, "fa", "legacy mode uses the bare rule trigger")
  assertEqual(legacy:findMatch("categor").replacement, "∨", "legacy mode preserves bare suffix matching")

  local indexed = matcher.new({
    rulesPath = tempDirectory .. "symbols.json",
    log = log,
    triggerPrefix = ":",
    requireTriggerPrefix = true,
  })

  assertEqual(indexed:findMatch(":fa").replacement, "∀", "indexed normal load includes logic rules")
  assertEqual(indexed:findMatch(":le").replacement, "≤", "indexed normal load includes relation rules")
  assertEqual(indexed:loadRules().ruleCount, 4, "normal load reports active rule count")

  state.categories = {
    logic = {
      fa = "FORALL",
    },
    relations = {
      le = "LESS-OR-EQUAL",
      ge = "GREATER-OR-EQUAL",
    },
  }

  local reloadResult = indexed:reload()
  assertEqual(reloadResult.ok, true, "valid reload succeeds")
  assertEqual(reloadResult.ruleCount, 3, "reload reports replacement rule count")
  assertEqual(indexed:findMatch(":fa").replacement, "FORALL", "reload replaces old logic rule")
  assertEqual(indexed:findMatch(":le").replacement, "LESS-OR-EQUAL", "reload replaces old relation rule")
  assertNil(indexed:findMatch(":neq"), "reload removes rules absent from new categories")

  state.categories.relations = "invalid"
  reloadResult = indexed:reload()
  assertEqual(reloadResult.ok, false, "invalid reload fails")
  assertEqual(reloadResult.ruleCount, 3, "invalid reload reports previous active count")
  assertEqual(indexed:findMatch(":le").replacement, "LESS-OR-EQUAL", "invalid reload preserves previous rules")

  print("matcher sanity checks passed")
end

local ok, errorMessage = xpcall(run, debug.traceback)
hs = originalHs

if not ok then
  error(errorMessage)
end
