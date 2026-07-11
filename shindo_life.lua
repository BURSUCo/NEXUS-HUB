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
local LocalPlayer = Players.LocalPlayer

-- Pune aici UserId-urile celor cărora vrei să le dai acces (al tău + al prietenilor)
local OwnerIds = {
    3213344881, -- OWNER BURSUC
    987654321, -- UserId DEVELOPER 1
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
    Title = "Debug: Find NPCs",
    Callback = function()
        -- Caută toate obiectele cu Humanoid din workspace (majoritatea NPC-urilor au Humanoid)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") then
                local npcModel = obj.Parent
                print("NPC găsit: " .. npcModel.Name .. " | Path: " .. npcModel:GetFullName())
            end
        end
    end,
})



-- setup distance

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Aici pui numele NPC-ului din workspace
local NPCName = "logtraining" -- schimbă cu numele exact al NPC-ului

local setupDistance = 5    -- distanța default (studs)
local setupHeight = 0      -- înălțimea default (studs, + sus / - jos)
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
            local npc = workspace:FindFirstChild(NPCName, true)
            if not npc or not npc:FindFirstChild("HumanoidRootPart") then
                WindUI:Notify({
                    Title = "Error",
                    Content = "NPC not found",
                    Duration = 3,
                })
                return
            end

            local npcRoot = npc.HumanoidRootPart
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
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

OWNER:Toggle({
    Title = "Setup Distance",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedBoss then
                WindUI:Notify({ Title = "Error", Content = "Alege întâi un boss", Duration = 3 })
                return
            end

            local missionFolder = workspace:WaitForChild("bossdropmission"):WaitForChild("missions"):FindFirstChild(selectedBoss)
            if not missionFolder then
                WindUI:Notify({ Title = "Error", Content = "Mission not found", Duration = 3 })
                return
        end

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
local selectedBoss = nil

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
            return
        end

        local args = {           
        game:GetService("Players"):WaitForChild("Bossdebossperoblox")
        }
        workspace:WaitForChild("bossdropmission")
            :WaitForChild("missions")
            :WaitForChild(selectedBoss)
            :WaitForChild("missiongiver")
            :WaitForChild("CLIENTTALK")
            :FireServer(unpack(args))
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
            task.wait(0.5)
        end
    end,
})