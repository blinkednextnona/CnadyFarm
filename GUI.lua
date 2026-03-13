-- ============================================
-- GUI.lua - Heart Zone V18 using CleanUI Library
-- ============================================
local GUI = {}
local Config = nil
local Library = nil
local Notify = nil
 
-- Element references for external updates
local StatusLabel, TimeLabel, EstLabel
 
function GUI.GetScreenGui()    return Library and Library.ScreenGui end
function GUI.GetStatusLabel()  return StatusLabel end
function GUI.GetTimeLabel()    return TimeLabel end
function GUI.GetEstLabel()     return EstLabel end
function GUI.GetColorBtn()     return nil end -- not needed with new UI
function GUI.GetColorTitle()   return nil end
function GUI.GetToggleBtn()    return nil end
function GUI.RefreshUI()       end -- handled by CleanUI toggles internally
 
function GUI.Init(cfg)
    Config = cfg
    local S = Config.Settings
 
    -- Set config on sub-modules
    if Config.Modules.LagFixer    then Config.Modules.LagFixer.SetConfig(Config)    end
    if Config.Modules.Webhook     then Config.Modules.Webhook.SetConfig(Config)     end
    if Config.Modules.Visuals     then Config.Modules.Visuals.SetConfig(Config)     end
    if Config.Modules.Pathfinding then Config.Modules.Pathfinding.SetConfig(Config) end
 
    -- Load the CleanUI library from GitHub
    local BASE_URL = "https://raw.githubusercontent.com/blinkednextnona/CnadyFarm/main/"
    local uiCode = game:HttpGet(BASE_URL .. "CleanUI.lua")
    Library = loadstring(uiCode)()
    Notify = Library.Notify
 
    -- ==================
    -- STATUS BAR (custom labels at bottom of sidebar area)
    -- We'll use labels in the Home tab for status
    -- ==================
 
    -- ══════════════════
    -- HOME TAB
    -- ══════════════════
    local HomeTab = Library:AddTab("Home", "💖")
 
    HomeTab:AddSection("Farm Control")
 
    -- Farm toggle
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
 
    -- Farm mode
    HomeTab:AddButton("Mode: " .. Config.Farm.CurrentMode .. " (click to toggle)", function()
        Config.Farm.CurrentMode = (Config.Farm.CurrentMode == "Closest") and "Highest" or "Closest"
        if Config.Farm.Enabled then Config.Farm.LockedTarget = nil; Config.Farm.PathGenerated = false end
        Notify("Mode", "Switched to: " .. Config.Farm.CurrentMode, 2)
        Config.SaveSettings()
    end)
 
    HomeTab:AddSeparator()
    HomeTab:AddSection("Live Stats")
    StatusLabel = HomeTab:AddLabel("Status: Idle")
    TimeLabel = HomeTab:AddLabel("Time: 00:00:00")
    EstLabel = HomeTab:AddLabel("Est. Hearts/Hr: 0")
 
    -- ══════════════════
    -- SAFETY TAB
    -- ══════════════════
    local SafetyTab = Library:AddTab("Safety", "🛡️")
 
    SafetyTab:AddSection("Flee Settings")
 
    SafetyTab:AddSlider("Safety Radius", 5, 100, S.Farming.SafetyRadius, function(val)
        S.Farming.SafetyRadius = val
        S.Farming.ResumeRadius = val + 5
        Config.SaveSettings()
    end)
 
    -- Flee mode cycle button
    local fleeModeBtn
    fleeModeBtn = SafetyTab:AddButton("Flee Mode: " .. S.Farming.FleeMode, function()
        if S.Farming.FleeMode == "Armed" then S.Farming.FleeMode = "All"
        elseif S.Farming.FleeMode == "All" then S.Farming.FleeMode = "Off"
        else S.Farming.FleeMode = "Armed" end
        fleeModeBtn.Text = "Flee Mode: " .. S.Farming.FleeMode
        Config.SaveSettings()
    end)
 
    SafetyTab:AddSeparator()
    SafetyTab:AddSection("Protection")
 
    SafetyTab:AddToggle("Anti-Admin", S.Farming.AntiAdmin, function(state)
        S.Farming.AntiAdmin = state
        Config.SaveSettings()
        Notify("Anti-Admin", state and "Protection ON" or "Protection OFF", 2, state and "success" or "warning")
    end)
 
    SafetyTab:AddToggle("TP Protection (Flee)", S.Movement.TPProtection, function(state)
        S.Movement.TPProtection = state
        Config.SaveSettings()
    end)
 
    SafetyTab:AddToggle("Anti-AFK", S.Movement.AntiAFK, function(state)
        S.Movement.AntiAFK = state
        Config.SaveSettings()
    end)
 
    -- ══════════════════
    -- MOVEMENT TAB
    -- ══════════════════
    local MoveTab = Library:AddTab("Movement", "🏃")
 
    MoveTab:AddSection("Speed")
 
    MoveTab:AddSlider("Walk Speed", 10, 100, S.Movement.WalkSpeed, function(val)
        S.Movement.WalkSpeed = val
        Config.SaveSettings()
    end)
 
    MoveTab:AddSeparator()
    MoveTab:AddSection("Teleport")
 
    MoveTab:AddToggle("Cheat TP (near target)", S.Movement.CheatTP, function(state)
        S.Movement.CheatTP = state
        Config.SaveSettings()
    end)
 
    -- ══════════════════
    -- VISUALS TAB
    -- ══════════════════
    local VisTab = Library:AddTab("Visuals", "🎨")
 
    VisTab:AddSection("Performance")
 
    VisTab:AddToggle("Lag Fixer", S.Farming.LagFixer, function(state)
        S.Farming.LagFixer = state
        if Config.Modules.LagFixer then Config.Modules.LagFixer.Toggle(state) end
        Config.SaveSettings()
        Notify("Lag Fixer", state and "Textures hidden for FPS" or "Textures restored", 2, state and "success" or "warning")
    end)
 
    VisTab:AddSeparator()
    VisTab:AddSection("Path Color Mode")
 
    VisTab:AddButton("Static Color (default)", function()
        S.Visuals.ColorMode = "Static"
        Config.SaveSettings()
        Notify("Color", "Static mode", 1.5)
    end)
 
    VisTab:AddButton("Rainbow Mode", function()
        S.Visuals.ColorMode = "Rainbow"
        Config.SaveSettings()
        Notify("Color", "Rainbow mode", 1.5, "success")
    end)
 
    VisTab:AddButton("Strobe Black/White", function()
        S.Visuals.ColorMode = "StrobeBW"
        Config.SaveSettings()
        Notify("Color", "Strobe mode", 1.5)
    end)
 
    VisTab:AddSlider("Color Speed", 1, 10, math.floor(S.Visuals.ColorSpeed), function(val)
        S.Visuals.ColorSpeed = val
        Config.SaveSettings()
    end)
 
    VisTab:AddToggle("Color Fade (smooth)", S.Visuals.ColorFade, function(state)
        S.Visuals.ColorFade = state
        Config.SaveSettings()
    end)
 
    -- ══════════════════
    -- WEBHOOK TAB
    -- ══════════════════
    local WebTab = Library:AddTab("Webhook", "📡")
 
    WebTab:AddSection("Discord Webhook")
 
    local whBox = WebTab:AddTextbox("URL", S.Webhook.URL ~= "" and S.Webhook.URL or "", function(text)
        S.Webhook.URL = text
        Config.SaveSettings()
    end)
 
    WebTab:AddToggle("Enable Webhook", S.Webhook.Enabled, function(state)
        S.Webhook.Enabled = state
        Config.SaveSettings()
        Notify("Webhook", state and "Webhook ON" or "Webhook OFF", 2, state and "success" or "warning")
    end)
 
    WebTab:AddSlider("Interval", 1, 60, S.Webhook.Interval, function(val)
        S.Webhook.Interval = val
        Config.SaveSettings()
    end)
 
    -- Unit cycle button
    local unitBtn
    unitBtn = WebTab:AddButton("Unit: " .. S.Webhook.Unit, function()
        if S.Webhook.Unit == "Seconds" then S.Webhook.Unit = "Minutes"
        elseif S.Webhook.Unit == "Minutes" then S.Webhook.Unit = "Hours"
        else S.Webhook.Unit = "Seconds" end
        unitBtn.Text = "Unit: " .. S.Webhook.Unit
        Config.SaveSettings()
    end)
 
    WebTab:AddSeparator()
    WebTab:AddButton("Send Test Webhook", function()
        if Config.Modules.Webhook then
            Config.Modules.Webhook.Send(false)
            Notify("Webhook", "Test sent!", 2, "success")
        end
    end)
 
    -- ══════════════════
    -- ZONE TAB
    -- ══════════════════
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
 
    -- ══════════════════
    -- EXTRA TAB
    -- ══════════════════
    local ExtraTab = Library:AddTab("Extra", "⚡")
 
    ExtraTab:AddSection("Extras")
 
    ExtraTab:AddToggle("Loop Buy Case 26", S.Extra.LoopBuyCase26, function(state)
        S.Extra.LoopBuyCase26 = state
        Config.SaveSettings()
        Notify("Case 26", state and "Auto-buying ON" or "Auto-buying OFF", 2, state and "success" or "warning")
    end)
 
    ExtraTab:AddSeparator()
    ExtraTab:AddSection("UI")
 
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
 
    -- ══════════════════
    -- CHARACTER RESPAWN
    -- ══════════════════
    Config.Player.CharacterAdded:Connect(Config.UpdateCharacter)
    if Config.Player.Character then Config.UpdateCharacter(Config.Player.Character) end
 
    -- AUTO START
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
 
    -- STARTUP NOTIFICATION
    task.wait(0.5)
    Notify("💖 Heart Zone V18", "Loaded! Press RightShift to toggle UI.", 4, "success")
end
 
return GUI
 
