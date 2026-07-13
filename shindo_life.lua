local _version = "1.6.66"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 

-- încarcă librăria cu toate funcțiile reutilizabile
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BURSUCo/NEXUS-HUB/refs/heads/main/lib.lua"))()

-- shindo life window
local Window = WindUI:CreateWindow({
    Title = "NexusHUB",
    Icon = "sprout",
    Author = "by Bursuc studio",
    Folder = "NexusHUB",
})

-- tab OWNER/DEVELOPERS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- variabile globale, declarate SUS, folosite de OWNER și de celelalte tab-uri
local selectedBoss = nil
local setupDistance = 5
local setupHeight = 0
local setupConnection = nil
local autoFarmRunning = false
local questFarmRunning = false
local selectedQuestType = "oricare"

-- Pune aici UserId-urile celor cărora vrei să le dai acces (al tău + al prietenilor)
local OwnerIds = {
    3213344881, -- OWNER BURSUC
    11188345834, -- UserId DEVELOPER 1
    111222333, -- UserId DEVELOPER 2
}

local function isOwner(userId)
    for _, id in ipairs(OwnerIds) do
        if id == userId then
            return true
        end
    end
    return false
end

local OWNER = Window:Tab({
    Title = "OWNER",
    Icon = "crown",
    Locked = not isOwner(LocalPlayer.UserId),
})

-- elements OWNER/DEVELOPERS

-- ==================== AUTO FARM (BOSS) ====================
OWNER:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(state)
        autoFarmRunning = state

        if state then
            task.spawn(function()
                while autoFarmRunning do
                    if selectedBoss then
                        Lib.AcceptBossMission("bossdropmission", selectedBoss)
                    end

                    task.wait(2) -- timp pentru spawn

                    Lib.KillAllMobs(setupDistance, setupHeight, function() return autoFarmRunning end)

                    task.wait(1) -- pauză înainte de misiunea următoare
                end
            end)
        end
    end,
})


-- ==================== AUTO FARM (QUEST NPC) ====================
OWNER:Dropdown({
    Title = "Tip misiune (Quest NPC)",
    Values = {"oricare", "defeat", "envelope", "grocerybag", "weeds", "dirt", "cat", "graffiti"},
    Value = "oricare",
    Flag = "QuestType",
    Callback = function(choice)
        selectedQuestType = choice
    end,
})

OWNER:Toggle({
    Title = "Auto Farm (Quest NPC)",
    Value = false,
    Callback = function(state)
        questFarmRunning = state

        if state then
            task.spawn(function()
                while questFarmRunning do
                    local accepted = Lib.AcceptNearestQuest(selectedQuestType)

                    if accepted then
                        task.wait(2) -- timp pentru spawn mob (dacă e misiune de tip defeat)
                        Lib.KillAllMobs(setupDistance, setupHeight, function() return questFarmRunning end)
                    end

                    task.wait(1)
                end
            end)
        end
    end,
})


-- ==================== SETUP DISTANCE ====================
OWNER:Input({
    Title = "Distance",
    Placeholder = "5",
    Value = "5",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            setupDistance = num
        end
    end,
})

OWNER:Input({
    Title = "Height",
    Placeholder = "0",
    Value = "0",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            setupHeight = num
        end
    end,
})

OWNER:Toggle({
    Title = "Setup Distance",
    Value = false,
    Callback = function(state)
        if state then
            setupConnection = Lib.StartSetupDistance(setupDistance, setupHeight, function(msg)
                WindUI:Notify({ Title = "Error", Content = msg, Duration = 3 })
            end)
        else
            if setupConnection then
                setupConnection:Disconnect()
                setupConnection = nil
            end
        end
    end,
})

-- tabs

local Tab9 = Window:Tab({
    Title = "Settings",
    Icon = "cog",
})

local Tab0 = Window:Tab({
    Title = "main",
    Icon = "house",
})

local Tab1 = Window:Tab({
    Title = "spins",
    Icon = "refresh-ccw-dot",
})

local Tab2 = Window:Tab({
    Title = "misc",
    Icon = "",
})

-- tab9 elements
Tab9:Dropdown({
    Title = "select a teme",
    Flag = "SelectedTheme",
    Values = {"Dark", "Light", "Rose", "Plant", "Indigo", "Sky", "Violet", "Amber", "Midnight"},
    Value = "Midnight",
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end,
})

-- tab0 elements

local FarmM = Tab0:Section({
    Title = "Farm mission"
})

FarmM:Dropdown({ 
    Title = "select boss",
    Values = { 
      "Bankai Akuma", "Dio Senko", "Forged Akuma", "Kamaki", "Pts Raion", "Raion Akuma", "Satori Akuma"
    },
    Value = "select boss",
    Flag = "SelectedBoss",
    Callback = function(choice)
        selectedBoss = choice
    end,
})

FarmM:Toggle({ 
    Title = "Start Farm",
    Callback = function()
        if not selectedBoss then
            WindUI:Notify({ Title = "Error", Content = "Select a boss first!", Duration = 3 })
            return
        end

        Lib.AcceptBossMission("bossdropmission", selectedBoss)
    end,
})

-- tab1 elements
getgenv().BloodlineSpin = false
getgenv().ElementSpin = false

local selectedKGs = {"kg1"}
local selectedElements = {"element1"}

-- Dropdown Multi pentru Bloodline
Tab1:Dropdown({
    Title = "Alege Bloodline(uri)",
    Values = {"kg1", "kg2", "kg3", "kg4"},
    Value = {"kg1"},
    Multi = true,
    Flag = "SelectedKGs",
    Callback = function(choices)
        selectedKGs = choices 
    end,
})

-- Toggle Bloodline Auto Spin
Tab1:Toggle({
    Title = "Bloodline Auto Spin",
    Value = false,
    Callback = function(state)
        getgenv().BloodlineSpin = state

        if state then
            task.spawn(function()
                Lib.AutoSpinBloodline(selectedKGs, function() return getgenv().BloodlineSpin end)
            end)
        end
    end,
})

-- Dropdown Multi pentru Element
Tab1:Dropdown({
    Title = "Alege Element(e)",
    Values = {"element1", "element2", "element3", "element4"},
    Value = {"element1"},
    Multi = true,
    Flag = "SelectedElements",
    Callback = function(choices)
        selectedElements = choices
    end,
})

-- Toggle Element Auto Spin
Tab1:Toggle({
    Title = "Element Auto Spin",
    Value = false,
    Callback = function(state)
        getgenv().ElementSpin = state

        if state then
            task.spawn(function()
                Lib.AutoSpinElement(selectedElements, function() return getgenv().ElementSpin end)
            end)
        end
    end,
})

-- tab2 codes
local ActiveCodes = {
    "ShindoDownAGAIN2x!", "ShindoLifeTakenDown!", "2mLikesC0d3d!", "RELLGIFTsc!",
    "RELLGIFTbag!", "Year5ShindoLife!", "5YearsReleased!", "5YearsOfShindoLife!",
    "5YearSL2!", "ShindoLife5YearCodes!", "ITSBeen5Years!", "ThankYouAllTruly!",
    "TimeFliesForFiveYears!", "ItrulyDOMissTheseTimes!", "ButWelooktowardThe!",
    "FutureAndRELLSeas!", "IsTheNextinLine!", "ItsTrulyLegendary!", "OneOfaKind!",
    "ThisPlatformaintReady!", "TheCommunitygonnaEat!", "BoredomWillBeRescued!",
    "WePerfectedRELLSeas!", "forTheFuture!", "ofOurGames!", "WeGotaLotofTestingtoDo!",
    "beforeWerecord!", "RELLSeasMovie3!", "theWorkloadSeems!", "neverENDING!"
}

-- tab2 elements
Tab2:Button({
    Title = "Redeem all codes",
    Callback = function()
        Lib.RedeemAllCodes(ActiveCodes, 0.01)
    end,
})
