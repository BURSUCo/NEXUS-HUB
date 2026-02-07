-- main.lua
-- Script principal NEXUS HUB

local Library = getgenv().NEXUS_LIBRARY
if not Library then
    warn("[NEXUS] Library not found!")
    return
end

print("[NEXUS] Main loaded")

-- Exemplu simplu de folosire a librăriei
local Window = Library:CreateWindow("NEXUS HUB")

-- Dacă library ta are tab/section, adaptezi aici
-- Exemplu generic:
if Window.AddTab then
    local Tab = Window:AddTab("Main")

    if Tab.AddButton then
        Tab:AddButton("Test Button", function()
            print("[NEXUS] Test Button clicked")
        end)
    end
end
