local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- ======================================================
-- Settings
-- ======================================================
local TELEPORT_DELAY = 5   -- seconds between teleports
local HATCH_DELAY = 0.1    -- seconds between each "T" press
local BUBBLE_DELAY = 1     -- seconds between each BlowBubble remote call

local positions = {
    -- Position 1
    CFrame.new(
        6827.57471, 505.156311, -4148.0835,
        0.487276375, -0.000857754843, -0.873247385,
        0.000333274278, 0.999999642, -0.000796289532,
        0.873247743, 9.69821995e-05, 0.487276495
    ) * CFrame.new(0, 0, -10),

    -- Position 2
    CFrame.new(
        6986.02295, 523.935791, -3995.64917,
        0.985097051, -7.45148936e-05, -0.171999574,
        -7.45148936e-05, 0.999999642, -0.000859997934,
        0.171999574, 0.000859997934, 0.985096633
    ) * CFrame.new(0, 0, -10),

    -- Position 3
    CFrame.new(
        6881.62207, 505.223114, -4207.12842,
        -0.93718636, 0.000895450241, 0.348827779,
        0.000803662813, 0.999999583, -0.000407846004,
        -0.348828018, -0.000101887839, -0.937186718
    ) * CFrame.new(0, 0, -10),

    -- Position 4
    CFrame.new(
        6881.84619, 523.646912, -3892.00366,
        0.452076316, 0.000859517837, 0.89197886,
        -0.00031733248, 0.999999642, -0.000802775729,
        -0.891979218, 7.98619876e-05, 0.452076435
    ) * CFrame.new(0, 0, -10),

    -- Position 5
    CFrame.new(
        7002.62305, 523.587952, -4055.22656,
        -0.901145458, 0.000899190549, 0.433516592,
        0.000784042641, 0.999999583, -0.000444398145,
        -0.43351683, -6.05717796e-05, -0.901145816
    ) * CFrame.new(0, 0, -10),

    -- Position 6
    CFrame.new(
        7020.41699, 523.503052, -4017.52905,
        0.258864164, 0.000847230898, 0.965913415,
        -0.000111560221, 0.999999642, -0.000847230898,
        -0.965913773, 0.000111560221, 0.258864164
    ) * CFrame.new(0, 0, -10),

    -- Position 7
    CFrame.new(
        7014.84863, 512.512939, -4196.08301,
        0.971019208, 0.000350602815, 0.239001304,
        -0.000163562974, 0.999999642, -0.000802422001,
        -0.239001513, 0.000740075426, 0.97101891
    ) * CFrame.new(0, 0, -10),

    -- Position 8
    CFrame.new(
        7037.37939, 512.511169, -4230.24902,
        -0.171847701, 0.000830302946, 0.985123098,
        -0.000169545441, 0.999999583, -0.000872417353,
        -0.985123456, -0.00031694604, -0.171847463
    ) * CFrame.new(0, 0, -10),

    -- Position 9
    CFrame.new(
        6822.06104, 523.64856, -3911.67969,
        -0.208646178, -0.000849829346, -0.977990866,
        -8.96432903e-05, 0.999999642, -0.000849829346,
        0.977991223, -8.96432903e-05, -0.208646178
    ) * CFrame.new(0, 0, -10),

    -- Position 10
    CFrame.new(
        6842.96924, 523.647156, -3876.49658,
        0.961369991, -0.000119969016, -0.275259435,
        -0.000119969016, 0.999999642, -0.000854843063,
        0.275259435, 0.000854843063, 0.961369634
    ) * CFrame.new(0, 0, -10),

    -- Position 11
    CFrame.new(
        7006.47461, 512.181335, -4257.64258,
        -0.999101877, -0.000154311841, 0.0423746593,
        -0.000190898645, 0.999999583, -0.000859367487,
        -0.0423745103, -0.000866684888, -0.99910152
    ) * CFrame.new(0, 0, -10)
}

-- ======================================================
-- State
-- ======================================================
local alive = true
local teleportEnabled = false
local autoHatchEnabled = false
local autoBubbleEnabled = false
local antiAfkEnabled = false
local index = 1

local antiAfkCon = nil
local disabledCons = {}

-- ======================================================
-- Helpers
-- ======================================================
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

-- ======================================================
-- Anti AFK
-- ======================================================
local function setAntiAfk(state)
    if state then
        -- Pause any existing idle connections (Roblox's own kick handler)
        if getconnections then
            local ok, cons = pcall(getconnections, player.Idled)
            if ok and cons then
                for _, c in ipairs(cons) do
                    pcall(function() c:Disable() end)
                    table.insert(disabledCons, c)
                end
            end
        end

        pcall(function()
            if antiAfkCon then antiAfkCon:Disconnect() end
        end)

        antiAfkCon = player.Idled:Connect(function()
            local VirtualInputManager = Instance.new("VirtualInputManager")
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            VirtualInputManager:Destroy()
        end)

        notify("Anti AFK", "Anti AFK is enabled")
    else
        pcall(function()
            if antiAfkCon then antiAfkCon:Disconnect() end
        end)
        antiAfkCon = nil

        -- Give Roblox's original idle handlers back
        for _, c in ipairs(disabledCons) do
            pcall(function() c:Enable() end)
        end
        disabledCons = {}

        notify("Anti AFK", "Anti AFK is disabled")
    end
end

-- ======================================================
-- GUI
-- ======================================================
local COLORS = {
    bg1 = Color3.fromRGB(28, 28, 42),
    bg2 = Color3.fromRGB(16, 16, 24),
    row = Color3.fromRGB(36, 36, 54),
    side = Color3.fromRGB(20, 20, 30),
    accent = Color3.fromRGB(140, 100, 255),
    on = Color3.fromRGB(70, 210, 130),
    off = Color3.fromRGB(70, 70, 90),
    text = Color3.fromRGB(240, 240, 250),
    subtext = Color3.fromRGB(150, 150, 175),
    close = Color3.fromRGB(235, 80, 90),
}

local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmHubGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local FULL_SIZE = UDim2.new(0, 460, 0, 280)
local MINI_SIZE = UDim2.new(0, 460, 0, 38)

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = FULL_SIZE
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = COLORS.bg1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new(COLORS.bg1, COLORS.bg2)
frameGradient.Rotation = 90
frameGradient.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = COLORS.accent
frameStroke.Thickness = 1.5
frameStroke.Transparency = 0.35
frameStroke.Parent = frame

-- Title bar (drag handle)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = COLORS.accent
titleBar.BackgroundTransparency = 0.82
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Auto Farm Hub"
title.TextColor3 = COLORS.text
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local function makeTitleButton(text, xOffset, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 24, 0, 24)
    b.Position = UDim2.new(1, xOffset, 0.5, -12)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.25
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = true
    b.Parent = titleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local minimizeBtn = makeTitleButton("–", -62, COLORS.off)
local closeBtn = makeTitleButton("×", -32, COLORS.close)

-- Body (sidebar + pages)
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -38)
body.Position = UDim2.new(0, 0, 0, 38)
body.BackgroundTransparency = 1
body.Parent = frame

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.BackgroundColor3 = COLORS.side
sidebar.BackgroundTransparency = 0.3
sidebar.BorderSizePixel = 0
sidebar.Parent = body

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 6)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 10)
sidebarPadding.PaddingLeft = UDim.new(0, 10)
sidebarPadding.PaddingRight = UDim.new(0, 10)
sidebarPadding.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -120, 1, 0)
content.Position = UDim2.new(0, 120, 0, 0)
content.BackgroundTransparency = 1
content.Parent = body

-- Tabs
local tabs = {}

local function selectTab(name)
    for tabName, tab in pairs(tabs) do
        local active = (tabName == name)
        tab.page.Visible = active
        TweenService:Create(tab.button, TWEEN_INFO, {
            BackgroundColor3 = active and COLORS.accent or COLORS.row,
            BackgroundTransparency = active and 0.1 or 0.4,
        }):Play()
        tab.button.TextColor3 = active and Color3.new(1, 1, 1) or COLORS.subtext
    end
end

local function createTab(name, icon, order)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 34)
    button.LayoutOrder = order
    button.BackgroundColor3 = COLORS.row
    button.BackgroundTransparency = 0.4
    button.Text = icon .. "  " .. name
    button.TextColor3 = COLORS.subtext
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = sidebar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    tabs[name] = { button = button, page = page }
    button.MouseButton1Click:Connect(function()
        selectTab(name)
    end)

    return page
end

local eventPage = createTab("Event", "🎯", 1)
local autofarmPage = createTab("Autofarm", "🔁", 2)
local eggPage = createTab("Egg", "🥚", 3)
local miscPage = createTab("Misc", "⚙️", 4)

-- Builds one row: label + subtitle + animated switch.
local function createToggleRow(parent, yPos, labelText, subText, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 56)
    row.Position = UDim2.new(0, 12, 0, yPos)
    row.BackgroundColor3 = COLORS.row
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -80, 0, 18)
    sub.Position = UDim2.new(0, 12, 0, 29)
    sub.BackgroundTransparency = 1
    sub.Text = subText
    sub.TextColor3 = COLORS.subtext
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 52, 0, 28)
    switch.Position = UDim2.new(1, -64, 0.5, -14)
    switch.BackgroundColor3 = COLORS.off
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = row
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 3, 0.5, -11)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function setVisual(state)
        TweenService:Create(switch, TWEEN_INFO, {
            BackgroundColor3 = state and COLORS.on or COLORS.off,
        }):Play()
        TweenService:Create(knob, TWEEN_INFO, {
            Position = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
        }):Play()
    end

    local state = false
    switch.MouseButton1Click:Connect(function()
        state = not state
        setVisual(state)
        onToggle(state)
    end)

    local function setSub(text)
        sub.Text = text
    end

    return setVisual, setSub
end

-- Event tab: Auto Teleport
createToggleRow(eventPage, 12, "Auto Teleport", "Teleports to all halloween houses", function(state)
    teleportEnabled = state
end)

-- Autofarm tab: Auto Blow Bubble
createToggleRow(autofarmPage, 12, "Auto Blow Bubble", "Blows a bubble every second", function(state)
    autoBubbleEnabled = state
end)

-- Egg tab: Auto Hatch
createToggleRow(eggPage, 12, "Auto Hatch", "Must be near a egg", function(state)
    autoHatchEnabled = state
end)

-- Misc tab: Anti AFK
local _, setAfkSub = createToggleRow(miscPage, 12, "Anti AFK", "Idle kick protection: Off", function(state)
    antiAfkEnabled = state
    setAntiAfk(state)
    setAfkSub(state and "Idle kick protection: On" or "Idle kick protection: Off")
end)

selectTab("Event")

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minimizeBtn.Text = minimized and "+" or "–"
    TweenService:Create(frame, TWEEN_INFO, {
        Size = minimized and MINI_SIZE or FULL_SIZE,
    }):Play()
end)

-- Dragging (mouse + touch)
do
    local dragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Close: stop everything and clean up
closeBtn.MouseButton1Click:Connect(function()
    alive = false
    teleportEnabled = false
    autoHatchEnabled = false
    autoBubbleEnabled = false
    if antiAfkEnabled then
        antiAfkEnabled = false
        setAntiAfk(false)
    end
    screenGui:Destroy()
end)

-- ======================================================
-- Teleport loop
-- ======================================================
task.spawn(function()
    local elapsed = 0
    while alive do
        elapsed += task.wait(0.1)

        if elapsed >= TELEPORT_DELAY then
            elapsed = 0

            if teleportEnabled then
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")

                if teleportEnabled and alive then
                    root.CFrame = positions[index]
                    index = (index % #positions) + 1
                end
            end
        end
    end
end)

-- ======================================================
-- Auto Hatch loop (spams the T key)
-- ======================================================
task.spawn(function()
    local vim
    pcall(function()
        vim = game:GetService("VirtualInputManager")
    end)
    if not vim then
        vim = Instance.new("VirtualInputManager")
    end

    while alive do
        if autoHatchEnabled then
            pcall(function()
                vim:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                task.wait(0.02)
                vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
            end)
            task.wait(HATCH_DELAY)
        else
            task.wait(0.2)
        end
    end
end)

-- ======================================================
-- Auto Blow Bubble loop (spams the remote event)
-- ======================================================
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    while alive do
        if autoBubbleEnabled then
            local Event = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent")
            if Event then
                pcall(function()
                    Event:FireServer("BlowBubble")
                end)
            end
            task.wait(BUBBLE_DELAY)
        else
            task.wait(0.2)
        end
    end
end)
