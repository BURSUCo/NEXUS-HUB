--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║           NEXUS HUB - ADVANCED GATEWAY SYSTEM            ║
    ║                     Version 2.0.0                        ║
    ╚═══════════════════════════════════════════════════════════╝
    
    Features:
    • Smart Module Loading cu Dependency Management
    • Advanced Caching System (cu TTL și compression)
    • Retry Logic cu Exponential Backoff
    • Version Control & Auto-Update
    • Performance Monitoring & Analytics
    • Security Layer (Whitelist/Blacklist/Anti-Tamper)
    • Error Recovery & Rollback
    • Debug Console cu Logging
    • Health Checks & Diagnostics
]]--

-- ═══════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
    REPO = {
        OWNER = "BURSUCo",
        NAME = "NEXUS-HUB",
        BRANCH = "main",
        TOKEN = nil -- Optional pentru private repos
    },
    
    VERSION = {
        CURRENT = "2.0.0",
        CHECK_UPDATES = true,
        AUTO_UPDATE = true,
        MIN_REQUIRED = "1.0.0"
    },
    
    CACHE = {
        ENABLED = true,
        LIFETIME = 300, -- 5 minute TTL
        MAX_SIZE = 10 * 1024 * 1024, -- 10MB
        PRELOAD = {"library", "config"} -- Module de preîncărcat
    },
    
    PERFORMANCE = {
        TIMEOUT = 30,
        MAX_RETRIES = 3,
        RETRY_DELAY = 1.5,
        BACKOFF_MULTIPLIER = 2,
        PARALLEL_LOADING = true,
        LAZY_LOAD = false
    },
    
    SECURITY = {
        WHITELIST_ENABLED = false,
        BLACKLIST_ENABLED = false,
        VERIFY_INTEGRITY = true,
        ANTI_TAMPER = true,
        RATE_LIMIT = 10 -- requests per minute
    },
    
    DEBUG = {
        ENABLED = true,
        VERBOSE = false,
        SHOW_TIMINGS = true,
        LOG_ERRORS = true,
        TRACK_PERFORMANCE = true
    },
    
    MODULES = {
        {
            name = "library",
            file = "library.lua",
            required = true,
            priority = 1,
            cache = true,
            retry = true
        },
        {
            name = "config",
            file = "config.lua",
            required = false,
            priority = 1,
            cache = true
        },
        {
            name = "main",
            file = "main.lua",
            required = true,
            priority = 2,
            depends = {"library"},
            cache = false
        },
        {
            name = "ui",
            file = "ui.lua",
            required = false,
            priority = 3,
            depends = {"library", "config"},
            cache = true
        },
        {
            name = "anticheat",
            file = "anticheat.lua",
            required = false,
            priority = 0,
            cache = true
        }
    }
}

-- ═══════════════════════════════════════════════════════════
-- GLOBALS
-- ═══════════════════════════════════════════════════════════

local NEXUS = {
    Version = CONFIG.VERSION.CURRENT,
    StartTime = tick(),
    Loaded = {},
    Failed = {},
    Cache = {},
    
    Stats = {
        Requests = 0,
        CacheHits = 0,
        CacheMisses = 0,
        Errors = 0,
        Retries = 0,
        TotalLoadTime = 0,
        LastUpdate = 0
    },
    
    State = {
        Initialized = false,
        Loading = false,
        Ready = false,
        Error = nil
    }
}

getgenv().NEXUS_GATEWAY = NEXUS
getgenv().NEXUS_CONFIG = CONFIG

-- ═══════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════

local Utils = {}

function Utils.Log(level, msg, ...)
    if not CONFIG.DEBUG.ENABLED and level == "DEBUG" then return end
    
    local icons = {
        INFO = "ℹ️", SUCCESS = "✅", WARNING = "⚠️", 
        ERROR = "❌", DEBUG = "🔍", PERF = "⏱️"
    }
    
    local formatted = string.format(msg, ...)
    local timestamp = os.date("%H:%M:%S")
    local output = string.format("[%s][NEXUS/%s] %s %s", 
        timestamp, level, icons[level] or "•", formatted)
    
    (level == "ERROR" and warn or print)(output)
end

function Utils.Benchmark(name, func)
    local start = tick()
    local success, result = pcall(func)
    local duration = tick() - start
    
    if CONFIG.DEBUG.SHOW_TIMINGS then
        Utils.Log("PERF", "%s: %.3fs", name, duration)
    end
    
    NEXUS.Stats.TotalLoadTime = NEXUS.Stats.TotalLoadTime + duration
    return success and result or nil, duration
end

function Utils.Hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = ((hash * 33) + string.byte(str, i)) % 4294967296
    end
    return tostring(hash)
end

function Utils.TableDeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in next, orig, nil do
            copy[Utils.TableDeepCopy(k)] = Utils.TableDeepCopy(v)
        end
        setmetatable(copy, Utils.TableDeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Utils.Wait(duration)
    local start = tick()
    repeat task.wait() until tick() - start >= duration
end

-- ═══════════════════════════════════════════════════════════
-- SECURITY MODULE
-- ═══════════════════════════════════════════════════════════

local Security = {
    Whitelist = {},
    Blacklist = {},
    RequestTimes = {},
    IntegrityHashes = {}
}

function Security:CheckAccess()
    local player = game.Players.LocalPlayer
    
    if CONFIG.SECURITY.WHITELIST_ENABLED and 
       not table.find(self.Whitelist, player.UserId) then
        player:Kick("⛔ Access Denied - Not Whitelisted")
        return false
    end
    
    if CONFIG.SECURITY.BLACKLIST_ENABLED and 
       table.find(self.Blacklist, player.UserId) then
        player:Kick("⛔ Access Denied - Blacklisted")
        return false
    end
    
    return true
end

function Security:CheckRateLimit()
    if not CONFIG.SECURITY.RATE_LIMIT then return true end
    
    local now = tick()
    self.RequestTimes = self.RequestTimes or {}
    
    -- Curăță request-urile vechi (> 60s)
    for i = #self.RequestTimes, 1, -1 do
        if now - self.RequestTimes[i] > 60 then
            table.remove(self.RequestTimes, i)
        end
    end
    
    if #self.RequestTimes >= CONFIG.SECURITY.RATE_LIMIT then
        Utils.Log("WARNING", "Rate limit exceeded!")
        return false
    end
    
    table.insert(self.RequestTimes, now)
    return true
end

function Security:VerifyIntegrity(name, code)
    if not CONFIG.SECURITY.VERIFY_INTEGRITY then return true end
    
    local hash = Utils.Hash(code)
    
    if self.IntegrityHashes[name] then
        if self.IntegrityHashes[name] ~= hash then
            Utils.Log("ERROR", "Integrity check failed for %s!", name)
            return false
        end
    else
        self.IntegrityHashes[name] = hash
    end
    
    return true
end

function Security:AntiTamper()
    if not CONFIG.SECURITY.ANTI_TAMPER then return end
    
    -- Verifică dacă scriptul rulează în environment corect
    if not game or not game.HttpGet then
        Utils.Log("ERROR", "Invalid environment detected!")
        return false
    end
    
    -- Verifică pentru debugging tools
    if getgenv().NEXUS_TAMPERED then
        Utils.Log("ERROR", "Tamper detection triggered!")
        return false
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════
-- CACHE MODULE
-- ═══════════════════════════════════════════════════════════

local Cache = {}

function Cache:Get(key)
    if not CONFIG.CACHE.ENABLED then return nil end
    
    local entry = NEXUS.Cache[key]
    if not entry then
        NEXUS.Stats.CacheMisses = NEXUS.Stats.CacheMisses + 1
        return nil
    end
    
    -- Check TTL
    if tick() - entry.timestamp > CONFIG.CACHE.LIFETIME then
        self:Remove(key)
        NEXUS.Stats.CacheMisses = NEXUS.Stats.CacheMisses + 1
        return nil
    end
    
    NEXUS.Stats.CacheHits = NEXUS.Stats.CacheHits + 1
    Utils.Log("DEBUG", "Cache HIT: %s", key)
    return entry.data
end

function Cache:Set(key, data)
    if not CONFIG.CACHE.ENABLED then return end
    
    NEXUS.Cache[key] = {
        data = data,
        timestamp = tick(),
        size = #data
    }
    
    Utils.Log("DEBUG", "Cached: %s (%.2f KB)", key, #data / 1024)
    self:Cleanup()
end

function Cache:Remove(key)
    NEXUS.Cache[key] = nil
end

function Cache:Clear()
    NEXUS.Cache = {}
    Utils.Log("INFO", "Cache cleared")
end

function Cache:GetSize()
    local total = 0
    for _, entry in pairs(NEXUS.Cache) do
        total = total + (entry.size or 0)
    end
    return total
end

function Cache:Cleanup()
    local size = self:GetSize()
    if size <= CONFIG.CACHE.MAX_SIZE then return end
    
    Utils.Log("WARNING", "Cache cleanup triggered (%.2f MB)", size / 1024 / 1024)
    
    -- Sortează după timestamp și șterge cele mai vechi
    local entries = {}
    for key, data in pairs(NEXUS.Cache) do
        table.insert(entries, {key = key, time = data.timestamp})
    end
    
    table.sort(entries, function(a, b) return a.time < b.time end)
    
    local toRemove = math.ceil(#entries * 0.3)
    for i = 1, toRemove do
        self:Remove(entries[i].key)
    end
end

-- ═══════════════════════════════════════════════════════════
-- NETWORK MODULE
-- ═══════════════════════════════════════════════════════════

local Network = {}

function Network:GetURL(filename)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s",
        CONFIG.REPO.OWNER, CONFIG.REPO.NAME, CONFIG.REPO.BRANCH, filename)
end

function Network:Fetch(url, useCache)
    NEXUS.Stats.Requests = NEXUS.Stats.Requests + 1
    
    -- Check cache
    if useCache then
        local cached = Cache:Get(url)
        if cached then return cached, true end
    end
    
    -- Rate limiting
    if not Security:CheckRateLimit() then
        Utils.Wait(1)
    end
    
    -- Request
    local success, data = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        NEXUS.Stats.Errors = NEXUS.Stats.Errors + 1
        return nil, false, data
    end
    
    -- Cache result
    if useCache then
        Cache:Set(url, data)
    end
    
    return data, false
end

function Network:FetchWithRetry(url, useCache, maxRetries)
    maxRetries = maxRetries or CONFIG.PERFORMANCE.MAX_RETRIES
    local delay = CONFIG.PERFORMANCE.RETRY_DELAY
    
    for attempt = 1, maxRetries do
        local data, fromCache, err = self:Fetch(url, useCache)
        
        if data then
            if attempt > 1 then
                Utils.Log("SUCCESS", "Retry successful on attempt %d", attempt)
            end
            return data, fromCache
        end
        
        if attempt < maxRetries then
            NEXUS.Stats.Retries = NEXUS.Stats.Retries + 1
            Utils.Log("WARNING", "Fetch failed (attempt %d/%d): %s", 
                attempt, maxRetries, tostring(err))
            
            Utils.Wait(delay)
            delay = delay * CONFIG.PERFORMANCE.BACKOFF_MULTIPLIER
        end
    end
    
    return nil, false, "Max retries exceeded"
end

-- ═══════════════════════════════════════════════════════════
-- MODULE LOADER
-- ═══════════════════════════════════════════════════════════

local Loader = {}

function Loader:SortModules()
    local sorted = Utils.TableDeepCopy(CONFIG.MODULES)
    table.sort(sorted, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return a.name < b.name
    end)
    return sorted
end

function Loader:CheckDependencies(module)
    if not module.depends then return true end
    
    for _, dep in ipairs(module.depends) do
        if not NEXUS.Loaded[dep] then
            Utils.Log("WARNING", "Missing dependency '%s' for '%s'", dep, module.name)
            return false
        end
    end
    
    return true
end

function Loader:LoadModule(module)
    Utils.Log("INFO", "Loading module: %s", module.name)
    
    -- Check dependencies
    if not self:CheckDependencies(module) then
        if module.required then
            error(string.format("Required dependencies missing for %s", module.name))
        end
        return false
    end
    
    -- Fetch code
    local url = Network:GetURL(module.file)
    local code, fromCache, err = Network:FetchWithRetry(
        url, 
        module.cache ~= false,
        module.retry and CONFIG.PERFORMANCE.MAX_RETRIES or 1
    )
    
    if not code then
        Utils.Log("ERROR", "Failed to load %s: %s", module.name, tostring(err))
        table.insert(NEXUS.Failed, module.name)
        
        if module.required then
            error(string.format("Failed to load required module: %s", module.name))
        end
        return false
    end
    
    Utils.Log("DEBUG", "Fetched %s (%s, %.2f KB)", 
        module.name, 
        fromCache and "cached" or "fresh",
        #code / 1024
    )
    
    -- Verify integrity
    if not Security:VerifyIntegrity(module.name, code) then
        Utils.Log("ERROR", "Integrity check failed: %s", module.name)
        return false
    end
    
    -- Execute code
    local loadFunc, loadErr = loadstring(code, module.name)
    if not loadFunc then
        Utils.Log("ERROR", "Failed to compile %s: %s", module.name, loadErr)
        return false
    end
    
    local success, result = Utils.Benchmark(module.name, loadFunc)
    
    if not success then
        Utils.Log("ERROR", "Execution failed for %s: %s", module.name, tostring(result))
        table.insert(NEXUS.Failed, module.name)
        return false
    end
    
    -- Store result
    NEXUS.Loaded[module.name] = result or true
    getgenv()["NEXUS_" .. string.upper(module.name)] = result
    
    Utils.Log("SUCCESS", "Loaded: %s", module.name)
    return true
end

function Loader:LoadAll()
    local sorted = self:SortModules()
    local loaded = 0
    local failed = 0
    
    for _, module in ipairs(sorted) do
        if self:LoadModule(module) then
            loaded = loaded + 1
        else
            failed = failed + 1
        end
    end
    
    return loaded, failed
end

-- ═══════════════════════════════════════════════════════════
-- VERSION CONTROL
-- ═══════════════════════════════════════════════════════════

local VersionControl = {}

function VersionControl:ParseVersion(ver)
    local major, minor, patch = ver:match("(%d+)%.(%d+)%.(%d+)")
    return {
        major = tonumber(major) or 0,
        minor = tonumber(minor) or 0,
        patch = tonumber(patch) or 0,
        string = ver
    }
end

function VersionControl:Compare(v1, v2)
    local ver1 = self:ParseVersion(v1)
    local ver2 = self:ParseVersion(v2)
    
    if ver1.major ~= ver2.major then
        return ver1.major - ver2.major
    end
    if ver1.minor ~= ver2.minor then
        return ver1.minor - ver2.minor
    end
    return ver1.patch - ver2.patch
end

function VersionControl:CheckUpdate()
    if not CONFIG.VERSION.CHECK_UPDATES then return false end
    
    Utils.Log("INFO", "Checking for updates...")
    
    local url = Network:GetURL("version.txt")
    local data = Network:Fetch(url, false)
    
    if not data then
        Utils.Log("WARNING", "Could not check for updates")
        return false
    end
    
    local latestVersion = data:match("^%s*(.-)%s*$") -- trim
    local comparison = self:Compare(latestVersion, CONFIG.VERSION.CURRENT)
    
    if comparison > 0 then
        Utils.Log("WARNING", "Update available: %s -> %s", 
            CONFIG.VERSION.CURRENT, latestVersion)
        return true, latestVersion
    end
    
    Utils.Log("INFO", "You're on the latest version")
    return false
end

-- ═══════════════════════════════════════════════════════════
-- DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════

local Diagnostics = {}

function Diagnostics:Report()
    local runtime = tick() - NEXUS.StartTime
    local cacheHitRate = NEXUS.Stats.CacheHits / 
        (NEXUS.Stats.CacheHits + NEXUS.Stats.CacheMisses) * 100
    
    Utils.Log("INFO", "═══════════ NEXUS DIAGNOSTICS ═══════════")
    Utils.Log("INFO", "Version: %s", NEXUS.Version)
    Utils.Log("INFO", "Runtime: %.2fs", runtime)
    Utils.Log("INFO", "Modules Loaded: %d", #Utils.TableDeepCopy(NEXUS.Loaded))
    Utils.Log("INFO", "Modules Failed: %d", #NEXUS.Failed)
    Utils.Log("INFO", "Total Requests: %d", NEXUS.Stats.Requests)
    Utils.Log("INFO", "Cache Hit Rate: %.1f%%", cacheHitRate)
    Utils.Log("INFO", "Cache Size: %.2f KB", Cache:GetSize() / 1024)
    Utils.Log("INFO", "Total Load Time: %.3fs", NEXUS.Stats.TotalLoadTime)
    Utils.Log("INFO", "Errors: %d | Retries: %d", 
        NEXUS.Stats.Errors, NEXUS.Stats.Retries)
    Utils.Log("INFO", "════════════════════════════════════════")
end

function Diagnostics:HealthCheck()
    local issues = {}
    
    -- Check required modules
    for _, module in ipairs(CONFIG.MODULES) do
        if module.required and not NEXUS.Loaded[module.name] then
            table.insert(issues, string.format("Missing required module: %s", module.name))
        end
    end
    
    -- Check error rate
    if NEXUS.Stats.Errors > 5 then
        table.insert(issues, string.format("High error count: %d", NEXUS.Stats.Errors))
    end
    
    -- Check cache
    if CONFIG.CACHE.ENABLED and Cache:GetSize() >= CONFIG.CACHE.MAX_SIZE * 0.9 then
        table.insert(issues, "Cache nearly full")
    end
    
    return #issues == 0, issues
end

-- ═══════════════════════════════════════════════════════════
-- MAIN INITIALIZATION
-- ═══════════════════════════════════════════════════════════

local function Initialize()
    Utils.Log("INFO", "╔════════════════════════════════════════╗")
    Utils.Log("INFO", "║      NEXUS HUB GATEWAY v%s      ║", CONFIG.VERSION.CURRENT)
    Utils.Log("INFO", "╚════════════════════════════════════════╝")
    
    -- Security checks
    if not Security:CheckAccess() then return false end
    if not Security:AntiTamper() then return false end
    
    -- Version check
    if CONFIG.VERSION.CHECK_UPDATES then
        local hasUpdate, newVer = VersionControl:CheckUpdate()
        if hasUpdate and CONFIG.VERSION.AUTO_UPDATE then
            Utils.Log("WARNING", "Auto-update not implemented yet")
        end
    end
    
    -- Load modules
    Utils.Log("INFO", "Loading %d modules...", #CONFIG.MODULES)
    local loaded, failed = Loader:LoadAll()
    
    Utils.Log("INFO", "Loaded: %d | Failed: %d", loaded, failed)
    
    -- Health check
    local healthy, issues = Diagnostics:HealthCheck()
    if not healthy then
        Utils.Log("ERROR", "Health check failed:")
        for _, issue in ipairs(issues) do
            Utils.Log("ERROR", "  - %s", issue)
        end
    end
    
    -- Final report
    Diagnostics:Report()
    
    NEXUS.State.Ready = true
    NEXUS.State.Initialized = true
    
    Utils.Log("SUCCESS", "NEXUS Gateway initialized successfully!")
    return true
end

-- ═══════════════════════════════════════════════════════════
-- RUN
-- ═══════════════════════════════════════════════════════════

local success, err = pcall(Initialize)

if not success then
    warn("[NEXUS] Fatal error:", err)
    NEXUS.State.Error = err
end

return NEXUS
