-- // CONFIGURATION //
local FOLDER_NAME = "AssetLogs"
local FILE_NAME = "Time_Synced_Log_" .. game.PlaceId .. ".txt"
local KEYBIND = Enum.KeyCode.G -- Press to disconnect

-- // SERVICES //
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- // FILE SETUP //
if not isfolder(FOLDER_NAME) then
    makefolder(FOLDER_NAME)
end

local filePath = FOLDER_NAME .. "/" .. FILE_NAME

-- Check if file exists; if not, create header. If yes, add a session separator.
if not isfile(filePath) then
    writefile(filePath, "TIME SYNCED ASSET LOG\n======================================\n")
else
    appendfile(filePath, "\n\n--- NEW SESSION STARTED: " .. os.date("%X") .. " ---\n")
end

-- // UI SETUP //
local ScreenGui = Instance.new("ScreenGui")
local StatusLabel = Instance.new("TextLabel")

if gethui then ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = CoreGui
else ScreenGui.Parent = CoreGui end

StatusLabel.Parent = ScreenGui
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusLabel.BackgroundTransparency = 0.5
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.Size = UDim2.new(0, 400, 0, 30)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
StatusLabel.TextSize = 14
StatusLabel.Text = "Logging duplicates & time pairs..."
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- // CACHE //
-- We cache NAMES only to avoid HTTP 429 errors (Too Many Requests). 
-- We still log every single event occurrence.
local nameCache = {} 

-- // FUNCTIONS //

local function extractId(str)
    if not str then return nil end
    return string.match(str, "%d+")
end

local function getNameSafe(id)
    if nameCache[id] then return nameCache[id] end
    
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(tonumber(id))
    end)
    
    if success and info then
        nameCache[id] = info.Name
        return info.Name
    else
        return "Unknown"
    end
end

local function logEvent(id, assetType)
    -- Run in background so it doesn't block the game
    task.spawn(function()
        local realName = getNameSafe(id)
        local timestamp = os.date("%H:%M:%S") -- Hour:Minute:Second
        
        -- FORMAT: [TIME] [TYPE] Name (ID)
        -- This format ensures paired events appear together
        local logLine = string.format("[%s] [%s] %s | ID: %s\n", timestamp, assetType, realName, id)
        
        appendfile(filePath, logLine)
        StatusLabel.Text = "Logged: " .. realName .. " (" .. assetType .. ")"
    end)
end

-- // LISTENERS //

local function processId(rawId, typeLabel)
    local id = extractId(rawId)
    if id then
        -- Removed the "seenIDs" check so duplicates are ALLOWED
        logEvent(id, typeLabel)
    end
end

-- 1. Monitor Humanoids for Animations
local function monitorHumanoid(humanoid)
    humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation then
            processId(track.Animation.AnimationId, "ANIM")
        end
    end)
end

-- 2. Monitor New Objects
local function onDescendantAdded(obj)
    if obj:IsA("Sound") then
        task.delay(0.1, function() -- Slight delay to let ID load
            processId(obj.SoundId, "SOUND")
        end)
    elseif obj:IsA("Humanoid") then
        monitorHumanoid(obj)
    end
end

-- // INITIALIZATION //

-- Hook existing humanoids
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") then monitorHumanoid(v) end
end

-- Hook listeners
workspace.DescendantAdded:Connect(onDescendantAdded)
game:GetService("ReplicatedStorage").DescendantAdded:Connect(onDescendantAdded)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then monitorHumanoid(hum) end
    end)
end)

-- // EXIT //
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == KEYBIND then
        Players.LocalPlayer:Kick("Logging Stopped. Check " .. FOLDER_NAME)
    end
end)

print("Time-Synced Logger Started")