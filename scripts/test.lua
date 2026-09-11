local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- UI LIBRARY
local UILibrary = {}
local theme = {
    Background = Color3.fromRGB(15, 15, 25), Sidebar = Color3.fromRGB(20, 18, 35),
    Header = Color3.fromRGB(25, 20, 40), Panel = Color3.fromRGB(28, 25, 45),
    Accent = Color3.fromRGB(138, 100, 255), AccentHover = Color3.fromRGB(158, 120, 255),
    ButtonBg = Color3.fromRGB(35, 30, 55), ButtonHover = Color3.fromRGB(45, 40, 65), 
    Text = Color3.fromRGB(230, 230, 240), TextDim = Color3.fromRGB(150, 150, 170),
    Font = Enum.Font.GothamMedium, TitleFont = Enum.Font.GothamBold,
    Error = Color3.fromRGB(255, 75, 75), Warning = Color3.fromRGB(255, 170, 0), Success = Color3.fromRGB(75, 255, 125)
}

local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function roundify(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
    return corner
end

function UILibrary:CreateWindow(titleText)
    local Window = {}
    
    local ScreenGui = create("ScreenGui", {Name = "RLoaderUpdateGui", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    pcall(function()
        local syn = syn or {}
        local protect = syn.protect_gui or gethui
        if protect then ScreenGui.Parent = protect() else ScreenGui.Parent = CoreGui end
    end)
    Window.ScreenGui = ScreenGui
    
    local MainFrame = create("Frame", {Size = UDim2.new(0, 500, 0, 400), Position = UDim2.new(0.5, -250, 0.5, -200), BackgroundColor3 = theme.Background, BorderSizePixel = 0, Parent = ScreenGui, ClipsDescendants = true})
    roundify(MainFrame, 8)
    
    local Header = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = theme.Header, BorderSizePixel = 0, Parent = MainFrame})
    local Title = create("TextLabel", {Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = titleText, TextColor3 = theme.Accent, Font = theme.TitleFont, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
    
    local ContentContainer = create("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -50), Position = UDim2.new(0, 10, 0, 45), BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = theme.Accent, Parent = MainFrame})
    local UIListLayout = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = ContentContainer})
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    Window.Container = ContentContainer
    
    function Window:Notify(title, text)
        local notif = create("Frame", {Size = UDim2.new(0, 250, 0, 80), Position = UDim2.new(1, 10, 1, -90), BackgroundColor3 = theme.Panel, Parent = ScreenGui})
        roundify(notif, 6)
        create("TextLabel", {Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = title, TextColor3 = theme.Accent, Font = theme.TitleFont, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = notif})
        create("TextLabel", {Size = UDim2.new(1, -20, 1, -30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, Text = text, TextColor3 = theme.Text, Font = theme.Font, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = notif})
        
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -90)}):Play()
        task.delay(3.5, function()
            TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -90)}):Play()
            task.wait(0.5)
            notif:Destroy()
        end)
    end

    function Window:Label(text, color)
        local lbl = create("TextLabel", {Size = UDim2.new(1, -10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = color or theme.Text, Font = theme.Font, TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Window.Container})
        -- Need a small wait so TextBounds calculation works properly
        task.spawn(function()
            task.wait(0.1)
            if lbl and lbl.Parent then
                lbl.Size = UDim2.new(1, -10, 0, lbl.TextBounds.Y + 10)
            end
        end)
        return lbl
    end

    function Window:Button(text, callback)
        local btn = create("TextButton", {Size = UDim2.new(1, -10, 0, 35), BackgroundColor3 = theme.ButtonBg, Text = text, TextColor3 = theme.Text, Font = theme.Font, TextSize = 14, AutoButtonColor = false, Parent = Window.Container})
        roundify(btn, 6)
        
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.ButtonHover}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.ButtonBg}):Play() end)
        btn.MouseButton1Click:Connect(function() 
            pcall(callback) 
        end)
    end
    
    return Window
end

-- // CREATE UI // -----------------------------------------------------------------------------
local Window = UILibrary:CreateWindow("R-Loader | Compatibility Check")

Window:Label("Checking Roblox version compatibility...", Color3.fromRGB(150, 150, 170))

task.wait(2.5)

-- Clear existing labels
for _, child in pairs(Window.Container:GetChildren()) do
    if child:IsA("TextLabel") then child:Destroy() end
end

Window:Label("ERROR: Executor Update Required", Color3.fromRGB(255, 75, 75))
Window:Label("Your current executor is outdated and cannot run this script. New Roblox features require an updated executor.")
Window:Label("Download one of the trusted executors below to continue using scripts:", Color3.fromRGB(255, 170, 0))

local function CopyLink(name, url)
    local copied = false
    pcall(function()
        if setclipboard then setclipboard(url); copied = true
        elseif toclipboard then toclipboard(url); copied = true
        end
    end)
    if copied then
        Window:Notify("Success", "Copied link for " .. name .. "!")
    else
        Window:Notify("Error", "Failed to copy link.")
    end
end

Window:Button("Copy Link: Volt Executor (Recommended)", function() CopyLink("Volt", "https://volt-executor.cc") end)
Window:Button("Copy Link: Wave Executor", function() CopyLink("Wave", "https://wave-executor.xyz") end)
Window:Button("Copy Link: Xeno Executor", function() CopyLink("Xeno", "https://xeno-executor.online") end)

Window:Notify("System", "Compatibility check failed. Please update your executor.")
