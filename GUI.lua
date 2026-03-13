-- ============================================
-- GUI.lua - Full Tabbed Interface + Color Picker
-- ============================================
local GUI = {}
local Config = nil

local ScreenGui, MainFrame
local ToggleBtn, StatusLabel, TimeLabel, EstLabel
local ColorBtn, ColorFrame, ColorTitle, EffectsFrame
local TabButtons, TabFrames
local slotButtons = {}
local TooltipLabel

local LagFixerBtn, AntiAdminBtn, WebhookToggle, CheatTPBtn, TPProtectBtn, AntiAFKBtn
local SmoothBtn, LoopBuyBtn, SpeedInp, SafetyBox, ArmedBtn
local WHBox, IntervalBox, UnitBtn, ColorSpeedBox

-- ==================
-- UI HELPERS
-- ==================
local function AddTooltip(obj, text)
    obj.MouseEnter:Connect(function()
        TooltipLabel.Text = text
        TooltipLabel.TextColor3 = Color3.new(1, 1, 1)
    end)
    obj.MouseLeave:Connect(function()
        TooltipLabel.Text = "Hover over settings for info..."
        TooltipLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
end

local function createUIBtn(parent, text, color, tooltip, onClick)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    if tooltip then AddTooltip(btn, tooltip) end
    if onClick then btn.MouseButton1Click:Connect(function() onClick(btn) end) end
    return btn
end

local function createUIInput(parent, text, tooltip, onFocusLost)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.95, 0, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    box.Text = text
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    if tooltip then AddTooltip(box, tooltip) end
    if onFocusLost then box.FocusLost:Connect(function() onFocusLost(box) end) end
    return box
end

function GUI.GetToggleBtn()    return ToggleBtn end
function GUI.GetStatusLabel()  return StatusLabel end
function GUI.GetTimeLabel()    return TimeLabel end
function GUI.GetEstLabel()     return EstLabel end
function GUI.GetColorBtn()     return ColorBtn end
function GUI.GetColorTitle()   return ColorTitle end
function GUI.GetScreenGui()    return ScreenGui end

function GUI.RefreshUI()
    if not Config then return end
    local S = Config.Settings
    LagFixerBtn.Text = "Lag Fixer: " .. (S.Farming.LagFixer and "ON" or "OFF")
    LagFixerBtn.TextColor3 = S.Farming.LagFixer and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
    AntiAdminBtn.Text = "Anti-Admin: " .. (S.Farming.AntiAdmin and "ON" or "OFF")
    AntiAdminBtn.TextColor3 = S.Farming.AntiAdmin and Color3.fromRGB(255, 150, 50) or Color3.new(1, 1, 1)
    WebhookToggle.Text = "Webhook: " .. (S.Webhook.Enabled and "ON" or "OFF")
    WebhookToggle.TextColor3 = S.Webhook.Enabled and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
    CheatTPBtn.Text = "Cheat TP: " .. (S.Movement.CheatTP and "ON" or "OFF")
    CheatTPBtn.TextColor3 = S.Movement.CheatTP and Color3.fromRGB(255, 170, 0) or Color3.new(1, 1, 1)
    TPProtectBtn.Text = "TP Protect: " .. (S.Movement.TPProtection and "ON" or "OFF")
    TPProtectBtn.TextColor3 = S.Movement.TPProtection and Color3.fromRGB(255, 170, 0) or Color3.new(1, 1, 1)
    AntiAFKBtn.Text = "Anti-AFK: " .. (S.Movement.AntiAFK and "ON" or "OFF")
    AntiAFKBtn.TextColor3 = S.Movement.AntiAFK and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
    SmoothBtn.Text = S.Visuals.ColorFade and "Fade: ON" or "Fade: OFF"
    SmoothBtn.TextColor3 = S.Visuals.ColorFade and Color3.new(1, 1, 1) or Color3.fromRGB(200, 50, 50)
    LoopBuyBtn.Text = "Loop Buy Case 26: " .. (S.Extra.LoopBuyCase26 and "ON" or "OFF")
    LoopBuyBtn.TextColor3 = S.Extra.LoopBuyCase26 and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
    SpeedInp.Text = "Walk Speed: " .. S.Movement.WalkSpeed
    SafetyBox.Text = "Safe Dist: " .. S.Farming.SafetyRadius
    ColorBtn.BackgroundColor3 = S.Visuals.PathColor
    ColorTitle.TextColor3 = S.Visuals.PathColor
    ArmedBtn.Text = "Flee Mode: " .. S.Farming.FleeMode
    ArmedBtn.TextColor3 = S.Farming.FleeMode == "Off" and Color3.new(1, 1, 1) or Color3.fromRGB(255, 150, 50)
    if S.Webhook.URL ~= "" then WHBox.Text = S.Webhook.URL end
    IntervalBox.Text = tostring(S.Webhook.Interval)
    UnitBtn.Text = S.Webhook.Unit
    ColorSpeedBox.Text = "Speed: " .. S.Visuals.ColorSpeed
    for i, slot in ipairs(slotButtons) do
        if S.Visuals.CustomColors[i] then
            slot.BackgroundColor3 = S.Visuals.CustomColors[i]
            slot.Text = ""
        else
            slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            slot.Text = tostring(i)
        end
    end
end

function GUI.Init(cfg)
    Config = cfg
    local S = Config.Settings

    if Config.Modules.LagFixer    then Config.Modules.LagFixer.SetConfig(Config)    end
    if Config.Modules.Webhook     then Config.Modules.Webhook.SetConfig(Config)     end
    if Config.Modules.Visuals     then Config.Modules.Visuals.SetConfig(Config)     end
    if Config.Modules.Pathfinding then Config.Modules.Pathfinding.SetConfig(Config) end

    local CoreGui = Config.Services.CoreGui

    ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "HeartFarmGUI_V18"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 250, 0, 380)
    MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "💖 HEART ZONE V18"
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.MouseButton1Click:Connect(function()
        Config.SaveSettings()
        if Config.Modules.Visuals then Config.Modules.Visuals.Cleanup() end
        if Config.Modules.LagFixer and S.Farming.LagFixer then Config.Modules.LagFixer.Toggle(false) end
        ScreenGui:Destroy()
    end)

    local StatsFrame = Instance.new("Frame", MainFrame)
    StatsFrame.Size = UDim2.new(0.9, 0, 0, 85)
    StatsFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)

    ToggleBtn = Instance.new("TextButton", StatsFrame)
    ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleBtn.Text = "🔴 FARM: OFF"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 14
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

    StatusLabel = Instance.new("TextLabel", StatsFrame)
    StatusLabel.Text = "Status: Idle"
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 15)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 11

    TimeLabel = Instance.new("TextLabel", StatsFrame)
    TimeLabel.Text = "Time: 00:00:00"
    TimeLabel.Size = UDim2.new(0.45, 0, 0, 15)
    TimeLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextSize = 11
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    EstLabel = Instance.new("TextLabel", StatsFrame)
    EstLabel.Text = "Hr/Min: 0 / 0"
    EstLabel.Size = UDim2.new(0.45, 0, 0, 15)
    EstLabel.Position = UDim2.new(0.5, 0, 0.7, 0)
    EstLabel.BackgroundTransparency = 1
    EstLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    EstLabel.Font = Enum.Font.Gotham
    EstLabel.TextSize = 11
    EstLabel.TextXAlignment = Enum.TextXAlignment.Right

    TooltipLabel = Instance.new("TextLabel", MainFrame)
    TooltipLabel.Size = UDim2.new(0.9, 0, 0, 25)
    TooltipLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
    TooltipLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TooltipLabel.Text = "Hover over settings for info..."
    TooltipLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    TooltipLabel.Font = Enum.Font.Gotham
    TooltipLabel.TextSize = 10
    Instance.new("UICorner", TooltipLabel).CornerRadius = UDim.new(0, 4)

    -- TAB BAR
    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.Size = UDim2.new(0.9, 0, 0, 25)
    TabBar.Position = UDim2.new(0.05, 0, 0.35, 0)
    TabBar.BackgroundTransparency = 1

    local Tabs = { "Farm", "Move", "Vis", "Web", "Zone", "Extra" }
    TabButtons = {}
    TabFrames = {}

    for i, name in ipairs(Tabs) do
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(1 / #Tabs, -2, 1, 0)
        btn.Position = UDim2.new((i - 1) / #Tabs, 1, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.Text = name
        btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        TabButtons[name] = btn

        local frame = Instance.new("ScrollingFrame", MainFrame)
        frame.Size = UDim2.new(0.9, 0, 0, 180)
        frame.Position = UDim2.new(0.05, 0, 0.44, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.Visible = false
        frame.ScrollBarThickness = 4
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        local layout = Instance.new("UIListLayout", frame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Instance.new("UIPadding", frame).PaddingTop = UDim.new(0, 5)
        TabFrames[name] = frame

        btn.MouseButton1Click:Connect(function()
            for k, f in pairs(TabFrames) do f.Visible = (k == name) end
            for k, b in pairs(TabButtons) do
                if k == name then
                    b.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    b.TextColor3 = Color3.new(1, 1, 1)
                else
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
                end
            end
        end)
    end

    TabButtons["Farm"].BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TabButtons["Farm"].TextColor3 = Color3.new(1, 1, 1)
    TabFrames["Farm"].Visible = true

    -- FARM TAB
    createUIBtn(TabFrames["Farm"], "Mode: " .. Config.Farm.CurrentMode, Color3.fromRGB(50, 50, 60), "Toggle between Closest or Highest Value heart.", function(b)
        Config.Farm.CurrentMode = (Config.Farm.CurrentMode == "Closest") and "Highest" or "Closest"
        b.Text = "Mode: " .. Config.Farm.CurrentMode
        if Config.Farm.Enabled then Config.Farm.LockedTarget = nil; Config.Farm.PathGenerated = false end
        Config.SaveSettings()
    end)

    LagFixerBtn = createUIBtn(TabFrames["Farm"], "Lag Fixer: OFF", Color3.fromRGB(40, 40, 45), "Hides textures for max FPS.", function(b)
        S.Farming.LagFixer = not S.Farming.LagFixer
        if Config.Modules.LagFixer then Config.Modules.LagFixer.Toggle(S.Farming.LagFixer) end
        b.Text = "Lag Fixer: " .. (S.Farming.LagFixer and "ON" or "OFF")
        b.TextColor3 = S.Farming.LagFixer and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    SafetyBox = createUIInput(TabFrames["Farm"], "Safe Dist: " .. S.Farming.SafetyRadius, "Distance to avoid other players.", function(b)
        local n = tonumber(b.Text:match("%d+"))
        if n then S.Farming.SafetyRadius = n; S.Farming.ResumeRadius = n + 5; b.Text = "Safe Dist: " .. n; Config.SaveSettings() end
    end)

    ArmedBtn = createUIBtn(TabFrames["Farm"], "Flee Mode: " .. S.Farming.FleeMode, Color3.fromRGB(40, 40, 45), "Who to run away from.", function(b)
        if S.Farming.FleeMode == "Armed" then S.Farming.FleeMode = "All"
        elseif S.Farming.FleeMode == "All" then S.Farming.FleeMode = "Off"
        else S.Farming.FleeMode = "Armed" end
        b.Text = "Flee Mode: " .. S.Farming.FleeMode
        b.TextColor3 = S.Farming.FleeMode == "Off" and Color3.new(1, 1, 1) or Color3.fromRGB(255, 150, 50)
        Config.SaveSettings()
    end)

    AntiAdminBtn = createUIBtn(TabFrames["Farm"], "Anti-Admin: OFF", Color3.fromRGB(40, 40, 45), "Kicks if <20 value item found on any player.", function(b)
        S.Farming.AntiAdmin = not S.Farming.AntiAdmin
        b.Text = "Anti-Admin: " .. (S.Farming.AntiAdmin and "ON" or "OFF")
        b.TextColor3 = S.Farming.AntiAdmin and Color3.fromRGB(255, 150, 50) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    -- MOVE TAB
    SpeedInp = createUIInput(TabFrames["Move"], "Walk Speed: " .. S.Movement.WalkSpeed, "Base Speed.", function(b)
        local n = tonumber(b.Text:match("%d+"))
        if n then S.Movement.WalkSpeed = n; b.Text = "Walk Speed: " .. n; Config.SaveSettings() end
    end)

    CheatTPBtn = createUIBtn(TabFrames["Move"], "Cheat TP: OFF", Color3.fromRGB(40, 40, 45), "Near TP.", function(b)
        S.Movement.CheatTP = not S.Movement.CheatTP
        b.Text = "Cheat TP: " .. (S.Movement.CheatTP and "ON" or "OFF")
        b.TextColor3 = S.Movement.CheatTP and Color3.fromRGB(255, 170, 0) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    TPProtectBtn = createUIBtn(TabFrames["Move"], "TP Protect: OFF", Color3.fromRGB(40, 40, 45), "Teleports away slightly when fleeing.", function(b)
        S.Movement.TPProtection = not S.Movement.TPProtection
        b.Text = "TP Protect: " .. (S.Movement.TPProtection and "ON" or "OFF")
        b.TextColor3 = S.Movement.TPProtection and Color3.fromRGB(255, 170, 0) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    AntiAFKBtn = createUIBtn(TabFrames["Move"], "Anti-AFK: ON", Color3.fromRGB(40, 40, 45), "Prevents idle kicks.", function(b)
        S.Movement.AntiAFK = not S.Movement.AntiAFK
        b.Text = "Anti-AFK: " .. (S.Movement.AntiAFK and "ON" or "OFF")
        b.TextColor3 = S.Movement.AntiAFK and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    -- VIS TAB
    ColorBtn = createUIBtn(TabFrames["Vis"], "Trajectory Color >", S.Visuals.PathColor, "Beam Color.", function() end)

    -- WEB TAB
    WHBox = createUIInput(TabFrames["Web"], S.Webhook.URL ~= "" and S.Webhook.URL or "Enter Webhook URL", "Paste Discord Webhook URL.", function(b)
        S.Webhook.URL = b.Text; Config.SaveSettings()
    end)
    WHBox.TextTruncate = Enum.TextTruncate.AtEnd

    local WHIntervalFrame = Instance.new("Frame", TabFrames["Web"])
    WHIntervalFrame.Size = UDim2.new(0.95, 0, 0, 30)
    WHIntervalFrame.BackgroundTransparency = 1

    IntervalBox = Instance.new("TextBox", WHIntervalFrame)
    IntervalBox.Size = UDim2.new(0.3, 0, 1, 0)
    IntervalBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    IntervalBox.Text = tostring(S.Webhook.Interval)
    IntervalBox.TextColor3 = Color3.new(1, 1, 1)
    IntervalBox.Font = Enum.Font.Gotham
    Instance.new("UICorner", IntervalBox).CornerRadius = UDim.new(0, 4)
    IntervalBox.FocusLost:Connect(function()
        local n = tonumber(IntervalBox.Text:match("%d+"))
        if n and n > 0 then S.Webhook.Interval = n else IntervalBox.Text = tostring(S.Webhook.Interval) end
        Config.SaveSettings()
    end)

    UnitBtn = Instance.new("TextButton", WHIntervalFrame)
    UnitBtn.Size = UDim2.new(0.65, -5, 1, 0)
    UnitBtn.Position = UDim2.new(0.35, 5, 0, 0)
    UnitBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    UnitBtn.Text = S.Webhook.Unit
    UnitBtn.TextColor3 = Color3.new(1, 1, 1)
    UnitBtn.Font = Enum.Font.Gotham
    Instance.new("UICorner", UnitBtn).CornerRadius = UDim.new(0, 4)
    UnitBtn.MouseButton1Click:Connect(function()
        if S.Webhook.Unit == "Seconds" then S.Webhook.Unit = "Minutes"
        elseif S.Webhook.Unit == "Minutes" then S.Webhook.Unit = "Hours"
        else S.Webhook.Unit = "Seconds" end
        UnitBtn.Text = S.Webhook.Unit; Config.SaveSettings()
    end)

    WebhookToggle = createUIBtn(TabFrames["Web"], "Webhook: OFF", Color3.fromRGB(40, 40, 45), "Enable sending stats to Discord.", function(b)
        S.Webhook.Enabled = not S.Webhook.Enabled
        b.Text = "Webhook: " .. (S.Webhook.Enabled and "ON" or "OFF")
        b.TextColor3 = S.Webhook.Enabled and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    -- ZONE TAB
    local P1Btn = createUIBtn(TabFrames["Zone"], "Set Pos 1", Color3.fromRGB(60, 60, 80), "Zone corner.", function(b)
        Config.Zone.Pos1 = Config.RootPart.Position; b.Text = "Pos 1: SET"
        if Config.Modules.Visuals then Config.Modules.Visuals.DrawZone() end
    end)

    local P2Btn = createUIBtn(TabFrames["Zone"], "Set Pos 2", Color3.fromRGB(60, 60, 80), "Zone corner.", function(b)
        Config.Zone.Pos2 = Config.RootPart.Position; b.Text = "Pos 2: SET"
        if Config.Zone.Pos1 then Config.Zone.Active = true; if Config.Modules.Visuals then Config.Modules.Visuals.DrawZone() end end
    end)

    createUIBtn(TabFrames["Zone"], "Reset Zone", Color3.fromRGB(80, 40, 40), "Clear zone constraints.", function()
        Config.Zone.Pos1 = nil; Config.Zone.Pos2 = nil; Config.Zone.Active = false
        P1Btn.Text = "Set Pos 1"; P2Btn.Text = "Set Pos 2"
        if Config.Modules.Visuals then Config.Modules.Visuals.ZoneFolder:ClearAllChildren() end
    end)

    -- EXTRA TAB
    LoopBuyBtn = createUIBtn(TabFrames["Extra"], "Loop Buy Case 26: OFF", Color3.fromRGB(40, 40, 45), "Spams buying Case 26.", function(b)
        S.Extra.LoopBuyCase26 = not S.Extra.LoopBuyCase26
        b.Text = "Loop Buy Case 26: " .. (S.Extra.LoopBuyCase26 and "ON" or "OFF")
        b.TextColor3 = S.Extra.LoopBuyCase26 and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)
        Config.SaveSettings()
    end)

    -- COLOR PICKER
    ColorFrame = Instance.new("Frame", MainFrame)
    ColorFrame.Size = UDim2.new(0, 200, 0, 240)
    ColorFrame.Position = UDim2.new(1.05, 0, 0, 0)
    ColorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ColorFrame.Visible = false
    Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0, 8)

    ColorTitle = Instance.new("TextLabel", ColorFrame)
    ColorTitle.Text = "PICK COLOR"
    ColorTitle.Size = UDim2.new(1, 0, 0, 35)
    ColorTitle.BackgroundTransparency = 1
    ColorTitle.TextColor3 = S.Visuals.PathColor
    ColorTitle.Font = Enum.Font.GothamBold
    ColorTitle.TextSize = 14

    ColorBtn.MouseButton1Click:Connect(function() ColorFrame.Visible = not ColorFrame.Visible end)

    local EffectsMenuBtn = createUIBtn(ColorFrame, "Changing Colors >", Color3.fromRGB(40, 40, 45), "Animated colors", nil)
    EffectsMenuBtn.Position = UDim2.new(0.05, 0, 0.8, 0)

    local Wheel = Instance.new("ImageButton", ColorFrame)
    Wheel.Size = UDim2.new(0, 120, 0, 120)
    Wheel.Position = UDim2.new(0.05, 0, 0.15, 0)
    Wheel.BackgroundTransparency = 1
    Wheel.Image = "rbxassetid://6020299385"
    Wheel.ZIndex = 2

    local WheelScope = Instance.new("Frame", Wheel)
    WheelScope.Size = UDim2.new(0, 10, 0, 10)
    WheelScope.AnchorPoint = Vector2.new(0.5, 0.5)
    WheelScope.Position = UDim2.new(0.5, 0, 0.5, 0)
    WheelScope.BackgroundColor3 = Color3.new(1, 1, 1)
    WheelScope.BorderColor3 = Color3.new(0, 0, 0)
    WheelScope.BorderSizePixel = 1
    WheelScope.ZIndex = 3
    Instance.new("UICorner", WheelScope).CornerRadius = UDim.new(1, 0)

    local ValueSlider = Instance.new("Frame", ColorFrame)
    ValueSlider.Size = UDim2.new(0, 30, 0, 120)
    ValueSlider.Position = UDim2.new(0.75, 0, 0.15, 0)
    ValueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    ValueSlider.BorderSizePixel = 0
    ValueSlider.ZIndex = 2
    Instance.new("UICorner", ValueSlider).CornerRadius = UDim.new(0, 4)
    local ValueGradient = Instance.new("UIGradient", ValueSlider)
    ValueGradient.Rotation = 90
    ValueGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0)) }

    local ValueBar = Instance.new("Frame", ValueSlider)
    ValueBar.Size = UDim2.new(1.2, 0, 0, 4)
    ValueBar.AnchorPoint = Vector2.new(0.5, 0)
    ValueBar.Position = UDim2.new(0.5, 0, 0, 0)
    ValueBar.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    ValueBar.BorderSizePixel = 1
    ValueBar.BorderColor3 = Color3.new(0, 0, 0)
    ValueBar.ZIndex = 3

    -- EFFECTS FRAME
    EffectsFrame = Instance.new("Frame", MainFrame)
    EffectsFrame.Size = UDim2.new(0, 200, 0, 280)
    EffectsFrame.Position = UDim2.new(1.05, 210, 0, 0)
    EffectsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    EffectsFrame.Visible = false
    Instance.new("UICorner", EffectsFrame).CornerRadius = UDim.new(0, 8)

    local EffectsTitle = Instance.new("TextLabel", EffectsFrame)
    EffectsTitle.Text = "CHANGING COLORS"
    EffectsTitle.Size = UDim2.new(1, 0, 0, 35)
    EffectsTitle.BackgroundTransparency = 1
    EffectsTitle.TextColor3 = Color3.new(1, 1, 1)
    EffectsTitle.Font = Enum.Font.GothamBold
    EffectsTitle.TextSize = 14

    local RainbowBtn = createUIBtn(EffectsFrame, "Rainbow Mode", Color3.fromRGB(50, 50, 60), nil, function() S.Visuals.ColorMode = "Rainbow"; Config.SaveSettings() end)
    RainbowBtn.Position = UDim2.new(0.05, 0, 0.12, 0)

    local StrobeBWBtn = createUIBtn(EffectsFrame, "Strobe Black/White", Color3.fromRGB(20, 20, 20), nil, function() S.Visuals.ColorMode = "StrobeBW"; Config.SaveSettings() end)
    StrobeBWBtn.Position = UDim2.new(0.05, 0, 0.23, 0)

    local Divider = Instance.new("TextLabel", EffectsFrame)
    Divider.Text = "--- CUSTOM CYCLE ---"
    Divider.Size = UDim2.new(1, 0, 0, 20)
    Divider.Position = UDim2.new(0, 0, 0.34, 0)
    Divider.BackgroundTransparency = 1
    Divider.TextColor3 = Color3.fromRGB(150, 150, 150)
    Divider.Font = Enum.Font.GothamBold
    Divider.TextSize = 10

    local GridFrame = Instance.new("Frame", EffectsFrame)
    GridFrame.Size = UDim2.new(0.9, 0, 0, 60)
    GridFrame.Position = UDim2.new(0.05, 0, 0.46, 0)
    GridFrame.BackgroundTransparency = 1

    for i = 1, 10 do
        local slot = Instance.new("TextButton", GridFrame)
        slot.Name = "Slot" .. i
        slot.Text = tostring(i)
        slot.TextColor3 = Color3.new(1, 1, 1)
        slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        slot.Size = UDim2.new(0, 30, 0, 25)
        slot.Position = UDim2.new(0, ((i-1) % 5) * 35, 0, math.floor((i-1) / 5) * 30)
        Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 4)
        slot.MouseButton1Click:Connect(function()
            S.Visuals.CustomColors[i] = S.Visuals.PathColor
            slot.BackgroundColor3 = S.Visuals.PathColor
            Config.SaveSettings()
        end)
        table.insert(slotButtons, slot)
    end

    local ClearAllBtn = createUIBtn(EffectsFrame, "Clear All", Color3.fromRGB(60, 30, 30), nil, function()
        S.Visuals.CustomColors = {}
        for _, s in ipairs(slotButtons) do s.BackgroundColor3 = Color3.fromRGB(40,40,40); s.Text = s.Name:match("%d+") end
        Config.SaveSettings()
    end)
    ClearAllBtn.Size = UDim2.new(0.4, 0, 0, 20)
    ClearAllBtn.Position = UDim2.new(0.05, 0, 0.69, 0)

    SmoothBtn = createUIBtn(EffectsFrame, "Fade: ON", Color3.fromRGB(40, 40, 50), nil, function(b)
        S.Visuals.ColorFade = not S.Visuals.ColorFade
        b.Text = S.Visuals.ColorFade and "Fade: ON" or "Fade: OFF"
        b.TextColor3 = S.Visuals.ColorFade and Color3.new(1,1,1) or Color3.fromRGB(200,50,50)
        Config.SaveSettings()
    end)
    SmoothBtn.Size = UDim2.new(0.45, 0, 0, 20)
    SmoothBtn.Position = UDim2.new(0.5, 0, 0.69, 0)

    ColorSpeedBox = createUIInput(EffectsFrame, "Speed: 1", nil, function(b)
        local n = tonumber(b.Text:match("[%d%.]+"))
        if n then S.Visuals.ColorSpeed = n; b.Text = "Speed: "..n end
        Config.SaveSettings()
    end)
    ColorSpeedBox.Size = UDim2.new(0.9, 0, 0, 25)
    ColorSpeedBox.Position = UDim2.new(0.05, 0, 0.78, 0)

    local PlayCustomBtn = createUIBtn(EffectsFrame, "Play Custom Cycle", Color3.fromRGB(50, 150, 50), nil, function()
        if #S.Visuals.CustomColors < 1 then return end
        S.Visuals.ColorMode = "Custom"; Config.SaveSettings()
    end)
    PlayCustomBtn.Size = UDim2.new(0.9, 0, 0, 25)
    PlayCustomBtn.Position = UDim2.new(0.05, 0, 0.89, 0)

    EffectsMenuBtn.MouseButton1Click:Connect(function() EffectsFrame.Visible = not EffectsFrame.Visible end)

    -- COLOR PICKER LOGIC
    local colorData = { h = 0, s = 1, v = 1 }
    local draggingWheel = false
    local draggingValue = false

    local function updateColor()
        if S.Visuals.ColorMode == "Static" then
            local c = Color3.fromHSV(colorData.h, colorData.s, colorData.v)
            S.Visuals.PathColor = c
            ColorBtn.BackgroundColor3 = c
            ColorTitle.TextColor3 = c
            if Config.Zone.Active or Config.Zone.Pos1 then
                if Config.Modules.Visuals then Config.Modules.Visuals.DrawZone() end
            end
            Config.SaveSettings()
        end
    end

    local function updateWheel(input)
        local r = Wheel.AbsoluteSize.X / 2
        local center = Wheel.AbsolutePosition + Vector2.new(r, r)
        local mouse = Vector2.new(input.Position.X, input.Position.Y)
        local offset = mouse - center
        local angle = math.atan2(offset.Y, offset.X)
        local dist = math.min(offset.Magnitude, r)
        colorData.h = (math.pi - angle) / (2 * math.pi)
        colorData.s = dist / r
        WheelScope.Position = UDim2.new(0.5, math.cos(angle) * dist, 0.5, math.sin(angle) * dist)
        if draggingWheel and S.Visuals.ColorMode ~= "Static" then S.Visuals.ColorMode = "Static" end
        updateColor()
    end

    local function updateValue(input)
        local y = input.Position.Y - ValueSlider.AbsolutePosition.Y
        local percent = math.clamp(y / ValueSlider.AbsoluteSize.Y, 0, 1)
        ValueBar.Position = UDim2.new(0.5, 0, percent, 0)
        colorData.v = 1 - percent
        updateColor()
    end

    Wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingWheel = true; updateWheel(input) end
    end)
    ValueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingValue = true; updateValue(input) end
    end)
    Config.Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingWheel then updateWheel(input) end
            if draggingValue then updateValue(input) end
        end
    end)
    Config.Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingWheel = false; draggingValue = false end
    end)

    -- TOGGLE FARM
    ToggleBtn.MouseButton1Click:Connect(function()
        Config.Farm.Enabled = not Config.Farm.Enabled
        if Config.Farm.Enabled then
            ToggleBtn.Text = "🟢 FARM: ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            Config.Farm.StartTime = tick()
            Config.Farm.LockedTarget = nil
            Config.Farm.Status = "Idle"
            Config.Farm.TotalCollected = 0
            Config.Farm.LastStatUpdate = tick()
            S.Webhook.LastTime = tick()
            TimeLabel.Text = "Time Active: 00:00:00"
            EstLabel.Text = "Est. Hearts/Hr: 0"
            Config.UpdateCharacter(Config.Player.Character or Config.Player.CharacterAdded:Wait())
        else
            ToggleBtn.Text = "🔴 FARM: OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            StatusLabel.Text = "Status: Idle"
            if Config.Humanoid then Config.Humanoid.AutoRotate = true; Config.Humanoid:MoveTo(Config.RootPart.Position) end
            if Config.Modules.Visuals then Config.Modules.Visuals.HideAllTrajectoryLines() end
        end
        Config.SaveSettings()
    end)

    Config.Player.CharacterAdded:Connect(Config.UpdateCharacter)
    if Config.Player.Character then Config.UpdateCharacter(Config.Player.Character) end

    GUI.RefreshUI()

    if S.Farming.AutoStartFarm then
        S.Farming.AutoStartFarm = false; Config.SaveSettings()
        task.spawn(function()
            local char = Config.Player.Character or Config.Player.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart", 10); task.wait(3.5)
            if not Config.Farm.Enabled then
                Config.Farm.Enabled = true
                ToggleBtn.Text = "🟢 FARM: ON"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                Config.Farm.LockedTarget = nil; Config.Farm.Status = "Idle"; Config.Farm.StartTime = tick()
                Config.Farm.TotalCollected = 0; Config.Farm.LastStatUpdate = tick(); S.Webhook.LastTime = tick()
                TimeLabel.Text = "Time Active: 00:00:00"; EstLabel.Text = "Est. Hearts/Hr: 0"
                Config.UpdateCharacter(char)
            end
        end)
    end
end

return GUI
