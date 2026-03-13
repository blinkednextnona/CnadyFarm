-- ============================================
-- GUI.lua - Heart Zone V18 using CleanUI Library
-- ALL settings restored + color picker + slots
-- ============================================
local GUI = {}
local Config = nil
local Library = nil
local Notify = nil
 
local StatusLabel, TimeLabel, EstLabel
 
function GUI.GetScreenGui()    return Library and Library.ScreenGui end
function GUI.GetStatusLabel()  return StatusLabel end
function GUI.GetTimeLabel()    return TimeLabel end
function GUI.GetEstLabel()     return EstLabel end
function GUI.GetColorBtn()     return nil end
function GUI.GetColorTitle()   return nil end
function GUI.GetToggleBtn()    return nil end
function GUI.RefreshUI()       end
 
function GUI.Init(cfg)
    Config = cfg
    local S = Config.Settings
 
    -- Set config on sub-modules
    if Config.Modules.LagFixer    then Config.Modules.LagFixer.SetConfig(Config)    end
    if Config.Modules.Webhook     then Config.Modules.Webhook.SetConfig(Config)     end
    if Config.Modules.Visuals     then Config.Modules.Visuals.SetConfig(Config)     end
    if Config.Modules.Pathfinding then Config.Modules.Pathfinding.SetConfig(Config) end
 
    -- Load CleanUI library
    local BASE_URL = "https://raw.githubusercontent.com/blinkednextnona/CnadyFarm/main/"
    local uiCode = game:HttpGet(BASE_URL .. "CleanUI.lua")
    Library = loadstring(uiCode)()
    Notify = Library.Notify
 
    -- ══════════════════════════════════════
    -- HOME TAB - Farm control + live stats
    -- ══════════════════════════════════════
    local HomeTab = Library:AddTab("Home", "")
 
    HomeTab:AddSection("Farm Control")
 
    local FarmToggle = HomeTab:AddToggle("Auto Farm", Config.Farm.Enabled, function(state)
        Config.Farm.Enabled = state
        if state then
            Config.Farm.StartTime = tick()
            Config.Farm.LockedTarget = nil
            Config.Farm.Status = "Idle"
            Config.Farm.TotalCollected = 0
            Config.Farm.LastStatUpdate = tick()
            S.Webhook.LastTime = tick()
            if StatusLabel then StatusLabel.Text = "Status: Farming" end
            if TimeLabel then TimeLabel.Text = "Time: 00:00:00" end
            if EstLabel then EstLabel.Text = "Est. Hearts/Hr: 0" end
            Config.UpdateCharacter(Config.Player.Character or Config.Player.CharacterAdded:Wait())
            Notify("Farm", "Auto Farm enabled", 2, "success")
        else
            Config.Farm.Status = "Idle"
            if StatusLabel then StatusLabel.Text = "Status: Idle" end
            if Config.Humanoid then
                Config.Humanoid.AutoRotate = true
                Config.Humanoid:MoveTo(Config.RootPart.Position)
            end
            if Config.Modules.Visuals then Config.Modules.Visuals.HideAllTrajectoryLines() end
            Notify("Farm", "Auto Farm disabled", 2, "error")
        end
        Config.SaveSettings()
    end)
 
    HomeTab:AddSeparator()
    HomeTab:AddSection("Live Stats")
    StatusLabel = HomeTab:AddLabel("Status: Idle")
    TimeLabel = HomeTab:AddLabel("Time: 00:00:00")
    EstLabel = HomeTab:AddLabel("Est. Hearts/Hr: 0")
 
    -- ══════════════════════════════════════
    -- FARM TAB - farming-specific settings
    -- ══════════════════════════════════════
    local FarmTab = Library:AddTab("Farm", "")
 
    FarmTab:AddSection("Target Mode")
 
    -- Mode toggle that updates its own text
    local modeToggle = FarmTab:AddToggle("Highest Value Mode", Config.Farm.CurrentMode == "Highest", function(state)
        Config.Farm.CurrentMode = state and "Highest" or "Closest"
        if Config.Farm.Enabled then Config.Farm.LockedTarget = nil; Config.Farm.PathGenerated = false end
        Notify("Mode", "Now: " .. Config.Farm.CurrentMode, 2)
        Config.SaveSettings()
    end)
 
    FarmTab:AddLabel("OFF = Closest heart  |  ON = Highest value heart")
 
    FarmTab:AddSeparator()
    FarmTab:AddSection("Collection")
 
    FarmTab:AddSlider("Collect Distance", 1, 10, S.Farming.CollectDistance, function(val)
        S.Farming.CollectDistance = val
        Config.SaveSettings()
    end)
 
    FarmTab:AddSeparator()
    FarmTab:AddSection("Performance")
 
    FarmTab:AddToggle("Lag Fixer", S.Farming.LagFixer, function(state)
        S.Farming.LagFixer = state
        if Config.Modules.LagFixer then Config.Modules.LagFixer.Toggle(state) end
        Config.SaveSettings()
        Notify("Lag Fixer", state and "Textures hidden" or "Textures restored", 2, state and "success" or "warning")
    end)
 
    -- ══════════════════════════════════════
    -- SAFETY TAB - flee, anti-admin, protection
    -- ══════════════════════════════════════
    local SafetyTab = Library:AddTab("Safety", "")
 
    SafetyTab:AddSection("Flee Settings")
 
    SafetyTab:AddSlider("Safety Radius", 5, 100, S.Farming.SafetyRadius, function(val)
        S.Farming.SafetyRadius = val
        S.Farming.ResumeRadius = val + 5
        Config.SaveSettings()
    end)
 
    -- Flee mode cycle
    local fleeModeLabel = SafetyTab:AddLabel("Current Flee Mode: " .. S.Farming.FleeMode)
    SafetyTab:AddButton("Cycle Flee Mode (Armed → All → Off)", function()
        if S.Farming.FleeMode == "Armed" then S.Farming.FleeMode = "All"
        elseif S.Farming.FleeMode == "All" then S.Farming.FleeMode = "Off"
        else S.Farming.FleeMode = "Armed" end
        fleeModeLabel.Text = "Current Flee Mode: " .. S.Farming.FleeMode
        Config.SaveSettings()
        Notify("Flee", "Mode: " .. S.Farming.FleeMode, 1.5)
    end)
 
    SafetyTab:AddSeparator()
    SafetyTab:AddSection("Protection")
 
    SafetyTab:AddToggle("Anti-Admin", S.Farming.AntiAdmin, function(state)
        S.Farming.AntiAdmin = state
        Config.SaveSettings()
        Notify("Anti-Admin", state and "ON" or "OFF", 2, state and "success" or "warning")
    end)
 
    SafetyTab:AddToggle("TP Protection (Flee)", S.Movement.TPProtection, function(state)
        S.Movement.TPProtection = state
        Config.SaveSettings()
    end)
 
    SafetyTab:AddToggle("Anti-AFK", S.Movement.AntiAFK, function(state)
        S.Movement.AntiAFK = state
        Config.SaveSettings()
    end)
 
    -- ══════════════════════════════════════
    -- MOVEMENT TAB - speed, teleport
    -- ══════════════════════════════════════
    local MoveTab = Library:AddTab("Movement", "")
 
    MoveTab:AddSection("Speed")
 
    MoveTab:AddSlider("Walk Speed", 10, 100, S.Movement.WalkSpeed, function(val)
        S.Movement.WalkSpeed = val
        Config.SaveSettings()
    end)
 
    MoveTab:AddSlider("Stuck Threshold", 1, 10, S.Movement.StuckThreshold, function(val)
        S.Movement.StuckThreshold = val
        Config.SaveSettings()
    end)
 
    MoveTab:AddSeparator()
    MoveTab:AddSection("Teleport")
 
    MoveTab:AddToggle("Cheat TP (near target)", S.Movement.CheatTP, function(state)
        S.Movement.CheatTP = state
        Config.SaveSettings()
    end)
 
    -- ══════════════════════════════════════
    -- VISUALS TAB - color picker, modes, slots
    -- ══════════════════════════════════════
    local VisTab = Library:AddTab("Visuals", "")
 
    VisTab:AddSection("Path Color")
 
    -- Color picker wheel
    local colorPicker = VisTab:AddColorPicker("Static Color", S.Visuals.PathColor, function(c)
        S.Visuals.PathColor = c
        S.Visuals.ColorMode = "Static"
        Config.SaveSettings()
    end)
 
    VisTab:AddSeparator()
    VisTab:AddSection("Color Animation Mode")
 
    -- Current mode label
    local colorModeLabel = VisTab:AddLabel("Current Mode: " .. S.Visuals.ColorMode)
 
    VisTab:AddButton("Static (use wheel color)", function()
        S.Visuals.ColorMode = "Static"; colorModeLabel.Text = "Current Mode: Static"
        Config.SaveSettings(); Notify("Color", "Static mode", 1.5)
    end)
 
    VisTab:AddButton("Rainbow", function()
        S.Visuals.ColorMode = "Rainbow"; colorModeLabel.Text = "Current Mode: Rainbow"
        Config.SaveSettings(); Notify("Color", "Rainbow mode", 1.5, "success")
    end)
 
    VisTab:AddButton("Strobe Black/White", function()
        S.Visuals.ColorMode = "StrobeBW"; colorModeLabel.Text = "Current Mode: StrobeBW"
        Config.SaveSettings(); Notify("Color", "Strobe mode", 1.5)
    end)
 
    VisTab:AddButton("Play Custom Cycle (use slots below)", function()
        if #S.Visuals.CustomColors < 1 then
            Notify("Color", "Add colors to slots first!", 2, "error")
            return
        end
        S.Visuals.ColorMode = "Custom"; colorModeLabel.Text = "Current Mode: Custom"
        Config.SaveSettings(); Notify("Color", "Custom cycle active", 1.5, "success")
    end)
 
    VisTab:AddSeparator()
    VisTab:AddSection("Animation Settings")
 
    VisTab:AddSlider("Color Speed", 1, 10, math.floor(S.Visuals.ColorSpeed), function(val)
        S.Visuals.ColorSpeed = val
        Config.SaveSettings()
    end)
 
    VisTab:AddToggle("Smooth Fade", S.Visuals.ColorFade, function(state)
        S.Visuals.ColorFade = state
        Config.SaveSettings()
    end)
 
    VisTab:AddSeparator()
    VisTab:AddSection("Custom Color Cycle Slots")
 
    -- Color slots (10 slots, click to save current path color)
    local colorSlots = VisTab:AddColorSlots(
        10,
        S.Visuals.CustomColors,
        function() return S.Visuals.PathColor end, -- getCurrentColor
        function(idx, color, allColors) -- onSave
            S.Visuals.CustomColors = allColors
            Config.SaveSettings()
            Notify("Slot " .. idx, "Color saved", 1, "success")
        end,
        function() -- onClear
            S.Visuals.CustomColors = {}
            Config.SaveSettings()
            Notify("Slots", "All cleared", 1.5, "warning")
        end
    )
    colorSlots:Refresh(S.Visuals.CustomColors)
 
    -- ══════════════════════════════════════
    -- WEBHOOK TAB
    -- ══════════════════════════════════════
    local WebTab = Library:AddTab("DC Webhook", "")
 
    WebTab:AddSection("Discord Webhook")
 
    WebTab:AddTextbox("URL", S.Webhook.URL ~= "" and S.Webhook.URL or "", function(text)
        S.Webhook.URL = text
        Config.SaveSettings()
    end)
 
    WebTab:AddToggle("Enable Webhook", S.Webhook.Enabled, function(state)
        S.Webhook.Enabled = state
        Config.SaveSettings()
        Notify("Webhook", state and "ON" or "OFF", 2, state and "success" or "warning")
    end)
 
    WebTab:AddSlider("Interval", 1, 60, S.Webhook.Interval, function(val)
        S.Webhook.Interval = val
        Config.SaveSettings()
    end)
 
    local unitLabel = WebTab:AddLabel("Unit: " .. S.Webhook.Unit)
    WebTab:AddButton("Cycle Unit (Sec → Min → Hr)", function()
        if S.Webhook.Unit == "Seconds" then S.Webhook.Unit = "Minutes"
        elseif S.Webhook.Unit == "Minutes" then S.Webhook.Unit = "Hours"
        else S.Webhook.Unit = "Seconds" end
        unitLabel.Text = "Unit: " .. S.Webhook.Unit
        Config.SaveSettings()
    end)
 
    WebTab:AddSeparator()
    WebTab:AddButton("Send Test Webhook", function()
        if Config.Modules.Webhook then
            Config.Modules.Webhook.Send(false)
            Notify("Webhook", "Test sent!", 2, "success")
        end
    end)
 
    -- ══════════════════════════════════════
    -- ZONE TAB
    -- ══════════════════════════════════════
    local ZoneTab = Library:AddTab("Zone", "📍")
 
    ZoneTab:AddSection("Farm Zone Restriction")
    ZoneTab:AddLabel("Set two corners to restrict farming area.")
 
    local p1Label = ZoneTab:AddLabel("Pos 1: Not set")
    local p2Label = ZoneTab:AddLabel("Pos 2: Not set")
 
    ZoneTab:AddAccentButton("Set Pos 1 (current position)", function()
        Config.Zone.Pos1 = Config.RootPart.Position
        p1Label.Text = "Pos 1: SET ✓"
        if Config.Modules.Visuals then Config.Modules.Visuals.DrawZone() end
        Notify("Zone", "Position 1 set", 1.5, "success")
    end)
 
    ZoneTab:AddAccentButton("Set Pos 2 (current position)", function()
        Config.Zone.Pos2 = Config.RootPart.Position
        p2Label.Text = "Pos 2: SET ✓"
        if Config.Zone.Pos1 then
            Config.Zone.Active = true
            if Config.Modules.Visuals then Config.Modules.Visuals.DrawZone() end
        end
        Notify("Zone", "Position 2 set", 1.5, "success")
    end)
 
    ZoneTab:AddSeparator()
    ZoneTab:AddButton("Reset Zone", function()
        Config.Zone.Pos1 = nil; Config.Zone.Pos2 = nil; Config.Zone.Active = false
        p1Label.Text = "Pos 1: Not set"; p2Label.Text = "Pos 2: Not set"
        if Config.Modules.Visuals then Config.Modules.Visuals.ZoneFolder:ClearAllChildren() end
        Notify("Zone", "Zone cleared", 1.5, "warning")
    end)
 
    -- ══════════════════════════════════════
    -- EXTRA TAB
    -- ══════════════════════════════════════
    local ExtraTab = Library:AddTab("Extra", "")
 
    ExtraTab:AddSection("Extras")
 
    ExtraTab:AddToggle("Loop Buy Case 26", S.Extra.LoopBuyCase26, function(state)
        S.Extra.LoopBuyCase26 = state
        Config.SaveSettings()
        Notify("Case 26", state and "Auto-buying ON" or "Auto-buying OFF", 2, state and "success" or "warning")
    end)
 
    ExtraTab:AddToggle("Auto Start Farm (next join)", false, function(state)
        S.Farming.AutoStartFarm = state
        Config.SaveSettings()
        Notify("Auto Start", state and "Will auto-farm next join" or "Disabled", 2, state and "success" or "warning")
    end)
 
    ExtraTab:AddSeparator()
    ExtraTab:AddSection("UI Controls")
 
    ExtraTab:AddButton("Reset UI Position", function()
        Library.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Notify("UI", "Position reset", 1.5)
    end)
 
    ExtraTab:AddButton("Destroy UI", function()
        Config.SaveSettings()
        if Config.Modules.Visuals then Config.Modules.Visuals.Cleanup() end
        if Config.Modules.LagFixer and S.Farming.LagFixer then Config.Modules.LagFixer.Toggle(false) end
        Library.Destroy()
    end)
 
    ExtraTab:AddSeparator()
    ExtraTab:AddLabel("Toggle UI: RightShift")
    ExtraTab:AddLabel("Drag the top bar to move.")
 
    -- ══════════════════════════════════════
    -- CHARACTER + AUTO START
    -- ══════════════════════════════════════
    Config.Player.CharacterAdded:Connect(Config.UpdateCharacter)
    if Config.Player.Character then Config.UpdateCharacter(Config.Player.Character) end
 
    if S.Farming.AutoStartFarm then
        S.Farming.AutoStartFarm = false; Config.SaveSettings()
        task.spawn(function()
            local char = Config.Player.Character or Config.Player.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart", 10); task.wait(3.5)
            if not Config.Farm.Enabled then
                Config.Farm.Enabled = true
                Config.Farm.LockedTarget = nil; Config.Farm.Status = "Idle"
                Config.Farm.StartTime = tick(); Config.Farm.TotalCollected = 0
                Config.Farm.LastStatUpdate = tick(); S.Webhook.LastTime = tick()
                if StatusLabel then StatusLabel.Text = "Status: Farming" end
                if TimeLabel then TimeLabel.Text = "Time: 00:00:00" end
                if EstLabel then EstLabel.Text = "Est. Hearts/Hr: 0" end
                Config.UpdateCharacter(char)
                FarmToggle:Set(true)
            end
        end)
    end
 
    task.wait(0.5)
    Notify("Heart Farm V18", "Loaded! Press RightShift to toggle UI.", 4, "success")
end
 
return GUI
