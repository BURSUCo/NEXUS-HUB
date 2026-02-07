-- gateway.lua
-- Loader pentru NEXUS HUB

local BASE = "https://raw.githubusercontent.com/BURSUCo/NEXUS-HUB/main/"

print("[NEXUS] Gateway loaded")

-- Load library.lua
local libCode = game:HttpGet(BASE .. "library.lua")
if not libCode then
    warn("[NEXUS] Failed to load library.lua")
    return
end

local Library = loadstring(libCode)()
if not Library then
    warn("[NEXUS] Library did not return anything")
    return
end

-- Save library globally for main.lua
getgenv().NEXUS_LIBRARY = Library
print("[NEXUS] Library loaded")

-- Load main.lua
local mainCode = game:HttpGet(BASE .. "main.lua")
if not mainCode then
    warn("[NEXUS] Failed to load main.lua")
    return
end

print("[NEXUS] Loading main.lua")
loadstring(mainCode)()
