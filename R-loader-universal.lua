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

-- // DISABLE SYSTEM // -----------------------------------------------------------------------
local DisabledFeatures = {}

-- Example: DisableFeature("Fly", true)
getgenv().DisableFeature = function(featureName, shouldDisable)
    DisabledFeatures[featureName] = shouldDisable
    
    -- Attempt to find the UI element dynamically to update the visual text
    local Core = game:GetService("CoreGui")
    if Core:FindFirstChild("RLoader_Universal_Remaster") then
        local UI = Core["RLoader_Universal_Remaster"]
        for _, obj in pairs(UI:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text == featureName then
                -- Check if it's inside a Toggle/Button Frame
                local parentBtn = obj.Parent
                if parentBtn:IsA("Frame") or parentBtn:IsA("TextButton") then
                    if shouldDisable then
                        obj.Text = featureName .. " (Disabled)"
                        obj.TextColor3 = Color3.fromRGB(150, 50, 50) -- Red tint
                        -- Disable interaction if possible (Visual indication mostly)
                    else
                        obj.Text = featureName
                        obj.TextColor3 = Color3.fromRGB(230, 230, 240) -- Reset color
                    end
                end
            end
        end
    end
end

local GameSpecificConfigs = {
    -- Example: Disabling Fly and Noclip for Game ID 9356971415
    [9356971415] = {"Fly", "Noclip"}, 
    
    -- Example: Disabling Instant Teleport for another game
    [1234567890] = {"Instant Teleport"},

}

-- // 2. CONFIGURATION DATA (PRESERVED FROM UNIVERSAL) // ------------------------------------
local Config = {
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Smoothness = 5,
        FOV = 300,
        TargetPart = "Head", -- Default
        TargetMode = "Head", -- New: Head, Body, Both
        ObjectLockon = false, -- New: Target Objects
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
        Fullbright = false
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
    },
    Fun = { -- New Tab Data
        Time = 12,
        Rain = false,
        Snow= false,
    },
    Binds = {
        ToggleUI = Enum.KeyCode.M,
        Phase = Enum.KeyCode.F,
        SavePos = Enum.KeyCode.H,
        Teleport = Enum.KeyCode.J,
        Fly = Enum.KeyCode.V,
        Noclip = Enum.KeyCode.B,
    },
    Toggles = {
        Fly = false,
        Noclip = false,
        Speed = false,
        Jump = false,
        SafeFly = false,
    }
}


-- Logic to apply the configuration automatically
local currentGameId = game.GameId
local configToApply = GameSpecificConfigs[currentGameId]

if configToApply then
    -- Optional: Notify user that features are being restricted
    task.delay(1, function() 
        if Window and Window.Notify then
            Window:Notify("System", "Restricted features disabled for this game.") 
        end
    end)

    for _, featureName in ipairs(configToApply) do
        -- 1. Call the global DisableFeature function to update UI text
        DisableFeature(featureName, true)
        
        -- 2. Force disable the actual variable in Config to stop logic immediately
        if Config.Toggles[featureName] ~= nil then
            Config.Toggles[featureName] = false
        elseif Config.Movement.InstantTP ~= nil and featureName == "Instant Teleport" then
            Config.Movement.InstantTP = false
        end
        
        -- 3. Safety Reset: If a movement feature was forced off, reset physics
        if featureName == "Fly" or featureName == "SafeFly" or featureName == "Noclip" then
            if LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if root then root.Anchored = false end
                if hum then 
                    hum.PlatformStand = false 
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
                end
            end
        end
    end
end

-- CONFIG SYSTEM (Universal Logic)
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
        
        -- Helper to safely load only if NOT disabled
        local function SafeLoad(category, key, value)
            -- If the feature is in our DisabledFeatures table, IGNORE the save data
            if DisabledFeatures[key] then return end
            
            -- Otherwise, load it normally
            if Config[category] and Config[category][key] ~= nil then
                Config[category][key] = value
            end
        end

        if decoded.Aimbot then for k,v in pairs(decoded.Aimbot) do SafeLoad("Aimbot", k, v) end end
        if decoded.ESP then for k,v in pairs(decoded.ESP) do SafeLoad("ESP", k, v) end end
        if decoded.Movement then for k,v in pairs(decoded.Movement) do SafeLoad("Movement", k, v) end end
        
        -- Special handling for Toggles since they are simple Key=Value pairs
        if decoded.Toggles then 
            for k,v in pairs(decoded.Toggles) do 
                if not DisabledFeatures[k] then -- CHECK DISABLE HERE
                    Config.Toggles[k] = v 
                end
            end 
        end

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

-- // 3. UI LIBRARY (IMPORTED FROM R-LOADER) // -----------------------------------------------
local Library = (function()
    local UILibrary = {}
    local theme = {
        Background = Color3.fromRGB(15, 15, 25), Sidebar = Color3.fromRGB(20, 18, 35),
        Header = Color3.fromRGB(25, 20, 40), Panel = Color3.fromRGB(28, 25, 45),
        Accent = Color3.fromRGB(138, 100, 255), AccentHover = Color3.fromRGB(158, 120, 255),
        ButtonBg = Color3.fromRGB(35, 30, 55), ButtonHover = Color3.fromRGB(45, 40, 65), 
        Text = Color3.fromRGB(230, 230, 240), TextDim = Color3.fromRGB(140, 135, 160), 
        Border = Color3.fromRGB(60, 50, 90), Error = Color3.fromRGB(255, 100, 120),
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
    local function tween(obj, props, t) TweenService:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

    function UILibrary:CreateWindow(config)
        local title = config.Title or "UI"
        local CurrentKeybind = Config.Binds.ToggleUI 

        local ScreenGui = create("ScreenGui", {
            Name = "RLoader_Universal_Remaster", 
            Parent = (gethui and gethui()) or CoreGui, 
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 10000, 
            IgnoreGuiInset = true 
        })

        local Container = create("Frame", {
            Size = UDim2.new(0, 700, 0, 500), 
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.Background,
            BackgroundTransparency = 0.1,
            Parent = ScreenGui,
            ClipsDescendants = true,
            Visible = true
        })
        roundify(Container, 12); addStroke(Container)

        -- Header
        local Header = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = theme.Header, BackgroundTransparency = 0.1, Parent = Container})
        roundify(Header, 12)
        create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = theme.Header, BackgroundTransparency = 0.1, Parent = Header, BorderSizePixel=0})
        
        -- Header Icon
        local HeaderIcon = create("ImageLabel", {
            Name = "HeaderIcon", Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 15, 0.5, -15),
            BackgroundTransparency = 1, Image = "https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/Image/Icons/R-loadertrans-Christmas.png",
            Parent = Header
        })
        
        create("TextLabel", {
            Text = title, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 55, 0, 0),          
            BackgroundTransparency = 1, TextColor3 = theme.Text, Font = theme.Font, TextSize = 18, 
            TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
        })

        -- Dragging
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

        local CloseBtn = create("TextButton", {Text = "X", Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-45,0,5), BackgroundTransparency = 1, TextColor3 = theme.Error, Font = Enum.Font.GothamBold, TextSize = 18, Parent = Header})
        CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

        -- Sidebar & Content
        local Sidebar = create("Frame", {Size = UDim2.new(0, 150, 1, -50), Position = UDim2.new(0,0,0,50), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.1, Parent = Container, BorderSizePixel = 0})
        create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
        create("Frame", {Size = UDim2.new(1, 0, 0, 15), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Sidebar})
        create("Frame", {Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Sidebar})

        local SidebarList = create("Frame", {Size = UDim2.new(1, 0, 1, -20), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, Parent = Sidebar})
        create("UIListLayout", {Parent = SidebarList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,5)})
        create("UIPadding", {Parent = SidebarList, PaddingTop = UDim.new(0,10)})

        local Content = create("Frame", {Size = UDim2.new(1, -160, 1, -60), Position = UDim2.new(0, 155, 0, 55), BackgroundTransparency = 1, Parent = Container})

        -- Notifications
        local NotifyFrame = create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -260, 0, 0), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100})
        create("UIListLayout", {Parent = NotifyFrame, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})
        create("UIPadding", {Parent = NotifyFrame, PaddingBottom = UDim.new(0, 20)})

        local Window = {ScreenGui = ScreenGui, Container = Container} 

        function Window:Notify(title, msg)
            local N = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1})
            roundify(N, 8); addStroke(N, theme.Accent)
            create("TextLabel", {Text = title, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = N})
            create("TextLabel", {Text = msg, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = N})
            N.Position = UDim2.new(1, 300, 0, 0)
            tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
            task.delay(4, function()
                tween(N, {BackgroundTransparency = 1}, 0.5)
                for _,v in pairs(N:GetChildren()) do if v:IsA("TextLabel") then tween(v, {TextTransparency=1}, 0.5) end end
                task.wait(0.5)
                N:Destroy()
            end)
        end
        
        -- Toggle UI Keybind
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Config.Binds.ToggleUI then
                Container.Visible = not Container.Visible
            end
        end)

        function Window:CreateCategory(name, icon)
            local TabBtn = create("TextButton", {
                Text = "   " .. (icon or "") .. "  " .. name, Size = UDim2.new(1, 0, 0, 35), 
                BackgroundColor3 = theme.Sidebar, BackgroundTransparency = 0.5, TextColor3 = theme.TextDim, 
                Font = theme.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = SidebarList, 
                BorderSizePixel = 0, Active = true
            })
            
            local TabFrame = create("ScrollingFrame", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, 
                Parent = Content, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout", {Parent = TabFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,10)})
            create("UIPadding", {Parent = TabFrame, PaddingRight = UDim.new(0,5), PaddingLeft = UDim.new(0,5), PaddingTop = UDim.new(0,5)})

            TabBtn.MouseButton1Click:Connect(function()
                for _,v in pairs(SidebarList:GetChildren()) do if v:IsA("TextButton") then tween(v, {BackgroundColor3 = theme.Sidebar, TextColor3 = theme.TextDim}, 0.2) end end
                for _,v in pairs(Content:GetChildren()) do v.Visible = false end
                tween(TabBtn, {BackgroundColor3 = theme.Background, TextColor3 = theme.Accent}, 0.2)
                TabFrame.Visible = true
            end)

            if name == "Main" or name == "Home" then -- Auto select first
                tween(TabBtn, {BackgroundColor3 = theme.Background, TextColor3 = theme.Accent}, 0.2)
                TabFrame.Visible = true
            end

            local Tab = {ScrollFrame = TabFrame}

            function Tab:Label(text)
                create("TextLabel", {Text = text, Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFrame})
            end

            function Tab:Button(text, callback)
                local Btn = create("TextButton", {Text = text, Size = UDim2.new(1,0,0,35), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency = 0.2, TextColor3 = theme.Text, Font = theme.Font, Parent = TabFrame})
                roundify(Btn, 6)
                Btn.MouseButton1Click:Connect(function() callback() end)
                return Btn
            end

function Tab:Toggle(text, default, callback)
                -- [[ 1. CHECK DISABLE STATUS FOR VISUALS ]]
                local isDisabled = DisabledFeatures[text]
                local displayText = isDisabled and (text .. " (Disabled)") or text
                local displayColor = isDisabled and Color3.fromRGB(200, 50, 50) or theme.Text

                local Frame = create("Frame", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame})
                roundify(Frame, 6)
                
                -- Apply the modified text and color here
                create("TextLabel", {
                    Text = displayText, 
                    Size = UDim2.new(1,-50,1,0), 
                    Position = UDim2.new(0,10,0,0), 
                    BackgroundTransparency = 1, 
                    TextColor3 = displayColor, 
                    Font = theme.Font, 
                    TextSize = 14, 
                    TextXAlignment = Enum.TextXAlignment.Left, 
                    Parent = Frame
                })
                
                local Indicator = create("TextButton", {Text="", Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-30,0.5,-10), BackgroundColor3 = default and theme.Accent or theme.Panel, Parent=Frame})
                roundify(Indicator, 4)
                
                local state = default
                
                Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isDisabled then 
                            Window:Notify("Restricted", text .. " is disabled for this game.")
                            return 
                        end
                        
                        state = not state
                        Indicator.BackgroundColor3 = state and theme.Accent or theme.Panel
                        callback(state)
                        SaveConfig()
                    end
                end)
            end

            function Tab:Slider(text, min, max, default, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame})
                roundify(Frame, 6)
                
                create("TextLabel", {Text = text, Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,10,0,5), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
                local ValueLabel = create("TextLabel", {Text = tostring(default), Size=UDim2.new(0,50,0,20), Position=UDim2.new(1,-60,0,5), BackgroundTransparency=1, TextColor3=theme.TextDim, Font=theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, Parent=Frame})
                
                local SliderBar = create("TextButton", {Text="", Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,35), BackgroundColor3=theme.Panel, AutoButtonColor=false, Parent=Frame})
                roundify(SliderBar, 3)
                
                local Fill = create("Frame", {Size=UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3=theme.Accent, Parent=SliderBar})
                roundify(Fill, 3)
                
                local dragging = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + ((max-min) * pos))
                    if max < 5 then val = math.floor((min + ((max-min) * pos))*100)/100 end
                    ValueLabel.Text = tostring(val)
                    callback(val)
                end
                
                SliderBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false; SaveConfig() end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            end

            function Tab:Binder(text, defaultKey, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame})
                roundify(Frame, 6)
                create("TextLabel", {Text = text, Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
                
                local BindBtn = create("TextButton", {Text = defaultKey.Name, Size=UDim2.new(0,80,0,25), Position=UDim2.new(1,-90,0.5,-12.5), BackgroundColor3=theme.Panel, TextColor3=theme.TextDim, Font=theme.Font, TextSize=12, Parent=Frame})
                roundify(BindBtn, 4)
                
                BindBtn.MouseButton1Click:Connect(function()
                    BindBtn.Text = "..."
                    BindBtn.TextColor3 = theme.Accent
                    local input = UserInputService.InputBegan:Wait()
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = theme.TextDim
                        callback(input.KeyCode)
                        SaveConfig()
                    else
                        BindBtn.Text = defaultKey.Name
                    end
                end)
            end

function Tab:Dropdown(text, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame, ClipsDescendants=true})
                roundify(Frame, 6)
                local Header = create("TextButton", {Text = text .. " ▼", Size = UDim2.new(1,0,0,35), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=14, Parent=Frame})
                
                -- [[ SCROLLBAR UPDATE ]]
                -- Changed from "Frame" to "ScrollingFrame"
                local List = create("ScrollingFrame", {
                    Size=UDim2.new(1,0,1,-35), 
                    Position=UDim2.new(0,0,0,35), 
                    BackgroundTransparency=1, 
                    Parent=Frame,
                    CanvasSize = UDim2.new(0,0,0,0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y, -- Auto-calculates scroll height
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = theme.Accent
                })
                create("UIListLayout", {Parent=List})
                
                local function Refresh()
                    for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            local OptBtn = create("TextButton", {Text = p.Name, Size = UDim2.new(1,0,0,30), BackgroundColor3 = theme.Panel, BackgroundTransparency=0.2, TextColor3 = theme.Text, Font = theme.Font, TextSize = 13, Parent = List})
                            OptBtn.MouseButton1Click:Connect(function() 
                                callback(p.Name)
                                Window:Notify("System", "Selected: "..p.Name) 
                                -- Optional: Close on select
                                -- tween(Frame, {Size = UDim2.new(1,0,0,35)}, 0.2)
                            end)
                        end
                    end
                end

                local open = false
                Header.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        Refresh()
                        -- Expand to 200px (Scrolling area)
                        tween(Frame, {Size = UDim2.new(1,0,0, 200)}, 0.2)
                    else
                        tween(Frame, {Size = UDim2.new(1,0,0,35)}, 0.2)
                    end
                end)
            end

            return Tab
        end
        return Window, theme
    end
    return UILibrary
end)()

-- // 4. WINDOW CREATION // -------------------------------------------------------------------
local Window, Theme = Library:CreateWindow({Title = "R-Loader | Universal"})
local MainTab = Window:CreateCategory("Main", "🏠")
local CombatTab = Window:CreateCategory("Combat", "🎯")
local VisualsTab = Window:CreateCategory("Visuals", "👁️")
local MoveTab = Window:CreateCategory("Movement", "💨")
local TPTab = Window:CreateCategory("Players", "👥")
local MiscTab = Window:CreateCategory("Misc", "⚙️")
local KeybindsTab = Window:CreateCategory("Binds", "⌨️")

-- // MAIN TAB //
-- // MAIN TAB //
MainTab:Label("Welcome to R-Loader Universal")
MainTab:Label("User: " .. LocalPlayer.Name)
MainTab:Label("Status: Undetected")
MainTab:Button("Copy Game ID", function() 
    setclipboard(tostring(game.GameId))
    Window:Notify("System", "Game ID Copied!") 
end)
MainTab:Button("Unload UI", function() SaveConfig(); Window.ScreenGui:Destroy() end)

-- // COMBAT TAB //
local TgtBtn
CombatTab:Toggle("Aimbot Enabled", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
TgtBtn = CombatTab:Button("Target Mode: " .. Config.Aimbot.TargetMode, function()
    -- 1. Cycle the mode
    if Config.Aimbot.TargetMode == "Head" then 
        Config.Aimbot.TargetMode = "Body"
    elseif Config.Aimbot.TargetMode == "Body" then 
        Config.Aimbot.TargetMode = "Both"
    else 
        Config.Aimbot.TargetMode = "Head" 
    end
    
    -- 2. Update the button text immediately
    TgtBtn.Text = "Target Mode: " .. Config.Aimbot.TargetMode
    Window:Notify("System", "Target Set to: " .. Config.Aimbot.TargetMode)
end)

CombatTab:Toggle("Object Lockon", Config.Aimbot.ObjectLockon, function(v) 
    Config.Aimbot.ObjectLockon = v 
end)
CombatTab:Slider("Smoothness", 1, 20, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end)
CombatTab:Slider("FOV Size", 50, 800, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
CombatTab:Label("Whitelist Player:")
CombatTab:Dropdown("Select to Whitelist", function(name)
    Config.Aimbot.Whitelist[name] = true
    SaveConfig()
end)
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

-- // VISUALS TAB //
VisualsTab:Toggle("ESP Enabled", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
VisualsTab:Toggle("Show Names", Config.ESP.ShowNames, function(v) Config.ESP.ShowNames = v end)

-- New Object ESP Controls
VisualsTab:Toggle("Show Objects", Config.ESP.ShowObjects, function(v) Config.ESP.ShowObjects = v end)
-- [[ FIXED OBJECT MODE SELECTOR ]]
local ObjBtn
ObjBtn = VisualsTab:Button("Obj Mode: " .. Config.ESP.ObjectMode, function()
    -- 1. Cycle the mode
    if Config.ESP.ObjectMode == "Interactable" then 
        Config.ESP.ObjectMode = "Tools"
    elseif Config.ESP.ObjectMode == "Tools" then 
        Config.ESP.ObjectMode = "All"
    else 
        Config.ESP.ObjectMode = "Interactable" 
    end
    
    -- 2. Update the button text immediately
    ObjBtn.Text = "Obj Mode: " .. Config.ESP.ObjectMode
    Window:Notify("System", "Object ESP: " .. Config.ESP.ObjectMode)
end)

VisualsTab:Slider("Fullbright Level", 0, 10, Config.ESP.Fullbrightness, function(v) Config.ESP.Fullbrightness = v end)
VisualsTab:Toggle("Enable Fullbright", Config.ESP.Fullbright, function(v) Config.ESP.Fullbright = v; ToggleFullbright(v) end)

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

MoveTab:Toggle("Instant Teleport", Config.Movement.InstantTP, function(v)
    if DisabledFeatures["Instant Teleport"] then return end -- Logic check
    Config.Movement.InstantTP = v
end)

MoveTab:Button("Save Position (Bind: H)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Window:Notify("System", "Position Saved")
    end
end)

MoveTab:Button("Teleport to Saved (Bind: J)", function()
    if not Config.Movement.SavedCFrame then Window:Notify("Error", "No Saved Pos!"); return end
    
    -- INSTANT TELEPORT LOGIC
    if Config.Movement.InstantTP then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Config.Movement.SavedCFrame
            Window:Notify("System", "Teleported Instantly")
        end
        return
    end

    -- LEGACY (TWEEN) LOGIC
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

-- // PLAYER TELEPORT & LOGS TAB (CUSTOM UI) //
-- Recreating the complex logic from Universal within the new UI structure
local TPPage = TPTab.ScrollFrame
local isTPingToPlayer = false
local liveUpdateEnabled = true
local trackedPlayers = {}

-- Custom Buttons for Switching Modes
local SwitchContainer = Instance.new("Frame", TPPage)
SwitchContainer.Size = UDim2.new(1, 0, 0, 35)
SwitchContainer.BackgroundTransparency = 1
local ListLayout = Instance.new("UIListLayout", SwitchContainer)
ListLayout.FillDirection = Enum.FillDirection.Horizontal
ListLayout.Padding = UDim.new(0, 10)

local ModeListBtn = Instance.new("TextButton", SwitchContainer)
ModeListBtn.Size = UDim2.new(0.5, -5, 1, 0)
ModeListBtn.BackgroundColor3 = Theme.Accent
ModeListBtn.Text = "Player List"
ModeListBtn.TextColor3 = Theme.Text
ModeListBtn.Font = Theme.Font
Instance.new("UICorner", ModeListBtn).CornerRadius = UDim.new(0, 6)

local ModeLogsBtn = Instance.new("TextButton", SwitchContainer)
ModeLogsBtn.Size = UDim2.new(0.5, -5, 1, 0)
ModeLogsBtn.BackgroundColor3 = Theme.ButtonBg
ModeLogsBtn.Text = "Logs"
ModeLogsBtn.TextColor3 = Theme.TextDim
ModeLogsBtn.Font = Theme.Font
Instance.new("UICorner", ModeLogsBtn).CornerRadius = UDim.new(0, 6)

local ListContainer = Instance.new("Frame", TPPage)
ListContainer.Size = UDim2.new(1, 0, 0, 300) -- Fixed height for scroll
ListContainer.BackgroundTransparency = 1
ListContainer.Visible = true

local LogsContainer = Instance.new("ScrollingFrame", TPPage)
LogsContainer.Size = UDim2.new(1, 0, 0, 300)
LogsContainer.BackgroundTransparency = 1
LogsContainer.Visible = false
LogsContainer.ScrollBarThickness = 2
local LogsLayout = Instance.new("UIListLayout", LogsContainer)
LogsLayout.SortOrder = Enum.SortOrder.LayoutOrder

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
    local LL = Instance.new("UIListLayout", ListContainer); LL.Padding = UDim.new(0, 5)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local distText = "?"
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                distText = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
            end
            local btn = Instance.new("TextButton", ListContainer)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Theme.ButtonBg
            btn.BackgroundTransparency = 0.2
            btn.Text = "  " .. plr.Name .. " [" .. distText .. " studs]"
            btn.TextColor3 = Theme.Text
            btn.Font = Theme.Font
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function() TeleportToPlayer(plr) end)
        end
    end
end

-- Live Update Loop for Player List
task.spawn(function()
    while true do
        if liveUpdateEnabled and ListContainer.Visible then RefreshPlayerList() end
        task.wait(1)
    end
end)

-- Logging Logic
local function AddLog(text, color)
    local label = Instance.new("TextLabel", LogsContainer)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Text = text
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    LogsContainer.CanvasPosition = Vector2.new(0, 99999)
end

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msgObj)
        local source = msgObj.TextSource
        if source then
            local plr = Players:GetPlayerByUserId(source.UserId)
            if plr and plr ~= LocalPlayer then AddLog("["..plr.Name.."]: " .. msgObj.Text, Color3.fromRGB(255, 235, 59)) end
        end
    end)
else
    local function ConnectChat(plr)
        plr.Chatted:Connect(function(msg) AddLog("["..plr.Name.."]: " .. msg, Color3.fromRGB(255, 235, 59)) end)
    end
    for _, p in pairs(Players:GetPlayers()) do ConnectChat(p) end
    Players.PlayerAdded:Connect(ConnectChat)
end

-- // MISC TAB //
MiscTab:Toggle("Fly", Config.Toggles.Fly, function(v) 
    Config.Toggles.Fly = v 
    if not v then ResetMovement() end
end)
MiscTab:Slider("Fly Speed", 10, 200, Config.Movement.FlySpeed, function(v) Config.Movement.FlySpeed = v end)

MiscTab:Toggle("Enable Safe Fly", Config.Toggles.SafeFly, function(v) 
    Config.Toggles.SafeFly = v 
    if not v then ResetMovement() end
end)
MiscTab:Slider("Safe Fly Speed", 10, 200, Config.Movement.SafeFlySpeed, function(v) Config.Movement.SafeFlySpeed = v end)

MiscTab:Toggle("Noclip", Config.Toggles.Noclip, function(v) Config.Toggles.Noclip = v end)

MiscTab:Toggle("Force 3rd Person", false, function(v)
    if v then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 100
        LocalPlayer.CameraMinZoomDistance = 10 -- Forces camera back 10 studs
    else
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5 -- Allows scrolling back in
    end
end)


-- // FUN TAB & WEATHER SYSTEM //
local FunTab = Window:CreateCategory("Fun", "🎉")
local Lighting = game:GetService("Lighting")

-- 1. TIME CONTROL
FunTab:Label("--- Time Control ---")
FunTab:Slider("Time of Day", 0, 24, Config.Fun.Time, function(v)
    Config.Fun.Time = v
    Lighting.ClockTime = v
end)

-- 2. WEATHER SYSTEM
FunTab:Label("--- Weather ---")

-- Folder to keep workspace clean
local WeatherFolder = workspace:FindFirstChild("RLoader_Weather") or Instance.new("Folder", workspace)
WeatherFolder.Name = "RLoader_Weather"

local SnowConnection = nil
local RainConnection = nil

-- SKYBOX MANAGEMENT
local StoredSky = nil -- To save the game's original sky
local ActiveSky = nil -- To track our custom sky

local function SetCustomSky(mode)
    -- 1. Save Original Sky (if we haven't yet)
    local currentSky = Lighting:FindFirstChildOfClass("Sky")
    if currentSky and currentSky.Name ~= "RLoader_Sky" then
        if not StoredSky then
            StoredSky = currentSky
            StoredSky.Parent = nil -- Hide it temporarily
        end
    end

    -- 2. Remove any existing custom sky
    if ActiveSky then ActiveSky:Destroy() ActiveSky = nil end

    -- 3. Apply New Sky (if mode is set)
    if mode then
        local s = Instance.new("Sky")
        s.Name = "RLoader_Sky"
        
        local asset = ""
        
        if mode == "Rain" then
            asset = "rbxassetid://169591672" -- Dark Stormy Sky
            s.SunTextureId = "" -- Hide sun for storm
            s.MoonTextureId = ""
            Lighting.Brightness = 0.5 -- Darken lighting
            
        elseif mode == "Snow" then
            asset = "rbxassetid://606626507" -- Cold Winter Sky
            Lighting.Brightness = 1.5 -- Brighten for reflection
        end
        
        -- [[ YOUR OPTIMIZED LOOP ]]
        for _, name in pairs({"Bk", "Dn", "Ft", "Lf", "Rt", "Up"}) do
            s["Skybox"..name] = asset
        end
        
        s.Parent = Lighting
        ActiveSky = s
    else
        -- 4. Restore Original Sky (if turning off)
        if StoredSky then
            StoredSky.Parent = Lighting
            StoredSky = nil
            Lighting.Brightness = 1 -- Reset brightness default
        end
    end
end

-- SNOWFLAKE LOGIC (Part Based)
local function CreateSnowflake()
    if not Config.Fun.Snow then return end
    local cam = workspace.CurrentCamera
    -- Spawn random position high above camera
    local startPos = cam.CFrame.Position + Vector3.new(math.random(-60, 60), 40, math.random(-60, 60))
    
    local snowflake = Instance.new("Part")
    snowflake.Name = "RL_Snowflake"
    snowflake.Size = Vector3.new(0.3, 0.3, 0.3)
    snowflake.Anchored = true
    snowflake.CanCollide = false
    snowflake.Transparency = 0.5
    snowflake.BrickColor = BrickColor.new("White")
    
    local decal = Instance.new("Decal")
    decal.Texture = "rbxassetid:/82374748"
    decal.Face = Enum.NormalId.Top
    decal.Parent = snowflake
    
    snowflake.Position = startPos
    snowflake.Parent = WeatherFolder
    
    -- Tween down
    local fallTween = TweenService:Create(snowflake, TweenInfo.new(math.random(30, 50)/10, Enum.EasingStyle.Linear), {
        Position = startPos - Vector3.new(0, 50, 0),
        Transparency = 1 
    })
    fallTween:Play()
    fallTween.Completed:Connect(function() snowflake:Destroy() end)
end

-- RAINDROP LOGIC (Part Based)
local function CreateRainDrop()
    if not Config.Fun.Rain then return end
    local cam = workspace.CurrentCamera
    local startPos = cam.CFrame.Position + Vector3.new(math.random(-50, 50), 45, math.random(-50, 50))
    
    local raindrop = Instance.new("Part")
    raindrop.Name = "RL_Raindrop"
    raindrop.Size = Vector3.new(0.1, 0.8, 0.1) 
    raindrop.Anchored = true
    raindrop.CanCollide = false
    raindrop.Transparency = 0.4
    raindrop.BrickColor = BrickColor.new("Electric blue")
    raindrop.Material = Enum.Material.SmoothPlastic
    
    local decal = Instance.new("Decal")
    decal.Texture = "rbxassetid://244222409"
    decal.Face = Enum.NormalId.Front
    decal.Transparency = 0.2
    decal.Parent = raindrop
    
    raindrop.Position = startPos
    raindrop.Parent = WeatherFolder
    
    -- Fast fall
    local fallTween = TweenService:Create(raindrop, TweenInfo.new(math.random(4, 6)/10, Enum.EasingStyle.Linear), {
        Position = startPos - Vector3.new(0, 60, 0),
        Transparency = 0.8
    })
    fallTween:Play()
    fallTween.Completed:Connect(function() raindrop:Destroy() end)
end

FunTab:Toggle("Enable Snow", Config.Fun.Snow, function(v)
    Config.Fun.Snow = v
    
    if v then
        if Config.Fun.Rain then -- Turn off Rain if active
            Config.Fun.Rain = false 
            if RainConnection then RainConnection:Disconnect() RainConnection = nil end
        end
        
        SetCustomSky("Snow")
        
        if not SnowConnection then
            SnowConnection = RunService.Heartbeat:Connect(function()
                if math.random() < 0.3 then 
                    CreateSnowflake()
                    if math.random() < 0.5 then CreateSnowflake() end
                end
            end)
        end
    else
        SetCustomSky(nil)
        if SnowConnection then SnowConnection:Disconnect() SnowConnection = nil end
        -- Clean up parts
        for _, v in pairs(WeatherFolder:GetChildren()) do if v.Name == "RL_Snowflake" then v:Destroy() end end
    end
end)

FunTab:Toggle("Enable Rain", Config.Fun.Rain, function(v)
    Config.Fun.Rain = v
    
    if v then
        if Config.Fun.Snow then -- Turn off Snow if active
            Config.Fun.Snow = false 
            if SnowConnection then SnowConnection:Disconnect() SnowConnection = nil end
        end
        
        SetCustomSky("Rain")

        if not RainConnection then
            RainConnection = RunService.Heartbeat:Connect(function()
                for i = 1, 3 do CreateRainDrop() end
            end)
        end
    else
        SetCustomSky(nil)
        if RainConnection then RainConnection:Disconnect() RainConnection = nil end
        -- Clean up parts
        for _, v in pairs(WeatherFolder:GetChildren()) do if v.Name == "RL_Raindrop" then v:Destroy() end end
    end
end)

-- [[ SPECTATE SYSTEM ]]
FunTab:Label("--- Spectate ---")
FunTab:Dropdown("Spectate Player", function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChild("Humanoid")
        Window:Notify("System", "Spectating: " .. name)
    end
end)

FunTab:Button("Stop Spectating", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        Window:Notify("System", "Stopped Spectating")
    end
end)

-- // 3. PLAYER INTERACTIONS //
FunTab:Label("--- Player Interactions ---")

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variables
local FlingTargetName = nil
local AttachTargetName = nil
local AttachPos = "Back" 
local CycleDuration = 2
local SafePos = nil -- Stores return position

-- Toggles
local FlingingSingle = false
local FlingingCycle = false
local Attaching = false

-- // HELPER: PHYSICS & NOCLIP //
local function EnablePhysics(enable)
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if enable then
        -- TURN ON FLING PHYSICS
        if hum then 
            hum.PlatformStand = true 
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        
        -- Anti-Fall (BodyVelocity)
        if root and not root:FindFirstChild("FlingHover") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlingHover"
            bv.Parent = root
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Velocity = Vector3.zero 
        end
        
        -- Noclip
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        -- TURN OFF / RESET
        if hum then 
            hum.PlatformStand = false 
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        if root then
            -- Remove Hover
            local bv = root:FindFirstChild("FlingHover")
            if bv then bv:Destroy() end
            
            -- Stop Spinning
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end
end

-- // HELPER: FLING ACTION //
-- This runs one "tick" of flinging logic
local function ProcessFling(targetRoot)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then

        local Wave = math.sin(tick() * 100)
        local VerticalOffset = math.sign(Wave) * 10 -- Move up/down by 10 studs
        
        myRoot.CFrame = CFrame.new(targetRoot.Position) * CFrame.new(0, VerticalOffset, 0)
        
        myRoot.AssemblyAngularVelocity = Vector3.new(0, 100000, 0) 

        myRoot.AssemblyLinearVelocity = Vector3.zero 
    end
end

-- [[ SINGLE TARGET FLING ]]
FunTab:Dropdown("Select Fling Target", function(name)
    FlingTargetName = name
    Window:Notify("System", "Fling Target: " .. name)
end)

FunTab:Toggle("Fling Player", false, function(v)
    FlingingSingle = v
    
    if v then
        -- Save Safe Position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SafePos = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        
        Window:Notify("System", "Flinging: " .. (FlingTargetName or "None"))
        EnablePhysics(true)
        
        task.spawn(function()
            while FlingingSingle do
                local target = Players:FindFirstChild(FlingTargetName)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    ProcessFling(target.Character.HumanoidRootPart)
                end
                RunService.Heartbeat:Wait() 
            end
            
            -- Cleanup
            EnablePhysics(false)
            if SafePos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = SafePos
            end
        end)
    else
        Window:Notify("System", "Fling Stopped")
    end
end)


-- [[ CYCLE FLING ALL ]]
FunTab:Label("--- Cycle Fling ---")

FunTab:Slider("Duration Per Player", 0.5, 5, CycleDuration, function(v)
    CycleDuration = v
end)

FunTab:Toggle("Cycle Fling All", false, function(v)
    FlingingCycle = v
    
    if v then
        -- 1. Save Safe Position ONCE
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SafePos = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        
        Window:Notify("System", "Cycle Mode: ON")
        EnablePhysics(true)
        
        task.spawn(function()
            while FlingingCycle do
                local potentialTargets = Players:GetPlayers()
                
                for _, plr in pairs(potentialTargets) do
                    -- Checks: Must be enabled, not us, and player must exist
                    if not FlingingCycle then break end
                    
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        
                        local timer = tick()
                        -- [[ ATTACK LOOP FOR THIS PLAYER ]]
                        while (tick() - timer) < CycleDuration and FlingingCycle do
                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                ProcessFling(plr.Character.HumanoidRootPart)
                            else
                                break -- Player died/left, move to next immediately
                            end
                            RunService.Heartbeat:Wait()
                        end
                        
                        -- Slight pause to stabilize before next target
                        task.wait(0.05)
                    end
                end
                
                -- Wait before restarting the list
                task.wait(0.5) 
            end
            
            -- Cleanup
            EnablePhysics(false)
            if SafePos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = SafePos
                Window:Notify("System", "Returned Safe")
            end
        end)
    else
        Window:Notify("System", "Cycle Mode: OFF")
    end
end)


-- [[ ATTACH SYSTEM (Preserved) ]]
FunTab:Label("--- Attach ---")

FunTab:Dropdown("Select Attach Target", function(name)
    AttachTargetName = name
    Window:Notify("System", "Attach Target: " .. name)
end)

local PosBtn
PosBtn = FunTab:Button("Position: " .. AttachPos, function()
    if AttachPos == "Back" then AttachPos = "Front" 
    elseif AttachPos == "Front" then AttachPos = "Under"
    else AttachPos = "Back" end
    PosBtn.Text = "Position: " .. AttachPos
end)

FunTab:Toggle("Attach to Player", false, function(v)
    Attaching = v
    if v then
        Window:Notify("System", "Attached to: " .. (AttachTargetName or "None"))
        task.spawn(function()
            while Attaching do
                local target = Players:FindFirstChild(AttachTargetName)
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myRoot then
                    local tRoot = target.Character.HumanoidRootPart
                    local offset
                    if AttachPos == "Back" then offset = CFrame.new(0, 0, 2)
                    elseif AttachPos == "Front" then offset = CFrame.new(0, 0, -2) * CFrame.Angles(0, math.pi, 0)
                    else offset = CFrame.new(0, -8, 0) * CFrame.Angles(math.rad(90), 0, 0) end
                    
                    myRoot.CFrame = tRoot.CFrame * offset
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.Velocity = Vector3.zero
                end
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

-- // KEYBINDS TAB //
KeybindsTab:Binder("Toggle UI", Config.Binds.ToggleUI, function(k) Config.Binds.ToggleUI = k end)
KeybindsTab:Binder("Phase", Config.Binds.Phase, function(k) Config.Binds.Phase = k end)
KeybindsTab:Binder("Save Position", Config.Binds.SavePos, function(k) Config.Binds.SavePos = k end)
KeybindsTab:Binder("Teleport", Config.Binds.Teleport, function(k) Config.Binds.Teleport = k end)
KeybindsTab:Binder("Fly Toggle", Config.Binds.Fly, function(k) Config.Binds.Fly = k end)
KeybindsTab:Binder("Noclip Toggle", Config.Binds.Noclip, function(k) Config.Binds.Noclip = k end)

-- // 5. LOGIC LOOPS & RUNTIME // -------------------------------------------------------------

-- Input Handling for Keybinds
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Config.Binds.Phase then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (Camera.CFrame.LookVector * Config.Movement.PhaseDist)
        end
    elseif input.KeyCode == Config.Binds.SavePos then
        if LocalPlayer.Character then
            Config.Movement.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            Window:Notify("System", "Position Saved")
        end
    elseif input.KeyCode == Config.Binds.Fly then
        Config.Toggles.Fly = not Config.Toggles.Fly
        if not Config.Toggles.Fly then ResetMovement() end
        Window:Notify("System", "Fly: " .. tostring(Config.Toggles.Fly))
        
    elseif input.KeyCode == Config.Binds.Noclip then
        Config.Toggles.Noclip = not Config.Toggles.Noclip
        Window:Notify("System", "Noclip: " .. tostring(Config.Toggles.Noclip))
    
    elseif input.KeyCode == Config.Binds.Teleport then
        if not Config.Movement.SavedCFrame then return end
        if isTeleporting then isTeleporting = false; Window:Notify("System", "TP Stopped"); return end
        
        isTeleporting = true
        Window:Notify("System", "Teleporting...")
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
-- Movement Loop (Fly, Speed, Jump)
RunService.RenderStepped:Connect(function(deltaTime)
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not root or not hum then return end

    if Config.Toggles.Fly then
        -- [[ FIX: DO NOT ANCHOR ]]
        -- Keeping Anchored = false ensures the server updates your hitbox position
        root.Anchored = false 
        hum.PlatformStand = true -- Disables standard physics/animations
        
        local moveDir = Vector3.zero
        local camCF = Camera.CFrame
        
        -- Calculate Direction
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        -- Apply Movement
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * (Config.Movement.FlySpeed * deltaTime)
            root.CFrame = root.CFrame + moveDir
        end
        
        -- [[ FIX: PHYSICS FREEZE ]]
        -- Instantly kill gravity and momentum so you don't fall
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Velocity = Vector3.zero 

    elseif Config.Toggles.SafeFly then
        -- Safe Fly Logic (Unchanged, physics based)
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        hum.PlatformStand = false
        local moveDir = Vector3.zero
        local camCF = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * Config.Movement.SafeFlySpeed
        end
        root.AssemblyLinearVelocity = moveDir
        root.AssemblyAngularVelocity = Vector3.zero
    end
end)

-- Noclip & Stats Loop
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
    
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if Config.Toggles.Speed then hum.WalkSpeed = Config.Movement.WalkSpeed end
        if Config.Toggles.Jump then hum.UseJumpPower = true; hum.JumpPower = Config.Movement.JumpPower end
    end
end)

-- ESP System
local ESPFolder = Instance.new("Folder", CoreGui); ESPFolder.Name = "RLoaderESP_Universal"
local InteractableCache = {}

local function CacheInteractable(obj)
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        if obj.Parent and (obj.Parent:IsA("BasePart") or obj.Parent:IsA("Model")) then
            table.insert(InteractableCache, obj.Parent)
        end
    end
end
for _, descendant in pairs(workspace:GetDescendants()) do CacheInteractable(descendant) end
workspace.DescendantAdded:Connect(CacheInteractable)

RunService.RenderStepped:Connect(function()
    if Config.ESP.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hlName = plr.Name .. "_Highlight"
                local hl = ESPFolder:FindFirstChild(hlName)
                if not hl then
                    hl = Instance.new("Highlight", ESPFolder); hl.Name = hlName
                    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                end
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(Config.ESP.Fill.R, Config.ESP.Fill.G, Config.ESP.Fill.B)
                hl.OutlineColor = Color3.fromRGB(Config.ESP.Outline.R, Config.ESP.Outline.G, Config.ESP.Outline.B)

                local tagName = plr.Name .. "_Tag"
                local tag = ESPFolder:FindFirstChild(tagName)
                if Config.ESP.ShowNames then
                    if not tag then
                        tag = Instance.new("BillboardGui", ESPFolder); tag.Name = tagName; tag.AlwaysOnTop = true
                        tag.Size = UDim2.new(0, 200, 0, 50); tag.StudsOffset = Vector3.new(0, -5, 0)
                        local label = Instance.new("TextLabel", tag); label.BackgroundTransparency = 1; label.Size = UDim2.new(1,0,1,0)
                        label.TextColor3 = Color3.new(1,1,1); label.TextSize = 13; label.Font = Enum.Font.GothamBold; label.Text = plr.Name
                    end
                    tag.Adornee = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.Head
                elseif tag then tag:Destroy() end
            end
        end
    else
        ESPFolder:ClearAllChildren()
    end
    
-- ========================================================================
    -- BLOCK B: OBJECT ESP (UPDATED)
    -- ========================================================================
    if Config.ESP.ShowObjects then
        for _, object in pairs(InteractableCache) do
            if object and object.Parent then
                local show = false
                
                -- Filter based on Dropdown Mode
                if Config.ESP.ObjectMode == "All" then
                    show = true
                elseif Config.ESP.ObjectMode == "Tools" then
                    if object:IsA("Tool") or object:FindFirstChildWhichIsA("Tool") then show = true end
                elseif Config.ESP.ObjectMode == "Interactable" then
                    -- Check cache source (ProximityPrompt/ClickDetector)
                    if object:FindFirstChildWhichIsA("ProximityPrompt", true) or object:FindFirstChildWhichIsA("ClickDetector", true) then
                        show = true
                    end
                end

                if show then
                    local objName = object.Name .. "_ObjHighlight"
                    local hl = ESPFolder:FindFirstChild(objName)
                    if not hl then
                        hl = Instance.new("Highlight", ESPFolder); hl.Name = objName
                        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                    end
                    hl.Adornee = object; hl.FillColor = Color3.new(0, 1, 0)
                else
                    -- Hide if mode switched
                    local hl = ESPFolder:FindFirstChild(object.Name .. "_ObjHighlight")
                    if hl then hl:Destroy() end
                end
            end
        end
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
        -- 1. OBJECT LOCKON LOGIC
        if Config.Aimbot.ObjectLockon then
            for _, obj in pairs(InteractableCache) do
                if obj and obj.Parent then -- Ensure valid
                    local targetPart = obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChild("Handle") or obj
                    if targetPart and targetPart:IsA("BasePart") then
                        local pos, vis = Camera:WorldToViewportPoint(targetPart.Position)
                        if vis then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < maxDist then maxDist = dist; closest = targetPart end
                        end
                    end
                end
            end
        end

        -- 2. PLAYER LOCKON LOGIC (Only if no object found or Object Lockon is off)
        if not closest then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not Config.Aimbot.Whitelist[p.Name] then
                    -- Determine Target Part
                    local targetP = nil
                    if Config.Aimbot.TargetMode == "Head" then targetP = p.Character:FindFirstChild("Head")
                    elseif Config.Aimbot.TargetMode == "Body" then targetP = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                    else -- "Both" / Auto
                        local h = p.Character:FindFirstChild("Head")
                        local b = p.Character:FindFirstChild("HumanoidRootPart")
                        if h and b then
                            local hPos = Camera:WorldToViewportPoint(h.Position)
                            local bPos = Camera:WorldToViewportPoint(b.Position)
                            local hDist = (Vector2.new(hPos.X, hPos.Y) - mousePos).Magnitude
                            local bDist = (Vector2.new(bPos.X, bPos.Y) - mousePos).Magnitude
                            targetP = (hDist < bDist) and h or b
                        end
                    end

                    if targetP then
                        local pos, vis = Camera:WorldToViewportPoint(targetP.Position)    
                        if vis then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < maxDist then maxDist = dist; closest = targetP end
                        end
                    end
                end
            end
        end

        -- 3. APPLY MOVEMENT
        if closest then
            local pos = Camera:WorldToViewportPoint(closest.Position)
            mousemoverel((pos.X - mousePos.X)/Config.Aimbot.Smoothness, (pos.Y - mousePos.Y)/Config.Aimbot.Smoothness)
        end
    end
end)

Window:Notify("System", "R-Loader Universal Injected")

-- End of Script ----------------------------------------------------------------