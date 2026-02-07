-- main.lua
local UI = require(script.Parent:WaitForChild("library"))  -- sau dofile("library.lua") dacă e local
local Window = UI:CreateWindow("Test Hub")

-- Creează un tab/categorie
local TestTab = Window:AddTab("Test Category")

-- Adaugă un buton simplu
TestTab:AddButton("Click Me!", function()
    print("Button clicked!")
end)

print("UI test initialized. Open Roblox Output pentru a vedea log-ul.")