local _version = "1.6.66"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 


-- shindo life window
local Window = WindUI:CreateWindow({
    Title = "NexusHUB",
    Icon = "sprout",
    Author = "by Bursuc studio",
    Folder = "MyHubConfig",
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

local Tab2 = Window:tab({
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

-- tab2 elements
tab2:button({
    Title = "redeam all codes"
    callback = function()
      local args = {
	"addtwitter",
	""
}
game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer(unpack(args))
})