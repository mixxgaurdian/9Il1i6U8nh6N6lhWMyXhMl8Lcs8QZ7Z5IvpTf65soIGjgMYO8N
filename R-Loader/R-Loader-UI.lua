return (function()
    local UILibrary = {}

local Icons = {
    -- Roles & Ranks (New)
    owner = "👑",
    admin = "🛡️",
    mod = "👮",
    dev = "🔨",
    vip = "💎",
    partner = "🤝",
    banned = "🚫",

    
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

    -- fake Cheat Features
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

UILibrary.Icons = Icons
UILibrary.Colors = Colors
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
        local RL_VERSION="rloader-b29"

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
            Image = GetProcessedIcon(Header_Image), -- PASTE YOUR PNG LINK INSIDE THESE QUOTES
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
            
            function Tab:ScriptCard(name, iconId, desc, isDown, callback)
                 local Container = create("Frame", {Name = "ScriptCard_"..name, Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = theme.Panel, BackgroundTransparency = 0.2, Parent = TabFrame})
                 roundify(Container, 8); addStroke(Container, theme.Border)
                 
                 local IconContainer = create("Frame", {Size = UDim2.new(0, 65, 0, 65), Position = UDim2.new(0, 8, 0.5, -32.5), BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.5, Parent = Container})
                 roundify(IconContainer, 8); addStroke(IconContainer, theme.Border)
                 create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = (GetProcessedIcon and GetProcessedIcon(iconId)) or iconId, ScaleType = Enum.ScaleType.Fit, Parent = IconContainer})
                 
                 create("TextLabel", {Text = name, Size = UDim2.new(1, -115, 0, 20), Position = UDim2.new(0, 83, 0, 8), BackgroundTransparency = 1, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Container})
                 
                 -- STATUS DOT LOGIC
                 local statusColor = isDown and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50) -- Red if down, Green if up
                 local StatusDot = create("Frame", {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -20, 0, 12), BackgroundColor3 = statusColor, Parent = Container})
                 roundify(StatusDot, 6) -- Makes it a perfect circle
                 
                 if not isDown then
                     create("TextLabel", {Text = desc or "Not Found.", Size = UDim2.new(1, -85, 0, 40), Position = UDim2.new(0, 83, 0, 30), BackgroundTransparency = 1, TextColor3 = theme.TextDim, Font = theme.Font, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Container})

                 else               
                    create("TextLabel", {Text = "Currently Offline / Maintenance.", Size = UDim2.new(1, -85, 0, 40), Position = UDim2.new(0, 83, 0, 30), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 100, 100), Font = theme.Font, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Container})
                 end
                 
                 -- BUTTON RENDERING LOGIC
                 if not isDown then
                     local LoadBtn = create("TextButton", {Text = "Load Script", Size = UDim2.new(1, -85, 0, 25), Position = UDim2.new(0, 83, 1, -33), BackgroundColor3 = theme.ButtonBgLoad, BackgroundTransparency = 0.2, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, Parent = Container})
                     roundify(LoadBtn, 4)
                     LoadBtn.MouseButton1Click:Connect(callback)
                 else
                     -- Optional: Text to replace the button so the UI doesn't look empty
                     create("TextLabel", {Text = "Currently Offline / Maintenance.", Size = UDim2.new(1, -85, 0, 25), Position = UDim2.new(0, 83, 1, -33), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 100, 100), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Parent = Container})
                     
                 end
                 
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
