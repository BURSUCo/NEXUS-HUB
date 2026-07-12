local _version = "1.6.66" -- Corectat "Local" cu "local"
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

OWNER:Button({
    Title = "TEST AUTO FARM (Atac Shindo Fixat)",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        -- Căutăm caracterul în workspace (ex: Workspace.bursucooo)
        local character = player.Character or workspace:FindFirstChild(player.Name)
        
        -- Definim locațiile exacte ale remote-urilor bazat pe log
        local combatUpdate = character and character:FindFirstChild("combat") and character.combat:FindFirstChild("update")
        local startEvent = player:FindFirstChild("startevent")

        if combatUpdate and startEvent then
            for i = 1, 4 do
                -- 1. Apăsăm click-ul (mouse1 = true)
                combatUpdate:FireServer("mouse1", true)
                
                -- 2. Trimitem semnalele de target așa cum face jocul
                startEvent:FireServer("target")
                startEvent:FireServer("target")
                startEvent:FireServer("target")
                
                task.wait(0.1) 
                
                -- 3. Ridicăm click-ul (mouse1 = false)
                combatUpdate:FireServer("mouse1", false)
                
                -- 4. Mai trimitem câteva semnale de target pe finalul mișcării
                startEvent:FireServer("target")
                
                task.wait(0.15) -- Pauză între pumni
            end
            print("Combo de 4 atacuri complet!")
        else
            WindUI:Notify({ Title = "Eroare", Content = "Remote-urile de combat nu au fost găsite!", Duration = 3 })
        end
    end,
})


-- setup distance
local setupDistance = 5
local setupHeight = 0
local setupConnection = nil

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
local selectedBoss = nil -- Declarată variabila pentru a evita erorile

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

        local args = {           
            game:GetService("Players").LocalPlayer -- Am schimbat din "Bossdebossperoblox" în LocalPlayer
        }
        
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
