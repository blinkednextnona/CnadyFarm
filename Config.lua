-- ============================================
-- CONFIG.lua - Services, State, Settings, Save/Load
-- ============================================
local Config = {}

-- SERVICES (shared across all modules)
Config.Services = {
    Players            = game:GetService("Players"),
    PathfindingService = game:GetService("PathfindingService"),
    RunService         = game:GetService("RunService"),
    CoreGui            = game:GetService("CoreGui"),
    Workspace          = game:GetService("Workspace"),
    UserInputService   = game:GetService("UserInputService"),
    HttpService        = game:GetService("HttpService"),
    VirtualUser        = game:GetService("VirtualUser"),
    TeleportService    = game:GetService("TeleportService"),
    ReplicatedStorage  = game:GetService("ReplicatedStorage"),
}

-- PLAYER refs (updated on respawn)
local player = Config.Services.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

Config.Player = player
Config.Character = character
Config.Humanoid = character:WaitForChild("Humanoid")
Config.RootPart = character:WaitForChild("HumanoidRootPart")

-- CACHE
Config.SafezoneCache = {}
Config.LastSafezoneUpdate = 0
Config.CandyFolder = Config.Services.Workspace:WaitForChild("CandyCanes", 10)

-- PRE-FETCH REMOTES
Config.OpenCaseRemote = nil
task.spawn(function()
    local remotes = Config.Services.ReplicatedStorage:WaitForChild("Remotes", 5)
    if remotes then
        Config.OpenCaseRemote = remotes:WaitForChild("OpenCase", 5)
    end
end)

-- FARM STATE
Config.Farm = {
    Enabled = false,
    Status = "Idle",
    LockedTarget = nil,
    IsGlobalTarget = false,
    Waypoints = {},
    CurrentWaypointIndex = 1,
    LastPosition = Vector3.zero,
    StuckTimer = 0,
    MoveTimeout = 0,
    IsPathfinding = false,
    CurrentMode = "Closest",
    Blacklist = {},
    PathGenerated = false,
    LastFleeTP = 0,
    StartTime = 0,
    LastCleanup = 0,
    TotalCollected = 0,
    LastStatUpdate = 0,
    LastZoneCheck = 0,
    CachedThreat = { Dist = math.huge, Pos = nil, Armed = false },
}

-- ZONE STATE
Config.Zone = {
    Pos1 = nil,
    Pos2 = nil,
    Active = false,
}

-- SETTINGS
Config.Settings = {
    Movement = {
        WalkSpeed = 21,
        DirectMoveDistance = 15,
        CheatTP = false,
        TPProtection = false,
        AntiAFK = true,
        StuckThreshold = 2,
    },
    Farming = {
        CollectDistance = 2,
        SafetyRadius = 25,
        ResumeRadius = 30,
        FleeMode = "Armed",
        LagFixer = false,
        AntiAdmin = false,
        AutoStartFarm = false,
    },
    Visuals = {
        PathColor = Color3.fromRGB(255, 105, 180),
        ColorMode = "Static",
        CustomColors = {},
        ColorSpeed = 1,
        ColorFade = true,
    },
    Webhook = {
        Enabled = false,
        URL = "",
        Interval = 1,
        Unit = "Minutes",
        LastTime = 0,
    },
    Extra = {
        LoopBuyCase26 = false,
    },
}

-- MODULE REGISTRY (filled by Loader)
Config.Modules = {}

-- FILE NAME FOR SAVE/LOAD
local FileName = "CandyZone_V18_Config.json"
local HttpService = Config.Services.HttpService

function Config.SaveSettings()
    if not writefile then return end
    local data = {
        Movement = Config.Settings.Movement,
        Farming  = Config.Settings.Farming,
        Visuals  = {
            ColorMode    = Config.Settings.Visuals.ColorMode,
            ColorSpeed   = Config.Settings.Visuals.ColorSpeed,
            ColorFade    = Config.Settings.Visuals.ColorFade,
            PathColor    = {
                r = Config.Settings.Visuals.PathColor.R,
                g = Config.Settings.Visuals.PathColor.G,
                b = Config.Settings.Visuals.PathColor.B,
            },
            CustomColors = {},
        },
        Webhook = Config.Settings.Webhook,
        Extra   = Config.Settings.Extra,
    }
    for _, col in ipairs(Config.Settings.Visuals.CustomColors) do
        table.insert(data.Visuals.CustomColors, { r = col.R, g = col.G, b = col.B })
    end
    pcall(function() writefile(FileName, HttpService:JSONEncode(data)) end)
end

function Config.LoadSettings()
    if not readfile or not isfile or not isfile(FileName) then return end
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(FileName))
    end)
    if not success or not result then return end

    if result.Movement then
        for k, v in pairs(result.Movement) do Config.Settings.Movement[k] = v end
    end
    if result.Farming then
        for k, v in pairs(result.Farming) do Config.Settings.Farming[k] = v end
    end
    if result.Webhook then
        for k, v in pairs(result.Webhook) do Config.Settings.Webhook[k] = v end
    end
    if result.Extra then
        for k, v in pairs(result.Extra) do Config.Settings.Extra[k] = v end
    end
    if result.Visuals then
        Config.Settings.Visuals.ColorMode  = result.Visuals.ColorMode or "Static"
        Config.Settings.Visuals.ColorSpeed = result.Visuals.ColorSpeed or 1
        Config.Settings.Visuals.ColorFade  = (result.Visuals.ColorFade ~= nil) and result.Visuals.ColorFade or true
        if result.Visuals.PathColor then
            Config.Settings.Visuals.PathColor = Color3.new(
                result.Visuals.PathColor.r,
                result.Visuals.PathColor.g,
                result.Visuals.PathColor.b
            )
        end
        if result.Visuals.CustomColors then
            Config.Settings.Visuals.CustomColors = {}
            for _, c in ipairs(result.Visuals.CustomColors) do
                table.insert(Config.Settings.Visuals.CustomColors, Color3.new(c.r, c.g, c.b))
            end
        end
    end
end

-- CHARACTER UPDATE HELPER
function Config.UpdateCharacter(newChar)
    if not newChar then return end
    Config.Character = newChar
    Config.Humanoid  = newChar:WaitForChild("Humanoid", 5)
    Config.RootPart  = newChar:WaitForChild("HumanoidRootPart", 5)
    if not Config.Humanoid or not Config.RootPart then return end

    Config.Farm.Status = "Idle"
    Config.Farm.LockedTarget = nil
    Config.Farm.Waypoints = {}
    Config.Farm.PathGenerated = false
    Config.Farm.StuckTimer = 0
    Config.Farm.MoveTimeout = 0

    if Config.Modules.Visuals then
        Config.Modules.Visuals.HideAllTrajectoryLines()
    end

    Config.Humanoid.Died:Connect(function()
        Config.Farm.LockedTarget = nil
        Config.Farm.PathGenerated = false
        if Config.Modules.Visuals then
            Config.Modules.Visuals.HideAllTrajectoryLines()
        end
    end)
end

return Config
