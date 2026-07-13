-- lib.lua
-- Librărie NexusHUB — toate funcțiile confirmate funcționale, reunite
-- Se încarcă în main.lua cu:
-- local Lib = loadstring(game:HttpGet("URL_RAW_lib.lua"))()

local Lib = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- COMBAT
-- ============================================================

-- Atacă o țintă (npc cu Humanoid) până moare, cât timp runningFlagFn() întoarce true
-- target: instanța NPC-ului (trebuie să aibă HumanoidRootPart + Humanoid)
-- setupDistance/setupHeight: poziția relativă de unde ataci
-- runningFlagFn: funcție care întoarce true/false (ex: function() return autoFarmRunning end)
function Lib.AttackTarget(target, setupDistance, setupHeight, runningFlagFn)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    local humanoid = target:FindFirstChildOfClass("Humanoid")

    if not (character and root and targetRoot and humanoid) then
        return false
    end

    while runningFlagFn() and target.Parent and humanoid.Health > 0 do
        local targetPos = targetRoot.Position + Vector3.new(0, setupHeight, -setupDistance)
        root.CFrame = CFrame.new(targetPos, targetRoot.Position)

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

    return true
end

-- Caută în workspace.npc toate obiectele "npc123" cu Humanoid viu, întoarce cel mai apropiat de root
function Lib.FindClosestMob(root)
    local npcFolder = workspace:FindFirstChild("npc")
    if not npcFolder or not root then
        return nil
    end

    local target = nil
    local targetDist = math.huge

    for _, child in ipairs(npcFolder:GetChildren()) do
        if child.Name:match("^npc%d+$") then
            local hum = child:FindFirstChildOfClass("Humanoid")
            local npcRoot = child:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and npcRoot then
                local dist = (npcRoot.Position - root.Position).Magnitude
                if dist < targetDist then
                    targetDist = dist
                    target = child
                end
            end
        end
    end

    return target
end

-- Omoară toate mob-urile (npc+număr) din workspace.npc, unul câte unul, cât timp runningFlagFn() e true
function Lib.KillAllMobs(setupDistance, setupHeight, runningFlagFn)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local anyFound = true
    while runningFlagFn() and anyFound do
        anyFound = false
        local npcFolder = workspace:FindFirstChild("npc")

        if npcFolder then
            for _, child in ipairs(npcFolder:GetChildren()) do
                if child.Name:match("^npc%d+$") then
                    local hum = child:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        anyFound = true
                    end
                end
            end
        end

        if anyFound then
            local target = Lib.FindClosestMob(root)
            if target then
                Lib.AttackTarget(target, setupDistance, setupHeight, runningFlagFn)
            end
        end

        task.wait(0.3)
    end
end

-- ============================================================
-- SETUP DISTANCE (teleport continuu lângă un NPC/boss deja spawnat)
-- ============================================================

-- Pornește un RenderStepped care ține personajul lipit de cel mai apropiat mob din workspace.npc
-- Întoarce conexiunea (folosește :Disconnect() ca s-o oprești)
function Lib.StartSetupDistance(setupDistance, setupHeight, onError)
    local npcFolder = workspace:FindFirstChild("npc")
    if not npcFolder then
        if onError then onError("Boss not spawned yet") end
        return nil
    end

    local npc = nil
    for _, child in ipairs(npcFolder:GetChildren()) do
        if child.Name:match("^npc%d+$") and child:FindFirstChildOfClass("Humanoid") then
            npc = child
            break
        end
    end

    if not npc then
        if onError then onError("Boss not spawned yet") end
        return nil
    end

    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    local character = LocalPlayer.Character
    if not npcRoot or not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local root = character.HumanoidRootPart

    local connection = RunService.RenderStepped:Connect(function()
        if npc and npc.Parent and root and root.Parent then
            local targetPos = npcRoot.Position + Vector3.new(0, setupHeight, -setupDistance)
            root.CFrame = CFrame.new(targetPos, npcRoot.Position)
        end
    end)

    return connection
end

-- ============================================================
-- MISIUNI BOSS (bossdropmission, HAPPYmission, Koramamission, etc.)
-- ============================================================

-- Acceptă o misiune de boss dintr-un folder generic
-- folderName: numele folderului din workspace ("bossdropmission", "HAPPYmission", "Koramamission")
-- missionName: numele misiunii din interior ("Raion Akuma", "Hollow4", "Hollow9", etc.)
function Lib.AcceptBossMission(folderName, missionName)
    local args = { LocalPlayer }
    local missionFolder = workspace:FindFirstChild(folderName)
    if not missionFolder then
        return false
    end

    local ok = pcall(function()
        missionFolder:WaitForChild("missions")
            :WaitForChild(missionName)
            :WaitForChild("missiongiver")
            :WaitForChild("CLIENTTALK")
            :FireServer(unpack(args))
    end)

    return ok
end

-- ============================================================
-- MISIUNI NPC (missiongivers - NPC-uri care se plimbă, dau side-quest-uri)
-- ============================================================

-- Caută cel mai apropiat NPC eligibil (cu misiune activă reală: talk1 nu e gol)
-- și opțional filtrat după tip (questType = "oricare" sau "defeat"/"envelope"/etc)
-- Trimite secvența completă de accept (FireServer() apoi FireServer("accept"))
-- ținând personajul lipit de NPC în timpul secvenței (ca să nu rateze din cauza mișcării NPC-ului)
function Lib.AcceptNearestQuest(questType)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end

    local folder = workspace:FindFirstChild("missiongivers")
    if not folder then
        return false
    end

    local closest = nil
    local closestDist = math.huge

    for _, giver in ipairs(folder:GetChildren()) do
        local talk = giver:FindFirstChild("Talk")
        local npcRoot = giver:FindFirstChild("HumanoidRootPart")

        if talk and npcRoot then
            local talk1 = talk:FindFirstChild("talk1")
            local typValue = talk:FindFirstChild("typ")
            local hasActiveQuest = talk1 and talk1.Value ~= ""
            local matchesType = questType == "oricare" or (typValue and typValue.Value == questType)

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
        return false
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
    end

    return true
end

-- ============================================================
-- CODES (redeem)
-- ============================================================

-- Trimite un singur cod
function Lib.RedeemCode(code)
    local args = { "addtwitter", code }
    game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer(unpack(args))
end

-- Trimite o listă întreagă de coduri, cu pauză mică între ele
function Lib.RedeemAllCodes(codesList, waitTime)
    waitTime = waitTime or 0.05
    for _, code in ipairs(codesList) do
        Lib.RedeemCode(code)
        task.wait(waitTime)
    end
end

-- ============================================================
-- STATS (jutsu / health)
-- ============================================================

-- statName: "ninjutsu" sau "health" (sau alt nume de stat valid din joc)
-- amount: câte puncte adaugi (de obicei 1)
function Lib.AddStat(statName, amount)
    amount = amount or 1
    local args = { "addstat", statName, amount }
    game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer(unpack(args))
end

-- ============================================================
-- SPIN (bloodline / element)
-- ============================================================

-- kgName: "kg1", "kg2", "kg3", "kg4"
function Lib.SpinBloodline(kgName)
    game.Players.LocalPlayer.startevent:FireServer("spin", kgName)
end

-- elementName: "element1", "element2", "element3", "element4"
function Lib.SpinElement(elementName)
    game.Players.LocalPlayer.startevent:FireServer("spin", elementName)
end

-- Auto spin continuu pentru o listă de bloodline-uri, cât timp runningFlagFn() e true
function Lib.AutoSpinBloodline(kgList, runningFlagFn)
    while runningFlagFn() do
        for _, kg in ipairs(kgList) do
            if not runningFlagFn() then break end
            Lib.SpinBloodline(kg)
            task.wait(0.5)
        end
        task.wait(1.5)
    end
end

-- Auto spin continuu pentru o listă de elemente, cât timp runningFlagFn() e true
function Lib.AutoSpinElement(elementList, runningFlagFn)
    while runningFlagFn() do
        for _, elem in ipairs(elementList) do
            if not runningFlagFn() then break end
            Lib.SpinElement(elem)
            task.wait(0.5)
        end
        task.wait(1.5)
    end
end

-- ============================================================
-- TELEPORT SERVER
-- ============================================================

-- placeId: id-ul locului/serverului către care te teleportezi (ex: 4601350214)
function Lib.TeleportToServer(placeId)
    local args = { "rpgteleport", placeId }
    game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer(unpack(args))
end

-- Trimite comanda de "play" (probabil confirmare de join/start în lobby)
function Lib.Play()
    local args = { "play" }
    game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer(unpack(args))
end

return Lib
