local Library = (function()
    local UILibrary = {}
    local theme = {
        Background = Color3.fromRGB(15, 15, 25),
        Sidebar = Color3.fromRGB(20, 18, 35),
        Header = Color3.fromRGB(25, 20, 40),
        Panel = Color3.fromRGB(28, 25, 45),
        Accent = Color3.fromRGB(138, 100, 255),
        AccentHover = Color3.fromRGB(158, 120, 255),
        ButtonBg = Color3.fromRGB(35, 30, 55),
        ButtonHover = Color3.fromRGB(158, 120, 255),
        ButtonBgLoad = Color3.fromRGB(158, 120, 255),
        Text = Color3.fromRGB(230, 230, 240),
        TextDim = Color3.fromRGB(140, 135, 160),
        Border = Color3.fromRGB(60, 50, 90),
        Error = Color3.fromRGB(255, 100, 120),
        Font = Enum.Font.Gotham
    }

    -- Helper functions
    local function create(class, props)
        local obj = Instance.new(class)
        for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
        if props.Parent then obj.Parent = props.Parent end
        return obj
    end
    local function roundify(obj, radius) create("UICorner", { CornerRadius = UDim.new(0, radius or 4), Parent = obj }) end
    local function addStroke(obj, color)
        create("UIStroke",
            { Color = color or theme.Border, Thickness = 1, Parent = obj })
    end
    local function tween(obj, props, t)
        if SimplifyAnimations then
            for k, v in pairs(props) do obj[k] = v end
        else
            TweenService:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
                :Play()
        end
    end

    function UILibrary:CreateWindow(config)
        local title = config.Title or "UI"

        -- [[ ROBUST KEYBIND LOADING ]]
        local CurrentKeybind = Enum.KeyCode.RightShift
        if SystemSettings.Keybind and Enum.KeyCode[SystemSettings.Keybind] then
            CurrentKeybind = Enum.KeyCode[SystemSettings.Keybind]
        end

        local ScreenGui = create("ScreenGui", {
            Name = "ModernUI_" .. title,
            Parent = (gethui and gethui()) or CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 10000,
            IgnoreGuiInset = true
        })
        --[[Loader version]]
        local RL_VERSION = (getgenv().ServerIsUp and " online v:" or " offline v:") .. "rloader-b29"

        -- [[ APPLY SAVED SCALE ]]
        local UIScale = create("UIScale", { Parent = ScreenGui, Scale = SystemSettings.UIScale or 1 })

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
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Crop,
            ImageTransparency = 0,
            ZIndex = 0,
            Parent = Container,
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
                tween(Container,
                    {
                        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y)
                    }, 0.05)
            end
        end)

        -- Header
        local Header = create("Frame",
            {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = theme.Header,
                BackgroundTransparency = 0.1,
                Parent =
                    Container
            })
        roundify(Header, 12)
        create("Frame",
            {
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 1, -10),
                BackgroundColor3 = theme.Header,
                BackgroundTransparency = 0.1,
                Parent =
                    Header,
                BorderSizePixel = 0
            })
        -- // CUSTOM ICON SUPPORT //
        local HeaderIcon = create("ImageLabel", {
            Name = "HeaderIcon",
            Size = UDim2.new(0, 37, 0, 37),           -- Size of the image (30x30 pixels)
            Position = UDim2.new(0, 15.5, 0.38, -15), -- 10px from left edge, centered vertically
            BackgroundTransparency = 1,               -- Ensure background is clear for rounding
            Image = "",                               -- ApplyIconAsync will set this
            Parent = Header
        })

        -- Apply rounding. 15px radius on a 30px image makes it a perfect circle.
        -- Change 15 to 8 if you want a rounded square instead.
        roundify(HeaderIcon, 8)
        ApplyIconAsync(HeaderIcon, Header_Image)

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
                if SimplifyAnimations then
                    Container.Size = UDim2.new(0, 700, 0, 500)
                    Container.BackgroundTransparency = 0.1
                else
                    Container.Size = UDim2.new(0, 650, 0, 450)
                    Container.BackgroundTransparency = 1
                    local openTween = TweenService:Create(Container,
                        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            Size = UDim2.new(0, 700, 0, 500), BackgroundTransparency = 0.1
                        })
                    openTween:Play()
                end
            else
                isMinimizing = true
                if SimplifyAnimations then
                    Container.Size = UDim2.new(0, 600, 0, 400)
                    Container.BackgroundTransparency = 1
                    Container.Visible = false
                    isMinimizing = false
                else
                    local closeTween = TweenService:Create(Container,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 1
                        })
                    closeTween:Play()
                    closeTween.Completed:Wait()
                    Container.Visible = false
                    isMinimizing = false
                end
            end
        end
        local MinimizeBtn = create("TextButton",
            {
                Text = "-",
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(1, -85, 0, 5),
                BackgroundTransparency = 1,
                TextColor3 =
                    theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 24,
                Parent = Header
            })
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

        local CloseBtn = create("TextButton",
            {
                Text = "X",
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(1, -45, 0, 5),
                BackgroundTransparency = 1,
                TextColor3 =
                    theme.Error,
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                Parent = Header
            })
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
        local Sidebar = create("Frame",
            {
                Size = UDim2.new(0, 140, 1, -50),
                Position = UDim2.new(0, 0, 0, 50),
                BackgroundColor3 = theme.Sidebar,
                BackgroundTransparency = 0.1,
                Parent =
                    Container,
                BorderSizePixel = 0
            })
        create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Sidebar })
        create("Frame",
            {
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundColor3 = theme.Sidebar,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Parent =
                    Sidebar
            })
        create("Frame",
            {
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new(1, -15, 1, -15),
                BackgroundColor3 = theme.Sidebar,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Parent =
                    Sidebar
            })

        local ProfileFrame = create("Frame",
            { Name = "Profile", Size = UDim2.new(1, 0, 0, 90), BackgroundTransparency = 1, Parent = Sidebar })
        local SidePFP = create("ImageLabel",
            {
                Size = UDim2.new(0, 50, 0, 50),
                Position = UDim2.new(0.5, -25, 0.1, 0),
                BackgroundTransparency = 1,
                Image =
                    "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
                Parent = ProfileFrame
            })
        create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SidePFP })
        create("UIStroke", { Color = theme.Accent, Thickness = 2, Parent = SidePFP })
        create("TextLabel",
            {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0.7, 0),
                BackgroundTransparency = 1,
                Text =
                    RandomGreeting .. ", " .. LocalPlayer.Name,
                TextColor3 = theme.Text,
                Font = theme.Font,
                TextSize = 12,
                Parent =
                    ProfileFrame
            })

        local SidebarList = create("Frame",
            {
                Size = UDim2.new(1, 0, 1, -90),
                Position = UDim2.new(0, 0, 0, 90),
                BackgroundTransparency = 1,
                Parent =
                    Sidebar
            })
        create("UIListLayout", { Parent = SidebarList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
        create("UIPadding", { Parent = SidebarList, PaddingTop = UDim.new(0, 10) })

        local Content = create("Frame",
            {
                Size = UDim2.new(1, -150, 1, -60),
                Position = UDim2.new(0, 145, 0, 55),
                BackgroundTransparency = 1,
                Parent =
                    Container
            })

        local VerLabel = create("TextLabel",
            {
                Text = RL_VERSION,
                Size = UDim2.new(0, 100, 0, 20),
                Position = UDim2.new(1, -10, 1, -20),
                AnchorPoint =
                    Vector2.new(1, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.TextDim,
                Font = theme.Font,
                TextSize = 10,
                TextXAlignment =
                    Enum.TextXAlignment.Right,
                Parent = Container,
                ZIndex = 20
            })

        -- Notifications
        local NotifyFrame = create("Frame",
            {
                Size = UDim2.new(0, 250, 1, 0),
                Position = UDim2.new(1, -260, 0, 0),
                BackgroundTransparency = 1,
                Parent =
                    ScreenGui,
                ZIndex = 100
            })
        create("UIListLayout",
            {
                Parent = NotifyFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment
                    .Bottom,
                Padding = UDim.new(0, 5)
            })
        create("UIPadding", { Parent = NotifyFrame, PaddingBottom = UDim.new(0, 20) })

        local Window = {
            ScreenGui = ScreenGui,
            Wallpaper = Wall,
            Scale = UIScale,
            Container = Container,
            SetState =
                SetState,
            SetKeybind = function(self, key) CurrentKeybind = key end
        }
        local ActiveNotifications = {}
        function Window:Notify(title, msg)
            local notifKey = title .. "_" .. msg

            if ActiveNotifications[notifKey] and ActiveNotifications[notifKey].Frame.Parent then
                local data = ActiveNotifications[notifKey]
                data.Count = data.Count + 1
                data.LastUpdate = tick()
                local titleLabel = data.Frame:FindFirstChild("TitleLabel")
                if titleLabel then
                    titleLabel.Text = title .. " (" .. data.Count .. ")"
                end
                tween(data.Frame, { Size = UDim2.new(1, 10, 0, 65) }, 0.1)
                task.delay(0.1, function()
                    if data.Frame and data.Frame.Parent then
                        tween(data.Frame, { Size = UDim2.new(1, 0, 0, 60) }, 0.1)
                    end
                end)
                return
            end

            local N = create("Frame",
                { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = theme.Panel, Parent = NotifyFrame, BackgroundTransparency = 0.1 })

            ActiveNotifications[notifKey] = { Frame = N, Count = 1, LastUpdate = tick() }
            roundify(N, 8); addStroke(N, theme.Accent)

            create("TextLabel",
                {
                    Name = "TitleLabel",
                    Text = title,
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = N
                })
            create("TextLabel",
                {
                    Name = "MsgLabel",
                    Text = msg,
                    Size = UDim2.new(1, -10, 0, 30),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.Text,
                    Font = theme.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = N
                })

            local function handleDestruction()
                while tick() - ActiveNotifications[notifKey].LastUpdate < 4 do
                    task.wait(0.1)
                end
                if not SimplifyAnimations then
                    tween(N, { BackgroundTransparency = 1 }, 0.5)
                    for _, v in pairs(N:GetChildren()) do
                        if v:IsA("TextLabel") then tween(v, { TextTransparency = 1 }, 0.5) end
                    end
                    task.wait(0.5)
                end
                if N and N.Parent then N:Destroy() end
                ActiveNotifications[notifKey] = nil
            end

            if SimplifyAnimations then
                N.Position = UDim2.new(0, 0, 0, 0)
                task.spawn(handleDestruction)
            else
                N.Position = UDim2.new(1, 300, 0, 0)
                tween(N, { Position = UDim2.new(0, 0, 0, 0) }, 0.5)
                task.spawn(handleDestruction)
            end
        end

        function Window:CreateCategory(name, icon)
            local isPinned = PinnedTabs[name] == true
            local order = isPinned and -1 or 1
            if name == "Dashboard" then order = -9999 end

            local TabFrame -- Forward declare to fix nil reference in closures

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

            TabBtn.MouseEnter:Connect(function()
                if TabFrame and not TabFrame.Visible then
                    tween(TabBtn, { BackgroundColor3 = theme.ButtonHover }, 0.2)
                end
            end)
            TabBtn.MouseLeave:Connect(function()
                if TabFrame and not TabFrame.Visible then
                    tween(TabBtn, { BackgroundColor3 = theme.Sidebar }, 0.2)
                end
            end)

            local PinIcon = create("ImageButton", {
                Image = "rbxassetid://10709791437",
                ImageColor3 = isPinned and theme.Accent or theme.TextDim,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                Parent = TabBtn,
                ZIndex = 2
            })

            TabFrame = create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                ScrollBarThickness = 2,
                Parent = Content,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout",
                { Parent = TabFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
            create("UIPadding",
                {
                    Parent = TabFrame,
                    PaddingRight = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingTop = UDim.new(
                        0, 5)
                })

            -- [[ LOGIC: OPEN TAB FUNCTION ]]
            local function OpenThisTab()
                -- Reset all buttons
                for _, v in pairs(SidebarList:GetChildren()) do
                    if v:IsA("TextButton") then
                        tween(v, { BackgroundColor3 = theme.Sidebar, TextColor3 = theme.TextDim }, 0.2)
                    end
                end

                -- Hide all frames
                for _, v in pairs(Content:GetChildren()) do
                    v.Visible = false
                end

                -- Activate current button
                tween(TabBtn, { BackgroundColor3 = theme.Background, TextColor3 = theme.Accent }, 0.2)

                -- Show current frame
                TabFrame.Visible = true

                -- Animate elements inside
                for i, v in pairs(TabFrame:GetChildren()) do
                    if v:IsA("GuiObject") then
                        v.BackgroundTransparency = 1
                        local targetTrans = 0
                        if v.Name == "Dropdown" or v.Name:find("ScriptCard") or v:IsA("TextButton") or v:IsA("ImageButton") then targetTrans = 0.2 end
                        if v:IsA("TextLabel") or v.Name == "SplitContainer" then targetTrans = 1 end
                        tween(v, { BackgroundTransparency = targetTrans }, 0.3 + (i * 0.05))

                        -- DEEP ANIMATE FOR SPLIT CONTAINER (Dev Tab)
                        if v.Name == "SplitContainer" then
                            local delayIdx = 0
                            for _, desc in ipairs(v:GetDescendants()) do
                                if desc:IsA("GuiObject") and (desc.Name == "scFrame" or desc.Name == "UserCard" or desc.Name == "gameBtn" or desc.Name == "SearchBox" or desc.Name == "BackBtn") then
                                    delayIdx = delayIdx + 1
                                    local descTarget = 0.2
                                    if desc.Name == "SearchBox" then descTarget = 0 end
                                    desc.BackgroundTransparency = 1
                                    tween(desc, { BackgroundTransparency = descTarget }, 0.3 + (delayIdx * 0.05))
                                end
                            end
                        end
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

            local Tab = { ScrollFrame = TabFrame }

            -- Add this helper function immediately above Tab:Button
            local function textShrink(obj, maxSize)
                obj.TextScaled = true
                obj.TextWrapped = true
                create("UITextSizeConstraint", { Parent = obj, MaxTextSize = maxSize })
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
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = theme.ButtonBg,
                    BackgroundTransparency = 0.2,
                    TextColor3 = finalColor, -- Color Applied Here
                    Font = theme.Font,
                    Parent = TabFrame
                })
                roundify(Btn, 6)
                textShrink(Btn, 14) -- Prevents text cutting off

                Btn.MouseEnter:Connect(function()
                    if Btn:GetAttribute("Disabled") then return end
                    tween(Btn, { BackgroundColor3 = theme.ButtonHover }, 0.2)
                end)
                Btn.MouseLeave:Connect(function()
                    if Btn:GetAttribute("Disabled") then return end
                    tween(Btn, { BackgroundColor3 = theme.ButtonBg }, 0.2)
                end)
                Btn.MouseButton1Click:Connect(function()
                    if Btn:GetAttribute("Disabled") then return end
                    callback()
                end)
                return Btn
            end

            function Tab:ScriptCard(name, iconId, desc, isDown, callback)
                local Container = create("Frame",
                    {
                        Name = "ScriptCard_" .. name,
                        Size = UDim2.new(1, 0, 0, 110),
                        BackgroundColor3 = theme.Panel,
                        BackgroundTransparency = 0.2,
                        Parent =
                            TabFrame
                    })
                roundify(Container, 8); addStroke(Container, theme.Border)

                local IconContainer = create("Frame",
                    {
                        Size = UDim2.new(0, 65, 0, 65),
                        Position = UDim2.new(0, 8, 0.5, -32.5),
                        BackgroundColor3 = Color3
                            .fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.5,
                        Parent = Container
                    })
                roundify(IconContainer, 8); addStroke(IconContainer, theme.Border)
                local imgLabel = create("ImageLabel",
                    {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Image = "",
                        ScaleType = Enum.ScaleType.Fit,
                        Parent = IconContainer
                    })
                ApplyIconAsync(imgLabel, iconId)

                create("TextLabel",
                    {
                        Text = name,
                        Size = UDim2.new(1, -115, 0, 20),
                        Position = UDim2.new(0, 83, 0, 8),
                        BackgroundTransparency = 1,
                        TextColor3 =
                            theme.Text,
                        Font = Enum.Font.GothamBold,
                        TextSize = 16,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate =
                            Enum.TextTruncate.AtEnd,
                        Parent = Container
                    })

                -- STATUS DOT LOGIC
                local statusColor = isDown and Color3.fromRGB(255, 50, 50) or
                    Color3.fromRGB(50, 255, 50) -- Red if down, Green if up
                local StatusDot = create("Frame",
                    {
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new(1, -20, 0, 12),
                        BackgroundColor3 = statusColor,
                        Parent =
                            Container
                    })
                roundify(StatusDot, 6) -- Makes it a perfect circle

                local isLongDesc = false
                if type(desc) == "string" then
                    isLongDesc = (string.len(desc) > 65) or string.find(desc, "\n")
                end

                local descLbl = create("TextLabel",
                    {
                        Text = desc or "Not Found.",
                        Size = UDim2.new(1, -85, 0, 40),
                        Position = UDim2.new(0, 83, 0, 30),
                        BackgroundTransparency = 1,
                        TextColor3 = isDown and Color3.fromRGB(255, 100, 100) or theme.TextDim,
                        Font = theme.Font,
                        TextSize = 12,
                        TextWrapped = true,
                        TextScaled = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        Parent = Container,
                        ClipsDescendants = true
                    })
                create("UITextSizeConstraint", { MaxTextSize = 12, MinTextSize = 7, Parent = descLbl })

                -- BUTTON RENDERING LOGIC
                if not isDown then
                    local loadBtnWidth = isLongDesc and UDim2.new(1, -165, 0, 25) or UDim2.new(1, -85, 0, 25)
                    local LoadBtn = create("TextButton",
                        {
                            Text = "Load Script",
                            Size = loadBtnWidth,
                            Position = UDim2.new(0, 83, 1, -33),
                            BackgroundColor3 = theme.ButtonBg,
                            BackgroundTransparency = 0.2,
                            TextColor3 = theme.Text,
                            Font = Enum.Font.GothamBold,
                            TextSize = 13,
                            Parent = Container
                        })
                    roundify(LoadBtn, 4)

                    LoadBtn.MouseEnter:Connect(function()
                        TweenService:Create(LoadBtn, TweenInfo.new(0.2), { BackgroundColor3 = theme.ButtonHover }):Play()
                    end)
                    LoadBtn.MouseLeave:Connect(function()
                        TweenService:Create(LoadBtn, TweenInfo.new(0.2), { BackgroundColor3 = theme.ButtonBg }):Play()
                    end)

                    LoadBtn.MouseButton1Click:Connect(callback)
                else
                    local offlineWidth = isLongDesc and UDim2.new(1, -165, 0, 25) or UDim2.new(1, -85, 0, 25)
                    create("TextLabel",
                        {
                            Text = "Currently Offline / Maintenance.",
                            Size = offlineWidth,
                            Position = UDim2.new(0, 83, 1, -33),
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.fromRGB(255, 100, 100),
                            Font = Enum.Font.GothamBold,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Parent = Container
                        })
                end

                if isLongDesc then
                    local ShowMoreBtn = create("TextButton",
                        {
                            Text = "Details",
                            Size = UDim2.new(0, 75, 0, 25),
                            Position = UDim2.new(1, -80, 1, -33),
                            BackgroundColor3 = theme.ButtonBg,
                            BackgroundTransparency = 0.2,
                            TextColor3 = theme.Text,
                            Font = Enum.Font.GothamBold,
                            TextSize = 12,
                            Parent = Container
                        })
                    roundify(ShowMoreBtn, 4)
                    ShowMoreBtn.MouseEnter:Connect(function()
                        TweenService:Create(ShowMoreBtn, TweenInfo.new(0.2), { BackgroundColor3 = theme.ButtonHover })
                            :Play()
                    end)
                    ShowMoreBtn.MouseLeave:Connect(function()
                        TweenService:Create(ShowMoreBtn, TweenInfo.new(0.2), { BackgroundColor3 = theme.ButtonBg }):Play()
                    end)
                    local expanded = false
                    ShowMoreBtn.MouseButton1Click:Connect(function()
                        expanded = not expanded
                        if expanded then
                            ShowMoreBtn.Text = "Back"
                            descLbl.TextTruncate = Enum.TextTruncate.None

                            local _, newlines = string.gsub(descLbl.Text, "\n", "")
                            local dynamicPadding = 15 + (newlines * 2) +
                                (math.floor(string.len(descLbl.Text) / 50) * 1)
                            local neededHeight = descLbl.TextBounds.Y + dynamicPadding
                            if neededHeight < 40 then neededHeight = 40 end
                            local extraHeight = neededHeight - 40

                            -- Minimum expansion for better visual focus
                            if extraHeight < 200 then extraHeight = 200 end

                            -- Expand self
                            TweenService:Create(Container,
                                TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                                { Size = UDim2.new(1, 0, 0, 110 + extraHeight) }):Play()
                            TweenService:Create(descLbl,
                                TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                                { Size = UDim2.new(1, -85, 0, 40 + extraHeight) }):Play()

                            -- Hide others smoothly
                            for _, v in ipairs(Container.Parent:GetChildren()) do
                                if v ~= Container and (v:IsA("Frame") or v:IsA("TextLabel")) then
                                    v.ClipsDescendants = true
                                    local targetSize = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, 0, 0)
                                    local t = TweenService:Create(v,
                                        TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                                        { Size = targetSize })
                                    t:Play()
                                    task.spawn(function()
                                        t.Completed:Wait()
                                        if expanded then v.Visible = false end
                                    end)
                                end
                            end
                        else
                            ShowMoreBtn.Text = "Details"
                            -- Shrink self
                            TweenService:Create(Container,
                                TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                                { Size = UDim2.new(1, 0, 0, 110) }):Play()
                            TweenService:Create(descLbl,
                                TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                                { Size = UDim2.new(1, -85, 0, 40) }):Play()

                            -- Show others smoothly
                            for _, v in ipairs(Container.Parent:GetChildren()) do
                                if v ~= Container and (v:IsA("Frame") or v:IsA("TextLabel")) then
                                    v.Visible = true
                                    local targetY = v:IsA("TextLabel") and 30 or 110
                                    local targetSize = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, 0, targetY)
                                    TweenService:Create(v,
                                        TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                                        { Size = targetSize }):Play()
                                end
                            end
                            task.delay(0.4, function()
                                if not expanded then descLbl.TextTruncate = Enum.TextTruncate.AtEnd end
                            end)
                        end
                    end)
                end

                return Container
            end

            function Tab:Label(text, customColor, textWrapped)
                local wrap = textWrapped or false
                local lbl = create("TextLabel",
                    {
                        Text = text,
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundTransparency = 1,
                        TextColor3 = customColor or
                            theme.TextDim,
                        Font = theme.Font,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent =
                            TabFrame,
                        TextWrapped = wrap
                    })
                if wrap then
                    lbl.AutomaticSize = Enum.AutomaticSize.Y
                    lbl.Size = UDim2.new(1, 0, 0, 0)
                end
                return lbl
            end

            function Tab:Dropdown(text, options, callback, defaultVal)
                local currentSelection = defaultVal or text
                local Frame = create("Frame",
                    {
                        Name = "Dropdown",
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundColor3 = theme.ButtonBg,
                        BackgroundTransparency = 0.2,
                        Parent =
                            TabFrame,
                        ClipsDescendants = true
                    })
                roundify(Frame, 6)
                local Header = create("TextButton",
                    {
                        Text = text .. (defaultVal and ": " .. defaultVal or " ▼"),
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundTransparency = 1,
                        TextColor3 =
                            theme.Text,
                        Font = theme.Font,
                        TextSize = 14,
                        Parent = Frame
                    })
                local List = create("Frame",
                    {
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 0, 35),
                        BackgroundTransparency = 1,
                        Parent =
                            Frame
                    })
                create("UIListLayout", { Parent = List })
                local open = false
                Header.MouseButton1Click:Connect(function()
                    open = not open
                    tween(Frame, { Size = UDim2.new(1, 0, 0, open and 35 + (#options * 30) or 35) }, 0.2)
                end)
                for _, opt in pairs(options) do
                    local OptBtn = create("TextButton",
                        {
                            Text = opt,
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = theme.Panel,
                            BackgroundTransparency = 0.2,
                            TextColor3 =
                                theme.Text,
                            Font = theme.Font,
                            TextSize = 13,
                            Parent = List
                        })
                    OptBtn.MouseButton1Click:Connect(function()
                        open = false
                        tween(Frame, { Size = UDim2.new(1, 0, 0, 35) }, 0.2)
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

                local Frame = create("Frame",
                    {
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundColor3 = theme.ButtonBg,
                        BackgroundTransparency = 0.2,
                        Parent =
                            TabFrame
                    })
                roundify(Frame, 6)
                create("TextLabel",
                    {
                        Text = text,
                        Size = UDim2.new(1, -50, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        TextColor3 =
                            theme.Text,
                        Font = theme.Font,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent =
                            Frame
                    })

                local Indicator = create("TextButton",
                    {
                        Text = "",
                        Size = UDim2.new(0, 20, 0, 20),
                        Position = UDim2.new(1, -30, 0.5, -10),
                        BackgroundColor3 =
                            savedState and theme.Accent or theme.Panel,
                        Parent = Frame
                    })
                roundify(Indicator, 4)

                task.spawn(function() callback(savedState) end)

                local state = savedState
                Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if Frame:GetAttribute("Disabled") then return end
                        state = not state
                        Indicator.BackgroundColor3 = state and theme.Accent or theme.Panel
                        if isRootSetting then SystemSettings[key] = state else SystemSettings.Toggles[key] = state end
                        SaveData()
                        callback(state)
                    end
                end)
                Frame:GetAttributeChangedSignal("ForceState"):Connect(function()
                    local forceVal = Frame:GetAttribute("ForceState")
                    if forceVal ~= nil and forceVal ~= state then
                        state = forceVal
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
