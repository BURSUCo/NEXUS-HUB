--[[
    Library.lua
    Librărie GUI custom pentru Roblox (Luau), inspirată vizual de panouri tip "Nexa".
    Componente: Window, Tab, Section, Button, Toggle, Dropdown, Input, Label.
    Complet themabilă (culori, titlu) prin Library:SetTheme({...}).

    UTILIZARE RAPIDĂ:
    local Library = loadstring(game:HttpGet("URL_CATRE_FISIER"))()
    -- sau, dacă îl bagi ca ModuleScript:
    local Library = require(path.to.Library)

    local Window = Library:CreateWindow({
        Title = "System Utilities",
        SubTitle = "Control Panel : Free",
        Theme = { Accent = Color3.fromRGB(0, 255, 140) }, -- optional overrides
    })

    local Tab = Window:CreateTab("System Status", "rbxassetid://0")

    local Left = Tab:CreateSection("System Core", "Left")
    Left:AddButton("Initialize All Tasks", function() print("run") end)
    Left:AddToggle("Optimize Output", true, function(state) print(state) end)
    Left:AddDropdown("Project Location", {"Global Server", "EU", "NA"}, "Global Server", function(v) end)
    Left:AddInput("Search", "Type here...", function(text) end)

    local Right = Tab:CreateSection("Resource Monitoring", "Right")
    Right:AddLabel("Mythic Creatures", "Not Active", false) -- false = roșu, true = verde
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// ===================== TEMA IMPLICITĂ (ca în poza ta) =====================
local DefaultTheme = {
    Background   = Color3.fromRGB(15, 18, 22),
    Header       = Color3.fromRGB(12, 14, 18),
    Sidebar      = Color3.fromRGB(18, 21, 26),
    SidebarItem  = Color3.fromRGB(24, 28, 34),
    Section      = Color3.fromRGB(20, 23, 28),
    Stroke       = Color3.fromRGB(35, 40, 47),
    Accent       = Color3.fromRGB(0, 255, 140),   -- verde ca în poză
    AccentDark   = Color3.fromRGB(0, 180, 100),
    Text         = Color3.fromRGB(235, 235, 235),
    SubText      = Color3.fromRGB(140, 145, 150),
    Good         = Color3.fromRGB(70, 220, 130),
    Bad          = Color3.fromRGB(255, 80, 80),
    Font         = Enum.Font.GothamBold,
    FontRegular  = Enum.Font.Gotham,
}

--// ===================== UTILITARE =====================
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function tween(inst, props, time)
    TweenService:Create(inst, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness)
    return create("UIStroke", { Color = color, Thickness = thickness or 1 })
end

--// ===================== LIBRARY CORE =====================
local Library = {}
Library.__index = Library

function Library:CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, Library)

    self.Theme = {}
    for k, v in pairs(DefaultTheme) do self.Theme[k] = v end
    if config.Theme then
        for k, v in pairs(config.Theme) do self.Theme[k] = v end
    end

    self._themedObjects = {} -- {instance, propertyName, themeKey}
    self.Tabs = {}

    -- ScreenGui
    local screenGui = create("ScreenGui", {
        Name = "CustomLibraryUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local ok = pcall(function() screenGui.Parent = CoreGui end)
    if not ok then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui = screenGui

    -- Main frame
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(500, 310),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        Parent = screenGui,
    }, { corner(10), stroke(self.Theme.Stroke, 1) })
    self.Main = main
    self:_registerTheme(main, "BackgroundColor3", "Background")

    -- Header (titlu / subtitlu ca în poza ta)
    local header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = self.Theme.Header,
        Parent = main,
    }, { corner(10) })
    self:_registerTheme(header, "BackgroundColor3", "Header")
    -- mască ca să nu rotunjească jos
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = self.Theme.Header,
        BorderSizePixel = 0,
        Parent = header,
    })

    local titleLabel = create("TextLabel", {
        Text = config.Title or "Window",
        Font = self.Theme.Font,
        TextSize = 18,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 8),
        Size = UDim2.new(1, -40, 0, 22),
        Parent = header,
    })
    self:_registerTheme(titleLabel, "TextColor3", "Text")

    local subLabel = create("TextLabel", {
        Text = config.SubTitle or "",
        Font = self.Theme.FontRegular,
        TextSize = 13,
        TextColor3 = self.Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 30),
        Size = UDim2.new(1, -40, 0, 18),
        Parent = header,
    })
    self:_registerTheme(subLabel, "TextColor3", "SubText")
    self.TitleLabel, self.SubTitleLabel = titleLabel, subLabel

    -- Close button
    local closeBtn = create("TextButton", {
        Text = "X",
        Font = self.Theme.Font,
        TextSize = 16,
        TextColor3 = self.Theme.SubText,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -40, 0, 15),
        Parent = header,
    })
    self:_registerTheme(closeBtn, "TextColor3", "SubText")
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)

    -- Sidebar
    local sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 220, 1, -60),
        Position = UDim2.fromOffset(0, 60),
        BackgroundColor3 = self.Theme.Sidebar,
        Parent = main,
    })
    self:_registerTheme(sidebar, "BackgroundColor3", "Sidebar")

    local sidebarList = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    sidebarList.Parent = sidebar
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }).Parent = sidebar

    -- Content area (unde apar tab-urile)
    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -220, 1, -60),
        Position = UDim2.fromOffset(220, 60),
        BackgroundTransparency = 1,
        Parent = main,
    })
    self.Sidebar = sidebar
    self.Content = content

    -- Drag din header
    do
        local dragging, dragStart, startPos = false, nil, nil
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    self._firstTab = true
    return self
end

function Library:_registerTheme(instance, property, themeKey)
    table.insert(self._themedObjects, { instance = instance, property = property, key = themeKey })
end

-- Schimbă tema live (culori din poza ta, titlu, etc.)
function Library:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        self.Theme[k] = v
    end
    for _, entry in ipairs(self._themedObjects) do
        if entry.instance and entry.instance.Parent then
            entry.instance[entry.property] = self.Theme[entry.key]
        end
    end
end

function Library:SetTitle(title, subtitle)
    if title then self.TitleLabel.Text = title end
    if subtitle then self.SubTitleLabel.Text = subtitle end
end

--// ===================== TAB =====================
function Library:CreateTab(name, icon)
    local theme = self.Theme

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = theme.SidebarItem,
        Text = "",
        Parent = self.Sidebar,
    }, { corner(6) })
    self:_registerTheme(btn, "BackgroundColor3", "SidebarItem")

    if icon then
        create("ImageLabel", {
            Image = icon,
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            ImageColor3 = theme.Accent,
            Parent = btn,
        })
    end

    local nameLabel = create("TextLabel", {
        Text = name,
        Font = theme.Font,
        TextSize = 15,
        TextColor3 = theme.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(icon and 44 or 14, 4),
        Size = UDim2.new(1, -50, 0, 18),
        Parent = btn,
    })
    self:_registerTheme(nameLabel, "TextColor3", "Text")

    -- Pagină asociată tab-ului (2 coloane, ca în poza ta)
    local page = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = self._firstTab,
        Parent = self.Content,
    })
    self._firstTab = false

    local scroll = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
    }).Parent = scroll

    local columns = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 15),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    columns.Parent = scroll

    local leftCol = create("Frame", {
        Size = UDim2.new(0.5, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = scroll,
    })
    create("UIListLayout", { Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = leftCol

    local rightCol = create("Frame", {
        Size = UDim2.new(0.5, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = scroll,
    })
    create("UIListLayout", { Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = rightCol

    -- Click pe tab -> ascunde restul, arată pagina asta
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = theme.SidebarItem
        end
        page.Visible = true
        btn.BackgroundColor3 = theme.AccentDark
    end)

    local Tab = {
        Button = btn,
        Page = page,
        Left = leftCol,
        Right = rightCol,
        _lib = self,
    }
    table.insert(self.Tabs, Tab)

    if page.Visible then
        btn.BackgroundColor3 = theme.AccentDark
    end

    --// ===================== SECTION =====================
    function Tab:CreateSection(sectionName, side)
        local lib = self._lib
        local theme = lib.Theme
        local parentCol = (side == "Right") and self.Right or self.Left

        local sectionFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Section,
            Parent = parentCol,
        }, { corner(6) })
        lib:_registerTheme(sectionFrame, "BackgroundColor3", "Section")

        create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }).Parent = sectionFrame

        local layout = create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        layout.Parent = sectionFrame

        local titleLbl = create("TextLabel", {
            Text = sectionName,
            Font = theme.Font,
            TextSize = 15,
            TextColor3 = theme.Text,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            LayoutOrder = 0,
            Parent = sectionFrame,
        })
        lib:_registerTheme(titleLbl, "TextColor3", "Text")

        local underline = create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Parent = sectionFrame,
        })
        lib:_registerTheme(underline, "BackgroundColor3", "Accent")

        local Section = { Frame = sectionFrame, _lib = lib, _order = 2 }

        local function nextOrder()
            Section._order += 1
            return Section._order
        end

        -- BUTTON
        function Section:AddButton(text, callback)
            local theme = lib.Theme
            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = theme.AccentDark,
                Text = text,
                Font = theme.Font,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(10, 10, 10),
                LayoutOrder = nextOrder(),
                Parent = sectionFrame,
            }, { corner(6) })
            lib:_registerTheme(btn, "BackgroundColor3", "AccentDark")
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = theme.Accent }) end)
            btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = theme.AccentDark }) end)
            return btn
        end

        -- TOGGLE
        function Section:AddToggle(text, default, callback)
            local theme = lib.Theme
            local state = default or false

            local holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = sectionFrame,
            })

            local lbl = create("TextLabel", {
                Text = text,
                Font = theme.FontRegular,
                TextSize = 14,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -50, 1, 0),
                Parent = holder,
            })
            lib:_registerTheme(lbl, "TextColor3", "Text")

            local box = create("TextButton", {
                Text = "",
                Size = UDim2.fromOffset(24, 24),
                Position = UDim2.new(1, -24, 0.5, -12),
                BackgroundColor3 = state and theme.Accent or theme.SidebarItem,
                Parent = holder,
            }, { corner(6) })

            local check = create("TextLabel", {
                Text = "✓",
                Font = theme.Font,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(10, 10, 10),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = state,
                Parent = box,
            })

            box.MouseButton1Click:Connect(function()
                state = not state
                check.Visible = state
                tween(box, { BackgroundColor3 = state and theme.Accent or theme.SidebarItem })
                if callback then callback(state) end
            end)

            return { Set = function(_, v) state = v; check.Visible = v; box.BackgroundColor3 = v and theme.Accent or theme.SidebarItem end }
        end

        -- DROPDOWN
        function Section:AddDropdown(text, options, default, callback)
            local theme = lib.Theme
            options = options or {}
            local selected = default or options[1] or ""

            local holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = sectionFrame,
            })

            create("TextLabel", {
                Text = text,
                Font = theme.FontRegular,
                TextSize = 13,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 16),
                Parent = holder,
            })

            local box = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.fromOffset(0, 20),
                BackgroundColor3 = theme.SidebarItem,
                Text = "  " .. tostring(selected),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = theme.FontRegular,
                TextSize = 14,
                TextColor3 = theme.Text,
                Parent = holder,
            }, { corner(6) })
            lib:_registerTheme(box, "BackgroundColor3", "SidebarItem")

            local optionsFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, #options * 28),
                Position = UDim2.fromOffset(0, 54),
                BackgroundColor3 = theme.SidebarItem,
                Visible = false,
                ZIndex = 5,
                Parent = holder,
            }, { corner(6) })

            local optList = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
            optList.Parent = optionsFrame

            for _, opt in ipairs(options) do
                local optBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = "  " .. tostring(opt),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = theme.FontRegular,
                    TextSize = 13,
                    TextColor3 = theme.Text,
                    ZIndex = 5,
                    Parent = optionsFrame,
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    box.Text = "  " .. tostring(opt)
                    optionsFrame.Visible = false
                    if callback then callback(opt) end
                end)
            end

            box.MouseButton1Click:Connect(function()
                optionsFrame.Visible = not optionsFrame.Visible
            end)

            return { Get = function() return selected end }
        end

        -- INPUT
        function Section:AddInput(text, placeholder, callback)
            local theme = lib.Theme
            local holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = sectionFrame,
            })

            create("TextLabel", {
                Text = text,
                Font = theme.FontRegular,
                TextSize = 13,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 16),
                Parent = holder,
            })

            local box = create("TextBox", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.fromOffset(0, 20),
                BackgroundColor3 = theme.SidebarItem,
                Text = "",
                PlaceholderText = placeholder or "",
                Font = theme.FontRegular,
                TextSize = 14,
                TextColor3 = theme.Text,
                PlaceholderColor3 = theme.SubText,
                ClearTextOnFocus = false,
                Parent = holder,
            }, { corner(6) })
            lib:_registerTheme(box, "BackgroundColor3", "SidebarItem")
            create("UIPadding", { PaddingLeft = UDim.new(0, 8) }).Parent = box

            box.FocusLost:Connect(function(enterPressed)
                if callback then callback(box.Text, enterPressed) end
            end)

            return box
        end

        -- LABEL (elementul "Cheie : Valoare" colorat, ca "Mythic Creatures : X Not Active")
        function Section:AddLabel(key, value, isGood)
            local theme = lib.Theme
            local holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = sectionFrame,
            })

            local keyLbl = create("TextLabel", {
                Text = key .. " : ",
                Font = theme.FontRegular,
                TextSize = 14,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0.6, 0, 1, 0),
                Parent = holder,
            })
            lib:_registerTheme(keyLbl, "TextColor3", "Text")

            local valueColor = (isGood == nil) and theme.SubText or (isGood and theme.Good or theme.Bad)
            local valLbl = create("TextLabel", {
                Text = tostring(value),
                Font = theme.Font,
                TextSize = 14,
                TextColor3 = valueColor,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(0.6, 0, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Parent = holder,
            })

            return {
                Set = function(_, newValue, good)
                    valLbl.Text = tostring(newValue)
                    valLbl.TextColor3 = (good == nil) and theme.SubText or (good and theme.Good or theme.Bad)
                end
            }
        end

        return Section
    end

    return Tab
end

return Library
