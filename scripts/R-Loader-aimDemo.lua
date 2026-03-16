-- // 1. SERVICES & SETUP // ------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Executor Safe Checks
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local isfile = isfile or function() return false end
local mousemoverel = mousemoverel or (Input and Input.MouseMove) or function() end

-- // CONFIGURATION // -----------------------------------------------------------------------
local WhitelistedIds = {
    [9016941031] = true,
    [2335971665] = true,
    [10104221280] = true,
}

getgenv().KeySystemEnabled = true  
getgenv().DisabledFeatures = {}
getgenv().BetaFeatures = {}

local function IsUserWhitelisted()
    if LocalPlayer and WhitelistedIds[LocalPlayer.UserId] then return true end
    return false
end

-- // 2. CONFIGURATION DATA // ------------------------------------
local Config = {
    Aimbot = {
        Enabled = false,
        AimKey = "MouseButton2", -- Defaults to Right Click
        Smoothness = 5,
        FOV = 300,
        TargetPart = "Head", 
        TargetMode = "Head", 
        Range = 2000, 
        ObjectLockon = false,
        TeamCheck = false,
        HealthDetach = false, 
        Whitelist = {}
    },
    ESP = {
        Enabled = false,
        Fill = {R=175, G=25, B=25},
        Outline = {R=255, G=255, B=255},
        ShowNames = true,
        ShowObjects = false,
        ObjectMode = "Interactable",
        Tracers = false,
        Boxes = false,
        Health = false,
    },
    Binds = {
        ToggleUI = "RightShift", -- Default Minimize Key
        ToggleAimbot = "C"       -- Default Aimbot Toggle Key
    }
}

-- CONFIG SYSTEM
local FolderName = "R-Loader_Config"
local FileName = "AimbotESP_Settings.json"

local function SaveConfig()
    if not makefolder then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    
    local SaveData = {
        Aimbot = Config.Aimbot,
        ESP = Config.ESP,
        Binds = Config.Binds
    }
    
    local Data = HttpService:JSONEncode(SaveData)
    writefile(FolderName .. "/" .. FileName, Data)
end

local function LoadConfig()
    if not isfile then return end
    if isfile(FolderName .. "/" .. FileName) then
        local content = readfile(FolderName .. "/" .. FileName)
        local decoded = HttpService:JSONDecode(content)
        
        local function SafeLoad(category, key, value)
            if Config[category] and Config[category][key] ~= nil then
                Config[category][key] = value
            end
        end

        if decoded.Aimbot then 
            for k,v in pairs(decoded.Aimbot) do SafeLoad("Aimbot", k, v) end 
            if decoded.Aimbot.Whitelist then Config.Aimbot.Whitelist = decoded.Aimbot.Whitelist end
        end
        if decoded.ESP then for k,v in pairs(decoded.ESP) do SafeLoad("ESP", k, v) end end
        if decoded.Binds then for k,v in pairs(decoded.Binds) do SafeLoad("Binds", k, v) end end
    end
end

-- // 3. UI LIBRARY // -----------------------------------------------
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
        local ScreenGui = create("ScreenGui", {Name = "RLoader_Universal_Remaster", Parent = (gethui and gethui()) or CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 10000, IgnoreGuiInset = true})
        
        local Container = create("Frame", {
            Size = UDim2.new(0, 650, 0, 450), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.Background, BackgroundTransparency = 0.05, Parent = ScreenGui, ClipsDescendants = true
        })
        roundify(Container, 10); addStroke(Container, theme.Border)

        local Header = create("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = theme.Header, Parent = Container})
        roundify(Header, 10)
        create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = theme.Header, Parent = Header, BorderSizePixel=0})
        
        local Sidebar = create("ScrollingFrame", {Size = UDim2.new(0, 140, 1, -40), Position = UDim2.new(0,0,0,40), BackgroundColor3 = theme.Sidebar, Parent = Container, ScrollBarThickness = 2, BorderSizePixel = 0})
        create("UIListLayout", {Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})
        create("UIPadding", {Parent = Sidebar, PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,5)})

        local ContentArea = create("Frame", {Size = UDim2.new(1, -150, 1, -50), Position = UDim2.new(0, 145, 0, 45), BackgroundTransparency = 1, Parent = Container})

        create("TextLabel", {
            Text = title, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
        })

        local CloseBtn = create("TextButton", {Text = "X", Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-35,0,5), BackgroundTransparency = 1, TextColor3 = theme.Error, Font = Enum.Font.GothamBold, TextSize = 14, Parent = Header})
        CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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
            
            if name == "Combat" then tween(TabBtn, {BackgroundTransparency = 0.8, BackgroundColor3 = theme.Accent, TextColor3 = theme.Accent}, 0.2); TabFrame.Visible = true end

            local TabObj = {ScrollFrame = TabFrame}

            function TabObj:Label(text) create("TextLabel", {Text = text, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFrame}) end
            
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

                Btn.MouseButton1Click:Connect(function()
                    tween(Btn, {BackgroundColor3 = theme.AccentHover}, 0.1)
                    task.wait(0.1)
                    tween(Btn, {BackgroundColor3 = theme.ButtonBg}, 0.1)
                    callback()
                end)
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

                local function UpdateVisual(s)
                    tween(Indicator, {BackgroundColor3 = s and theme.Accent or theme.Panel}, 0.2)
                    tween(Label, {TextColor3 = s and theme.Text or theme.TextDim}, 0.2)
                end

                Frame.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateVisual(state)
                    callback(state)
                    SaveConfig()
                end)
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

            function TabObj:Binder(text, defaultKey, callback)
                local Frame = create("Frame", {Size = UDim2.new(1,0,0,28), BackgroundColor3 = theme.ButtonBg, Parent = TabFrame}); roundify(Frame, 4)
                create("TextLabel", {Text = text, Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=theme.Text, Font=theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
                local BindBtn = create("TextButton", {Text = defaultKey, Size=UDim2.new(0,80,0,20), Position=UDim2.new(1,-90,0.5,-10), BackgroundColor3=theme.Panel, TextColor3=theme.TextDim, Font=theme.Font, TextSize=11, Parent=Frame}); roundify(BindBtn, 4)
                
                BindBtn.MouseButton1Click:Connect(function()
                    BindBtn.Text = "..."
                    BindBtn.TextColor3 = theme.Accent
                    local input = UserInputService.InputBegan:Wait()
                    if input.UserInputType == Enum.UserInputType.Keyboard then 
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = theme.TextDim
                        callback(input.KeyCode.Name)
                        SaveConfig() 
                    else 
                        BindBtn.Text = defaultKey 
                        BindBtn.TextColor3 = theme.TextDim
                    end
                end)
            end

            return TabObj
        end
        return WindowObj, theme
    end
    return UILibrary
end)()

-- // 4. WINDOW CREATION // -------------------------------------------------------------------
local Window, Theme = Library:CreateWindow({Title = "R-Loader | Rivals Demo"})

-- Initialize Settings early so binds catch properly
LoadConfig()

-- // COMBAT TAB //
local CombatTab = Window:CreateCategory("Combat", "🎯")

-- Lock-on Key Toggle (Left Click vs Right Click)
local AimKeyBtn 
AimKeyBtn = CombatTab:Button("Aim Key: " .. (Config.Aimbot.AimKey == "MouseButton1" and "Left Click (MB1)" or "Right Click (MB2)"), function()
    if Config.Aimbot.AimKey == "MouseButton2" then 
        Config.Aimbot.AimKey = "MouseButton1"
        AimKeyBtn.Text = "Aim Key: Left Click (MB1)"
    else 
        Config.Aimbot.AimKey = "MouseButton2"
        AimKeyBtn.Text = "Aim Key: Right Click (MB2)"
    end
    SaveConfig()
end)

local TgtBtn
CombatTab:Slider("Aimbot Range", 100, 5000, Config.Aimbot.Range, function(v) Config.Aimbot.Range = v end) 

-- Storing the toggle in a variable so we can visually update it if the keybind is pressed
local AimbotToggle
AimbotToggle = CombatTab:Toggle("Aimbot Enabled", Config.Aimbot.Enabled, function(v) 
    Config.Aimbot.Enabled = v 
end)

TgtBtn = CombatTab:Button("Target Mode: " .. Config.Aimbot.TargetMode, function()
    if Config.Aimbot.TargetMode == "Head" then Config.Aimbot.TargetMode = "Body"
    elseif Config.Aimbot.TargetMode == "Body" then Config.Aimbot.TargetMode = "Both"
    else Config.Aimbot.TargetMode = "Head" end
    TgtBtn.Text = "Target Mode: " .. Config.Aimbot.TargetMode
end)

CombatTab:Toggle("Team Check", Config.Aimbot.TeamCheck or false, function(v) Config.Aimbot.TeamCheck = v end)
CombatTab:Toggle("Health Detach", Config.Aimbot.HealthDetach, function(v) Config.Aimbot.HealthDetach = v end)
CombatTab:Toggle("Object Lockon", Config.Aimbot.ObjectLockon, function(v) Config.Aimbot.ObjectLockon = v end)
CombatTab:Slider("Smoothness", 1, 20, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end)
CombatTab:Slider("FOV Size", 50, 800, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
CombatTab:Label("Whitelist Player:")
CombatTab:Dropdown("Select to Whitelist", function(name) Config.Aimbot.Whitelist[name] = true; SaveConfig() end)
CombatTab:Button("Clear Whitelist", function() Config.Aimbot.Whitelist = {}; Window:Notify("System", "Whitelist Cleared") end)

-- // VISUALS TAB //
local VisualsTab = Window:CreateCategory("Visuals", "👁️")
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

-- // SETTINGS TAB (For Minimize Bind & Toggle Bind) //
local SettingsTab = Window:CreateCategory("Settings", "⚙️")
SettingsTab:Binder("Minimize Menu Key", Config.Binds.ToggleUI, function(kName) 
    Config.Binds.ToggleUI = kName 
end)

-- ADDED: Aimbot Toggle Keybind
SettingsTab:Binder("Toggle Aimbot Key", Config.Binds.ToggleAimbot, function(kName)
    Config.Binds.ToggleAimbot = kName
end)

-- // 5. LOGIC LOOPS & RUNTIME // -------------------------------------------------------------

-- // ESP SYSTEM // ------------------------------------------------------------------
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

local function CleanupESP(plrName)
    local suffix3D = {"_Highlight", "_Tag", "_ObjHighlight"}
    for _, s in pairs(suffix3D) do
        local obj = ESPFolder:FindFirstChild(plrName .. s)
        if obj then obj:Destroy() end
    end
    
    local suffix2D = {"_Box", "_Tracer", "_HealthBar"}
    for _, s in pairs(suffix2D) do
        local obj = ESP_2D:FindFirstChild(plrName .. s)
        if obj then obj:Destroy() end
    end
end

Players.PlayerRemoving:Connect(function(plr) CleanupESP(plr.Name) end)

local function MonitorCharacter(plr)
    if plr.Character then
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.Died:Connect(function() CleanupESP(plr.Name) end) end
    end
    plr.CharacterAdded:Connect(function(char)
        CleanupESP(plr.Name)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then humanoid.Died:Connect(function() CleanupESP(plr.Name) end) end
    end)
end

for _, p in pairs(Players:GetPlayers()) do MonitorCharacter(p) end
Players.PlayerAdded:Connect(MonitorCharacter)

RunService.RenderStepped:Connect(function()
    if Config.ESP.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local root = char.HumanoidRootPart
                local head = char.Head
                local hum = char:FindFirstChild("Humanoid")
                
                if hum and hum.Health > 0 then
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

                    local vector, onScreen = Camera:WorldToViewportPoint(root.Position)

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
                    CleanupESP(plr.Name)
                end
            else
                CleanupESP(plr.Name)
            end
        end
    else 
        for _, v in pairs(ESPFolder:GetChildren()) do if not v.Name:find("_ObjHighlight") then v:Destroy() end end
        ESP_2D:ClearAllChildren()
    end
    
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

-- // AIMBOT & TOGGLE LOGIC //
local aiming = false

UserInputService.InputBegan:Connect(function(i, gpe) 
    if not gpe then 
        -- 1. Check Aimbot Lock-on trigger (Mouse Click)
        if i.UserInputType.Name == Config.Aimbot.AimKey then 
            aiming = true 
        end 
        
        -- Keyboard specific checks
        if i.UserInputType == Enum.UserInputType.Keyboard then
            -- 2. Check UI Minimize Keybind
            if i.KeyCode.Name == Config.Binds.ToggleUI then
                Window.Container.Visible = not Window.Container.Visible
            end
            
            -- 3. Check Aimbot Toggle Keybind
            if i.KeyCode.Name == Config.Binds.ToggleAimbot then
                Config.Aimbot.Enabled = not Config.Aimbot.Enabled
                
                -- Send a notification so you know it turned on/off without opening the menu
                local statusText = Config.Aimbot.Enabled and "Enabled" or "Disabled"
                Window:Notify("Aimbot Status", "Aimbot is now " .. statusText)
                
                SaveConfig()
            end
        end
    end 
end)

UserInputService.InputEnded:Connect(function(i, gpe) 
    if i.UserInputType.Name == Config.Aimbot.AimKey then 
        aiming = false 
    end 
end)

RunService.RenderStepped:Connect(function()
    if aiming and Config.Aimbot.Enabled then
        local closest, maxDist = nil, Config.Aimbot.FOV
        local mousePos = UserInputService:GetMouseLocation()
        local camPos = Camera.CFrame.Position 

        if Config.Aimbot.ObjectLockon then
            for _, obj in pairs(InteractableCache) do
                if obj and obj.Parent then 
                    local targetPart = obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChild("Handle") or obj
                    if targetPart and targetPart:IsA("BasePart") then
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

        if not closest then
            for _, p in pairs(Players:GetPlayers()) do
                local isTeammate = Config.Aimbot.TeamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team
                
                if p ~= LocalPlayer and p.Character and not Config.Aimbot.Whitelist[p.Name] and not isTeammate then
                    
                    local hum = p.Character:FindFirstChild("Humanoid")
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    
                    local isTargetValid = true
                    if Config.Aimbot.HealthDetach and hum and hum.Health <= 0 then isTargetValid = false end
                    if root and (root.Position - camPos).Magnitude > Config.Aimbot.Range then isTargetValid = false end

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

        if closest then
            local pos = Camera:WorldToViewportPoint(closest.Position)
            mousemoverel((pos.X - mousePos.X)/Config.Aimbot.Smoothness, (pos.Y - mousePos.Y)/Config.Aimbot.Smoothness)
        end
    end
end)

Window:Notify("System", "Aimbot & ESP Core Injected")