-- [[ SERVICES & INITIALIZATION ]]
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- [[ GAME LOGIC VARIABLES ]]
local autoAttack = false
local Settings = { Distance = 50, AttackDelay = 0 }
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local hitData = { [4] = "4676ac1a" }
local selectedWeaponType = "Melee"
local selectedStat = "Melee"
local autoStats = false
local addAmount = 1
local bountyFarm = false
local autofarm = false
local autoFarmNearest = false
local chestFarmEnabled = false
local infJumpEnabled = false
local info
local orbitDistance = 15
local orbitRadius = 10
local orbitHeight = 20
local snapTime = 1.5
local snapIndex = 1
local lastSwitch = os.clock()
local snapOffsets = {
    Vector3.new(orbitRadius, orbitHeight, 0),
    Vector3.new(0, orbitHeight, orbitRadius),
    Vector3.new(-orbitRadius, orbitHeight, 0),
    Vector3.new(0, orbitHeight, -orbitRadius)
}
local tweenSpeed = 350
local orbitBringEnabled = false
local bringOffset = 10
local espConnection = nil

Player.CharacterAdded:Connect(function(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid")
    HumanoidRootPart = c:WaitForChild("HumanoidRootPart")
    if not Character:FindFirstChild("HasBuso") then
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
    end
end)

local Quests = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/CFR-Executor/resources/refs/heads/main/bfquestdumpfull"))()

-- [[ CORE FUNCTIONS ]]
local function isOnIsland(islandName)
    local map = Workspace:WaitForChild("Map")
    local island = map:FindFirstChild(islandName)
    if not island then return false end
    for _, part in ipairs(island:GetDescendants()) do
        if part:IsA("BasePart") then
            local relative = part.CFrame:PointToObjectSpace(HumanoidRootPart.Position)
            local half = part.Size / 2
            if math.abs(relative.X) <= half.X and math.abs(relative.Z) <= half.Z then
                if relative.Y >= -50 and relative.Y <= half.Y + 50 then return true end
            end
        end
    end
    return false
end

local function moveTo(position)
    if not HumanoidRootPart then return end
    local dist = (HumanoidRootPart.Position - position).Magnitude
    local timeToTravel = dist / tweenSpeed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = CFrame.new(position) })
    tween:Play()
end

local function loadEnemy(enemyName)
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    if not origin then return nil end
    local spawns = origin:FindFirstChild("EnemySpawns")
    if not spawns then return nil end
    for _, spawn in ipairs(spawns:GetChildren()) do
        local cleanName = spawn.Name:gsub("%[Lv%.%s*%d+%]%s*", ""):gsub("%s+$", "")
        if cleanName == enemyName then
            moveTo(spawn.Position + Vector3.new(0, 20, 0))
            return spawn
        end
    end
    return nil
end

local function teleportToIsland(island)
    if not HumanoidRootPart then return end
    if island == "Fishmen" or island == "Fishman" then
        if isOnIsland("Fishmen") or isOnIsland("Fishman") then
            HumanoidRootPart.CFrame = workspace.Map.TeleportSpawn.ExitPoint.CFrame
        else
            HumanoidRootPart.CFrame = workspace.Map.TeleportSpawn.EntrancePoint.CFrame
        end
    elseif island == "SkyArea1" then
        HumanoidRootPart.CFrame = workspace.Map.SkyArea2.PathwayHouse.EntrancePoint.CFrame
    elseif island == "SkyArea2" then
        HumanoidRootPart.CFrame = workspace.Map.SkyArea1.PathwayTemple.ExitPoint.CFrame
    else
        local islandModel = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild(island)
        if islandModel and islandModel:GetPivot() then
            moveTo(islandModel:GetPivot().Position + Vector3.new(0, 50, 0))
        end
    end
end

local islandNames = {
    BanditQuest1 = "Windmill",
    MarineQuest = "MarineStart",
    JungleQuest = "Jungle",
    BuggyQuest1 = "Pirate",
    BuggyQuest2 = "Pirate",
    DesertQuest = "Desert",
    SnowQuest = "Ice",
    MarineQuest2 = "MarineBase",
    SkyQuest = "Sky",
    SkyQuest2 = "Sky",
    PrisonerQuest = "Prison",
    ImpelQuest = "Prison",
    ColosseumQuest = "Colosseum",
    MagmaQuest = "Magma",
    FishmanQuest = "Fishmen",
    SkyExp1Quest = "SkyArea1",
    SkyExp2Quest = "SkyArea2",
    FountainQuest = "Fountain"
}

local function attachFloat()
    if not HumanoidRootPart then return end
    if not HumanoidRootPart:FindFirstChild("FloatBV") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FloatBV"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = HumanoidRootPart
    end
    if not HumanoidRootPart:FindFirstChild("StabilizerBG") then
        local bg = Instance.new("BodyGyro")
        bg.Name = "StabilizerBG"
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.CFrame = HumanoidRootPart.CFrame
        bg.Parent = HumanoidRootPart
    end
end

local function getQuest(level)
    local player = game:GetService("Players").LocalPlayer
    local levelObj = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level")
    if not levelObj then return nil end
    local levelData = levelObj.Value
    local highestQuest, highestIsland
    for islandName, questList in pairs(Quests) do
        for _, quest in ipairs(questList) do
            if levelData >= quest.LevelReq then
                if not highestQuest or quest.LevelReq > highestQuest.LevelReq then
                    highestQuest = quest
                    highestIsland = islandName
                end
            end
        end
    end
    if not highestQuest then return nil end
    local questFrame = player.PlayerGui:WaitForChild("Main"):WaitForChild("Quest")
    local hasQuest = questFrame.Visible
    if not hasQuest then
        pcall(function()
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(highestQuest.Args))
        end)
    end
    local enemyName
    if hasQuest then
        local titleLabel = questFrame.Container.QuestTitle:FindFirstChild("Title")
        if titleLabel then
            local parsed = titleLabel.Text:match("Defeat%s+%d+%s+(.+)%s+%(%d+/%d+%)")
            if parsed then enemyName = parsed end
        end
    end
    if not enemyName and highestQuest.Task then
        for name, _ in pairs(highestQuest.Task) do
            enemyName = name
            break
        end
    end
    local island = islandNames[highestIsland] or highestIsland
    if not isOnIsland(island) then
        local islandModel = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild(island)
        if islandModel then
            teleportToIsland(island)
        end
    end
    if enemyName then loadEnemy(enemyName) end
    return {
        quest = highestQuest,
        enemy = enemyName,
        island = island,
        levelReq = highestQuest.LevelReq,
        args = highestQuest.Args
    }
end

local function toggleAutoAttack()
    if autoAttack then
        task.spawn(function()
            while autoAttack do
                if not HumanoidRootPart then break end
                local enemiesInRange = {}
                for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                    local head = enemy:FindFirstChild("Head")
                    if head and (HumanoidRootPart.Position - head.Position).Magnitude <= Settings.Distance then
                        table.insert(enemiesInRange, { enemy, head })
                    end
                end
                if bountyFarm then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Player and p.Character then
                            local head = p.Character:FindFirstChild("Head")
                            if head and (HumanoidRootPart.Position - head.Position).Magnitude <= Settings.Distance then
                                table.insert(enemiesInRange, { p.Character, head })
                            end
                        end
                    end
                end
                if #enemiesInRange >= 1 then
                    local target = enemiesInRange[1]
                    local args
                    if #enemiesInRange >= 2 then
                        local other = enemiesInRange[2]
                        args = { target[2], { { other[1], other[2] } }, [4] = hitData[4] }
                    else
                        args = { target[2], {}, [4] = hitData[4] }
                    end
                    pcall(function()
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(unpack(args))
                    end)
                end
                for _, tool in ipairs(Player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == selectedWeaponType then
                        tool.Parent = Character
                    end
                end
                for _, tool in ipairs(Character:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip ~= selectedWeaponType then
                        tool.Parent = Player.Backpack
                    end
                end
                task.wait(Settings.AttackDelay)
            end
        end)
    end
end

-- Infinite Jump
local holdingSpace = false
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Space then
        holdingSpace = true
        task.spawn(function()
            while holdingSpace and infJumpEnabled and Player.Character do
                local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                task.wait(0.1)
            end
        end)
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Space then
        holdingSpace = false
    end
end)

-- Water Walk
local waterWalk = Instance.new("Part", workspace)
waterWalk.Transparency = 1
waterWalk.Name = "WaterWalk"
waterWalk.CanCollide = false
waterWalk.Size = Vector3.new(1000, 1, 1000)
waterWalk.Anchored = true

-- Main Loops
RunService.Heartbeat:Connect(function(dt)
    if autoStats then
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", selectedStat, addAmount) end)
    end

    if not (autofarm or autoFarmNearest or bountyFarm) then
        if HumanoidRootPart and HumanoidRootPart:FindFirstChild("FloatBV") then
            HumanoidRootPart.FloatBV:Destroy()
        end
        if HumanoidRootPart and HumanoidRootPart:FindFirstChild("StabilizerBG") then
            HumanoidRootPart.StabilizerBG:Destroy()
        end
        return
    end

    attachFloat()

    local target = nil
    if autofarm then
        if not info or not info.enemy then
            info = getQuest(true)
            return
        end
        for _, bodypart in ipairs(Character:GetChildren()) do
            if bodypart:IsA("BasePart") then bodypart.CanCollide = false end
        end

        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if enemy.Name == info.enemy and humanoid and humanoid.Health > 0 then
                target = enemy
                break
            end
        end

        if not Player.PlayerGui.Main.Quest.Visible then
            info = getQuest(true)
            return
        end
    elseif autoFarmNearest then
        local nearest = math.huge
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                local d = (HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if d < nearest then
                    nearest = d
                    target = enemy
                end
            end
        end
    end

    if target and target:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.HumanoidRootPart.Position

        if orbitBringEnabled then
            -- 1. Check if we've ALREADY grabbed the target
            local expectedHoldPos = HumanoidRootPart.Position - Vector3.new(0, bringOffset, 0)
            local isHoldingTarget = (targetPos - expectedHoldPos).Magnitude < 5

            if isHoldingTarget then
                -- WE HAVE THE TARGET: Lock the player strictly in place so we don't fly up
                HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position)

                -- Keep primary target under us
                target.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, -bringOffset, 0)
                target.HumanoidRootPart.Anchored = false
                target.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

                -- Bring all other enemies
                for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                    if enemy ~= target and enemy.Name == target.Name and enemy:FindFirstChild("HumanoidRootPart") then
                        enemy.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, -bringOffset, 0)
                        enemy.HumanoidRootPart.Anchored = false
                        enemy.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            else
                -- WE DON'T HAVE THE TARGET YET: Move towards the orbit position above them
                local orbitPos = targetPos + Vector3.new(0, orbitHeight, 0)

                -- Measure distance to the ORBIT spot in the sky, not the target on the ground
                local distanceToOrbit = (HumanoidRootPart.Position - orbitPos).Magnitude

                if distanceToOrbit > orbitDistance then
                    moveTo(orbitPos)
                else
                    -- We reached the spot! Do the first teleport to grab them.
                    target.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, -bringOffset, 0)
                    target.HumanoidRootPart.Anchored = false
                    target.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        else
            -- Normal orbit
            local distanceToTarget = (HumanoidRootPart.Position - targetPos).Magnitude
            if distanceToTarget > orbitDistance then
                moveTo(targetPos + Vector3.new(0, 10, 0))
            else
                HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

                if os.clock() - lastSwitch >= snapTime then
                    snapIndex = (snapIndex % #snapOffsets) + 1
                    lastSwitch = os.clock()
                end
                local orbitPos = targetPos + snapOffsets[snapIndex]

                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position:Lerp(orbitPos, 0.2))
                target.HumanoidRootPart.Anchored = false
                target.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)
local LocalPlayer = Players.LocalPlayer
local noclip = false
local noclipConnection = nil

local function toggleNoclip(forceState)
    -- If the UI toggle provides a specific true/false value, use it.
    -- If no value is provided (e.g., triggered by a keybind), just flip the current state.
    if type(forceState) == "boolean" then
        noclip = forceState
    else
        noclip = not noclip
    end

    if noclip then
        if noclipConnection then
            noclipConnection:Disconnect()
        end

        noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part.Parent:IsA("Accessory") then
                    part.CanCollide = true
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if HumanoidRootPart then
        waterWalk.Position = Vector3.new(HumanoidRootPart.Position.X, -4.5, HumanoidRootPart.Position.Z)
    end
end)


-- [[ MODERN UI LIBRARY ]]
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "NexusUI" then gui:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusUI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 65)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopBar.BackgroundTransparency = 0
TopBar.Size = UDim2.new(1, 0, 0, 45)

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarSquare = Instance.new("Frame")
TopBarSquare.Parent = TopBar
TopBarSquare.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopBarSquare.BorderSizePixel = 0
TopBarSquare.Position = UDim2.new(0, 0, 1, -10)
TopBarSquare.Size = UDim2.new(1, 0, 0, 10)

local TopBarSeparator = Instance.new("Frame")
TopBarSeparator.Parent = TopBar
TopBarSeparator.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
TopBarSeparator.BorderSizePixel = 0
TopBarSeparator.Position = UDim2.new(0, 0, 1, 0)
TopBarSeparator.Size = UDim2.new(1, 0, 0, 1)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Nexus <font color='#8A64FF'>Myrobloxgame</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TopBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 16
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = TopBar
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -80, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 40, 1, 0)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 600, 0, 45)
    else
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
            startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.Size = UDim2.new(0, 140, 1, -46)

local SidebarSeparator = Instance.new("Frame")
SidebarSeparator.Parent = Sidebar
SidebarSeparator.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
SidebarSeparator.BorderSizePixel = 0
SidebarSeparator.Position = UDim2.new(1, 0, 0, 0)
SidebarSeparator.Size = UDim2.new(0, 1, 1, 0)

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Parent = Sidebar
TabContainer.BackgroundTransparency = 1
TabContainer.Size = UDim2.new(1, 0, 1, 0)
TabContainer.ScrollBarThickness = 0
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 141, 0, 46)
ContentContainer.Size = UDim2.new(1, -141, 1, -46)

local Tabs = {}
local activeTab = nil

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    TabBtn.TextSize = 14

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Parent = ContentContainer
    TabPage.BackgroundTransparency = 1
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.ScrollBarThickness = 2
    TabPage.Visible = false

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = TabPage
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local PagePadding = Instance.new("UIPadding")
    PagePadding.Parent = TabPage
    PagePadding.PaddingTop = UDim.new(0, 15)
    PagePadding.PaddingBottom = UDim.new(0, 15)

    TabBtn.MouseButton1Click:Connect(function()
        if activeTab then
            TweenService:Create(activeTab.Btn, TweenInfo.new(0.2),
                { TextColor3 = Color3.fromRGB(150, 150, 160), BackgroundTransparency = 1 }):Play()
            activeTab.Page.Visible = false
        end
        activeTab = { Btn = TabBtn, Page = TabPage }
        TweenService:Create(TabBtn, TweenInfo.new(0.2),
            { TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.5 }):Play()
        TabPage.Visible = true
    end)

    if not activeTab then
        activeTab = { Btn = TabBtn, Page = TabPage }
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 0.5
        TabPage.Visible = true
    end

    local Elements = {}
    local lastRow = nil

    function Elements:CreateToggle(title, default, callback)
        local parentFrame
        if lastRow and #lastRow:GetChildren() < 3 then -- 3 because UIListLayout adds 1 implicitly
            parentFrame = lastRow
        else
            lastRow = Instance.new("Frame")
            lastRow.Parent = TabPage
            lastRow.BackgroundTransparency = 1
            lastRow.Size = UDim2.new(0, 420, 0, 40)
            local RowLayout = Instance.new("UIListLayout")
            RowLayout.Parent = lastRow
            RowLayout.FillDirection = Enum.FillDirection.Horizontal
            RowLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RowLayout.Padding = UDim.new(0, 10)
            parentFrame = lastRow
        end

        local Frame = Instance.new("Frame")
        Frame.Parent = parentFrame
        Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        Frame.Size = UDim2.new(0, 205, 0, 40)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Size = UDim2.new(1, -55, 1, 0)
        Label.Font = Enum.Font.GothamMedium
        Label.Text = title
        Label.TextColor3 = Color3.fromRGB(220, 220, 225)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton")
        Btn.Parent = Frame
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Btn.Position = UDim2.new(1, -42, 0.5, -10)
        Btn.Size = UDim2.new(0, 34, 0, 20)
        Btn.Text = ""
        Btn.AutoButtonColor = false
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(1, 0)
        BtnCorner.Parent = Btn

        local Circle = Instance.new("Frame")
        Circle.Parent = Btn
        Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Circle.Position = UDim2.new(0, 2, 0.5, -8)
        Circle.Size = UDim2.new(0, 16, 0, 16)
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = Circle

        local state = default

        local function setState(val)
            state = val
            callback(state)
            if state then
                TweenService:Create(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(138, 100, 255) }):Play()
                TweenService:Create(Circle, TweenInfo.new(0.2),
                    { Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            else
                TweenService:Create(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 50) }):Play()
                TweenService:Create(Circle, TweenInfo.new(0.2),
                    { Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200, 200, 200) }):Play()
            end
        end
        setState(state)

        Btn.MouseButton1Click:Connect(function() setState(not state) end)
    end

    function Elements:CreateSlider(title, min, max, default, callback)
        lastRow = nil -- break toggle row
        local Frame = Instance.new("Frame")
        Frame.Parent = TabPage
        Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        Frame.Size = UDim2.new(0, 420, 0, 50)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 15, 0, 20)
        Label.Size = UDim2.new(1, -70, 0, 20)
        Label.Font = Enum.Font.GothamMedium
        Label.Text = title .. ": " .. tostring(default)
        Label.TextColor3 = Color3.fromRGB(220, 220, 225)
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local SliderBg = Instance.new("TextButton")
        SliderBg.Parent = Frame
        SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        SliderBg.Position = UDim2.new(0, 15, 0, 35)
        SliderBg.Size = UDim2.new(1, -30, 0, 6)
        SliderBg.Text = ""
        SliderBg.AutoButtonColor = false
        local BgCorner = Instance.new("UICorner")
        BgCorner.CornerRadius = UDim.new(1, 0)
        BgCorner.Parent = SliderBg

        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderBg
        SliderFill.BackgroundColor3 = Color3.fromRGB(138, 100, 255)
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill

        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            Label.Text = title .. ": " .. tostring(val)
            callback(val)
        end
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
    end

    function Elements:CreateDropdown(title, options, callback)
        lastRow = nil -- break toggle row
        local Frame = Instance.new("Frame")
        Frame.Parent = TabPage
        Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        Frame.Size = UDim2.new(0, 420, 0, 40)
        Frame.ClipsDescendants = true
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local Btn = Instance.new("TextButton")
        Btn.Parent = Frame
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.Font = Enum.Font.GothamMedium
        Btn.Text = "  " .. title .. ": " .. options[1]
        Btn.TextColor3 = Color3.fromRGB(220, 220, 225)
        Btn.TextSize = 13
        Btn.TextXAlignment = Enum.TextXAlignment.Left

        local Icon = Instance.new("TextLabel")
        Icon.Parent = Btn
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(1, -30, 0, 0)
        Icon.Size = UDim2.new(0, 30, 1, 0)
        Icon.Font = Enum.Font.GothamBold
        Icon.Text = "+"
        Icon.TextColor3 = Color3.fromRGB(150, 150, 160)
        Icon.TextSize = 16

        local List = Instance.new("Frame")
        List.Parent = Frame
        List.BackgroundTransparency = 1
        List.Position = UDim2.new(0, 0, 0, 40)
        List.Size = UDim2.new(1, 0, 1, -40)
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = List

        local open = false
        Btn.MouseButton1Click:Connect(function()
            open = not open
            Icon.Text = open and "-" or "+"
            TweenService:Create(Frame, TweenInfo.new(0.2),
                { Size = UDim2.new(0, 420, 0, open and 40 + (#options * 30) or 40) }):Play()
        end)

        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Parent = List
            OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            OptBtn.BackgroundTransparency = 0.5
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.Text = opt
            OptBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            OptBtn.TextSize = 13
            OptBtn.MouseButton1Click:Connect(function()
                open = false
                Icon.Text = "+"
                TweenService:Create(Frame, TweenInfo.new(0.2), { Size = UDim2.new(0, 420, 0, 40) }):Play()
                Btn.Text = "  " .. title .. ": " .. opt
                callback(opt)
            end)
        end
    end

    return Elements
end

-- [[ BUILD UI TABS ]]
local AutoFarmTab = CreateTab("Auto Farm")
AutoFarmTab:CreateDropdown("Weapon Type", { "Melee", "Blox Fruit", "Sword" }, function(val)
    selectedWeaponType = val
end)
AutoFarmTab:CreateToggle("Auto Attack", false, function(val)
    autoAttack = val
    if autoAttack then toggleAutoAttack() end
end)
AutoFarmTab:CreateToggle("Auto Farm Level", false, function(val)
    autofarm = val
    if autofarm then
        info = getQuest(true)
        if not autoAttack then
            autoAttack = true
            toggleAutoAttack()
        end
    end
end)
AutoFarmTab:CreateToggle("Auto Farm Nearest", false, function(val)
    autoFarmNearest = val
    if autoFarmNearest then
        if not autoAttack then
            autoAttack = true
            toggleAutoAttack()
        end
    end
end)
AutoFarmTab:CreateToggle("Orbit Bring", false, function(val)
    orbitBringEnabled = val
end)
AutoFarmTab:CreateToggle("NoClip", false, function(val)
    toggleNoclip(val)
end)
AutoFarmTab:CreateToggle("Auto Farm Chests", false, function(val)
    chestFarmEnabled = val
    if chestFarmEnabled then
        task.spawn(function()
            local taken = {}
            while chestFarmEnabled do
                local character = Players.LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")

                if hrp then
                    for _, chest in ipairs(workspace:WaitForChild("ChestModels"):GetChildren()) do
                        -- Immediately break the loop if the user turns off the toggle mid-farm
                        if not chestFarmEnabled then break end

                        if not taken[chest] and chest:IsA("Model") then
                            local targetPos = chest:GetPivot().Position

                            -- Use your existing tween function instead of snapping
                            moveTo(targetPos)

                            -- Yield the script until the tween actually reaches the chest
                            repeat
                                task.wait(0.1)
                                if not hrp or not chestFarmEnabled then break end
                            until (hrp.Position - targetPos).Magnitude < 5

                            taken[chest] = true

                            -- Give the server a brief moment to register the chest collection
                            task.wait(0.2)
                        end
                    end
                end
                task.wait(1) -- Wait before scanning for newly spawned chests
            end
        end)
    end
end)
AutoFarmTab:CreateSlider("Orbit Height", 10, 50, 20, function(val)
    orbitHeight = val
end)
AutoFarmTab:CreateSlider("Bring Offset", 5, 30, 10, function(val)
    bringOffset = val
end)

local PlayerTab = CreateTab("Player")
PlayerTab:CreateDropdown("Stat Select", { "Melee", "Defense", "Sword", "Gun", "Demon Fruit" }, function(val)
    selectedStat = val
end)
PlayerTab:CreateToggle("Infinite Jump", false, function(val)
    infJumpEnabled = val
end)
PlayerTab:CreateToggle("Walk on Water", false, function(val)
    waterWalk.CanCollide = val
end)
PlayerTab:CreateToggle("Auto Stats", false, function(val)
    autoStats = val
end)
PlayerTab:CreateSlider("WalkSpeed", 16, 325, 16, function(val)
    if Humanoid then Humanoid.WalkSpeed = val end
end)
PlayerTab:CreateSlider("Stat Amount", 1, 10, 1, function(val)
    addAmount = val
end)

local MiscTab = CreateTab("Misc")
MiscTab:CreateSlider("Teleport Speed", 100, 1000, 350, function(val)
    tweenSpeed = val
end)
MiscTab:CreateToggle("Highlight Enemies", false, function(val)
    if val then
        espConnection = RunService.RenderStepped:Connect(function()
            local enemiesFolder = workspace:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if not enemy:FindFirstChild("EnemyHighlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "EnemyHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 50, 50)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.6
                        highlight.OutlineTransparency = 0.1
                        highlight.Parent = enemy
                    end
                end
            end
        end)
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                local hl = enemy:FindFirstChild("EnemyHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
end)
