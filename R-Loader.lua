-- // ULTRA-ADVANCED GUI V3 (With Intro Animation) //

-- [[ 1. SERVICE, REFERENCE, AND FILE SYSTEM SETUP ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- PATH DEFINITIONS
local SETTINGS_FOLDER = "R-Loader" 

local SCRIPT_FOLDER_PATH = SETTINGS_FOLDER .. "/scripts"
local CONFIGS_FOLDER = SETTINGS_FOLDER .. "/configs"
local DEFAULT_CONFIG_NAME = "default_config.json"
local LAST_LOADED_FILE = SETTINGS_FOLDER .. "/last_config.txt" 

-- // --- INTRO ANIMATION LOGIC (ADDED) ---
-- This runs before the rest of the script loads
local function PlayIntro()
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "RLoader_Intro"
    IntroGui.Parent = CoreGui
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Background
    local IntroBG = Instance.new("Frame")
    IntroBG.Size = UDim2.new(1, 0, 1, 0)
    IntroBG.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    IntroBG.BackgroundTransparency = 1
    IntroBG.Parent = IntroGui

    -- Center Container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 300, 0, 300)
    Container.Position = UDim2.new(0.5, 0, 0.5, -175)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundTransparency = 1
    Container.Parent = IntroBG

    -- 1. Profile Picture (Starts Invisible)
    local PFP = Instance.new("ImageLabel")
    PFP.Size = UDim2.new(0, 100, 0, 100)
    PFP.Position = UDim2.new(0.5, -50, 0.3, 0)
    PFP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PFP.BackgroundTransparency = 1
    PFP.ImageTransparency = 1 -- Hidden initially
    -- Instant load thumbnail
    PFP.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    PFP.Parent = Container
    
    local PFPCorner = Instance.new("UICorner")
    PFPCorner.CornerRadius = UDim.new(1, 0)
    PFPCorner.Parent = PFP
    
    local PFPStroke = Instance.new("UIStroke")
    PFPStroke.Parent = PFP
    PFPStroke.Transparency = 1
    PFPStroke.Color = Color3.fromRGB(0, 150, 255) -- Accent Blue
    PFPStroke.Thickness = 2

    -- 2. Username Text (Starts Empty for Typewriter)
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0, 30)
    NameLabel.Position = UDim2.new(0, 0, 0.65, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    NameLabel.TextSize = 24
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = "" -- Empty start
    NameLabel.Parent = Container

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, 0, 0, 40)
    MsgLabel.Position = UDim2.new(0, 0, 0.75, 0)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    MsgLabel.TextSize = 24
    MsgLabel.Font = Enum.Font.GothamBold
    MsgLabel.Text = "" -- Empty start
    MsgLabel.Parent = Container
    
    -- 3. Accent Line (Starts Invisible/Small)
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 0, 0, 2) -- Start width 0
    Line.Position = UDim2.new(0.5, 0, 0.75, 0)
    Line.AnchorPoint = Vector2.new(0.5, 0)
    Line.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Line.BorderSizePixel = 0
    Line.BackgroundTransparency = 1
    Line.Parent = Container

--Urls deprecated:
--https://www.avezano.com/cdn/shop/products/AN-2278.jpg

local SpecialUsers = {
    -- clix
    [2335971665] = {
        FirstTime = "Greetings 👑",
        Returning = "Welcome Back!! 👑",
        UserURl = "https://4kwallpapers.com/images/walls/thumbs_3t/14452.jpg"
    },

    -- mixxgaurdian
    [1104273577] = {
        FirstTime = "Welcome, sir ",
        Returning = "Welcome Back, sir ",
        UserURl = "https://www.avezano.com/cdn/shop/products/AN-2278.jpg"

    },
    [4520375383] = {
        FirstTime = "Welcome, dev👤",
        Returning = "Welcome Back dev, 👤",
        UserURl = "https://4kwallpapers.com/images/walls/thumbs_3t/14452.jpg"

    },

}

-- 2. Create the Global Function

_G.UserURl = function()
    local player = game:GetService("Players").LocalPlayer
    
    -- Check if the player exists and is in the table
    if player and SpecialUsers[player.UserId] then
        -- Return their specific URL
        return SpecialUsers[player.UserId].UserURl
    end
end

    local fullText = ""
    local greetingPrefix = ""
    local userFolderExists = false

    -- 1. Check if the folder exists (Status Check)
    if isfolder and isfolder(SETTINGS_FOLDER) then
        userFolderExists = true
    end

    -- 2. Determine the Prefix (Custom vs Default)
    local userData = SpecialUsers[LocalPlayer.UserId]

    if userData then
        -- >> USER IS SPECIAL
        if userFolderExists then
            greetingPrefix = userData.Returning
        else
            greetingPrefix = userData.FirstTime
        end
    else
        -- >> USER IS NORMAL
        if userFolderExists then
            greetingPrefix = "Welcome Back "
        else
            greetingPrefix = "Welcome "
        end
    end

    -- 3. Handle Folder Creation (If they are new, regardless of if they are special)
    if not userFolderExists and makefolder then
        makefolder(SETTINGS_FOLDER)
    end

    -- Construct the final message
    fullText = greetingPrefix .. LocalPlayer.Name .. "!"
    LoadingText="Loading Background..."


    for i = 1, #fullText do
        NameLabel.Text = string.sub(fullText, 1, i)
        -- Randomize typing speed slightly for realism
        task.wait(math.random(5, 10) / 150) 
    end
    
    task.wait(0.2)


    -- Step 2: Fade In PFP
    TweenService:Create(PFP, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
    TweenService:Create(PFPStroke, TweenInfo.new(0.5), {Transparency = 0}):Play()
    task.wait(0.1)

    -- Step 3: Expand & Fade Line
    local lineTween = TweenService:Create(Line, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 2), BackgroundTransparency = 0})
    lineTween:Play()
    lineTween.Completed:Wait()

    task.wait(0.5) -- Hold the visual for a moment

    
    task.wait(0.2)

        for i = 1, #LoadingText do
        NameLabel.Text = string.sub(LoadingText, 1, i)
        -- Randomize typing speed slightly for realism
        task.wait(math.random(5, 10) / 500) 
    end
    
    task.wait(0.2)

    -- Step 4: Fade Out Everything
    local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    TweenService:Create(PFP, fadeInfo, {ImageTransparency = 1}):Play()
    TweenService:Create(PFPStroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(NameLabel, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(Line, fadeInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2)}):Play()
    
    -- Fade background last
    local bgFade = TweenService:Create(IntroBG, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
    bgFade:Play()
    bgFade.Completed:Wait()

    IntroGui:Destroy()
end

-- PLAY THE INTRO
PlayIntro()
-- // --- END OF INTRO ---

--Version
RLoaderV="Version: beta-4gaqg45A"
RLoaderStatus=" Status: 🟢"

-- Placeholder functions for file operations (Requires Executor Support)
local makefolder = makefolder or function(path) warn("makefolder not defined in environment:", path) end
local isfolder = isfolder or function(path) warn("isfolder not defined in environment:", path); return false end
local writefile = writefile or function(path, content) warn("writefile not defined in environment:", path) end
local readfile = readfile or function(path) warn("readfile not defined in environment:", path); return nil end
local isfile = isfile or function(path) warn("isfile not defined in environment:", path); return false end
local listfiles = listfiles or function(path) warn("listfiles not defined in environment:", path); return {} end
local delfile = delfile or function(path) warn("delfile not defined in environment:", path) end

-- Pin Persistence Data
local InitialPinData = {}
local CurrentPinMap = {} 
local SelectedConfigName = DEFAULT_CONFIG_NAME

-- Function to handle folder and file creation
local function SetupFilesystem()
    pcall(function()
        if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end
        if not isfolder(SCRIPT_FOLDER_PATH) then makefolder(SCRIPT_FOLDER_PATH) end
        if not isfolder(CONFIGS_FOLDER) then makefolder(CONFIGS_FOLDER) end
        
        if isfile(LAST_LOADED_FILE) then
            SelectedConfigName = readfile(LAST_LOADED_FILE) or DEFAULT_CONFIG_NAME
        end

        local configFile = CONFIGS_FOLDER .. "/" .. SelectedConfigName
        if isfile(configFile) then
            local content = readfile(configFile)
            if content and content ~= "" then
                InitialPinData = HttpService:JSONDecode(content)
            end
        else
            writefile(configFile, "{}")
        end
    end)
end

SetupFilesystem()

-- // THEME //
local THEME = {
    -- Colors
    Main = Color3.fromRGB(25, 25, 30),
    Sidebar = Color3.fromRGB(35, 35, 40),
    TopBar = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(240, 240, 240),
    Red = Color3.fromRGB(235, 60, 60),
    Green = Color3.fromRGB(60, 235, 100),
    Pin = Color3.fromRGB(255, 215, 0),
    Input = Color3.fromRGB(20, 20, 25),

    -- Transparency Settings (0.0 = Solid, 1.0 = Invisible)
    Transparency = {
        Sidebar = 0.7, -- Make sidebar slightly see-through
        TopBar = 0.7,  -- Make top bar slightly see-through
        Content = 0.5  -- Background for content areas (if used)
    }
}

-- // SCRIPT-LOAD1 //  

-- Configuration
local CURRENT_GAME_ID = game.GameId

-- List of all supported game IDs
local GameList = {
    Arsenal = 286090429,
    Rivals = 6035872082,
    Baseplate = 80461030,
    Emote_RNG = 8313824597,
    Blade_Ball = 4777817887,
    Valley_Prison = 5456952508,
    Lucky_Blocks = 279565647,
    AOTR= 4658598196,
    ERLC = 903807016,
    BB_Legends = 4931927012,
    The_Forge = 7671049560,
    Prison_Life = 73885730,
    Universal = 0 -- fallback for unsupported games
}

-- Detect the current game
local CurrentGame = "Universal" -- default fallback
for gameName, gameId in pairs(GameList) do
    if CURRENT_GAME_ID == gameId then
        CurrentGame = gameName
        break
    end
end


-- Current target variables
local TARGET_GAME_ID = CURRENT_GAME_ID
local TARGET_GAME_NAME = CurrentGame



-- Universal scripts
local test_lua = "loadstring(game:HttpGet('https://raw.githubusercontent.com/test.lua"
local Infinite_yield = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"
local ManaV2 = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Maanaaaa/ManaV2ForRoblox/main/MainScript.lua'))()"

-- Blade Ball Scripts--
Akashial = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Akash1al/Blade-Ball-Updated-Script/refs/heads/main/Blade-Ball-Script'))()"
MixRawwr = "loadstring(game:HttpGet('https://pastebin.com/raw/5v3yQUvH',true))()"


-- [[ 2. GAME CONTENT PARTITIONING (UPDATED WITH TARGETGAME) ]] --
local FullScriptCatalog = {

    ["Universal"] = {
        {
            Name = "Mana",
            Image = "rbxassetid://9868265037",
            Loadable = true,
            scripload = ManaV2
        },
        {
            Name = "Infinite Yield",
            Image = "rbxassetid://115810237733262",
            Loadable = true,
            scripload = Infinite_yield
        },
        {
            Name = "R-Loader/Universal",
            Image = "",
            Loadable = true,
            scripload = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/xkJ8rtl85wxTZ9apvlfQPx7U88r5E3WVZGMoP.lua'))()"
        },

    },

    ["Arsenal"] = {
        {
            Name = "Z3US",
            TargetGame = "Arsenal",
            Image = "",
            Loadable = true,
            scripload = "loadstring(game:HttpGet('https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Arsenal%20Beta.lua'))()"
        },
    },

    ["Baseplate"] = {
        {
            Name = "Baseplate",
            TargetGame = "Baseplate",
            Image = "",
            Loadable = true,
            scripload = test_lua
        },
    },

    ["BB_Legends"] = {
        {
            Name = "absence-mini",
            TargetGame = "BB_Legends",
            Image = "",
            Loadable = true,
            scripload = "loadstring(game:HttpGet('https://raw.githubusercontent.com/vnausea/absence-mini/refs/heads/main/absencemini.lua'))()"
        },
    },

    ["Lucky_Blocks"] = {
        {
            Name = "Lucky Blocks",
            TargetGame = "Lucky_Blocks",
            Image = "",
            Loadable = true,
            scripload = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Veaquach/LBBattlegroundsscript/refs/heads/main/Universal%20Lucky%20Block%20Battle%20Grounds%20Script.txt'))()"
        },
    },

    ["ERLC"] = {
        {
            Name = "Emergency Response: Liberty County",
            TargetGame = "ERLC",
            Image = "",
            Loadable = true,
            scripload = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/xkJ8rtl85wxTZ9apvlfQPx7U88r5E3WVZGMoP.lua'))()"
        },
    },

    ["AOTR"] = {
        {
            Name = "Attack on Titan Revolution",
            TargetGame = "AOTR",
            Image = "",
            Loadable = true,
            scripload = 'loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/705e7fe7aa288f0fe86900cedb1119b1.lua"))()'
        },
    },
    
    ["The_Forge"] = {
        {
            Name = "Rayfield",
            TargetGame = "The_Forge",
            Image = "",
            Loadable = true,
            scripload = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/LioK251/RbScripts/refs/heads/main/lazyuhub_theforge.lua"))()'
        },
        {
            Name = "ForgeHub",
            TargetGame = "The_Forge",
            Image = "",
            Loadable = true,
            scripload = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/jokerbiel13/FourHub/refs/heads/main/TheForgeFH.lua",true))()'
        },

        
    },
    ["Prison_Life"] = {
        {
            Name = "DP-HUB",
            TargetGame = "Prison_Life",
            Image = "",
            Loadable = true,
            scripload = "loadstring(game:HttpGet('https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/LOK83u70UdGWBhj3LwexaiKVy5Q8MJTrxhM6KUz.lua'))()"
        
    },

    ["Valley_Prison"] = {
        {
            Name = "Valley Prison",
            TargetGame = "Valley_Prison",
            Image = "",
            Loadable = false,
            scripload = test_lua
        },
    },


    ["Emote_RNG"] = {
        {
            Name = "Emote RNG BETA",
            TargetGame = "Emote_RNG_BETA",
            Image = "",
            Loadable = false,
            scripload = test_lua
        },
    },

    ["Blade_Ball"] = {
        {
            Name = "Akashial",
            TargetGame = "Blade_Ball",
            Image = "",
            Loadable = true,
            scripload = Akashial
        },
        {
            Name = "MixRawwr",
            TargetGame = "Blade_Ball",
            Image = "",
            Loadable = true,
            scripload = MixRawwr
        },

    },

    ["Rivals"] = {
        {
            Name = "Z3US Rivals",
            TargetGame = "Rivals",
            Image = "",
            Loadable = true,
            scripload = [[
                getgenv().autoload = autoloadEnabled
                loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Rivals%20Beta.lua"))()
            ]]
        },
    },


}

-- This is the new, filtered catalog used by the rest of your script
local ScriptCatalog = {
    ["Universal"] = FullScriptCatalog["Universal"] -- Always include Universal scripts
}

-- Check if the current game is supported (not "Universal" by default)
if TARGET_GAME_NAME ~= "Universal" and FullScriptCatalog[TARGET_GAME_NAME] then
    -- If it is supported, include only those scripts
    ScriptCatalog[TARGET_GAME_NAME] = FullScriptCatalog[TARGET_GAME_NAME]
end

-- // SCRIPT-LOAD2-END //



-- // SCREEN GUI //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R-Loader"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- // BACKGROUND CONFIGURATION //
local BackgroundConfig = {
    Enabled = true, 
    Url = _G.UserURl(), -- Dynamically gets the URL
    Transparency = 0.5 
}

-- // MAIN FRAME //
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- START CLOSED FOR ANIMATION
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- CENTERED
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- CENTER ANCHOR
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
MainFrame.Visible = true -- Start invisible
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- // --- UI BACKGROUND LOGIC (FORCE RELOAD) --- //
if BackgroundConfig.Enabled then
    MainFrame.BackgroundColor3 = THEME.Main 
    MainFrame.BackgroundTransparency = 1 -- Make transparent for image

    task.spawn(function()
        -- 1. Check for Exploit Support
        local getAsset = getgenv().getcustomasset or getgenv().getsynasset
        if not getAsset or not makefolder then 
            MainFrame.BackgroundTransparency = 0 -- Fallback to solid color
            return 
        end

        local BackgroundFileName = "R_Loader_BG_Image.png"
        local filePath = SETTINGS_FOLDER .. "/" .. BackgroundFileName

        -- 2. CLEANUP: Delete the old file if it exists (Forces a refresh)
        if isfile(filePath) then
            delfile(filePath)
        end

        -- 3. DOWNLOAD: Fetch the new image based on the current URL
        if BackgroundConfig.Url and BackgroundConfig.Url ~= "" then
            local success, response = pcall(function() return game:HttpGet(BackgroundConfig.Url) end)
            if success and response then
                writefile(filePath, response)
            end
        end

        -- 4. APPLY: Load the newly downloaded image
        if isfile(filePath) then
            local BG = Instance.new("ImageLabel")
            BG.Name = "UI_Background"
            BG.Size = UDim2.new(1, 0, 1, 0) -- Fills entire frame
            BG.Position = UDim2.new(0, 0, 0, 0)
            BG.BackgroundTransparency = 1
            BG.BorderSizePixel = 0
            BG.ZIndex = 0 
            
            -- THIS IS THE AUTO-RESIZE MAGIC
            BG.ScaleType = Enum.ScaleType.Crop 
            -- Crop: Zooms in to fill space (No black bars, correct aspect ratio)
            
            BG.Parent = MainFrame

            -- Load via custom asset
            local success, assetId = pcall(function() return getAsset(filePath) end)
            if success then
                BG.Image = assetId
            end

            -- 5. Dark Overlay (Tint)
            local Overlay = Instance.new("Frame")
            Overlay.Name = "Tint"
            Overlay.Size = UDim2.new(1, 0, 1, 0)
            Overlay.BackgroundColor3 = THEME.Main 
            Overlay.BackgroundTransparency = BackgroundConfig.Transparency
            Overlay.ZIndex = 0
            Overlay.Parent = MainFrame
        else
            -- Fallback if download failed
            MainFrame.BackgroundTransparency = 0
        end
    end)
else
    MainFrame.BackgroundColor3 = THEME.Main
    MainFrame.BackgroundTransparency = 0
end

-- // TOP BAR //
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = THEME.TopBar
TopBar.BackgroundTransparency = THEME.Transparency.TopBar -- <--- ADD THIS LINE
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local TopPatch = Instance.new("Frame")
TopPatch.Size = UDim2.new(1, 0, 0, 10)
TopPatch.Position = UDim2.new(0, 0, 1, -10)
TopPatch.BackgroundColor3 = THEME.TopBar
TopPatch.BackgroundTransparency = THEME.Transparency.TopBar -- <--- ADD THIS LINE (Must match TopBar)
TopPatch.BorderSizePixel = 0
TopPatch.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Text = "  R-Loader | Target: "..TARGET_GAME_NAME.." [Game-ID: "..CURRENT_GAME_ID..RLoaderStatus.."]"


Title.Size = UDim2.new(1, -60, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = THEME.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = TopBar

-- // DRAGGING //
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- // WINDOW CONTROLS //
local function AddWinButton(text, color, posOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = UDim2.new(1, posOffset, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TopBar
    btn.MouseButton1Click:Connect(callback)
end

-- // --- MODERN NOTIFICATION SYSTEM (SLIDE VARIANT) ---
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Size = UDim2.new(0, 300, 1, -20)
-- POSITION CHANGED: Locked to the Right Side
NotificationHolder.Position = UDim2.new(1, -310, 0, 20) 
NotificationHolder.AnchorPoint = Vector2.new(0, 0)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = ScreenGui 

local NoteLayout = Instance.new("UIListLayout")
NoteLayout.Parent = NotificationHolder
NoteLayout.SortOrder = Enum.SortOrder.LayoutOrder
NoteLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NoteLayout.Padding = UDim.new(0, 10)

local function SendNotification(title, text, duration)
    local duration = duration or 3
    
    -- 1. THE CONTAINER (Invisible - Handles the List Layout spacing)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0) -- Starts with 0 height
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = false -- Crucial: Allows the slide animation to be seen outside the box
    Container.Parent = NotificationHolder

    -- 2. THE VISUAL FRAME (Visible - Handles the Slide Animation)
    local Note = Instance.new("Frame")
    Note.Name = "VisualFrame"
    Note.Size = UDim2.new(1, 0, 1, 0) -- Fills the Container
    Note.Position = UDim2.new(1.5, 0, 0, 0) -- Starts OFF SCREEN (Right side)
    Note.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Note.BorderSizePixel = 0
    Note.Parent = Container
    
    local NoteCorner = Instance.new("UICorner")
    NoteCorner.CornerRadius = UDim.new(0, 6)
    NoteCorner.Parent = Note
    
    -- Accent Line
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = THEME.Accent -- Uses your script's Blue Accent
    Accent.BorderSizePixel = 0
    Accent.Parent = Note
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 6)
    AccentCorner.Parent = Accent
    
    -- Title
    local NoteTitle = Instance.new("TextLabel")
    NoteTitle.Size = UDim2.new(1, -20, 0, 20)
    NoteTitle.Position = UDim2.new(0, 12, 0, 5)
    NoteTitle.BackgroundTransparency = 1
    NoteTitle.Text = title
    NoteTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoteTitle.TextSize = 14
    NoteTitle.Font = Enum.Font.GothamBold
    NoteTitle.TextXAlignment = Enum.TextXAlignment.Left
    NoteTitle.Parent = Note
    
    -- Text
    local NoteText = Instance.new("TextLabel")
    NoteText.Size = UDim2.new(1, -20, 0, 30)
    NoteText.Position = UDim2.new(0, 12, 0, 25)
    NoteText.BackgroundTransparency = 1
    NoteText.Text = text
    NoteText.TextColor3 = Color3.fromRGB(200, 200, 200)
    NoteText.TextSize = 12
    NoteText.Font = Enum.Font.Gotham
    NoteText.TextXAlignment = Enum.TextXAlignment.Left
    NoteText.TextWrapped = true
    NoteText.Parent = Note

    -- // ANIMATION LOGIC //
    -- 1. Expand Container Height (Push other notes up)
    game:GetService("TweenService"):Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)}):Play()
    
    -- 2. Slide Visual Frame In (From Right to Left)
    game:GetService("TweenService"):Create(Note, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    -- Auto Remove
    task.delay(duration, function()
        if Container and Container.Parent then
            -- Slide Out to the Right
            game:GetService("TweenService"):Create(Note, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)}):Play()
            
            -- Collapse Height
            local closeTween = game:GetService("TweenService"):Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            
            task.wait(0.2) -- Slight delay so we see the slide start before it shrinks
            closeTween:Play()
            closeTween.Completed:Wait()
            
            Container:Destroy()
        end
    end)
end

-- // CALLABLE WRAPPER (Global Access) //
getgenv().Notification = function(arg1, arg2, arg3)
    if not arg2 then
        -- Called as Notification("Text Only")
        SendNotification("R-Loader", tostring(arg1), 3)
    else
        -- Called as Notification("Title", "Text", Duration)
        SendNotification(tostring(arg1), tostring(arg2), arg3 or 3)
    end
end

-- // --- MINIMIZE & TOGGLE LOGIC (SMOOTH ANIMATIONS) ---
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- 1. PREPARE MAINFRAME FOR ANIMATION
-- We set AnchorPoint to 0.5, 0.5 so it scales from the center
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
MainFrame.ClipsDescendants = true -- Ensures content hides when shrinking

local UI_Open = false -- Start closed, let the startup anim open it
local Debounce = false -- Prevents spamming keys breaking animations

-- Animation Settings
local OpenTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out) -- "Bouncy" pop open
local CloseTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In) -- Smooth shrink close

-- // TOGGLE FUNCTION
local function ToggleUI(state)
    if Debounce then return end
    Debounce = true
    
    if state then
        -- OPENING
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Start tiny
        
        local openAnim = TweenService:Create(MainFrame, OpenTweenInfo, {Size = UDim2.new(0, 550, 0, 350)}) -- Target Size
        openAnim:Play()
        openAnim.Completed:Wait()
        UI_Open = true
    else
        -- CLOSING/MINIMIZING
        local closeAnim = TweenService:Create(MainFrame, CloseTweenInfo, {Size = UDim2.new(0, 0, 0, 0)}) -- Shrink to 0
        closeAnim:Play()
        closeAnim.Completed:Wait()
        MainFrame.Visible = false
        UI_Open = false
    end
    
    Debounce = false
end

-- // RIGHT Right Shift LISTENER
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Only toggle if Right Shift pressed AND not typing in chat
    if input.KeyCode == Enum.KeyCode.RightShift and not UserInputService:GetFocusedTextBox() then
        ToggleUI(not UI_Open) -- Toggle opposite of current state
    end
end)

-- // MINIMIZE BUTTON (-)
AddWinButton("-", THEME.Text, -60, function()
    ToggleUI(false) -- Trigger Smooth Close
    SendNotification("Hidden", "Press Right Shift to open the menu.", 4)
end)

-- // CLOSE BUTTON (X)
AddWinButton("X", THEME.Red, -30, function()
    if Debounce then return end
    Debounce = true
    
    -- Smooth Close Animation
    local closeAnim = TweenService:Create(MainFrame, CloseTweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
    closeAnim:Play()
    closeAnim.Completed:Wait()
    
    -- Destroy GUI after animation finishes
    ScreenGui:Destroy()
    shared.Mana = nil 
    getgenv().Notification = nil
end)

-- // TABS & CONTAINERS //
local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(0, 110, 1, -30)
TabHolder.Position = UDim2.new(0, 0, 0, 30)
TabHolder.BackgroundColor3 = THEME.Sidebar
TabHolder.BorderSizePixel = 0
TabHolder.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabHolder
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -120, 1, -40)
ContentHolder.Position = UDim2.new(0, 115, 0, 35)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

local Tabs = {}

-- Utility to manage tab sorting
local function ReSortTabs()
    table.sort(Tabs, function(a, b)
        if a.isPinned ~= b.isPinned then
            return a.isPinned -- Pinned (true) comes before unpinned (false)
        else
            return a.Btn.Text < b.Btn.Text
        end
    end)
    
    for i, data in ipairs(Tabs) do
        data.Btn.LayoutOrder = i
    end
end

local function CreateTab(name)
    local Btn = Instance.new("TextButton")
    Btn.Name = name -- Name property is crucial for the Config system
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = THEME.Sidebar
    Btn.Text = name
    Btn.TextColor3 = THEME.SubText
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.Parent = TabHolder

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 1, 0)
    Indicator.BackgroundColor3 = THEME.Accent
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = 1
    Indicator.Parent = Btn
    
    local PinIndicator = Instance.new("Frame") -- New Pin Indicator
    PinIndicator.Size = UDim2.new(0, 8, 0, 8)
    PinIndicator.Position = UDim2.new(1, -12, 0.5, -4)
    PinIndicator.BackgroundColor3 = THEME.Pin
    PinIndicator.Parent = Btn
    Instance.new("UICorner", PinIndicator).CornerRadius = UDim.new(1, 0)

    local Page = Instance.new("Frame")
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentHolder

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Padding = Instance.new("UIPadding")
    Padding.Parent = Page
    Padding.PaddingTop = UDim.new(0, 5)

    -- Pin Logic
    local isPinned = InitialPinData[name] or false
    PinIndicator.Visible = isPinned

    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isPinned = not isPinned
            PinIndicator.Visible = isPinned
            TabData.isPinned = isPinned
            ReSortTabs()
        end
    end)

    -- Selection Logic
    Btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            TweenService:Create(tab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Sidebar, TextColor3 = THEME.SubText}):Play()
            tab.Indicator.BackgroundTransparency = 1
            tab.Page.Visible = false
        end
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,45,50), TextColor3 = THEME.Text}):Play()
        Indicator.BackgroundTransparency = 0
        Page.Visible = true
    end)

    local TabData = {
        Btn = Btn,
        Page = Page,
        Indicator = Indicator,
        isPinned = isPinned,
        PinIndicator = PinIndicator -- Added for external control (Config tab)
    }
    table.insert(Tabs, TabData)
    return Page
end

-- [[ 3. SCRIPT CONTAINER CREATION FUNCTION (UPDATED LOAD STRING) ]] --
local function CreateContainer(pageData, name, scriptImageURL, isLoadable, scripload)
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundColor3 = THEME.TopBar
    Frame.Parent = pageData
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 5)
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    Padding.Parent = Frame
    
    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 1, 0)
    List.BackgroundTransparency = 1
    List.Parent = Frame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.FillDirection = Enum.FillDirection.Horizontal
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = List

    local ImageHolder = Instance.new("Frame")
    ImageHolder.Size = UDim2.new(0, 50, 0, 50)
    ImageHolder.BackgroundTransparency = 1
    ImageHolder.Parent = List
    local DEFAULT_IMAGE_ASSET_ID = "rbxassetid://138544928930772" 

    -- Determine the image to use
    local finalImageURL
    if scriptImageURL and scriptImageURL ~= "" then
    -- Use the provided script image URL
    finalImageURL = scriptImageURL 
    else
    -- Use the default image ID and hide the "NO IMAGE" text
    finalImageURL = DEFAULT_IMAGE_ASSET_ID
    end

    -- ImageDisplay setup
    local ImageDisplay = Instance.new("ImageLabel")
    ImageDisplay.Size = UDim2.new(1, 0, 1, 0)
    ImageDisplay.BackgroundColor3 = THEME.Sidebar
    ImageDisplay.Image = finalImageURL  -- Use the determined URL/ID
    ImageDisplay.ScaleType = Enum.ScaleType.Fit
    ImageDisplay.Parent = ImageHolder
    Instance.new("UICorner", ImageDisplay).CornerRadius = UDim.new(0, 4)

    -- NoImageLabel setup
    local NoImageLabel = Instance.new("TextLabel")
    NoImageLabel.Size = UDim2.new(1, 0, 1, 0)
    NoImageLabel.BackgroundTransparency = 1
    NoImageLabel.Text = "NO IMAGE"
    NoImageLabel.TextColor3 = THEME.SubText
    NoImageLabel.Font = Enum.Font.Gotham
    NoImageLabel.TextSize = 8
    NoImageLabel.TextWrapped = true
    -- Only show the "NO IMAGE" label if the original URL was missing AND we are NOT using the default image
    NoImageLabel.Visible = (not scriptImageURL or scriptImageURL == "") and finalImageURL == ""
    NoImageLabel.Parent = ImageDisplay
 
    local InfoHolder = Instance.new("Frame")
    InfoHolder.Size = UDim2.new(1, -90, 1, 0)
    InfoHolder.BackgroundTransparency = 1
    InfoHolder.Parent = List
    
    local InfoLayout = Instance.new("UIListLayout")
    InfoLayout.Parent = InfoHolder
    InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InfoLayout.Padding = UDim.new(0, 3)
    InfoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    InfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local TitleLabel_Cont = Instance.new("TextLabel")
    TitleLabel_Cont.Text = name
    TitleLabel_Cont.Size = UDim2.new(1, 0, 0, 15)
    TitleLabel_Cont.BackgroundTransparency = 1
    TitleLabel_Cont.TextColor3 = THEME.Text
    TitleLabel_Cont.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel_Cont.Font = Enum.Font.GothamSemibold
    TitleLabel_Cont.TextSize = 14
    TitleLabel_Cont.Parent = InfoHolder
    
    local ControlsStatus = Instance.new("Frame")
    ControlsStatus.Size = UDim2.new(1, 0, 0, 20)
    ControlsStatus.BackgroundTransparency = 1
    ControlsStatus.Parent = InfoHolder
    
    local ControlsStatusLayout = Instance.new("UIListLayout")
    ControlsStatusLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsStatusLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsStatusLayout.Padding = UDim.new(0, 10)
    ControlsStatusLayout.Parent = ControlsStatus
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0, 70, 1, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 12
    StatusLabel.Parent = ControlsStatus
    
    if isLoadable then
        StatusLabel.Text = "LOADABLE"
        StatusLabel.TextColor3 = THEME.Green
    else
        StatusLabel.Text = "DISABLED"
        StatusLabel.TextColor3 = THEME.Red
    end
    
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0, 60, 1, 0)
    LoadBtn.BackgroundColor3 = THEME.Accent
    LoadBtn.Text = "Load"
    LoadBtn.TextColor3 = THEME.Text
    LoadBtn.Font = Enum.Font.Gotham
    LoadBtn.TextSize = 13
    LoadBtn.Parent = ControlsStatus
    Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 4)
    
    local DefaultLoadColor = THEME.Accent
    local HoverLoadColor = Color3.fromRGB(20, 170, 255)

    LoadBtn.MouseEnter:Connect(function()
        TweenService:Create(LoadBtn, TweenInfo.new(0.1), {BackgroundColor3 = HoverLoadColor}):Play()
    end)
    LoadBtn.MouseLeave:Connect(function()
        TweenService:Create(LoadBtn, TweenInfo.new(0.1), {BackgroundColor3 = DefaultLoadColor}):Play()
    end)
    
    LoadBtn.MouseButton1Click:Connect(function()
        if isLoadable and scripload and scripload ~= "" then
            pcall(function()
                loadstring(scripload)() -- Execute the script load string
            end)
            
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification",{ Title="Script Loaded", Text=name.." executed!", Duration=3 })
            end)
        else
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification",{ Title="Cannot Load", Text=name.." is disabled or missing load string!", Duration=3 })
            end)
        end
    end)
end

-- [[ 4. CONFIG TAB CREATION FUNCTION ]] --
-- Utility function to refresh the Configs list from the filesystem
local function GetAvailableConfigs()
    local files = {}
    pcall(function()
        for _, file in ipairs(listfiles(CONFIGS_FOLDER)) do
            if file:find(".json$") then
                table.insert(files, file)
            end
        end
    end)
    return files
end

-- Function to load pin data onto the UI elements
local function ApplyPinsFromData(data)
    for _, tabData in pairs(Tabs) do
        local isPinned = data[tabData.Btn.Name] or false
        tabData.isPinned = isPinned
        tabData.PinIndicator.Visible = isPinned
    end
    ReSortTabs()
end

-- Function to update the Hot-Reload file
local function UpdateHotReloadFile(configName)
    pcall(function()
        writefile(LAST_LOADED_FILE, configName)
    end)
end

local function CreateConfigTab(pageData)
    local Notify
    pcall(function()
        local function showNotification(text, color)
            local NotifyLabel = Instance.new("TextLabel")
            NotifyLabel.Text = text
            NotifyLabel.Size = UDim2.new(0.6, 0, 0, 30)
            NotifyLabel.Position = UDim2.new(0.5, -(MainFrame.Size.X.Offset * 0.3), 1, -40)
            NotifyLabel.BackgroundTransparency = 1
            NotifyLabel.TextColor3 = color
            NotifyLabel.TextXAlignment = Enum.TextXAlignment.Center
            NotifyLabel.Font = Enum.Font.GothamBold
            NotifyLabel.TextSize = 16
            NotifyLabel.ZIndex = 5
            NotifyLabel.Parent = MainFrame
            NotifyLabel.TextTransparency = 1
            
            TweenService:Create(NotifyLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            task.delay(2, function()
                TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.delay(0.5, function() NotifyLabel:Destroy() end)
            end)
        end
        Notify = showNotification
    end)

    local ConfigPanel = Instance.new("Frame")
    ConfigPanel.Size = UDim2.new(1, 0, 1, 0)
    ConfigPanel.BackgroundTransparency = 1
    ConfigPanel.Parent = pageData
    
    local ConfigLayout = Instance.new("UIListLayout")
    ConfigLayout.Parent = ConfigPanel
    ConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ConfigLayout.Padding = UDim.new(0, 10)
    ConfigLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    ----------------------------------------------------------
    -- 1. CONFIG SELECTION SYSTEM
    ----------------------------------------------------------
    local SelectFrame = Instance.new("Frame")
    SelectFrame.Size = UDim2.new(1, 0, 0, 150)
    SelectFrame.BackgroundColor3 = THEME.TopBar
    SelectFrame.Parent = ConfigPanel
    Instance.new("UICorner", SelectFrame).CornerRadius = UDim.new(0, 8)
    
    local ListTitle = Instance.new("TextLabel")
    ListTitle.Text = "Config Selection"
    ListTitle.Size = UDim2.new(1, 0, 0, 20)
    ListTitle.BackgroundTransparency = 1
    ListTitle.TextColor3 = THEME.Accent
    ListTitle.Font = Enum.Font.GothamBold
    ListTitle.TextSize = 14
    ListTitle.Parent = SelectFrame

    local ConfigListBox = Instance.new("ScrollingFrame")
    ConfigListBox.Size = UDim2.new(1, -20, 0, 120)
    ConfigListBox.Position = UDim2.new(0, 10, 0, 25)
    ConfigListBox.BackgroundTransparency = 1
    ConfigListBox.BorderSizePixel = 0
    ConfigListBox.Parent = SelectFrame
    
    local ConfigListLayout = Instance.new("UIListLayout")
    ConfigListLayout.Parent = ConfigListBox
    ConfigListLayout.Padding = UDim.new(0, 5)

    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, 0, 0, 20)
    SelectedLabel.Position = UDim2.new(0, 0, 1, 5)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.TextColor3 = THEME.SubText
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 12
    SelectedLabel.Text = "Selected: "..SelectedConfigName
    SelectedLabel.Parent = SelectFrame

    local function RefreshConfigList()
        for _, child in ipairs(ConfigListBox:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local configs = GetAvailableConfigs()
        for _, name in ipairs(configs) do
            local btn = Instance.new("TextButton")
            btn.Name = name
            btn.Text = name:gsub(".json", "")
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.BackgroundColor3 = (name == SelectedConfigName) and THEME.Accent or THEME.Sidebar
            btn.TextColor3 = THEME.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = ConfigListBox

            btn.MouseButton1Click:Connect(function()
                SelectedConfigName = name
                SelectedLabel.Text = "Selected: "..name
                RefreshConfigList() -- Refresh colors
            end)
        end
        if #configs == 0 then
            SelectedLabel.Text = "Selected: (No Configs)"
            SelectedConfigName = ""
        end
    end
    RefreshConfigList()

    

    ----------------------------------------------------------
    -- 2. ACTIONS FRAME
    ----------------------------------------------------------
    local ActionsFrame = Instance.new("Frame")
    ActionsFrame.Size = UDim2.new(1, 0, 0, 30)
    ActionsFrame.BackgroundTransparency = 1
    ActionsFrame.Parent = ConfigPanel
    
    local ActionsLayout = Instance.new("UIListLayout")
    ActionsLayout.Parent = ActionsFrame
    ActionsLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionsLayout.Padding = UDim.new(0, 5)
    ActionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- LOAD BUTTON
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0.33, -5, 0.7, 0)
    LoadBtn.Text = "Load Config"
    LoadBtn.BackgroundColor3 = THEME.Green
    LoadBtn.TextColor3 = THEME.Text
    LoadBtn.Font = Enum.Font.GothamBold
    LoadBtn.TextSize = 14
    LoadBtn.Parent = ActionsFrame
    Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 4)

    LoadBtn.MouseButton1Click:Connect(function()
        if SelectedConfigName == "" then Notify("Error: No config selected.", THEME.Red) return end
        
        local configFile = CONFIGS_FOLDER .. "/" .. SelectedConfigName
        if isfile(configFile) then
            local content = readfile(configFile)
            if content and content ~= "" then
                local data = HttpService:JSONDecode(content)
                ApplyPinsFromData(data)
                Notify("Config '"..SelectedConfigName.."' loaded successfully.", THEME.Green)
            else
                Notify("Error: Config file is empty.", THEME.Red)
            end
        else
            Notify("Error: Config file not found.", THEME.Red)
        end
    end)
    
    -- OVERWRITE BUTTON
    local OverwriteBtn = Instance.new("TextButton")
    OverwriteBtn.Size = UDim2.new(0.33, -5, 0.7, 0)
    OverwriteBtn.Text = "Overwrite"
    OverwriteBtn.BackgroundColor3 = THEME.Pin
    OverwriteBtn.TextColor3 = THEME.Main
    OverwriteBtn.Font = Enum.Font.GothamBold
    OverwriteBtn.TextSize = 14
    OverwriteBtn.Parent = ActionsFrame
    Instance.new("UICorner", OverwriteBtn).CornerRadius = UDim.new(0, 4)

    OverwriteBtn.MouseButton1Click:Connect(function()
        if SelectedConfigName == "" then Notify("Error: No config selected.", THEME.Red) return end

        local pinMap = {}
        for _, tabData in pairs(Tabs) do
            pinMap[tabData.Btn.Name] = tabData.isPinned
        end
        local content = HttpService:JSONEncode(pinMap)
        
        pcall(function()
            writefile(CONFIGS_FOLDER .. "/" .. SelectedConfigName, content)
            Notify("Config '"..SelectedConfigName.."' overwritten.", THEME.Pin)
        end)
    end)
    
    -- DELETE BUTTON
    local DeleteBtn = Instance.new("TextButton")
    DeleteBtn.Size = UDim2.new(0.35, -5, 0.7, 0)
    DeleteBtn.Text = "Delete"
    DeleteBtn.BackgroundColor3 = THEME.Red
    DeleteBtn.TextColor3 = THEME.Text
    DeleteBtn.Font = Enum.Font.GothamBold
    DeleteBtn.TextSize = 14
    DeleteBtn.Parent = ActionsFrame
    Instance.new("UICorner", DeleteBtn).CornerRadius = UDim.new(0, 4)

    DeleteBtn.MouseButton1Click:Connect(function()
        if SelectedConfigName == "" then Notify("Error: No config selected.", THEME.Red) return end
        if SelectedConfigName == DEFAULT_CONFIG_NAME then Notify("Cannot delete the default config.", THEME.Red) return end

        pcall(function()
            delfile(CONFIGS_FOLDER .. "/" .. SelectedConfigName)
            SelectedConfigName = DEFAULT_CONFIG_NAME -- Reset selection
            Notify("Config '"..SelectedConfigName.."' deleted.", THEME.Red)
        end)
        RefreshConfigList()
    end)
    
    ----------------------------------------------------------
    -- 3. HOT RELOAD TOGGLE
    ----------------------------------------------------------
    local HotReloadFrame = Instance.new("Frame")
    HotReloadFrame.Size = UDim2.new(1, 0, 0, 30)
    HotReloadFrame.BackgroundColor3 = THEME.Sidebar
    HotReloadFrame.Parent = ConfigPanel
    Instance.new("UICorner", HotReloadFrame).CornerRadius = UDim.new(0, 8)

    local HotReloadLabel = Instance.new("TextLabel")
    HotReloadLabel.Text = "Hot Reload selected config on run:"
    HotReloadLabel.Size = UDim2.new(0.7, 0, 1, 0)
    HotReloadLabel.Position = UDim2.new(0, 10, 0, 0)
    HotReloadLabel.BackgroundTransparency = 1
    HotReloadLabel.TextColor3 = THEME.Text
    HotReloadLabel.TextXAlignment = Enum.TextXAlignment.Left
    HotReloadLabel.Font = Enum.Font.Gotham
    HotReloadLabel.TextSize = 14
    HotReloadLabel.Parent = HotReloadFrame
    
    local HotReloadToggle = Instance.new("TextButton")
    HotReloadToggle.Size = UDim2.new(0, 80, 0, 20)
    HotReloadToggle.Position = UDim2.new(1, -90, 0.5, -10)
    HotReloadToggle.Parent = HotReloadFrame
    Instance.new("UICorner", HotReloadToggle).CornerRadius = UDim.new(0, 4)

    local isHotReloading = isfile(LAST_LOADED_FILE) and readfile(LAST_LOADED_FILE) ~= ""
    
    local function UpdateToggleState()
        if isHotReloading then
            HotReloadToggle.Text = "Enabled"
            HotReloadToggle.BackgroundColor3 = THEME.Green
            UpdateHotReloadFile(SelectedConfigName)
        else
            HotReloadToggle.Text = "Disabled"
            HotReloadToggle.BackgroundColor3 = THEME.Red
            UpdateHotReloadFile("") -- Clear the file to disable hot-reload
        end
    end
    
    HotReloadToggle.MouseButton1Click:Connect(function()
        isHotReloading = not isHotReloading
        UpdateToggleState()
        Notify(isHotReloading and "Hot Reload Enabled for: "..SelectedConfigName or "Hot Reload Disabled.", isHotReloading and THEME.Green or THEME.Red)
    end)
    
    UpdateToggleState() 

    ----------------------------------------------------------
    -- 4. NEW CONFIG INPUT
    ----------------------------------------------------------
    local NewConfigFrame = Instance.new("Frame")
    NewConfigFrame.Size = UDim2.new(1, 0, 0, 50)
    NewConfigFrame.BackgroundColor3 = THEME.Sidebar
    NewConfigFrame.Parent = ConfigPanel
    Instance.new("UICorner", NewConfigFrame).CornerRadius = UDim.new(0, 8)
    
    local NewInput = Instance.new("TextBox")
    NewInput.Size = UDim2.new(0.6, -10, 0, 20)
    NewInput.Position = UDim2.new(0, 5, 0.5, -10)
    NewInput.PlaceholderText = "New Config Name (e.g., jump_pins)"
    NewInput.Text = ""
    NewInput.TextColor3 = THEME.Text
    NewInput.BackgroundColor3 = THEME.TopBar
    NewInput.Parent = NewConfigFrame
    
    local CreateBtn = Instance.new("TextButton")
    CreateBtn.Size = UDim2.new(0.4, -10, 0, 20)
    CreateBtn.Position = UDim2.new(0.6, 5, 0.5, -10)
    CreateBtn.Text = "Create & Overwrite"
    CreateBtn.BackgroundColor3 = THEME.Accent
    CreateBtn.TextColor3 = THEME.Text
    CreateBtn.Font = Enum.Font.GothamBold
    CreateBtn.TextSize = 14
    CreateBtn.Parent = NewConfigFrame
    Instance.new("UICorner", CreateBtn).CornerRadius = UDim.new(0, 4)

    CreateBtn.MouseButton1Click:Connect(function()
        local name = NewInput.Text:gsub("[^a-zA-Z0-9_]", "")
        if name == "" then Notify("Error: Invalid config name.", THEME.Red) return end
        
        local fileName = name .. ".json"
        
        SelectedConfigName = fileName
        OverwriteBtn:Click() 
        RefreshConfigList()
        UpdateToggleState() 
        
        NewInput.Text = ""
        Notify("New Config '"..fileName.."' created and saved!", THEME.Green)
    end)
end

-- [[ 5. INITIALIZATION AND SCRIPT POPULATION ]] --

-- Create Tabs based on the Script Catalog Keys
for tabName, scriptList in pairs(ScriptCatalog) do
    local page = CreateTab(tabName)
    -- Add a placeholder to prevent errors if the list is empty
    if #scriptList == 0 then 
        local NoScriptsLabel = Instance.new("TextLabel")
        NoScriptsLabel.Size = UDim2.new(1, 0, 1, 0)
        NoScriptsLabel.BackgroundTransparency = 1
        NoScriptsLabel.Text = "No scripts available"
        NoScriptsLabel.TextColor3 = THEME.SubText
        NoScriptsLabel.Font = Enum.Font.GothamBold
        NoScriptsLabel.TextSize = 18
        NoScriptsLabel.Parent = page
    end

    for _, scriptInfo in ipairs(scriptList) do
        CreateContainer(page, scriptInfo.Name, scriptInfo.Image, scriptInfo.Loadable, scriptInfo.scripload)
    end
end

-- Create the static tabs (Config and Support)
--local ConfigPage = CreateTab("Config")
--CreateConfigTab(ConfigPage)

-- [[ 4. SUPPORT TAB CREATION FUNCTION (REVISED) ]] --
local function CreateSupportTab(pageData)
    
    local Notify
    pcall(function()
        -- Notification function local to the config/support section
        local function showNotification(text, color)
            local NotifyLabel = Instance.new("TextLabel")
            NotifyLabel.Text = text
            NotifyLabel.Size = UDim2.new(0.6, 0, 0, 30)
            NotifyLabel.Position = UDim2.new(0.5, -(MainFrame.Size.X.Offset * 0.3), 1, -40)
            NotifyLabel.BackgroundTransparency = 1
            NotifyLabel.TextColor3 = color
            NotifyLabel.TextXAlignment = Enum.TextXAlignment.Center
            NotifyLabel.Font = Enum.Font.GothamBold
            NotifyLabel.TextSize = 16
            NotifyLabel.ZIndex = 5
            NotifyLabel.Parent = MainFrame
            NotifyLabel.TextTransparency = 1
            
            TweenService:Create(NotifyLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            task.delay(1.5, function()
                TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.delay(0.5, function() NotifyLabel:Destroy() end)
            end)
        end
        Notify = showNotification
    end)
    
    -- Main Info Container
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Size = UDim2.new(1, 0, 0, 260)
    InfoFrame.BackgroundColor3 = THEME.TopBar
    InfoFrame.Parent = pageData
    Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 8)

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = InfoFrame
    Layout.Padding = UDim.new(0, 5)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.Parent = InfoFrame

    local function createInfoLine(text, copyValue, color)
        local Button = Instance.new("TextButton")
        Button.Text = text
        Button.Size = UDim2.new(1, -20, 0, 20)
        Button.BackgroundTransparency = 1
        Button.TextColor3 = color or THEME.Text
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.BorderSizePixel = 0
        Button.Parent = InfoFrame
        
        local DefaultTextColor = color or THEME.Text

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = THEME.Accent, BackgroundTransparency = 0.9}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = DefaultTextColor, BackgroundTransparency = 1}):Play()
        end)
        
        if copyValue then
            Button.MouseButton1Click:Connect(function()
                local success = pcall(function()
                    setclipboard(copyValue) 
                end)
                
                if success then
                    Notify("Copied: '"..copyValue.."'!", THEME.Green)
                else
                    Notify("Error: setclipboard not available.", THEME.Red)
                end
            end)
        end

        return Button
    end
    -- Title Section
    createInfoLine("🛠️ R-Loader Support Information", nil, THEME.Accent).Font = Enum.Font.GothamBold
    
    -- Version Info
    createInfoLine(RLoaderV)
        createInfoLine("Config-status(❌)")
    -- Developer Contacts
    createInfoLine("Developer: Mix/R-Loader", "Mix/R-Loader")
    createInfoLine("Discord Invite: discord.gg/LoaderCommunity", "https://discord.gg/fveV8thB", THEME.Green)
    createInfoLine("Why tf dont you have this: https://ublockorigin.com", "https://ublockorigin.com", THEME.Red)
    createInfoLine("Avoid increasing suicide rates: https://bypass.vip", "https://bypass.vip", THEME.Red)

    createInfoLine("Right-Click Tab to Pin/Unpin", nil, THEME.SubText)
    createInfoLine("Config Tab to Save/Load Pin States", nil, THEME.SubText)
    local DevBot2 = CURRENT_GAME_ID
    createInfoLine("GameID: "..DevBot2, DevBot2, THEME.Accent)
end

local SupportPage = CreateTab("Help/Support")
CreateSupportTab(SupportPage)

-- Apply initial pin data and sorting
ReSortTabs()


-- [[ NEW MAIN TAB CREATION FUNCTION (FINAL REVISION - USING createInfoLine) ]] --
local function CreateMainTab(name)
    -- Utility function to show notifications (Necessary for copy/paste feedback)
    local function Notify(text, color)
        pcall(function()
            local NotifyLabel = Instance.new("TextLabel")
            NotifyLabel.Text = text
            NotifyLabel.Size = UDim2.new(0.6, 0, 0, 10)
            NotifyLabel.Position = UDim2.new(0.5, -(MainFrame.Size.X.Offset * 0.3), 1, -40)
            NotifyLabel.BackgroundTransparency = 1
            NotifyLabel.TextColor3 = color
            NotifyLabel.TextXAlignment = Enum.TextXAlignment.Center
            NotifyLabel.Font = Enum.Font.GothamBold
            NotifyLabel.TextSize = 16
            NotifyLabel.ZIndex = 5
            NotifyLabel.Parent = MainFrame
            NotifyLabel.TextTransparency = 1
            
            TweenService:Create(NotifyLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            task.delay(1.5, function()
                TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.delay(0.5, function() NotifyLabel:Destroy() end)
            end)
        end)
    end
    
    local Btn = Instance.new("TextButton")
    Btn.Name = name 
    Btn.LayoutOrder = -100 
    Btn.Size = UDim2.new(1, 0, 0, 45) 
    Btn.BackgroundColor3 = THEME.Sidebar
    Btn.Text = "" 
    Btn.TextColor3 = THEME.SubText
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.Parent = TabHolder

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 1, 0)
    Indicator.BackgroundColor3 = THEME.Accent
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = 1
    Indicator.Parent = Btn
    
    local PinIndicator = Instance.new("Frame") 
    PinIndicator.Size = UDim2.new(0, 0, 0, 0) 
    PinIndicator.Visible = false
    PinIndicator.Parent = Btn

    local player = game.Players.LocalPlayer
    -- refined to use rbxthumb (instant load, higher quality, no yielding)
    local thumbUrl = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"

    -- Profile Picture (Tab Button)
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 30, 0, 30)
    AvatarImage.Position = UDim2.new(0, 8, 0.5, -15)
    AvatarImage.BackgroundColor3 = THEME.Input
    AvatarImage.Image = thumbUrl
    AvatarImage.Parent = Btn
    Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

    -- Username Label
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Text = LocalPlayer.Name
    UsernameLabel.Size = UDim2.new(1, -50, 0, 15) 
    UsernameLabel.Position = UDim2.new(0, 42, 0.5, -10) 
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.TextColor3 = THEME.Text
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextSize = 10
    UsernameLabel.Parent = Btn
    
    -- Status/Version Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Status: Online"
    StatusLabel.Size = UDim2.new(1, -50, 0, 15)
    StatusLabel.Position = UDim2.new(0, 42, 0.5, 3) 
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = THEME.Accent
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 10
    StatusLabel.Parent = Btn

  
    local Page = Instance.new("Frame")
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentHolder

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Padding = Instance.new("UIPadding")
    Padding.Parent = Page
    Padding.PaddingTop = UDim.new(0, 5)

    ----------------------------------------------------------
    -- 1. UTILITY FOR COPY/PASTE LINES (Local Definition)
    ----------------------------------------------------------
    local function createInfoLine(text, copyValue, color)
        local Button = Instance.new("TextButton")
        Button.Text = text
        Button.Size = UDim2.new(1, 0, 0, 20) -- Full width, no extra padding
        Button.BackgroundTransparency = 1
        Button.TextColor3 = color or THEME.Text
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.BorderSizePixel = 0
        Button.Parent = Page -- Parented directly to the page (using PageLayout)
        
        local DefaultTextColor = color or THEME.Text

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = THEME.Accent, BackgroundTransparency = 0.9}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = DefaultTextColor, BackgroundTransparency = 1}):Play()
        end)
        
        if copyValue then
            Button.MouseButton1Click:Connect(function()
                local success = pcall(function()
                    setclipboard(copyValue) 
                end)
                
                if success then
                    Notify("Copied: '"..copyValue.."'!", THEME.Green)
                else
                    Notify("Error: setclipboard not available.", THEME.Red)
                end
            end)
        end

        return Button
    end
    
    ----------------------------------------------------------
    -- 2. PAGE CONTENT
    ----------------------------------------------------------
    
    -- Welcome Label (Updated to just a simple label)
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Text = "Welcome to "..RLoaderV
    WelcomeLabel.Size = UDim2.new(1, 0, 0, 30)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.TextColor3 = THEME.Text
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.TextSize = 16
    WelcomeLabel.Parent = Page

    -- User Profile Frame
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, 0, 0, 50)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Page
    
    local ProfileLayout = Instance.new("UIListLayout")
    ProfileLayout.FillDirection = Enum.FillDirection.Horizontal
    ProfileLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ProfileLayout.Padding = UDim.new(0, 10)
    ProfileLayout.Parent = ProfileFrame
    
    local PageAvatar = Instance.new("ImageLabel")
    PageAvatar.Size = UDim2.new(0, 40, 0, 40)
    PageAvatar.BackgroundColor3 = THEME.Input
    PageAvatar.Image = thumbUrl -- Use the same resolved URL
    PageAvatar.Parent = ProfileFrame
    Instance.new("UICorner", PageAvatar).CornerRadius = UDim.new(1, 0)
    
    local WelcomeUserText = Instance.new("TextLabel")
    WelcomeUserText.Text = "Hello, " .. LocalPlayer.Name
    WelcomeUserText.Size = UDim2.new(1, -60, 1, 0)
    WelcomeUserText.BackgroundTransparency = 1
    WelcomeUserText.TextColor3 = THEME.Accent
    WelcomeUserText.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeUserText.Font = Enum.Font.GothamBold
    WelcomeUserText.TextSize = 18
    WelcomeUserText.Parent = ProfileFrame

    -- Description
    createInfoLine("--- DESCRIPTION ---", nil, THEME.SubText).Font = Enum.Font.GothamBold
    createInfoLine("R-Loader "..RLoaderV.." is a stable, persistent, and modular scripting solution.", nil, THEME.SubText).TextSize = 10
    createInfoLine("Use the tabs for game-specific scripts and the Config tab to save pin layouts.", nil, THEME.SubText).TextSize = 10

    -- Contact Info (Using createInfoLine)
    local DiscordTag = "mixapire"
    local KingsTab = "ewkobe"
    local RLoaderCommunity = "R-Loader Community"
    local DiscordInvite = "https://discord.gg/8UNFGpyn"
    createInfoLine("--- CONTACT INFO ---", nil, THEME.SubText).Font = Enum.Font.GothamBold
    createInfoLine("👤Dev-Tag: "..DiscordTag, DiscordTag, THEME.Green).TextSize = 13
    createInfoLine("👑King's-Tag: "..KingsTab, KingsTab, THEME.Green).TextSize = 13
    createInfoLine("Discord Invite: "..RLoaderCommunity, DiscordInvite, THEME.Accent).TextSize = 13



    ----------------------------------------------------------
    -- END OF PAGE CONTENT
    ----------------------------------------------------------

    -- The Main tab cannot be pinned or unpinned via right-click, so we skip that logic.
    local isPinned = true

    -- Selection Logic (Same as other tabs)
    Btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            TweenService:Create(tab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Sidebar, TextColor3 = THEME.SubText}):Play()
            tab.Indicator.BackgroundTransparency = 1
            tab.Page.Visible = false
        end
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,45,50), TextColor3 = THEME.Text}):Play()
        Indicator.BackgroundTransparency = 0
        Page.Visible = true
    end)

    local TabData = {
        Btn = Btn,
        Page = Page,
        Indicator = Indicator,
        isPinned = isPinned,
        PinIndicator = PinIndicator
    }
    table.insert(Tabs, TabData)
    return Page
end

-- 1. Create the fixed Main Tab FIRST
local MainPage = CreateMainTab("Main")
ReSortTabs()

-- Open the first tab 
if Tabs[1] then
    local ActiveColor = Color3.fromRGB(45,45,50)
    Tabs[1].Btn.BackgroundColor3 = ActiveColor
    Tabs[1].Btn.TextColor3 = THEME.Text
    Tabs[1].Indicator.BackgroundTransparency = 0
    Tabs[1].Page.Visible = true
end

-- // --- TRIGGER OPEN ANIMATION AFTER INTRO FINISHES ---
ToggleUI(true)
