-- Resizable, searchable symbol reference opened by hotkey.
local cheatsheet = {}

local SETTINGS_FRAME_KEY = "ProofIME.cheatSheet.frame"
local MIN_WIDTH = 420
local MIN_HEIGHT = 360
local DEFAULT_WIDTH = 620
local DEFAULT_HEIGHT = 720

local CATEGORY_ORDER = {
  "logic",
  "sets",
  "relations",
  "arrows",
  "greek",
  "calculus",
}

local CATEGORY_LABELS = {
  logic = "Logic",
  sets = "Sets",
  relations = "Relations",
  arrows = "Arrows",
  greek = "Greek",
  calculus = "Calculus",
}

local function displayCategory(category)
  return CATEGORY_LABELS[category] or "Other"
end

local function htmlEscape(value)
  local escaped = tostring(value or "")

  escaped = escaped:gsub("&", "&amp;")
  escaped = escaped:gsub("<", "&lt;")
  escaped = escaped:gsub(">", "&gt;")
  escaped = escaped:gsub('"', "&quot;")
  escaped = escaped:gsub("'", "&#39;")

  return escaped
end

local function usableFrame(frame)
  return type(frame) == "table"
    and type(frame.x) == "number"
    and type(frame.y) == "number"
    and type(frame.w) == "number"
    and type(frame.h) == "number"
    and frame.w >= MIN_WIDTH
    and frame.h >= MIN_HEIGHT
end

local function defaultFrame()
  local visibleFrame = nil

  if hs.screen and hs.screen.mainScreen then
    local screen = hs.screen.mainScreen()

    if screen and screen.visibleFrame then
      visibleFrame = screen:visibleFrame()
    end
  end

  if not usableFrame(visibleFrame) then
    return { x = 120, y = 120, w = DEFAULT_WIDTH, h = DEFAULT_HEIGHT }
  end

  return {
    x = visibleFrame.x + math.max(24, (visibleFrame.w - DEFAULT_WIDTH) / 2),
    y = visibleFrame.y + math.max(24, (visibleFrame.h - DEFAULT_HEIGHT) / 2),
    w = math.min(DEFAULT_WIDTH, visibleFrame.w - 48),
    h = math.min(DEFAULT_HEIGHT, visibleFrame.h - 48),
  }
end

local function savedFrame()
  if not hs.settings then
    return defaultFrame()
  end

  local frame = hs.settings.get(SETTINGS_FRAME_KEY)

  if usableFrame(frame) then
    return frame
  end

  return defaultFrame()
end

local function sortedRules(rules)
  local sorted = {}

  for _, rule in ipairs(rules or {}) do
    table.insert(sorted, rule)
  end

  table.sort(sorted, function(left, right)
    if tostring(left.trigger) ~= tostring(right.trigger) then
      return tostring(left.trigger) < tostring(right.trigger)
    end

    return tostring(left.replacement) < tostring(right.replacement)
  end)

  return sorted
end

local function groupedRules(rules)
  local byCategory = {}

  for _, rule in ipairs(rules or {}) do
    local category = rule.category or "other"

    if not byCategory[category] then
      byCategory[category] = {}
    end

    table.insert(byCategory[category], rule)
  end

  return byCategory
end

local function ruleRow(rule, triggerPrefix)
  local trigger = tostring(triggerPrefix or "") .. tostring(rule.trigger)
  local searchText = table.concat({
    trigger,
    tostring(rule.replacement or ""),
    tostring(rule.description or ""),
    tostring(rule.category or ""),
    table.concat(rule.keywords or {}, " "),
  }, " ")

  return '<div class="rule" data-search="'
    .. htmlEscape(searchText:lower())
    .. '"><code>'
    .. htmlEscape(trigger)
    .. '</code><span class="arrow">→</span><span class="symbol">'
    .. htmlEscape(rule.replacement)
    .. '</span><span class="description">'
    .. htmlEscape(rule.description or "")
    .. "</span></div>"
end

local function categorySection(category, rules, triggerPrefix)
  local rows = {}

  table.insert(rows, '<section class="category" data-category="' .. htmlEscape(category) .. '">')
  table.insert(rows, "<h2>" .. htmlEscape(displayCategory(category)) .. "</h2>")

  for _, rule in ipairs(sortedRules(rules)) do
    table.insert(rows, ruleRow(rule, triggerPrefix))
  end

  table.insert(rows, "</section>")
  return table.concat(rows, "\n")
end

local function buildHtml(rules, triggerPrefix)
  local byCategory = groupedRules(rules)
  local sections = {}
  local seenCategories = {}

  local function appendCategory(category)
    seenCategories[category] = true
    table.insert(sections, categorySection(category, byCategory[category], triggerPrefix))
  end

  for _, category in ipairs(CATEGORY_ORDER) do
    if byCategory[category] then
      appendCategory(category)
    end
  end

  for category, _ in pairs(byCategory) do
    if not seenCategories[category] then
      appendCategory(category)
    end
  end

  return [[<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>
:root {
  color-scheme: light dark;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
body {
  margin: 0;
  background: #f7f7f8;
  color: #1f2328;
}
.toolbar {
  position: sticky;
  top: 0;
  z-index: 2;
  padding: 14px 16px 12px;
  background: rgba(247, 247, 248, 0.96);
  border-bottom: 1px solid #d7dce2;
}
input {
  box-sizing: border-box;
  width: 100%;
  height: 34px;
  border: 1px solid #c8cdd4;
  border-radius: 7px;
  padding: 0 10px;
  font-size: 14px;
  background: #ffffff;
  color: #1f2328;
}
main {
  padding: 8px 16px 18px;
}
h2 {
  margin: 16px 0 8px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  color: #59636e;
}
.rule {
  display: grid;
  grid-template-columns: minmax(90px, 1fr) 22px minmax(44px, 0.45fr) minmax(0, 1.8fr);
  align-items: baseline;
  min-height: 30px;
  border-bottom: 1px solid #e4e7eb;
  column-gap: 8px;
}
code {
  font-family: Menlo, ui-monospace, monospace;
  font-size: 13px;
  color: #20262e;
}
.arrow {
  color: #68717d;
}
.symbol {
  font-size: 18px;
  color: #111820;
}
.description {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #68717d;
  font-size: 13px;
}
.hidden {
  display: none;
}
@media (prefers-color-scheme: dark) {
  body {
    background: #17191d;
    color: #e5e7eb;
  }
  .toolbar {
    background: rgba(23, 25, 29, 0.96);
    border-bottom-color: #383d45;
  }
  input {
    background: #20242a;
    border-color: #474d57;
    color: #f2f4f7;
  }
  h2 {
    color: #a7afb9;
  }
  .rule {
    border-bottom-color: #30353d;
  }
  code,
  .symbol {
    color: #f2f4f7;
  }
  .arrow,
  .description {
    color: #a7afb9;
  }
}
</style>
</head>
<body>
<div class="toolbar">
  <input id="search" type="search" autofocus placeholder="Search ProofIME symbols">
</div>
<main id="content">
]] .. table.concat(sections, "\n") .. [[
</main>
<script>
const search = document.getElementById("search");
const rules = Array.from(document.querySelectorAll(".rule"));
const sections = Array.from(document.querySelectorAll(".category"));

function filter() {
  const query = search.value.trim().toLowerCase();

  rules.forEach((rule) => {
    rule.classList.toggle("hidden", query !== "" && !rule.dataset.search.includes(query));
  });

  sections.forEach((section) => {
    const visibleRule = section.querySelector(".rule:not(.hidden)");
    section.classList.toggle("hidden", visibleRule === null);
  });
}

search.addEventListener("input", filter);
setTimeout(() => search.focus(), 100);
</script>
</body>
</html>]]
end

function cheatsheet.new(options)
  local instance = {
    matcher = options.matcher,
    log = options.log,
    triggerPrefix = options.triggerPrefix or "",
    webview = nil,
    frameTimer = nil,
  }

  function instance:saveFrame()
    if not self.webview or not hs.settings then
      return
    end

    local ok, frame = pcall(function()
      return self.webview:frame()
    end)

    if ok and usableFrame(frame) then
      hs.settings.set(SETTINGS_FRAME_KEY, frame)
    end
  end

  function instance:startFramePersistence()
    if self.frameTimer or not hs.timer then
      return
    end

    self.frameTimer = hs.timer.doEvery(1, function()
      self:saveFrame()
    end)
  end

  function instance:ensureWindow()
    if self.webview then
      return
    end

    self.webview = hs.webview.new(savedFrame())
    self.webview:windowStyle({ "titled", "closable", "resizable", "miniaturizable" })
    self.webview:allowTextEntry(true)
    self.webview:deleteOnClose(false)

    if self.webview.windowTitle then
      self.webview:windowTitle("ProofIME Cheat Sheet")
    end

    if hs.drawing and hs.drawing.windowLevels then
      self.webview:level(hs.drawing.windowLevels.floating)
    end

    if self.webview.windowCallback then
      self.webview:windowCallback(function(...)
        for _, value in ipairs({ ... }) do
          if value == "closing" or value == "frameChange" then
            self:saveFrame()
            return
          end
        end
      end)
    end
  end

  function instance:show()
    self:ensureWindow()

    local rules = self.matcher and self.matcher.rules or {}

    self.webview:html(buildHtml(rules, self.triggerPrefix))
    self.webview:frame(savedFrame())
    self.webview:show()
    self:startFramePersistence()

    if self.log then
      self.log:i("ProofIME cheat sheet opened with " .. tostring(#rules) .. " entries")
    end
  end

  return instance
end

return cheatsheet
