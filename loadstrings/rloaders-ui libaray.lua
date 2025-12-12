-- // MODERN UI LIBRARY // -------------------------------------------------------
-- // Based on R-Loader Architecture // ------------------------------------------

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // 1. THEME MANAGEMENT //
-- You can modify Library.Theme before creating a window to change colors
Library.Theme = {
    Background = Color3.fromRGB(15, 15, 25), 
    Sidebar = Color3.fromRGB(20, 18, 35),
    Header = Color3.fromRGB(25, 20, 40), 
    Panel = Color3.fromRGB(28, 25, 45),
    Accent = Color3.fromRGB(138, 100, 255), 
    AccentHover = Color3.fromRGB(158, 120, 255),
    ButtonBg = Color3.fromRGB(35, 30, 55), 
    ButtonHover = Color3.fromRGB(45, 40, 65), 
    ButtonBgLoad = Color3.fromRGB(35, 30, 55), 
    Text = Color3.fromRGB(230, 230, 240), 
    TextDim = Color3.fromRGB(140, 135, 160), 
    Border = Color3.fromRGB(60, 50, 90), 
    Error = Color3.fromRGB(255, 100, 120),
    Font = Enum.Font.Gotham
}

-- // 2. HELPER FUNCTIONS //
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do 
        if k ~= "Parent" then 
            obj[k] = v 
        end 
    end
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

local function textShrink(obj, maxSize) 
    obj.TextScaled = true 
    obj.TextWrapped = true 
    create("UITextSizeConstraint", {Parent = obj, MaxTextSize = maxSize}) 
end

-- // 3. WINDOW CREATION //
function Library:CreateWindow(config)
    local title = config.Title or "UI"
    local author = config.Author or "User"
    local icon = config.Icon or "rbxassetid://0" -- Default to empty or custom
    local toggleKey = config.Keybind or Enum.KeyCode.RightShift

    local ScreenGui = create("ScreenGui", {
        Name = "ModernLib_" .. title, 
        Parent = (gethui and gethui()) or CoreGui, 
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10000, 
        IgnoreGuiInset = true 
    })

    local UIScale = create("UIScale", {Parent = ScreenGui, Scale = 1})

    -- Main Container
    local Container = create("Frame", {
        Size = UDim2.new(0, 700, 0, 500), 
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 0.1, -- Default slightly transparent
        Parent = ScreenGui,
        ClipsDescendants = true,
        Visible = true
    })
    roundify(Container, 12); addStroke(Container)

    -- Wallpaper Layer
    local Wall = create("ImageLabel", {
        Name = "Wallpaper",
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0, ZIndex = 0, Parent = Container,
        Visible = false 
    })
    roundify(Wall, 12)

    -- Draggable Logic
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
    local Header = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = Library.Theme.Header, BackgroundTransparency = 0.1, Parent = Container})
    roundify(Header, 12)
    -- Cover bottom rounded corners of header to blend with body
    create("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = Library.Theme.Header, BackgroundTransparency = 0.1, Parent = Header, BorderSizePixel=0})

    -- Icon & Title
    local HeaderIcon = create("ImageLabel", {
        Name = "HeaderIcon", Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 15, 0.5, -15),
        BackgroundTransparency = 1, Image = icon, Parent = Header
    })
    roundify(HeaderIcon, 8)

    create("TextLabel", {
        Text = title, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 55, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, 
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
    })

    -- Close / Minimize
    local CloseBtn = create("TextButton", {Text = "X", Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-45,0,5), BackgroundTransparency = 1, TextColor3 = Library.Theme.Error, Font = Enum.Font.GothamBold, TextSize = 18, Parent = Header})
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MinimizeBtn = create("TextButton", {Text = "-", Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-85,0,5), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 24, Parent = Header})
    
    -- Sidebar
    local Sidebar = create("Frame", {Size = UDim2.new(0, 140, 1, -50), Position = UDim2.new(0,0,0,50), BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0.1, Parent = Container, BorderSizePixel = 0})
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
    create("Frame", {Size = UDim2.new(1, 0, 0, 15), BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Sidebar}) -- Blending
    create("Frame", {Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Sidebar}) -- Blending

    -- Profile Area
    local ProfileFrame = create("Frame", {Name = "Profile", Size = UDim2.new(1, 0, 0, 90), BackgroundTransparency = 1, Parent = Sidebar})
    local SidePFP = create("ImageLabel", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, -25, 0.1, 0), BackgroundTransparency = 1, Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", Parent = ProfileFrame})
    create("UICorner", {CornerRadius = UDim.new(1,0), Parent = SidePFP})
    create("UIStroke", {Color = Library.Theme.Accent, Thickness = 2, Parent = SidePFP})
    create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.7, 0), BackgroundTransparency = 1, Text = "Welcome, " .. LocalPlayer.Name, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 12, Parent = ProfileFrame})

    local SidebarList = create("Frame", {Size = UDim2.new(1, 0, 1, -90), Position = UDim2.new(0, 0, 0, 90), BackgroundTransparency = 1, Parent = Sidebar})
    create("UIListLayout", {Parent = SidebarList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,5)})
    create("UIPadding", {Parent = SidebarList, PaddingTop = UDim.new(0,10)})

    -- Content Area
    local Content = create("Frame", {Size = UDim2.new(1, -150, 1, -60), Position = UDim2.new(0, 145, 0, 55), BackgroundTransparency = 1, Parent = Container})

    -- Notification Container
    local NotifyFrame = create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -260, 0, 0), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100})
    create("UIListLayout", {Parent = NotifyFrame, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})
    create("UIPadding", {Parent = NotifyFrame, PaddingBottom = UDim.new(0, 20)})

    -- // WINDOW LOGIC //
    local Window = {
        Gui = ScreenGui, 
        Container = Container, 
        Wallpaper = Wall,
        ScaleObj = UIScale
    }

    local isOpen = true
    local isMinimizing = false

    function Window:Toggle(state)
        if isMinimizing then return end
        isOpen = (state ~= nil) and state or not isOpen
        
        if isOpen then
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

    MinimizeBtn.MouseButton1Click:Connect(function() Window:Toggle(false) end)

    UserInputService.InputBegan:Connect(function(input)
        local isTyping = UserInputService:GetFocusedTextBox() ~= nil
        if input.KeyCode == toggleKey and not isTyping then
            Window:Toggle()
        end
    end)

    function Window:Notify(title, msg, duration)
        local N = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Library.Theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1})
        roundify(N, 8); addStroke(N, Library.Theme.Accent)
        create("TextLabel", {Text = title, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = N})
        create("TextLabel", {Text = msg, Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = N})
        N.Position = UDim2.new(1, 300, 0, 0)
        tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
        task.spawn(function()
            task.wait(duration or 4)
            tween(N, {BackgroundTransparency = 1}, 0.5)
            for _,v in pairs(N:GetChildren()) do if v:IsA("TextLabel") then tween(v, {TextTransparency=1}, 0.5) end end
            task.wait(0.5)
            N:Destroy()
        end)
    end

    -- // 4. TAB SYSTEM //
    function Window:CreateTab(name, icon)
        local TabBtn = create("TextButton", {
            Text = "   " .. (icon or "") .. "  " .. name, 
            Size = UDim2.new(1, 0, 0, 35), 
            BackgroundColor3 = Library.Theme.Sidebar, 
            BackgroundTransparency = 0.5, 
            TextColor3 = Library.Theme.TextDim, 
            Font = Library.Theme.Font, 
            TextSize = 14, 
            TextXAlignment = Enum.TextXAlignment.Left, 
            Parent = SidebarList, 
            BorderSizePixel = 0
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

        -- Select Logic
        TabBtn.MouseButton1Click:Connect(function()
            -- Deselect all
            for _,v in pairs(SidebarList:GetChildren()) do 
                if v:IsA("TextButton") then 
                    tween(v, {BackgroundColor3 = Library.Theme.Sidebar, TextColor3 = Library.Theme.TextDim}, 0.2)
                end 
            end
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end

            -- Select This
            tween(TabBtn, {BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.Accent}, 0.2)
            TabFrame.Visible = true
            
            -- Animation
            for i, v in pairs(TabFrame:GetChildren()) do
                if v:IsA("GuiObject") then
                    local targetTrans = (v.Name == "Dropdown" or v.Name:find("Card")) and 0.2 or 0
                    if v:IsA("TextLabel") then targetTrans = 1 end
                    -- Reset to invisible then fade in
                    v.BackgroundTransparency = 1
                    tween(v, {BackgroundTransparency = targetTrans}, 0.3 + (i * 0.05))
                end
            end
        end)

        -- If it's the first tab, open it
        if #SidebarList:GetChildren() == 2 then -- 2 because of Layout & Padding
            TabBtn.FireClick(TabBtn) -- Simulate click to open
        end

        local Tab = {Frame = TabFrame}

        -- // ELEMENTS //

        function Tab:Label(text)
            create("TextLabel", {Text = text, Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = Library.Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFrame})
        end

        function Tab:Button(text, callback)
            local Btn = create("TextButton", {
                Text = text, 
                Size = UDim2.new(1,0,0,35), 
                BackgroundColor3 = Library.Theme.ButtonBg, 
                BackgroundTransparency = 0.2, 
                TextColor3 = Library.Theme.Text, 
                Font = Library.Theme.Font, 
                Parent = TabFrame
            })
            roundify(Btn, 6)
            textShrink(Btn, 14)

            Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = Library.Theme.ButtonHover}, 0.2) end)
            Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = Library.Theme.ButtonBg}, 0.2) end)
            Btn.MouseButton1Click:Connect(callback)
            return Btn
        end

        function Tab:Toggle(text, default, callback)
            local state = default or false
            local Frame = create("Frame", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = Library.Theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame})
            roundify(Frame, 6)
            create("TextLabel", {Text = text, Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=Library.Theme.Text, Font=Library.Theme.Font, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=Frame})
            
            local Indicator = create("TextButton", {Text="", Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-30,0.5,-10), BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Panel, Parent=Frame})
            roundify(Indicator, 4)
            
            -- Initial call
            if default then task.spawn(function() callback(state) end) end

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    Indicator.BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Panel
                    callback(state)
                end
            end)
        end

        function Tab:Input(placeholder, callback)
            local InputFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Theme.ButtonBg, BackgroundTransparency = 0.2, Parent = TabFrame})
            roundify(InputFrame, 6)
            
            local TextBox = create("TextBox", {
                Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text,
                Font = Library.Theme.Font, TextSize = 14,
                PlaceholderText = placeholder or "Type here...",
                Text = "", ClearTextOnFocus = false,
                Parent = InputFrame
            })

            -- Trigger callback on enter pressed or focus lost
            TextBox.FocusLost:Connect(function(enterPressed)
                callback(TextBox.Text)
            end)
            return TextBox
        end

        function Tab:Dropdown(text, options, callback)
            local Frame = create("Frame", {Name="Dropdown", Size = UDim2.new(1,0,0,35), BackgroundColor3 = Library.Theme.ButtonBg, BackgroundTransparency=0.2, Parent = TabFrame, ClipsDescendants=true})
            roundify(Frame, 6)
            local Header = create("TextButton", {Text = text .. " ▼", Size = UDim2.new(1,0,0,35), BackgroundTransparency=1, TextColor3=Library.Theme.Text, Font=Library.Theme.Font, TextSize=14, Parent=Frame})
            local List = create("Frame", {Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,35), BackgroundTransparency=1, Parent=Frame})
            create("UIListLayout", {Parent=List})
            
            local open = false
            
            local function toggle()
                open = not open
                tween(Frame, {Size = UDim2.new(1,0,0, open and 35 + (#options*30) or 35)}, 0.2)
                Header.Text = text .. (open and " ▲" or " ▼")
            end
            
            Header.MouseButton1Click:Connect(toggle)
            
            for _, opt in pairs(options) do
                local OptBtn = create("TextButton", {Text = opt, Size = UDim2.new(1,0,0,30), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency=0.2, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 13, Parent = List})
                OptBtn.MouseButton1Click:Connect(function()
                    open = false
                    tween(Frame, {Size = UDim2.new(1,0,0,35)}, 0.2)
                    Header.Text = text .. ": " .. opt
                    callback(opt)
                end)
            end
        end

        function Tab:Card(name, desc, iconId, callback)
             local Container = create("Frame", {Name = "Card_"..name, Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.2, Parent = TabFrame})
             roundify(Container, 8); addStroke(Container, Library.Theme.Border)
             
             local hasIcon = (iconId and iconId ~= "")
             local textOffset = hasIcon and 83 or 10

             if hasIcon then
                 local IconContainer = create("Frame", {Size = UDim2.new(0, 65, 0, 65), Position = UDim2.new(0, 8, 0.5, -32.5), BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.5, Parent = Container})
                 roundify(IconContainer, 8); addStroke(IconContainer, Library.Theme.Border)
                 create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = iconId, ScaleType = Enum.ScaleType.Fit, Parent = IconContainer})
             end

             create("TextLabel", {Text = name, Size = UDim2.new(1, -textOffset, 0, 20), Position = UDim2.new(0, textOffset, 0, 8), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Container})
             create("TextLabel", {Text = desc or "No description.", Size = UDim2.new(1, -textOffset, 0, 40), Position = UDim2.new(0, textOffset, 0, 30), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = Library.Theme.Font, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Container})
             
             local ActionBtn = create("TextButton", {Text = "Execute", Size = UDim2.new(1, -textOffset, 0, 25), Position = UDim2.new(0, textOffset, 1, -33), BackgroundColor3 = Library.Theme.ButtonBgLoad, BackgroundTransparency = 0.2, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, Parent = Container})
             roundify(ActionBtn, 4)
             
             ActionBtn.MouseButton1Click:Connect(callback)
             return Container
        end

        return Tab
    end
    return Window
end

return Library