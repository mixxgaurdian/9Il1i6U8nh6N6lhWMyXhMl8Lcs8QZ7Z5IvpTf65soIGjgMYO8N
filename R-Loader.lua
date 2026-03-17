-- // R-LOADER KEY SYSTEM // ------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global variable to yield the main script
getgenv().RLoader_KeyVerified = false

-- // SPECIAL USERS & BYPASS // ---------------------------------------------------------------
local SpecialUsers = {
    [1104273577] = { Title = "Welcome, Developer" },
    [2335971665] = { Title = "Welcome, 👑King" },
    --[10104221280] = { Title = "Welcome, Dev" }
}

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
local function tween(obj, props, t) TweenService:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

-- // INTRO ANIMATION // ----------------------------------------------------------------------
local function PlayIntro()
    local isSpecial = SpecialUsers[LocalPlayer.UserId]
    local introText = isSpecial and isSpecial.Title or "Welcome, " .. LocalPlayer.Name

    local IntroGui = create("ScreenGui", {Name = "RLoader_KeyIntro", Parent = (gethui and gethui()) or CoreGui, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local IntroBG = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BackgroundTransparency = 1, Parent = IntroGui})
    local Container = create("Frame", {Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.5, 0, 0.5, -175), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = IntroBG})
    local PFP = create("ImageLabel", {Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, -50, 0.3, 0), BackgroundTransparency = 1, ImageTransparency = 1, Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150", Parent = Container})
    roundify(PFP, 50)
    
    local NameLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.65, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(240, 240, 240), TextScaled = true, Font = Enum.Font.GothamBold, Text = "", Parent = Container})
    local Line = create("Frame", {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 0.75, 0), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = Container})

    TweenService:Create(PFP, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
    TweenService:Create(Line, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 2), BackgroundTransparency = 0}):Play()
    
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

--PlayIntro()

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
    N.Position = UDim2.new(1, 300, 0, 0)
    tween(N, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
    task.spawn(function()
        task.wait(3)
        tween(N, {BackgroundTransparency = 1}, 0.5)
        for _,v in pairs(N:GetChildren()) do if v:IsA("TextLabel") then tween(v, {TextTransparency=1}, 0.5) end end
        task.wait(0.5); N:Destroy()
    end)
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

local VerifyBtn = create("TextButton", {Text = "Verify Key", Size = UDim2.new(0, 450, 0, 45), Position = UDim2.new(0.5, 0, 0.5, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = theme.ButtonBg, TextColor3 = theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, Parent = Container})
roundify(VerifyBtn, 6); addStroke(VerifyBtn, theme.Accent)

local DiscordBtn = create("TextButton", {Text = "Copy Discord Link", Size = UDim2.new(0, 450, 0, 40), Position = UDim2.new(0.5, 0, 0.5, 80), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(88, 101, 242), BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(255, 255, 255), Font = theme.Font, TextSize = 14, Parent = Container})
roundify(DiscordBtn, 6)
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

local CORRECT_KEY = "R-LOADER-DISCORD!"
local Discord_Link = "https://discord.gg/g2ufS3jV"

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard(Discord_Link)
    Notify("Discord", "Invite link copied to clipboard!")
end)

local function Authenticate()
    getgenv().RLoader_KeyVerified = true
    Notify("Success", "Key authenticated. Loading R-Loader...")
    task.wait(1)
    
    -- Smooth exit animation before destroying
    tween(Container, {Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 1}, 0.3)
    for _, v in pairs(Container:GetChildren()) do if v:IsA("GuiObject") then tween(v, {BackgroundTransparency = 1}, 0.3) end end
    tween(Wall, {ImageTransparency = 1}, 0.5)
    
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mixxgaurdian/9Il1i6U8nh6N6lhWMyXhMl8Lcs8QZ7Z5IvpTf65soIGjgMYO8N/refs/heads/main/R-Loader.lua"))()
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
        KeyInput.Text = "Is this the key? 🤔"
        KeyInput.TextEditable = false
        task.wait(0.2)
        Authenticate()
    end
end)

-- Yield execution until key is verified
while not getgenv().RLoader_KeyVerified do
    task.wait(0.1)
end
