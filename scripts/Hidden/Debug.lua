local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local uiName = "RLoader_DebugUI"

-- Clean up previous instance if running multiple times
local gethui = gethui or function() return CoreGui end
local targetGui = gethui()
if targetGui:FindFirstChild(uiName) then
    targetGui[uiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = targetGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 6)
TopBarCorner.Parent = TopBar

-- Hide bottom corners of topbar to make it seamless
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 6)
TopBarFix.Position = UDim2.new(0, 0, 1, -6)
TopBarFix.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Debug Menu"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local GetGameIdBtn = Instance.new("TextButton")
GetGameIdBtn.Size = UDim2.new(1, -20, 0, 30)
GetGameIdBtn.Position = UDim2.new(0, 10, 0, 45)
GetGameIdBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
GetGameIdBtn.Text = "Get Game ID"
GetGameIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetGameIdBtn.TextSize = 12
GetGameIdBtn.Font = Enum.Font.GothamSemibold
GetGameIdBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 4)
BtnCorner.Parent = GetGameIdBtn

-- // Functionality //

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

GetGameIdBtn.MouseButton1Click:Connect(function()
    local gameId = tostring(game.GameId)
    print("Game ID: " .. gameId)
    if setclipboard then
        setclipboard(gameId)
    end
    GetGameIdBtn.Text = "Copied: " .. gameId
    task.delay(1.5, function()
        if GetGameIdBtn and GetGameIdBtn.Parent then
            GetGameIdBtn.Text = "Get Game ID"
        end
    end)
end)

-- // Dragging Logic //

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
        startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
