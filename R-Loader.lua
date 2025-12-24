
-- // 1. SERVICES & SETUP // ------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Executor Safe Checks
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local isfile = isfile or function() return false end
local listfiles = listfiles or function() return {} end
local delfile = delfile or function() end
local getcustomasset = getcustomasset or function(path) return path end

-- // 2. FILE SYSTEM & CONFIG LOGIC // ---------------------------------------------------------
local SETTINGS_FOLDER = "R-Loader"
local SCRIPT_FOLDER_PATH = SETTINGS_FOLDER .. "/scripts"
local CONFIGS_FOLDER = SETTINGS_FOLDER .. "/configs"
local HOTRELOAD_FILE = SETTINGS_FOLDER .. "/hotreload.txt"
local ASSETS_FOLDER = SETTINGS_FOLDER .. "/assets"
local PINS_FILE = SETTINGS_FOLDER .. "/pinned_tabs.json"
local UI_SETTINGS_FILE = SETTINGS_FOLDER .. "/ui_settings.json"

-- // ICONS / EMOJI DICTIONARY //
local Icons = {
    -- Roles & Ranks (New)
    owner = "👑",
    admin = "🛡️",
    mod = "👮",
    dev = "🔨",
    vip = "💎",
    partner = "🤝",
    banned = "🚫",

    -- Cheat Features
    aimbot = "🎯",
    esp = "👁️",
    fly = "🕊️",
    speed = "💨",
    jump = "🦘",
    noclip = "🧱",
    godmode = "💪",
    teleport = "🌌",
    exploit = "💉",
    
    -- General / UI
    home = "🏠",
    settings = "⚙️",
    user = "👤",
    search = "🔍",
    menu = "☰",
    star = "⭐",
    heart = "❤️",
    trash = "🗑️",
    save = "💾",
    edit = "✏️",
    close = "❌",
    check = "✅",
    alert = "⚠️",
    info = "ℹ️",
    loading = "⏳",
    
    -- Actions
    copy = "📋",
    paste = "📋",
    download = "📥",
    upload = "📤",
    refresh = "🔄",
    link = "🔗",
    lock = "🔒",
    unlock = "🔓",
    play = "▶️",
    pause = "⏸️",
    stop = "⏹️",
    
    -- Socials & Web
    discord = "💬",
    youtube = "📺",
    twitter = "🐦",
    globe = "🌐",
    mail = "✉️",
    announcement = "📢",
    
    -- Combat / Game
    sword = "⚔️",
    shield = "🛡️",
    gun = "🔫",
    skull = "💀",
    eye = "👁️",
    ghost = "👻",
    fire = "🔥",
    lightning = "⚡",
    
    -- System & Stats
    server = "🖥️",
    wifi = "📶",
    ram = "💾",
    cpu = "🧠",
    fps = "🎞️",
    
    -- Arrows
    left = "⬅️",
    right = "➡️",
    up = "⬆️",
    down = "⬇️",
    back = "🔙"
}

-- // COLOR DICTIONARY //
local Colors = {
    -- Roles & Ranks
    owner = Color3.fromRGB(255, 215, 0),     -- Gold
    admin = Color3.fromRGB(255, 50, 50),     -- Power Red
    mod = Color3.fromRGB(50, 150, 255),      -- Police Blue
    dev = Color3.fromRGB(255, 140, 0),       -- Construction Orange
    vip = Color3.fromRGB(220, 80, 255),      -- Gem Purple
    partner = Color3.fromRGB(255, 105, 180), -- Pink
    banned = Color3.fromRGB(160, 0, 0),      -- Dark Red

    -- Cheat Features
    aimbot = Color3.fromRGB(255, 60, 60),    -- Target Red
    esp = Color3.fromRGB(0, 255, 255),       -- Vision Cyan
    fly = Color3.fromRGB(135, 206, 250),     -- Sky Blue
    speed = Color3.fromRGB(255, 255, 0),     -- Lightning Yellow
    jump = Color3.fromRGB(50, 255, 100),     -- Spring Green
    noclip = Color3.fromRGB(150, 150, 150),  -- Ghost Gray
    godmode = Color3.fromRGB(255, 223, 0),   -- God Gold
    teleport = Color3.fromRGB(148, 0, 211),  -- Void Purple
    exploit = Color3.fromRGB(0, 255, 0),     -- Hacker Green
    
    -- General / UI
    home = Color3.fromRGB(230, 230, 240),    -- White/Off-White
    settings = Color3.fromRGB(160, 160, 170),-- Gear Gray
    user = Color3.fromRGB(255, 255, 255),
    search = Color3.fromRGB(200, 200, 255),
    menu = Color3.fromRGB(200, 200, 200),
    star = Color3.fromRGB(255, 215, 0),
    heart = Color3.fromRGB(255, 80, 80),
    trash = Color3.fromRGB(255, 90, 90),
    save = Color3.fromRGB(80, 160, 255),     -- Floppy Disk Blue
    edit = Color3.fromRGB(255, 200, 50),     -- Pencil Yellow
    close = Color3.fromRGB(255, 50, 50),
    check = Color3.fromRGB(100, 255, 100),
    alert = Color3.fromRGB(255, 200, 0),
    info = Color3.fromRGB(100, 200, 255),
    loading = Color3.fromRGB(200, 200, 200),
    
    -- Actions
    copy = Color3.fromRGB(220, 220, 220),
    paste = Color3.fromRGB(220, 220, 220),
    download = Color3.fromRGB(100, 255, 150),
    upload = Color3.fromRGB(100, 150, 255),
    refresh = Color3.fromRGB(100, 255, 200),
    link = Color3.fromRGB(50, 150, 255),
    lock = Color3.fromRGB(255, 100, 100),
    unlock = Color3.fromRGB(100, 255, 100),
    play = Color3.fromRGB(100, 255, 100),
    pause = Color3.fromRGB(255, 200, 100),
    stop = Color3.fromRGB(255, 50, 50),
    
    -- Socials & Web
    discord = Color3.fromRGB(88, 101, 242),  -- Official Blurple
    youtube = Color3.fromRGB(255, 0, 0),     -- YouTube Red
    twitter = Color3.fromRGB(29, 161, 242),  -- Twitter Blue
    globe = Color3.fromRGB(50, 150, 255),
    mail = Color3.fromRGB(240, 240, 200),
    announcement = Color3.fromRGB(255, 120, 50),
    
    -- Combat / Game
    sword = Color3.fromRGB(192, 192, 192),   -- Steel
    shield = Color3.fromRGB(50, 100, 255),   -- Shield Blue
    gun = Color3.fromRGB(128, 128, 128),     -- Gunmetal
    skull = Color3.fromRGB(220, 220, 220),   -- Bone
    eye = Color3.fromRGB(0, 255, 255),
    ghost = Color3.fromRGB(200, 200, 255),
    fire = Color3.fromRGB(255, 80, 0),
    lightning = Color3.fromRGB(255, 255, 0),
    
    -- System & Stats
    server = Color3.fromRGB(50, 255, 50),
    wifi = Color3.fromRGB(50, 200, 255),
    ram = Color3.fromRGB(0, 150, 255),
    cpu = Color3.fromRGB(100, 100, 255),
    fps = Color3.fromRGB(200, 200, 200),
    
    -- Arrows (Default White)
    left = Color3.fromRGB(255, 255, 255),
    right = Color3.fromRGB(255, 255, 255),
    up = Color3.fromRGB(255, 255, 255),
    down = Color3.fromRGB(255, 255, 255),
    back = Color3.fromRGB(255, 255, 255)
}

-- Initialize Folders
if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end
if not isfolder(CONFIGS_FOLDER) then makefolder(CONFIGS_FOLDER) end
if not isfolder(SCRIPT_FOLDER_PATH) then makefolder(SCRIPT_FOLDER_PATH) end
if not isfolder(ASSETS_FOLDER) then makefolder(ASSETS_FOLDER) end

-- [[ DATA MANAGEMENT ]] --
local PinnedTabs = {}

-- Default Settings
local SystemSettings = {
    Keybind = "RightShift",
    UIScale = 1,
    ShowWallpaper = true,
    WallpaperURL = "", -- << ADD THIS LINE
    Toggles = {} -- Stores generic toggle states by name
}

local function SaveData()
    pcall(function()
        writefile(PINS_FILE, HttpService:JSONEncode(PinnedTabs))
        writefile(UI_SETTINGS_FILE, HttpService:JSONEncode(SystemSettings))
    end)
end

local function LoadData()
    -- Load Pins
    if isfile(PINS_FILE) then
        local s, r = pcall(function() return HttpService:JSONDecode(readfile(PINS_FILE)) end)
        if s and type(r) == "table" then PinnedTabs = r end
    end
    -- Load System Settings
    if isfile(UI_SETTINGS_FILE) then
        local s, r = pcall(function() return HttpService:JSONDecode(readfile(UI_SETTINGS_FILE)) end)
        if s and type(r) == "table" then 
            -- Merge loaded data into default table to ensure all keys exist
            for k, v in pairs(r) do 
                if k == "Toggles" and type(v) == "table" then
                    for tk, tv in pairs(v) do SystemSettings.Toggles[tk] = tv end
                else
                    SystemSettings[k] = v 
                end
            end
        end
    end
end

LoadData() -- Load immediately before UI construction

local function GetProcessedIcon(id)
    if not id or string.find(id, "rbxassetid://") then return id end
    if string.find(id, "http") then
        local fileName = string.gsub(id, "[^%w]", "") .. ".png"
        local filePath = ASSETS_FOLDER .. "/" .. fileName
        if isfile(filePath) then return getcustomasset(filePath) end
        local success, data = pcall(function() return game:HttpGet(id) end)
        if success and data then
            writefile(filePath, data)
            return getcustomasset(filePath)
        end
    end
    return id 
end

-- // 3. SPECIAL USERS & INTRO // -------------------------------------------------------------
local SpecialUsers = {
    --mix
    [1104273577] = { Title = "Welcome, Developer", Background = "https://w.wallhaven.cc/full/4g/wallhaven-4gy2zd.jpg" },
    --ceyy
    [2335971665] = { Title = "Welcome, 👑King", Background = "https://w.wallhaven.cc/full/4d/wallhaven-4d39wo.jpg" }
}
local DEFAULT_BACKGROUND = "https://wallpapercave.com/wp/wp5055045.jpg"
local GreetingsList = {"Hello", "Welcome", "Greetings", "Hey there", "Sup"}
local RandomGreeting = GreetingsList[math.random(1, #GreetingsList)]

local isSpecial = SpecialUsers[LocalPlayer.UserId]
local introText = isSpecial and isSpecial.Title or RandomGreeting .. ", " .. LocalPlayer.Name

local function PlayIntro()
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "RLoader_Intro"
    IntroGui.Parent = (gethui and gethui()) or CoreGui
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IntroBG = Instance.new("Frame")
    IntroBG.Size = UDim2.new(1, 0, 1, 0)
    IntroBG.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    IntroBG.BackgroundTransparency = 1
    IntroBG.Parent = IntroGui

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 300, 0, 300)
    Container.Position = UDim2.new(0.5, 0, 0.5, -175)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundTransparency = 1
    Container.Parent = IntroBG

    local PFP = Instance.new("ImageLabel")
    PFP.Size = UDim2.new(0, 100, 0, 100)
    PFP.Position = UDim2.new(0.5, -50, 0.3, 0)
    PFP.BackgroundTransparency = 1
    PFP.ImageTransparency = 1
    PFP.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    PFP.Parent = Container
    
    local PFPCorner = Instance.new("UICorner")
    PFPCorner.CornerRadius = UDim.new(1, 0)
    PFPCorner.Parent = PFP
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0, 30)
    NameLabel.Position = UDim2.new(0, 0, 0.65, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    NameLabel.TextScaled = true 
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = "" 
    NameLabel.Parent = Container

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 0, 0, 2)
    Line.Position = UDim2.new(0.5, 0, 0.75, 0)
    Line.AnchorPoint = Vector2.new(0.5, 0)
    Line.BackgroundColor3 = Color3.fromRGB(138, 100, 255)
    Line.BorderSizePixel = 0
    Line.BackgroundTransparency = 1
    Line.Parent = Container

    TweenService:Create(PFP, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
    local lineTween = TweenService:Create(Line, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 2), BackgroundTransparency = 0})
    lineTween:Play()
    
    for i = 1, #introText do
        NameLabel.Text = string.sub(introText, 1, i)
        task.wait(0.05)
    end
    
    task.wait(0.5) 
    
    local fadeInfo = TweenInfo.new(0.5)
    TweenService:Create(PFP, fadeInfo, {ImageTransparency = 1}):Play()
    TweenService:Create(NameLabel, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(Line, fadeInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2)}):Play()
    TweenService:Create(IntroBG, fadeInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.5)
    IntroGui:Destroy()
end

PlayIntro()

-- // 4. EMBEDDED UI LIBRARY // -------------------------------------------------------
local Library = (function()
    local UILibrary = {}
    local theme = {
        Background = Color3.fromRGB(15, 15, 25), Sidebar = Color3.fromRGB(20, 18, 35),
        Header = Color3.fromRGB(25, 20, 40), Panel = Color3.fromRGB(28, 25, 45),
        Accent = Color3.fromRGB(138, 100, 255), AccentHover = Color3.fromRGB(158, 120, 255),
        ButtonBg = Color3.fromRGB(35, 30, 55), ButtonHover = Color3.fromRGB(45, 40, 65), 
        ButtonBgLoad = Color3.fromRGB(35, 30, 55), 
        Text = Color3.fromRGB(230, 230, 240), TextDim = Color3.fromRGB(140, 135, 160), 
        Border = Color3.fromRGB(60, 50, 90), Error = Color3.fromRGB(255, 100, 120),
        Font = Enum.Font.Gotham
    }

    -- Helper functions
    local function create(class, props)
        local obj = Instance.new(class)
        for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
        if props.Parent then obj.Parent = props.Parent end
        return obj
    end
    local function roundify(obj, radius) create("UICorner", {CornerRadius = UDim.new(0, radius or 4), Parent = obj}) end
    local function addStroke(obj, color) create("UIStroke", {Color = color or theme.Border, Thickness = 1, Parent = obj}) end
    local function tween(obj, props, t) TweenService:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

    function UILibrary:CreateWindow(config)
        local title = config.Title or "UI"
        
        -- [[ ROBUST KEYBIND LOADING ]]
        local CurrentKeybind = Enum.KeyCode.RightShift
        if SystemSettings.Keybind and Enum.KeyCode[SystemSettings.Keybind] then
            CurrentKeybind = Enum.KeyCode[SystemSettings.Keybind]
        end

        local ScreenGui = create("ScreenGui", {
            Name = "ModernUI_"..title, 
            Parent = (gethui and gethui()) or CoreGui, 
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 10000, 
            IgnoreGuiInset = true 
        })
        --[[Loader version]]
        local RL_VERSION="beta-b32c6wt86"

        -- [[ APPLY SAVED SCALE ]]
        local UIScale = create("UIScale", {Parent = ScreenGui, Scale = SystemSettings.UIScale or 1})

        -- [[ MAIN CONTAINER ]]
        local Container = create("Frame", {
            Size = UDim2.new(0, 700, 0, 500), 
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.Background,
            BackgroundTransparency = 1,
            Parent = ScreenGui,
            ClipsDescendants = true,
            Visible = false
        })
        roundify(Container, 12); addStroke(Container)

        -- [[ FIX: APPLY SAVED WALLPAPER STATE ]]
        local Wall = create("ImageLabel", {
            Name = "Wallpaper",
            Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop,
            ImageTransparency = 0, ZIndex = 0, Parent = Container,
            Visible = SystemSettings.ShowWallpaper -- Directly use saved boolean
        })
        roundify(Wall, 12)

        -- Dragging
        local dragging, dragInput, dragStart, startPos
        Container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = Container.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        Container.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                tween(Container, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
            end
        end)

        -- Header
        local Header = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = theme.Header, BackgroundTransparency = 0.1, Parent = Container})
        roundify(Header, 12)
        create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = theme.Header, BackgroundTransparency = 0.1, Parent = Header, BorderSizePixel=0})
-- // CUSTOM ICON SUPPORT //
        local HeaderIcon = create("ImageLabel", {
            Name = "HeaderIcon",
            Size = UDim2.new(0, 37, 0, 37),                -- Size of the image (30x30 pixels)
            Position = UDim2.new(0, 15.5, 0.38, -15),          -- 10px from left edge, centered vertically
            BackgroundTransparency = 1,                     -- Ensure background is clear for rounding
            Image = GetProcessedIcon("https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/Image/Icons/R-loadertrans-Christmas.png"), -- PASTE YOUR PNG LINK INSIDE THESE QUOTES
            Parent = Header
        })
        
        -- Apply rounding. 15px radius on a 30px image makes it a perfect circle.
        -- Change 15 to 8 if you want a rounded square instead.
        roundify(HeaderIcon, 8) 

        -- // TITLE LABEL (Moved right) //
        create("TextLabel", {
            Text = title, 
            Size = UDim2.new(1, -100, 1, 0), 
            Position = UDim2.new(0, 51, 0, 0),          
            BackgroundTransparency = 1, 
            TextColor3 = theme.Text, 
            Font = theme.Font, 
            TextSize = 20, 
            TextXAlignment = Enum.TextXAlignment.Left, 
            Parent = Header
        })

        -- Toggle/Min/Close Logic
        local isOpen = false
        local isMinimizing = false

        local function SetState(state)
            if isMinimizing then return end
            isOpen = state
            
            if state then
                Container.Visible = true
                Container.Size = UDim2.new(0, 650, 0, 450)
                Container.BackgroundTransparency = 1
                local openTween = TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 700, 0, 500), BackgroundTransparency = 0.1
                })
                openTween:Play()
            else
                isMinimizing = true
                local closeTween = TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 1
                })
                closeTween:Play()
                closeTween.Completed:Wait()
                Container.Visible = false
                isMinimizing = false
            end
        end
        local MinimizeBtn = create("TextButton", {Text = "-", Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-85,0,5), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 24, Parent = Header})
        MinimizeBtn.MouseButton1Click:Connect(function() 
            SetState(false)
            
            -- [[ NOTIFY USER OF KEYBIND ]]
            local savedKey = SystemSettings.Keybind or "RightShift"
            -- We use a task.delay to ensure Window is fully initialized before calling Notify
            task.delay(0.1, function()
                if Window and Window.Notify then
                    Window:Notify("UI Hidden", "Press " .. tostring(savedKey) .. " to toggle UI")
                end
            end)
        end)

        local CloseBtn = create("TextButton", {Text = "X", Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-45,0,5), BackgroundTransparency = 1, TextColor3 = theme.Error, Font = Enum.Font.GothamBold, TextSize = 18, Parent = Header})
        CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
        
-- [[ FIX: ROBUST INPUT LISTENER ]]
        UserInputService.InputBegan:Connect(function(input)
            -- Check if user is typing in chat/console
            local isTyping = UserInputService:GetFocusedTextBox() ~= nil
            
            if input.KeyCode == CurrentKeybind and not isTyping then
                SetState(not isOpen)
            end
        end)
        -- Sidebar & Content
        local Sidebar = create("Frame", {Size = UDim2.new(0, 140, 1, -50), Position = UDim2.new(0,0,0,50), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.1, Parent = Container, BorderSizePixel = 0})
        create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
        create("Frame", {Size = UDim2.new(1, 0, 0, 15), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Sidebar})
        create("Frame", {Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Sidebar})

        local ProfileFrame = create("Frame", {Name = "Profile", Size = UDim2.new(1, 0, 0, 90), BackgroundTransparency = 1, Parent = Sidebar})
        local SidePFP = create("ImageLabel", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, -25, 0.1, 0), BackgroundTransparency = 1, Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", Parent = ProfileFrame})
        create("UICorner", {CornerRadius = UDim.new(1,0), Parent = SidePFP})
        create("UIStroke", {Color = theme.Accent, Thickness = 2, Parent = SidePFP})
        create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.7, 0), BackgroundTransparency = 1, Text = RandomGreeting .. ", " .. LocalPlayer.Name, TextColor3 = theme.Text, Font = theme.Font, TextSize = 12, Parent = ProfileFrame})

        local SidebarList = create("Frame", {Size = UDim2.new(1, 0, 1, -90), Position = UDim2.new(0, 0, 0, 90), BackgroundTransparency = 1, Parent = Sidebar})
        create("UIListLayout", {Parent = SidebarList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,5)})
        create("UIPadding", {Parent = SidebarList, PaddingTop = UDim.new(0,10)})

        local Content = create("Frame", {Size = UDim2.new(1, -150, 1, -60), Position = UDim2.new(0, 145, 0, 55), BackgroundTransparency = 1, Parent = Container})

        local VerLabel = create("TextLabel", {Text = RL_VERSION, Size = UDim2.new(0, 100, 0, 20), Position = UDim2.new(1, -10, 1, -20), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, Parent = Container, ZIndex = 20})

        -- Notifications
        local NotifyFrame = create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -260, 0, 0), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100})
        create("UIListLayout", {Parent = NotifyFrame, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})
        create("UIPadding", {Parent = NotifyFrame, PaddingBottom = UDim.new(0, 20)})

        local Window = {ScreenGui = ScreenGui, Wallpaper = Wall, Scale = UIScale, Container = Container, SetState = SetState, SetKeybind = function(self, key) CurrentKeybind = key end} 

        function Window:Notify(title, msg)
            local N = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1})
            roundify(N, 8); addStroke(N, theme.Accent)
            create("TextLabel", {Text = title, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = N})
            create("TextLabel", {Text = msg, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = N})
            N.Position = UDim2.new(1, 300, 0, 0)
            tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
            task.spawn(function()
                task.wait(4)
                tween(N, {BackgroundTransparency = 1}, 0.5)
                for _,v in pairs(N:GetChildren()) do if v:IsA("TextLabel") then tween(v, {TextTransparency=1}, 0.5) end end
                task.wait(0.5)
                N:Destroy()
            end)
        end


function Window:CreateCategory(name, icon)
            local isPinned = PinnedTabs[name] == true
            local order = isPinned and -1 or 1
            if name == "Dashboard" then order = -9999 end 

            local TabBtn = create("TextButton", {
                Text = "   " .. icon .. "  " .. name, 
                Size = UDim2.new(1, 0, 0, 35), 
                BackgroundColor3 = theme.Sidebar, 
                BackgroundTransparency = 0.5, 
                TextColor3 = theme.TextDim, 
                Font = theme.Font, 
                TextSize = 14, 
                TextXAlignment = Enum.TextXAlignment.Left, 
                Parent = SidebarList, 
                BorderSizePixel = 0, 
                LayoutOrder = order, 
                Active = true
            })
            
            local PinIcon = create("ImageButton", {
                Image = "rbxassetid://10709791437", 
                ImageColor3 = isPinned and theme.Accent or theme.TextDim, 
                BackgroundTransparency = 1, 
                Size = UDim2.new(0, 20, 0, 20), 
                Position = UDim2.new(1, -30, 0.5, -10), 
                Parent = TabBtn, 
                ZIndex = 2
            })

            local TabFrame = create("ScrollingFrame", {
                Size = UDim2.new(1,0,1,0), 
                BackgroundTransparency = 1, 
                Visible = false, 
                ScrollBarThickness = 2, 
                Parent = Content, 
                CanvasSize = UDim2.new(0,0,0,0), 
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout", {Parent = TabFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,10)})
            create("UIPadding", {Parent = TabFrame, PaddingRight = UDim.new(0,5), PaddingLeft = UDim.new(0,5), PaddingTop = UDim.new(0,5)})

            -- [[ LOGIC: OPEN TAB FUNCTION ]]
            local function OpenThisTab()
                -- Reset all buttons
                for _,v in pairs(SidebarList:GetChildren()) do 
                    if v:IsA("TextButton") then 
                        tween(v, {BackgroundColor3 = theme.Sidebar, TextColor3 = theme.TextDim}, 0.2)
                    end 
                end
                
                -- Hide all frames
                for _,v in pairs(Content:GetChildren()) do 
                    v.Visible = false 
                end

                -- Activate current button
                tween(TabBtn, {BackgroundColor3 = theme.Background, TextColor3 = theme.Accent}, 0.2)
                
                -- Show current frame
                TabFrame.Visible = true
                
                -- Animate elements inside
                for i, v in pairs(TabFrame:GetChildren()) do
                    if v:IsA("GuiObject") then
                        v.BackgroundTransparency = 1
                        local targetTrans = (v.Name == "Dropdown" or v.Name:find("ScriptCard")) and 0.2 or 0
                        if v:IsA("TextLabel") then targetTrans = 1 end
                        tween(v, {BackgroundTransparency = targetTrans}, 0.3 + (i * 0.05))
                    end
                end
            end

            TabBtn.MouseButton1Click:Connect(OpenThisTab)

            -- [[ FIX: CHECK IF THIS IS DASHBOARD AND LOAD IT ]]
            if name == "Dashboard" then
                OpenThisTab()
            end

            -- Pin Logic
            local function TogglePin()
                if name == "Dashboard" then return end
                local newState = not PinnedTabs[name]
                PinnedTabs[name] = newState
                PinIcon.ImageColor3 = newState and theme.Accent or theme.TextDim
                TabBtn.LayoutOrder = newState and -1 or 1
                SaveData()
            end
            TabBtn.MouseButton2Click:Connect(TogglePin) 
            PinIcon.MouseButton1Click:Connect(TogglePin)

            local Tab = {ScrollFrame = TabFrame}

-- Add this helper function immediately above Tab:Button
            local function textShrink(obj, maxSize) 
                obj.TextScaled = true 
                obj.TextWrapped = true 
                create("UITextSizeConstraint", {Parent = obj, MaxTextSize = maxSize}) 
            end

            function Tab:Button(text, icon, textColor, callback)
                -- 1. Auto-Detect Arguments (Icon/Color are optional)
                if type(icon) == "function" then 
                    callback = icon; icon = nil; textColor = nil 
                elseif type(textColor) == "function" then
                    callback = textColor; textColor = nil
                end

                -- 2. Format Text with Icon
                local displayText = text
                if icon and icon ~= "" then displayText = icon .. "  " .. text end
                
                -- 3. Determine Color
                local finalColor = textColor or theme.Text

                local Btn = create("TextButton", {
                    Text = displayText, 
                    Size = UDim2.new(1,0,0,35), 
                    BackgroundColor3 = theme.ButtonBg, 
                    BackgroundTransparency = 0.2, 
                    TextColor3 = finalColor, -- Color Applied Here
                    Font = theme.Font, 
                    Parent = TabFrame
                })
                roundify(Btn, 6)
                textShrink(Btn, 14) -- Prevents text cutting off

                Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = theme.ButtonHover}, 0.2) end)
                Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = theme.ButtonBg}, 0.2) end)
                Btn.MouseButton1Click:Connect(callback)
                return Btn
            end
            
            -- (Ensure you include the rest of the Tab functions like Tab:ScriptCard, Tab:Label, etc. here)
            function Tab:ScriptCard(name, iconId, desc, callback)
                 -- ... paste your existing ScriptCard logic here ...
                 local Container = create("Frame", {Name = "ScriptCard_"..name, Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = theme.Panel, BackgroundTransparency = 0.2, Parent = TabFrame})
                 roundify(Container, 8); addStroke(Container, theme.Border)
                 local IconContainer = create("Frame", {Size = UDim2.new(0, 65, 0, 65), Position = UDim2.new(0, 8, 0.5, -32.5), BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.5, Parent = Container})
                 roundify(IconContainer, 8); addStroke(IconContainer, theme.Border)
                 create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = (GetProcessedIcon and GetProcessedIcon(iconId)) or iconId, ScaleType = Enum.ScaleType.Fit, Parent = IconContainer})
                 create("TextLabel", {Text = name, Size = UDim2.new(1, -85, 0, 20), Position = UDim2.new(0, 83, 0, 8), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Container})
                 create("TextLabel", {Text = desc or "No description.", Size = UDim2.new(1, -85, 0, 40), Position = UDim2.new(0, 83, 0, 30), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Container})
                 local LoadBtn = create("TextButton", {Text = "Load Script", Size = UDim2.new(1, -85, 0, 25), Position = UDim2.new(0, 83, 1, -33), BackgroundColor3 = theme.ButtonBgLoad, BackgroundTransparency = 0.2, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, Parent = Container})
                 roundify(LoadBtn, 4)
                 LoadBtn.MouseButton1Click:Connect(callback)
                 return Container
            end

            function Tab:Label(text)
                return create("TextLabel", {Text = text, Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFrame})
            end

            function Tab:Dropdown(text, options, callback, defaultVal)
                local currentSelection = defaultVal or text
                local Frame = create("Frame", {Name="Dropdown", Size = UDim2.new(1,0,0,35), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame, ClipsDescendants=true})
                roundify(Frame, 6)
                local Header = create("TextButton", {Text = text .. (defaultVal and ": " .. defaultVal or " ▼"), Size = UDim2.new(1,0,0,35), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=14, Parent=Frame})
                local List = create("Frame", {Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,35), BackgroundTransparency=1, Parent=Frame})
                create("UIListLayout", {Parent=List})
                local open = false
                Header.MouseButton1Click:Connect(function()
                    open = not open
                    tween(Frame, {Size = UDim2.new(1,0,0, open and 35 + (#options*30) or 35)}, 0.2)
                end)
                for _, opt in pairs(options) do
                    local OptBtn = create("TextButton", {Text = opt, Size = UDim2.new(1,0,0,30), BackgroundColor3 = theme.Panel, BackgroundTransparency=0.2, TextColor3 = theme.Text, Font = theme.Font, TextSize = 13, Parent = List})
                    OptBtn.MouseButton1Click:Connect(function()
                        open = false
                        tween(Frame, {Size = UDim2.new(1,0,0,35)}, 0.2)
                        Header.Text = text .. ": " .. opt
                        callback(opt)
                    end)
                end
                return Frame
            end

            function Tab:Toggle(text, default, callback, saveOverrideKey)
                local key = saveOverrideKey or text
                local isRootSetting = (saveOverrideKey ~= nil) 
                local savedState
                if isRootSetting then savedState = SystemSettings[key] else savedState = SystemSettings.Toggles[key] end
                if savedState == nil then savedState = default end

                local Frame = create("Frame", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame})
                roundify(Frame, 6)
                create("TextLabel", {Text = text, Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
                
                local Indicator = create("TextButton", {Text="", Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-30,0.5,-10), BackgroundColor3 = savedState and theme.Accent or theme.Panel, Parent=Frame})
                roundify(Indicator, 4)
                
                task.spawn(function() callback(savedState) end)

                local state = savedState
                Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        Indicator.BackgroundColor3 = state and theme.Accent or theme.Panel
                        if isRootSetting then SystemSettings[key] = state else SystemSettings.Toggles[key] = state end
                        SaveData()
                        callback(state)
                    end
                end)
                return Frame
            end

            return Tab
        end
        return Window
    end
    return UILibrary
end)()

-- // 5. DATA & SCRIPT CATALOG // --------------------------------------------------------------
local CURRENT_GAME_ID = game.GameId
local GameList = {
    ["Arsenal"] = 111958650,
    ["Rivals"] = 6035872082,
    ["Baseplate"] = 80461030,
    ["Emote RNG"] = 8313824597,
    ["Blade Ball"] = 4777817887,
    ["Valley Prison"] = 5456952508,
    ["Lucky Blocks"] = 279565647,
    ["AOTR"] = 4658598196,
    ["BB Legends"] = 4931927012,
    ["The Forge"] = 7671049560,
    ["Prison Life"] = 73885730,
    ["Flick"] = 8795154789,
    ["Build A Boat"] = 210851291,
    ["FNAF Eternal Nights"] = 4053293514,
    ["Doors"] = 2440500124,
    ["Legends Of Sd"] = 1119466531,
    ["Nights in the Forest"] = 7326934954,
    ["Slayers Battleground"] = 5114901609,

}
local CurrentGameName = "Universal"
for name, id in pairs(GameList) do if CURRENT_GAME_ID == id then CurrentGameName = name break end end

BG_christmas_1="https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/Image/Icons/R-loadertrans-Christmas.png"

local FullCatalog = {

    ["Universal"] = {
        {
            Name = "Mana",
            Icon = BG_christmas_1,
            Description = "ManaV2 universal utility hub.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Maanaaaa/ManaV2ForRoblox/main/MainScript.lua'))()"
        },
        {
            Name = "Infinite Yield",
            Icon = BG_christmas_1,
            Description = "The ultimate admin command script with hundreds of commands.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"
        },
        {
            Name = "R-Loader/Universal",
            Icon = BG_christmas_1,
            Description = "Universal version of R-Loader.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/R-loader-universal.lua'))()"
        },
        {
            Name = "R-Loader Old UI",
            Icon = BG_christmas_1,
            Description = "This is the old ui of R-loader if you run into any issues happy exploiting",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/R-Loader-deprecated.lua'))()"
        },
    },

    ["Arsenal"] = {
        {
            Name = "Z3US: partially Detected",
            Icon = BG_christmas_1,
            Description = "Aimbot, silent aim, and Arsenal utilities. Partially detected.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Arsenal%20Beta.lua'))()"
        },
        {
            Name = "Vapa-v2",
            Icon = BG_christmas_1,
            Description = "Advanced Arsenal script with combat utilities.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Nickyangtpe/Vapa-v2/refs/heads/main/Vapav2-Arsenal.lua", true))()'
        },
    },

    ["Rivals"] = {
        {
            Name = "Z3US Rivals",
            Icon = BG_christmas_1,
            Description = "Z3US version for Rivals with autoload support.",
            Load = [[
                getgenv().autoload = autoloadEnabled
                loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Rivals%20Beta.lua"))()
            ]]
        },
    },


    ["Prison Life"] = {
        {
            Name = "DP-HUB",
            Icon = BG_christmas_1,
            Description = "Prison Life admin, ESP, combat, and more.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/PrisonLife_DP-HUB.lua'))()"
        },
    },

    ["BB Legends"] = {
        {
            Name = "absence-mini",
            Icon = BG_christmas_1,
            Description = "Mini version of absence-hub for BB Legends.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/vnausea/absence-mini/refs/heads/main/absencemini.lua'))()"
        },
    },
    ["Slayers Battleground"] = {
        {
            Name = "Slayers Battleground/R-Loader",
            Icon = BG_christmas_1,
            Description = "Gives you infinite Ult.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/SlayerBattleGrounds.lua'))()"
        },
    },

    ["Build A Boat"] = {
        {
            Name = "Uniqu Hub",
            Icon = BG_christmas_1,
            Description = "Multi-game hub including Build A Boat support.",
            Load = 'loadstring(game:HttpGet("https://rawscripts.net/raw/Unique-Hub-(14-Gmes)_521"))()'
        },
        {
            Name = "Lexus Hub: partially working/laggy",
            Icon = BG_christmas_1,
            Description = "BABFT script with partial features but laggy.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/102KIRA/Best-Babft-script/refs/heads/main/Actually%20Best%20babft%20script"))()'
        },
    },

    ["Lucky Blocks"] = {
        {
            Name = "Lucky Blocks",
            Icon = BG_christmas_1,
            Description = "Universal Lucky Blocks Battlegrounds script.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Veaquach/LBBattlegroundsscript/refs/heads/main/Universal%20Lucky%20Block%20Battle%20Grounds%20Script.txt'))()"
        },
    },

    ["Legends Of Sd"] = {
        {
            Name = "Legends Of Speed",
            Icon = BG_christmas_1,
            Description = "Legends of Speed script with auto-farm and utilities.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/Speed%20legendsFh.lua",true))()'
        },
    },

    ["FNAF Eternal Nights"] = {
        {
            Name = "FNAF Eternal Nights",
            Icon = BG_christmas_1,
            Description = "FNAF Eternal Nights script pack.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Snipez-Dev/Rbx-Scripts/refs/heads/main/Eternal%20Nights"))()'
        },
    },

    ["Nights in the Forest"] = {
        {
            Name = "unknown",
            Icon = BG_christmas_1,
            Description = "Luarmor-protected loader for Nights In The Forest.",
            Load = 'loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/c27892d6692ba09d991c09dc9d5ceae1.lua"))()'
        },
    },

    ["Doors"] = {
        {
            Name = "Rloader Doors",
            Icon = BG_christmas_1,
            Description = "R-Loader version for Doors.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/Doors_RLoader.lua"))()'
        },
        {
            Name = "zynlope-no-ui",
            Icon = BG_christmas_1,
            Description = "UI-less Doors script.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/rolezeay/doors/refs/heads/main/hmmmmm"))()'
        },
    },

    ["AOTR"] = {
        {
            Name = "Attack on Titan Revolution",
            Icon = BG_christmas_1,
            Description = "AOTR Luarmor script loader.",
            Load = 'loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/705e7fe7aa288f0fe86900cedb1119b1.lua"))()'
        },
    },

    ["The Forge"] = {
        {
            Name = "Rayfield",
            Icon = BG_christmas_1,
            Description = "The Forge script using Rayfield UI.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/LioK251/RbScripts/refs/heads/main/lazyuhub_theforge.lua"))()'
        },
        {
            Name = "ForgeHub",
            Icon = BG_christmas_1,
            Description = "Utility hub for The Forge.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/TheForgeFH.lua",true))()'
        },
        {
            Name = "pepehook-loader",
            Icon = BG_christmas_1,
            Description = "Pepehook loader for The Forge.",
            Load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/GiftStein1/pepehook-loader/refs/heads/main/loader.lua"))()'
        },
    },

    ["Blade Ball"] = {
        {
            Name = "Akashial",
            Icon = BG_christmas_1,
            Description = "Akashial Blade Ball loader.",
            Load = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Akash1al/Blade-Ball-Updated-Script/refs/heads/main/Blade-Ball-Script'))()"
        },
        {
            Name = "MixRawwr",
            Icon = BG_christmas_1,
            Description = "MixRawwr Blade Ball loader.",
            Load = "loadstring(game:HttpGet('https://pastebin.com/raw/5v3yQUvH',true))()"
        },
    },
}


local ActiveCatalog = { ["Universal"] = FullCatalog["Universal"] }
if CurrentGameName ~= "Universal" and FullCatalog[CurrentGameName] then ActiveCatalog[CurrentGameName] = FullCatalog[CurrentGameName] end

-- // 6. UI INITIALIZATION & BACKGROUND PRELOAD // --------------------------------------------

local Window = Library:CreateWindow({
    Title = "Loader | " .. CurrentGameName,
    Size = Vector2.new(700, 500)
})

-- Background Preload Logic (REPLACE YOUR EXISTING BLOCK IN SECTION 6 WITH THIS)
task.spawn(function()
    local BG_FILE_PATH = SETTINGS_FOLDER .. "/custom_bg.jpg"
    
    -- 1. Determine which URL to use
    local bgUrl = DEFAULT_BACKGROUND
    
    -- If user has a saved custom URL, use that first
    if SystemSettings.WallpaperURL and SystemSettings.WallpaperURL ~= "" then
        bgUrl = SystemSettings.WallpaperURL
    -- Otherwise check for Special User background
    elseif SpecialUsers[LocalPlayer.UserId] and SpecialUsers[LocalPlayer.UserId].Background ~= "" then
        bgUrl = SpecialUsers[LocalPlayer.UserId].Background
    end

    local function LoadBG()
        -- 2. If file exists and matches our goal, just load it (faster)
        -- Note: We re-download if the saved URL changed or file is missing
        if isfile(BG_FILE_PATH) then
            local asset = getcustomasset and getcustomasset(BG_FILE_PATH) or BG_FILE_PATH
            if Window.Wallpaper then Window.Wallpaper.Image = asset end
        else
            -- File missing, force download
            local success, response = pcall(function() return game:HttpGet(bgUrl) end)
            if success and response then
                writefile(BG_FILE_PATH, response)
                local asset = getcustomasset and getcustomasset(BG_FILE_PATH) or BG_FILE_PATH
                if Window.Wallpaper then Window.Wallpaper.Image = asset end
            end
        end
    end
    
    Window:Notify("System", "Loading Assets...")
    LoadBG()
    
    task.wait(0.5)
    Window.SetState(true) 
end)

-- Hot Reload
task.spawn(function()
    if isfile(HOTRELOAD_FILE) then
        local savedData = readfile(HOTRELOAD_FILE)
        local gameContext, scriptName = savedData:match("([^:]+):(.+)")
        if gameContext == CurrentGameName or gameContext == "Universal" then
             local targetScript = nil
             if FullCatalog[gameContext] then
                 for _, s in ipairs(FullCatalog[gameContext]) do if s.Name == scriptName then targetScript = s break end end
             end
             if targetScript then
                 Window:Notify("Hot Reload", "Loading " .. scriptName)
                 loadstring(targetScript.Load)()
             end
        end
    end
end)

-- // 7. UI TABS // ---------------------------------------------------------------------------

-- >> DASHBOARD (Always First)
local Dashboard = Window:CreateCategory("Dashboard", "🏠")
Dashboard:Label("--- User Profile ---")
Dashboard:Button("Copy Game ID: " .. tostring(CURRENT_GAME_ID), function() setclipboard(tostring(CURRENT_GAME_ID)); Window:Notify("System", "Game ID copied.") end)
Dashboard:Label("--- Credits ---")
-- 1. Owner Button (Gold Icon + Text)
Dashboard:Button("Owner Discord: ewkobe", Icons.owner, Colors.owner, function() 
    setclipboard("ewkobe")
    Window:Notify("System", "Discord copied!") 
end)

-- 2. Dev Button (Orange Icon + Text)
Dashboard:Button("Owner/Dev: @mixapire", Icons.dev, Colors.dev, function() 
    setclipboard("mixapire")
    Window:Notify("System", "Discord copied!") 
end)

-- 3. Invite Button (Discord Blue Icon + Text)
Dashboard:Button("Copy Discord Invite", Icons.discord, Colors.discord, function() 
    setclipboard("https://discord.gg/g2ufS3jV")
    Window:Notify("System", "Discord Link Copied!") 
end)

-- >> GAME SCRIPTS
for categoryName, scripts in pairs(ActiveCatalog) do
    local GameTab = Window:CreateCategory(categoryName, "🎮")
    GameTab:Label("--- " .. categoryName .. " Scripts ---")
    for _, scriptData in ipairs(scripts) do
        GameTab:ScriptCard(scriptData.Name, scriptData.Icon, scriptData.Description, function()
            pcall(function() loadstring(scriptData.Load)() end)
            Window:Notify("Executor Loading", scriptData.Name)
            Window:Notify("Executor", scriptData.Name .. " Loaded.")
        end)
    end
end

-- >> SETTINGS
local Settings = Window:CreateCategory("Settings", "⚙️")

Settings:Label("--- UI Appearance ---")
Settings:Dropdown("UI Scale", {"0.5", "0.75", "1", "1.25", "1.5"}, function(val)
    if Window.Scale then Window.Scale.Scale = tonumber(val) end
    SystemSettings.UIScale = tonumber(val); SaveData()
end, tostring(SystemSettings.UIScale)) -- Pass default saved value

-- FIX: Using specific save key "ShowWallpaper" so it maps to SystemSettings.ShowWallpaper
Settings:Toggle("Custom Wallpaper", true, function(state)
    if Window.Wallpaper then Window.Wallpaper.Visible = state end
    -- Note: Save logic handled inside toggle function now
end, "ShowWallpaper") 

-- // WALLPAPER INPUT FIELD (UPDATED) // ---------------------------------------
Settings:Label("--- Set Custom Background ---")

local WallpaperInput = Instance.new("TextBox")
WallpaperInput.Name = "WallpaperInput"
WallpaperInput.Size = UDim2.new(1, 0, 0, 35)
WallpaperInput.BackgroundColor3 = Color3.fromRGB(28, 25, 45)
WallpaperInput.TextColor3 = Color3.fromRGB(230, 230, 240)
WallpaperInput.Font = Enum.Font.Gotham
WallpaperInput.TextSize = 14
WallpaperInput.PlaceholderText = "Paste Image URL here..."
-- Pre-fill with saved URL if it exists
WallpaperInput.Text = SystemSettings.WallpaperURL or "" 
WallpaperInput.ClearTextOnFocus = false
WallpaperInput.Parent = Settings.ScrollFrame

local WP_Corner = Instance.new("UICorner"); WP_Corner.CornerRadius = UDim.new(0, 6); WP_Corner.Parent = WallpaperInput

Settings:Button("Download & Save", function()
    local url = WallpaperInput.Text
    local BG_FILE_PATH = SETTINGS_FOLDER .. "/custom_bg.jpg"

    if url == "" or not url:find("http") then 
        Window:Notify("Error", "Invalid URL.")
        return 
    end
    
    -- // 1. UNLOAD & VISUAL FEEDBACK //
    if Window.Wallpaper then
        Window.Wallpaper.Image = "" -- Unload current
        Window.Wallpaper.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Dark loading screen
        Window.Wallpaper.BackgroundTransparency = 0.5 -- Semi-transparent
        Window.Wallpaper.Visible = true
    end
    
    Window:Notify("System", "Downloading...")

    task.spawn(function()
        -- // 2. ATTEMPT DOWNLOAD //
        local success, data = pcall(function() return game:HttpGet(url) end)

        if success and data and #data > 0 then
            -- // SUCCESS //
            if isfile(BG_FILE_PATH) then delfile(BG_FILE_PATH) end
            writefile(BG_FILE_PATH, data)
            
            -- Save the URL so it persists on reload
            SystemSettings.WallpaperURL = url
            SystemSettings.ShowWallpaper = true
            SaveData() 
            
            -- Load new asset
            local newAsset = getcustomasset(BG_FILE_PATH)
            if Window.Wallpaper then
                Window.Wallpaper.Image = newAsset
                Window.Wallpaper.BackgroundTransparency = 1 -- Return to transparent container
            end
            Window:Notify("Success", "Wallpaper Updated & Saved.")
        else
            Window:Notify("Error", "Download Failed. Restoring...")
            
            -- Restore previous file if it exists
            if isfile(BG_FILE_PATH) then
                local oldAsset = getcustomasset(BG_FILE_PATH)
                if Window.Wallpaper then
                    Window.Wallpaper.Image = oldAsset
                    Window.Wallpaper.BackgroundTransparency = 1
                end
            end
        end
    end)
end)

Settings:Label("--- Keybinds ---")
local keys = {"RightShift", "RightControl", "LeftControl", "LeftAlt", "Insert", "Delete", "Home", "End", "F1", "F4", "F8"}
Settings:Dropdown("UI Toggle Key", keys, function(val)
    if Enum.KeyCode[val] then
        Window:SetKeybind(Enum.KeyCode[val])
        SystemSettings.Keybind = val
        SaveData()
        Window:Notify("Settings", "Bind saved to " .. val)
    end
end, SystemSettings.Keybind)

Settings:Label("--- Hot Reload ("..CurrentGameName..") ---")
local validScripts = {"None"}
for _, s in ipairs(FullCatalog["Universal"]) do table.insert(validScripts, "Universal:" .. s.Name) end
if CurrentGameName ~= "Universal" and FullCatalog[CurrentGameName] then
    for _, s in ipairs(FullCatalog[CurrentGameName]) do table.insert(validScripts, CurrentGameName .. ":" .. s.Name) end
end

Settings:Dropdown("Select Auto-Load Script", validScripts, function(val)
    if val == "None" then delfile(HOTRELOAD_FILE); Window:Notify("Hot Reload", "Disabled") else
        local g, s = val:match("([^:]+):(.+)")
        writefile(HOTRELOAD_FILE, g .. ":" .. s)
        Window:Notify("Hot Reload", "Set to: " .. s)
    end
end)

Settings:Label("--- Config Management ---")
local selectedConfig = "Default"
local configList = listfiles(CONFIGS_FOLDER) or {}
local cleanList = {}
for _, file in pairs(configList) do table.insert(cleanList, file:gsub(CONFIGS_FOLDER.."\\", ""):gsub(CONFIGS_FOLDER.."/", "")) end

Settings:Dropdown("Select Config", cleanList, function(val) selectedConfig = val end)
Settings:Button("Load Config", function()
    local path = CONFIGS_FOLDER .. "/" .. selectedConfig
    if isfile(path) then
        Window:Notify("Config", "Loaded " .. selectedConfig)
    end
end)

local InputBox = Instance.new("TextBox")
InputBox.Name = "CustomInput"
InputBox.Size = UDim2.new(1, 0, 0, 35)
InputBox.BackgroundColor3 = Color3.fromRGB(28, 25, 45)
InputBox.TextColor3 = Color3.fromRGB(230, 230, 240)
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.PlaceholderText = "Type new config name..."
InputBox.Text = ""
InputBox.Parent = Settings.ScrollFrame
local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 6); UICorner.Parent = InputBox

Settings:Button("Save / Overwrite", function()
    local name = InputBox.Text ~= "" and InputBox.Text or selectedConfig
    if not name:find(".json") then name = name .. ".json" end
    writefile(CONFIGS_FOLDER .. "/" .. name, HttpService:JSONEncode({Saved = true, Game = CurrentGameName}))
    Window:Notify("Config", "Saved " .. name)
end)

Settings:Button("Delete Selected", function()
    local path = CONFIGS_FOLDER .. "/" .. selectedConfig
    if isfile(path) then delfile(path); Window:Notify("Config", "Deleted " .. selectedConfig) end
end)