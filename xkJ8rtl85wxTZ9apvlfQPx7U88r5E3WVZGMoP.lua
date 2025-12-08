local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
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
        Fill = {R=175, G=25, B=25},
        Outline = {R=255, G=255, B=255},
        ShowNames = true
    },
    Movement = {
        PhaseDist = 10,
        SavedCFrame = nil, 
        IntervalSpeed = 0.05,
        FlySpeed = 50,
        WalkSpeed = 16,
        SprintSpeed = 24,
        JumpPower = 50
    },
    Binds = {
        ToggleUI = Enum.KeyCode.M,
        Phase = Enum.KeyCode.F,
        SavePos = Enum.KeyCode.H,
        Teleport = Enum.KeyCode.J,
        Fly = Enum.KeyCode.V,
        Noclip = Enum.KeyCode.B,
        InvisibleTG = Enum.KeyCode.Y,

    },
    Toggles = {
        Fly = false,
        Noclip = false,
        InvisibleTG = false,
        InfiniteJump = false,
        Safe_Teleport = false,
        WalkSpeed=false,
        SprintSpeedT=false,
    }
}

-- CONFIG SYSTEM
local FolderName = "R-Loader_Config"
local FileName = "Settings.json"

local function SaveConfig()
    if not makefolder then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    
    local SaveData = {
        Aimbot = Config.Aimbot,
        ESP = Config.ESP,
        Movement = Config.Movement,
        Toggles = Config.Toggles,
        Binds = {} 
    }

    for name, key in pairs(Config.Binds) do
        if typeof(key) == "EnumItem" then
            SaveData.Binds[name] = key.Name
        end
    end
    
    local Data = HttpService:JSONEncode(SaveData)
    writefile(FolderName .. "/" .. FileName, Data)
end

local function LoadConfig()
    if not isfile then return end
    if isfile(FolderName .. "/" .. FileName) then
        local content = readfile(FolderName .. "/" .. FileName)
        local decoded = HttpService:JSONDecode(content)
        
        if decoded.Aimbot then for k,v in pairs(decoded.Aimbot) do Config.Aimbot[k] = v end end
        if decoded.ESP then for k,v in pairs(decoded.ESP) do Config.ESP[k] = v end end
        if decoded.Movement then for k,v in pairs(decoded.Movement) do Config.Movement[k] = v end end
        if decoded.Toggles then for k,v in pairs(decoded.Toggles) do Config.Toggles[k] = v end end

        if decoded.Binds then
            for name, keyName in pairs(decoded.Binds) do
                if Enum.KeyCode[keyName] then
                    Config.Binds[name] = Enum.KeyCode[keyName]
                end
            end
        end
    end
end

LoadConfig()

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

local Colors = {
    Bg = Color3.fromRGB(20, 20, 25),
    DarkBg = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150)
}

MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Colors.Bg
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = MainFrame

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
Title.Text = "R-loader | Universal"
Title.TextColor3 = Colors.Accent
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

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
    Notify("Press M to Open")
end)

TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.Size = UDim2.new(0, 120, 1, -40)
local TabList = Instance.new("UIListLayout"); TabList.Parent = TabContainer; TabList.SortOrder = Enum.SortOrder.LayoutOrder

Content.Parent = MainFrame
Content.BackgroundColor3 = Colors.DarkBg
Content.Position = UDim2.new(0, 120, 0, 40)
Content.Size = UDim2.new(1, -120, 1, -40)
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 0); cc.Parent = Content

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabContainer
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 0) -- Ensure this is 0

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.BackgroundColor3 = Colors.Bg
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 0) -- Initial size (fixed below)
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
    
    -- Default Layout for standard tabs
    local pl = Instance.new("UIListLayout"); pl.Parent = page; pl.Padding = UDim.new(0, 8); pl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pp = Instance.new("UIPadding"); pp.Parent = page; pp.PaddingTop = UDim.new(0, 15)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        for _,v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Colors.SubText; v.BackgroundColor3 = Colors.Bg end end
        page.Visible = true
        btn.TextColor3 = Colors.Accent
        btn.BackgroundColor3 = Colors.DarkBg
    end)

    -- // AUTO-RESIZE LOGIC //
    -- 1. Get all current tabs
    local tabs = {}
    for _, child in pairs(TabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            table.insert(tabs, child)
        end
    end
    
    -- 2. Calculate percentage height (1 / Number of tabs)
    local newHeight = 1 / #tabs
    
    -- 3. Apply to ALL tabs
    for _, tabBtn in pairs(tabs) do
        tabBtn.Size = UDim2.new(1, 0, newHeight, 0)
    end

    return page, btn
end

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
        SaveConfig()
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
    -- FIXED: Added SaveConfig() when slider input ends
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging=false 
            SaveConfig()
        end 
    end)
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
    local currentKey = defaultKey
    local btn = CreateButton(page, text .. " [" .. currentKey.Name .. "]", function() end)
    
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Press any key..."
        btn.TextColor3 = Colors.Accent
        local input = UserInputService.InputBegan:Wait()
        if input.UserInputType == Enum.UserInputType.Keyboard then
            btn.Text = text .. " [" .. input.KeyCode.Name .. "]"
            btn.TextColor3 = Colors.Text
            callback(input.KeyCode)
            SaveConfig()
        else
            btn.Text = text .. " [" .. currentKey.Name .. "]"
            btn.TextColor3 = Colors.Text
        end
    end)
end

local function CreateDropdown(page, text, callback)
    local frame = Instance.new("Frame")
    frame.Parent = page
    frame.BackgroundColor3 = Colors.Bg
    frame.Size = UDim2.new(0.9, 0, 0, 40)
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
                    SaveConfig()
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

-- [[ CRITICAL FIX: TO PLAYER TAB ]]
local TPPage, TPTab = CreateTab("To Player")
-- We must remove the default layout so the custom layout works
for _, v in pairs(TPPage:GetChildren()) do
    if v:IsA("UIListLayout") or v:IsA("UIPadding") then
        v:Destroy()
    end
end

local MiscPage, MiscTab = CreateTab("Misc")
local BindsPage, BindsTab = CreateTab("Keybinds")
local WhitePage, WhiteTab = CreateTab("Whitelist")

InfoTab.TextColor3 = Colors.Accent
InfoTab.BackgroundColor3 = Colors.DarkBg
InfoPage.Visible = true

local Status = " Undetected"

-- [[ INFO TAB ]] --
CreateLabel(InfoPage, "Welcome to R-Loader")
CreateLabel(InfoPage, "Game: Universal")
CreateLabel(InfoPage, "Status:" .. Status)
CreateLabel(InfoPage, "Press M to Toggle UI")
CreateButton(InfoPage, "Unload Script", function() SaveConfig(); ScreenGui:Destroy() end)

-- [[ COMBAT TAB ]] --
CreateToggle(CombatPage, "Aimbot Enabled", Config.Aimbot.Enabled, function(v) 
    Config.Aimbot.Enabled = v 
    SaveConfig()
end)

CreateSlider(CombatPage, "Smoothness", 1, 20, Config.Aimbot.Smoothness, function(v) 
    Config.Aimbot.Smoothness = v 
end)

CreateSlider(CombatPage, "FOV Size", 50, 800, Config.Aimbot.FOV, function(v) 
    Config.Aimbot.FOV = v 
end)

-- [[ VISUALS TAB ]] --
CreateToggle(VisualsPage, "ESP Enabled", Config.ESP.Enabled, function(v) 
    Config.ESP.Enabled = v 
    SaveConfig()
end)

CreateToggle(VisualsPage, "Show Names", Config.ESP.ShowNames, function(v) 
    Config.ESP.ShowNames = v 
    SaveConfig()
end)

--------------------------------------------------------------------------------
-- TAB: MOVEMENT
--------------------------------------------------------------------------------
local isTeleporting = false

local function CheckRig(char)
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        if hum.RigType == Enum.HumanoidRigType.R15 then return 'R15' else return 'R6' end
    end
    return 'R6'
end

CreateSlider(MovePage, "Phase Distance", 1, 50, Config.Movement.PhaseDist, function(v) 
    Config.Movement.PhaseDist = v 
end)

CreateButton(MovePage, "Phase Forward", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local targetCFrame = Camera.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist)
        root.CFrame = CFrame.new(targetCFrame.Position) * root.CFrame.Rotation
        root.AssemblyLinearVelocity = Vector3.zero 
        root.Velocity = Vector3.zero
    end
end)

CreateButton(MovePage, "Save Position", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Notify("Position Saved")
    end
end)

Config.Toggles.Safe_Teleport = Config.Toggles.Safe_Teleport or false
CreateToggle(MovePage, "Safe Teleport (Desync)", Config.Toggles.Safe_Teleport, function(v) 
    Config.Toggles.Safe_Teleport = v 
    SaveConfig()
end)

CreateSlider(MovePage, "Interval Speed", 0.01, 1, Config.Movement.IntervalSpeed, function(v) 
    Config.Movement.IntervalSpeed = v 
end)

CreateButton(MovePage, "Teleport", function()
    if not Config.Movement.SavedCFrame then Notify("No Saved Pos!"); return end
    
    if Config.Toggles.Safe_Teleport then
        local char = LocalPlayer.Character
        if not char or not char.PrimaryPart then return end
        
        Notify("Safe Teleporting...")

        local Part = Instance.new('Part', workspace)
        Part.Size = Vector3.new(10, 1, 10)
        Part.Anchored = true
        Part.CFrame = CFrame.new(9999, 9999, 9999)
        
        char:SetPrimaryPartCFrame(Part.CFrame * CFrame.new(0, 3, 0))
        task.wait(0.1) 
        
        local rigType = CheckRig(char)
        if rigType == 'R6' then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local clone = root:Clone()
                root:Destroy()
                clone.Parent = char
                char.PrimaryPart = clone
            end
        else
            local lowerTorso = char:FindFirstChild("LowerTorso")
            if lowerTorso then
                local root = lowerTorso:FindFirstChild("Root")
                if root then
                    local clone = root:Clone()
                    root:Destroy()
                    clone.Parent = lowerTorso
                end
            end
        end

        task.wait(0.2)
        if char.PrimaryPart then
            char:SetPrimaryPartCFrame(Config.Movement.SavedCFrame)
        end
        
        task.delay(3, function() 
            if Part then Part:Destroy() end 
        end)
        return
    end

    if isTeleporting then 
        isTeleporting = false
        Notify("TP Stopped")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
        return 
    end
    
    isTeleporting = true
    Notify("Teleporting...")
    
    task.spawn(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local target = Config.Movement.SavedCFrame.Position
        
        if root then root.Anchored = true end
        
        while isTeleporting and root and (root.Position - target).Magnitude > 5 do
            local dir = (target - root.Position).Unit
            root.CFrame = CFrame.new(root.Position + (dir * 5)) * root.CFrame.Rotation
            task.wait(Config.Movement.IntervalSpeed)
            
            if not LocalPlayer.Character then break end
            root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        
        if root then
            if isTeleporting then root.CFrame = Config.Movement.SavedCFrame end
            root.Anchored = false
        end
        isTeleporting = false
    end)
end)

--------------------------------------------------------------------------------
-- TAB: TELEPORT TO PLAYER + LOGGER
--------------------------------------------------------------------------------

local isTPingToPlayer = false
local liveUpdateEnabled = true
local trackedPlayers = {} 

local SubNav = Instance.new("Frame")
SubNav.Parent = TPPage
SubNav.BackgroundColor3 = Colors.Bg
SubNav.BackgroundTransparency = 1
SubNav.Position = UDim2.new(0, 0, 0, 0)
SubNav.Size = UDim2.new(1, 0, 0, 35)

local ViewListBtn = Instance.new("TextButton")
ViewListBtn.Parent = SubNav
ViewListBtn.BackgroundColor3 = Colors.DarkBg
ViewListBtn.Position = UDim2.new(0, 0, 0, 0)
ViewListBtn.Size = UDim2.new(0.5, -2, 1, 0)
ViewListBtn.Text = "Player List"
ViewListBtn.TextColor3 = Colors.Accent
ViewListBtn.Font = Enum.Font.GothamBold
ViewListBtn.TextSize = 14
local v1Corner = Instance.new("UICorner"); v1Corner.Parent = ViewListBtn

local ViewLogsBtn = Instance.new("TextButton")
ViewLogsBtn.Parent = SubNav
ViewLogsBtn.BackgroundColor3 = Colors.DarkBg
ViewLogsBtn.Position = UDim2.new(0.5, 2, 0, 0)
ViewLogsBtn.Size = UDim2.new(0.5, -2, 1, 0)
ViewLogsBtn.Text = "Activity Logs"
ViewLogsBtn.TextColor3 = Colors.Text
ViewLogsBtn.Font = Enum.Font.GothamBold
ViewLogsBtn.TextSize = 14
local v2Corner = Instance.new("UICorner"); v2Corner.Parent = ViewLogsBtn

local ListContainer = Instance.new("Frame")
ListContainer.Parent = TPPage
ListContainer.BackgroundTransparency = 1
ListContainer.Position = UDim2.new(0, 0, 0, 40)
ListContainer.Size = UDim2.new(1, 0, 1, -40)
ListContainer.Visible = true 

local LogsContainerFrame = Instance.new("Frame")
LogsContainerFrame.Parent = TPPage
LogsContainerFrame.BackgroundTransparency = 1
LogsContainerFrame.Position = UDim2.new(0, 0, 0, 40)
LogsContainerFrame.Size = UDim2.new(1, 0, 1, -40)
LogsContainerFrame.Visible = false 

ViewListBtn.MouseButton1Click:Connect(function()
    ListContainer.Visible = true
    LogsContainerFrame.Visible = false
    ViewListBtn.TextColor3 = Colors.Accent
    ViewLogsBtn.TextColor3 = Colors.Text
end)

ViewLogsBtn.MouseButton1Click:Connect(function()
    ListContainer.Visible = false
    LogsContainerFrame.Visible = true
    ViewListBtn.TextColor3 = Colors.Text
    ViewLogsBtn.TextColor3 = Colors.Accent
end)

local ListControls = Instance.new("Frame")
ListControls.Parent = ListContainer
ListControls.BackgroundTransparency = 1
ListControls.Size = UDim2.new(1, 0, 0, 35)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Parent = ListControls
RefreshBtn.BackgroundColor3 = Colors.DarkBg
RefreshBtn.Size = UDim2.new(0.65, -5, 1, 0)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Colors.Text
RefreshBtn.Font = Enum.Font.Gotham
RefreshBtn.TextSize = 14
local rCorner = Instance.new("UICorner"); rCorner.Parent = RefreshBtn

local LiveCheckBtn = Instance.new("TextButton")
LiveCheckBtn.Parent = ListControls
LiveCheckBtn.BackgroundColor3 = Colors.DarkBg
LiveCheckBtn.Position = UDim2.new(0.65, 5, 0, 0)
LiveCheckBtn.Size = UDim2.new(0.35, -5, 1, 0)
LiveCheckBtn.Text = "Live: ON"
LiveCheckBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
LiveCheckBtn.Font = Enum.Font.Gotham
LiveCheckBtn.TextSize = 12
local cCorner = Instance.new("UICorner"); cCorner.Parent = LiveCheckBtn

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Parent = ListContainer
PlayerListScroll.BackgroundColor3 = Colors.Bg
PlayerListScroll.BackgroundTransparency = 1
PlayerListScroll.Position = UDim2.new(0, 0, 0, 40)
PlayerListScroll.Size = UDim2.new(1, 0, 1, -40)
PlayerListScroll.ScrollBarThickness = 2
PlayerListScroll.BorderSizePixel = 0
local PListLayout = Instance.new("UIListLayout"); PListLayout.Parent = PlayerListScroll; PListLayout.Padding = UDim.new(0, 5); PListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function TeleportToPlayer(targetPlayer)
    if isTPingToPlayer then 
        isTPingToPlayer = false
        Notify("TP Stopped")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
        return 
    end
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Player invalid!")
        return
    end
    isTPingToPlayer = true
    Notify("Going to: " .. targetPlayer.Name)
    task.spawn(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = true end
        while isTPingToPlayer and root and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
            local targetRoot = targetPlayer.Character.HumanoidRootPart
            local dist = (targetRoot.Position - root.Position).Magnitude
            if dist < 5 then break end
            local dir = (targetRoot.Position - root.Position).Unit
            root.CFrame = CFrame.new(root.Position + (dir * 5)) * root.CFrame.Rotation
            task.wait(Config.Movement.IntervalSpeed or 0.05)
            if not LocalPlayer.Character then break end
            root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        if root then root.Anchored = false end
        isTPingToPlayer = false
        Notify("Arrived!")
    end)
end

local function RefreshPlayerList()
    local currentPos = PlayerListScroll.CanvasPosition
    for _, v in pairs(PlayerListScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local distText = "?"
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                distText = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
            end
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerListScroll
            btn.BackgroundColor3 = Colors.DarkBg
            btn.Size = UDim2.new(0.9, 0, 0, 35)
            btn.Text = plr.Name .. " [" .. distText .. " studs]"
            btn.TextColor3 = Colors.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            local c = Instance.new("UICorner"); c.Parent = btn
            btn.MouseButton1Click:Connect(function() TeleportToPlayer(plr) end)
        end
    end
    PlayerListScroll.CanvasPosition = currentPos
end

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
LiveCheckBtn.MouseButton1Click:Connect(function()
    liveUpdateEnabled = not liveUpdateEnabled
    if liveUpdateEnabled then LiveCheckBtn.Text = "Live: ON"; LiveCheckBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else LiveCheckBtn.Text = "Live: OFF"; LiveCheckBtn.TextColor3 = Color3.fromRGB(255, 100, 100) end
end)
task.spawn(function() while true do if liveUpdateEnabled then RefreshPlayerList() end; task.wait(1) end end)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Parent = LogsContainerFrame
LogScroll.BackgroundColor3 = Colors.Bg
LogScroll.BackgroundTransparency = 1
LogScroll.Size = UDim2.new(1, 0, 1, 0)
LogScroll.ScrollBarThickness = 3
LogScroll.BorderSizePixel = 0
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local LogLayout = Instance.new("UIListLayout"); LogLayout.Parent = LogScroll; LogLayout.Padding = UDim.new(0, 2); LogLayout.VerticalAlignment = Enum.VerticalAlignment.Top; LogLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local isModernChat = (TextChatService.ChatVersion == Enum.ChatVersion.TextChatService)

local function AddLog(text, color)
    local label = Instance.new("TextLabel")
    label.Parent = LogScroll
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -5, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Text = " " .. text
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.RichText = true 
    LogScroll.CanvasPosition = Vector2.new(0, 99999)
end

if isModernChat then
    TextChatService.MessageReceived:Connect(function(msgObj)
        local source = msgObj.TextSource
        if source then
            local plr = Players:GetPlayerByUserId(source.UserId)
            if plr and plr ~= LocalPlayer then AddLog("["..plr.Name.."]: " .. msgObj.Text, Color3.fromRGB(255, 235, 59)) end
        end
    end)
    AddLog("System: Modern Chat Detected", Color3.fromRGB(100, 255, 255))
else
    AddLog("System: Legacy Chat Detected", Color3.fromRGB(100, 255, 255))
end

local function ConnectChat(plr)
    if isModernChat then return end 
    if plr == LocalPlayer then return end 
    plr.Chatted:Connect(function(msg) AddLog("["..plr.Name.."]: " .. msg, Color3.fromRGB(255, 235, 59)) end)
end

task.spawn(function()
    for _, p in pairs(Players:GetPlayers()) do trackedPlayers[p.Name] = true; ConnectChat(p) end
    while true do
        local currentPlayers = Players:GetPlayers()
        local currentNames = {}
        for _, p in pairs(currentPlayers) do
            currentNames[p.Name] = true
            if not trackedPlayers[p.Name] then
                trackedPlayers[p.Name] = true
                AddLog("[+] " .. p.Name .. " Joined", Color3.fromRGB(0, 255, 0))
                ConnectChat(p) 
                RefreshPlayerList()
            end
        end
        for name, _ in pairs(trackedPlayers) do
            if not currentNames[name] then
                trackedPlayers[name] = nil
                AddLog("[-] " .. name .. " Left", Color3.fromRGB(255, 0, 0))
                RefreshPlayerList()
            end
        end
        task.wait(0.5) 
    end
end)
AddLog("Logger Active...", Color3.fromRGB(200, 200, 200))
RefreshPlayerList()

-- [[ MISC TAB ]] --
CreateSlider(MiscPage, "Fly Speed", 10, 200, Config.Movement.FlySpeed, function(v) 
    Config.Movement.FlySpeed = v 
end)

Config.Movement.WalkSpeed = Config.Movement.WalkSSpeed or 16
CreateSlider(MiscPage, "WalkS Speed", 10, 200, Config.Movement.WalkSSpeed, function(v) 
    Config.Movement.WalkSSpeed = v 
end)

Config.Movement.SprintSpeed = Config.Movement.SprintSpeed or 24
CreateSlider(MiscPage, "Sprint Speed", 10, 200, Config.Movement.SprintSpeed, function(v) 
    Config.Movement.SprintSpeed = v 
end)

Config.Movement.JumpPower = Config.Movement.JumpPower or 50
CreateSlider(MiscPage, "Jump Power", 10, 200, Config.Movement.JumpPower, function(v) 
    Config.Movement.JumpPower = v 
end)

CreateToggle(MiscPage, "Fly", Config.Toggles.Fly, function(v) 
    Config.Toggles.Fly = v 
    SaveConfig()
end)
CreateToggle(MiscPage, "Infinite Jump", Config.Toggles.InfiniteJump, function(v) 
    Config.Toggles.InfiniteJump = v 
    SaveConfig()
end)

CreateToggle(MiscPage, "Walk Speed", Config.Toggles.InfiniteJump, function(v) 
    Config.Toggles.WalkSpeedT = v 
    SaveConfig()
end)

CreateToggle(MiscPage, "Sprint Speed", Config.Toggles.Fly, function(v) 
    Config.Toggles.SprintSpeedT = v 
    SaveConfig()
end)

CreateToggle(MiscPage, "Noclip", Config.Toggles.Noclip, function(v) 
    Config.Toggles.Noclip = v 
    SaveConfig()
end)
CreateToggle(MiscPage, "Invisiblity", Config.Toggles.InvisibleTG, function(v) 
    Config.Toggles.InvisibleTG = v 
    SaveConfig()
end)

-- [[ KEYBINDS TAB ]] --
CreateBinder(BindsPage, "ToggleUI", Config.Binds.ToggleUI, function(k) Config.Binds.ToggleUI = k; SaveConfig() end)
CreateBinder(BindsPage, "Phase", Config.Binds.Phase, function(k) Config.Binds.Phase = k; SaveConfig() end)
CreateBinder(BindsPage, "Save Pos", Config.Binds.SavePos, function(k) Config.Binds.SavePos = k; SaveConfig() end)
CreateBinder(BindsPage, "Teleport", Config.Binds.Teleport, function(k) Config.Binds.Teleport = k; SaveConfig() end)
CreateBinder(BindsPage, "Fly Toggle", Config.Binds.Fly, function(k) Config.Binds.Fly = k; SaveConfig() end)
CreateBinder(BindsPage, "Noclip Toggle", Config.Binds.Noclip, function(k) Config.Binds.Noclip = k; SaveConfig() end)
CreateBinder(BindsPage, "Invisible Toggle", Config.Binds.InvisibleTG, function(k) Config.Binds.InvisibleTG = k; SaveConfig() end)

-- [[ WHITELIST TAB ]] --
CreateDropdown(WhitePage, "Select Player to Whitelist", function(name)
    Config.Aimbot.Whitelist[name] = true
    SaveConfig()
end)
CreateButton(WhitePage, "Clear Whitelist", function()
    Config.Aimbot.Whitelist = {}
    Notify("Whitelist Cleared")
    SaveConfig()
end)

--------------------------------------------------------------------------------
-- LOGIC
--------------------------------------------------------------------------------

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        SaveConfig()
    end
end)
TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

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
    elseif input.KeyCode == Config.Binds.InvisibleTG then
        Config.Toggles.InvisibleTG = not Config.Toggles.InvisibleTG
        Notify("Invisible: " .. tostring(Config.Toggles.InvisibleTG))
    end
    
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
        root.AssemblyLinearVelocity = vel * Config.Movement.FlySpeed 
    end
end)

local lastNoclipState = false
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    if Config.Toggles.Noclip then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        lastNoclipState = true
    elseif lastNoclipState then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
        lastNoclipState = false
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            local sprint = Config.Movement.SprintSpeed or 24
            if hum.WalkSpeed ~= sprint then hum.WalkSpeed = sprint end
        else
            local walk = Config.Movement.WalkSSpeed or 16
            if hum.WalkSpeed ~= walk then hum.WalkSpeed = walk end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        local power = Config.Movement.JumpPower or 50
        if hum.UseJumpPower == false then hum.UseJumpPower = true end
        if hum.JumpPower ~= power then hum.JumpPower = power end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Toggles.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if char and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local lastInvisibleState = false
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    if Config.Toggles.InvisibleTG then
        lastInvisibleState = true
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 1 end
        end

        if not char:FindFirstChild("LocalGhostEffect") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "LocalGhostEffect"
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end
        
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None 
            if char:FindFirstChild("Head") then
                for _, obj in pairs(char.Head:GetChildren()) do
                    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then obj.Enabled = false end
                end
            end
        end

    elseif lastInvisibleState then
        local oldHighlight = char:FindFirstChild("LocalGhostEffect")
        if oldHighlight then oldHighlight:Destroy() end

        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 else v.Transparency = 0 end
            elseif v:IsA("Decal") then
                v.Transparency = 0
            end
        end
        
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            if char:FindFirstChild("Head") then
                for _, obj in pairs(char.Head:GetChildren()) do
                    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then obj.Enabled = true end
                end
            end
        end
        lastInvisibleState = false
    end
end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "RLoaderESP"
ESPFolder.Parent = CoreGui

RunService.RenderStepped:Connect(function()
    if Config.ESP.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hl = ESPFolder:FindFirstChild(plr.Name .. "_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = plr.Name .. "_Highlight"
                    hl.Parent = ESPFolder
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                end
                
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(Config.ESP.Fill.R, Config.ESP.Fill.G, Config.ESP.Fill.B)
                hl.OutlineColor = Color3.fromRGB(Config.ESP.Outline.R, Config.ESP.Outline.G, Config.ESP.Outline.B)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                local tagName = plr.Name .. "_Tag"
                local tag = ESPFolder:FindFirstChild(tagName)

                if Config.ESP.ShowNames then
                    if not tag then
                        tag = Instance.new("BillboardGui")
                        tag.Name = tagName
                        tag.Parent = ESPFolder
                        tag.AlwaysOnTop = true
                        tag.Size = UDim2.new(0, 200, 0, 50)
                        tag.StudsOffset = Vector3.new(0, -5, 0)
                        
                        local label = Instance.new("TextLabel", tag)
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.TextSize = 13
                        label.Font = Enum.Font.GothamBold
                        label.Text = plr.Name
                    end

                    if plr.Character:FindFirstChild("HumanoidRootPart") then
                        tag.Adornee = plr.Character.HumanoidRootPart
                    else
                        tag.Adornee = plr.Character.Head
                    end
                else
                    if tag then tag:Destroy() end
                end

            end
        end
    else
        ESPFolder:ClearAllChildren()
    end
end)

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

Notify("Loading R-Loader...", 0.3)
Notify("R-Loader Injected Successfully", 0.3)