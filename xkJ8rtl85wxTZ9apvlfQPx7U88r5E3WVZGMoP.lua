
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer



local Config = {
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Smoothness = 5,
        FOV = 300,
        TargetPart = "Head",
        Whitelist = {}
    },
    ESP = {
        Enabled = false,
        Fill = {R=175, G=25, B=25}, -- Saved as table for JSON compat
        Outline = {R=255, G=255, B=255},
        ShowNames = true
    },
    Movement = {
        PhaseDist = 10,
        SavedCFrame = nil, -- Not saved to file
        IntervalSpeed = 0.05,
        FlySpeed = 50
    },
    Binds = {
        ToggleUI = Enum.KeyCode.RightControl,
        Phase = Enum.KeyCode.F,
        SavePos = Enum.KeyCode.H,
        Teleport = Enum.KeyCode.J,
        Fly = Enum.KeyCode.V,
        Noclip = Enum.KeyCode.B
    },
    Toggles = {
        Fly = false,
        Noclip = false
    }
}

-- CONFIG SYSTEM
local FolderName = "R-Loader_Config"
local FileName = "Settings.json"

local function SaveConfig()
    if not makefolder then return end -- Check for executor support
    if not isfolder(FolderName) then makefolder(FolderName) end
    
    local Data = HttpService:JSONEncode(Config)
    writefile(FolderName .. "/" .. FileName, Data)
end

local function LoadConfig()
    if not isfile then return end
    if isfile(FolderName .. "/" .. FileName) then
        local content = readfile(FolderName .. "/" .. FileName)
        local decoded = HttpService:JSONDecode(content)
        
        -- Safely load essential settings (ignoring complex userdatas for simplicity)
        if decoded.Aimbot then 
            Config.Aimbot.Enabled = decoded.Aimbot.Enabled 
            Config.Aimbot.Smoothness = decoded.Aimbot.Smoothness
            Config.Aimbot.FOV = decoded.Aimbot.FOV
        end
        if decoded.Movement then
            Config.Movement.PhaseDist = decoded.Movement.PhaseDist
            Config.Movement.IntervalSpeed = decoded.Movement.IntervalSpeed
            Config.Movement.FlySpeed = decoded.Movement.FlySpeed
        end
    end
end

-- Auto Save Loop
task.spawn(function()
    while true do
        task.wait(10)
        SaveConfig()
    end
end)

-- Safe MouseMove
local mousemoverel = mousemoverel or (Input and Input.MouseMove) or function() end

--------------------------------------------------------------------------------
-- UI LIBRARY
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R-Loader_UI"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() elseif CoreGui:FindFirstChild("RobloxGui") then ScreenGui.Parent = CoreGui else ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TabContainer = Instance.new("Frame")
local Content = Instance.new("Frame")

-- Colors
local Colors = {
    Bg = Color3.fromRGB(20, 20, 25),
    DarkBg = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(0, 150, 255), -- Rebranded Green Accent
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150)
}

-- Main Frame
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Colors.Bg
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = MainFrame

-- Top Bar
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Colors.DarkBg
TopBar.Size = UDim2.new(1, 0, 0, 40)
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 8); tc.Parent = TopBar
local fix = Instance.new("Frame"); fix.Parent = TopBar; fix.BackgroundColor3 = Colors.DarkBg; fix.BorderSizePixel = 0; fix.Size = UDim2.new(1,0,0,10); fix.Position = UDim2.new(0,0,1,-10)

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "R-loader | ERLC/Universal"
Title.TextColor3 = Colors.Accent
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Notification System
local function Notify(msg, duration)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = ScreenGui
    lbl.BackgroundColor3 = Colors.DarkBg
    lbl.TextColor3 = Colors.Text
    lbl.Text = "  " .. msg .. "  "
    lbl.Size = UDim2.new(0, 0, 0, 0)
    lbl.Position = UDim2.new(1, -20, 1, -50)
    lbl.AnchorPoint = Vector2.new(1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.ClipsDescendants = true
    
    local c = Instance.new("UICorner"); c.Parent = lbl
    local s = Instance.new("UIStroke"); s.Parent = lbl; s.Color = Colors.Accent; s.Thickness = 1
    
    TweenService:Create(lbl, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 40)}):Play()
    task.wait(duration or 2)
    TweenService:Create(lbl, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.3)
    lbl:Destroy()
end

-- Close/Mini Buttons
local function CreateWinBtn(text, offset, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = TopBar
    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(1, offset, 0, 0)
    btn.Size = UDim2.new(0, 40, 1, 0)
    btn.Text = text
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
end

CreateWinBtn("X", -40, function() SaveConfig(); ScreenGui:Destroy() end)
CreateWinBtn("-", -80, function() 
    MainFrame.Visible = false 
    Notify("Press Right Ctrl to Open")
end)

-- Tabs Area
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.Size = UDim2.new(0, 120, 1, -40)
local TabList = Instance.new("UIListLayout"); TabList.Parent = TabContainer; TabList.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Area
Content.Parent = MainFrame
Content.BackgroundColor3 = Colors.DarkBg
Content.Position = UDim2.new(0, 120, 0, 40)
Content.Size = UDim2.new(1, -120, 1, -40)
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 0); cc.Parent = Content

-- Helper: Create Tab
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.BackgroundColor3 = Colors.Bg
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = Colors.SubText
    btn.TextSize = 13
    
    local page = Instance.new("ScrollingFrame")
    page.Parent = Content
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.BorderSizePixel = 0
    local pl = Instance.new("UIListLayout"); pl.Parent = page; pl.Padding = UDim.new(0, 8); pl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pp = Instance.new("UIPadding"); pp.Parent = page; pp.PaddingTop = UDim.new(0, 15)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        for _,v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Colors.SubText; v.BackgroundColor3 = Colors.Bg end end
        page.Visible = true
        btn.TextColor3 = Colors.Accent
        btn.BackgroundColor3 = Colors.DarkBg
    end)
    return page, btn
end

-- UI Component Helpers
local function CreateLabel(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = page
    lbl.Size = UDim2.new(0.9, 0, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.SubText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
end

local function CreateToggle(page, text, state, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = page
    btn.BackgroundColor3 = Colors.Bg
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = ""
    btn.AutoButtonColor = false
    local c = Instance.new("UICorner"); c.Parent = btn
    
    local txt = Instance.new("TextLabel")
    txt.Parent = btn
    txt.BackgroundTransparency = 1
    txt.Position = UDim2.new(0, 15, 0, 0)
    txt.Size = UDim2.new(0.7, 0, 1, 0)
    txt.Text = text
    txt.TextColor3 = Colors.Text
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    
    local ind = Instance.new("Frame")
    ind.Parent = btn
    ind.Position = UDim2.new(1, -35, 0.5, -10)
    ind.Size = UDim2.new(0, 20, 0, 20)
    ind.BackgroundColor3 = state and Colors.Accent or Color3.fromRGB(40,40,45)
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0,6); ic.Parent = ind
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        ind.BackgroundColor3 = state and Colors.Accent or Color3.fromRGB(40,40,45)
        callback(state)
    end)
end

local function CreateSlider(page, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = page
    frame.BackgroundColor3 = Colors.Bg
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    local c = Instance.new("UICorner"); c.Parent = frame
    
    local txt = Instance.new("TextLabel")
    txt.Parent = frame
    txt.BackgroundTransparency = 1
    txt.Position = UDim2.new(0, 15, 0, 5)
    txt.Size = UDim2.new(1, -20, 0, 20)
    txt.Text = text .. ": " .. default
    txt.TextColor3 = Colors.Text
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    
    local bar = Instance.new("TextButton")
    bar.Parent = frame
    bar.BackgroundColor3 = Colors.DarkBg
    bar.Position = UDim2.new(0, 15, 0, 30)
    bar.Size = UDim2.new(1, -30, 0, 8)
    bar.Text = ""
    bar.AutoButtonColor = false
    local sc = Instance.new("UICorner"); sc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.BackgroundColor3 = Colors.Accent
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    local fc = Instance.new("UICorner"); fc.Parent = fill
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + ((max-min) * pos))
        if max < 5 then val = math.floor((min + ((max-min) * pos))*100)/100 end
        txt.Text = text .. ": " .. val
        callback(val)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
end

local function CreateButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = page
    btn.BackgroundColor3 = Colors.Bg
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = text
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local c = Instance.new("UICorner"); c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateBinder(page, text, defaultKey, callback)
    local btn = CreateButton(page, text .. " [" .. defaultKey.Name .. "]", function() end)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Press any key..."
        btn.TextColor3 = Colors.Accent
        local input = UserInputService.InputBegan:Wait()
        if input.UserInputType == Enum.UserInputType.Keyboard then
            btn.Text = text .. " [" .. input.KeyCode.Name .. "]"
            btn.TextColor3 = Colors.Text
            callback(input.KeyCode)
        else
            btn.Text = text .. " [" .. defaultKey.Name .. "]"
            btn.TextColor3 = Colors.Text
        end
    end)
end

-- New Dropdown for Player Selection
local function CreateDropdown(page, text, callback)
    local frame = Instance.new("Frame")
    frame.Parent = page
    frame.BackgroundColor3 = Colors.Bg
    frame.Size = UDim2.new(0.9, 0, 0, 40) -- Collapsed size
    frame.ClipsDescendants = true
    local c = Instance.new("UICorner"); c.Parent = frame
    
    local open = false
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = text .. " (Click to Open)"
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    
    local list = Instance.new("ScrollingFrame")
    list.Parent = frame
    list.BackgroundTransparency = 1
    list.Position = UDim2.new(0, 0, 0, 40)
    list.Size = UDim2.new(1, 0, 1, -40)
    list.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout"); layout.Parent = list
    
    local function Refresh()
        for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local item = Instance.new("TextButton")
                item.Parent = list
                item.Size = UDim2.new(1, 0, 0, 30)
                item.BackgroundTransparency = 1
                item.Text = p.Name
                item.TextColor3 = Colors.SubText
                item.Font = Enum.Font.Gotham
                item.MouseButton1Click:Connect(function()
                    callback(p.Name)
                    Notify("Whitelisted: " .. p.Name)
                end)
            end
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            Refresh()
            TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0.9, 0, 0, 200)}):Play()
            btn.Text = text .. " (Click to Close)"
        else
            TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0.9, 0, 0, 40)}):Play()
            btn.Text = text .. " (Click to Open)"
        end
    end)
end

--------------------------------------------------------------------------------
-- TABS CONSTRUCTION
--------------------------------------------------------------------------------
local InfoPage, InfoTab = CreateTab("Main")
local CombatPage, CombatTab = CreateTab("Combat")
local VisualsPage, VisualsTab = CreateTab("Visuals")
local MovePage, MoveTab = CreateTab("Movement")
local MiscPage, MiscTab = CreateTab("Misc")
local BindsPage, BindsTab = CreateTab("Keybinds")
local WhitePage, WhiteTab = CreateTab("Whitelist")

InfoTab.TextColor3 = Colors.Accent
InfoTab.BackgroundColor3 = Colors.DarkBg
InfoPage.Visible = true

-- INFO
CreateLabel(InfoPage, "Welcome to R-Loader")
CreateLabel(InfoPage, "Game: ERLC / Universal")
CreateLabel(InfoPage, "Status: Undetected")
CreateLabel(InfoPage, "Press Right Ctrl to Toggle UI")
CreateButton(InfoPage, "Unload Script", function() SaveConfig(); ScreenGui:Destroy() end)

-- COMBAT
CreateToggle(CombatPage, "Aimbot Enabled", false, function(v) Config.Aimbot.Enabled = v end)
CreateSlider(CombatPage, "Smoothness", 1, 20, 5, function(v) Config.Aimbot.Smoothness = v end)
CreateSlider(CombatPage, "FOV Size", 50, 800, 300, function(v) Config.Aimbot.FOV = v end)

-- VISUALS
CreateToggle(VisualsPage, "ESP Enabled", false, function(v) Config.ESP.Enabled = v end)
CreateToggle(VisualsPage, "Show Names", true, function(v) Config.ESP.ShowNames = v end)

-- MOVEMENT
local isTeleporting = false
CreateSlider(MovePage, "Phase Distance", 1, 50, 10, function(v) Config.Movement.PhaseDist = v end)
CreateButton(MovePage, "Phase Forward", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist)
    end
end)
CreateButton(MovePage, "Save Position", function()
    if LocalPlayer.Character then
        Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Notify("Position Saved")
    end
end)
CreateSlider(MovePage, "Interval Speed", 0.01, 1, 0.05, function(v) Config.Movement.IntervalSpeed = v end)
CreateButton(MovePage, "Teleport (Interval)", function()
    if not Config.Movement.SavedCFrame then Notify("No Saved Pos!"); return end
    if isTeleporting then isTeleporting = false; Notify("TP Stopped"); return end
    isTeleporting = true
    Notify("Teleporting...")
    task.spawn(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local target = Config.Movement.SavedCFrame.Position
        while isTeleporting and root and (root.Position - target).Magnitude > 5 do
            local dir = (target - root.Position).Unit
            root.CFrame = CFrame.new(root.Position + (dir * 5))
            task.wait(Config.Movement.IntervalSpeed)
            if not LocalPlayer.Character then break end
            root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        if root and isTeleporting then root.CFrame = Config.Movement.SavedCFrame end
        isTeleporting = false
    end)
end)

-- MISC
CreateToggle(MiscPage, "Fly Enabled", false, function(v) Config.Toggles.Fly = v end)
CreateSlider(MiscPage, "Fly Speed", 10, 200, 50, function(v) Config.Movement.FlySpeed = v end)
CreateToggle(MiscPage, "Noclip Enabled", false, function(v) Config.Toggles.Noclip = v end)

-- KEYBINDS
CreateBinder(BindsPage, "Phase", Config.Binds.Phase, function(k) Config.Binds.Phase = k end)
CreateBinder(BindsPage, "Save Pos", Config.Binds.SavePos, function(k) Config.Binds.SavePos = k end)
CreateBinder(BindsPage, "Teleport", Config.Binds.Teleport, function(k) Config.Binds.Teleport = k end)
CreateBinder(BindsPage, "Fly Toggle", Config.Binds.Fly, function(k) Config.Binds.Fly = k end)
CreateBinder(BindsPage, "Noclip Toggle", Config.Binds.Noclip, function(k) Config.Binds.Noclip = k end)

-- WHITELIST
CreateDropdown(WhitePage, "Select Player to Whitelist", function(name)
    Config.Aimbot.Whitelist[name] = true
end)
CreateButton(WhitePage, "Clear Whitelist", function()
    Config.Aimbot.Whitelist = {}
    Notify("Whitelist Cleared")
end)

--------------------------------------------------------------------------------
-- LOGIC
--------------------------------------------------------------------------------

-- Dragging
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- Global Input
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Config.Binds.ToggleUI then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Config.Binds.Phase then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist)
        end
    elseif input.KeyCode == Config.Binds.SavePos then
        if LocalPlayer.Character then
            Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            Notify("Position Saved")
        end
    elseif input.KeyCode == Config.Binds.Fly then
        Config.Toggles.Fly = not Config.Toggles.Fly
        Notify("Fly: " .. tostring(Config.Toggles.Fly))
    elseif input.KeyCode == Config.Binds.Noclip then
        Config.Toggles.Noclip = not Config.Toggles.Noclip
        Notify("Noclip: " .. tostring(Config.Toggles.Noclip))
    end
    -- Trigger teleport via Keybind
    if input.KeyCode == Config.Binds.Teleport then
        if not Config.Movement.SavedCFrame then return end
        if isTeleporting then 
             isTeleporting = false
             Notify("TP Stopped")
             return
        end
        
        isTeleporting = true
        Notify("Teleporting...")
        task.spawn(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local target = Config.Movement.SavedCFrame.Position
            
            while isTeleporting and root and (root.Position - target).Magnitude > 5 do
                local dir = (target - root.Position).Unit
                root.CFrame = CFrame.new(root.Position + (dir * 5))
                task.wait(Config.Movement.IntervalSpeed)
                if not LocalPlayer.Character then break end
                root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            if root and isTeleporting then root.CFrame = Config.Movement.SavedCFrame end
            isTeleporting = false
        end)
    end
end)

-- Fly Logic
RunService.RenderStepped:Connect(function()
    if Config.Toggles.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local vel = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, 1, 0) end
        
        root.Velocity = vel * Config.Movement.FlySpeed
        root.AssemblyLinearVelocity = vel * Config.Movement.FlySpeed -- Newer physics
    end
end)

-- Noclip Logic
RunService.Stepped:Connect(function()
    if Config.Toggles.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ESP Logic
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "RLoaderESP"
ESPFolder.Parent = CoreGui

RunService.RenderStepped:Connect(function()
    if Config.ESP.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hl = ESPFolder:FindFirstChild(plr.Name)
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = plr.Name
                    hl.Parent = ESPFolder
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                end
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(Config.ESP.Fill.R, Config.ESP.Fill.G, Config.ESP.Fill.B)
                hl.OutlineColor = Color3.fromRGB(Config.ESP.Outline.R, Config.ESP.Outline.G, Config.ESP.Outline.B)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end
    else
        ESPFolder:ClearAllChildren()
    end
end)

-- Aimbot Logic
local aiming = false
UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Config.Aimbot.Key then aiming = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Config.Aimbot.Key then aiming = false end end)

RunService.RenderStepped:Connect(function()
    if aiming and Config.Aimbot.Enabled then
        local closest, maxDist = nil, Config.Aimbot.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.Aimbot.TargetPart) and not Config.Aimbot.Whitelist[p.Name] then
                local pos, vis = Camera:WorldToViewportPoint(p.Character[Config.Aimbot.TargetPart].Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < maxDist then maxDist = dist; closest = p.Character[Config.Aimbot.TargetPart] end
                end
            end
        end
        if closest then
            local pos = Camera:WorldToViewportPoint(closest.Position)
            local mousePos = UserInputService:GetMouseLocation()
            mousemoverel((pos.X - mousePos.X)/Config.Aimbot.Smoothness, (pos.Y - mousePos.Y)/Config.Aimbot.Smoothness)
        end
    end
end)

-- Initialize
Notify("R-Loader Injected Successfully", 4)
LoadConfig()