-- NEXUS HUB Gateway (GitHub RAW)
-- Toate fișierele sunt în același repo

-- RAW linkuri (schimbă USER/REPO dacă e cazul)
local RAW_BASE = "https://raw.githubusercontent.com/BURSUCo/NEXUS-HUB/main/"

local LIB_URL  = RAW_BASE .. "library.lua"
local MAIN_URL = RAW_BASE .. "main.lua"

print("[NEXUS] Loading Library...")

local libCode = game:HttpGet(LIB_URL)
local Library = loadstring(libCode)()

if not Library then
    warn("[NEXUS] Failed to load Library!")
    return
end

getgenv().NEXUS_LIBRARY = Library

print("[NEXUS] Loading Main...")

local mainCode = game:HttpGet(MAIN_URL)
loadstring(mainCode)()
