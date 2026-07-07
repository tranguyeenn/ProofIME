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
      enabled = { "logic", "relations", "greek" },
    },
    categories = {
      logic = {
        {
          trigger = "fa",
          replacement = "∀",
          description = "for all",
          keywords = { "forall", "universal", "logic" },
          category = "logic",
        },
        {
          trigger = "or",
          replacement = "∨",
          description = "logical or",
          keywords = { "vee", "logic" },
          category = "logic",
        },
      },
      relations = {
        e = "E",
        le = "≤",
        neq = "≠",
      },
      greek = {
        {
          trigger = "alpha",
          replacement = "α",
          description = "Greek alpha",
          keywords = { "alp", "greek", "letter" },
          category = "greek",
        },
        {
          trigger = "beta",
          replacement = "β",
          description = "Greek beta",
          keywords = { "greek", "letter" },
          category = "greek",
        },
        {
          trigger = "gamma",
          replacement = "γ",
          description = "Greek gamma",
          keywords = { "greek", "letter" },
          category = "greek",
        },
        {
          trigger = "lambda",
          replacement = "λ",
          description = "Greek lambda",
          keywords = { "function", "greek", "letter" },
          category = "greek",
        },
      },
    },
  }

  -- Minimal Hammerspoon stub for local Lua runs. matcher.lua only reaches
  -- Hammerspoon through utils.readJson -> hs.json.read in this test.
  hs = {
    json = {
      read = function(path)
        if path == tempDirectory .. "index.json" then
          return state.index
        end

        local category = path:match("/([^/]+)%.json$")
        local categoryRules = category and state.categories[category]
        if categoryRules == "__throw__" then
          error("malformed JSON")
        end

        if categoryRules ~= nil then
          return categoryRules
        end

        if path:match("symbols%.json$") then
          return {
            fa = "∀",
            e = "E",
            ["in"] = "∈",
            le = "≤",
            neq = "≠",
            lambda = "λ",
            int = "∫",
            ["or"] = "∨",
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

  local function assertContains(actual, expected, message)
    if type(actual) ~= "string" or not actual:find(expected, 1, true) then
      error(message .. ": expected '" .. tostring(actual) .. "' to contain '" .. tostring(expected) .. "'", 2)
    end
  end

  local function assertLength(actual, expected, message)
    if #actual ~= expected then
      error(message .. ": expected length " .. tostring(expected) .. ", got " .. tostring(#actual), 2)
    end
  end

  local indexed

  local function assertReloadFailsWith(categoryRules, message)
    state.categories.relations = categoryRules
    local result = indexed:reload()
    assertEqual(result.ok, false, message .. " fails reload")
    assertEqual(result.ruleCount, 3, message .. " reports previous active count")
    assertEqual(indexed:findMatch(":le").replacement, "LESS-OR-EQUAL", message .. " preserves previous rules")
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
  assertEqual(prefixed:findMatch(":le").ruleTrigger, "le", "longest prefixed trigger match wins")
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

  indexed = matcher.new({
    rulesPath = tempDirectory .. "symbols.json",
    log = log,
    triggerPrefix = ":",
    requireTriggerPrefix = true,
  })

  assertEqual(indexed:findMatch(":fa").replacement, "∀", "indexed normal load includes logic rules")
  assertEqual(indexed:findMatch(":fa").description, "for all", "metadata description loads")
  assertEqual(indexed:findMatch(":fa").keywords[1], "forall", "metadata keywords load")
  assertEqual(indexed:findMatch(":fa").category, "logic", "metadata category loads")
  assertEqual(indexed:findMatch(":le").replacement, "≤", "indexed normal load includes relation rules")
  assertEqual(indexed:findMatch(":le").ruleTrigger, "le", "indexed longest trigger match wins")
  assertEqual(indexed:findMatch(":le").category, "relations", "legacy category file supplies category metadata")
  assertEqual(indexed:loadRules().ruleCount, 9, "normal load reports active rule count")

  local candidates = indexed:getCandidates(":fa", { triggerPrefix = ":", requireTriggerPrefix = true }, 5)
  assertEqual(candidates[1].trigger, "fa", "exact candidate ranks first")
  assertEqual(candidates[1].replacement, "∀", "exact candidate returns forall replacement")
  assertEqual(candidates[1].rankReason, "exact", "exact candidate reports rank reason")

  candidates = indexed:getCandidates(":alp", { triggerPrefix = ":", requireTriggerPrefix = true }, 5)
  assertEqual(candidates[1].trigger, "alpha", "alpha prefix candidate ranks first")
  assertEqual(candidates[1].replacement, "α", "alpha prefix candidate returns replacement")
  assertEqual(candidates[1].category, "greek", "alpha candidate preserves category metadata")

  candidates = indexed:getCandidates(":lamb", { triggerPrefix = ":", requireTriggerPrefix = true }, 5)
  assertEqual(candidates[1].trigger, "lambda", "lambda prefix candidate ranks first")
  assertEqual(candidates[1].replacement, "λ", "lambda prefix candidate returns replacement")
  assertEqual(candidates[1].rankReason, "trigger-prefix", "lambda candidate reports prefix rank reason")

  candidates = indexed:getCandidates(":universal", { triggerPrefix = ":", requireTriggerPrefix = true }, 5)
  assertEqual(candidates[1].trigger, "fa", "keyword candidate finds forall")
  assertEqual(candidates[1].rankReason, "keyword", "keyword candidate reports rank reason")

  candidates = indexed:getCandidates(":fa", { triggerPrefix = ":", requireTriggerPrefix = true }, 5)
  assertEqual(candidates[1].rankReason, "exact", "exact candidate beats fuzzy candidates")

  candidates = indexed:getCandidates(":a", { triggerPrefix = ":", requireTriggerPrefix = true }, 2)
  assertLength(candidates, 2, "candidate limit is applied")

  candidates = indexed:getCandidates("fa", { triggerPrefix = ":", requireTriggerPrefix = true }, 5)
  assertLength(candidates, 0, "candidate search respects required prefix")

  state.categories = {
    logic = {
      {
        trigger = "fa",
        replacement = "FORALL",
        description = "updated forall",
        keywords = { "logic" },
        category = "logic",
      },
    },
    relations = {
      le = "LESS-OR-EQUAL",
      ge = "GREATER-OR-EQUAL",
    },
  }
  state.index.enabled = { "logic", "relations" }

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

  assertReloadFailsWith({
    [""] = "EMPTY-TRIGGER",
  }, "empty trigger")

  assertReloadFailsWith({
    ["   "] = "WHITESPACE-TRIGGER",
  }, "whitespace-only trigger")

  assertReloadFailsWith({
    le = 123,
  }, "non-string replacement")

  assertReloadFailsWith({
    {
      trigger = "le",
      replacement = "LESS-OR-EQUAL",
      description = 123,
    },
  }, "non-string metadata description")

  assertReloadFailsWith({
    {
      trigger = "le",
      replacement = "LESS-OR-EQUAL",
      keywords = { "relation", 123 },
    },
  }, "non-string metadata keyword")

  assertReloadFailsWith({
    {
      trigger = "le",
      replacement = "LESS-OR-EQUAL",
      category = 123,
    },
  }, "non-string metadata category")

  state.categories.relations = {
    {
      trigger = "le",
      replacement = 123,
    },
  }
  reloadResult = indexed:reload()
  assertEqual(reloadResult.ok, false, "metadata replacement validation fails reload")
  assertContains(reloadResult.error, "replacement must be a string", "metadata replacement validation reports clear error")
  assertEqual(reloadResult.ruleCount, 3, "metadata validation failure reports previous active count")
  assertEqual(indexed:findMatch(":le").replacement, "LESS-OR-EQUAL", "metadata validation failure preserves previous rules")

  state.categories.relations = nil
  reloadResult = indexed:reload()
  assertEqual(reloadResult.ok, false, "malformed JSON read failure fails reload")
  assertEqual(reloadResult.ruleCount, 3, "malformed JSON read failure reports previous active count")
  assertEqual(indexed:findMatch(":le").replacement, "LESS-OR-EQUAL", "malformed JSON read failure preserves previous rules")

  state.categories.relations = "__throw__"
  reloadResult = indexed:reload()
  assertEqual(reloadResult.ok, false, "malformed JSON parser error fails reload")
  assertEqual(reloadResult.ruleCount, 3, "malformed JSON parser error reports previous active count")
  assertEqual(indexed:findMatch(":le").replacement, "LESS-OR-EQUAL", "malformed JSON parser error preserves previous rules")

  state.index.enabled = { "logic" }
  reloadResult = indexed:reload()
  assertEqual(reloadResult.ok, true, "disabled broken category does not block reload")
  assertEqual(reloadResult.ruleCount, 1, "disabled broken category reloads enabled rules only")
  assertEqual(indexed:findMatch(":fa").replacement, "FORALL", "enabled rules remain available after disabled broken category")

  print("matcher sanity checks passed")
end

local ok, errorMessage = xpcall(run, debug.traceback)
hs = originalHs

if not ok then
  error(errorMessage)
end
