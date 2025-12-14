--[[ 
    R-LOADER UI LIBRARY (FIXED & REFACTORED)
    Update this code in your GitHub/Workspace file.
]]

local Library = {}

-- // SERVICES //
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // EXECUTOR COMPATIBILITY //
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local isfile = isfile or function() return false end
local getcustomasset = getcustomasset or function(path) return path end

-- // ASSETS & FILES //
local SETTINGS_FOLDER = "R-Loader_Lib"
local ASSETS_FOLDER = SETTINGS_FOLDER .. "/assets"
if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end
if not isfolder(ASSETS_FOLDER) then makefolder(ASSETS_FOLDER) end

-- // THEME //
Library.Theme = {
    Background = Color3.fromRGB(15, 15, 25),
    Sidebar = Color3.fromRGB(20, 18, 35),
    Header = Color3.fromRGB(25, 20, 40),
    Panel = Color3.fromRGB(28, 25, 45),
    Accent = Color3.fromRGB(138, 100, 255),
    AccentHover = Color3.fromRGB(158, 120, 255),
    ButtonBg = Color3.fromRGB(35, 30, 55),
    ButtonHover = Color3.fromRGB(45, 40, 65),
    Text = Color3.fromRGB(230, 230, 240),
    TextDim = Color3.fromRGB(140, 135, 160),
    Border = Color3.fromRGB(60, 50, 90),
    Error = Color3.fromRGB(255, 100, 120),
    Font = Enum.Font.Gotham
}

-- // HELPER FUNCTIONS //
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function roundify(obj, radius) 
    create("UICorner", {CornerRadius = UDim.new(0, radius or 4), Parent = obj}) 
end

local function addStroke(obj, color) 
    create("UIStroke", {Color = color or Library.Theme.Border, Thickness = 1, Parent = obj}) 
end

local function tween(obj, props, t) 
    TweenService:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() 
end

local function GetProcessedIcon(id)
    if not id then return "" end
    if string.find(id, "rbxassetid://") then return id end
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

-- // MAIN WINDOW FUNCTION //
function Library:CreateWindow(config)
    local title = config.Title or "UI"
    local savedKey = config.Keybind or Enum.KeyCode.RightShift
    local uiScale = config.Scale or 1
    
    local ScreenGui = create("ScreenGui", {
        Name = "RLoader_"..title, 
        Parent = (gethui and gethui()) or CoreGui, 
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10000, 
        IgnoreGuiInset = true 
    })
    
    local ScaleObj = create("UIScale", {Parent = ScreenGui, Scale = uiScale})
    
    -- Main Container
    local Container = create("Frame", {
        Size = UDim2.new(0, 700, 0, 500), 
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 0.1,
        Parent = ScreenGui,
        ClipsDescendants = true,
        Visible = false 
    })
    roundify(Container, 12); addStroke(Container)

    -- Draggable Logic
    local dragging, dragInput, dragStart, startPos
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Container.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
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
    local Header = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = Library.Theme.Header, BackgroundTransparency = 0.1, Parent = Container})
    roundify(Header, 12)
    create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = Library.Theme.Header, BackgroundTransparency = 0, Parent = Header, BorderSizePixel=0})
    
    local HeaderIcon = create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 15, 0.5, -15),
        BackgroundTransparency = 1, Image = GetProcessedIcon(config.Icon or ""), Parent = Header
    })
    create("TextLabel", {
        Text = title, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 55, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, 
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
    })

    -- Sidebar
    local Sidebar = create("Frame", {Size = UDim2.new(0, 150, 1, -50), Position = UDim2.new(0,0,0,50), BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0.1, Parent = Container, BorderSizePixel = 0})
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
    create("Frame", {Size = UDim2.new(1, 0, 0, 15), BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0, BorderSizePixel = 0, Parent = Sidebar}) 
    create("Frame", {Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0, BorderSizePixel = 0, Parent = Sidebar}) 

    -- Profile Area
    local ProfileFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 80), BackgroundTransparency = 1, Parent = Sidebar})
    local PFP = create("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0.5, -20, 0.2, 0),
        BackgroundTransparency = 1, Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", Parent = ProfileFrame
    })
    roundify(PFP, 20); addStroke(PFP, Library.Theme.Accent)
    create("TextLabel", {
        Text = "Welcome,\n" .. LocalPlayer.Name, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.7, 0),
        BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = Library.Theme.Font, TextSize = 11, Parent = ProfileFrame
    })

    -- Tab Container
    local SidebarList = create("Frame", {Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 80), BackgroundTransparency = 1, Parent = Sidebar})
    create("UIListLayout", {Parent = SidebarList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,5)})
    create("UIPadding", {Parent = SidebarList, PaddingTop = UDim.new(0,10)})

    -- Content Area
    local Content = create("Frame", {Size = UDim2.new(1, -160, 1, -60), Position = UDim2.new(0, 155, 0, 55), BackgroundTransparency = 1, Parent = Container})

    -- Notification Logic
    local NotifyFrame = create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -260, 0, 0), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100})
    create("UIListLayout", {Parent = NotifyFrame, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})
    create("UIPadding", {Parent = NotifyFrame, PaddingBottom = UDim.new(0, 20)})

    -- Window Object
    local Window = {
        Gui = ScreenGui,
        Container = Container
    }

    function Window:Notify(title, msg, duration)
        local N = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Library.Theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1})
        roundify(N, 8); addStroke(N, Library.Theme.Accent)
        create("TextLabel", {Text = title, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = N})
        create("TextLabel", {Text = msg, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = N})
        
        N.Position = UDim2.new(1, 300, 0, 0)
        tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.delay(duration or 3, function()
            tween(N, {BackgroundTransparency = 1}, 0.5)
            N:Destroy()
        end)
    end

    -- Tab Tracking for Auto-Select
    local FirstTab = true

    function Window:CreateTab(name, icon)
        local TabBtn = create("TextButton", {
            Text = "   " .. (icon or "") .. "  " .. name, 
            Size = UDim2.new(1, 0, 0, 35), 
            BackgroundColor3 = Library.Theme.Sidebar, 
            BackgroundTransparency = 0.5, 
            TextColor3 = Library.Theme.TextDim, 
            Font = Library.Theme.Font, 
            TextSize = 13, 
            TextXAlignment = Enum.TextXAlignment.Left, 
            Parent = SidebarList, 
            BorderSizePixel = 0, 
            AutoButtonColor = false
        })

        local TabFrame = create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, 
            ScrollBarThickness = 2, Parent = Content, CanvasSize = UDim2.new(0,0,0,0), 
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarImageColor3 = Library.Theme.Accent
        })
        create("UIListLayout", {Parent = TabFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
        create("UIPadding", {Parent = TabFrame, PaddingRight = UDim.new(0,5), PaddingLeft = UDim.new(0,5), PaddingTop = UDim.new(0,5)})

        -- Selection Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(SidebarList:GetChildren()) do 
                if v:IsA("TextButton") then 
                    tween(v, {BackgroundColor3 = Library.Theme.Sidebar, TextColor3 = Library.Theme.TextDim}, 0.2) 
                end 
            end
            for _, v in pairs(Content:GetChildren()) do v.Visible = false end
            
            tween(TabBtn, {BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.Accent}, 0.2)
            TabFrame.Visible = true
            
            -- Fade in children (FIXED: Supports Buttons & Sliders now)
            for i, v in pairs(TabFrame:GetChildren()) do
                if v:IsA("GuiObject") and not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    v.BackgroundTransparency = 1
                    tween(v, {BackgroundTransparency = 0.2}, 0.3 + (i*0.05))
                end
            end
        end)

        -- Auto Select First Tab (FIXED LOGIC)
        if FirstTab then
            FirstTab = false
            TabBtn.MouseButton1Click:Fire()
        end

        local Tab = {}

        function Tab:Label(text)
            local Lab = create("TextLabel", {
                Text = text, Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, 
                TextColor3 = Library.Theme.TextDim, Font = Library.Theme.Font, TextSize = 12, 
                TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFrame
            })
            create("UIPadding", {Parent = Lab, PaddingLeft = UDim.new(0, 5)})
        end

        function Tab:Button(text, callback)
            local BtnFrame = create("TextButton", {
                Text = text, Size = UDim2.new(1,0,0,35), BackgroundColor3 = Library.Theme.ButtonBg, 
                BackgroundTransparency = 0.2, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, 
                TextSize = 14, Parent = TabFrame
            })
            roundify(BtnFrame, 6)
            
            BtnFrame.MouseButton1Click:Connect(function()
                tween(BtnFrame, {BackgroundColor3 = Library.Theme.ButtonHover}, 0.1)
                task.delay(0.1, function() tween(BtnFrame, {BackgroundColor3 = Library.Theme.ButtonBg}, 0.2) end)
                if callback then callback() end
            end)
        end

        function Tab:Toggle(text, default, callback)
            local state = default or false
            local ToggleFrame = create("TextButton", {
                Text = "", Size = UDim2.new(1,0,0,35), BackgroundColor3 = Library.Theme.ButtonBg,
                BackgroundTransparency = 0.2, Parent = TabFrame, AutoButtonColor = false
            })
            roundify(ToggleFrame, 6)

            create("TextLabel", {
                Text = text, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font,
                TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleFrame
            })

            local Indicator = create("Frame", {
                Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Panel,
                Parent = ToggleFrame
            })
            roundify(Indicator, 4)

            local function Update()
                state = not state
                tween(Indicator, {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Panel}, 0.2)
                if callback then callback(state) end
            end

            ToggleFrame.MouseButton1Click:Connect(Update)
            if default then if callback then callback(true) end end 
        end

        function Tab:Slider(text, min, max, default, callback)
            local value = default or min
            local SliderFrame = create("Frame", {
                Size = UDim2.new(1,0,0,45), BackgroundColor3 = Library.Theme.ButtonBg,
                BackgroundTransparency = 0.2, Parent = TabFrame
            })
            roundify(SliderFrame, 6)

            create("TextLabel", {
                Text = text, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,10,0,5),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font,
                TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = SliderFrame
            })

            local ValueLabel = create("TextLabel", {
                Text = tostring(value), Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0, 5),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = Library.Theme.Font,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = SliderFrame
            })

            local BarBG = create("TextButton", {
                Text = "", Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = Library.Theme.Panel, AutoButtonColor = false, Parent = SliderFrame
            })
            roundify(BarBG, 3)

            local BarFill = create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Library.Theme.Accent, Parent = BarBG, BorderSizePixel = 0
            })
            roundify(BarFill, 3)

            local dragging = false
            local function Update(input)
                local percent = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(min + (max - min) * percent)
                value = newValue
                ValueLabel.Text = tostring(newValue)
                tween(BarFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
                if callback then callback(newValue) end
            end

            BarBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end
        
        function Tab:Dropdown(text, options, callback)
            local DropFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Theme.ButtonBg,
                BackgroundTransparency = 0.2, Parent = TabFrame, ClipsDescendants = true
            })
            roundify(DropFrame, 6)
            
            local Header = create("TextButton", {
                Text = text .. " ▼", Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1,
                TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, Parent = DropFrame
            })
            
            local Container = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 35),
                BackgroundTransparency = 1, Parent = DropFrame
            })
            create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder})
            
            local isOpen = false
            Header.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local height = isOpen and (35 + (#options * 30)) or 35
                tween(DropFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.3)
            end)
            
            for _, opt in ipairs(options) do
                local OptBtn = create("TextButton", {
                    Text = opt, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Library.Theme.Panel,
                    BackgroundTransparency = 0.5, TextColor3 = Library.Theme.TextDim, Font = Library.Theme.Font,
                    TextSize = 13, Parent = Container
                })
                OptBtn.MouseButton1Click:Connect(function()
                    isOpen = false
                    tween(DropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
                    Header.Text = text .. ": " .. opt
                    if callback then callback(opt) end
                end)
            end
        end

        return Tab
    end
    
    Container.Visible = true
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == savedKey then
            Container.Visible = not Container.Visible
        end
    end)

    return Window
end

return Library