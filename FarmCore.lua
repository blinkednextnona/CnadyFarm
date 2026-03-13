-- ============================================
-- FARMCORE.lua - Main Loop, Targeting, Fleeing
-- Fixed: no duplicate functions, cleaner logic
-- Improved: smoother waypoint following, less stutter
-- ============================================
local FarmCore = {}
local Config = nil

local LastSearchTime = 0
local LastAdminCheck = 0

-- ==================
-- HELPER FUNCTIONS
-- ==================
local function updateSafezoneCache()
    if tick() - Config.LastSafezoneUpdate < 60 then return end
    Config.LastSafezoneUpdate = tick()
    Config.SafezoneCache = {}
    for _, item in pairs(Config.Services.Workspace:GetDescendants()) do
        if item.Name == "Safezone" and item:IsA("BasePart") then
            table.insert(Config.SafezoneCache, item)
        end
    end
end

local function cleanupBlacklist()
    if tick() - Config.Farm.LastCleanup < 5 then return end
    Config.Farm.LastCleanup = tick()
    for part, expiry in pairs(Config.Farm.Blacklist) do
        if tick() > expiry or not part.Parent then
            Config.Farm.Blacklist[part] = nil
        end
    end
end

local function isInsideSafezone(char)
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    for _, zonePart in pairs(Config.SafezoneCache) do
        local dist = (zonePart.Position - root.Position).Magnitude
        if dist < (math.max(zonePart.Size.X, zonePart.Size.Z) * 0.6) then
            return true
        end
    end
    return false
end

local function getBestEscapeSafezone(threatPos)
    local rootPart = Config.RootPart
    local bestZone, bestScore = nil, -math.huge
    for _, zonePart in pairs(Config.SafezoneCache) do
        local score = (zonePart.Position - threatPos).Magnitude - ((zonePart.Position - rootPart.Position).Magnitude * 1.5)
        if score > bestScore then
            bestScore = score
            bestZone = zonePart
        end
    end
    return bestZone
end

local function getThreatInfo()
    local rootPart = Config.RootPart
    local closestDist, closestThreatPos, isArmed = math.huge, nil, false
    for _, other in pairs(Config.Services.Players:GetPlayers()) do
        if other ~= Config.Player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") and not isInsideSafezone(other.Character) then
            local dist = (other.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if dist < Config.Settings.Farming.ResumeRadius then
                local hasTool = other.Character:FindFirstChildWhichIsA("Tool") ~= nil
                if hasTool then
                    if not isArmed or dist < closestDist then
                        closestDist = dist
                        closestThreatPos = other.Character.HumanoidRootPart.Position
                        isArmed = true
                    end
                elseif not isArmed and dist < closestDist then
                    closestDist = dist
                    closestThreatPos = other.Character.HumanoidRootPart.Position
                end
            end
        end
    end
    return closestDist, closestThreatPos, isArmed
end

local function getCandyValue(heartPart)
    local lbl = heartPart:FindFirstChild("Heart")
        and heartPart.Heart:FindFirstChild("Attachment")
        and heartPart.Heart.Attachment:FindFirstChild("BillboardGui")
        and heartPart.Heart.Attachment.BillboardGui:FindFirstChild("TextLabel")
    return lbl and tonumber(lbl.Text) or 0
end

local function checkSight(targetPos)
    local rootPart = Config.RootPart
    local character = Config.Character
    local Visuals = Config.Modules.Visuals
    local origin = rootPart.Position
    local rightVec = rootPart.CFrame.RightVector

    local filterList = { character }
    if Visuals then
        table.insert(filterList, Visuals.ZoneFolder)
        table.insert(filterList, Visuals.TrajectoryFolder)
    end
    if Config.CandyFolder then
        table.insert(filterList, Config.CandyFolder)
    end

    local p = RaycastParams.new()
    p.FilterDescendantsInstances = filterList
    p.FilterType = Enum.RaycastFilterType.Exclude

    if Config.Services.Workspace:Raycast(origin, targetPos - origin, p) then return false end
    if Config.Services.Workspace:Raycast(origin - (rightVec * 1.5), targetPos - (origin - (rightVec * 1.5)), p) then return false end
    if Config.Services.Workspace:Raycast(origin + (rightVec * 1.5), targetPos - (origin + (rightVec * 1.5)), p) then return false end
    return true
end

local function findBestTarget()
    local folder = Config.CandyFolder or Config.Services.Workspace:FindFirstChild("CandyCanes")
    if not folder then return nil, false end
    local rootPart = Config.RootPart
    local Zone = Config.Zone
    local Farm = Config.Farm
    local candidates = {}

    for _, child in pairs(folder:GetChildren()) do
        local heart = child.Name == "CandyCane" and child:FindFirstChild("Heart")
        if heart and heart:IsA("BasePart") and not Farm.Blacklist[heart] then
            local inZone = true
            if Zone.Active and Zone.Pos1 and Zone.Pos2 then
                inZone = heart.Position.X >= math.min(Zone.Pos1.X, Zone.Pos2.X)
                    and heart.Position.X <= math.max(Zone.Pos1.X, Zone.Pos2.X)
                    and heart.Position.Z >= math.min(Zone.Pos1.Z, Zone.Pos2.Z)
                    and heart.Position.Z <= math.max(Zone.Pos1.Z, Zone.Pos2.Z)
            end
            if inZone then
                table.insert(candidates, {
                    Part = heart,
                    Dist = (heart.Position - rootPart.Position).Magnitude,
                    Val = Farm.CurrentMode == "Highest" and getCandyValue(heart) or 0,
                })
            end
        end
    end

    table.sort(candidates, function(a, b)
        if Farm.CurrentMode == "Closest" then
            return a.Dist < b.Dist
        else
            if a.Val == b.Val then return a.Dist < b.Dist end
            return a.Val > b.Val
        end
    end)

    -- Prefer visible targets
    for i = 1, math.min(#candidates, 15) do
        if checkSight(candidates[i].Part.Position) then
            return candidates[i].Part, false
        end
    end

    return #candidates > 0 and candidates[1].Part or nil, #candidates > 0
end

-- ==================
-- ANTI-ADMIN CHECK
-- ==================
local function runAntiAdminCheck()
    if not Config.Settings.Farming.AntiAdmin then return end
    if tick() - LastAdminCheck < 5 then return end
    LastAdminCheck = tick()

    local swordDataFolder = Config.Services.ReplicatedStorage:FindFirstChild("Sword Copy Data")
    if not swordDataFolder then return end

    pcall(function()
        local lowValueItems = {}
        for _, dataItem in ipairs(swordDataFolder:GetChildren()) do
            if (dataItem:IsA("IntValue") or dataItem:IsA("NumberValue")) and dataItem.Value < 20 then
                lowValueItems[dataItem.Name] = dataItem.Value
            end
        end

        local detected = false
        local detectedInfo = ""

        for _, targetPlayer in ipairs(Config.Services.Players:GetPlayers()) do
            local function scan(container, cName)
                if not container then return false end
                for _, item in ipairs(container:GetChildren()) do
                    if lowValueItems[item.Name] then
                        detectedInfo = targetPlayer.Name .. " was caught with '" .. item.Name .. "' (Value: " .. lowValueItems[item.Name] .. ") in their " .. cName .. "!"
                        return true
                    end
                end
                return false
            end

            if scan(targetPlayer:FindFirstChild("inventory"), "Inventory")
                or scan(targetPlayer:FindFirstChild("Backpack"), "Backpack")
                or (targetPlayer.Character and scan(targetPlayer.Character, "Character (Equipped)")) then
                detected = true
                break
            end
        end

        if detected then
            local GUI = Config.Modules.GUI
            if GUI then
                local lbl = GUI.GetStatusLabel()
                if lbl then lbl.Text = "Status: ANTI-ADMIN KICKING!" end
            end
            Config.Farm.Enabled = false
            if Config.Modules.Webhook then
                Config.Modules.Webhook.Send(true, detectedInfo)
            end
            task.wait(0.5)
            Config.Player:Kick("\n[ANTI-ADMIN PROTECTION]\n\n" .. detectedInfo .. "\n\nServer connection severed to protect your account.")
        end
    end)
end

-- ==================
-- INIT: Start the main loop
-- ==================
function FarmCore.Init(cfg)
    Config = cfg

    -- GC loop
    task.spawn(function()
        while true do task.wait(300); collectgarbage("collect") end
    end)

    -- Candy respawn listener
    if Config.CandyFolder then
        Config.CandyFolder.ChildAdded:Connect(function(child)
            if child.Name == "CandyCane" and Config.Farm.Enabled then
                task.delay(0.1, function() Config.Farm.LockedTarget = nil end)
            end
        end)
    end

    -- Anti-AFK
    Config.Player.Idled:Connect(function()
        if Config.Settings.Movement.AntiAFK then
            Config.Services.VirtualUser:CaptureController()
            Config.Services.VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    -- Loop Buy Case 26
    task.spawn(function()
        while true do
            task.wait(0.1)
            if Config.Settings.Extra.LoopBuyCase26 and Config.OpenCaseRemote then
                pcall(function() Config.OpenCaseRemote:FireServer(26) end)
            end
        end
    end)

    -- ==================
    -- MAIN HEARTBEAT LOOP
    -- ==================
    local Visuals = Config.Modules.Visuals
    local Pathfinding = Config.Modules.Pathfinding
    local Webhook = Config.Modules.Webhook
    local GUI = Config.Modules.GUI

    Config.Services.RunService.Heartbeat:Connect(function(deltaTime)
        local screenGui = GUI and GUI.GetScreenGui()
        if not screenGui or not screenGui.Parent then return end

        -- Update colors
        if Visuals then
            Visuals.UpdateColors()
            local colorBtn = GUI and GUI.GetColorBtn()
            local colorTitle = GUI and GUI.GetColorTitle()
            if colorBtn then colorBtn.BackgroundColor3 = Config.Settings.Visuals.PathColor end
            if colorTitle then colorTitle.TextColor3 = Config.Settings.Visuals.PathColor end
            if Config.Zone.Active then Visuals.DrawZone() end
        end

        -- Update stats display
        if Config.Farm.Enabled then
            local currentTime = tick()
            local elapsed = currentTime - Config.Farm.StartTime
            local hours = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = math.floor(elapsed % 60)
            local timeLabel = GUI and GUI.GetTimeLabel()
            if timeLabel then timeLabel.Text = string.format("Time Active: %02d:%02d:%02d", hours, mins, secs) end

            if currentTime - Config.Farm.LastStatUpdate > 2 then
                Config.Farm.LastStatUpdate = currentTime
                if elapsed > 0 then
                    local estLabel = GUI and GUI.GetEstLabel()
                    if estLabel then estLabel.Text = "Est. Hearts/Hr: " .. tostring(math.floor((Config.Farm.TotalCollected / elapsed) * 3600)) end
                end
            end

            -- Webhook timer
            if Webhook and Config.Settings.Webhook.Enabled and Config.Settings.Webhook.URL ~= "" then
                local multiplier = 1
                if Config.Settings.Webhook.Unit == "Minutes" then multiplier = 60
                elseif Config.Settings.Webhook.Unit == "Hours" then multiplier = 3600 end
                if currentTime - Config.Settings.Webhook.LastTime >= (Config.Settings.Webhook.Interval * multiplier) then
                    Config.Settings.Webhook.LastTime = currentTime
                    Webhook.Send(false)
                end
            end
        end

        -- Early exits
        if not Config.Farm.Enabled then
            if Visuals then Visuals.HideAllTrajectoryLines() end
            return
        end

        local humanoid = Config.Humanoid
        local rootPart = Config.RootPart
        if not humanoid or humanoid.Health <= 0 or not rootPart or not rootPart.Parent then
            if Visuals then Visuals.HideAllTrajectoryLines() end
            return
        end

        -- Fell through map fix
        if rootPart.Position.Y < -50 then
            pcall(function() rootPart.CFrame = CFrame.new(rootPart.Position.X, 100, rootPart.Position.Z) end)
            Config.Farm.PathGenerated = false
            return
        end

        humanoid.WalkSpeed = Config.Settings.Movement.WalkSpeed
        humanoid.AutoRotate = true

        -- Anti-Admin
        runAntiAdminCheck()

        -- Threat check (throttled)
        local statusLabel = GUI and GUI.GetStatusLabel()
        if tick() - Config.Farm.LastZoneCheck > 1 then
            Config.Farm.LastZoneCheck = tick()
            updateSafezoneCache()
            cleanupBlacklist()
            local d, p, a = getThreatInfo()
            Config.Farm.CachedThreat = { Dist = d, Pos = p, Armed = a }
        end

        -- Should we flee?
        local shouldFlee = false
        if Config.Farm.CachedThreat.Dist < Config.Settings.Farming.SafetyRadius then
            if Config.Settings.Farming.FleeMode == "Armed" and Config.Farm.CachedThreat.Armed then
                shouldFlee = true
            elseif Config.Settings.Farming.FleeMode == "All" then
                shouldFlee = true
            end
        end

        -- FLEEING STATE
        if Config.Farm.Status == "Fleeing" or Config.Farm.Status == "Waiting" then
            if statusLabel then statusLabel.Text = "🔴 EVADING THREAT!" end
            if Config.Farm.CachedThreat.Dist > Config.Settings.Farming.ResumeRadius then
                Config.Farm.Status = "Idle"
                Config.Farm.LockedTarget = nil
                if Visuals then Visuals.HideAllTrajectoryLines() end
            else
                if Config.Settings.Movement.TPProtection and tick() - Config.Farm.LastFleeTP > 1 then
                    Config.Farm.LastFleeTP = tick()
                    local bz = getBestEscapeSafezone(Config.Farm.CachedThreat.Pos)
                    local dir = bz and (bz.Position - rootPart.Position).Unit or (rootPart.Position - Config.Farm.CachedThreat.Pos).Unit
                    rootPart.CFrame = rootPart.CFrame + (dir * 4) + Vector3.new(0, 0.5, 0)
                end
                if Config.Farm.LockedTarget then
                    if (rootPart.Position - Config.Farm.LockedTarget.Position).Magnitude > 5 then
                        local wPos = Config.Farm.Waypoints[Config.Farm.CurrentWaypointIndex]
                        if wPos then
                            humanoid:MoveTo(wPos)
                            if (rootPart.Position - wPos).Magnitude < 2.5 then
                                Config.Farm.CurrentWaypointIndex = Config.Farm.CurrentWaypointIndex + 1
                            end
                        elseif Pathfinding then
                            Pathfinding.CreatePathTo(Config.Farm.LockedTarget.Position)
                        end
                    else
                        Config.Farm.Status = "Waiting"
                        humanoid:MoveTo(rootPart.Position)
                    end
                end
                return
            end
        end

        if shouldFlee then
            Config.Farm.Status = "Fleeing"
            if statusLabel then statusLabel.Text = "🔴 RUNNING!" end
            local bz = getBestEscapeSafezone(Config.Farm.CachedThreat.Pos)
            if bz then
                Config.Farm.LockedTarget = bz
                if Pathfinding then Pathfinding.CreatePathTo(bz.Position) end
            else
                humanoid:MoveTo(rootPart.Position + ((rootPart.Position - Config.Farm.CachedThreat.Pos).Unit * 20))
            end
            return
        end

        -- FARMING STATE
        Config.Farm.Status = "Farming"

        -- Clear invalid target
        if Config.Farm.LockedTarget then
            if not Config.Farm.LockedTarget.Parent or Config.Farm.LockedTarget.Name == "Safezone" then
                Config.Farm.LockedTarget = nil
                Config.Farm.PathGenerated = false
                if Visuals then Visuals.HideAllTrajectoryLines() end
            end
        end

        -- Find new target (throttled)
        if tick() - LastSearchTime > 0.15 then
            LastSearchTime = tick()
            local newTarget, isFar = findBestTarget()
            if newTarget and newTarget ~= Config.Farm.LockedTarget then
                Config.Farm.LockedTarget = newTarget
                Config.Farm.IsGlobalTarget = isFar
                Config.Farm.PathGenerated = false
            end
        end

        if not Config.Farm.LockedTarget then
            if statusLabel then statusLabel.Text = "🟡 Searching..." end
            if Visuals then Visuals.HideAllTrajectoryLines() end
            return
        end

        if statusLabel then
            statusLabel.Text = Config.Farm.IsGlobalTarget and "🟢 Traveling Far..." or "🟢 Farming"
        end

        local distToTarget = (rootPart.Position - Config.Farm.LockedTarget.Position).Magnitude

        -- Cheat TP
        if Config.Settings.Movement.CheatTP and distToTarget <= 15 then
            pcall(function() rootPart.CFrame = CFrame.new(Config.Farm.LockedTarget.Position + Vector3.new(0, 3, 0)) end)
            return
        end

        -- Collected!
        if distToTarget < Config.Settings.Farming.CollectDistance then
            local val = getCandyValue(Config.Farm.LockedTarget)
            if val == 0 then val = 1 end
            Config.Farm.TotalCollected = Config.Farm.TotalCollected + val
            Config.Farm.Blacklist[Config.Farm.LockedTarget] = tick() + 2
            Config.Farm.LockedTarget = nil
            Config.Farm.PathGenerated = false
            return
        end

        -- Generate path if needed
        if not Config.Farm.PathGenerated and Pathfinding then
            if checkSight(Config.Farm.LockedTarget.Position) then
                Config.Farm.Waypoints = Pathfinding.CreateHumanPath(
                    rootPart.Position,
                    Config.Farm.LockedTarget.Position,
                    { rootPart.Position, Config.Farm.LockedTarget.Position }
                )
                Config.Farm.CurrentWaypointIndex = 1
                Config.Farm.PathGenerated = true
            else
                Pathfinding.CreatePathTo(Config.Farm.LockedTarget.Position)
                Config.Farm.PathGenerated = true
            end
        end

        -- Follow waypoints
        if Config.Farm.CurrentWaypointIndex > #Config.Farm.Waypoints then
            Config.Farm.PathGenerated = false
        end

        local targetPos = Config.Farm.Waypoints[Config.Farm.CurrentWaypointIndex]

        if targetPos then
            local flatRoot   = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
            local flatTarget = Vector3.new(targetPos.X, 0, targetPos.Z)

            -- IMPROVED: slightly larger acceptance radius for smoother flow
            if (flatRoot - flatTarget).Magnitude < 2.8 then
                Config.Farm.CurrentWaypointIndex = Config.Farm.CurrentWaypointIndex + 1
                Config.Farm.MoveTimeout = 0
                targetPos = Config.Farm.Waypoints[Config.Farm.CurrentWaypointIndex]
            end
        end

        if not targetPos then
            targetPos = Config.Farm.LockedTarget.Position
            if not checkSight(Config.Farm.LockedTarget.Position) and not Config.Farm.IsPathfinding then
                Config.Farm.PathGenerated = false
            end
        end

        if targetPos then
            humanoid:MoveTo(targetPos)
            Config.Farm.MoveTimeout = (Config.Farm.MoveTimeout or 0) + deltaTime
            if Config.Farm.MoveTimeout > 6 then
                Config.Farm.PathGenerated = false
                Config.Farm.MoveTimeout = 0
            end

            -- Stuck detection + auto-jump
            local flatRoot   = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
            local flatTarget = Vector3.new(targetPos.X, 0, targetPos.Z)
            if rootPart.Velocity.Magnitude < 0.5 and (flatTarget - flatRoot).Magnitude > 2 then
                Config.Farm.StuckTimer = Config.Farm.StuckTimer + deltaTime
                humanoid.Jump = true
            else
                -- IMPROVED: reset stuck timer when actually moving
                Config.Farm.StuckTimer = math.max(0, Config.Farm.StuckTimer - deltaTime * 2)
            end

            -- Knee-level obstacle jump
            local lookDir = (targetPos - rootPart.Position).Unit
            local kneePos = rootPart.Position - Vector3.new(0, 2, 0)
            local rayP = RaycastParams.new()
            rayP.FilterDescendantsInstances = { Config.Character }
            rayP.FilterType = Enum.RaycastFilterType.Exclude
            if Config.Services.Workspace:Raycast(kneePos, lookDir * 4, rayP) then
                humanoid.Jump = true
            end
        end

        -- Stuck timeout -> switch targets
        if Config.Farm.StuckTimer > Config.Settings.Movement.StuckThreshold then
            humanoid.Jump = true
            if Config.Farm.LockedTarget then
                Config.Farm.Blacklist[Config.Farm.LockedTarget] = tick() + 10
            end
            Config.Farm.LockedTarget = nil
            Config.Farm.StuckTimer = 0
            Config.Farm.PathGenerated = false
            Config.Farm.MoveTimeout = 0
            if statusLabel then statusLabel.Text = "🟡 STUCK - SWITCHING" end
        end

        -- Draw trajectory
        if Visuals and Config.Farm.LockedTarget and Config.Farm.Status == "Farming" then
            local floorLevelY = Config.Farm.LockedTarget.Position.Y - 0.5
            Visuals.DrawCurvedTrajectory(Config.Farm.Waypoints, Config.Farm.CurrentWaypointIndex, floorLevelY)
        elseif Visuals then
            Visuals.HideAllTrajectoryLines()
        end
    end)
end

return FarmCore
