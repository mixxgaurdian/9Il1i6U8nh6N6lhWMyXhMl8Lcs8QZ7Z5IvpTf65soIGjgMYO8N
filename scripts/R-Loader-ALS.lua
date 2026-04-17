-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- System Variables
local defensePadding = 50 
local farmRegularKi = false
local farmGreenKi = false
local showDefenseZone = true
local showBossBarrier = false
local teleportInterval = 0.02 
local lastTeleportTime = 0

local cachedBossBarrier = nil
local defenseVisualizer = nil
local barrierHighlight = nil

-- The Memory Cache to prevent getting stuck on "dead" Ki
local grabbedCache = {}

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "R-Loader-ALS UI-DEMO",
   LoadingTitle = "Loading Configuration...",
   LoadingSubtitle = "Reading JSON Data",
   
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "R-Loader_ALS", -- Folder created in your executor's workspace
      FileName = "FarmSettings"           -- Saved as FarmSettings.json
   },
   Discord = { Enabled = false },
   KeySystem = false,
   KeybindOptions = {
       UseUIBind = false,
   }
})

-- ==========================================
-- Core Functions
-- ==========================================

local function getBossBarrier()
    if cachedBossBarrier and cachedBossBarrier.Parent then
        return cachedBossBarrier
    end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "BossBarrier" then
            cachedBossBarrier = v
            return v
        end
    end
    return nil
end

local function updateVisuals(barrier, boxSize, boxCFrame)
    if not showDefenseZone then
        if defenseVisualizer then defenseVisualizer:Destroy() end
    else
        if not defenseVisualizer or not defenseVisualizer.Parent then
            defenseVisualizer = Instance.new("Part")
            defenseVisualizer.Name = "BossDefenseVisualizer"
            defenseVisualizer.Shape = Enum.PartType.Block 
            defenseVisualizer.Color = Color3.fromRGB(255, 50, 50)
            defenseVisualizer.Transparency = 0.7
            defenseVisualizer.Material = Enum.Material.ForceField
            defenseVisualizer.CanCollide = false
            defenseVisualizer.Massless = true
            defenseVisualizer.Anchored = true
            defenseVisualizer.CastShadow = false
            defenseVisualizer.Parent = workspace
        end

        if barrier then
            defenseVisualizer.CFrame = boxCFrame
            defenseVisualizer.Size = boxSize
        end
    end

    if not showBossBarrier then
        if barrierHighlight then barrierHighlight:Destroy() end
    else
        if barrier and (not barrierHighlight or not barrierHighlight.Parent) then
            barrierHighlight = Instance.new("SelectionBox")
            barrierHighlight.Name = "BarrierReveal"
            barrierHighlight.Color3 = Color3.fromRGB(0, 255, 0)
            barrierHighlight.LineThickness = 0.05
            barrierHighlight.SurfaceTransparency = 0.8
            barrierHighlight.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
            barrierHighlight.Adornee = barrier
            barrierHighlight.Parent = barrier
        end
    end
end

local function handleVisualizerToggles()
    if not showDefenseZone and defenseVisualizer then
        defenseVisualizer:Destroy()
        defenseVisualizer = nil
    end
    if not showBossBarrier and barrierHighlight then
        barrierHighlight:Destroy()
        barrierHighlight = nil
    end
end

-- ==========================================
-- Main Interceptor Loop (Pre-Physics)
-- ==========================================

RunService.Stepped:Connect(function()
    if not farmRegularKi and not farmGreenKi then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local barrier = getBossBarrier()
    if not barrier then return end

    local detectionSize = barrier.Size + Vector3.new(defensePadding, defensePadding, defensePadding)
    local detectionCFrame = barrier.CFrame

    updateVisuals(barrier, detectionSize, detectionCFrame)

    if os.clock() - lastTeleportTime < teleportInterval then return end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {char, defenseVisualizer}
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local partsInZone = workspace:GetPartBoundsInBox(detectionCFrame, detectionSize, overlapParams)

    local closestKi = nil
    local shortestDistance = math.huge 

    for _, hit in ipairs(partsInZone) do
        local isRegular = farmRegularKi and hit.Name == "RegularKi"
        local isGreen = farmGreenKi and hit.Name == "GreenKi"

        if isRegular or isGreen then
            if grabbedCache[hit] and (os.clock() - grabbedCache[hit] < 1.5) then
                continue 
            end

            local distanceToBarrier = (hit.Position - barrier.Position).Magnitude
            if distanceToBarrier < shortestDistance then
                shortestDistance = distanceToBarrier
                closestKi = hit
            end
        end
    end

    if closestKi then
        hrp.CFrame = closestKi.CFrame
        grabbedCache[closestKi] = os.clock()
        lastTeleportTime = os.clock()

        if firetouchinterest and closestKi:FindFirstChildWhichIsA("TouchTransmitter") then
            firetouchinterest(hrp, closestKi, 0) 
            firetouchinterest(hrp, closestKi, 1) 
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        local currentTime = os.clock()
        for ki, timeGrabbed in pairs(grabbedCache) do
            if not ki.Parent or (currentTime - timeGrabbed > 2) then
                grabbedCache[ki] = nil
            end
        end
    end
end)

-- ==========================================
-- User Interface (With Auto-Save Flags)
-- ==========================================

local InterceptTab = Window:CreateTab("Main", nil)
local ConfigTab = Window:CreateTab("Configuration", nil)

InterceptTab:CreateSection("Absolute Defense Zone")

InterceptTab:CreateSlider({
   Name = "Defense Box Padding",
   Range = {0, 500},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 50,
   Flag = "DefensePaddingSlider", -- Flag ensures this saves to JSON
   Callback = function(Value)
        defensePadding = Value * 2 
   end,
})

InterceptTab:CreateToggle({
   Name = "Show Defense Box (Red)",
   CurrentValue = true,
   Flag = "ZoneVisibility",
   Callback = function(Value)
       showDefenseZone = Value
       handleVisualizerToggles()
   end,
})

InterceptTab:CreateToggle({
   Name = "Show Boss Barrier (Green)",
   CurrentValue = false,
   Flag = "BarrierVisibility",
   Callback = function(Value)
       showBossBarrier = Value
       handleVisualizerToggles()
   end,
})

InterceptTab:CreateSection("Target Settings")

InterceptTab:CreateToggle({
   Name = "Auto-Grab RegularKi",
   CurrentValue = false,
   Flag = "GrabRegular",
   Callback = function(Value)
       farmRegularKi = Value
   end,
})

InterceptTab:CreateToggle({
   Name = "Auto-Grab GreenKi",
   CurrentValue = false,
   Flag = "GrabGreen",
   Callback = function(Value)
       farmGreenKi = Value
   end,
})

InterceptTab:CreateSlider({
   Name = "Teleport Cooldown Interval",
   Range = {0, 1},
   Increment = 0.01,
   Suffix = "Seconds",
   CurrentValue = 0.02, 
   Flag = "IntervalSlider",
   Callback = function(Value)
        teleportInterval = Value
   end,
})

-- ==========================================
-- Configuration & JSON Controls
-- ==========================================

ConfigTab:CreateSection("Hotkey Config")

ConfigTab:CreateSection("Data Management")

ConfigTab:CreateButton({
   Name = "Save Current Settings to JSON",
   Callback = function()
       -- Triggers Rayfield's native writefile command
       Rayfield:SaveConfiguration()
   end,
})

ConfigTab:CreateButton({
   Name = "Load Settings from JSON",
   Callback = function()
       -- Reads the JSON from the workspace folder and updates all sliders/toggles
       Rayfield:LoadConfiguration()
   end,
})

-- Auto-load configuration upon injection if the file already exists
task.delay(1, function()
    pcall(function()
        Rayfield:LoadConfiguration()
    end)
end)