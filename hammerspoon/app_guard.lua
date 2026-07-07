local AppGuard = {}
AppGuard.__index = AppGuard

local log = hs.logger.new("appGuard", "info")

local function toSet(list)
    local set = {}

    for _, value in ipairs(list or {}) do
        set[value] = true
    end

    return set
end

function AppGuard.new(config)
    local self = setmetatable({}, AppGuard)

    self.ignoredApplications = toSet(config.ignoredApplications)
    self.ignoredBundleIDs = toSet(config.ignoredBundleIDs)

    return self
end

function AppGuard:isIgnored()
    local app = hs.application.frontmostApplication()

    if not app then
        return false
    end

    local name = app:name()
    local bundleID = app:bundleID()

    if name and self.ignoredApplications[name] then
        log.df("Ignoring application: %s", name)
        return true
    end

    if bundleID and self.ignoredBundleIDs[bundleID] then
        log.df("Ignoring bundle: %s", bundleID)
        return true
    end

    return false
end

return AppGuard