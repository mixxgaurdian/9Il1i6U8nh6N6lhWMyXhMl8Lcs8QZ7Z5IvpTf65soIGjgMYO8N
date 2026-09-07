-- // R-LOADER KEY SYSTEM // ------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global variable to yield the main script
getgenv().RLoader_KeyVerified = false

local DisableAesthetics = true -- Set to true to disable HTTP calls for wallpapers and icons
local SimplifyAnimations = true -- Set to true to reduce tween calls and simplify notifications
local DisableFileSystem = true -- Set to true to use in-memory tables instead of writing to disk

-- // SPECIAL USERS & BYPASS // ---------------------------------------------------------------
local SpecialUsers = {
    [1104273577] = { Title = "Welcome, Developer" },
    [2335971665] = { Title = "Welcome, 👑King" },
    [10104221280] = { Title = "Welcome, Dev" },

    
    [10827226101] = { Title = "Welcome, Special User" }
}
local CORRECT_KEY = "R-LOADER-DISCORD!"
local FREE_KEY = "R-LOADER-DISCORD!"
local Discord_Link = "https://discord.gg/g2ufS3jV"

-- // THEME & HELPERS // ----------------------------------------------------------------------
local theme = {
    Background = Color3.fromRGB(15, 15, 25), 
    Header = Color3.fromRGB(25, 20, 40), 
    Panel = Color3.fromRGB(28, 25, 45),
    Accent = Color3.fromRGB(138, 100, 255), 
    ButtonBg = Color3.fromRGB(35, 30, 55), 
    ButtonHover = Color3.fromRGB(45, 40, 65), 
    Text = Color3.fromRGB(230, 230, 240), 
    TextDim = Color3.fromRGB(140, 135, 160), 
    Border = Color3.fromRGB(60, 50, 90), 
    Error = Color3.fromRGB(255, 100, 120),
    Font = Enum.Font.Gotham
}

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end
local function roundify(obj, radius) create("UICorner", {CornerRadius = UDim.new(0, radius or 4), Parent = obj}) end
local function addStroke(obj, color) create("UIStroke", {Color = color or theme.Border, Thickness = 1, Parent = obj}) end
local function tween(obj, props, t)
    if SimplifyAnimations then
        for k, v in pairs(props) do obj[k] = v end
    else
        TweenService:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
end

-- // MAIN KEY GUI // -------------------------------------------------------------------------
local ScreenGui = create("ScreenGui", {Name = "RLoader_KeySystem", Parent = (gethui and gethui()) or CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 10000, IgnoreGuiInset = true})

-- Background Wallpaper (Default)
local Wall = create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, Image = "https://wallpapercave.com/wp/wp5055045.jpg", ZIndex = 0, Parent = ScreenGui})

-- Notification Frame
local NotifyFrame = create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -260, 0, 0), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100})
create("UIListLayout", {Parent = NotifyFrame, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})
create("UIPadding", {Parent = NotifyFrame, PaddingBottom = UDim.new(0, 20)})

local function Notify(title, msg)
    local N = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1})
    roundify(N, 8); addStroke(N, theme.Accent)
    create("TextLabel", {Text = title, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = N})
    create("TextLabel", {Text = msg, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = N})
    if SimplifyAnimations then
        N.Position = UDim2.new(0, 0, 0, 0)
        task.spawn(function()
            task.wait(3)
            N:Destroy()
        end)
    else
        N.Position = UDim2.new(1, 300, 0, 0)
        tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.spawn(function()
            task.wait(3)
            tween(N, {BackgroundTransparency = 1}, 0.5)
            for _,v in pairs(N:GetChildren()) do if v:IsA("TextLabel") then tween(v, {TextTransparency=1}, 0.5) end end
            task.wait(0.5); N:Destroy()
        end)
    end
end

-- Key Container (UPDATED TO DEFAULT 600x400)
local Container = create("Frame", {Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = theme.Background, BackgroundTransparency = 0.1, Parent = ScreenGui, ClipsDescendants = true})
roundify(Container, 12); addStroke(Container)

-- Header
local Header = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = theme.Header, BackgroundTransparency = 0.1, Parent = Container})
roundify(Header, 12)
create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = theme.Header, BackgroundTransparency = 0.1, Parent = Header, BorderSizePixel=0})
create("TextLabel", {Text = "R-Loader | Key System", Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})

-- X Button (ADDED BACK)
local CloseBtn = create("TextButton", {Text = "X", Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-45,0,5), BackgroundTransparency = 1, TextColor3 = theme.Error, Font = Enum.Font.GothamBold, TextSize = 18, Parent = Header})

-- Inputs & Buttons (CENTERED & SCALED FOR 700x500)
local KeyInput = create("TextBox", {Size = UDim2.new(0, 450, 0, 45), Position = UDim2.new(0.5, 0, 0.5, -40), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = theme.Panel, TextColor3 = theme.Text, Font = theme.Font, TextSize = 14, PlaceholderText = "Enter Key Here...", Text = "", ClearTextOnFocus = false, Parent = Container})
roundify(KeyInput, 6); addStroke(KeyInput, theme.Border)
local CopyKeyBtn = create("TextButton", {
    Text = "Free Key", 
    Size = UDim2.new(0, 100, 0, 45), 
    Position = UDim2.new(0.5, 175, 0.5, -40), -- Aligned to the right side of the input
    AnchorPoint = Vector2.new(0.5, 0.5), 
    BackgroundColor3 = theme.ButtonBg, 
    TextColor3 = theme.Text, 
    Font = theme.Font, 
    TextSize = 14, 
    Parent = Container
})
roundify(CopyKeyBtn, 6); addStroke(CopyKeyBtn, theme.Accent)

-- Functionality for Copy Button
CopyKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(FREE_KEY)
    Notify("Clipboard", "Free key copied to clipboard! KEY: " .. FREE_KEY)
    Notify("Info", "Join our Discord for support and updates! " .. Discord_Link)
end)

local VerifyBtn = create("TextButton", {Text = "Verify Key", Size = UDim2.new(0, 450, 0, 45), Position = UDim2.new(0.5, 0, 0.5, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = theme.ButtonBg, TextColor3 = Color3.fromRGB(255, 255, 255), Font = theme.Font, TextSize = 14, Parent = Container})
roundify(VerifyBtn, 6); addStroke(VerifyBtn, theme.Accent)

local DiscordBtn = create("TextButton", {Text = "Copy Discord Link", Size = UDim2.new(0, 450, 0, 40), Position = UDim2.new(0.5, 0, 0.5, 80), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(88, 101, 242), BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(255, 255, 255), Font = theme.Font, TextSize = 14, Parent = Container})
roundify(DiscordBtn, 6);


local EndLabel = create("TextLabel", {Text = "Key does change when I feel like it. Join our Discord for support and updates!", Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 1, -40), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Container.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        tween(Container, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
    end
end)

-- Hover Effects
VerifyBtn.MouseEnter:Connect(function() tween(VerifyBtn, {BackgroundColor3 = theme.ButtonHover}, 0.2) end)
VerifyBtn.MouseLeave:Connect(function() tween(VerifyBtn, {BackgroundColor3 = theme.ButtonBg}, 0.2) end)

-- // LOGIC // --------------------------------------------------------------------------------


DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard(Discord_Link)
    Notify("Discord", "Invite link copied to clipboard!")
end)

local function Authenticate()
    getgenv().RLoader_KeyVerified = true
    Notify("Success", "Key authenticated. Loading R-Loader...")
    task.wait(0.3)
    
    -- Smooth exit animation before destroying
    tween(Container, {Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 1}, 0.3)
    for _, v in pairs(Container:GetChildren()) do if v:IsA("GuiObject") then tween(v, {BackgroundTransparency = 1}, 0.3) end end
    tween(Wall, {ImageTransparency = 1}, 0.5)
    
    ScreenGui:Destroy()
end

VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        Authenticate()
    else
        Notify("Error", "Invalid Key provided. Try again.")
        KeyInput.Text = ""
    end
end)

-- Close Button Logic (FIX)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    error("R-Loader: Key System closed by user. Execution halted.")
end)

-- Dev Bypass Check
task.spawn(function()
    if SpecialUsers[LocalPlayer.UserId] then
        Notify("Dev Bypass", "Special User recognized. Bypassing Key System...")
        KeyInput.Text = "Bypassed for " .. SpecialUsers[LocalPlayer.UserId].Title
        KeyInput.TextEditable = false
        task.wait(0.2)
        Authenticate()
    end
end)

-- Yield execution until key is verified
while not getgenv().RLoader_KeyVerified do
    task.wait(0.1)
end

--// LOAD MAIN LOADER AFTER AUTHENTICATION // --------------------------------------------------
-- // 1. SERVICES & SETUP // ------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Executor Safe Checks & Virtual File System
local makefolder, isfolder, writefile, readfile, isfile, listfiles, delfile, getcustomasset

if DisableFileSystem then
    shared.VirtualFileSystem = shared.VirtualFileSystem or {}
    shared.VirtualFolders = shared.VirtualFolders or {}
    
    makefolder = function(path) shared.VirtualFolders[path] = true end
    isfolder = function(path) return shared.VirtualFolders[path] == true end
    writefile = function(path, data) shared.VirtualFileSystem[path] = data end
    readfile = function(path) return shared.VirtualFileSystem[path] or "" end
    isfile = function(path) return shared.VirtualFileSystem[path] ~= nil end
    listfiles = function(folder)
        local results = {}
        for path, _ in pairs(shared.VirtualFileSystem) do
            if string.find(path, folder, 1, true) then table.insert(results, path) end
        end
        return results
    end
    delfile = function(path) shared.VirtualFileSystem[path] = nil end
    getcustomasset = function(path) return "" end
else
    local env = getgenv and getgenv() or _G
    makefolder = env.makefolder or function() end
    isfolder = env.isfolder or function() return false end
    writefile = env.writefile or function() end
    readfile = env.readfile or function() return "" end
    isfile = env.isfile or function() return false end
    listfiles = env.listfiles or function() return {} end
    delfile = env.delfile or function() end
    getcustomasset = env.getcustomasset or function(path) return path end
end

-- // 2. FILE SYSTEM & CONFIG LOGIC // ---------------------------------------------------------
local SETTINGS_FOLDER = "R-Loader"
local SCRIPT_FOLDER_PATH = SETTINGS_FOLDER .. "/scripts"
local CONFIGS_FOLDER = SETTINGS_FOLDER .. "/configs"
local HOTRELOAD_FILE = SETTINGS_FOLDER .. "/hotreload.txt"
local ASSETS_FOLDER = SETTINGS_FOLDER .. "/assets"
local PINS_FILE = SETTINGS_FOLDER .. "/pinned_tabs.json"
local UI_SETTINGS_FILE = SETTINGS_FOLDER .. "/ui_settings.json"

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
        if DisableAesthetics then return "" end
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
local GreetingsList = {"Hello", "Welcome", "Greetings", "Hey there", "Sup", "Salutations", "Ahoy", "Howdy", "Welcome back", "Good to see you", "Yo", "Hiya", "Welcome aboard", "Nice to see you", "Hey", "What's up", "Welcome, player", "Salute", "G'day", "Welcome, friend"}
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

    if SimplifyAnimations then
        PFP.ImageTransparency = 0
        Line.Size = UDim2.new(0, 150, 0, 2)
        Line.BackgroundTransparency = 0
        NameLabel.Text = introText
        task.wait(1.5)
        IntroGui:Destroy()
    else
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
end

PlayIntro()

-- // 4. EMBEDDED UI LIBRARY // -------------------------------------------------------
-- // 4. EMBEDDED UI LIBRARY (NOW EXTERNAL) // ------------------------------------
local LibContext = {
    theme = theme,
    create = create,
    roundify = roundify,
    addStroke = addStroke,
    tween = tween,
    ScreenGui = ScreenGui,
    SimplifyAnimations = SimplifyAnimations,
    PinnedTabs = PinnedTabs,
    TweenService = TweenService,
    UserInputService = UserInputService,
    UIScale = UIScale
}

-- [USER] Replace this URL with your GitHub raw URL once uploaded
local LIBRARY_URL = "https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/library.lua"
local Library
local success, result = pcall(function() return game:HttpGet(LIBRARY_URL) end)
if success and result and #result > 0 then
    Library = loadstring(result)()(LibContext)
else
    -- Fallback for local execution if you don't use github
    if isfile and isfile("R-Loader/library.lua") then
        Library = loadstring(readfile("R-Loader/library.lua"))()(LibContext)
    else
        warn("Failed to load UI Library. Ensure it is uploaded to GitHub or in the correct local folder.")
        return
    end
end

local Icons = Library.Icons
local Colors = Library.Colors

-- // 5. DATA & SCRIPT CATALOG // --------------------------------------------------------------
local CURRENT_GAME_ID = game.GameId
local GameList = {
    ["Arsenal"] = 111958650,
    ["Anime Last Stand"] = 4509896324,
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

Background_1="https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/Image/Icons/R-loadert-transparent.png"

local FullCatalog = {

    ["Universal"] = {
        {
            Name = "Mana",
            Icon = "https://static-cdn.jtvnw.net/jtv_user_pictures/ad1760c3-166d-4238-a5ab-d20ff38d5cbd-profile_image-70x70.png",
            Description = "ManaV2 universal utility hub.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/Maanaaaa/ManaV2ForRoblox/main/MainScript.lua'))() end)"
        },
        {
            Name = "Infinite Yield",
            Icon = Background_1,
            Description = "The ultimate admin command script with hundreds of commands.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)"
        },
        {
            Name = "R-Loader/Universal",
            Icon = Background_1,
            Description = "Universal version of R-Loader.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/R-loader-universal.lua'))() end)"
        },
        {
            Name = "R-Loader Old UI",
            Icon = Background_1,
            isdown = true,
            Description = "This is the old ui of R-loader if you run into any issues happy exploiting",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/R-Loader-deprecated.lua'))() end)"
        },
    },

    ["Arsenal"] = {
        {
            Name = "Z3US: partially Detected",
            Icon = Background_1,
            Description = "Aimbot, silent aim, and Arsenal utilities. Partially detected.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Arsenal%20Beta.lua'))() end)"
        },
        {
            Name = "Vapa-v2",
            Icon = Background_1,
            Description = "Advanced Arsenal script with combat utilities.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Nickyangtpe/Vapa-v2/refs/heads/main/Vapav2-Arsenal.lua", true))() end)'
        },
    },
    ["Anime Last Stand"] = {
        {
            Name = "R-Loader-ALS Demo",
            Icon = "https://tr.rbxcdn.com/180DAY-e0f69f1a31c02a5838bb9bf2ddbddf7d/512/512/Image/Webp/noFilter",
            Description = "Script for Anime Last Stand with limited features.",
            Load = "pcall(function() loadstring(game:HttpGet('https://github.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/raw/refs/heads/main/scripts/R-Loader-ALS.lua'))() end)"
        },
    },

    ["Rivals"] = {
        {
            Name = "Z3US Rivals",
            Icon = Background_1,
            Description = "Z3US version for Rivals with autoload support.",
            isdown = false,
            Load = [[
                getgenv().autoload = autoloadEnabled
			    pcall(function() loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/8be52e21a0145a401c446ca7ab2b5df9bd327ea80b0cf1d2fe99e442edd0f9c9/download"))() end)
            ]]
        },
        {
            Name = "R-Loader | Rivals Demo",
            Icon = Background_1,
            Description = "R-Loader version for Rivals with aimbot and esp.",
            Load = [[
                getgenv().autoload = autoloadEnabled
                pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/R-Loader-aimDemo.lua", true))() end)
            ]]
        },
    },


    ["Prison Life"] = {
        {
            Name = "DP-HUB",
            Icon = Background_1,
            Description = "Prison Life admin, ESP, combat, and more.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/PrisonLife_DP-HUB.lua'))() end)"
        },
    },

    ["BB Legends"] = {
        {
            Name = "absence-mini",
            Icon = Background_1,
            Description = "Mini version of absence-hub for BB Legends.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/vnausea/absence-mini/refs/heads/main/absencemini.lua'))() end)"
        },
    },
    ["Slayers Battleground"] = {
        {
            Name = "No Cooldown/R-Loader",
            Icon = Background_1,
            Description = "No cooldowns for Slayers Battlegrounds.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/SlayerBattleGrounds.lua'))() end)"
        },
                {
            Name = "Crasher/R-Loader",
            Icon = Background_1,
            Description = "Crashes the game.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/SlayerBattleGroundsCrasher.lua'))() end)"
        },
    },

    ["Build A Boat"] = {
        {
            Name = "Uniqu Hub",
            Icon = Background_1,
            Description = "Multi-game hub including Build A Boat support.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Unique-Hub-(14-Gmes)_521"))() end)'
        },
        {
            Name = "Lexus Hub: partially working/laggy",
            Icon = Background_1,
            Description = "BABFT script with partial features but laggy.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/102KIRA/Best-Babft-script/refs/heads/main/Actually%20Best%20babft%20script"))() end)'
        },
    },

    ["Lucky Blocks"] = {
        {
            Name = "Lucky Blocks",
            Icon = Background_1,
            Description = "Universal Lucky Blocks Battlegrounds script.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/Veaquach/LBBattlegroundsscript/refs/heads/main/Universal%20Lucky%20Block%20Battle%20Grounds%20Script.txt'))() end)"
        },
    },

    ["Legends Of Sd"] = {
        {
            Name = "Legends Of Speed",
            Icon = Background_1,
            Description = "Legends of Speed script with auto-farm and utilities.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/Speed%20legendsFh.lua",true))() end)'
        },
    },

    ["FNAF Eternal Nights"] = {
        {
            Name = "FNAF Eternal Nights",
            Icon = Background_1,
            Description = "FNAF Eternal Nights script pack.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Snipez-Dev/Rbx-Scripts/refs/heads/main/Eternal%20Nights"))() end)'
        },
    },

    ["Nights in the Forest"] = {
        {
            Name = "unknown",
            Icon = Background_1,
            Description = "Luarmor-protected loader for Nights In The Forest.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/c27892d6692ba09d991c09dc9d5ceae1.lua"))() end)'
        },
    },

    ["Doors"] = {
        {
            Name = "Rloader Doors",
            Icon = Background_1,
            Description = "R-Loader version for Doors.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/scripts/Doors_RLoader.lua"))() end)'
        },
        {
            Name = "zynlope-no-ui",
            Icon = Background_1,
            Description = "UI-less Doors script.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/rolezeay/doors/refs/heads/main/hmmmmm"))() end)'
        },
    },

    ["AOTR"] = {
        {
            Name = "Attack on Titan Revolution",
            Icon = Background_1,
            Description = "AOTR Luarmor script loader.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/705e7fe7aa288f0fe86900cedb1119b1.lua"))() end)'
        },
    },

    ["The Forge"] = {
        {
            Name = "Rayfield",
            Icon = Background_1,
            Description = "The Forge script using Rayfield UI.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/LioK251/RbScripts/refs/heads/main/lazyuhub_theforge.lua"))() end)'
        },
        {
            Name = "ForgeHub",
            Icon = Background_1,
            Description = "Utility hub for The Forge.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/TheForgeFH.lua",true))() end)'
        },
        {
            Name = "pepehook-loader",
            Icon = Background_1,
            Description = "Pepehook loader for The Forge.",
            Load = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GiftStein1/pepehook-loader/refs/heads/main/loader.lua"))() end)'
        },
    },

    ["Blade Ball"] = {
        {
            Name = "Akashial",
            Icon = Background_1,
            Description = "Akashial Blade Ball loader.",
            Load = "pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/Akash1al/Blade-Ball-Updated-Script/refs/heads/main/Blade-Ball-Script'))() end)"
        },
        {
            Name = "MixRawwr",
            Icon = Background_1,
            Description = "MixRawwr Blade Ball loader.",
            Load = "pcall(function() loadstring(game:HttpGet('https://pastebin.com/raw/5v3yQUvH',true))() end)"
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
        if DisableAesthetics then return end
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
        -- Pass scriptData.isdown into the ScriptCard arguments
        GameTab:ScriptCard(scriptData.Name, scriptData.Icon, scriptData.Description, scriptData.isdown, function()
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
    
    if DisableAesthetics then
        Window:Notify("Error", "Aesthetics are disabled.")
        return
    end
    
    -- // 1. UNLOAD & VISUAL FEEDBACK //
    if Window.Wallpaper then
        Window.Wallpaper.Image = "" -- Unload current
        Window.Wallpaper.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Dark loading screen
        Window.Wallpaper.BackgroundTransparency = 0.5 -- Semi-transparent
        Window.Wallpaper.Visible = true
    end
    
    Window:Notify("System", "Downloading... (Rejoin Game)")

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