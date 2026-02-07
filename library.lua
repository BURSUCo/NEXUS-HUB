--[[
    ╔══════════════════════════════════════════╗
    ║         ALCHEMY HUB UI LIBRARY           ║
    ║      Dark Theme • Purple/Blue Glow       ║
    ╚══════════════════════════════════════════╝
]]

local AlchemyLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════
--  THEME CONFIGURATION
-- ═══════════════════════════════════
local Theme = {
    Background        = Color3.fromRGB(18, 18, 24),
    Sidebar           = Color3.fromRGB(14, 14, 20),
    TopBar            = Color3.fromRGB(22, 22, 30),
    Section           = Color3.fromRGB(25, 25, 35),
    SectionBorder     = Color3.fromRGB(40, 40, 60),
    ElementBackground = Color3.fromRGB(30, 30, 42),
    ElementHover      = Color3.fromRGB(38, 38, 55),
    Accent            = Color3.fromRGB(130, 80, 255),
    AccentGlow        = Color3.fromRGB(100, 60, 220),
    AccentDark        = Color3.fromRGB(80, 40, 180),
    Text              = Color3.fromRGB(225, 225, 235),
    SubText           = Color3.fromRGB(150, 150, 170),
    DimText           = Color3.fromRGB(100, 100, 120),
    ToggleOn          = Color3.fromRGB(130, 80, 255),
    ToggleOff         = Color3.fromRGB(50, 50, 65),
    SliderFill        = Color3.fromRGB(130, 80, 255),
    SliderBackground  = Color3.fromRGB(40, 40, 55),
    DropdownBG        = Color3.fromRGB(22, 22, 32),
    CloseButton       = Color3.fromRGB(255, 70, 70),
    MinimizeButton    = Color3.fromRGB(255, 200, 50),
    CornerRadius      = UDim.new(0, 8),
    SmallCorner       = UDim.new(0, 6),
    TinyCorner        = UDim.new(0, 4),
    Font              = Enum.Font.Gotham,
    FontBold          = Enum.Font.GothamBold,
    FontSemibold      = Enum.Font.GothamSemibold,
    FontMedium        = Enum.Font.GothamMedium,
}

-- ═══════════════════════════════════
--  UTILITY FUNCTIONS
-- ═══════════════════════════════════
local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerRadius
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.SectionBorder
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 8)
    padding.PaddingRight = UDim.new(0, right or 8)
    padding.Parent = parent
    return padding
end

local function CreateListLayout(parent, padding, fillDir, hAlign, vAlign, sortOrder)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 6)
    layout.FillDirection = fillDir or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
    layout.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

local function CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

local function RippleEffect(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.ZIndex = button.ZIndex + 5
    ripple.Parent = button

    CreateCorner(ripple, UDim.new(1, 0))

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.5)

    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- ═══════════════════════════════════
--  CONFIG SYSTEM
-- ═══════════════════════════════════
local ConfigSystem = {}

function ConfigSystem:Save(name, data)
    if writefile then
        local success, err = pcall(function()
            writefile("AlchemyHub_" .. name .. ".json", HttpService:JSONEncode(data))
        end)
        return success
    end
    return false
end

function ConfigSystem:Load(name)
    if readfile and isfile then
        local fileName = "AlchemyHub_" .. name .. ".json"
        if isfile(fileName) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(fileName))
            end)
            if success then return data end
        end
    end
    return nil
end

-- ═══════════════════════════════════
--  KEY SYSTEM
-- ═══════════════════════════════════
local function CreateKeySystem(screenGui, key, callback)
    local keyFrame = Instance.new("Frame")
    keyFrame.Name = "KeySystem"
    keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    keyFrame.Size = UDim2.new(0, 350, 0, 200)
    keyFrame.BackgroundColor3 = Theme.Background
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = screenGui
    CreateCorner(keyFrame)
    CreateStroke(keyFrame, Theme.Accent, 2, 0.3)
    CreateShadow(keyFrame)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🔑 Alchemy Hub - Key System"
    title.TextColor3 = Theme.Accent
    title.Font = Theme.FontBold
    title.TextSize = 16
    title.Parent = keyFrame

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "KeyInput"
    inputBox.AnchorPoint = Vector2.new(0.5, 0)
    inputBox.Position = UDim2.new(0.5, 0, 0, 55)
    inputBox.Size = UDim2.new(0.85, 0, 0, 40)
    inputBox.BackgroundColor3 = Theme.ElementBackground
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = "Enter your key..."
    inputBox.PlaceholderColor3 = Theme.DimText
    inputBox.TextColor3 = Theme.Text
    inputBox.Font = Theme.Font
    inputBox.TextSize = 14
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = keyFrame
    CreateCorner(inputBox, Theme.SmallCorner)
    CreateStroke(inputBox, Theme.SectionBorder, 1, 0.6)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.AnchorPoint = Vector2.new(0.5, 0)
    statusLabel.Position = UDim2.new(0.5, 0, 0, 105)
    statusLabel.Size = UDim2.new(0.85, 0, 0, 20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Theme.SubText
    statusLabel.Font = Theme.Font
    statusLabel.TextSize = 12
    statusLabel.Parent = keyFrame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "Submit"
    submitBtn.AnchorPoint = Vector2.new(0.5, 0)
    submitBtn.Position = UDim2.new(0.5, 0, 0, 135)
    submitBtn.Size = UDim2.new(0.85, 0, 0, 40)
    submitBtn.BackgroundColor3 = Theme.Accent
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "Submit Key"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Theme.FontBold
    submitBtn.TextSize = 14
    submitBtn.AutoButtonColor = false
    submitBtn.Parent = keyFrame
    CreateCorner(submitBtn, Theme.SmallCorner)

    submitBtn.MouseEnter:Connect(function()
        Tween(submitBtn, {BackgroundColor3 = Theme.AccentGlow}, 0.2)
    end)
    submitBtn.MouseLeave:Connect(function()
        Tween(submitBtn, {BackgroundColor3 = Theme.Accent}, 0.2)
    end)

    submitBtn.MouseButton1Click:Connect(function()
        if inputBox.Text == key then
            statusLabel.Text = "✅ Key accepted!"
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            Tween(keyFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
            task.delay(0.4, function()
                keyFrame:Destroy()
                if callback then callback() end
            end)
        else
            statusLabel.Text = "❌ Invalid key. Try again."
            statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
            Tween(keyFrame, {Position = UDim2.new(0.5, 8, 0.5, 0)}, 0.05, Enum.EasingStyle.Linear)
            task.delay(0.05, function()
                Tween(keyFrame, {Position = UDim2.new(0.5, -8, 0.5, 0)}, 0.05, Enum.EasingStyle.Linear)
                task.delay(0.05, function()
                    Tween(keyFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.1)
                end)
            end)
        end
    end)

    return keyFrame
end

-- ═══════════════════════════════════
--  MAIN LIBRARY: CreateWindow
-- ═══════════════════════════════════
function AlchemyLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Alchemy Hub"
    local windowSize = config.Size or UDim2.new(0, 600, 0, 400)
    local keySystem = config.KeySystem or false
    local key = config.Key or ""

    local Window = {}
    Window._tabs = {}
    Window._activeTab = nil
    Window._configData = {}

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AlchemyHubUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end

    Window._screenGui = screenGui

    -- Build main UI function
    local function BuildMainUI()
        -- Main Frame
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainWindow"
        mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundColor3 = Theme.Background
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = true
        mainFrame.Parent = screenGui
        CreateCorner(mainFrame)
        CreateStroke(mainFrame, Theme.Accent, 1.5, 0.4)
        CreateShadow(mainFrame)
        Window._mainFrame = mainFrame

        -- Open animation
        Tween(mainFrame, {Size = windowSize}, 0.5, Enum.EasingStyle.Back)

        -- ═══ TOP BAR ═══
        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 36)
        topBar.BackgroundColor3 = Theme.TopBar
        topBar.BorderSizePixel = 0
        topBar.ZIndex = 10
        topBar.Parent = mainFrame
        CreateCorner(topBar)

        -- Fix bottom corners of topbar
        local topBarFix = Instance.new("Frame")
        topBarFix.Name = "TopBarFix"
        topBarFix.Size = UDim2.new(1, 0, 0, 12)
        topBarFix.Position = UDim2.new(0, 0, 1, -12)
        topBarFix.BackgroundColor3 = Theme.TopBar
        topBarFix.BorderSizePixel = 0
        topBarFix.ZIndex = 10
        topBarFix.Parent = topBar

        -- Accent line under topbar
        local accentLine = Instance.new("Frame")
        accentLine.Name = "AccentLine"
        accentLine.Size = UDim2.new(1, 0, 0, 2)
        accentLine.Position = UDim2.new(0, 0, 1, 0)
        accentLine.BackgroundColor3 = Theme.Accent
        accentLine.BorderSizePixel = 0
        accentLine.ZIndex = 11
        accentLine.Parent = topBar

        -- Glow gradient on accent line
        local lineGrad = Instance.new("UIGradient")
        lineGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.AccentDark),
            ColorSequenceKeypoint.new(0.5, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentDark)
        })
        lineGrad.Parent = accentLine

        -- Icon
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 30, 1, 0)
        iconLabel.Position = UDim2.new(0, 10, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = "⚗️"
        iconLabel.TextSize = 16
        iconLabel.Font = Theme.Font
        iconLabel.TextColor3 = Theme.Accent
        iconLabel.ZIndex = 11
        iconLabel.Parent = topBar

        -- Title Label
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -120, 1, 0)
        titleLabel.Position = UDim2.new(0, 40, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Theme.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = Theme.FontBold
        titleLabel.TextSize = 15
        titleLabel.ZIndex = 11
        titleLabel.Parent = topBar

        -- Close Button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "Close"
        closeBtn.Size = UDim2.new(0, 26, 0, 26)
        closeBtn.Position = UDim2.new(1, -35, 0.5, -13)
        closeBtn.BackgroundColor3 = Theme.CloseButton
        closeBtn.BackgroundTransparency = 0.6
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Theme.Text
        closeBtn.TextSize = 12
        closeBtn.Font = Theme.FontBold
        closeBtn.AutoButtonColor = false
        closeBtn.ZIndex = 12
        closeBtn.Parent = topBar
        CreateCorner(closeBtn, UDim.new(1, 0))

        closeBtn.MouseEnter:Connect(function()
            Tween(closeBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.CloseButton}, 0.2)
        end)
        closeBtn.MouseLeave:Connect(function()
            Tween(closeBtn, {BackgroundTransparency = 0.6}, 0.2)
        end)
        closeBtn.MouseButton1Click:Connect(function()
            Window:Destroy()
        end)

        -- Minimize Button
        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Name = "Minimize"
        minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
        minimizeBtn.Position = UDim2.new(1, -67, 0.5, -13)
        minimizeBtn.BackgroundColor3 = Theme.MinimizeButton
        minimizeBtn.BackgroundTransparency = 0.6
        minimizeBtn.BorderSizePixel = 0
        minimizeBtn.Text = "─"
        minimizeBtn.TextColor3 = Theme.Text
        minimizeBtn.TextSize = 12
        minimizeBtn.Font = Theme.FontBold
        minimizeBtn.AutoButtonColor = false
        minimizeBtn.ZIndex = 12
        minimizeBtn.Parent = topBar
        CreateCorner(minimizeBtn, UDim.new(1, 0))

        local minimized = false
        minimizeBtn.MouseEnter:Connect(function()
            Tween(minimizeBtn, {BackgroundTransparency = 0}, 0.2)
        end)
        minimizeBtn.MouseLeave:Connect(function()
            Tween(minimizeBtn, {BackgroundTransparency = 0.6}, 0.2)
        end)
        minimizeBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                Tween(mainFrame, {Size = UDim2.new(0, windowSize.X.Offset, 0, 36)}, 0.3, Enum.EasingStyle.Quart)
            else
                Tween(mainFrame, {Size = windowSize}, 0.3, Enum.EasingStyle.Quart)
            end
        end)

        -- ═══ DRAGGING ═══
        local dragging, dragInput, dragStart, startPos
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        topBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        -- ═══ SIDEBAR ═══
        local sidebar = Instance.new("Frame")
        sidebar.Name = "Sidebar"
        sidebar.Size = UDim2.new(0, 150, 1, -38)
        sidebar.Position = UDim2.new(0, 0, 0, 38)
        sidebar.BackgroundColor3 = Theme.Sidebar
        sidebar.BorderSizePixel = 0
        sidebar.ZIndex = 5
        sidebar.Parent = mainFrame

        -- Fix sidebar corners (only bottom-left should be rounded)
        local sidebarCornerFix = Instance.new("Frame")
        sidebarCornerFix.Size = UDim2.new(1, 0, 0, 10)
        sidebarCornerFix.BackgroundColor3 = Theme.Sidebar
        sidebarCornerFix.BorderSizePixel = 0
        sidebarCornerFix.ZIndex = 5
        sidebarCornerFix.Parent = sidebar

        local sidebarCornerFix2 = Instance.new("Frame")
        sidebarCornerFix2.Size = UDim2.new(0, 10, 1, 0)
        sidebarCornerFix2.Position = UDim2.new(1, -10, 0, 0)
        sidebarCornerFix2.BackgroundColor3 = Theme.Sidebar
        sidebarCornerFix2.BorderSizePixel = 0
        sidebarCornerFix2.ZIndex = 5
        sidebarCornerFix2.Parent = sidebar

        CreateCorner(sidebar, Theme.CornerRadius)

        -- Sidebar separator line
        local sidebarSep = Instance.new("Frame")
        sidebarSep.Name = "Separator"
        sidebarSep.Size = UDim2.new(0, 1, 1, 0)
        sidebarSep.Position = UDim2.new(1, 0, 0, 0)
        sidebarSep.BackgroundColor3 = Theme.SectionBorder
        sidebarSep.BackgroundTransparency = 0.5
        sidebarSep.BorderSizePixel = 0
        sidebarSep.ZIndex = 6
        sidebarSep.Parent = sidebar

        -- Tab buttons container
        local tabContainer = Instance.new("ScrollingFrame")
        tabContainer.Name = "TabContainer"
        tabContainer.Size = UDim2.new(1, -8, 1, -16)
        tabContainer.Position = UDim2.new(0, 4, 0, 8)
        tabContainer.BackgroundTransparency = 1
        tabContainer.BorderSizePixel = 0
        tabContainer.ScrollBarThickness = 2
        tabContainer.ScrollBarImageColor3 = Theme.Accent
        tabContainer.ZIndex = 6
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContainer.Parent = sidebar

        local tabListLayout = CreateListLayout(tabContainer, 4, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)

        -- ═══ CONTENT AREA ═══
        local contentArea = Instance.new("Frame")
        contentArea.Name = "ContentArea"
        contentArea.Size = UDim2.new(1, -152, 1, -40)
        contentArea.Position = UDim2.new(0, 152, 0, 40)
        contentArea.BackgroundTransparency = 1
        contentArea.BorderSizePixel = 0
        contentArea.ZIndex = 5
        contentArea.ClipsDescendants = true
        contentArea.Parent = mainFrame
        Window._contentArea = contentArea

        -- Store references
        Window._tabContainer = tabContainer

        -- ═══ MOBILE TOGGLE BUTTON ═══
        local mobileToggle = Instance.new("TextButton")
        mobileToggle.Name = "MobileToggle"
        mobileToggle.Size = UDim2.new(0, 46, 0, 46)
        mobileToggle.Position = UDim2.new(0, 10, 1, -60)
        mobileToggle.BackgroundColor3 = Theme.Accent
        mobileToggle.BorderSizePixel = 0
        mobileToggle.Text = "⚗️"
        mobileToggle.TextSize = 20
        mobileToggle.Font = Theme.FontBold
        mobileToggle.TextColor3 = Theme.Text
        mobileToggle.AutoButtonColor = false
        mobileToggle.Visible = false
        mobileToggle.ZIndex = 100
        mobileToggle.Parent = screenGui
        CreateCorner(mobileToggle, UDim.new(1, 0))
        CreateShadow(mobileToggle)

        local uiVisible = true
        mobileToggle.MouseButton1Click:Connect(function()
            uiVisible = not uiVisible
            mainFrame.Visible = uiVisible
        end)

        -- Detect mobile
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            mobileToggle.Visible = true
        end

        -- Toggle with keybind (RightControl)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Home then
                uiVisible = not uiVisible
                mainFrame.Visible = uiVisible
            end
        end)
    end

    -- ═══════════════════════════════════
    --  AddTab METHOD
    -- ═══════════════════════════════════
    function Window:AddTab(name, icon)
        local Tab = {}
        Tab._sections = {}
        Tab._name = name or "Tab"
        Tab._icon = icon or "📁"

        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. name
        tabButton.Size = UDim2.new(1, -8, 0, 36)
        tabButton.BackgroundColor3 = Theme.ElementBackground
        tabButton.BackgroundTransparency = 0.5
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.ZIndex = 7
        tabButton.Parent = Window._tabContainer
        CreateCorner(tabButton, Theme.SmallCorner)

        -- Tab icon
        local tabIcon = Instance.new("TextLabel")
        tabIcon.Name = "Icon"
        tabIcon.Size = UDim2.new(0, 24, 1, 0)
        tabIcon.Position = UDim2.new(0, 8, 0, 0)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = Tab._icon
        tabIcon.TextSize = 14
        tabIcon.Font = Theme.Font
        tabIcon.TextColor3 = Theme.SubText
        tabIcon.ZIndex = 8
        tabIcon.Parent = tabButton

        -- Tab label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.Size = UDim2.new(1, -40, 1, 0)
        tabLabel.Position = UDim2.new(0, 34, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = name
        tabLabel.TextColor3 = Theme.SubText
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Font = Theme.FontMedium
        tabLabel.TextSize = 13
        tabLabel.ZIndex = 8
        tabLabel.Parent = tabButton

        -- Active indicator
        local activeIndicator = Instance.new("Frame")
        activeIndicator.Name = "Indicator"
        activeIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        activeIndicator.Position = UDim2.new(0, 0, 0.2, 0)
        activeIndicator.BackgroundColor3 = Theme.Accent
        activeIndicator.BorderSizePixel = 0
        activeIndicator.BackgroundTransparency = 1
        activeIndicator.ZIndex = 9
        activeIndicator.Parent = tabButton
        CreateCorner(activeIndicator, UDim.new(0, 2))

        -- Content scroll frame for this tab
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "TabContent_" .. name
        tabContent.Size = UDim2.new(1, -8, 1, -8)
        tabContent.Position = UDim2.new(0, 4, 0, 4)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Theme.Accent
        tabContent.ScrollBarImageTransparency = 0.3
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.ZIndex = 6
        tabContent.Parent = Window._contentArea

        local contentLayout = CreateListLayout(tabContent, 10)
        CreatePadding(tabContent, 4, 4, 4, 4)

        Tab._button = tabButton
        Tab._content = tabContent
        Tab._indicator = activeIndicator
        Tab._label = tabLabel
        Tab._iconLabel = tabIcon

        -- Switch tabs
        local function ActivateTab()
            -- Deactivate all tabs
            for _, t in pairs(Window._tabs) do
                t._content.Visible = false
                Tween(t._button, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.ElementBackground}, 0.2)
                Tween(t._label, {TextColor3 = Theme.SubText}, 0.2)
                Tween(t._iconLabel, {TextColor3 = Theme.SubText}, 0.2)
                Tween(t._indicator, {BackgroundTransparency = 1}, 0.2)
            end
            -- Activate this tab
            tabContent.Visible = true
            Tween(tabButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.AccentDark}, 0.2)
            Tween(tabLabel, {TextColor3 = Theme.Text}, 0.2)
            Tween(tabIcon, {TextColor3 = Theme.Accent}, 0.2)
            Tween(activeIndicator, {BackgroundTransparency = 0}, 0.2)
            Window._activeTab = Tab
        end

        tabButton.MouseButton1Click:Connect(ActivateTab)

        tabButton.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(tabButton, {BackgroundTransparency = 0.2}, 0.15)
                Tween(tabLabel, {TextColor3 = Theme.Text}, 0.15)
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(tabButton, {BackgroundTransparency = 0.5}, 0.15)
                Tween(tabLabel, {TextColor3 = Theme.SubText}, 0.15)
            end
        end)

        -- ═══════════════════════════════════
        --  AddSection METHOD
        -- ═══════════════════════════════════
        function Tab:AddSection(sectionName)
            local Section = {}
            Section._elements = {}

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section_" .. (sectionName or "Section")
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.BackgroundColor3 = Theme.Section
            sectionFrame.BorderSizePixel = 0
            sectionFrame.ZIndex = 7
            sectionFrame.Parent = tabContent
            CreateCorner(sectionFrame, Theme.SmallCorner)
            CreateStroke(sectionFrame, Theme.SectionBorder, 1, 0.6)

            -- Section title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "SectionTitle"
            sectionTitle.Size = UDim2.new(1, -16, 0, 28)
            sectionTitle.Position = UDim2.new(0, 8, 0, 4)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = "⬥ " .. (sectionName or "Section")
            sectionTitle.TextColor3 = Theme.Accent
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Font = Theme.FontSemibold
            sectionTitle.TextSize = 13
            sectionTitle.ZIndex = 8
            sectionTitle.Parent = sectionFrame

            -- Section divider
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(1, -16, 0, 1)
            divider.Position = UDim2.new(0, 8, 0, 32)
            divider.BackgroundColor3 = Theme.SectionBorder
            divider.BackgroundTransparency = 0.5
            divider.BorderSizePixel = 0
            divider.ZIndex = 8
            divider.Parent = sectionFrame

            -- Elements container
            local elementsContainer = Instance.new("Frame")
            elementsContainer.Name = "Elements"
            elementsContainer.Size = UDim2.new(1, -16, 0, 0)
            elementsContainer.Position = UDim2.new(0, 8, 0, 38)
            elementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            elementsContainer.BackgroundTransparency = 1
            elementsContainer.ZIndex = 7
            elementsContainer.Parent = sectionFrame

            local elemLayout = CreateListLayout(elementsContainer, 6)
            Section._container = elementsContainer

            -- Auto resize section
            elemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(1, 0, 0, elemLayout.AbsoluteContentSize.Y + 48)
            end)

            -- ═══ AddButton ═══
            function Section:AddButton(label, callback)
                local btnFrame = Instance.new("TextButton")
                btnFrame.Name = "Button_" .. label
                btnFrame.Size = UDim2.new(1, 0, 0, 34)
                btnFrame.BackgroundColor3 = Theme.ElementBackground
                btnFrame.BorderSizePixel = 0
                btnFrame.Text = ""
                btnFrame.AutoButtonColor = false
                btnFrame.ZIndex = 8
                btnFrame.ClipsDescendants = true
                btnFrame.Parent = elementsContainer
                CreateCorner(btnFrame, Theme.SmallCorner)

                local btnLabel = Instance.new("TextLabel")
                btnLabel.Name = "Label"
                btnLabel.Size = UDim2.new(1, -16, 1, 0)
                btnLabel.Position = UDim2.new(0, 12, 0, 0)
                btnLabel.BackgroundTransparency = 1
                btnLabel.Text = "▸ " .. label
                btnLabel.TextColor3 = Theme.Text
                btnLabel.TextXAlignment = Enum.TextXAlignment.Left
                btnLabel.Font = Theme.FontMedium
                btnLabel.TextSize = 13
                btnLabel.ZIndex = 9
                btnLabel.Parent = btnFrame

                btnFrame.MouseEnter:Connect(function()
                    Tween(btnFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                btnFrame.MouseLeave:Connect(function()
                    Tween(btnFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                end)
                btnFrame.MouseButton1Click:Connect(function()
                    RippleEffect(btnFrame, Mouse.X, Mouse.Y)
                    -- Flash effect
                    Tween(btnFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                    task.delay(0.15, function()
                        Tween(btnFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.2)
                    end)
                    if callback then
                        pcall(callback)
                    end
                end)

                return btnFrame
            end

            -- ═══ AddToggle ═══
            function Section:AddToggle(label, default, callback)
                local toggled = default or false

                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle_" .. label
                toggleFrame.Size = UDim2.new(1, 0, 0, 34)
                toggleFrame.BackgroundColor3 = Theme.ElementBackground
                toggleFrame.BorderSizePixel = 0
                toggleFrame.ZIndex = 8
                toggleFrame.Parent = elementsContainer
                CreateCorner(toggleFrame, Theme.SmallCorner)

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.Size = UDim2.new(1, -70, 1, 0)
                toggleLabel.Position = UDim2.new(0, 12, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = label
                toggleLabel.TextColor3 = Theme.Text
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Font = Theme.FontMedium
                toggleLabel.TextSize = 13
                toggleLabel.ZIndex = 9
                toggleLabel.Parent = toggleFrame

                -- Toggle switch background
                local switchBG = Instance.new("Frame")
                switchBG.Name = "SwitchBG"
                switchBG.Size = UDim2.new(0, 44, 0, 22)
                switchBG.Position = UDim2.new(1, -56, 0.5, -11)
                switchBG.BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff
                switchBG.BorderSizePixel = 0
                switchBG.ZIndex = 9
                switchBG.Parent = toggleFrame
                CreateCorner(switchBG, UDim.new(1, 0))

                -- Toggle circle
                local switchCircle = Instance.new("Frame")
                switchCircle.Name = "Circle"
                switchCircle.Size = UDim2.new(0, 18, 0, 18)
                switchCircle.Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                switchCircle.BorderSizePixel = 0
                switchCircle.ZIndex = 10
                switchCircle.Parent = switchBG
                CreateCorner(switchCircle, UDim.new(1, 0))

                -- Status text
                local statusText = Instance.new("TextLabel")
                statusText.Name = "Status"
                statusText.Size = UDim2.new(1, 0, 1, 0)
                statusText.BackgroundTransparency = 1
                statusText.Text = toggled and "ON" or "OFF"
                statusText.TextColor3 = toggled and Theme.Accent or Theme.DimText
                statusText.Font = Theme.FontBold
                statusText.TextSize = 8
                statusText.ZIndex = 10
                statusText.Visible = false
                statusText.Parent = switchBG

                -- Click handling
                local toggleButton = Instance.new("TextButton")
                toggleButton.Name = "ClickArea"
                toggleButton.Size = UDim2.new(1, 0, 1, 0)
                toggleButton.BackgroundTransparency = 1
                toggleButton.Text = ""
                toggleButton.ZIndex = 11
                toggleButton.Parent = toggleFrame

                local function UpdateToggle()
                    if toggled then
                        Tween(switchBG, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
                        Tween(switchCircle, {Position = UDim2.new(1, -20, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
                        statusText.Text = "ON"
                        Tween(statusText, {TextColor3 = Theme.Accent}, 0.2)
                    else
                        Tween(switchBG, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
                        Tween(switchCircle, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
                        statusText.Text = "OFF"
                        Tween(statusText, {TextColor3 = Theme.DimText}, 0.2)
                    end
                end

                toggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    UpdateToggle()
                    if callback then
                        pcall(callback, toggled)
                    end
                end)

                toggleButton.MouseEnter:Connect(function()
                    Tween(toggleFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                toggleButton.MouseLeave:Connect(function()
                    Tween(toggleFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                end)

                local ToggleObj = {}
                function ToggleObj:Set(state)
                    toggled = state
                    UpdateToggle()
                    if callback then
                        pcall(callback, toggled)
                    end
                end
                function ToggleObj:Get()
                    return toggled
                end

                return ToggleObj
            end

            -- ═══ AddSlider ═══
            function Section:AddSlider(label, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = math.clamp(default or min, min, max)

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "Slider_" .. label
                sliderFrame.Size = UDim2.new(1, 0, 0, 50)
                sliderFrame.BackgroundColor3 = Theme.ElementBackground
                sliderFrame.BorderSizePixel = 0
                sliderFrame.ZIndex = 8
                sliderFrame.Parent = elementsContainer
                CreateCorner(sliderFrame, Theme.SmallCorner)

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.Size = UDim2.new(1, -60, 0, 20)
                sliderLabel.Position = UDim2.new(0, 12, 0, 4)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = label
                sliderLabel.TextColor3 = Theme.Text
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Font = Theme.FontMedium
                sliderLabel.TextSize = 13
                sliderLabel.ZIndex = 9
                sliderLabel.Parent = sliderFrame

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Name = "Value"
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(1, -58, 0, 4)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(default)
                valueLabel.TextColor3 = Theme.Accent
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Font = Theme.FontBold
                valueLabel.TextSize = 13
                valueLabel.ZIndex = 9
                valueLabel.Parent = sliderFrame

                -- Slider track
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.Size = UDim2.new(1, -24, 0, 6)
                sliderTrack.Position = UDim2.new(0, 12, 0, 32)
                sliderTrack.BackgroundColor3 = Theme.SliderBackground
                sliderTrack.BorderSizePixel = 0
                sliderTrack.ZIndex = 9
                sliderTrack.Parent = sliderFrame
                CreateCorner(sliderTrack, UDim.new(1, 0))

                -- Slider fill
                local fillPercent = (default - min) / (max - min)
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
                sliderFill.BackgroundColor3 = Theme.SliderFill
                sliderFill.BorderSizePixel = 0
                sliderFill.ZIndex = 10
                sliderFill.Parent = sliderTrack
                CreateCorner(sliderFill, UDim.new(1, 0))

                -- Glow on fill
                local fillGrad = Instance.new("UIGradient")
                fillGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.AccentDark),
                    ColorSequenceKeypoint.new(1, Theme.Accent)
                })
                fillGrad.Parent = sliderFill

                -- Slider knob
                local knob = Instance.new("Frame")
                knob.Name = "Knob"
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.ZIndex = 11
                knob.Parent = sliderTrack
                CreateCorner(knob, UDim.new(1, 0))

                -- Knob glow stroke
                CreateStroke(knob, Theme.Accent, 2, 0.3)

                local sliding = false

                local function UpdateSlider(input)
                    local trackPos = sliderTrack.AbsolutePosition.X
                    local trackSize = sliderTrack.AbsoluteSize.X
                    local relativeX = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)

                    local value = math.floor(min + (max - min) * relativeX + 0.5)
                    value = math.clamp(value, min, max)
                    local newPercent = (value - min) / (max - min)

                    Tween(sliderFill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.05)
                    Tween(knob, {Position = UDim2.new(newPercent, 0, 0.5, 0)}, 0.05)
                    valueLabel.Text = tostring(value)

                    if callback then
                        pcall(callback, value)
                    end
                end

                -- Slider interaction
                local sliderButton = Instance.new("TextButton")
                sliderButton.Name = "SliderClickArea"
                sliderButton.Size = UDim2.new(1, 0, 0, 20)
                sliderButton.Position = UDim2.new(0, 0, 0, 25)
                sliderButton.BackgroundTransparency = 1
                sliderButton.Text = ""
                sliderButton.ZIndex = 12
                sliderButton.Parent = sliderFrame

                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSlider(input)
                    end
                end)

                sliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                sliderFrame.MouseEnter:Connect(function()
                    Tween(sliderFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                sliderFrame.MouseLeave:Connect(function()
                    Tween(sliderFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                end)

                local SliderObj = {}
                function SliderObj:Set(value)
                    value = math.clamp(math.floor(value + 0.5), min, max)
                    local newPercent = (value - min) / (max - min)
                    Tween(sliderFill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.15)
                    Tween(knob, {Position = UDim2.new(newPercent, 0, 0.5, 0)}, 0.15)
                    valueLabel.Text = tostring(value)
                    if callback then pcall(callback, value) end
                end
                function SliderObj:Get()
                    return tonumber(valueLabel.Text) or default
                end

                return SliderObj
            end

            -- ═══ AddDropdown ═══
            function Section:AddDropdown(label, options, callback)
                options = options or {}
                local dropdownOpen = false
                local selectedValue = nil

                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "Dropdown_" .. label
                dropdownFrame.Size = UDim2.new(1, 0, 0, 34)
                dropdownFrame.BackgroundColor3 = Theme.ElementBackground
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ZIndex = 8
                dropdownFrame.ClipsDescendants = true
                dropdownFrame.Parent = elementsContainer
                CreateCorner(dropdownFrame, Theme.SmallCorner)

                local dropLabel = Instance.new("TextLabel")
                dropLabel.Name = "Label"
                dropLabel.Size = UDim2.new(0.5, -8, 0, 34)
                dropLabel.Position = UDim2.new(0, 12, 0, 0)
                dropLabel.BackgroundTransparency = 1
                dropLabel.Text = label
                dropLabel.TextColor3 = Theme.Text
                dropLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropLabel.Font = Theme.FontMedium
                dropLabel.TextSize = 13
                dropLabel.ZIndex = 9
                dropLabel.Parent = dropdownFrame

                -- Selected display
                local selectedDisplay = Instance.new("TextButton")
                selectedDisplay.Name = "Selected"
                selectedDisplay.Size = UDim2.new(0.5, -12, 0, 26)
                selectedDisplay.Position = UDim2.new(0.5, 0, 0, 4)
                selectedDisplay.BackgroundColor3 = Theme.DropdownBG
                selectedDisplay.BorderSizePixel = 0
                selectedDisplay.Text = "Select..."
                selectedDisplay.TextColor3 = Theme.SubText
                selectedDisplay.Font = Theme.FontMedium
                selectedDisplay.TextSize = 12
                selectedDisplay.AutoButtonColor = false
                selectedDisplay.ZIndex = 9
                selectedDisplay.Parent = dropdownFrame
                CreateCorner(selectedDisplay, Theme.TinyCorner)
                CreateStroke(selectedDisplay, Theme.SectionBorder, 1, 0.5)

                -- Arrow indicator
                local arrow = Instance.new("TextLabel")
                arrow.Name = "Arrow"
                arrow.Size = UDim2.new(0, 20, 0, 26)
                arrow.Position = UDim2.new(1, -22, 0, 4)
                arrow.BackgroundTransparency = 1
                arrow.Text = "▼"
                arrow.TextColor3 = Theme.DimText
                arrow.Font = Theme.Font
                arrow.TextSize = 10
                arrow.ZIndex = 10
                arrow.Parent = dropdownFrame

                -- Options container
                local optionsContainer = Instance.new("Frame")
                optionsContainer.Name = "Options"
                optionsContainer.Size = UDim2.new(1, -16, 0, 0)
                optionsContainer.Position = UDim2.new(0, 8, 0, 38)
                optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
                optionsContainer.BackgroundTransparency = 1
                optionsContainer.ZIndex = 9
                optionsContainer.Parent = dropdownFrame

                local optionsLayout = CreateListLayout(optionsContainer, 3)

                -- Build option buttons
                local function BuildOptions()
                    for _, child in pairs(optionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for i, option in pairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Name = "Option_" .. tostring(option)
                        optBtn.Size = UDim2.new(1, 0, 0, 28)
                        optBtn.BackgroundColor3 = Theme.DropdownBG
                        optBtn.BorderSizePixel = 0
                        optBtn.Text = tostring(option)
                        optBtn.TextColor3 = Theme.SubText
                        optBtn.Font = Theme.FontMedium
                        optBtn.TextSize = 12
                        optBtn.AutoButtonColor = false
                        optBtn.ZIndex = 10
                        optBtn.LayoutOrder = i
                        optBtn.Parent = optionsContainer
                        CreateCorner(optBtn, Theme.TinyCorner)

                        optBtn.MouseEnter:Connect(function()
                            Tween(optBtn, {BackgroundColor3 = Theme.AccentDark, TextColor3 = Theme.Text}, 0.15)
                        end)
                        optBtn.MouseLeave:Connect(function()
                            Tween(optBtn, {BackgroundColor3 = Theme.DropdownBG, TextColor3 = Theme.SubText}, 0.15)
                        end)
                        optBtn.MouseButton1Click:Connect(function()
                            selectedValue = option
                            selectedDisplay.Text = tostring(option)
                            Tween(selectedDisplay, {TextColor3 = Theme.Accent}, 0.2)
                            -- Close dropdown
                            dropdownOpen = false
                            arrow.Text = "▼"
                            local closedSize = UDim2.new(1, 0, 0, 34)
                            Tween(dropdownFrame, {Size = closedSize}, 0.25, Enum.EasingStyle.Quart)
                            if callback then
                                pcall(callback, option)
                            end
                        end)
                    end
                end
                BuildOptions()

                -- Toggle dropdown
                selectedDisplay.MouseButton1Click:Connect(function()
                    dropdownOpen = not dropdownOpen
                    if dropdownOpen then
                        arrow.Text = "▲"
                        local optionsHeight = #options * 31 + 8
                        Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 38 + optionsHeight)}, 0.25, Enum.EasingStyle.Quart)
                    else
                        arrow.Text = "▼"
                        Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 34)}, 0.25, Enum.EasingStyle.Quart)
                    end
                end)

                selectedDisplay.MouseEnter:Connect(function()
                    Tween(selectedDisplay, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                selectedDisplay.MouseLeave:Connect(function()
                    Tween(selectedDisplay, {BackgroundColor3 = Theme.DropdownBG}, 0.15)
                end)

                local DropdownObj = {}
                function DropdownObj:Set(value)
                    selectedValue = value
                    selectedDisplay.Text = tostring(value)
                    Tween(selectedDisplay, {TextColor3 = Theme.Accent}, 0.2)
                    if callback then pcall(callback, value) end
                end
                function DropdownObj:Get()
                    return selectedValue
                end
                function DropdownObj:Refresh(newOptions)
                    options = newOptions or {}
                    BuildOptions()
                end

                return DropdownObj
            end

            -- ═══ AddColorPicker ═══
            function Section:AddColorPicker(label, default, callback)
                default = default or Color3.fromRGB(130, 80, 255)
                local currentColor = default
                local pickerOpen = false

                local pickerFrame = Instance.new("Frame")
                pickerFrame.Name = "ColorPicker_" .. label
                pickerFrame.Size = UDim2.new(1, 0, 0, 34)
                pickerFrame.BackgroundColor3 = Theme.ElementBackground
                pickerFrame.BorderSizePixel = 0
                pickerFrame.ZIndex = 8
                pickerFrame.ClipsDescendants = true
                pickerFrame.Parent = elementsContainer
                CreateCorner(pickerFrame, Theme.SmallCorner)

                local pickerLabel = Instance.new("TextLabel")
                pickerLabel.Name = "Label"
                pickerLabel.Size = UDim2.new(1, -60, 0, 34)
                pickerLabel.Position = UDim2.new(0, 12, 0, 0)
                pickerLabel.BackgroundTransparency = 1
                pickerLabel.Text = label
                pickerLabel.TextColor3 = Theme.Text
                pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                pickerLabel.Font = Theme.FontMedium
                pickerLabel.TextSize = 13
                pickerLabel.ZIndex = 9
                pickerLabel.Parent = pickerFrame

                -- Color preview button
                local colorPreview = Instance.new("TextButton")
                colorPreview.Name = "Preview"
                colorPreview.Size = UDim2.new(0, 32, 0, 22)
                colorPreview.Position = UDim2.new(1, -44, 0, 6)
                colorPreview.BackgroundColor3 = currentColor
                colorPreview.BorderSizePixel = 0
                colorPreview.Text = ""
                colorPreview.AutoButtonColor = false
                colorPreview.ZIndex = 9
                colorPreview.Parent = pickerFrame
                CreateCorner(colorPreview, Theme.TinyCorner)
                CreateStroke(colorPreview, Color3.fromRGB(80, 80, 100), 1, 0.4)

                -- Color picker palette
                local paletteFrame = Instance.new("Frame")
                paletteFrame.Name = "Palette"
                paletteFrame.Size = UDim2.new(1, -16, 0, 120)
                paletteFrame.Position = UDim2.new(0, 8, 0, 40)
                paletteFrame.BackgroundColor3 = Theme.DropdownBG
                paletteFrame.BorderSizePixel = 0
                paletteFrame.ZIndex = 9
                paletteFrame.Parent = pickerFrame
                CreateCorner(paletteFrame, Theme.TinyCorner)

                -- Saturation/Value field
                local svField = Instance.new("ImageLabel")
                svField.Name = "SVField"
                svField.Size = UDim2.new(1, -40, 1, -8)
                svField.Position = UDim2.new(0, 4, 0, 4)
                svField.BackgroundColor3 = currentColor
                svField.BorderSizePixel = 0
                svField.ZIndex = 10
                svField.Image = ""
                svField.Parent = paletteFrame
                CreateCorner(svField, Theme.TinyCorner)

                -- White gradient overlay (saturation)
                local whiteGrad = Instance.new("UIGradient")
                whiteGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
                whiteGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                whiteGrad.Parent = svField

                -- Black gradient overlay (value) - use a separate frame
                local blackOverlay = Instance.new("Frame")
                blackOverlay.Name = "BlackOverlay"
                blackOverlay.Size = UDim2.new(1, 0, 1, 0)
                blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                blackOverlay.BorderSizePixel = 0
                blackOverlay.ZIndex = 11
                blackOverlay.Parent = svField
                CreateCorner(blackOverlay, Theme.TinyCorner)

                local blackGrad = Instance.new("UIGradient")
                blackGrad.Rotation = 90
                blackGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                blackGrad.Parent = blackOverlay

                -- SV cursor
                local svCursor = Instance.new("Frame")
                svCursor.Name = "Cursor"
                svCursor.Size = UDim2.new(0, 10, 0, 10)
                svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                svCursor.BorderSizePixel = 0
                svCursor.ZIndex = 13
                svCursor.Parent = svField
                CreateCorner(svCursor, UDim.new(1, 0))
                CreateStroke(svCursor, Color3.fromRGB(0, 0, 0), 2, 0)

                -- Hue bar
                local hueBar = Instance.new("Frame")
                hueBar.Name = "HueBar"
                hueBar.Size = UDim2.new(0, 24, 1, -8)
                hueBar.Position = UDim2.new(1, -30, 0, 4)
                hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueBar.BorderSizePixel = 0
                hueBar.ZIndex = 10
                hueBar.Parent = paletteFrame
                CreateCorner(hueBar, Theme.TinyCorner)

                local hueGrad = Instance.new("UIGradient")
                hueGrad.Rotation = 90
                hueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                })
                hueGrad.Parent = hueBar

                -- Hue cursor
                local hueCursor = Instance.new("Frame")
                hueCursor.Name = "HueCursor"
                hueCursor.Size = UDim2.new(1, 4, 0, 4)
                hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                hueCursor.Position = UDim2.new(0.5, 0, 0, 0)
                hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueCursor.BorderSizePixel = 0
                hueCursor.ZIndex = 12
                hueCursor.Parent = hueBar
                CreateCorner(hueCursor, UDim.new(0, 2))
                CreateStroke(hueCursor, Color3.fromRGB(0, 0, 0), 1, 0)

                local hue, sat, val = Color3.toHSV(currentColor)
                svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
                svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

                local svDragging = false
                local hueDragging = false

                local function UpdateColor()
                    currentColor = Color3.fromHSV(hue, sat, val)
                    colorPreview.BackgroundColor3 = currentColor
                    svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    if callback then pcall(callback, currentColor) end
                end

                -- SV field interaction button
                local svButton = Instance.new("TextButton")
                svButton.Size = UDim2.new(1, 0, 1, 0)
                svButton.BackgroundTransparency = 1
                svButton.Text = ""
                svButton.ZIndex = 14
                svButton.Parent = svField

                svButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = true
                    end
                end)
                svButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                    end
                end)

                -- Hue bar interaction button
                local hueButton = Instance.new("TextButton")
                hueButton.Size = UDim2.new(1, 0, 1, 0)
                hueButton.BackgroundTransparency = 1
                hueButton.Text = ""
                hueButton.ZIndex = 14
                hueButton.Parent = hueBar

                hueButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                    end
                end)
                hueButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if svDragging then
                            local relX = math.clamp((input.Position.X - svField.AbsolutePosition.X) / svField.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((input.Position.Y - svField.AbsolutePosition.Y) / svField.AbsoluteSize.Y, 0, 1)
                            sat = relX
                            val = 1 - relY
                            svCursor.Position = UDim2.new(relX, 0, relY, 0)
                            UpdateColor()
                        elseif hueDragging then
                            local relY = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                            hue = relY
                            hueCursor.Position = UDim2.new(0.5, 0, relY, 0)
                            UpdateColor()
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                        hueDragging = false
                    end
                end)

                -- Toggle picker
                colorPreview.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 170)}, 0.3, Enum.EasingStyle.Quart)
                    else
                        Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 34)}, 0.3, Enum.EasingStyle.Quart)
                    end
                end)

                pickerFrame.MouseEnter:Connect(function()
                    if not pickerOpen then
                        Tween(pickerFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                    end
                end)
                pickerFrame.MouseLeave:Connect(function()
                    if not pickerOpen then
                        Tween(pickerFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                    end
                end)

                local ColorPickerObj = {}
                function ColorPickerObj:Set(color)
                    currentColor = color
                    hue, sat, val = Color3.toHSV(color)
                    colorPreview.BackgroundColor3 = color
                    svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
                    svField.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    if callback then pcall(callback, color) end
                end
                function ColorPickerObj:Get()
                    return currentColor
                end

                return ColorPickerObj
            end

            -- ═══ AddTextbox ═══
            function Section:AddTextbox(label, placeholder, callback)
                local textboxFrame = Instance.new("Frame")
                textboxFrame.Name = "Textbox_" .. label
                textboxFrame.Size = UDim2.new(1, 0, 0, 34)
                textboxFrame.BackgroundColor3 = Theme.ElementBackground
                textboxFrame.BorderSizePixel = 0
                textboxFrame.ZIndex = 8
                textboxFrame.Parent = elementsContainer
                CreateCorner(textboxFrame, Theme.SmallCorner)

                local tbLabel = Instance.new("TextLabel")
                tbLabel.Name = "Label"
                tbLabel.Size = UDim2.new(0.4, -8, 1, 0)
                tbLabel.Position = UDim2.new(0, 12, 0, 0)
                tbLabel.BackgroundTransparency = 1
                tbLabel.Text = label
                tbLabel.TextColor3 = Theme.Text
                tbLabel.TextXAlignment = Enum.TextXAlignment.Left
                tbLabel.Font = Theme.FontMedium
                tbLabel.TextSize = 13
                tbLabel.ZIndex = 9
                tbLabel.Parent = textboxFrame

                local inputBox = Instance.new("TextBox")
                inputBox.Name = "Input"
                inputBox.Size = UDim2.new(0.55, -8, 0, 26)
                inputBox.Position = UDim2.new(0.42, 0, 0, 4)
                inputBox.BackgroundColor3 = Theme.DropdownBG
                inputBox.BorderSizePixel = 0
                inputBox.Text = ""
                inputBox.PlaceholderText = placeholder or "Type here..."
                inputBox.PlaceholderColor3 = Theme.DimText
                inputBox.TextColor3 = Theme.Text
                inputBox.Font = Theme.Font
                inputBox.TextSize = 12
                inputBox.ClearTextOnFocus = false
                inputBox.ZIndex = 9
                inputBox.Parent = textboxFrame
                CreateCorner(inputBox, Theme.TinyCorner)
                CreateStroke(inputBox, Theme.SectionBorder, 1, 0.6)

                inputBox.Focused:Connect(function()
                    Tween(inputBox, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                    CreateStroke(inputBox, Theme.Accent, 1, 0.3)
                end)
                inputBox.FocusLost:Connect(function(enterPressed)
                    Tween(inputBox, {BackgroundColor3 = Theme.DropdownBG}, 0.15)
                    if callback and enterPressed then
                        pcall(callback, inputBox.Text)
                    end
                end)

                local TextboxObj = {}
                function TextboxObj:Set(text)
                    inputBox.Text = text
                end
                function TextboxObj:Get()
                    return inputBox.Text
                end

                return TextboxObj
            end

            -- ═══ AddLabel ═══
            function Section:AddLabel(text)
                local labelFrame = Instance.new("TextLabel")
                labelFrame.Name = "Label"
                labelFrame.Size = UDim2.new(1, 0, 0, 22)
                labelFrame.BackgroundTransparency = 1
                labelFrame.Text = text
                labelFrame.TextColor3 = Theme.SubText
                labelFrame.Font = Theme.Font
                labelFrame.TextSize = 12
                labelFrame.TextXAlignment = Enum.TextXAlignment.Left
                labelFrame.ZIndex = 8
                labelFrame.Parent = elementsContainer

                local LabelObj = {}
                function LabelObj:Set(newText)
                    labelFrame.Text = newText
                end
                return LabelObj
            end

            -- ═══ AddKeybind ═══
            function Section:AddKeybind(label, default, callback)
                local currentKey = default or Enum.KeyCode.Unknown
                local listening = false

                local keybindFrame = Instance.new("Frame")
                keybindFrame.Name = "Keybind_" .. label
                keybindFrame.Size = UDim2.new(1, 0, 0, 34)
                keybindFrame.BackgroundColor3 = Theme.ElementBackground
                keybindFrame.BorderSizePixel = 0
                keybindFrame.ZIndex = 8
                keybindFrame.Parent = elementsContainer
                CreateCorner(keybindFrame, Theme.SmallCorner)

                local kbLabel = Instance.new("TextLabel")
                kbLabel.Name = "Label"
                kbLabel.Size = UDim2.new(1, -90, 1, 0)
                kbLabel.Position = UDim2.new(0, 12, 0, 0)
                kbLabel.BackgroundTransparency = 1
                kbLabel.Text = label
                kbLabel.TextColor3 = Theme.Text
                kbLabel.TextXAlignment = Enum.TextXAlignment.Left
                kbLabel.Font = Theme.FontMedium
                kbLabel.TextSize = 13
                kbLabel.ZIndex = 9
                kbLabel.Parent = keybindFrame

                local keyButton = Instance.new("TextButton")
                keyButton.Name = "KeyButton"
                keyButton.Size = UDim2.new(0, 70, 0, 24)
                keyButton.Position = UDim2.new(1, -80, 0.5, -12)
                keyButton.BackgroundColor3 = Theme.DropdownBG
                keyButton.BorderSizePixel = 0
                keyButton.Text = currentKey.Name or "None"
                keyButton.TextColor3 = Theme.Accent
                keyButton.Font = Theme.FontMedium
                keyButton.TextSize = 11
                keyButton.AutoButtonColor = false
                keyButton.ZIndex = 10
                keyButton.Parent = keybindFrame
                CreateCorner(keyButton, Theme.TinyCorner)
                CreateStroke(keyButton, Theme.SectionBorder, 1, 0.5)

                keyButton.MouseButton1Click:Connect(function()
                    listening = true
                    keyButton.Text = "..."
                    Tween(keyButton, {BackgroundColor3 = Theme.AccentDark}, 0.15)
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyButton.Text = input.KeyCode.Name
                            listening = false
                            Tween(keyButton, {BackgroundColor3 = Theme.DropdownBG}, 0.15)
                        end
                    elseif input.KeyCode == currentKey then
                        if callback then
                            pcall(callback, currentKey)
                        end
                    end
                end)

                keybindFrame.MouseEnter:Connect(function()
                    Tween(keybindFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                keybindFrame.MouseLeave:Connect(function()
                    Tween(keybindFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                end)

                local KeybindObj = {}
                function KeybindObj:Set(newKey)
                    currentKey = newKey
                    keyButton.Text = newKey.Name
                end
                function KeybindObj:Get()
                    return currentKey
                end

                return KeybindObj
            end

            table.insert(Tab._sections, Section)
            return Section
        end

        table.insert(Window._tabs, Tab)

        -- Auto-select first tab
        if #Window._tabs == 1 then
            task.defer(function()
                tabButton.MouseButton1Click:Fire()
            end)
        end

        return Tab
    end

    -- ═══════════════════════════════════
    --  WINDOW METHODS
    -- ═══════════════════════════════════
    function Window:Destroy()
        if Window._mainFrame then
            Tween(Window._mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.4, function()
                if screenGui then
                    screenGui:Destroy()
                end
            end)
        end
    end

    function Window:SetThemeAccent(color)
        Theme.Accent = color
        Theme.AccentGlow = color
    end

    function Window:Notify(title, message, duration)
        duration = duration or 4

        local notif = Instance.new("Frame")
        notif.Name = "Notification"
        notif.AnchorPoint = Vector2.new(1, 1)
        notif.Position = UDim2.new(1, 30, 1, -10)
        notif.Size = UDim2.new(0, 280, 0, 70)
        notif.BackgroundColor3 = Theme.Background
        notif.BorderSizePixel = 0
        notif.ZIndex = 100
        notif.Parent = screenGui
        CreateCorner(notif)
        CreateStroke(notif, Theme.Accent, 1, 0.4)
        CreateShadow(notif)

        local notifTitle = Instance.new("TextLabel")
        notifTitle.Size = UDim2.new(1, -16, 0, 24)
        notifTitle.Position = UDim2.new(0, 8, 0, 6)
        notifTitle.BackgroundTransparency = 1
        notifTitle.Text = "⚗️ " .. (title or "Alchemy Hub")
        notifTitle.TextColor3 = Theme.Accent
        notifTitle.Font = Theme.FontBold
        notifTitle.TextSize = 14
        notifTitle.TextXAlignment = Enum.TextXAlignment.Left
        notifTitle.ZIndex = 101
        notifTitle.Parent = notif

        local notifMsg = Instance.new("TextLabel")
        notifMsg.Size = UDim2.new(1, -16, 0, 30)
        notifMsg.Position = UDim2.new(0, 8, 0, 30)
        notifMsg.BackgroundTransparency = 1
        notifMsg.Text = message or ""
        notifMsg.TextColor3 = Theme.SubText
        notifMsg.Font = Theme.Font
        notifMsg.TextSize = 12
        notifMsg.TextXAlignment = Enum.TextXAlignment.Left
        notifMsg.TextWrapped = true
        notifMsg.ZIndex = 101
        notifMsg.Parent = notif

        -- Progress bar
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 2)
        progressBar.Position = UDim2.new(0, 0, 1, -2)
        progressBar.BackgroundColor3 = Theme.Accent
        progressBar.BorderSizePixel = 0
        progressBar.ZIndex = 101
        progressBar.Parent = notif

        -- Slide in
        Tween(notif, {Position = UDim2.new(1, -15, 1, -10)}, 0.4, Enum.EasingStyle.Quart)

        -- Progress bar shrink
        Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration)

        -- Slide out and destroy
        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1, 30, 1, -10)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.45, function()
                notif:Destroy()
            end)
        end)
    end

    function Window:SaveConfig(name)
        return ConfigSystem:Save(name, Window._configData)
    end

    function Window:LoadConfig(name)
        local data = ConfigSystem:Load(name)
        if data then
            Window._configData = data
        end
        return data
    end

    -- ═══ BUILD UI ═══
    if keySystem and key ~= "" then
        CreateKeySystem(screenGui, key, function()
            BuildMainUI()
            -- Welcome notification
            task.delay(0.6, function()
                Window:Notify("Welcome", "Alchemy Hub loaded successfully!", 3)
            end)
        end)
    else
        BuildMainUI()
        -- Welcome notification
        task.delay(0.6, function()
            Window:Notify("Welcome", "Alchemy Hub loaded successfully!", 3)
        end)
    end

    return Window
end

return AlchemyLib