-- ============================================
-- PATHFINDING.lua - Human-Like Movement (IMPROVED)
-- Fixed: removed duplicate functions from original
-- Improved: more natural curves, variable drift, 
--           consistent speed, less stuttering
-- ============================================
local Pathfinding = {}
local Config = nil

-- Quadratic Bezier interpolation
local function bezier2(p0, p1, p2, t)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

-- Cubic Bezier for smoother long-distance curves
local function bezier3(p0, p1, p2, p3, t)
    local u = 1 - t
    return u*u*u * p0 + 3*u*u*t * p1 + 3*u*t*t * p2 + t*t*t * p3
end

--[[
    IMPROVED: createHumanPath
    - Uses cubic bezier for longer distances (smoother arcs)
    - Variable drift amplitude based on distance (short = subtle, long = wider)
    - More waypoints for smoother walking (no stuttering)
    - Alternating drift direction feels more natural
    - Tiny random micro-offsets on each point to avoid robotic precision
]]
local driftSide = 1 -- alternates each path so you don't always curve the same way

function Pathfinding.CreateHumanPath(startPos, targetPos, waypoints)
    local pts = {}
    local dist = (startPos - targetPos).Magnitude

    -- Very short distance: just walk there
    if dist < 4 then
        return { targetPos }
    end

    -- STRAIGHT LINE (direct sight or 2 waypoints) -> generate a natural arc
    if #waypoints <= 2 then
        local mid = (startPos + targetPos) / 2
        local dir = (targetPos - startPos).Unit
        local right = Vector3.new(-dir.Z, 0, dir.X)

        -- Flip drift side each path for variety
        driftSide = driftSide * -1

        -- Scale drift by distance: subtle for short walks, wider for long ones
        -- Clamp between 1 and 4 studs of drift
        local driftAmp = math.clamp(dist * 0.12, 1, 4) * driftSide

        -- Add a tiny random wobble so identical paths don't look identical
        driftAmp = driftAmp + (math.random() - 0.5) * 0.8

        if dist > 25 then
            -- LONG DISTANCE: use cubic bezier with two control points for S-curve feel
            local q1 = startPos + (targetPos - startPos) * 0.3 + right * driftAmp
            local q2 = startPos + (targetPos - startPos) * 0.7 + right * (driftAmp * -0.5)

            -- More points = smoother walk (1 point per ~3 studs)
            local numPoints = math.clamp(math.floor(dist / 3), 5, 20)
            for i = 1, numPoints do
                local t = i / numPoints
                local p = bezier3(startPos, q1, q2, targetPos, t)
                -- Micro-jitter: tiny random offset per point (0.1-0.3 studs)
                p = p + Vector3.new((math.random() - 0.5) * 0.3, 0, (math.random() - 0.5) * 0.3)
                table.insert(pts, p)
            end
        else
            -- MEDIUM DISTANCE: quadratic bezier with single control point
            local controlPt = mid + (right * driftAmp)

            local numPoints = math.clamp(math.floor(dist / 2.5), 4, 12)
            for i = 1, numPoints do
                local t = i / numPoints
                local p = bezier2(startPos, controlPt, targetPos, t)
                p = p + Vector3.new((math.random() - 0.5) * 0.2, 0, (math.random() - 0.5) * 0.2)
                table.insert(pts, p)
            end
        end

        return pts
    end

    -- PATHFINDING WAYPOINTS (obstacles in the way) -> smooth the corners
    table.insert(pts, waypoints[1])

    for i = 2, #waypoints - 1 do
        local p0 = (waypoints[i-1] + waypoints[i]) / 2
        if i == 2 then p0 = waypoints[1] end

        local p1 = waypoints[i]

        local p2 = (waypoints[i] + waypoints[i+1]) / 2
        if i == #waypoints - 1 then p2 = waypoints[i+1] end

        -- More subdivisions for smoother cornering
        local segDist = (p0 - p2).Magnitude
        local subdivisions = math.clamp(math.floor(segDist / 2), 3, 6)

        for j = 1, subdivisions do
            local t = j / subdivisions
            local p = bezier2(p0, p1, p2, t)
            -- Subtle micro-jitter on pathfinding curves too
            p = p + Vector3.new((math.random() - 0.5) * 0.15, 0, (math.random() - 0.5) * 0.15)
            table.insert(pts, p)
        end
    end

    table.insert(pts, waypoints[#waypoints])
    return pts
end

function Pathfinding.CreatePathTo(targetPos)
    if not Config then return end
    if Config.Farm.IsPathfinding then return end
    Config.Farm.IsPathfinding = true

    task.spawn(function()
        local rootPart = Config.RootPart
        local humanoid = Config.Humanoid
        if not rootPart or not humanoid then
            Config.Farm.IsPathfinding = false
            return
        end

        local path = Config.Services.PathfindingService:CreatePath({
            AgentRadius = 3,
            AgentHeight = 5,
            AgentCanJump = true,
            Costs = { Water = 20 },
        })

        local success = pcall(function()
            path:ComputeAsync(rootPart.Position, targetPos)
        end)

        if success and path.Status == Enum.PathStatus.Success then
            local rawWaypoints = path:GetWaypoints()
            local pointList = {}
            for _, wp in ipairs(rawWaypoints) do
                table.insert(pointList, wp.Position)
                if wp.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
            end
            Config.Farm.Waypoints = Pathfinding.CreateHumanPath(rootPart.Position, targetPos, pointList)
            Config.Farm.CurrentWaypointIndex = 1
        else
            -- Fallback: straight line with curve
            Config.Farm.Waypoints = Pathfinding.CreateHumanPath(rootPart.Position, targetPos, { rootPart.Position, targetPos })
            Config.Farm.CurrentWaypointIndex = 1
        end

        Config.Farm.IsPathfinding = false
    end)
end

function Pathfinding.SetConfig(cfg)
    Config = cfg
end

return Pathfinding
