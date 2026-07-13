local _version = "1.6.66"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 

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
                    -- PAS 1: Acceptă misiunea (dacă e selectat un boss)
                    if selectedBoss then
                        pcall(function()
                            local missionFolder = workspace:FindFirstChild("bossdropmission")
                            if missionFolder then
                                local args = { LocalPlayer }
                                missionFolder:WaitForChild("missions")
                                    :WaitForChild(selectedBoss)
                                    :WaitForChild("missiongiver")
                                    :WaitForChild("CLIENTTALK")
                                    :FireServer(unpack(args))
                            end
                        end)
                    end

                    task.wait(2) -- timp pentru spawn

                    -- PAS 2: cât timp mai există orice NPC (npc+număr) viu, omoară-i pe rând
                    local anyFound = true
                    while autoFarmRunning and anyFound do
                        anyFound = false

                        local npcFolder = workspace:FindFirstChild("npc")
                        if npcFolder then
                            local character = LocalPlayer.Character
                            local root = character and character:FindFirstChild("HumanoidRootPart")

                            -- găsește cel mai apropiat NPC viu
                            local target = nil
                            local targetDist = math.huge

                            for _, child in ipairs(npcFolder:GetChildren()) do
                                if child.Name:match("^npc%d+$") then
                                    local hum = child:FindFirstChildOfClass("Humanoid")
                                    local npcRoot = child:FindFirstChild("HumanoidRootPart")
                                    if hum and hum.Health > 0 and npcRoot and root then
                                        anyFound = true
                                        local dist = (npcRoot.Position - root.Position).Magnitude
                                        if dist < targetDist then
                                            targetDist = dist
                                            target = child
                                        end
                                    end
                                end
                            end

                            if target and root then
                                local npcRoot = target:FindFirstChild("HumanoidRootPart")
                                local humanoid = target:FindFirstChildOfClass("Humanoid")

                                -- atacă acest target până moare sau nu mai e valid
                                while autoFarmRunning and target.Parent and humanoid.Health > 0 do
                                    local targetPos = npcRoot.Position + Vector3.new(0, setupHeight, -setupDistance)
                                    root.CFrame = CFrame.new(targetPos, npcRoot.Position)

                                    local combatUpdate = character:FindFirstChild("combat") and character.combat:FindFirstChild("update")
                                    local startEvent = LocalPlayer:FindFirstChild("startevent")

                                    if combatUpdate and startEvent then
                                        combatUpdate:FireServer("mouse1", true)
                                        for j = 1, 5 do
                                            startEvent:FireServer("target")
                                        end
                                        task.wait(0.05)
                                        combatUpdate:FireServer("mouse1", false)
                                        startEvent:FireServer("target")
                                    end

                                    task.wait(0.4)
                                end
                            end
                        end

                        task.wait(0.3)
                    end

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
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if not root then
                        task.wait(1)
                        continue
                    end

                    local folder = workspace:FindFirstChild("missiongivers")
                    if not folder then
                        task.wait(1)
                        continue
                    end

                    local closest = nil
                    local closestDist = math.huge

                    for _, giver in ipairs(folder:GetChildren()) do
                        local talk = giver:FindFirstChild("Talk")
                        local npcRoot = giver:FindFirstChild("HumanoidRootPart")

                        if talk and npcRoot then
                            local talk1 = talk:FindFirstChild("talk1")
                            local typValue = talk:FindFirstChild("typ")

                            -- eligibil DOAR dacă talk1 are text real (nu e gol)
                            local hasActiveQuest = talk1 and talk1.Value ~= ""

                            local matchesType = selectedQuestType == "oricare"
                                or (typValue and typValue.Value == selectedQuestType)

                            if hasActiveQuest and matchesType then
                                local dist = (npcRoot.Position - root.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closest = giver
                                end
                            end
                        end
                    end

                    if not closest then
                        task.wait(1)
                        continue
                    end

                    local npcRoot = closest:FindFirstChild("HumanoidRootPart")
                    local clientTalk = closest:WaitForChild("CLIENTTALK")

                    local pinConnection
                    pinConnection = RunService.RenderStepped:Connect(function()
                        if npcRoot and npcRoot.Parent and root and root.Parent then
                            root.CFrame = npcRoot.CFrame * CFrame.new(0, 0, 3)
                        end
                    end)

                    task.wait(0.3)
                    clientTalk:FireServer()
                    task.wait(0.5)
                    clientTalk:FireServer("accept")
                    task.wait(0.5)

                    if pinConnection then
                        pinConnection:Disconnect()
                        pinConnection = nil
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
            local npcFolder = workspace:FindFirstChild("npc")
            if not npcFolder then
                WindUI:Notify({ Title = "Error", Content = "Boss not spawned yet", Duration = 3 })
                return
            end

            local npc = nil
            for _, child in ipairs(npcFolder:GetChildren()) do
                if child.Name:match("^npc%d+$") and child:FindFirstChildOfClass("Humanoid") then
                    npc = child
                    break
                end
            end

            if not npc then
                WindUI:Notify({ Title = "Error", Content = "Boss not spawned yet", Duration = 3 })
                return
            end

            local npcRoot = npc:FindFirstChild("HumanoidRootPart")
            local character = LocalPlayer.Character
            if not npcRoot or not character or not character:FindFirstChild("HumanoidRootPart") then
                return
            end
            local root = character.HumanoidRootPart

            setupConnection = RunService.RenderStepped:Connect(function()
                if npc and npc.Parent and root and root.Parent then
                    local targetPos = npcRoot.Position + Vector3.new(0, setupHeight, -setupDistance)
                    root.CFrame = CFrame.new(targetPos, npcRoot.Position)
                end
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

        local args = { LocalPlayer }
        
        local missionFolder = workspace:FindFirstChild("bossdropmission")
        if missionFolder then
            missionFolder:WaitForChild("missions")
                :WaitForChild(selectedBoss)
                :WaitForChild("missiongiver")
                :WaitForChild("CLIENTTALK")
                :FireServer(unpack(args))
        end
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
                while getgenv().BloodlineSpin do
                    for _, kg in ipairs(selectedKGs) do
                        if not getgenv().BloodlineSpin then break end
                        game.Players.LocalPlayer.startevent:FireServer("spin", kg)
                        task.wait(0.5)
                    end
                    task.wait(1.5)
                end
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
                while getgenv().ElementSpin do
                    for _, elem in ipairs(selectedElements) do
                        if not getgenv().ElementSpin then break end
                        game.Players.LocalPlayer.startevent:FireServer("spin", elem)
                        task.wait(0.5)
                    end
                    task.wait(1.5)
                end
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
        for _, code in ipairs(ActiveCodes) do
            local args = { "addtwitter", code }
            game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer(unpack(args))
            task.wait(0.01)
        end
    end,
})
