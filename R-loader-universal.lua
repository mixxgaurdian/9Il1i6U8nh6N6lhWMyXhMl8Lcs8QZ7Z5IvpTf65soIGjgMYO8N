-- // 1. SERVICES & SETUP // ------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Camera = workspace.CurrentCamera
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
local mousemoverel = mousemoverel or (Input and Input.MouseMove) or function() end

-- // CONFIGURATION // -----------------------------------------------------------------------
--// DEVELOPERS //-- Whitelisted IDs
local WhitelistedIds = {
    [901694101] = true, -- Replace with actual IDs
    [87654321] = true,
}

-- Features that are COMPLETELY DISABLED (Red, Unclickable) per game
local GameSpecificConfigs = {
    [9356971415] = {"Fly", "Noclip"}, 
    [1234567890] = {"Instant Teleport"},
    [5456952508] = {"Fly", "Noclip"},
    [5114901609] = {"Local Loop (Stick)","Local Bring All Loop"}, 
}

local GlobalBetaFeatures = {
    "FE Bring (object fix coming soon)",
}

getgenv().KeySystemEnabled = true  -- Enable/Disable Key System
getgenv().TempKey = "TEMP-KEY-2025"

-- // STATE MANAGEMENT // ---------------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Core = game:GetService("CoreGui")

-- State Tables
getgenv().DisabledFeatures = {}
getgenv().BetaFeatures = {}

-- Helper: Check Permissions
local function IsUserWhitelisted()
    if LocalPlayer and WhitelistedIds[LocalPlayer.UserId] then return true end
    return false
end

-- [FUNCTION 1] DISABLE SYSTEM (Priority: High - Blocks Usage)
getgenv().DisableFeature = function(featureName, shouldDisable)
    if shouldDisable and IsUserWhitelisted() then shouldDisable = false end 
    getgenv().DisabledFeatures[featureName] = shouldDisable
    
    -- Visual Update
    if Core:FindFirstChild("RLoader_Universal_Remaster") then
        local UI = Core["RLoader_Universal_Remaster"]
        for _, obj in pairs(UI:GetDescendants()) do
            if obj:IsA("TextLabel") and (obj.Text == featureName or obj.Text:find(featureName)) then
                if shouldDisable then
                    obj.Text = featureName .. " (Disabled)"
                    obj.TextColor3 = Color3.fromRGB(150, 50, 50) 
                else

                    if getgenv().BetaFeatures[featureName] then
                        getgenv().SetBetaStatus(featureName, true)
                    else
                        obj.Text = featureName
                        obj.TextColor3 = Color3.fromRGB(230, 230, 240)
                    end
                end
            end
        end
    end
end

-- [FUNCTION 2] BETA/KEY SYSTEM (Priority: Medium - Warns User)
getgenv().SetBetaStatus = function(featureName, isBeta)
    getgenv().BetaFeatures[featureName] = isBeta

    -- If the feature is currently Disabled, do NOT update visuals (Red overrides Yellow)
    if getgenv().DisabledFeatures[featureName] then return end

    -- Visual Update
    if Core:FindFirstChild("RLoader_Universal_Remaster") then
        local UI = Core["RLoader_Universal_Remaster"]
        for _, obj in pairs(UI:GetDescendants()) do
            if obj:IsA("TextLabel") and (obj.Text == featureName or obj.Text:find(featureName)) then
                if isBeta then
                    if getgenv().KeySystemEnabled then
                        obj.Text = featureName .. " (Locked)"
                        obj.TextColor3 = Color3.fromRGB(255, 140, 0) -- Orange
                    else
                        obj.Text = featureName .. " (Beta)"
                        obj.TextColor3 = Color3.fromRGB(255, 215, 0) -- Yellow
                    end
                else
                    -- Reset to normal
                    obj.Text = featureName
                    obj.TextColor3 = Color3.fromRGB(230, 230, 240)
                end
            end
        end
    end
end

-- // INITIALIZATION // -----------------------------------------------------------------------
-- 1. Apply Game Specific Disables
local currentPlaceId = game.PlaceId
if GameSpecificConfigs[currentPlaceId] then
    for _, feature in pairs(GameSpecificConfigs[currentPlaceId]) do
        getgenv().DisableFeature(feature, true)
    end
end

-- 2. Apply Global Beta Features
for _, feature in pairs(GlobalBetaFeatures) do
    getgenv().SetBetaStatus(feature, true)
end

-- // 2. CONFIGURATION DATA // ------------------------------------
local Config = {
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Smoothness = 5,
        FOV = 300,
        TargetPart = "Head", 
        TargetMode = "Head", 
        Range = 2000, -- [NEW] Max Distance
        ObjectLockon = false,
        TeamCheck = false,
        HealthDetach = false, -- [NEW] Stop locking when dead
        Whitelist = {}
    },
    ESP = {
        Enabled = false,
        Fullbrightness = 0,
        Fill = {R=175, G=25, B=25},
        Outline = {R=255, G=255, B=255},
        ShowNames = true,
        ShowObjects = false,
        ObjectMode = "Interactable",
        Fullbright = false,
        WallClip = false,
        WallClipTrans = 0.5,
        Tracers = false,
        Boxes = false,
        Health = false,
    },
    Movement = {
        PhaseDist = 10,
        SavedCFrame = nil, 
        IntervalSpeed = 0.05,
        FlySpeed = 50,
        WalkSpeed = 16,
        JumpPower = 50,
        SafeFlySpeed = 50,
        InstantTP = false,
        NoGravSpeed = 50,
        BringSpeed = 75,
    },
    Fun = { 
        Time = 12,
        Rain = false,
        Snow= false,
    },
    Misc = {
        AntiVoid = false,
        AntiVoidHeight = -50,
        ContactInfo = "Discord: Rloader_Community",
        ContactInfolink = "https://discord.gg/MaJPqA6k",
    },
    Binds = {
        ToggleUI = Enum.KeyCode.M,
        Phase = Enum.KeyCode.F,
        SavePos = Enum.KeyCode.H,
        Teleport = Enum.KeyCode.J,
        Fly = Enum.KeyCode.V,
        Noclip = Enum.KeyCode.B,
        CarFly = Enum.KeyCode.Unknown, -- [NEW]
        SafeFly = Enum.KeyCode.Unknown,
        Speed = Enum.KeyCode.Unknown,
        Jump = Enum.KeyCode.Unknown,
        NoGravity = Enum.KeyCode.Unknown,
        ESP = Enum.KeyCode.Unknown,
        WallClip = Enum.KeyCode.Unknown,
        Fullbright = Enum.KeyCode.Unknown,
        Aimbot = Enum.KeyCode.Unknown,
        Rain = Enum.KeyCode.Unknown,
        Snow = Enum.KeyCode.Unknown,
    },
    Toggles = {
        Fly = false,
        Noclip = false,
        Speed = false,
        Jump = false,
        SafeFly = false,
    }
}

-- Forward Declaration for AntiVoid function
local UpdateAntiVoid = nil 

-- Apply Game Configs
local currentGameId = game.GameId
local configToApply = GameSpecificConfigs[currentGameId]

if configToApply then
    task.delay(1, function() 
        if Window and Window.Notify then
            Window:Notify("System", "Restricted features disabled for this game.") 
        end
    end)
    for _, featureName in ipairs(configToApply) do
        DisableFeature(featureName, true)
        if Config.Toggles[featureName] ~= nil then Config.Toggles[featureName] = false end
    end
end


-- CONFIG SYSTEM
local FolderName = "R-Loader_Config"
local FileName = "Universal_Settings.json"

local function SaveConfig()
    if not makefolder then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    
    local SaveData = {
        Aimbot = Config.Aimbot,
        ESP = Config.ESP,
        Movement = Config.Movement,
        Toggles = Config.Toggles,
        Misc = Config.Misc,
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
        
        local function SafeLoad(category, key, value)
            if DisabledFeatures[key] then return end
            if Config[category] and Config[category][key] ~= nil then
                Config[category][key] = value
            end
        end

        if decoded.Aimbot then 
            for k,v in pairs(decoded.Aimbot) do SafeLoad("Aimbot", k, v) end 
            if decoded.Aimbot.Whitelist then Config.Aimbot.Whitelist = decoded.Aimbot.Whitelist end
        end
        if decoded.ESP then for k,v in pairs(decoded.ESP) do SafeLoad("ESP", k, v) end end
        if decoded.Movement then for k,v in pairs(decoded.Movement) do SafeLoad("Movement", k, v) end end
        if decoded.Misc then for k,v in pairs(decoded.Misc) do SafeLoad("Misc", k, v) end end
        
        if decoded.Toggles then 
            for k,v in pairs(decoded.Toggles) do 
                if not DisabledFeatures[k] then Config.Toggles[k] = v end
            end 
        end

        if decoded.Binds then
            for name, keyName in pairs(decoded.Binds) do
                if Enum.KeyCode[keyName] then
                    Config.Binds[name] = Enum.KeyCode[keyName]
                end
            end
        end
        
        -- [[ FIX: Activate AntiVoid if it was saved as true ]] --
        if Config.Misc.AntiVoid and UpdateAntiVoid then
            UpdateAntiVoid(true)
        end
    end
end

-- // 3. UI LIBRARY (REMASTERED & ADAPTED) // -----------------------------------------------
local Library = (function()
    local UILibrary = {}
    local SearchableElements = {} 

    local theme = {
        Background = Color3.fromRGB(15, 15, 20), Sidebar = Color3.fromRGB(20, 20, 25),
        Header = Color3.fromRGB(25, 25, 30), Panel = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(138, 100, 255), AccentHover = Color3.fromRGB(158, 120, 255),
        ButtonBg = Color3.fromRGB(35, 35, 40), ButtonHover = Color3.fromRGB(45, 45, 50), 
        Text = Color3.fromRGB(240, 240, 245), TextDim = Color3.fromRGB(160, 160, 170), 
        Border = Color3.fromRGB(50, 50, 60), Error = Color3.fromRGB(255, 80, 80),
        Success = Color3.fromRGB(80, 255, 120), Font = Enum.Font.GothamMedium
    }

    local function create(class, props)
        local obj = Instance.new(class)
        for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
        if props.Parent then obj.Parent = props.Parent end
        return obj
    end
    
    local function roundify(obj, radius) create("UICorner", {CornerRadius = UDim.new(0, radius or 4), Parent = obj}) end
    local function addStroke(obj, color) create("UIStroke", {Color = color or theme.Border, Thickness = 1, Parent = obj}) end
    local function tween(obj, props, t) TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

    function UILibrary:CreateWindow(config)
        local title = config.Title or "UI"
        local isMinimized = false

        local ScreenGui = create("ScreenGui", {Name = "RLoader_Universal_Remaster", Parent = (gethui and gethui()) or CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 10000, IgnoreGuiInset = true})
        
        local Container = create("Frame", {
            Size = UDim2.new(0, 650, 0, 450), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.Background, BackgroundTransparency = 0.05, Parent = ScreenGui, ClipsDescendants = true
        })
        roundify(Container, 10); addStroke(Container, theme.Border)

        -- [[ LAYOUT SETUP (MOVED UP) ]] --
        -- We create Sidebar and ContentArea FIRST so the search bar can access them
        local Header = create("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = theme.Header, Parent = Container})
        roundify(Header, 10)
        create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = theme.Header, Parent = Header, BorderSizePixel=0})
        
        local Sidebar = create("ScrollingFrame", {Size = UDim2.new(0, 140, 1, -40), Position = UDim2.new(0,0,0,40), BackgroundColor3 = theme.Sidebar, Parent = Container, ScrollBarThickness = 2, BorderSizePixel = 0})
        create("UIListLayout", {Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})
        create("UIPadding", {Parent = Sidebar, PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,5)})

        local ContentArea = create("Frame", {Size = UDim2.new(1, -150, 1, -50), Position = UDim2.new(0, 145, 0, 45), BackgroundTransparency = 1, Parent = Container})

        -- [[ HEADER CONTENTS ]] --
        create("TextLabel", {
            Text = title, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
        })

        -- [[ SEARCH BAR ]] --
        local SearchBg = create("Frame", {
            Size = UDim2.new(0, 200, 0, 26), Position = UDim2.new(0.5, -100, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = theme.Sidebar, Parent = Header
        })
        roundify(SearchBg, 6); addStroke(SearchBg, theme.Border)
        
        local SearchBox = create("TextBox", {
            Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 25, 0, 0), BackgroundTransparency = 1,
            Text = "", PlaceholderText = "Search features...", TextColor3 = theme.Text, PlaceholderColor3 = theme.TextDim,
            Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = SearchBg
        })
        create("ImageLabel", {
            Image = "rbxassetid://6031154871", Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,6,0.5,-7),
            BackgroundTransparency = 1, ImageColor3 = theme.TextDim, Parent = SearchBg
        })

        -- [[ SEARCH LOGIC (NARROW DOWN) ]] --
        local SearchResults = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Visible = false, Parent = ContentArea,
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent
        })
        create("UIListLayout", {Parent = SearchResults, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
        create("UIPadding", {Parent = SearchResults, PaddingTop = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

        SearchBox.Changed:Connect(function(prop)
            if prop == "Text" then
                local query = SearchBox.Text:lower()
                if #query > 0 then
                    -- Hide tabs, Show Search
                    for _, v in pairs(ContentArea:GetChildren()) do if v ~= SearchResults then v.Visible = false end end
                    SearchResults.Visible = true
                    
                    -- Clear Old
                    for _, v in pairs(SearchResults:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end

                    -- Find Matches
                    for _, item in pairs(SearchableElements) do
                        if item.Name:lower():find(query) then
                            if item.Type == "Button" then
                                local Btn = create("TextButton", {Text = item.Name, Size = UDim2.new(1,0,0,28), BackgroundColor3 = theme.ButtonBg, TextColor3 = theme.Text, Font = theme.Font, TextSize = 12, Parent = SearchResults}); roundify(Btn, 4)
                                Btn.MouseButton1Click:Connect(function() 
                                    tween(Btn, {BackgroundColor3 = theme.AccentHover}, 0.1); task.wait(0.1); tween(Btn, {BackgroundColor3 = theme.ButtonBg}, 0.1)
                                    item.Callback() 
                                end)
                            elseif item.Type == "Toggle" then
                                local state = Config.Toggles[item.Name] or false
                                if item.CurrentState ~= nil then state = item.CurrentState end
                                local Frame = create("TextButton", {Text = "", Size = UDim2.new(1,0,0,28), BackgroundColor3 = theme.ButtonBg, AutoButtonColor = false, Parent = SearchResults}); roundify(Frame, 4)
                                local Label = create("TextLabel", {Text = item.Name, Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Frame})
                                local Indicator = create("Frame", {Size=UDim2.new(0,18,0,18), Position=UDim2.new(1,-24,0.5,-9), BackgroundColor3 = state and theme.Accent or theme.Panel, Parent=Frame}); roundify(Indicator, 4)
                                Frame.MouseButton1Click:Connect(function()
                                    if DisabledFeatures[item.Name] then WindowObj:Notify("Restricted", item.Name.." disabled."); return end
                                    state = not state
                                    tween(Indicator, {BackgroundColor3 = state and theme.Accent or theme.Panel}, 0.2); tween(Label, {TextColor3 = state and theme.Text or theme.TextDim}, 0.2)
                                    if item.UpdateFunc then item.UpdateFunc(state) end
                                    if item.Callback then item.Callback(state) end
                                    SaveConfig()
                                end)
                            end
                        end
                    end
                else
                    -- Empty Search: Hide
                    SearchResults.Visible = false
                    -- Auto-show first tab if nothing visible
                    local anyVisible = false
                    for _, v in pairs(ContentArea:GetChildren()) do if v.Visible then anyVisible = true break end end
                    if not anyVisible and #ContentArea:GetChildren() > 1 then ContentArea:GetChildren()[1].Visible = true end
                end
            end
        end)

        -- Control Buttons
        local CloseBtn = create("TextButton", {Text = "X", Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-35,0,5), BackgroundTransparency = 1, TextColor3 = theme.Error, Font = Enum.Font.GothamBold, TextSize = 14, Parent = Header})
        local MinBtn = create("TextButton", {Text = "_", Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-65,0,5), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = Enum.Font.GothamBold, TextSize = 14, Parent = Header})

        CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
        MinBtn.MouseButton1Click:Connect(function()
            Container.Visible = false
            -- Optional: Notify the user how to get it back
            if WindowObj and WindowObj.Notify then
                WindowObj:Notify("System", "UI Hidden. Press Keybind to open.")
            end
        end)

        -- Dragging
        local dragging, dragInput, dragStart, startPos
        Header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Container.Position end end)
        UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and input == dragInput then local delta = input.Position - dragStart; tween(Container, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05) end end)
        Header.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

        local NotifyFrame = create("Frame", {Size = UDim2.new(0, 250, 1, -150), Position = UDim2.new(1, -260, 0, 20), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100})
        create("UIListLayout", {Parent = NotifyFrame, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})
        
        local WindowObj = {ScreenGui = ScreenGui, Container = Container} 

        function WindowObj:Notify(title, msg)
            local N = create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1})
            roundify(N, 6); addStroke(N, theme.Accent)
            create("TextLabel", {Text = title, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 2), BackgroundTransparency = 1, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = N})
            create("TextLabel", {Text = msg, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 10, 0, 20), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = theme.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = N})
            N.Position = UDim2.new(1, 0, 0, 0)
            tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
            task.delay(4, function() tween(N, {Position = UDim2.new(1.2, 0, 0, 0), BackgroundTransparency = 1}, 0.5); task.wait(0.5); N:Destroy() end)
        end
        
        UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.KeyCode == Config.Binds.ToggleUI then Container.Visible = not Container.Visible end end)

        function WindowObj:CreateCategory(name, icon)
            local TabBtn = create("TextButton", {Text = "  " .. (icon or "") .. " " .. name, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Sidebar, BorderSizePixel = 0, AutoButtonColor = false})
            roundify(TabBtn, 6)

            local TabFrame = create("ScrollingFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 3, Parent = ContentArea, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarImageColor3 = theme.Accent})
            create("UIListLayout", {Parent = TabFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})
            create("UIPadding", {Parent = TabFrame, PaddingRight = UDim.new(0,5), PaddingLeft = UDim.new(0,0), PaddingTop = UDim.new(0,2)})

            TabBtn.MouseButton1Click:Connect(function()
                for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then tween(v, {BackgroundTransparency = 1, TextColor3 = theme.TextDim}, 0.2) end end
                for _,v in pairs(ContentArea:GetChildren()) do v.Visible = false end
                tween(TabBtn, {BackgroundTransparency = 0.8, BackgroundColor3 = theme.Accent, TextColor3 = theme.Accent}, 0.2); TabFrame.Visible = true
            end)
            
            if name == "Main" or name == "Home" then tween(TabBtn, {BackgroundTransparency = 0.8, BackgroundColor3 = theme.Accent, TextColor3 = theme.Accent}, 0.2); TabFrame.Visible = true end

            local TabObj = {ScrollFrame = TabFrame}

            function TabObj:Label(text) create("TextLabel", {Text = text, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFrame}) end
            
            function TabObj:Profile()
                local PFrame = create("Frame", {Size = UDim2.new(1,0,0,80), BackgroundColor3 = theme.ButtonBg, Parent = TabFrame}); roundify(PFrame, 6); addStroke(PFrame, theme.Border)
                local PfpImg = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
                local Img = create("ImageLabel", {Size=UDim2.new(0,60,0,60), Position=UDim2.new(0,10,0,10), BackgroundColor3=theme.Panel, Image=PfpImg, Parent=PFrame}); roundify(Img, 30); addStroke(Img, theme.Accent)
                create("TextLabel", {Text = LocalPlayer.DisplayName, Size=UDim2.new(0,200,0,20), Position=UDim2.new(0,80,0,15), BackgroundTransparency=1, TextColor3=theme.Text, Font=Enum.Font.GothamBold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left, Parent=PFrame})
                create("TextLabel", {Text = "@" .. LocalPlayer.Name, Size=UDim2.new(0,200,0,15), Position=UDim2.new(0,80,0,35), BackgroundTransparency=1, TextColor3=theme.TextDim, Font=theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=PFrame})
                create("TextLabel", {Text = "Status: Undetected", Size=UDim2.new(0,200,0,15), Position=UDim2.new(0,80,0,52), BackgroundTransparency=1, TextColor3=theme.Success, Font=theme.Font, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, Parent=PFrame})
                local ContactBtn = create("TextButton", {
                    Text = Config.Misc.ContactInfo or "Discord: N/A", 
                    Size = UDim2.new(0, 130, 0, 20), 
                    Position = UDim2.new(1, -145, 0, 55), 
                    BackgroundTransparency = 1, 
                    TextColor3 = theme.Accent, 
                    Font = theme.Font, 
                    TextSize = 10, 
                    Parent = PFrame
                })

                -- Hover Effects (Green on hover, theme Accent on leave)
                ContactBtn.MouseEnter:Connect(function() tween(ContactBtn, {TextColor3 = Color3.fromRGB(80, 255, 120)}, 0.2) end)
                ContactBtn.MouseLeave:Connect(function() tween(ContactBtn, {TextColor3 = theme.Accent}, 0.2) end)

                ContactBtn.MouseButton1Click:Connect(function() setclipboard(Config.Misc.ContactInfolink); WindowObj:Notify("System", "Contact info copied!") end)
            end
                function TabObj:Button(text, callback)
                local Btn = create("TextButton", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.ButtonBg,
                    TextColor3 = theme.Text,
                    Font = theme.Font,
                    TextSize = 12,
                    Parent = TabFrame
                })
                roundify(Btn, 4)

                -- [[ 1. VISUAL SETUP ]]
                if getgenv().DisabledFeatures[text] then
                    if IsUserWhitelisted() then
                        -- DEV: Green & Accessible
                        Btn.Text = text .. " (Dev Access)"
                        Btn.TextColor3 = Color3.fromRGB(80, 255, 120) -- Green
                    else
                        -- USER: Red & Disabled
                        Btn.Text = text .. " (Disabled)"
                        Btn.TextColor3 = Color3.fromRGB(150, 50, 50) -- Red
                    end
                elseif getgenv().BetaFeatures[text] then
                    if getgenv().KeySystemEnabled then
                        if IsUserWhitelisted() then
                            -- DEV: Cyan & Accessible
                            Btn.Text = text .. " (Dev Access)"
                            Btn.TextColor3 = Color3.fromRGB(0, 255, 200) -- Cyan
                        else
                            -- USER: Orange & Locked
                            Btn.Text = text .. " (Locked)"
                            Btn.TextColor3 = Color3.fromRGB(255, 140, 0) -- Orange
                        end
                    else
                        Btn.Text = text .. " (Beta)"
                        Btn.TextColor3 = Color3.fromRGB(255, 215, 0) -- Yellow
                    end
                end

                -- [[ 2. CLICK LOGIC ]]
                Btn.MouseButton1Click:Connect(function()
                    -- A. Check Hard Disable
                    if getgenv().DisabledFeatures[text] then
                        if IsUserWhitelisted() then
                            --WindowObj:Notify("Dev User", "Bypassing Disable...")
                            -- BYPASS: Continue to execution
                        else
                           -- WindowObj:Notify("Restricted", text .. " is disabled for this game.")
                            return -- STOP EXECUTION
                        end
                    end

                    -- B. Check Key Lock
                    if getgenv().BetaFeatures[text] and getgenv().KeySystemEnabled then
                        if IsUserWhitelisted() then
                            --WindowObj:Notify("Dev User", "Bypassing Key Lock...")
                            -- BYPASS: Continue to execution
                        else
                            WindowObj:Notify("Locked", "To unlock this feature, use the key: Join the Discord")
                            return -- STOP EXECUTION
                        end
                    end

                    -- C. Check Beta Warning
                    if getgenv().BetaFeatures[text] and not getgenv().KeySystemEnabled then
                        WindowObj:Notify("Beta Feature", "Warning: Bugs may occur.")
                    end

                    -- D. Execute Normal
                    tween(Btn, {BackgroundColor3 = theme.AccentHover}, 0.1)
                    task.wait(0.1)
                    tween(Btn, {BackgroundColor3 = theme.ButtonBg}, 0.1)
                    callback()
                end)
                
                table.insert(SearchableElements, {Name = text, Type = "Button", Callback = callback})
                return Btn
            end

            function TabObj:Toggle(text, default, callback)
                local state = default
                local Frame = create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.ButtonBg,
                    AutoButtonColor = false,
                    Parent = TabFrame
                })
                roundify(Frame, 4)
                
                local Label = create("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.Text,
                    Font = theme.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local Indicator = create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -24, 0.5, -9),
                    BackgroundColor3 = default and theme.Accent or theme.Panel,
                    Parent = Frame
                })
                roundify(Indicator, 4)

                -- [[ 1. VISUAL SETUP ]]
                if getgenv().DisabledFeatures[text] then
                    if IsUserWhitelisted() then
                         -- DEV: Green & Accessible
                        Label.Text = text .. " (Dev Access)"
                        Label.TextColor3 = Color3.fromRGB(80, 255, 120) -- Green
                    else
                        -- USER: Red & Disabled
                        Label.Text = text .. " (Disabled)"
                        Label.TextColor3 = Color3.fromRGB(150, 50, 50) -- Red
                    end
                elseif getgenv().BetaFeatures[text] then
                    if getgenv().KeySystemEnabled then
                        if IsUserWhitelisted() then
                            -- DEV: Cyan & Accessible
                            Label.Text = text .. " (Dev Access)"
                            Label.TextColor3 = Color3.fromRGB(0, 255, 200) -- Cyan
                        else
                            -- USER: Orange & Locked
                            Label.Text = text .. " (Locked)"
                            Label.TextColor3 = Color3.fromRGB(255, 140, 0) -- Orange
                        end
                    else
                        Label.Text = text .. " (Beta)"
                        Label.TextColor3 = Color3.fromRGB(255, 215, 0) -- Yellow
                    end
                end

                local function UpdateVisual(s)
                    tween(Indicator, {BackgroundColor3 = s and theme.Accent or theme.Panel}, 0.2)
                    tween(Label, {TextColor3 = s and theme.Text or theme.TextDim}, 0.2)
                end

                -- [[ 2. CLICK LOGIC ]]
                Frame.MouseButton1Click:Connect(function()
                    -- A. Check Hard Disable
                    if getgenv().DisabledFeatures[text] then
                        if IsUserWhitelisted() then
                            --WindowObj:Notify("Dev User", "Bypassing Disable...")
                            -- BYPASS
                        else
                            WindowObj:Notify("Restricted", text .. " is disabled.")
                            return -- STOP EXECUTION
                        end
                    end

                    -- B. Check Key Lock
                    if getgenv().BetaFeatures[text] and getgenv().KeySystemEnabled then
                        if IsUserWhitelisted() then
                            --WindowObj:Notify("Dev User", "Bypassing Key Lock...")
                            -- BYPASS
                        else
                            WindowObj:Notify("Locked", "To unlock this feature, use the key: Join the Discord")
                            return -- STOP EXECUTION
                        end
                    end

                    -- C. Check Beta Warning
                    if getgenv().BetaFeatures[text] and not getgenv().KeySystemEnabled then
                        WindowObj:Notify("Beta Feature", "Warning: Bugs may occur.")
                    end

                    state = not state
                    UpdateVisual(state)
                    callback(state)
                    SaveConfig()
                end)
                
                table.insert(SearchableElements, {Name = text, Type = "Toggle", Callback = callback, CurrentState = default, UpdateFunc = UpdateVisual})
                return Frame
            end
            function TabObj:Slider(text, min, max, default, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = theme.ButtonBg, Parent = TabFrame}); roundify(Frame, 4)
                create("TextLabel", {Text = text, Size=UDim2.new(1,-10,0,15), Position=UDim2.new(0,10,0,5), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
                local ValueLabel = create("TextLabel", {Text = tostring(default), Size=UDim2.new(0,40,0,15), Position=UDim2.new(1,-45,0,5), BackgroundTransparency=1, TextColor3=theme.TextDim, Font=theme.Font, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, Parent=Frame})
                local SliderBar = create("TextButton", {Text="", Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,28), BackgroundColor3=theme.Panel, AutoButtonColor=false, Parent=Frame}); roundify(SliderBar, 2)
                local Fill = create("Frame", {Size=UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3=theme.Accent, Parent=SliderBar}); roundify(Fill, 2)
                local dragging = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                    local val = math.floor(min + ((max-min) * pos)); if max < 5 then val = math.floor((min + ((max-min) * pos))*100)/100 end
                    ValueLabel.Text = tostring(val); callback(val)
                end
                SliderBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false; SaveConfig() end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            end

            function TabObj:Binder(text, defaultKey, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,28), BackgroundColor3 = theme.ButtonBg, Parent = TabFrame}); roundify(Frame, 4)
                create("TextLabel", {Text = text, Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
                local BindBtn = create("TextButton", {Text = defaultKey.Name, Size=UDim2.new(0,80,0,20), Position=UDim2.new(1,-90,0.5,-10), BackgroundColor3=theme.Panel, TextColor3=theme.TextDim, Font=theme.Font, TextSize=11, Parent=Frame}); roundify(BindBtn, 4)
                BindBtn.MouseButton1Click:Connect(function()
                    BindBtn.Text = "..."; BindBtn.TextColor3 = theme.Accent
                    local input = UserInputService.InputBegan:Wait()
                    if input.UserInputType == Enum.UserInputType.Keyboard then BindBtn.Text = input.KeyCode.Name; BindBtn.TextColor3 = theme.TextDim; callback(input.KeyCode); SaveConfig() else BindBtn.Text = defaultKey.Name end
                end)
            end

            function TabObj:Dropdown(text, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,28), BackgroundColor3 = theme.ButtonBg, Parent = TabFrame, ClipsDescendants=true}); roundify(Frame, 4)
                local Header = create("TextButton", {Text = text .. " ▼", Size = UDim2.new(1,0,0,28), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=12, Parent=Frame})
                local List = create("ScrollingFrame", {Size=UDim2.new(1,0,0,100), Position=UDim2.new(0,0,0,28), BackgroundTransparency=1, Parent=Frame, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2}); create("UIListLayout", {Parent=List})
                local function Refresh()
                    for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            local OptBtn = create("TextButton", {Text = p.Name, Size = UDim2.new(1,0,0,25), BackgroundColor3 = theme.Panel, BackgroundTransparency=0.5, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 11, Parent = List})
                            OptBtn.MouseButton1Click:Connect(function() callback(p.Name); Header.Text = text .. " ["..p.Name.."] ▼"; tween(Frame, {Size = UDim2.new(1,0,0,28)}, 0.2) end)
                        end
                    end
                end
                local open = false
                Header.MouseButton1Click:Connect(function() open = not open; if open then Refresh(); tween(Frame, {Size = UDim2.new(1,0,0, 130)}, 0.2) else tween(Frame, {Size = UDim2.new(1,0,0,28)}, 0.2) end end)
            end
            return TabObj
        end
        return WindowObj, theme
    end
    return UILibrary
end)()

-- // 4. WINDOW CREATION // -------------------------------------------------------------------
local Window, Theme = Library:CreateWindow({Title = "R-Loader | Universal"})

-- // MAIN TAB (UPDATED) //
local MainTab = Window:CreateCategory("Main", "🏠")
MainTab:Profile()
MainTab:Label("System Information")
MainTab:Button("Copy Game ID", function() setclipboard(tostring(game.GameId)); Window:Notify("System", "Game ID Copied!") end)
MainTab:Button("Force Unload UI", function() SaveConfig(); Window.ScreenGui:Destroy() end)

local CombatTab = Window:CreateCategory("Combat", "🎯")
local VisualsTab = Window:CreateCategory("Visuals", "👁️")
local MoveTab = Window:CreateCategory("Movement", "💨")
local TPTab = Window:CreateCategory("Players", "👥")
local FunTab = Window:CreateCategory("Fun", "🎉")
local MiscTab = Window:CreateCategory("Misc", "⚙️")
local KeybindsTab = Window:CreateCategory("Binds", "⌨️")

-- [[ MODULAR CMD SYSTEM ]] --
local CMD_Enabled = false
local CMD_Frame, CMD_Input, CMD_Scroll = nil, nil, nil
local CommandList = {} 

getgenv().CMD_Add = function(name, desc, callback)
    for i, cmd in pairs(CommandList) do
        if cmd.name == name:lower() then table.remove(CommandList, i) break end
    end
    table.insert(CommandList, {name = name:lower(), desc = desc, func = callback})
end

local function ParseCommand(text)
    local args = {}
    for word in text:gmatch("%S+") do table.insert(args, word) end
    local cmd = table.remove(args, 1)
    return cmd and cmd:lower() or "", args
end

getgenv().ToggleCMDMode = function(state)
    CMD_Enabled = state
    if Window and Window.Container then Window.Container.Visible = not state end

    if state then
        if not CMD_Frame then
            local Screen = Window.ScreenGui
            CMD_Frame = Instance.new("Frame", Screen)
            CMD_Frame.Name = "CMD_Bar"
            CMD_Frame.Size = UDim2.new(0, 300, 0, 35)
            CMD_Frame.Position = UDim2.new(1, -310, 1, -45) 
            CMD_Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            Instance.new("UICorner", CMD_Frame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", CMD_Frame).Color = Color3.fromRGB(138, 100, 255)
            
            CMD_Input = Instance.new("TextBox", CMD_Frame)
            CMD_Input.Size = UDim2.new(1, -20, 1, 0); CMD_Input.Position = UDim2.new(0, 10, 0, 0)
            CMD_Input.BackgroundTransparency = 1; CMD_Input.Text = ""; CMD_Input.PlaceholderText = "Type 'ui' to exit..."
            CMD_Input.TextColor3 = Color3.fromRGB(255, 255, 255); CMD_Input.Font = Enum.Font.Code; CMD_Input.TextSize = 14
            CMD_Input.TextXAlignment = Enum.TextXAlignment.Left

            CMD_Scroll = Instance.new("ScrollingFrame", CMD_Frame)
            CMD_Scroll.Size = UDim2.new(1, 0, 0, 0); CMD_Scroll.Position = UDim2.new(0, 0, 0, 0)
            CMD_Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25); CMD_Scroll.BackgroundTransparency = 0.1
            CMD_Scroll.Visible = false; CMD_Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Instance.new("UICorner", CMD_Scroll).CornerRadius = UDim.new(0, 6)
            Instance.new("UIListLayout", CMD_Scroll).SortOrder = Enum.SortOrder.LayoutOrder

            local function UpdateSuggestions(filter)
                for _, v in pairs(CMD_Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                local count = 0
                for _, cmd in pairs(CommandList) do
                    if filter == "" or cmd.name:find(filter:lower()) then
                        count = count + 1
                        local btn = Instance.new("TextButton", CMD_Scroll)
                        btn.Size = UDim2.new(1, -10, 0, 25); btn.BackgroundTransparency = 1
                        btn.Text = "  " .. cmd.name .. "  -  " .. (cmd.desc or ""); btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code; btn.TextSize = 13
                        btn.MouseButton1Click:Connect(function() CMD_Input.Text = cmd.name .. " "; CMD_Input:CaptureFocus() end)
                    end
                end
                local height = math.min(count * 25 + 10, 250)
                CMD_Scroll.Size = UDim2.new(1, 0, 0, height); CMD_Scroll.Position = UDim2.new(0, 0, 0, -height - 5)
                CMD_Scroll.Visible = (count > 0)
            end

            CMD_Frame.MouseEnter:Connect(function() UpdateSuggestions(CMD_Input.Text) end)
            CMD_Frame.MouseLeave:Connect(function() if not CMD_Input:IsFocused() then CMD_Scroll.Visible = false end end)
            CMD_Input.Focused:Connect(function() UpdateSuggestions(CMD_Input.Text) end)
            CMD_Input.Changed:Connect(function(p) if p == "Text" then UpdateSuggestions(CMD_Input.Text) end end)
            
            CMD_Input.FocusLost:Connect(function(enter) 
                if not enter then CMD_Scroll.Visible = false; return end
                local cmdName, args = ParseCommand(CMD_Input.Text)
                local found = false
                for _, cmd in pairs(CommandList) do
                    if cmd.name == cmdName then
                        local msg = cmd.func(args); Window:Notify("CMD", msg); found = true; break
                    end
                end
                if not found and cmdName ~= "" then Window:Notify("Error", "Unknown: " .. cmdName) end
                CMD_Input.Text = ""; CMD_Scroll.Visible = false
            end)
        end
        CMD_Frame.Visible = true
        Window:Notify("CMD", "Type 'ui' to exit")
    else
        if CMD_Frame then CMD_Frame.Visible = false end
        if Window and Window.Container then Window.Container.Visible = true end
    end
end

CMD_Add("ui", "Restore Main UI", function() ToggleCMDMode(false); return "Restoring UI..." end)
CMD_Add("exit", "Restore Main UI", function() ToggleCMDMode(false); return "Restoring UI..." end)

-- // MAIN TAB //
MainTab:Label("Description:")
MainTab:Label("Not Found: To Mr.Simms I CANT Fu*cking Find The Color to change it back so cry")

-- // COMBAT TAB //
local TgtBtn
CombatTab:Slider("Aimbot Range", 100, 5000, Config.Aimbot.Range, function(v) Config.Aimbot.Range = v end) -- [NEW]
CombatTab:Toggle("Aimbot Enabled", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
TgtBtn = CombatTab:Button("Target Mode: " .. Config.Aimbot.TargetMode, function()
    if Config.Aimbot.TargetMode == "Head" then Config.Aimbot.TargetMode = "Body"
    elseif Config.Aimbot.TargetMode == "Body" then Config.Aimbot.TargetMode = "Both"
    else Config.Aimbot.TargetMode = "Head" end
    TgtBtn.Text = "Target Mode: " .. Config.Aimbot.TargetMode
end)

CombatTab:Toggle("Team Check", Config.Aimbot.TeamCheck or false, function(v) Config.Aimbot.TeamCheck = v end)
CombatTab:Toggle("Health Detach", Config.Aimbot.HealthDetach, function(v) Config.Aimbot.HealthDetach = v end) -- [NEW]
CombatTab:Toggle("Object Lockon", Config.Aimbot.ObjectLockon, function(v) Config.Aimbot.ObjectLockon = v end)
CombatTab:Slider("Smoothness", 1, 20, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end)
CombatTab:Slider("FOV Size", 50, 800, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
CombatTab:Label("Whitelist Player:")
CombatTab:Dropdown("Select to Whitelist", function(name) Config.Aimbot.Whitelist[name] = true; SaveConfig() end)
CombatTab:Button("Clear Whitelist", function() Config.Aimbot.Whitelist = {}; Window:Notify("System", "Whitelist Cleared") end)

-- // VISUALS TAB //
local Lighting = game:GetService("Lighting")
local OriginalLighting = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient }
local FullbrightLoop = nil

local function ToggleFullbright(state)
    if state then
        if not FullbrightLoop then
            FullbrightLoop = RunService.RenderStepped:Connect(function()
                Lighting.Brightness = Config.ESP.Fullbrightness
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end)
        end
    else
        if FullbrightLoop then FullbrightLoop:Disconnect(); FullbrightLoop = nil end
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

VisualsTab:Toggle("ESP Enabled", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
VisualsTab:Toggle("Show Names", Config.ESP.ShowNames, function(v) Config.ESP.ShowNames = v end)
VisualsTab:Toggle("Show Objects", Config.ESP.ShowObjects, function(v) Config.ESP.ShowObjects = v end)
VisualsTab:Toggle("Show Boxes", Config.ESP.Boxes, function(v) Config.ESP.Boxes = v end)
VisualsTab:Toggle("Show Tracers", Config.ESP.Tracers, function(v) Config.ESP.Tracers = v end)
VisualsTab:Toggle("Show Health", Config.ESP.Health, function(v) Config.ESP.Health = v end)
local ObjBtn
ObjBtn = VisualsTab:Button("Obj Mode: " .. Config.ESP.ObjectMode, function()
    if Config.ESP.ObjectMode == "Interactable" then Config.ESP.ObjectMode = "Tools"
    elseif Config.ESP.ObjectMode == "Tools" then Config.ESP.ObjectMode = "NPCs" 
    elseif Config.ESP.ObjectMode == "NPCs" then Config.ESP.ObjectMode = "All"
    else Config.ESP.ObjectMode = "Interactable" end
    ObjBtn.Text = "Obj Mode: " .. Config.ESP.ObjectMode
end)

VisualsTab:Slider("Fullbright Level", 0, 10, Config.ESP.Fullbrightness, function(v) Config.ESP.Fullbrightness = v end)
VisualsTab:Toggle("Enable Fullbright", Config.ESP.Fullbright, function(v) Config.ESP.Fullbright = v; ToggleFullbright(v) end)

-- WALL CLIP UI
VisualsTab:Label("--- Wall Clip (Hybrid) ---")
VisualsTab:Toggle("Enable Wall Clip", Config.ESP.WallClip, function(v) Config.ESP.WallClip = v end)
VisualsTab:Slider("Opacity Level", 0, 1, Config.ESP.WallClipTrans, function(v) Config.ESP.WallClipTrans = v end)
VisualsTab:Button("Reset All Walls", function() getgenv().WallClip_Reset = true; Window:Notify("System", "Restoring walls...") end)

-- // MOVEMENT TAB //
local isTeleporting = false
local function ResetMovement()
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root then root.Anchored = false; root.AssemblyLinearVelocity = Vector3.zero end
        if hum then hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

MoveTab:Label("--- Vehicle ---")

local CarFlyCon = nil
local CarFlySpeed = 50 

MoveTab:Slider("Car Fly Speed", 10, 300, CarFlySpeed, function(v)
    CarFlySpeed = v
end)

-- [[ GLOBAL CAR FLY FUNCTION ]] --
getgenv().ToggleCarFly = function(state)
    if state then
        -- START CAR FLY
        CarFlyCon = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            
            if hum and hum.SeatPart then
                local seat = hum.SeatPart
                local vehicleModel = seat:FindFirstAncestorWhichIsA("Model")
                local rootPart = vehicleModel and (vehicleModel.PrimaryPart or seat)
                
                if rootPart and vehicleModel then
                    -- 1. UN-ANCHOR & NOCLIP
                    rootPart.Anchored = false
                    for _, part in pairs(vehicleModel:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    
                    -- 2. MOVEMENT CALCULATION
                    local camCF = workspace.CurrentCamera.CFrame
                    local moveDir = Vector3.zero
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                    
                    -- 3. APPLY VELOCITY (Replicates to Server)
                    if moveDir.Magnitude > 0 then
                        rootPart.AssemblyLinearVelocity = moveDir.Unit * CarFlySpeed
                    else
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
                    end
                    rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
        Window:Notify("System", "Car Fly Enabled")
    else
        -- STOP CAR FLY
        if CarFlyCon then CarFlyCon:Disconnect(); CarFlyCon = nil end
        Window:Notify("System", "Car Fly Disabled")
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.SeatPart then
            local vehicleModel = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
            local rootPart = vehicleModel and (vehicleModel.PrimaryPart or hum.SeatPart)
            
            -- RESTORE COLLISIONS & VELOCITY
            if vehicleModel then
                for _, part in pairs(vehicleModel:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            if rootPart then
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end

MoveTab:Toggle("Car Fly (Velocity)", false, function(v) ToggleCarFly(v) end)

MoveTab:Toggle("Enable Speed", Config.Toggles.Speed, function(v) 
    Config.Toggles.Speed = v 
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 
    end
end)
MoveTab:Slider("WalkSpeed", 16, 200, Config.Movement.WalkSpeed, function(v) Config.Movement.WalkSpeed = v end)

MoveTab:Toggle("Enable Jump", Config.Toggles.Jump, function(v) 
    Config.Toggles.Jump = v 
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)
MoveTab:Slider("JumpPower", 50, 300, Config.Movement.JumpPower, function(v) Config.Movement.JumpPower = v end)


MoveTab:Label("--- Teleportation ---")
MoveTab:Slider("Phase Distance", 1, 50, Config.Movement.PhaseDist, function(v) Config.Movement.PhaseDist = v end)
MoveTab:Button("Phase Forward (Bind: F)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local targetCFrame = Camera.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist)
        root.CFrame = CFrame.new(targetCFrame.Position) * root.CFrame.Rotation
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

MoveTab:Toggle("Instant Teleport", Config.Movement.InstantTP, function(v) if DisabledFeatures["Instant Teleport"] then return end Config.Movement.InstantTP = v end)
MoveTab:Button("Save Position (Bind: H)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Window:Notify("System", "Position Saved")
    end
end)

MoveTab:Button("Teleport to Saved (Bind: J)", function()
    if not Config.Movement.SavedCFrame then Window:Notify("Error", "No Saved Pos!"); return end
    if Config.Movement.InstantTP then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Config.Movement.SavedCFrame
            Window:Notify("System", "Teleported Instantly")
        end
        return
    end
    isTeleporting = true
    Window:Notify("System", "Teleporting...")
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
MoveTab:Slider("TP Speed Interval", 0.01, 1, Config.Movement.IntervalSpeed, function(v) Config.Movement.IntervalSpeed = v end)

-- // PLAYER TELEPORT & LOGS TAB //
local TPPage = TPTab.ScrollFrame -- FIX: Reference the ScrollFrame inside the tab object
local isTPingToPlayer = false
local liveUpdateEnabled = true

-- Switch Buttons (List vs Logs)
local SwitchContainer = Instance.new("Frame", TPPage)
SwitchContainer.Size = UDim2.new(1, 0, 0, 35); SwitchContainer.BackgroundTransparency = 1
local ListLayout = Instance.new("UIListLayout", SwitchContainer)
ListLayout.FillDirection = Enum.FillDirection.Horizontal; ListLayout.Padding = UDim.new(0, 10)

local ModeListBtn = Instance.new("TextButton", SwitchContainer)
ModeListBtn.Size = UDim2.new(0.5, -5, 1, 0); ModeListBtn.BackgroundColor3 = Theme.Accent; ModeListBtn.Text = "Player List"; ModeListBtn.TextColor3 = Theme.Text; ModeListBtn.Font = Theme.Font
Instance.new("UICorner", ModeListBtn).CornerRadius = UDim.new(0, 6)

local ModeLogsBtn = Instance.new("TextButton", SwitchContainer)
ModeLogsBtn.Size = UDim2.new(0.5, -5, 1, 0); ModeLogsBtn.BackgroundColor3 = Theme.ButtonBg; ModeLogsBtn.Text = "Logs"; ModeLogsBtn.TextColor3 = Theme.TextDim; ModeLogsBtn.Font = Theme.Font
Instance.new("UICorner", ModeLogsBtn).CornerRadius = UDim.new(0, 6)

-- Containers
local ListContainer = Instance.new("ScrollingFrame", TPPage)
ListContainer.Size = UDim2.new(1, 0, 0, 300); ListContainer.BackgroundTransparency = 1; ListContainer.Visible = true
ListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y; ListContainer.ScrollBarThickness = 4; ListContainer.ScrollBarImageColor3 = Theme.Accent

local LogsContainer = Instance.new("ScrollingFrame", TPPage)
LogsContainer.Size = UDim2.new(1, 0, 0, 300); LogsContainer.BackgroundTransparency = 1; LogsContainer.Visible = false
LogsContainer.ScrollBarThickness = 4; LogsContainer.ScrollBarImageColor3 = Theme.Accent; LogsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
local LogsLayout = Instance.new("UIListLayout", LogsContainer); LogsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Logic
ModeListBtn.MouseButton1Click:Connect(function() 
    ListContainer.Visible = true; LogsContainer.Visible = false
    ModeListBtn.BackgroundColor3 = Theme.Accent; ModeListBtn.TextColor3 = Theme.Text
    ModeLogsBtn.BackgroundColor3 = Theme.ButtonBg; ModeLogsBtn.TextColor3 = Theme.TextDim 
end)
ModeLogsBtn.MouseButton1Click:Connect(function() 
    ListContainer.Visible = false; LogsContainer.Visible = true
    ModeListBtn.BackgroundColor3 = Theme.ButtonBg; ModeListBtn.TextColor3 = Theme.TextDim
    ModeLogsBtn.BackgroundColor3 = Theme.Accent; ModeLogsBtn.TextColor3 = Theme.Text 
end)

-- [[ 1. TELEPORT LOGIC ]] --
local function TeleportToPlayer(targetPlayer)
    if isTPingToPlayer then isTPingToPlayer = false; Window:Notify("System", "TP Stopped"); ResetMovement(); return end
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then Window:Notify("Error", "Player invalid!"); return end
    
    if Config.Movement.InstantTP then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            Window:Notify("System", "Arrived Instantly")
        end
        return
    end

    isTPingToPlayer = true
    Window:Notify("System", "Going to: " .. targetPlayer.Name)
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
        Window:Notify("System", "Arrived!")
    end)
end

local function RefreshPlayerList()
    for _, v in pairs(ListContainer:GetChildren()) do if v:IsA("TextButton") or v:IsA("UIListLayout") then v:Destroy() end end
    local LL = Instance.new("UIListLayout", ListContainer); LL.Padding = UDim.new(0, 5); LL.SortOrder = Enum.SortOrder.LayoutOrder
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local distText = "?"
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                distText = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
            end
            local btn = Instance.new("TextButton", ListContainer)
            btn.Size = UDim2.new(1, -10, 0, 30); btn.BackgroundColor3 = Theme.ButtonBg; btn.BackgroundTransparency = 0.2
            btn.Text = "  " .. plr.Name .. " [" .. distText .. " studs]"; btn.TextColor3 = Theme.Text; btn.Font = Theme.Font; btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function() TeleportToPlayer(plr) end)
        end
    end
end
task.spawn(function() while true do if liveUpdateEnabled and ListContainer.Visible then RefreshPlayerList() end task.wait(1) end end)
-- [[ 1. SHARED SELECTION ]] --
local BringTarget = nil
local LocalLoopCon = nil

TPTab:Label("--- Player Selection ---")
TPTab:Dropdown("Select Player", function(name)
    BringTarget = Players:FindFirstChild(name)
    if BringTarget then Window:Notify("System", "Selected: " .. name) end
end)

-- [[ 2. LOCAL BRING (CLIENT SIDE) ]] --
TPTab:Label("--- Local Bring (Client) ---")

TPTab:Button("Local Bring (Once)", function()
    if not BringTarget then Window:Notify("Error", "Select a player first!"); return end
    
    local c = LocalPlayer.Character
    local t = BringTarget.Character
    
    if c and c:FindFirstChild("HumanoidRootPart") and t and t:FindFirstChild("HumanoidRootPart") then
        -- FIXED: Move TARGET to LOCALPLAYER
        -- We put them 3 studs in front of you (-3 on Z axis)
        t.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
    end
end)

TPTab:Toggle("Local Loop (Stick)", false, function(v)
    if v then
        if not BringTarget then Window:Notify("Error", "Select a player first!"); return end
        Window:Notify("System", "Sticking player to me...")
        
        LocalLoopCon = RunService.RenderStepped:Connect(function()
            local c = LocalPlayer.Character
            local t = BringTarget.Character
            
            if c and c:FindFirstChild("HumanoidRootPart") and t and t:FindFirstChild("HumanoidRootPart") then
                local tRoot = t.HumanoidRootPart
                local myRoot = c.HumanoidRootPart
                
                -- FIXED: Constantly set TARGET CFrame to YOUR CFrame
                -- We use specific CFrame setting rather than Lerp for "Stick" to fight replication harder
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                
                -- Zero out their velocity so they don't slide away
                tRoot.AssemblyLinearVelocity = Vector3.zero
                tRoot.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    else
        if LocalLoopCon then LocalLoopCon:Disconnect(); LocalLoopCon = nil end
        Window:Notify("System", "Unstuck")
    end
end)

-- [[ LOCAL BRING ALL LOOP ]] --
local LoopBringAllCon = nil

TPTab:Toggle("Local Bring All Loop", false, function(v)
    if v then
        Window:Notify("System", "Loop Bringing ALL players...")
        
        LoopBringAllCon = RunService.RenderStepped:Connect(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local tRoot = plr.Character.HumanoidRootPart
                        
                        -- Set their CFrame to 4 studs in front of you
                        tRoot.CFrame = c.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
                        
                        -- Zero out velocity to keep them from sliding away
                        tRoot.AssemblyLinearVelocity = Vector3.zero
                        tRoot.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end)
    else
        if LoopBringAllCon then 
            LoopBringAllCon:Disconnect()
            LoopBringAllCon = nil 
        end
        Window:Notify("System", "Stopped Bring All")
    end
end)

TPTab:Button("FE Bring (object fix coming soon)", function()
    if not BringTarget then Window:Notify("Error", "Select a player first!"); return end
    
    local c = LocalPlayer.Character
    local c1 = BringTarget.Character
    
    if not (c and c1) then Window:Notify("Error", "Character missing"); return end
    
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChild("Humanoid")
    local hrp1 = c1:FindFirstChild("HumanoidRootPart")
    
    if not (hrp and hrp1) then Window:Notify("Error", "RootPart missing"); return end

    Window:Notify("System", "Attempting Smart Bring...")

    -- --- CONSTANTS ---
    local speeding = 32      
    local maxspeed = 75      
    local dodgeSpeed = 40    
    local reactionTime = 0.5 -- SECONDS TO WAIT BEFORE DODGING
    local off = CFrame.Angles(-1.5707963267948966, 0, 0) 
    local v3_0 = Vector3.new(0, 0, 0)
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {c, c1, workspace.CurrentCamera}
    -- -----------------

    -- 1. SAVE HOME & CONFIG
    local HomeCFrame = hrp.CFrame
    
    -- 2. TELEPORT INITIAL 
    local TargetCFrame = hrp1.CFrame
    hrp.CFrame = (TargetCFrame * CFrame.new(0, -3, 0)) * off
    
    if hum then hum.PlatformStand = true end
    task.wait(1) 
    
    -- 3. SETUP PATH VARIABLES
    local startPos = hrp.Position
    local endPos = HomeCFrame.Position + Vector3.new(0, 3, 0) 
    startPos = Vector3.new(startPos.X, endPos.Y, startPos.Z)

    local totalDistance = (startPos - endPos).Magnitude 
    local forwardDir = (endPos - startPos).Unit 
    local rightDir = forwardDir:Cross(Vector3.new(0,1,0)) 

    local forwardVel = 0
    local currentDistanceTraveled = 0
    local dodgeOffset = Vector3.new(0,0,0) 
    
    -- STATE VARIABLES
    local sine = os.clock()
    local lastsine = sine
    local bringing = true
    
    local isBlocked = false       -- Are we currently stuck?
    local blockedTimestamp = 0    -- When did we get stuck?

    -- 4. MOVEMENT LOOP
    while bringing and c.Parent and c1.Parent do
        sine = os.clock()
        local deltaTime = sine - lastsine
        lastsine = sine

        -- A. OBSTACLE CHECK
        local currentRealPos = startPos + (forwardDir * currentDistanceTraveled) + dodgeOffset
        local hitFront = workspace:Raycast(currentRealPos, forwardDir * 10, rayParams)

        if hitFront then
            -- === OBSTACLE DETECTED ===
            
            -- 1. HARD STOP FORWARD
            forwardVel = 0 

            -- 2. HANDLE TIMER
            if not isBlocked then
                isBlocked = true
                blockedTimestamp = os.clock() -- Start the timer NOW
            end

            -- 3. CHECK IF WE HAVE WAITED LONG ENOUGH
            local timeStuck = os.clock() - blockedTimestamp
            
            if timeStuck >= reactionTime then
                -- WE HAVE WAITED, NOW WE DODGE
                
                -- Check UP
                local hitUp = workspace:Raycast(currentRealPos, Vector3.new(0, 10, 0), rayParams)
                if not hitUp then
                    dodgeOffset = dodgeOffset + (Vector3.new(0, 1, 0) * dodgeSpeed * deltaTime)
                else
                    -- Check RIGHT
                    local hitRight = workspace:Raycast(currentRealPos, rightDir * 8, rayParams)
                    if not hitRight then
                         dodgeOffset = dodgeOffset + (rightDir * dodgeSpeed * deltaTime)
                    else
                         -- Check LEFT
                         dodgeOffset = dodgeOffset - (rightDir * dodgeSpeed * deltaTime)
                    end
                end
            else
                -- WE ARE STILL WAITING (Do nothing, just hover)
                -- This allows the player/physics to settle before we jerk them sideways
            end
            
        else
            -- === PATH CLEAR ===
            isBlocked = false -- Reset blocked status
            
            -- Resume Acceleration
            if currentDistanceTraveled < totalDistance / 2 then
                 forwardVel = forwardVel + (speeding * deltaTime)
            else
                 if currentDistanceTraveled > totalDistance - 20 then 
                    forwardVel = forwardVel - (speeding * deltaTime)
                 else
                    forwardVel = forwardVel + (speeding * deltaTime)
                 end
            end
            
            if forwardVel > maxspeed then forwardVel = maxspeed end
            if forwardVel < 10 then forwardVel = 10 end 
            
            currentDistanceTraveled = currentDistanceTraveled + (forwardVel * deltaTime)
        end

        if currentDistanceTraveled >= totalDistance then
            break
        end

        -- B. APPLY POSITION
        if not (hrp:IsGrounded()) then 
            local finalPos = startPos + (forwardDir * currentDistanceTraveled) + dodgeOffset
            
            hrp.CFrame = CFrame.new(finalPos, endPos) * off
            
            if forwardVel <= 1 then
                -- Hover velocity while waiting/stopped
                hrp.Velocity = Vector3.new(0, 2, 0)
            else
                hrp.Velocity = forwardDir * forwardVel
            end
            
            hrp.RotVelocity = v3_0
        end

        task.wait()
    end

    -- 5. FINISH
    hrp.CFrame = HomeCFrame
    hrp.Velocity = v3_0
    hrp.RotVelocity = v3_0
    if hum then hum.PlatformStand = false end
    Window:Notify("System", "Bring Finished")
end)


-- [[ 2. CHAT LOGS LOGIC ]] --
local function AddLog(text, color)
    local label = Instance.new("TextLabel", LogsContainer)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Text = text
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    
    -- Auto Scroll to Bottom
    LogsContainer.CanvasPosition = Vector2.new(0, 99999)
end

-- Method A: New TextChatService
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msgObj)
        if msgObj.TextSource then
            local plr = Players:GetPlayerByUserId(msgObj.TextSource.UserId)
            local name = plr and plr.Name or "Unknown"
            if name ~= LocalPlayer.Name then
                AddLog("["..name.."]: " .. msgObj.Text, Color3.fromRGB(255, 235, 59))
            end
        end
    end)
end

-- Method B: Legacy Chat (Backups)
-- We run this regardless, just in case the game uses a custom chat or hybrid system
local function ConnectChat(plr)
    plr.Chatted:Connect(function(msg)
        AddLog("["..plr.Name.."]: " .. msg, Color3.fromRGB(255, 235, 59))
    end)
end

for _, p in pairs(Players:GetPlayers()) do 
    if p ~= LocalPlayer then ConnectChat(p) end 
end
Players.PlayerAdded:Connect(function(p) 
    if p ~= LocalPlayer then ConnectChat(p) end 
end)

-- // MISC TAB //
MiscTab:Label("--- Modes ---")
MiscTab:Toggle("CMD Mode", false, function(v) ToggleCMDMode(v) end)

MiscTab:Toggle("Fly", Config.Toggles.Fly, function(v) Config.Toggles.Fly = v; if not v then ResetMovement() end end)
MiscTab:Slider("Fly Speed", 10, 200, Config.Movement.FlySpeed, function(v) Config.Movement.FlySpeed = v end)

MiscTab:Toggle("Enable Safe Fly", Config.Toggles.SafeFly, function(v) Config.Toggles.SafeFly = v; if not v then ResetMovement() end end)
MiscTab:Slider("Safe Fly Speed", 10, 200, Config.Movement.SafeFlySpeed, function(v) Config.Movement.SafeFlySpeed = v end)
MiscTab:Toggle("Noclip", Config.Toggles.Noclip, function(v) Config.Toggles.Noclip = v end)

local NoGravCon = nil
MiscTab:Slider("No Grav Speed", 10, 200, Config.Movement.NoGravSpeed, function(v) Config.Movement.NoGravSpeed = v end)
MiscTab:Toggle("No Gravity", false, function(v)
    if v then
        NoGravCon = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local vel = root.AssemblyLinearVelocity; local targetY = vel.Y
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then targetY = Config.Movement.NoGravSpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then targetY = -Config.Movement.NoGravSpeed
                elseif vel.Y < -0.01 then targetY = 0 end
                if targetY ~= vel.Y then root.AssemblyLinearVelocity = Vector3.new(vel.X, targetY, vel.Z) end
            end
            SaveConfig()
        end)
    else
        if NoGravCon then NoGravCon:Disconnect(); NoGravCon = nil end
    end
end)

MiscTab:Label("--- Self ---")

MiscTab:Toggle("Force Shiftlock", false, function(v)
    LocalPlayer.DevEnableMouseLock = v
    if v then task.spawn(function() while LocalPlayer.DevEnableMouseLock == false and v do LocalPlayer.DevEnableMouseLock = true; task.wait(1) end end) end
end)

MiscTab:Toggle("Force 3rd Person", false, function(v)
    if v then LocalPlayer.CameraMode = Enum.CameraMode.Classic; LocalPlayer.CameraMaxZoomDistance = 100; LocalPlayer.CameraMinZoomDistance = 10
    else LocalPlayer.CameraMaxZoomDistance = 128; LocalPlayer.CameraMinZoomDistance = 0.5 end
end)

MiscTab:Toggle("Freeze Self", false, function(v)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if v then
        -- HARD FREEZE
        if root then 
            root.Anchored = true 
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if hum then 
            hum.PlatformStand = true -- Disables inputs and physics
        end
        Window:Notify("System", "Frozen (Hard)")
    else
        -- UNFREEZE
        if root then 
            root.Anchored = false 
        end
        if hum then 
            hum.PlatformStand = false 
        end
        Window:Notify("System", "Unfrozen")
    end
end)

MiscTab:Label("--- Safety ---")
-- // ANTI-VOID LOGIC // ----------------------------------------------------------------------
local AntiVoidPart = nil
local AntiVoidConnection = nil

-- Define the function in scope so LoadConfig can access it
UpdateAntiVoid = function(state)
    if state then
        if not AntiVoidConnection then
            AntiVoidConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    -- Trigger if player falls below specific height
                    if root.Position.Y < Config.Misc.AntiVoidHeight then
                        -- Create the platform if it doesn't exist
                        if not AntiVoidPart or not AntiVoidPart.Parent then
                            AntiVoidPart = Instance.new("Part")
                            AntiVoidPart.Name = "RLoader_AntiVoid"
                            AntiVoidPart.Size = Vector3.new(2048, 1, 2048)
                            AntiVoidPart.Anchored = true
                            AntiVoidPart.Transparency = 0.5
                            AntiVoidPart.BrickColor = BrickColor.new("Royal purple")
                            AntiVoidPart.Material = Enum.Material.Neon
                            AntiVoidPart.Parent = workspace
                        end
                        
                        -- Position platform directly under player at the trigger height
                        AntiVoidPart.CFrame = CFrame.new(root.Position.X, Config.Misc.AntiVoidHeight - 5, root.Position.Z)
                        
                        -- Cancel downward velocity to prevent impact damage
                        local vel = root.AssemblyLinearVelocity
                        if vel.Y < 0 then
                            root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
                        end
                    else
                        -- Cleanup platform if player is safe
                        if AntiVoidPart then 
                            AntiVoidPart:Destroy()
                            AntiVoidPart = nil 
                        end
                    end
                end
            end)
        end
    else
        -- Cleanup everything when disabled
        if AntiVoidConnection then AntiVoidConnection:Disconnect(); AntiVoidConnection = nil end
        if AntiVoidPart then AntiVoidPart:Destroy(); AntiVoidPart = nil end
    end
end

MiscTab:Toggle("Anti-Void", Config.Misc.AntiVoid or false, function(v)
    if not Config.Misc.AntiVoidHeight then Config.Misc.AntiVoidHeight = -50 end
    Config.Misc.AntiVoid = v
    UpdateAntiVoid(v)
    Window:Notify("System", "Anti-Void: " .. tostring(v))
end)
MiscTab:Button("Rejoin Server", function()
    Window:Notify("System", "Rejoining...")
    if #Players:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nRejoining...")
        task.wait()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    else
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end)

-- // FUN & WEATHER //
local WeatherFolder = workspace:FindFirstChild("RLoader_Weather") or Instance.new("Folder", workspace); WeatherFolder.Name = "RLoader_Weather"
local SnowConnection, RainConnection, StoredSky, ActiveSky = nil, nil, nil, nil

local function SetCustomSky(mode)
    local currentSky = Lighting:FindFirstChildOfClass("Sky")
    if currentSky and currentSky.Name ~= "RLoader_Sky" then
        if not StoredSky then StoredSky = currentSky; StoredSky.Parent = nil end
    end
    if ActiveSky then ActiveSky:Destroy(); ActiveSky = nil end
    if mode then
        local s = Instance.new("Sky"); s.Name = "RLoader_Sky"
        local asset = (mode == "Rain") and "rbxassetid://169591672" or "rbxassetid://606626507"
        if mode == "Rain" then s.SunTextureId = ""; s.MoonTextureId = ""; Lighting.Brightness = 0.5 else Lighting.Brightness = 1.5 end
        for _, name in pairs({"Bk", "Dn", "Ft", "Lf", "Rt", "Up"}) do s["Skybox"..name] = asset end
        s.Parent = Lighting; ActiveSky = s
    else
        if StoredSky then StoredSky.Parent = Lighting; StoredSky = nil; Lighting.Brightness = 1 end
    end
end

local function CreateSnowflake()
    if not Config.Fun.Snow then return end
    local cam = workspace.CurrentCamera; local startPos = cam.CFrame.Position + Vector3.new(math.random(-60, 60), 40, math.random(-60, 60))
    local snowflake = Instance.new("Part"); snowflake.Name = "RL_Snowflake"; snowflake.Size = Vector3.new(0.3, 0.3, 0.3); snowflake.Anchored = true; snowflake.CanCollide = false; snowflake.Transparency = 0.5; snowflake.BrickColor = BrickColor.new("White"); snowflake.Position = startPos; snowflake.Parent = WeatherFolder
    local decal = Instance.new("Decal"); decal.Texture = "rbxassetid:/82374748"; decal.Face = Enum.NormalId.Top; decal.Parent = snowflake
    local fallTween = TweenService:Create(snowflake, TweenInfo.new(math.random(30, 50)/10, Enum.EasingStyle.Linear), {Position = startPos - Vector3.new(0, 50, 0), Transparency = 1}); fallTween:Play(); fallTween.Completed:Connect(function() snowflake:Destroy() end)
end

local function CreateRainDrop()
    if not Config.Fun.Rain then return end
    local cam = workspace.CurrentCamera; local startPos = cam.CFrame.Position + Vector3.new(math.random(-50, 50), 45, math.random(-50, 50))
    local raindrop = Instance.new("Part"); raindrop.Name = "RL_Raindrop"; raindrop.Size = Vector3.new(0.1, 0.8, 0.1); raindrop.Anchored = true; raindrop.CanCollide = false; raindrop.Transparency = 0.4; raindrop.BrickColor = BrickColor.new("Electric blue"); raindrop.Material = Enum.Material.SmoothPlastic; raindrop.Position = startPos; raindrop.Parent = WeatherFolder
    local decal = Instance.new("Decal"); decal.Texture = "rbxassetid://244222409"; decal.Face = Enum.NormalId.Front; decal.Transparency = 0.2; decal.Parent = raindrop
    local fallTween = TweenService:Create(raindrop, TweenInfo.new(math.random(4, 6)/10, Enum.EasingStyle.Linear), {Position = startPos - Vector3.new(0, 60, 0), Transparency = 0.8}); fallTween:Play(); fallTween.Completed:Connect(function() raindrop:Destroy() end)
end

FunTab:Label("--- Time Control ---")
FunTab:Slider("Time of Day", 0, 24, Config.Fun.Time, function(v) Config.Fun.Time = v; Lighting.ClockTime = v end)

FunTab:Label("--- Weather ---")
FunTab:Toggle("Enable Snow", Config.Fun.Snow, function(v)
    Config.Fun.Snow = v; if v then Config.Fun.Rain = false; if RainConnection then RainConnection:Disconnect() end SetCustomSky("Snow"); if not SnowConnection then SnowConnection = RunService.Heartbeat:Connect(function() if math.random() < 0.3 then CreateSnowflake(); if math.random() < 0.5 then CreateSnowflake() end end end) end else SetCustomSky(nil); if SnowConnection then SnowConnection:Disconnect(); SnowConnection = nil end end
end)
FunTab:Toggle("Enable Rain", Config.Fun.Rain, function(v)
    Config.Fun.Rain = v; if v then Config.Fun.Snow = false; if SnowConnection then SnowConnection:Disconnect() end SetCustomSky("Rain"); if not RainConnection then RainConnection = RunService.Heartbeat:Connect(function() for i = 1, 3 do CreateRainDrop() end end) end else SetCustomSky(nil); if RainConnection then RainConnection:Disconnect(); RainConnection = nil end end
end)

-- [[ AIR WALK - ANTI-ASCEND & NO FALL + DESCEND ]]
local AirWalkPart = nil
local AirWalkCon = nil
local AirParticles = nil
local LockedY = nil 
local UIS = game:GetService("UserInputService") 

FunTab:Toggle("Air Walk", false, function(v)
    if v then
        -- 1. Create Platform
        AirWalkPart = Instance.new("Part")
        AirWalkPart.Name = "RL_AirWalk"
        AirWalkPart.Size = Vector3.new(6, 1, 6)
        AirWalkPart.Transparency = 1 
        AirWalkPart.Anchored = true
        AirWalkPart.CanCollide = true
        AirWalkPart.Parent = workspace

        -- 2. Particles
        AirParticles = Instance.new("ParticleEmitter")
        AirParticles.Parent = AirWalkPart
        AirParticles.Texture = "rbxassetid://4758322939"
        AirParticles.Color = ColorSequence.new(Color3.new(1,1,1))
        AirParticles.Size = NumberSequence.new(1.5)
        AirParticles.Rate = 500
        AirParticles.Lifetime = NumberRange.new(0.5, 1)
        AirParticles.Transparency = NumberSequence.new(0.5, 1)
        AirParticles.Enabled = false

        -- 3. Logic Loop
        AirWalkCon = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if root and hum and AirWalkPart then
                local vel = root.AssemblyLinearVelocity
                
                -- Raycast for Real Ground
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char, AirWalkPart}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local hitGround = workspace:Raycast(root.Position, Vector3.new(0, -6, 0), rayParams)

                -- [[ 1. RESET CONDITIONS (Jump/Land) ]]
                if vel.Y > 0 or hitGround then
                    -- If jumping OR on real ground, hide platform
                    AirWalkPart.Position = Vector3.new(0, -1000, 0)
                    AirParticles.Enabled = false
                    LockedY = nil 

                -- [[ 2. AIR WALK ACTIVE ]]
                else
                    -- Capture Height ONCE
                    if LockedY == nil then
                        LockedY = root.Position.Y - (hum.HipHeight + (root.Size.Y / 2) + 0.5)
                    end

                    -- [[ DESCEND LOGIC ]] --
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                        LockedY = LockedY - 0.5 -- Lower the platform
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, -30, vel.Z) -- Force player down
                    else
                        -- Freeze Y (Normal Air Walk)
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
                    end

                    -- Update Platform Position
                    AirWalkPart.CFrame = CFrame.new(root.Position.X, LockedY, root.Position.Z)
                    AirParticles.Enabled = true
                end
            end
        end)
    else
        -- Cleanup
        if AirWalkCon then AirWalkCon:Disconnect(); AirWalkCon = nil end
        if AirWalkPart then AirWalkPart:Destroy(); AirWalkPart = nil end
        LockedY = nil
    end
end)
-- [[ SPECTATE SYSTEM ]]
FunTab:Label("--- Spectate ---")
FunTab:Dropdown("Spectate Player", function(name) local t = Players:FindFirstChild(name) if t and t.Character then workspace.CurrentCamera.CameraSubject = t.Character.Humanoid end end)
FunTab:Button("Stop Spectating", function() if LocalPlayer.Character then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end end)

-- // PLAYER INTERACTIONS //
local FlingTargetName, AttachTargetName, AttachPos, CycleDuration, SafePos = nil, nil, "Back", 2, nil
local FlingingSingle, FlingingCycle, Attaching = false, false, false

local function EnablePhysics(enable)
    local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if enable then
        if hum then hum.PlatformStand = true; hum:ChangeState(Enum.HumanoidStateType.Physics) end
        if root and not root:FindFirstChild("FlingHover") then local bv = Instance.new("BodyVelocity", root); bv.Name = "FlingHover"; bv.MaxForce = Vector3.new(100000, 100000, 100000); bv.Velocity = Vector3.zero end
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    else
        if hum then hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        if root then local bv = root:FindFirstChild("FlingHover") if bv then bv:Destroy() end root.AssemblyAngularVelocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero end
    end
end

local function ProcessFling(targetRoot)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        myRoot.CFrame = CFrame.new(targetRoot.Position) * CFrame.new(0, math.sign(math.sin(tick() * 100)) * 10, 0)
        myRoot.AssemblyAngularVelocity = Vector3.new(0, 100000, 0); myRoot.AssemblyLinearVelocity = Vector3.zero 
    end
end

FunTab:Dropdown("Select Fling Target", function(name) FlingTargetName = name end)
FunTab:Toggle("Fling Player", false, function(v)
    FlingingSingle = v
    if v then
        if LocalPlayer.Character then SafePos = LocalPlayer.Character.HumanoidRootPart.CFrame end
        EnablePhysics(true)
        task.spawn(function()
            while FlingingSingle do
                local target = Players:FindFirstChild(FlingTargetName)
                if target and target.Character then ProcessFling(target.Character.HumanoidRootPart) end
                RunService.Heartbeat:Wait() 
            end
            EnablePhysics(false); if SafePos then LocalPlayer.Character.HumanoidRootPart.CFrame = SafePos end
        end)
    end
end)

FunTab:Label("--- Cycle Fling ---")
FunTab:Slider("Duration Per Player", 0.5, 5, CycleDuration, function(v) CycleDuration = v end)
FunTab:Toggle("Cycle Fling All", false, function(v)
    FlingingCycle = v
    if v then
        if LocalPlayer.Character then SafePos = LocalPlayer.Character.HumanoidRootPart.CFrame end
        EnablePhysics(true)
        task.spawn(function()
            while FlingingCycle do
                for _, plr in pairs(Players:GetPlayers()) do
                    if not FlingingCycle then break end
                    if plr ~= LocalPlayer and plr.Character then
                        local timer = tick()
                        while (tick() - timer) < CycleDuration and FlingingCycle do
                            if plr.Character then ProcessFling(plr.Character.HumanoidRootPart) else break end
                            RunService.Heartbeat:Wait()
                        end
                        task.wait(0.05)
                    end
                end
                task.wait(0.5) 
            end
            EnablePhysics(false); if SafePos then LocalPlayer.Character.HumanoidRootPart.CFrame = SafePos end
        end)
    end
end)

FunTab:Label("--- Attach ---")
FunTab:Dropdown("Select Attach Target", function(name) AttachTargetName = name end)
local PosBtn; PosBtn = FunTab:Button("Position: " .. AttachPos, function()
    if AttachPos == "Back" then AttachPos = "Front" elseif AttachPos == "Front" then AttachPos = "Under" else AttachPos = "Back" end
    PosBtn.Text = "Position: " .. AttachPos
end)
FunTab:Toggle("Attach to Player", false, function(v)
    Attaching = v
    if v then
        task.spawn(function()
            while Attaching do
                local target = Players:FindFirstChild(AttachTargetName)
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if target and target.Character and myRoot then
                    local offset = (AttachPos == "Back" and CFrame.new(0, 0, 2)) or (AttachPos == "Front" and CFrame.new(0, 0, -2) * CFrame.Angles(0, math.pi, 0)) or CFrame.new(0, -8, 0) * CFrame.Angles(math.rad(90), 0, 0)
                    myRoot.CFrame = target.Character.HumanoidRootPart.CFrame * offset
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                end
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

-- // KEYBINDS TAB //
-- Core UI Binds
KeybindsTab:Label("--- Core ---")
KeybindsTab:Binder("Toggle UI", Config.Binds.ToggleUI, function(k) Config.Binds.ToggleUI = k end)

-- Movement
KeybindsTab:Label("--- Movement Actions ---")
KeybindsTab:Binder("Phase Forward", Config.Binds.Phase, function(k) Config.Binds.Phase = k end)
KeybindsTab:Binder("Save Position", Config.Binds.SavePos, function(k) Config.Binds.SavePos = k end)
KeybindsTab:Binder("Teleport to Saved", Config.Binds.Teleport, function(k) Config.Binds.Teleport = k end)

-- Toggles (Expanded)
KeybindsTab:Label("--- Toggles ---")
KeybindsTab:Binder("Toggle Fly", Config.Binds.Fly, function(k) Config.Binds.Fly = k end)
KeybindsTab:Binder("Toggle Noclip", Config.Binds.Noclip, function(k) Config.Binds.Noclip = k end)
KeybindsTab:Binder("Toggle CarFly", Config.Binds.CarFly, function(k) Config.Binds.CarFly = k end) -- [NEW]
KeybindsTab:Binder("Toggle SafeFly", Config.Binds.SafeFly, function(k) Config.Binds.SafeFly = k end)
KeybindsTab:Binder("Toggle Speed", Config.Binds.Speed, function(k) Config.Binds.Speed = k end)
KeybindsTab:Binder("Toggle Jump", Config.Binds.Jump, function(k) Config.Binds.Jump = k end)
KeybindsTab:Binder("Toggle NoGravity", Config.Binds.NoGravity, function(k) Config.Binds.NoGravity = k end)

KeybindsTab:Label("--- Visuals ---")
KeybindsTab:Binder("Toggle ESP", Config.Binds.ESP, function(k) Config.Binds.ESP = k end)
KeybindsTab:Binder("Toggle WallClip", Config.Binds.WallClip, function(k) Config.Binds.WallClip = k end)
KeybindsTab:Binder("Toggle Fullbright", Config.Binds.Fullbright, function(k) Config.Binds.Fullbright = k end)

KeybindsTab:Label("--- Other ---")
KeybindsTab:Binder("Toggle Aimbot", Config.Binds.Aimbot, function(k) Config.Binds.Aimbot = k end)
KeybindsTab:Binder("Toggle Rain", Config.Binds.Rain, function(k) Config.Binds.Rain = k end)
KeybindsTab:Binder("Toggle Snow", Config.Binds.Snow, function(k) Config.Binds.Snow = k end)

-- Reset Button
KeybindsTab:Button("Reset All Keybinds (Set to None)", function()
    for k, v in pairs(Config.Binds) do
        Config.Binds[k] = Enum.KeyCode.Unknown
    end
    SaveConfig()
    Window:Notify("System", "All Keybinds Reset to None. Re-open UI to see changes.")
end)


-- // 5. LOGIC LOOPS & RUNTIME // -------------------------------------------------------------

-- Load config at end of setup (and trigger antivoid if needed)
LoadConfig()

-- Input Handling for Keybinds
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Helper to check bind
    local function IsBind(bindName) return input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == Config.Binds[bindName] end

    if IsBind("Phase") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist)
        end
    elseif IsBind("SavePos") then
        if LocalPlayer.Character then Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame; Window:Notify("System", "Position Saved") end
    
    elseif IsBind("Teleport") then
        if not Config.Movement.SavedCFrame then return end
        if Config.Movement.InstantTP then
            if LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = Config.Movement.SavedCFrame; Window:Notify("System", "Teleported Instantly") end
            return
        end
        isTeleporting = true
        Window:Notify("System", "Teleporting...")
        task.spawn(function()
            local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local target = Config.Movement.SavedCFrame.Position
            while isTeleporting and root and (root.Position - target).Magnitude > 5 do
                root.CFrame = CFrame.new(root.Position + ((target - root.Position).Unit * 5)); task.wait(Config.Movement.IntervalSpeed)
                if not LocalPlayer.Character then break end; root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            if root and isTeleporting then root.CFrame = Config.Movement.SavedCFrame end; isTeleporting = false
        end)
    
    -- Toggles
    elseif IsBind("Fly") then Config.Toggles.Fly = not Config.Toggles.Fly; if not Config.Toggles.Fly then ResetMovement() end; Window:Notify("System", "Fly: "..tostring(Config.Toggles.Fly))
    elseif IsBind("Noclip") then Config.Toggles.Noclip = not Config.Toggles.Noclip; Window:Notify("System", "Noclip: "..tostring(Config.Toggles.Noclip))
    
    -- [[ NEW: CarFly Bind ]] --
    elseif IsBind("CarFly") then
        local isEnabled = (CarFlyCon ~= nil)
        ToggleCarFly(not isEnabled)
        
    elseif IsBind("SafeFly") then Config.Toggles.SafeFly = not Config.Toggles.SafeFly; if not Config.Toggles.SafeFly then ResetMovement() end; Window:Notify("System", "SafeFly: "..tostring(Config.Toggles.SafeFly))
    elseif IsBind("Speed") then Config.Toggles.Speed = not Config.Toggles.Speed; Window:Notify("System", "Speed: "..tostring(Config.Toggles.Speed))
    elseif IsBind("Jump") then Config.Toggles.Jump = not Config.Toggles.Jump; Window:Notify("System", "Jump: "..tostring(Config.Toggles.Jump))
    elseif IsBind("NoGravity") then -- No Gravity is tricky as it's not in Toggles table directly usually, handled via UI callback logic. 
        Window:Notify("System", "Please use UI for NoGrav Toggle") 
    
    -- Visuals
    elseif IsBind("ESP") then Config.ESP.Enabled = not Config.ESP.Enabled; Window:Notify("System", "ESP: "..tostring(Config.ESP.Enabled))
    elseif IsBind("WallClip") then Config.ESP.WallClip = not Config.ESP.WallClip; Window:Notify("System", "WallClip: "..tostring(Config.ESP.WallClip))
    elseif IsBind("Fullbright") then Config.ESP.Fullbright = not Config.ESP.Fullbright; ToggleFullbright(Config.ESP.Fullbright); Window:Notify("System", "Fullbright: "..tostring(Config.ESP.Fullbright))
    
    -- Other
    elseif IsBind("Aimbot") then Config.Aimbot.Enabled = not Config.Aimbot.Enabled; Window:Notify("System", "Aimbot: "..tostring(Config.Aimbot.Enabled))
    elseif IsBind("Rain") then Config.Fun.Rain = not Config.Fun.Rain; Window:Notify("System", "Rain: "..tostring(Config.Fun.Rain)) -- Requires UI trigger ideally
    elseif IsBind("Snow") then Config.Fun.Snow = not Config.Fun.Snow; Window:Notify("System", "Snow: "..tostring(Config.Fun.Snow))
    end
end)

-- Movement Loop
RunService.RenderStepped:Connect(function(deltaTime)
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not root or not hum then return end

    if Config.Toggles.Fly then
        root.Anchored = false; hum.PlatformStand = true
        local moveDir = Vector3.zero; local camCF = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then root.CFrame = root.CFrame + (moveDir.Unit * (Config.Movement.FlySpeed * deltaTime)) end
        root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero; root.Velocity = Vector3.zero 
    elseif Config.Toggles.SafeFly then
        hum:ChangeState(Enum.HumanoidStateType.Physics); hum.PlatformStand = false
        local moveDir = Vector3.zero; local camCF = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then root.AssemblyLinearVelocity = moveDir.Unit * Config.Movement.SafeFlySpeed else root.AssemblyLinearVelocity = Vector3.zero end
        root.AssemblyAngularVelocity = Vector3.zero
    end
end)

-- Noclip & Stats Loop
local lastNoclipState = false
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    local shouldNoclip = Config.Toggles.Noclip or Config.Toggles.Fly
    if shouldNoclip then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide == true then v.CanCollide = false end end
        lastNoclipState = true
    elseif lastNoclipState then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and not v.Parent:IsA("Accessory") then v.CanCollide = true end end
        lastNoclipState = false
    end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if Config.Toggles.Speed then hum.WalkSpeed = Config.Movement.WalkSpeed end
        if Config.Toggles.Jump then hum.UseJumpPower = true; hum.JumpPower = Config.Movement.JumpPower end
    end
end)

-- // ESP SYSTEM (FIXED) // ------------------------------------------------------------------
local ESPFolder = Instance.new("Folder", CoreGui); ESPFolder.Name = "RLoaderESP_Universal"
local ESP_2D = Instance.new("ScreenGui", CoreGui)
ESP_2D.Name = "RLoaderESP_2D_Overlay"
ESP_2D.IgnoreGuiInset = true

local InteractableCache = {}

local function CacheInteractable(obj)
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        if obj.Parent and (obj.Parent:IsA("BasePart") or obj.Parent:IsA("Model")) then 
            table.insert(InteractableCache, obj.Parent) 
        end
    elseif obj:IsA("Model") then
        task.delay(0.1, function()
            if obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                table.insert(InteractableCache, obj)
            end
        end)
    end
end

for _, descendant in pairs(workspace:GetDescendants()) do CacheInteractable(descendant) end
workspace.DescendantAdded:Connect(CacheInteractable)

-- [[ NEW: DEDICATED CLEANUP FUNCTION ]] --
local function CleanupESP(plrName)
    -- Cleanup 3D (Highlights/Billboards)
    local suffix3D = {"_Highlight", "_Tag", "_ObjHighlight"}
    for _, s in pairs(suffix3D) do
        local obj = ESPFolder:FindFirstChild(plrName .. s)
        if obj then obj:Destroy() end
    end
    
    -- Cleanup 2D (Boxes, Tracers, Bars)
    local suffix2D = {"_Box", "_Tracer", "_HealthBar"}
    for _, s in pairs(suffix2D) do
        local obj = ESP_2D:FindFirstChild(plrName .. s)
        if obj then obj:Destroy() end
    end
end

-- [[ NEW: EVENT LISTENERS FOR LEAVING/DYING ]] --
Players.PlayerRemoving:Connect(function(plr)
    CleanupESP(plr.Name)
end)

local function MonitorCharacter(plr)
    if plr.Character then
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                CleanupESP(plr.Name)
            end)
        end
    end
    plr.CharacterAdded:Connect(function(char)
        -- Cleanup old ESP on respawn to prevent ghosting
        CleanupESP(plr.Name)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                CleanupESP(plr.Name)
            end)
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do MonitorCharacter(p) end
Players.PlayerAdded:Connect(MonitorCharacter)

-- [[ MAIN RENDER LOOP ]] --
RunService.RenderStepped:Connect(function()
    -- [[ PLAYER ESP ]] --
    if Config.ESP.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            -- Valid Check: Must be alive, not local, have Root and Head
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local root = char.HumanoidRootPart
                local head = char.Head
                local hum = char:FindFirstChild("Humanoid")
                
                -- LOGIC CHANGE: Instead of 'continue', we only draw if Health > 0
                if hum and hum.Health > 0 then
                    -- 1. HIGHLIGHTS (Chams)
                    local hlName = plr.Name .. "_Highlight"
                    local hl = ESPFolder:FindFirstChild(hlName)
                    if not hl then hl = Instance.new("Highlight", ESPFolder); hl.Name = hlName; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0 end
                    hl.Adornee = char
                    
                    if Config.Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                    else
                        hl.FillColor = Color3.fromRGB(Config.ESP.Fill.R, Config.ESP.Fill.G, Config.ESP.Fill.B)
                        hl.OutlineColor = Color3.fromRGB(Config.ESP.Outline.R, Config.ESP.Outline.G, Config.ESP.Outline.B)
                    end

                    -- 2. BILLBOARD TAGS
                    local tagName = plr.Name .. "_Tag"
                    local tag = ESPFolder:FindFirstChild(tagName)
                    if Config.ESP.ShowNames then
                        if not tag then
                            tag = Instance.new("BillboardGui", ESPFolder); tag.Name = tagName; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0, 200, 0, 50); tag.StudsOffset = Vector3.new(0, -5, 0)
                            local label = Instance.new("TextLabel", tag); label.BackgroundTransparency = 1; label.Size = UDim2.new(1,0,1,0); label.TextColor3 = Color3.new(1,1,1); label.TextSize = 13; label.Font = Enum.Font.GothamBold
                        end
                        tag.Adornee = root
                        tag:FindFirstChildOfClass("TextLabel").Text = plr.Name
                    elseif tag then tag:Destroy() end

                    -- [[ 2D VISUALS ]] --
                    local vector, onScreen = Camera:WorldToViewportPoint(root.Position)

                    -- 3. BOXES
                    local boxName = plr.Name .. "_Box"
                    local box = ESP_2D:FindFirstChild(boxName)
                    
                    if Config.ESP.Boxes and onScreen then
                        if not box then
                            box = Instance.new("Frame", ESP_2D); box.Name = boxName; box.BackgroundTransparency = 1; box.BorderSizePixel = 0
                            local s = Instance.new("UIStroke", box); s.Thickness = 1.5
                        end
                        
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local height = legPos.Y - headPos.Y
                        local width = height / 1.5

                        box.Size = UDim2.new(0, width, 0, height)
                        box.Position = UDim2.new(0, vector.X - (width/2), 0, headPos.Y)
                        box:FindFirstChild("UIStroke").Color = hl.FillColor
                        box.Visible = true
                    elseif box then box:Destroy() end
                    
                    -- 4. HEALTH BAR
                    local barName = plr.Name .. "_HealthBar"
                    local barOutline = ESP_2D:FindFirstChild(barName)
                    
                    if Config.ESP.Health and onScreen and hum then
                        if not barOutline then
                            barOutline = Instance.new("Frame", ESP_2D); barOutline.Name = barName; barOutline.BorderSizePixel = 1; barOutline.BorderColor3 = Color3.new(0,0,0); barOutline.BackgroundColor3 = Color3.fromRGB(60, 60, 60); barOutline.ZIndex = 2
                            local fill = Instance.new("Frame", barOutline); fill.Name = "Fill"; fill.BorderSizePixel = 0; fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0); fill.AnchorPoint = Vector2.new(0, 1); fill.Position = UDim2.new(0, 0, 1, 0); fill.ZIndex = 3
                        end
                        
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local height = legPos.Y - headPos.Y
                        local width = height / 1.5
                        
                        barOutline.Size = UDim2.new(0, 4, 0, height)
                        barOutline.Position = UDim2.new(0, (vector.X - (width/2)) + width + 2, 0, headPos.Y)
                        
                        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        barOutline.Fill.Size = UDim2.new(1, 0, healthPercent, 0)
                        barOutline.Visible = true
                    elseif barOutline then barOutline:Destroy() end

                    -- 5. TRACERS
                    local lineName = plr.Name .. "_Tracer"
                    local line = ESP_2D:FindFirstChild(lineName)
                    
                    if Config.ESP.Tracers and onScreen then
                        if not line then
                            line = Instance.new("Frame", ESP_2D); line.Name = lineName; line.BorderSizePixel = 0; line.AnchorPoint = Vector2.new(0.5, 0.5)
                        end
                        
                        local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        local endPos = Vector2.new(vector.X, vector.Y)
                        local length = (endPos - startPos).Magnitude
                        local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)

                        line.Size = UDim2.new(0, length, 0, 1.5)
                        line.Position = UDim2.new(0, (startPos.X + endPos.X) / 2, 0, (startPos.Y + endPos.Y) / 2)
                        line.Rotation = math.deg(angle)
                        line.BackgroundColor3 = hl.FillColor
                        line.Visible = true
                    elseif line then line:Destroy() end

                else
                    -- Player is dead, cleanup
                    CleanupESP(plr.Name)
                end
            else
                -- Player is invalid/loading, cleanup
                CleanupESP(plr.Name)
            end
        end
    else 
        -- Master Switch OFF - Clean everything
        for _, v in pairs(ESPFolder:GetChildren()) do if not v.Name:find("_ObjHighlight") then v:Destroy() end end
        ESP_2D:ClearAllChildren()
    end
    
    -- [[ OBJECT ESP LOGIC ]] --
    if Config.ESP.ShowObjects then
        for _, object in pairs(InteractableCache) do
            if object and object.Parent then
                local show = false
                if Config.ESP.ObjectMode == "All" then show = true
                elseif Config.ESP.ObjectMode == "Tools" and (object:IsA("Tool") or object:FindFirstChildWhichIsA("Tool")) then show = true
                elseif Config.ESP.ObjectMode == "Interactable" and (object:FindFirstChildWhichIsA("ProximityPrompt", true) or object:FindFirstChildWhichIsA("ClickDetector", true)) then show = true 
                elseif Config.ESP.ObjectMode == "NPCs" and object:IsA("Model") and object:FindFirstChild("Humanoid") then show = true end

                if show then
                    local objName = object.Name .. "_ObjHighlight"
                    local hl = ESPFolder:FindFirstChild(objName)
                    if not hl then hl = Instance.new("Highlight", ESPFolder); hl.Name = objName; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0 end
                    hl.Adornee = object
                    hl.FillColor = object:FindFirstChild("Humanoid") and Color3.fromRGB(255, 170, 0) or Color3.new(0, 1, 0)
                else
                    local hl = ESPFolder:FindFirstChild(object.Name .. "_ObjHighlight"); if hl then hl:Destroy() end
                end
            end
        end
    else
        for _, child in pairs(ESPFolder:GetChildren()) do if child.Name:find("_ObjHighlight") then child:Destroy() end end
    end
end)

-- // WALL CLIP LOGIC (FIXED RESTORE & RESET) //
local ModifiedParts, HoverPart, HoverOrigin = {}, nil, nil
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not Config.ESP.WallClip then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = LocalPlayer:GetMouse(); local target = mouse.Target
        if target and not target.Parent:FindFirstChild("Humanoid") and not target.Parent.Parent:FindFirstChild("Humanoid") then
            if ModifiedParts[target] then
                ModifiedParts[target] = nil
                if HoverPart == target then HoverOrigin = target.Transparency end
            else
                local trueOrigin = (HoverPart == target and HoverOrigin) or target.Transparency
                ModifiedParts[target] = trueOrigin; target.Transparency = Config.ESP.WallClipTrans
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if getgenv().WallClip_Reset then
        for part, original in pairs(ModifiedParts) do if part and part.Parent then part.Transparency = original end end
        ModifiedParts = {}; getgenv().WallClip_Reset = false
    end
    if Config.ESP.WallClip then
        local mouse = LocalPlayer:GetMouse(); local target = mouse.Target
        for part, _ in pairs(ModifiedParts) do if part and part.Parent then part.Transparency = Config.ESP.WallClipTrans else ModifiedParts[part] = nil end end
        if target ~= HoverPart then
            if HoverPart and not ModifiedParts[HoverPart] then if HoverOrigin then HoverPart.Transparency = HoverOrigin end end
            if target and not target.Parent:FindFirstChild("Humanoid") and not target.Parent.Parent:FindFirstChild("Humanoid") then
                HoverPart = target
                if not ModifiedParts[target] then HoverOrigin = target.Transparency; target.Transparency = Config.ESP.WallClipTrans else HoverOrigin = ModifiedParts[target] end
            else HoverPart = nil; HoverOrigin = nil end
        elseif HoverPart then
            if not ModifiedParts[HoverPart] then HoverPart.Transparency = Config.ESP.WallClipTrans end
        end
    else
        local count = 0
        for part, original in pairs(ModifiedParts) do if part and part.Parent then part.Transparency = original end count = count + 1 end
        if count > 0 then ModifiedParts = {} end
        if HoverPart and HoverOrigin and HoverPart.Parent then HoverPart.Transparency = HoverOrigin end
        HoverPart = nil; HoverOrigin = nil
    end
end)

-- Aimbot Loop
local aiming = false
UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Config.Aimbot.Key then aiming = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Config.Aimbot.Key then aiming = false end end)

RunService.RenderStepped:Connect(function()
    if aiming and Config.Aimbot.Enabled then
        local closest, maxDist = nil, Config.Aimbot.FOV
        local mousePos = UserInputService:GetMouseLocation()
        local camPos = Camera.CFrame.Position -- Get Camera Position for range check

        -- 1. Object Lockon Logic
        if Config.Aimbot.ObjectLockon then
            for _, obj in pairs(InteractableCache) do
                if obj and obj.Parent then 
                    local targetPart = obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChild("Handle") or obj
                    if targetPart and targetPart:IsA("BasePart") then
                        -- [NEW] Range Check
                        if (targetPart.Position - camPos).Magnitude <= Config.Aimbot.Range then
                            local pos, vis = Camera:WorldToViewportPoint(targetPart.Position)
                            if vis then 
                                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                if dist < maxDist then maxDist = dist; closest = targetPart end 
                            end
                        end
                    end
                end
            end
        end

        -- 2. Player Aimbot Logic
        if not closest then
            for _, p in pairs(Players:GetPlayers()) do
                local isTeammate = Config.Aimbot.TeamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team
                
                if p ~= LocalPlayer and p.Character and not Config.Aimbot.Whitelist[p.Name] and not isTeammate then
                    
                    local hum = p.Character:FindFirstChild("Humanoid")
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    
                    -- Check Validity & Range
                    local isTargetValid = true
                    if Config.Aimbot.HealthDetach and hum and hum.Health <= 0 then isTargetValid = false end
                    
                    -- [NEW] Distance Check (Player)
                    if root and (root.Position - camPos).Magnitude > Config.Aimbot.Range then
                        isTargetValid = false
                    end

                    if isTargetValid then
                        local targetP = nil
                        if Config.Aimbot.TargetMode == "Head" then 
                            targetP = p.Character:FindFirstChild("Head")
                        elseif Config.Aimbot.TargetMode == "Body" then 
                            targetP = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                        else
                            local h = p.Character:FindFirstChild("Head")
                            local b = p.Character:FindFirstChild("HumanoidRootPart")
                            if h and b then
                                local hPos = Camera:WorldToViewportPoint(h.Position)
                                local bPos = Camera:WorldToViewportPoint(b.Position)
                                if (Vector2.new(hPos.X, hPos.Y) - mousePos).Magnitude < (Vector2.new(bPos.X, bPos.Y) - mousePos).Magnitude then 
                                    targetP = h 
                                else 
                                    targetP = b 
                                end
                            end
                        end

                        if targetP then
                            local pos, vis = Camera:WorldToViewportPoint(targetP.Position)    
                            if vis then 
                                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                if dist < maxDist then 
                                    maxDist = dist
                                    closest = targetP 
                                end 
                            end
                        end
                    end
                end
            end
        end

        -- 3. Move Mouse to Target
        if closest then
            local pos = Camera:WorldToViewportPoint(closest.Position)
            mousemoverel((pos.X - mousePos.X)/Config.Aimbot.Smoothness, (pos.Y - mousePos.Y)/Config.Aimbot.Smoothness)
        end
    end
end)

-- // AUTO-ADD FEATURES TO CMD // --------------------------------------------
-- Movement
CMD_Add("speed", "Set Speed [val]", function(args) local v = tonumber(args[1]); if v then Config.Toggles.Speed = true; Config.Movement.WalkSpeed = v; return "Speed: "..v else Config.Toggles.Speed = false; return "Speed: Off" end end)
CMD_Add("jump", "Set Jump [val]", function(args) local v = tonumber(args[1]); if v then Config.Toggles.Jump = true; Config.Movement.JumpPower = v; return "Jump: "..v else Config.Toggles.Jump = false; return "Jump: Off" end end)
CMD_Add("fly", "Toggle Fly", function() Config.Toggles.Fly = not Config.Toggles.Fly; if not Config.Toggles.Fly then ResetMovement() end; return "Fly: "..tostring(Config.Toggles.Fly) end)
CMD_Add("safefly", "Toggle Safe Fly", function() Config.Toggles.SafeFly = not Config.Toggles.SafeFly; if not Config.Toggles.SafeFly then ResetMovement() end; return "SafeFly: "..tostring(Config.Toggles.SafeFly) end)
CMD_Add("noclip", "Toggle Noclip", function() Config.Toggles.Noclip = not Config.Toggles.Noclip; return "Noclip: "..tostring(Config.Toggles.Noclip) end)
CMD_Add("nograv", "Toggle No Gravity", function() Window:Notify("CMD", "Use UI for now"); return "Check UI" end)
CMD_Add("phase", "Phase Forward", function() local c = LocalPlayer.Character; if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist); return "Phased" end return "Error" end)
CMD_Add("instanttp", "Toggle Instant TP", function() Config.Movement.InstantTP = not Config.Movement.InstantTP; return "InstantTP: "..tostring(Config.Movement.InstantTP) end)
CMD_Add("airwalk", "Toggle AirWalk", function()
    -- Check if it is currently running (based on the connection variable)
    local isEnabled = (AirWalkCon ~= nil)
    
    -- If it's ON, we turn it OFF. If it's OFF, we turn it ON.
    local newState = not isEnabled

    -- Reuse the exact logic from your UI Toggle
    if newState then
        -- [[ TURN ON ]]
        
        -- 1. Create Platform
        if AirWalkPart then AirWalkPart:Destroy() end -- Safety check
        AirWalkPart = Instance.new("Part")
        AirWalkPart.Name = "RL_AirWalk"
        AirWalkPart.Size = Vector3.new(6, 1, 6)
        AirWalkPart.Transparency = 1 
        AirWalkPart.Anchored = true
        AirWalkPart.CanCollide = true
        AirWalkPart.Parent = workspace

        -- 2. Particles
        AirParticles = Instance.new("ParticleEmitter")
        AirParticles.Parent = AirWalkPart
        AirParticles.Texture = "rbxassetid://4758322939"
        AirParticles.Color = ColorSequence.new(Color3.new(1,1,1))
        AirParticles.Size = NumberSequence.new(1.5)
        AirParticles.Rate = 500
        AirParticles.Lifetime = NumberRange.new(0.5, 1)
        AirParticles.Transparency = NumberSequence.new(0.5, 1)
        AirParticles.Enabled = false

        -- 3. Logic Loop
        AirWalkCon = game:GetService("RunService").Heartbeat:Connect(function()
            local char = game:GetService("Players").LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if root and hum and AirWalkPart then
                local vel = root.AssemblyLinearVelocity
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char, AirWalkPart}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local hitGround = workspace:Raycast(root.Position, Vector3.new(0, -6, 0), rayParams)

                -- Reset if jumping or on ground
                if vel.Y > 0 or hitGround then
                    AirWalkPart.Position = Vector3.new(0, -1000, 0)
                    AirParticles.Enabled = false
                    LockedY = nil 
                else
                    -- Active AirWalk
                    if LockedY == nil then
                        LockedY = root.Position.Y - (hum.HipHeight + (root.Size.Y / 2) + 0.5)
                    end

                    -- Descend with Left Control
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
                        LockedY = LockedY - 0.5
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, -30, vel.Z)
                    else
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
                    end

                    AirWalkPart.CFrame = CFrame.new(root.Position.X, LockedY, root.Position.Z)
                    AirParticles.Enabled = true
                end
            end
        end)
        return "AirWalk: ON"
    else
        -- [[ TURN OFF ]]
        if AirWalkCon then AirWalkCon:Disconnect(); AirWalkCon = nil end
        if AirWalkPart then AirWalkPart:Destroy(); AirWalkPart = nil end
        LockedY = nil
        return "AirWalk: OFF"
    end
end)

-- Combat Section of CMD
CMD_Add("healthdetach", "Toggle Health Detach", function() 
    Config.Aimbot.HealthDetach = not Config.Aimbot.HealthDetach 
    return "HealthDetach: " .. tostring(Config.Aimbot.HealthDetach) 
end)

CMD_Add("carspeed", "Set Car Fly Speed [val]", function(args)
    local v = tonumber(args[1])
    if v then 
        CarFlySpeed = v
        return "CarSpeed: " .. v
    end
    return "Current Speed: " .. CarFlySpeed
end)

CMD_Add("carfly", "Toggle Car Fly", function()
    local isEnabled = (CarFlyCon ~= nil)
    ToggleCarFly(not isEnabled)
    return "CarFly Toggled"
end)

-- Visuals
CMD_Add("esp", "Toggle ESP", function() Config.ESP.Enabled = not Config.ESP.Enabled; return "ESP: "..tostring(Config.ESP.Enabled) end)
CMD_Add("names", "Toggle Names", function() Config.ESP.ShowNames = not Config.ESP.ShowNames; return "Names: "..tostring(Config.ESP.ShowNames) end)
CMD_Add("objects", "Toggle Objects", function() Config.ESP.ShowObjects = not Config.ESP.ShowObjects; return "Objects: "..tostring(Config.ESP.ShowObjects) end)
CMD_Add("fullbright", "Toggle Fullbright", function() Config.ESP.Fullbright = not Config.ESP.Fullbright; ToggleFullbright(Config.ESP.Fullbright); return "Fullbright: "..tostring(Config.ESP.Fullbright) end)
CMD_Add("wallclip", "Set WallClip Trans [val]", function(args) local v = tonumber(args[1]); if v then Config.ESP.WallClipTrans = v; return "Opacity: "..v end; Config.ESP.WallClip = not Config.ESP.WallClip; return "WallClip: "..tostring(Config.ESP.WallClip) end)
CMD_Add("fixwalls", "Reset WallClip", function() getgenv().WallClip_Reset = true; return "Walls Reset" end)

-- Combat
CMD_Add("aimbot", "Toggle Aimbot", function() Config.Aimbot.Enabled = not Config.Aimbot.Enabled; return "Aimbot: "..tostring(Config.Aimbot.Enabled) end)
CMD_Add("teamcheck", "Toggle TeamCheck", function() Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck; return "TeamCheck: "..tostring(Config.Aimbot.TeamCheck) end)

-- Fun / Weather
CMD_Add("rain", "Toggle Rain", function() Config.Fun.Rain = not Config.Fun.Rain; return "Rain: "..tostring(Config.Fun.Rain) end)
CMD_Add("snow", "Toggle Snow", function() Config.Fun.Snow = not Config.Fun.Snow; return "Snow: "..tostring(Config.Fun.Snow) end)
CMD_Add("time", "Set Time [0-24]", function(args) local v = tonumber(args[1]); if v then Config.Fun.Time = v; Lighting.ClockTime = v; return "Time: "..v end return "Invalid Time" end)

-- Player Interactions
CMD_Add("tp", "TP to [player]", function(args) 
    local name = args[1]; if not name then return "Name required" end
    for _, p in pairs(Players:GetPlayers()) do if p.Name:lower():sub(1, #name) == name:lower() then TeleportToPlayer(p); return "TP to "..p.Name end end
    return "Not Found" 
end)
CMD_Add("fling", "Fling [player]", function(args)
    local name = args[1]; if not name then return "Name required" end
    for _, p in pairs(Players:GetPlayers()) do 
        if p.Name:lower():sub(1, #name) == name:lower() then 
            FlingTargetName = p.Name; FlingingSingle = true
            Window:Notify("System", "Flinging " .. p.Name)
            EnablePhysics(true)
            task.spawn(function()
                while FlingingSingle do if p.Character then ProcessFling(p.Character.HumanoidRootPart) end RunService.Heartbeat:Wait() end
                EnablePhysics(false); if SafePos then LocalPlayer.Character.HumanoidRootPart.CFrame = SafePos end
            end)
            return "Flinging "..p.Name
        end 
    end
    return "Not Found"
end)
CMD_Add("cyclefling", "Fling All Loop", function() FlingingCycle = not FlingingCycle; return "CycleFling: "..tostring(FlingingCycle) end)
CMD_Add("stopfling", "Stop Flinging", function() FlingingSingle = false; FlingingCycle = false; return "Fling Stopped" end)
CMD_Add("antivoid", "Toggle AntiVoid", function() 
    Config.Misc.AntiVoid = not Config.Misc.AntiVoid
    UpdateAntiVoid(Config.Misc.AntiVoid)
    return "AntiVoid: "..tostring(Config.Misc.AntiVoid) 
end)
CMD_Add("attach", "Attach to [player]", function(args)
    local name = args[1]; if not name then return "Name required" end
    for _, p in pairs(Players:GetPlayers()) do if p.Name:lower():sub(1, #name) == name:lower() then AttachTargetName = p.Name; Attaching = true; return "Attached to "..p.Name end end
    return "Not Found"
end)
CMD_Add("stopattach", "Stop Attach", function() Attaching = false; return "Detached" end)
CMD_Add("spectate", "Spectate [player]", function(args)
    local name = args[1]; if not name then return "Name required" end
    for _, p in pairs(Players:GetPlayers()) do if p.Name:lower():sub(1, #name) == name:lower() then workspace.CurrentCamera.CameraSubject = p.Character.Humanoid; return "Watching "..p.Name end end
    return "Not Found"
end)
CMD_Add("unspectate", "Stop Spectating", function() if LocalPlayer.Character then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end return "Camera Reset" end)

-- // FINAL INITIALIZATION // ----------------------------------------------------------------
Window:Notify("System", "R-Loader Universal Injected")

-- Check for Whitelist and Notify
if IsUserWhitelisted() then
    task.wait(0.5) -- Slight delay to ensure the first notify doesn't overlap too quickly
    Window:Notify("Is Developer", "Full Access Granted: " .. LocalPlayer.Name)
end