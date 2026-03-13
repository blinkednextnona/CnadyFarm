-- ============================================
-- VISUALS.lua - Trajectory, Zone Drawing, Colors
-- ============================================
local Visuals = {}
local Config = nil

-- Folders
local zoneVisualFolder = Instance.new("Folder")
zoneVisualFolder.Name = "ZoneVisuals"
zoneVisualFolder.Parent = game:GetService("Workspace")

local trajectoryFolder = game:GetService("Workspace"):FindFirstChild("HeartTrajectoryFolder") or Instance.new("Folder")
trajectoryFolder.Name = "HeartTrajectoryFolder"
trajectoryFolder.Parent = game:GetService("Workspace")

Visuals.ZoneFolder = zoneVisualFolder
Visuals.TrajectoryFolder = trajectoryFolder

-- LINE POOL (object pooling for performance)
local LinePool = {}

function Visuals.HideAllTrajectoryLines()
    for _, line in ipairs(LinePool) do
        line.CFrame = CFrame.new(0, -9999, 0)
    end
end

function Visuals.DrawCurvedTrajectory(waypoints, currentIndex, fixedY)
    if not Config or not Config.Farm.Enabled or not waypoints or #waypoints == 0 or currentIndex > #waypoints then
        Visuals.HideAllTrajectoryLines()
        return
    end

    local lineIndex = 1
    local rootPart = Config.RootPart
    if not rootPart then return end

    local function drawSegment(p1, p2)
        local dist = (p1 - p2).Magnitude
        if dist > 0.1 then
            local line = LinePool[lineIndex]
            if not line then
                line = Instance.new("Part")
                line.Anchored = true
                line.CanCollide = false
                line.Material = Enum.Material.Neon
                line.Parent = trajectoryFolder
                LinePool[lineIndex] = line
            end
            line.Color = Config.Settings.Visuals.PathColor
            line.Transparency = 0.3
            line.Size = Vector3.new(0.08, 0.08, dist)
            line.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist / 2)
            lineIndex = lineIndex + 1
        end
    end

    local rootFlat = Vector3.new(rootPart.Position.X, fixedY, rootPart.Position.Z)
    local firstWp  = Vector3.new(waypoints[currentIndex].X, fixedY, waypoints[currentIndex].Z)
    drawSegment(rootFlat, firstWp)

    for i = currentIndex, #waypoints - 1 do
        local w1 = Vector3.new(waypoints[i].X,   fixedY, waypoints[i].Z)
        local w2 = Vector3.new(waypoints[i+1].X, fixedY, waypoints[i+1].Z)
        drawSegment(w1, w2)
    end

    for i = lineIndex, #LinePool do
        LinePool[i].CFrame = CFrame.new(0, -9999, 0)
    end
end

function Visuals.DrawZone()
    if not Config then return end
    zoneVisualFolder:ClearAllChildren()
    if not Config.Zone.Pos1 then return end

    local p1 = Config.Zone.Pos1
    local p2 = Config.Zone.Pos2 or Config.Zone.Pos1
    local minX, maxX = math.min(p1.X, p2.X), math.max(p1.X, p2.X)
    local minZ, maxZ = math.min(p1.Z, p2.Z), math.max(p1.Z, p2.Z)
    local yVal = p1.Y
    local color = Config.Settings.Visuals.PathColor
    local thickness = 0.1

    local function makeLine(a, b)
        local d = (a - b).Magnitude
        if d < 0.1 then return end
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.Neon
        p.Color = color
        p.Transparency = 0.6
        p.Size = Vector3.new(thickness, thickness, d)
        p.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -d / 2)
        Instance.new("CylinderMesh", p)
        p.Parent = zoneVisualFolder
    end

    local c1 = Vector3.new(minX, yVal, minZ)
    local c2 = Vector3.new(maxX, yVal, minZ)
    local c3 = Vector3.new(maxX, yVal, maxZ)
    local c4 = Vector3.new(minX, yVal, maxZ)
    makeLine(c1, c2); makeLine(c2, c3); makeLine(c3, c4); makeLine(c4, c1)

    local ty = yVal + 10
    local t1 = Vector3.new(minX, ty, minZ)
    local t2 = Vector3.new(maxX, ty, minZ)
    local t3 = Vector3.new(maxX, ty, maxZ)
    local t4 = Vector3.new(minX, ty, maxZ)
    makeLine(t1, t2); makeLine(t2, t3); makeLine(t3, t4); makeLine(t4, t1)
    makeLine(c1, t1); makeLine(c2, t2); makeLine(c3, t3); makeLine(c4, t4)
end

function Visuals.UpdateColors()
    if not Config then return end
    local S = Config.Settings.Visuals
    if S.ColorMode == "Rainbow" then
        local hue = (tick() * S.ColorSpeed / 5) % 1
        S.PathColor = Color3.fromHSV(hue, 1, 1)
    elseif S.ColorMode == "StrobeBW" then
        local t = tick() * S.ColorSpeed * 2
        S.PathColor = (math.floor(t) % 2 == 0) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    elseif S.ColorMode == "Custom" and #S.CustomColors > 0 then
        local count = #S.CustomColors
        local speed = S.ColorSpeed * 0.5
        if S.ColorFade then
            local t = (tick() * speed) % count
            local idx1 = math.floor(t) + 1
            local idx2 = (math.floor(t) + 1) % count + 1
            S.PathColor = S.CustomColors[idx1]:Lerp(S.CustomColors[idx2], t - math.floor(t))
        else
            S.PathColor = S.CustomColors[math.floor(tick() * speed * 2) % count + 1]
        end
    end
end

function Visuals.Cleanup()
    pcall(function() zoneVisualFolder:Destroy() end)
    pcall(function() trajectoryFolder:Destroy() end)
end

function Visuals.SetConfig(cfg)
    Config = cfg
end

return Visuals
