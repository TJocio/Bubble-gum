local Players = game:GetService("Players")
local player = Players.LocalPlayer

local enabled = false -- starts OFF, use the button (set to true to start ON)

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

local index = 1

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0, 20, 0.5, -45)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Auto Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 40)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = frame
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

local function updateButton()
    if enabled then
        button.Text = "ON"
        button.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
    else
        button.Text = "OFF"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end
updateButton()

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateButton()
end)

-- Teleport loop (checks the toggle every 0.1s so OFF reacts quickly)
task.spawn(function()
    local elapsed = 0
    while true do
        elapsed += task.wait(0.1)

        if elapsed >= 2 then
            if enabled then
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")

                if enabled then
                    root.CFrame = positions[index]
                    index = (index % #positions) + 1
                end
            end
            elapsed = 0
        end
    end
end)
