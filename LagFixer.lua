-- ============================================
-- LAGFIXER.lua - Hide textures/decals for FPS
-- ============================================
local LagFixer = {}

local HiddenInstances = {}
local Connection = nil
local Config = nil

local function HideInstance(inst)
    if not Config or not Config.Settings.Farming.LagFixer then return end
    if inst:IsA("Decal") or inst:IsA("Texture") then
        if not HiddenInstances[inst] then
            HiddenInstances[inst] = { Prop = "Transparency", Val = inst.Transparency }
        end
        inst.Transparency = 1
    elseif inst:IsA("SurfaceAppearance") then
        if not HiddenInstances[inst] then
            HiddenInstances[inst] = { Prop = "Parent", Val = inst.Parent }
        end
        inst.Parent = nil
    elseif inst:IsA("BasePart") then
        if Config.CandyFolder and inst:IsDescendantOf(Config.CandyFolder) then
            if not HiddenInstances[inst] then
                HiddenInstances[inst] = { Prop = "Transparency", Val = inst.Transparency }
            end
            inst.Transparency = 1
        end
    end
end

function LagFixer.Toggle(state)
    if not Config then return end
    Config.Settings.Farming.LagFixer = state
    if state then
        for _, inst in pairs(Config.Services.Workspace:GetDescendants()) do
            HideInstance(inst)
        end
        if not Connection then
            Connection = Config.Services.Workspace.DescendantAdded:Connect(HideInstance)
        end
    else
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
        for inst, data in pairs(HiddenInstances) do
            if inst and (inst.Parent ~= nil or data.Prop == "Parent") then
                pcall(function()
                    if data.Prop == "Transparency" then
                        inst.Transparency = data.Val
                    elseif data.Prop == "Parent" then
                        inst.Parent = data.Val
                    end
                end)
            end
        end
        HiddenInstances = {}
    end
    Config.SaveSettings()
end

function LagFixer.SetConfig(cfg)
    Config = cfg
end

-- Auto-bind config if loaded via module registry
task.defer(function()
    -- Config gets set by GUI.Init or FarmCore.Init
end)

return LagFixer
