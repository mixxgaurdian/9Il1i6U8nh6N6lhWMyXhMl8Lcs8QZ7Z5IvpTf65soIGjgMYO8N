if getgenv().ZeScriptLoaded then
    warn("RLoader-Doors is already running! Please destroy the existing instance first.")
    return
end
getgenv().ZeScriptLoaded = true

-- Removed HTTP Request dependency checks since we aren't using webhooks anymore

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/XasonYTB/XaLib/refs/heads/main/UILibrary.lua"))()

-- Keeping the track-track loader as it might be a dependency, 
-- but be aware external scripts can sometimes contain loggers.
loadstring(game:HttpGet("https://raw.githubusercontent.com/XasonYTB/ZeScript-Doors/refs/heads/main/track-track"))() 

local Window = Library:CreateWindow({
    Title = "RLoader's Doors (Enjoy!!)",
    Size = Vector2.new(700, 500),
    Keybind = Enum.KeyCode.RightShift
})

local currentFloor = "Unknown"
local function detectFloor()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local gameData = ReplicatedStorage:FindFirstChild("GameData")
        if gameData then
            local floorValue = gameData:FindFirstChild("Floor")
            if floorValue then
                currentFloor = floorValue.Value
            end
        end
    end)
    return currentFloor
end

currentFloor = detectFloor()

local ExploitCategory = Window:CreateCategory("Exploits", "⚡")
local UniversalTab = ExploitCategory:CreateTab("Universal", "🌍")
local HotelTab = ExploitCategory:CreateTab("Hotel", "🏨")
local MinesTab = ExploitCategory:CreateTab("Mines", "⛏️")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Spoof Crouch
local spoofCrouchEnabled = false
local spoofCrouchLoop

UniversalTab:Toggle("Spoof Crouch", false, function(enabled)
    spoofCrouchEnabled = enabled
    
    if enabled then
        spoofCrouchLoop = task.spawn(function()
            while spoofCrouchEnabled do
                pcall(function()
                    game.ReplicatedStorage.RemotesFolder.Crouch:FireServer(true, true)
                end)
                task.wait(0.32)
            end
        end)
    else
        if spoofCrouchLoop then
            task.cancel(spoofCrouchLoop)
            spoofCrouchLoop = nil
        end
    end
end, "Tricks the game into thinking you're always crouching. Useful for avoiding certain entities!")

-- Disable Screech
local screechDisabled = false
local screechOriginalParent = nil

UniversalTab:Toggle("Disable Screech", false, function(enabled)
    screechDisabled = enabled
    
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local screech = ReplicatedStorage.Entities:FindFirstChild("Screech")
        
        if enabled and screech then
            local zeScriptStuff = ReplicatedStorage:FindFirstChild("ZeScript_Stuff")
            if not zeScriptStuff then
                zeScriptStuff = Instance.new("Folder")
                zeScriptStuff.Name = "ZeScript_Stuff"
                zeScriptStuff.Parent = ReplicatedStorage
            end
            
            local disabledEntity = zeScriptStuff:FindFirstChild("DisabledEntity")
            if not disabledEntity then
                disabledEntity = Instance.new("Folder")
                disabledEntity.Name = "DisabledEntity"
                disabledEntity.Parent = zeScriptStuff
            end
            
            screechOriginalParent = screech.Parent
            screech.Parent = disabledEntity
        elseif not enabled and screech and screechOriginalParent then
            screech.Parent = screechOriginalParent
        end
    end)
end, "Prevents Screech from spawning by moving it to a disabled folder")

-- Disable Snare
local snareDisabled = false
local snareHitboxes = {}

UniversalTab:Toggle("Disable Snare", false, function(enabled)
    snareDisabled = enabled
    
    if enabled then
        -- Disable all existing snares
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            pcall(function()
                local assets = room:FindFirstChild("Assets")
                if assets then
                    for _, snare in pairs(assets:GetChildren()) do
                        if snare.Name == "Snare" then
                            local hitbox = snare:FindFirstChild("Hitbox")
                            if hitbox then
                                hitbox.CanTouch = false
                                table.insert(snareHitboxes, hitbox)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Monitor for new snares
        task.spawn(function()
            while snareDisabled do
                task.wait(0.5)
                pcall(function()
                    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                        local assets = room:FindFirstChild("Assets")
                        if assets then
                            for _, snare in pairs(assets:GetChildren()) do
                                if snare.Name == "Snare" then
                                    local hitbox = snare:FindFirstChild("Hitbox")
                                    if hitbox and hitbox.CanTouch then
                                        hitbox.CanTouch = false
                                        if not table.find(snareHitboxes, hitbox) then
                                            table.insert(snareHitboxes, hitbox)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        -- Re-enable all snares
        for _, hitbox in pairs(snareHitboxes) do
            pcall(function()
                if hitbox and hitbox.Parent then
                    hitbox.CanTouch = true
                end
            end)
        end
        snareHitboxes = {}
    end
end, "Disables Snare traps by turning off their hitboxes")

-- Object Bypass
local objectBypassEnabled = false
local disabledObjects = {}

UniversalTab:Toggle("Object Bypass", false, function(enabled)
    objectBypassEnabled = enabled
    
    if enabled then
        -- Disable all existing dangerous objects
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            pcall(function()
                local assets = room:FindFirstChild("Assets")
                if assets then
                    -- Check for ChandelierObstruction
                    for _, chandelier in pairs(assets:GetChildren()) do
                        if chandelier.Name == "ChandelierObstruction" then
                            local collision = chandelier:FindFirstChild("Collision")
                            if collision then
                                collision.CanTouch = false
                                collision.CanQuery = false
                                table.insert(disabledObjects, collision)
                            end
                        end
                    end
                    
                    -- Check for objects with AnimatedObstacleKill attribute
                    for _, object in pairs(assets:GetDescendants()) do
                        if object:IsA("Model") and object:GetAttribute("LoadModule") == "AnimatedObstacleKill" then
                            -- Disable collision for all parts in the model
                            for _, part in pairs(object:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanTouch = false
                                    part.CanQuery = false
                                    if not table.find(disabledObjects, part) then
                                        table.insert(disabledObjects, part)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        
        -- Monitor for new dangerous objects
        task.spawn(function()
            while objectBypassEnabled do
                task.wait(0.5)
                pcall(function()
                    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                        local assets = room:FindFirstChild("Assets")
                        if assets then
                            -- Check for new ChandelierObstruction
                            for _, chandelier in pairs(assets:GetChildren()) do
                                if chandelier.Name == "ChandelierObstruction" then
                                    local collision = chandelier:FindFirstChild("Collision")
                                    if collision and collision.CanTouch then
                                        collision.CanTouch = false
                                        collision.CanQuery = false
                                        if not table.find(disabledObjects, collision) then
                                            table.insert(disabledObjects, collision)
                                        end
                                    end
                                end
                            end
                            
                            -- Check for new AnimatedObstacleKill objects
                            for _, object in pairs(assets:GetDescendants()) do
                                if object:IsA("Model") and object:GetAttribute("LoadModule") == "AnimatedObstacleKill" then
                                    for _, part in pairs(object:GetDescendants()) do
                                        if part:IsA("BasePart") and part.CanTouch then
                                            part.CanTouch = false
                                            part.CanQuery = false
                                            if not table.find(disabledObjects, part) then
                                                table.insert(disabledObjects, part)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        -- Re-enable all objects
        for _, part in pairs(disabledObjects) do
            pcall(function()
                if part and part.Parent then
                    part.CanTouch = true
                    part.CanQuery = true
                end
            end)
        end
        disabledObjects = {}
    end
end, "Disables chandeliers and animated obstacles that can kill you")

-- No Acceleration
local noAccelEnabled = false
local noAccelLoop = nil
local originalHrpProps = nil

UniversalTab:Toggle("No Acceleration", false, function(enabled)
    noAccelEnabled = enabled

    if enabled then
        pcall(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                originalHrpProps = hrp.CustomPhysicalProperties
                hrp.CustomPhysicalProperties = PhysicalProperties.new(100, 0.7, 0, 1, 1)
            end
        end)

        noAccelLoop = task.spawn(function()
            while noAccelEnabled do
                task.wait(0.5)
                pcall(function()
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local Character = LocalPlayer and LocalPlayer.Character
                    if Character then
                        local hrp = Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local cpp = hrp.CustomPhysicalProperties
                            if not cpp or cpp.Density ~= 100 then
                                hrp.CustomPhysicalProperties = PhysicalProperties.new(100, 0.7, 0, 1, 1)
                            end
                        end
                    end
                end)
            end
        end)
    else
        if noAccelLoop then
            task.cancel(noAccelLoop)
            noAccelLoop = nil
        end

        pcall(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer and LocalPlayer.Character
            if Character then
                local hrp = Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CustomPhysicalProperties = originalHrpProps
                end
            end
        end)

        originalHrpProps = nil
    end
end, "Removes movement acceleration for instant max speed")

-- Proximity Reach
local proximityReach = 0

UniversalTab:Slider("Proximity Prompt Reach", 0, 12, 0, function(value)
    proximityReach = value
end, "Increases the range at which you can interact with doors, levers, etc.")

-- Auto Proximity
local autoProxiEnabled = false
local autoProxiLoop
local UserInputService = game:GetService("UserInputService")
local isRKeyHeld = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R and not gameProcessed then
        isRKeyHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R then
        isRKeyHeld = false
    end
end)

UniversalTab:Toggle("Auto Proxi", false, function(enabled)
    autoProxiEnabled = enabled
    
    if enabled then
        autoProxiLoop = task.spawn(function()
            while autoProxiEnabled do
                task.wait(0.01)
                pcall(function()
                    if not isRKeyHeld then
                        return
                    end
                    
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local Character = LocalPlayer and LocalPlayer.Character
                    
                    if not Character then return end
                    
                    local hrp = Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    local currentRooms = workspace:FindFirstChild("CurrentRooms")
                    if not currentRooms then return end
                    
                    for _, descendant in pairs(currentRooms:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                            local promptParent = descendant.Parent
                            
                            local targetPos
                            if promptParent:IsA("BasePart") then
                                targetPos = promptParent.Position
                            elseif promptParent:IsA("Model") then
                                local primaryPart = promptParent.PrimaryPart or promptParent:FindFirstChildWhichIsA("BasePart")
                                if primaryPart then
                                    targetPos = primaryPart.Position
                                end
                            end
                            
                            if targetPos then
                                local distance = (hrp.Position - targetPos).Magnitude
                                
                                local effectiveRange = proximityReach > 0 and proximityReach or descendant.MaxActivationDistance
                                
                                if distance <= effectiveRange then
                                    local actionText = descendant.ActionText or ""
                                    
                                    if actionText:lower():find("close") then
                                        continue
                                    end

                                    if descendant.Name == "UnlockPrompt" or actionText:lower():find("unlock") then
                                        local originalHoldDuration = descendant.HoldDuration
                                        descendant.HoldDuration = 0
                                        fireproximityprompt(descendant)
                                        task.wait(0.1)
                                        descendant.HoldDuration = originalHoldDuration
                                    else
                                        fireproximityprompt(descendant)
                                    end
                                    
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        if autoProxiLoop then
            task.cancel(autoProxiLoop)
            autoProxiLoop = nil
        end
    end
end, "Automatically interacts with nearby prompts when holding R key")

-- AntiSpeed Bypass (Hotel)
local antiSpeedEnabled = false
local antiSpeedLoop
local clonedCollision

HotelTab:Toggle("AntiSpeed Bypass", false, function(enabled)
    antiSpeedEnabled = enabled
    
    if enabled then
        pcall(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local CollisionPart = Character:WaitForChild("CollisionPart")
            
            clonedCollision = CollisionPart:Clone()
            clonedCollision.Name = "_CollisionClone"
            clonedCollision.Massless = true
            clonedCollision.Parent = Character
            clonedCollision.CanCollide = false
            clonedCollision.CanQuery = false
            clonedCollision.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
            
            antiSpeedLoop = task.spawn(function()
                while antiSpeedEnabled do
                    task.wait(0.23)
                    if clonedCollision then
                        clonedCollision.Massless = false
                        task.wait(0.23)
                        local root = Character:FindFirstChild("HumanoidRootPart")
                        if root and root.Anchored then
                            clonedCollision.Massless = true
                            task.wait(1)
                        end
                        clonedCollision.Massless = true
                    end
                end
            end)
        end)
    else
        antiSpeedEnabled = false
        if antiSpeedLoop then
            task.cancel(antiSpeedLoop)
            antiSpeedLoop = nil
        end
        if clonedCollision then
            clonedCollision:Destroy()
            clonedCollision = nil
        end
    end
end, "Required for Speed on Hotel floor - bypasses anticheat")

-- Speed (Hotel)
local speedEnabled = false
local originalWalkSpeed = 16
local speedValue = 16
local speedLoop

HotelTab:Toggle("Speed", false, function(enabled)
    if enabled and not antiSpeedEnabled then
        Window:Notify({
            Text = "Please enable AntiSpeed Bypass first!",
            Duration = 4,
            Type = "Warning"
        })
        speedEnabled = false
        return
    end
    
    speedEnabled = enabled
    
    if enabled then
        pcall(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character
            
            if Character then
                local Humanoid = Character:FindFirstChild("Humanoid")
                if Humanoid then
                    originalWalkSpeed = Humanoid.WalkSpeed
                end
            end
        end)
        
        speedLoop = task.spawn(function()
            while speedEnabled do
                task.wait(0.1)
                pcall(function()
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local Character = LocalPlayer.Character
                    
                    if Character then
                        local Humanoid = Character:FindFirstChild("Humanoid")
                        if Humanoid then
                            Humanoid.WalkSpeed = speedValue
                        end
                    end
                end)
            end
        end)
    else
        if speedLoop then
            task.cancel(speedLoop)
            speedLoop = nil
        end
        
        pcall(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character
            
            if Character then
                local Humanoid = Character:FindFirstChild("Humanoid")
                if Humanoid then
                    Humanoid.WalkSpeed = originalWalkSpeed
                end
            end
        end)
    end
end, "Increase your walk speed - requires AntiSpeed Bypass!")

HotelTab:Slider("Speed Value", 2, 250, 16, function(value)
    speedValue = value
end, "Set your desired walk speed (default: 16)")

-- Mines Bypass
local bypassEnabled = false
local bypassLoop
local ladderESP = {}

if currentFloor == "Mines" or currentFloor == "Unknown" then
    MinesTab:Toggle("Anticheat Bypass", false, function(enabled)
        bypassEnabled = enabled
        
        if enabled then
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                pcall(function()
                    local ladder = room:FindFirstChild("Ladder", true)
                    if ladder then
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = Color3.fromRGB(0, 100, 255)
                        highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = ladder
                        table.insert(ladderESP, highlight)
                    end
                end)
            end
            
            bypassLoop = task.spawn(function()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                
                while bypassEnabled do
                    task.wait(0.1)
                    pcall(function()
                        local Character = LocalPlayer.Character
                        if Character then
                            local climbingAttr = Character:GetAttribute("Climbing")
                            if climbingAttr == true then
                                Window:Notify({
                                    Text = "[Bypass]: Please wait 2 seconds and don't move",
                                    Duration = 2,
                                    Type = "Warning"
                                })
                                task.wait(0.5)
                                Character:SetAttribute("Climbing", false)
                            end
                        end
                    end)
                end
            end)
        else
            if bypassLoop then
                task.cancel(bypassLoop)
                bypassLoop = nil
            end
            
            for _, highlight in pairs(ladderESP) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            ladderESP = {}
        end
    end, "Prevents ladder detection on Mines floor - highlights all ladders in blue")
    
    MinesTab:Label("⚠️ Speed is disabled on Mines floor for safety")
else
    MinesTab:Label("⚠️ Mines floor not detected")
end

local VisualCategory = Window:CreateCategory("Visual", "👁️")
local ESPTab = VisualCategory:CreateTab("ESP", "📍")
local DisplayTab = VisualCategory:CreateTab("Display", "🎨")

local espEnabled = {
    Door = false,
    Objective = false,
    Entity = false,
    Snare = false
}
local espHighlights = {}
local espUpdateLoop
local espTrackedObjects = {}

local function clearESP(espType)
    if espHighlights[espType] then
        for _, highlight in pairs(espHighlights[espType]) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        espHighlights[espType] = {}
    end
    
    if espTrackedObjects[espType] then
        espTrackedObjects[espType] = {}
    end
end

local function isObjectTracked(espType, object)
    if not espTrackedObjects[espType] then
        espTrackedObjects[espType] = {}
    end
    
    for _, tracked in pairs(espTrackedObjects[espType]) do
        if tracked == object then
            return true
        end
    end
    return false
end

local function addTrackedObject(espType, object)
    if not espTrackedObjects[espType] then
        espTrackedObjects[espType] = {}
    end
    table.insert(espTrackedObjects[espType], object)
end

-- Create Door ESP
local function createDoorESP()
    if not espHighlights.Door then
        espHighlights.Door = {}
    end
    
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        pcall(function()
            local door = room:FindFirstChild("Door")
            if door and door:IsA("Model") and not isObjectTracked("Door", door) then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = door
                table.insert(espHighlights.Door, highlight)
                addTrackedObject("Door", door)
            end
        end)
    end
end

-- Create Objective ESP
local function createObjectiveESP()
    if not espHighlights.Objective then
        espHighlights.Objective = {}
    end
    
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        pcall(function()
            -- KeyObtain
            local keyObtain = room:FindFirstChild("KeyObtain", true)
            if keyObtain and not isObjectTracked("Objective", keyObtain) then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = keyObtain
                table.insert(espHighlights.Objective, highlight)
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ObjectiveESP"
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.Parent = keyObtain
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "Key"
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.GothamBold
                textLabel.Parent = billboard
                
                table.insert(espHighlights.Objective, billboard)
                addTrackedObject("Objective", keyObtain)
            end
            
            -- FuseHolder
            local fuseHolder = room:FindFirstChild("FuseHolder", true)
            if fuseHolder and not isObjectTracked("Objective", fuseHolder) then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = fuseHolder
                table.insert(espHighlights.Objective, highlight)
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ObjectiveESP"
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.Parent = fuseHolder
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "Fuse"
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.GothamBold
                textLabel.Parent = billboard
                
                table.insert(espHighlights.Objective, billboard)
                addTrackedObject("Objective", fuseHolder)
            end
            
            -- LiveHintBook
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, bookshelf in pairs(assets:GetChildren()) do
                    if bookshelf.Name:match("Bookshelves") then
                        local liveHintBook = bookshelf:FindFirstChild("LiveHintBook", true)
                        if liveHintBook and not isObjectTracked("Objective", liveHintBook) then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(255, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = liveHintBook
                            table.insert(espHighlights.Objective, highlight)
                            
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "ObjectiveESP"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 2, 0)
                            billboard.Parent = liveHintBook
                            
                            local textLabel = Instance.new("TextLabel")
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Text = "Book"
                            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                            textLabel.TextStrokeTransparency = 0
                            textLabel.TextScaled = true
                            textLabel.Font = Enum.Font.GothamBold
                            textLabel.Parent = billboard
                            
                            table.insert(espHighlights.Objective, billboard)
                            addTrackedObject("Objective", liveHintBook)
                        end
                    end
                end
                
                -- LeverForGate
                local lever = assets:FindFirstChild("LeverForGate")
                if lever and not isObjectTracked("Objective", lever) then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = lever
                    table.insert(espHighlights.Objective, highlight)
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ObjectiveESP"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Parent = lever
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "Lever"
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Parent = billboard
                    
                    table.insert(espHighlights.Objective, billboard)
                    addTrackedObject("Objective", lever)
                end
                
                -- LiveBreakerPolePickup
                local breakerPole = assets:FindFirstChild("LiveBreakerPolePickup", true)
                if breakerPole and not isObjectTracked("Objective", breakerPole) then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = breakerPole
                    table.insert(espHighlights.Objective, highlight)
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ObjectiveESP"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Parent = breakerPole
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "Breaker"
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Parent = billboard
                    
                    table.insert(espHighlights.Objective, billboard)
                    addTrackedObject("Objective", breakerPole)
                end
            end
            
            -- TimerLever
            local timerLever = room:FindFirstChild("TimerLever")
            if timerLever and not isObjectTracked("Objective", timerLever) then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = timerLever
                table.insert(espHighlights.Objective, highlight)
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ObjectiveESP"
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.Parent = timerLever
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "Timer Lever"
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.GothamBold
                textLabel.Parent = billboard
                
                table.insert(espHighlights.Objective, billboard)
                addTrackedObject("Objective", timerLever)
            end
        end)
    end
end

-- Create Snare ESP
local function createSnareESP()
    if not espHighlights.Entity then
        espHighlights.Entity = {}
    end
    
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        pcall(function()
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, snare in pairs(assets:GetChildren()) do
                    if snare.Name == "Snare" and not isObjectTracked("Entity", snare) then
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = snare
                        table.insert(espHighlights.Entity, highlight)
                        
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "EntityESP"
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.Parent = snare
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = "SNARE"
                        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.Parent = billboard
                        
                        table.insert(espHighlights.Entity, billboard)
                        addTrackedObject("Entity", snare)
                    end
                end
            end
        end)
    end
end

-- Create Entity ESP
local function createEntityESP()
    if not espHighlights.Entity then
        espHighlights.Entity = {}
    end
    
    -- Rush
    pcall(function()
        local rushMoving = workspace:FindFirstChild("RushMoving")
        if rushMoving and rushMoving:IsA("Model") and not isObjectTracked("Entity", rushMoving) then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = rushMoving
            table.insert(espHighlights.Entity, highlight)
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "EntityESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = rushMoving
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "RUSH"
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
            
            table.insert(espHighlights.Entity, billboard)
            addTrackedObject("Entity", rushMoving)
        end
    end)
    
    -- Ambush
    pcall(function()
        local ambushMoving = workspace:FindFirstChild("AmbushMoving")
        if ambushMoving and ambushMoving:IsA("Model") and not isObjectTracked("Entity", ambushMoving) then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 100, 0)
            highlight.OutlineColor = Color3.fromRGB(200, 80, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = ambushMoving
            table.insert(espHighlights.Entity, highlight)
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "EntityESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = ambushMoving
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "AMBUSH"
            textLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
            
            table.insert(espHighlights.Entity, billboard)
            addTrackedObject("Entity", ambushMoving)
        end
    end)
    
    -- Eyes
    pcall(function()
        local eyes = workspace:FindFirstChild("Eyes")
        if eyes and eyes:IsA("Model") and not isObjectTracked("Entity", eyes) then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(150, 0, 255)
            highlight.OutlineColor = Color3.fromRGB(120, 0, 200)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = eyes
            table.insert(espHighlights.Entity, highlight)
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "EntityESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = eyes
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "EYES"
            textLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
            
            table.insert(espHighlights.Entity, billboard)
            addTrackedObject("Entity", eyes)
        end
    end)
    
    -- Figure
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        pcall(function()
            local figureSetup = room:FindFirstChild("FigureSetup")
            if figureSetup then
                local figureRig = figureSetup:FindFirstChild("FigureRig")
                if figureRig and not isObjectTracked("Entity", figureRig) then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = figureRig
                    table.insert(espHighlights.Entity, highlight)
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "EntityESP"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.Parent = figureRig
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "FIGURE"
                    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Parent = billboard
                    
                    table.insert(espHighlights.Entity, billboard)
                    addTrackedObject("Entity", figureRig)
                end
            end
        end)
    end
end

-- ESP Update Loop
local function startESPUpdateLoop()
    if espUpdateLoop then
        task.cancel(espUpdateLoop)
    end
    
    espUpdateLoop = task.spawn(function()
        while espEnabled.Door or espEnabled.Objective or espEnabled.Entity do
            task.wait(1)
            
            if espEnabled.Door then
                createDoorESP()
            end
            
            if espEnabled.Objective then
                createObjectiveESP()
            end
            
            if espEnabled.Entity then
                createEntityESP()
                createSnareESP()
            end
        end
    end)
end

-- ESP Dropdown
ESPTab:Dropdown("ESP Types", {"Door", "Objective", "Entity", "Snare"}, function(selected)
    -- Door ESP
    if selected["Door"] and not espEnabled.Door then
        espEnabled.Door = true
        createDoorESP()
        startESPUpdateLoop()
    elseif not selected["Door"] and espEnabled.Door then
        espEnabled.Door = false
        clearESP("Door")
    end
    
    -- Objective ESP
    if selected["Objective"] and not espEnabled.Objective then
        espEnabled.Objective = true
        createObjectiveESP()
        startESPUpdateLoop()
    elseif not selected["Objective"] and espEnabled.Objective then
        espEnabled.Objective = false
        clearESP("Objective")
    end
    
    -- Entity ESP
    if selected["Entity"] and not espEnabled.Entity then
        espEnabled.Entity = true
        createEntityESP()
        startESPUpdateLoop()
    elseif not selected["Entity"] and espEnabled.Entity then
        espEnabled.Entity = false
        clearESP("Entity")
    end
    
    -- Snare ESP
    if selected["Snare"] and not espEnabled.Snare then
        espEnabled.Snare = true
        createSnareESP()
        startESPUpdateLoop()
    elseif not selected["Snare"] and espEnabled.Snare then
        espEnabled.Snare = false
        clearESP("Snare")
    end
    
    -- Stop update loop if all disabled
    if not espEnabled.Door and not espEnabled.Objective and not espEnabled.Entity and not espEnabled.Snare then
        if espUpdateLoop then
            task.cancel(espUpdateLoop)
            espUpdateLoop = nil
        end
    end
end, "Select which objects to highlight")

ESPTab:Label("🟢 Door ESP - Highlights all doors")
ESPTab:Label("🟡 Objective ESP - Keys, fuses, books, levers")
ESPTab:Label("🔴 Entity ESP - Rush, Ambush, Eyes, Figure, Snare")

local entityNotifierEnabled = false
local notifiedEntities = {}

ESPTab:Toggle("Entity Notifier", false, function(enabled)
    entityNotifierEnabled = enabled
    if not enabled then
        notifiedEntities = {}
    end
end, "Get notifications when entities spawn")

task.spawn(function()
    while true do
        task.wait(0.5)
        if entityNotifierEnabled then
            pcall(function()
                local rushMoving = workspace:FindFirstChild("RushMoving")
                if rushMoving and not notifiedEntities["RushMoving"] then
                    notifiedEntities["RushMoving"] = true
                    Window:Notify({
                        Text = "Rush is coming!",
                        Duration = 5,
                        Type = "Error"
                    })
                elseif not rushMoving and notifiedEntities["RushMoving"] then
                    notifiedEntities["RushMoving"] = nil
                end
                
                local ambushMoving = workspace:FindFirstChild("AmbushMoving")
                if ambushMoving and not notifiedEntities["AmbushMoving"] then
                    notifiedEntities["AmbushMoving"] = true
                    Window:Notify({
                        Text = "Ambush is coming!",
                        Duration = 5,
                        Type = "Error"
                    })
                elseif not ambushMoving and notifiedEntities["AmbushMoving"] then
                    notifiedEntities["AmbushMoving"] = nil
                end
                
                local eyes = workspace:FindFirstChild("Eyes")
                if eyes and not notifiedEntities["Eyes"] then
                    notifiedEntities["Eyes"] = true
                    Window:Notify({
                        Text = "Eyes has appeared!",
                        Duration = 5,
                        Type = "Error"
                    })
                elseif not eyes and notifiedEntities["Eyes"] then
                    notifiedEntities["Eyes"] = nil
                end
            end)
        end
    end
end)

local fullbrightEnabled = false
local originalLighting = {}
local lightingConnection

DisplayTab:Toggle("Fullbright", false, function(enabled)
    fullbrightEnabled = enabled
    
    if enabled then
        local Lighting = game:GetService("Lighting")
        originalLighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient
        }
        
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        
        lightingConnection = Lighting.Changed:Connect(function(property)
            if fullbrightEnabled then
                if property == "Brightness" and Lighting.Brightness ~= 2 then
                    Lighting.Brightness = 2
                elseif property == "ClockTime" and Lighting.ClockTime ~= 14 then
                    Lighting.ClockTime = 14
                elseif property == "FogEnd" and Lighting.FogEnd ~= 100000 then
                    Lighting.FogEnd = 100000
                elseif property == "GlobalShadows" and Lighting.GlobalShadows ~= false then
                    Lighting.GlobalShadows = false
                elseif property == "Ambient" and Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                end
            end
        end)
    else
        if lightingConnection then
            lightingConnection:Disconnect()
            lightingConnection = nil
        end
        
        local Lighting = game:GetService("Lighting")
        for property, value in pairs(originalLighting) do
            Lighting[property] = value
        end
    end
end, "See clearly in dark areas - removes fog and shadows")

local RunService = game:GetService("RunService")
local desiredFOV = 70
local fovConnection

fovConnection = RunService.RenderStepped:Connect(function()
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera and camera.FieldOfView ~= desiredFOV then
            camera.FieldOfView = desiredFOV
        end
    end)
end)

DisplayTab:Slider("FOV", 70, 120, 70, function(value)
    desiredFOV = value
end, "Adjust your field of view (default: 70)")

local BetaCat = Window:CreateCategory("BETA", "⚠️")

BetaCat:Button("Bypass A-90", function()
    while wait(0.23) do
        game.ReplicatedStorage.RemotesFolder.A90:FireServer("didnt")
    end
end, "Bypass's A-90 killing/Damaging you inside the rooms (works with modifier's on)")

local SettingsCategory = Window:CreateCategory("Settings", "⚙️")

local function destroyScript()
    if lightingConnection then
        lightingConnection:Disconnect()
    end
    if fovConnection then
        fovConnection:Disconnect()
    end
    
    if spoofCrouchLoop then
        task.cancel(spoofCrouchLoop)
    end
    if antiSpeedLoop then
        task.cancel(antiSpeedLoop)
    end
    if bypassLoop then
        task.cancel(bypassLoop)
    end
    if speedLoop then
        task.cancel(speedLoop)
    end
    if noAccelLoop then
        task.cancel(noAccelLoop)
    end
    if autoProxiLoop then
        task.cancel(autoProxiLoop)
    end
    if espUpdateLoop then
        task.cancel(espUpdateLoop)
    end
    
    clearESP("Door")
    clearESP("Objective")
    clearESP("Entity")
    
    pcall(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer and LocalPlayer.Character
        
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = originalWalkSpeed
            end
            
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CustomPhysicalProperties = originalHrpProps
            end
            
            if clonedCollision then
                clonedCollision:Destroy()
            end
            
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
    
    if fullbrightEnabled then
        local Lighting = game:GetService("Lighting")
        for property, value in pairs(originalLighting) do
            Lighting[property] = value
        end
    end
    
    if screechDisabled and screechOriginalParent then
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local screech = ReplicatedStorage.Entities:FindFirstChild("Screech")
            if screech then
                screech.Parent = screechOriginalParent
            end
        end)
    end
    
    Window:Notify({
        Text = "Script destroyed! All features disabled.",
        Duration = 3,
        Type = "Warning"
    })
    
    task.wait(0.5)
    if Window.Destroy then
        Window:Destroy()
    end
end

SettingsCategory:Button("Destroy Script", function()
    destroyScript()
end, "⚠️ Completely removes the script and restores all game settings")

SettingsCategory:Button("Reset All Settings", function()
    spoofCrouchEnabled = false
    screechDisabled = false
    antiSpeedEnabled = false
    bypassEnabled = false
    speedEnabled = false
    noAccelEnabled = false
    autoProxiEnabled = false
    fullbrightEnabled = false
    entityNotifierEnabled = false
    
    speedValue = 16
    proximityReach = 0
    desiredFOV = 70
    
    Window:Notify({
        Text = "All settings have been reset!",
        Duration = 2,
        Type = "Success"
    })
end, "Reset all toggles and values to default")

SettingsCategory:Button("Hide UI", function()
    Window:Hide()
end, "Hide the UI - press RightShift to show again")

SettingsCategory:Label("═══════════════════")
SettingsCategory:Label("🎮 RLoader Doors v1.0")
SettingsCategory:Label("📍 Current Floor: " .. currentFloor)
SettingsCategory:Label("⌨️ Press RightShift to toggle UI")
SettingsCategory:Label("═══════════════════")

wait(0.2)
Window:Show()

Window:Notify({
    Text = "Rloader Loaded (Use in Doors game avoid the risk!!)",
    Duration = 5,
    Type = "Success"
})