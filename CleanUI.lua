--[[
    CLEAN UI LIBRARY v1.0
    Ultra-minimal Roblox Script Hub
    Loaded as a module for CandyZone V18
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ═══════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════
local CONFIG = {
    Background        = Color3.fromRGB(15, 15, 20),
    BackgroundSecond  = Color3.fromRGB(20, 20, 28),
    Surface           = Color3.fromRGB(25, 25, 35),
    SurfaceHover      = Color3.fromRGB(32, 32, 45),
    Border            = Color3.fromRGB(40, 40, 55),
    Accent            = Color3.fromRGB(255, 105, 180), -- Pink to match heart theme
    AccentHover       = Color3.fromRGB(255, 130, 200),
    AccentDim         = Color3.fromRGB(255, 105, 180),
    TextPrimary       = Color3.fromRGB(235, 235, 245),
    TextSecondary     = Color3.fromRGB(145, 145, 165),
    TextMuted         = Color3.fromRGB(90, 90, 110),
    Success           = Color3.fromRGB(72, 199, 142),
    Warning           = Color3.fromRGB(250, 176, 67),
    Error             = Color3.fromRGB(237, 95, 95),
    WindowWidth       = 520,
    WindowHeight      = 380,
    CornerRadius      = UDim.new(0, 10),
    SmallRadius       = UDim.new(0, 6),
    TweenSpeed        = 0.3,
    TweenEase         = Enum.EasingStyle.Quint,
    Font              = Enum.Font.GothamBold,
    FontMedium        = Enum.Font.GothamMedium,
    FontRegular       = Enum.Font.Gotham,
    ToggleKey         = Enum.KeyCode.RightShift,
    Title             = "Heart Farm V18",
    Subtitle          = "Made By CozzyBruh",
}

-- ═══════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════
local function Tween(object, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or CONFIG.TweenSpeed,
        style or CONFIG.TweenEase,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, props)
    tween:Play()
    return tween
end

local function CreateInstance(className, properties, children)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function AddCorner(parent, radius)
    return CreateInstance("UICorner", { CornerRadius = radius or CONFIG.CornerRadius, Parent = parent })
end

local function AddStroke(parent, color, thickness)
    return CreateInstance("UIStroke", { Color = color or CONFIG.Border, Thickness = thickness or 1, Transparency = 0.5, Parent = parent })
end

local function AddPadding(parent, t, b, l, r)
    return CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, t or 8), PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft = UDim.new(0, l or 8), PaddingRight = UDim.new(0, r or 8),
        Parent = parent
    })
end

-- ═══════════════════════════════════════
-- CORE GUI
-- ═══════════════════════════════════════
local ScreenGui = CreateInstance("ScreenGui", {
    Name = "CleanUI_HeartZone",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = game:GetService("CoreGui")
})

local Shadow = CreateInstance("ImageLabel", {
    Name = "Shadow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, CONFIG.WindowWidth + 40, 0, CONFIG.WindowHeight + 40),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.4,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    Parent = ScreenGui
})

local MainFrame = CreateInstance("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight),
    BackgroundColor3 = CONFIG.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenGui
})
AddCorner(MainFrame)
AddStroke(MainFrame, CONFIG.Border, 1)

-- ═══════════════════════════════════════
-- DRAGGING
-- ═══════════════════════════════════════
local Dragging, DragInput, DragStart, StartPos

local function DragUpdate(input)
    local delta = input.Position - DragStart
    local targetPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    Tween(MainFrame, {Position = targetPos}, 0.08, Enum.EasingStyle.Quart)
    Shadow.Position = targetPos
end

-- ═══════════════════════════════════════
-- TOP BAR
-- ═══════════════════════════════════════
local TopBar = CreateInstance("Frame", {
    Name = "TopBar", Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = CONFIG.Background, BorderSizePixel = 0, Parent = MainFrame
})

CreateInstance("Frame", {
    Name = "AccentLine", Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, Parent = TopBar
})

local TitleLabel = CreateInstance("TextLabel", {
    Position = UDim2.new(0, 16, 0, 2), Size = UDim2.new(0, 200, 1, -2),
    BackgroundTransparency = 1, Text = CONFIG.Title,
    TextColor3 = CONFIG.TextPrimary, TextSize = 14, Font = CONFIG.Font,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar
})

CreateInstance("TextLabel", {
    Position = UDim2.new(0, 180, 0, 2), Size = UDim2.new(0, 60, 1, -2),
    BackgroundTransparency = 1, Text = CONFIG.Subtitle,
    TextColor3 = CONFIG.TextMuted, TextSize = 11, Font = CONFIG.FontRegular,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar
})

local CloseBtn = CreateInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 1),
    Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 1,
    Text = "✕", TextColor3 = CONFIG.TextSecondary, TextSize = 14, Font = CONFIG.Font,
    BackgroundColor3 = CONFIG.Surface, Parent = TopBar
})
AddCorner(CloseBtn, CONFIG.SmallRadius)

local MinBtn = CreateInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -42, 0.5, 1),
    Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 1,
    Text = "─", TextColor3 = CONFIG.TextSecondary, TextSize = 14, Font = CONFIG.Font,
    BackgroundColor3 = CONFIG.Surface, Parent = TopBar
})
AddCorner(MinBtn, CONFIG.SmallRadius)

for _, btn in pairs({CloseBtn, MinBtn}) do
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.5, TextColor3 = CONFIG.TextPrimary}, 0.15) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 1, TextColor3 = CONFIG.TextSecondary}, 0.15) end)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true; DragStart = input.Position; StartPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then DragUpdate(input) end end)

CreateInstance("Frame", {
    Name = "Divider", Position = UDim2.new(0, 0, 0, 44), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = CONFIG.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = MainFrame
})

-- ═══════════════════════════════════════
-- SIDEBAR
-- ═══════════════════════════════════════
local Sidebar = CreateInstance("Frame", {
    Name = "Sidebar", Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(0, 130, 1, -45),
    BackgroundColor3 = CONFIG.BackgroundSecond, BorderSizePixel = 0, Parent = MainFrame
})
CreateInstance("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = Sidebar })
AddPadding(Sidebar, 8, 8, 6, 6)
CreateInstance("Frame", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = CONFIG.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = Sidebar
})

-- ═══════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════
local ContentArea = CreateInstance("Frame", {
    Name = "ContentArea", Position = UDim2.new(0, 131, 0, 45), Size = UDim2.new(1, -131, 1, -45),
    BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, Parent = MainFrame
})

-- ═══════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════
local NotifHolder = CreateInstance("Frame", {
    Name = "Notifications", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.new(0, 250, 0, 300), BackgroundTransparency = 1, Parent = ScreenGui
})
CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6),
    VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Parent = NotifHolder
})

local function Notify(title, message, duration, notifType)
    local accentColor = CONFIG.Accent
    if notifType == "success" then accentColor = CONFIG.Success
    elseif notifType == "warning" then accentColor = CONFIG.Warning
    elseif notifType == "error" then accentColor = CONFIG.Error end

    local Notif = CreateInstance("Frame", {
        Size = UDim2.new(0, 250, 0, 0), BackgroundColor3 = CONFIG.Surface,
        BorderSizePixel = 0, ClipsDescendants = true, Parent = NotifHolder
    })
    AddCorner(Notif, CONFIG.SmallRadius)
    AddStroke(Notif, CONFIG.Border, 1)
    CreateInstance("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = accentColor, BorderSizePixel = 0, Parent = Notif })
    CreateInstance("TextLabel", {
        Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -24, 0, 16), BackgroundTransparency = 1,
        Text = title or "Notification", TextColor3 = CONFIG.TextPrimary, TextSize = 12, Font = CONFIG.Font,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Notif
    })
    CreateInstance("TextLabel", {
        Position = UDim2.new(0, 14, 0, 28), Size = UDim2.new(1, -24, 0, 28), BackgroundTransparency = 1,
        Text = message or "", TextColor3 = CONFIG.TextSecondary, TextSize = 11, Font = CONFIG.FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = Notif
    })

    Tween(Notif, {Size = UDim2.new(0, 250, 0, 64)}, 0.35)
    task.delay(duration or 3, function()
        Tween(Notif, {Size = UDim2.new(0, 250, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.wait(0.35); Notif:Destroy()
    end)
end

-- ═══════════════════════════════════════
-- LIBRARY API
-- ═══════════════════════════════════════
local Library = {}
Library.__index = Library
Library.ScreenGui = ScreenGui
Library.MainFrame = MainFrame
Library.Notify = Notify
Library.CONFIG = CONFIG

local Tabs = {}
local ActiveTab = nil
local TabButtonsList = {}
local TabPagesList = {}

function Library:AddTab(name, icon)
    local tabIndex = #Tabs + 1

    local TabBtn = CreateInstance("TextButton", {
        Name = name, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", LayoutOrder = tabIndex, Parent = Sidebar
    })
    AddCorner(TabBtn, CONFIG.SmallRadius)

    CreateInstance("TextLabel", {
        Name = "TabIcon", Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1, Text = icon or "•", TextColor3 = CONFIG.TextMuted,
        TextSize = 14, Font = CONFIG.FontRegular, Parent = TabBtn
    })

    local TabName = CreateInstance("TextLabel", {
        Name = "TabName", Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1, Text = name, TextColor3 = CONFIG.TextSecondary,
        TextSize = 12, Font = CONFIG.FontMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabBtn
    })

    local TabPage = CreateInstance("ScrollingFrame", {
        Name = name .. "Page", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Accent,
        ScrollBarImageTransparency = 0.5, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = ContentArea
    })
    CreateInstance("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = TabPage })
    AddPadding(TabPage, 10, 10, 14, 14)

    TabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= tabIndex then
            Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.15)
            Tween(TabName, {TextColor3 = CONFIG.TextPrimary}, 0.15)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= tabIndex then
            Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            Tween(TabName, {TextColor3 = CONFIG.TextSecondary}, 0.15)
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab == tabIndex then return end
        if ActiveTab then
            local oldBtn = TabButtonsList[ActiveTab]
            Tween(oldBtn, {BackgroundTransparency = 1}, 0.2)
            for _, child in pairs(oldBtn:GetChildren()) do
                if child:IsA("TextLabel") then
                    Tween(child, {TextColor3 = child.Name == "TabIcon" and CONFIG.TextMuted or CONFIG.TextSecondary}, 0.2)
                end
            end
            TabPagesList[ActiveTab].Visible = false
        end
        ActiveTab = tabIndex
        Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.2)
        for _, child in pairs(TabBtn:GetChildren()) do
            if child:IsA("TextLabel") then Tween(child, {TextColor3 = CONFIG.TextPrimary}, 0.2) end
        end
        TabPage.Visible = true
    end)

    TabButtonsList[tabIndex] = TabBtn
    TabPagesList[tabIndex] = TabPage
    table.insert(Tabs, name)

    if tabIndex == 1 then
        ActiveTab = 1; TabBtn.BackgroundTransparency = 0.85
        for _, child in pairs(TabBtn:GetChildren()) do
            if child:IsA("TextLabel") then child.TextColor3 = CONFIG.TextPrimary end
        end
        TabPage.Visible = true
    end

    local Tab = {}
    Tab.Page = TabPage

    function Tab:AddSection(text)
        return CreateInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = string.upper(text),
            TextColor3 = CONFIG.TextMuted, TextSize = 10, Font = CONFIG.Font,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
    end

    function Tab:AddToggle(text, default, callback)
        callback = callback or function() end
        local toggled = default or false

        local ToggleFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0, LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(ToggleFrame, CONFIG.SmallRadius)

        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1,
            Text = text, TextColor3 = CONFIG.TextPrimary, TextSize = 12, Font = CONFIG.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleFrame
        })

        local SwitchTrack = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 36, 0, 20), BackgroundColor3 = toggled and CONFIG.Accent or CONFIG.Border,
            BorderSizePixel = 0, Parent = ToggleFrame
        })
        AddCorner(SwitchTrack, UDim.new(1, 0))

        local SwitchKnob = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = CONFIG.TextPrimary,
            BorderSizePixel = 0, Parent = SwitchTrack
        })
        AddCorner(SwitchKnob, UDim.new(1, 0))

        local ClickBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = ToggleFrame
        })

        ClickBtn.MouseEnter:Connect(function() Tween(ToggleFrame, {BackgroundColor3 = CONFIG.SurfaceHover}, 0.15) end)
        ClickBtn.MouseLeave:Connect(function() Tween(ToggleFrame, {BackgroundColor3 = CONFIG.Surface}, 0.15) end)

        ClickBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            Tween(SwitchTrack, {BackgroundColor3 = toggled and CONFIG.Accent or CONFIG.Border}, 0.2)
            Tween(SwitchKnob, {Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
            callback(toggled)
        end)

        -- External set method
        local toggleObj = { Frame = ToggleFrame }
        function toggleObj:Set(val)
            toggled = val
            Tween(SwitchTrack, {BackgroundColor3 = toggled and CONFIG.Accent or CONFIG.Border}, 0.2)
            Tween(SwitchKnob, {Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
        end
        return toggleObj
    end

    function Tab:AddButton(text, callback)
        callback = callback or function() end
        local Button = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = CONFIG.Surface, BorderSizePixel = 0,
            Text = text, TextColor3 = CONFIG.TextPrimary, TextSize = 12, Font = CONFIG.FontMedium,
            LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(Button, CONFIG.SmallRadius)
        Button.MouseEnter:Connect(function() Tween(Button, {BackgroundColor3 = CONFIG.SurfaceHover}, 0.15) end)
        Button.MouseLeave:Connect(function() Tween(Button, {BackgroundColor3 = CONFIG.Surface}, 0.15) end)
        Button.MouseButton1Click:Connect(function()
            Tween(Button, {BackgroundColor3 = CONFIG.Accent}, 0.1)
            task.wait(0.12); Tween(Button, {BackgroundColor3 = CONFIG.Surface}, 0.2)
            callback()
        end)
        return Button
    end

    function Tab:AddAccentButton(text, callback)
        callback = callback or function() end
        local Button = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0,
            Text = text, TextColor3 = Color3.new(1,1,1), TextSize = 12, Font = CONFIG.Font,
            LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(Button, CONFIG.SmallRadius)
        Button.MouseEnter:Connect(function() Tween(Button, {BackgroundColor3 = CONFIG.AccentHover}, 0.15) end)
        Button.MouseLeave:Connect(function() Tween(Button, {BackgroundColor3 = CONFIG.Accent}, 0.15) end)
        Button.MouseButton1Click:Connect(callback)
        return Button
    end

    function Tab:AddSlider(text, min, max, default, callback)
        callback = callback or function() end
        min = min or 0; max = max or 100; default = default or min

        local SliderFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0, LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(SliderFrame, CONFIG.SmallRadius)

        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -60, 0, 18), BackgroundTransparency = 1,
            Text = text, TextColor3 = CONFIG.TextPrimary, TextSize = 12, Font = CONFIG.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = SliderFrame
        })

        local ValueLabel = CreateInstance("TextLabel", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6),
            Size = UDim2.new(0, 40, 0, 18), BackgroundTransparency = 1, Text = tostring(default),
            TextColor3 = CONFIG.Accent, TextSize = 12, Font = CONFIG.Font,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = SliderFrame
        })

        local Track = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 32),
            Size = UDim2.new(1, -24, 0, 4), BackgroundColor3 = CONFIG.Border, BorderSizePixel = 0, Parent = SliderFrame
        })
        AddCorner(Track, UDim.new(1, 0))

        local Fill = CreateInstance("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, Parent = Track
        })
        AddCorner(Fill, UDim.new(1, 0))

        local Knob = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = CONFIG.TextPrimary, BorderSizePixel = 0, Parent = Track
        })
        AddCorner(Knob, UDim.new(1, 0))

        local sliding = false
        local SliderBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = SliderFrame
        })

        local function updateSlider(input)
            local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relative)
            Tween(Fill, {Size = UDim2.new(relative, 0, 1, 0)}, 0.08)
            Tween(Knob, {Position = UDim2.new(relative, 0, 0.5, 0)}, 0.08)
            ValueLabel.Text = tostring(value)
            callback(value)
        end

        SliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; updateSlider(input) end
        end)
        SliderBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
        end)
        SliderBtn.MouseEnter:Connect(function() Tween(SliderFrame, {BackgroundColor3 = CONFIG.SurfaceHover}, 0.15) end)
        SliderBtn.MouseLeave:Connect(function() Tween(SliderFrame, {BackgroundColor3 = CONFIG.Surface}, 0.15) end)

        local sliderObj = { Frame = SliderFrame }
        function sliderObj:SetValue(val)
            local rel = math.clamp((val - min) / (max - min), 0, 1)
            Tween(Fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.08)
            Tween(Knob, {Position = UDim2.new(rel, 0, 0.5, 0)}, 0.08)
            ValueLabel.Text = tostring(val)
        end
        return sliderObj
    end

    function Tab:AddLabel(text)
        return CreateInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = text,
            TextColor3 = CONFIG.TextSecondary, TextSize = 11, Font = CONFIG.FontRegular,
            TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
            LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
    end

    function Tab:AddSeparator()
        local Sep = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1,
            LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = CONFIG.Border,
            BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = Sep
        })
        return Sep
    end

    function Tab:AddTextbox(text, default, callback)
        callback = callback or function() end
        local BoxFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0, LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(BoxFrame, CONFIG.SmallRadius)

        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.45, 0, 1, 0), BackgroundTransparency = 1,
            Text = text, TextColor3 = CONFIG.TextPrimary, TextSize = 12, Font = CONFIG.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = BoxFrame
        })

        local Input = CreateInstance("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0.48, 0, 0, 26), BackgroundColor3 = CONFIG.BackgroundSecond,
            BorderSizePixel = 0, Text = default or "", TextColor3 = CONFIG.TextPrimary,
            PlaceholderColor3 = CONFIG.TextMuted, TextSize = 11, Font = CONFIG.FontRegular,
            ClearTextOnFocus = false, Parent = BoxFrame
        })
        AddCorner(Input, CONFIG.SmallRadius)
        local inputPad = Instance.new("UIPadding", Input)
        inputPad.PaddingLeft = UDim.new(0, 6)
        inputPad.PaddingRight = UDim.new(0, 6)

        Input.FocusLost:Connect(function() callback(Input.Text) end)

        local boxObj = { Frame = BoxFrame, Input = Input }
        function boxObj:SetText(t) Input.Text = t end
        return boxObj
    end

    -- ─── Color Picker (wheel + value slider) ───
    function Tab:AddColorPicker(text, default, callback)
        callback = callback or function() end
        default = default or Color3.new(1, 1, 1)

        local PickerFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 160), BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0, LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(PickerFrame, CONFIG.SmallRadius)

        -- Label + preview swatch
        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(0.5, 0, 0, 18), BackgroundTransparency = 1,
            Text = text, TextColor3 = CONFIG.TextPrimary, TextSize = 12, Font = CONFIG.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = PickerFrame
        })

        local Preview = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6),
            Size = UDim2.new(0, 40, 0, 18), BackgroundColor3 = default, BorderSizePixel = 0, Parent = PickerFrame
        })
        AddCorner(Preview, CONFIG.SmallRadius)

        -- Color wheel
        local Wheel = CreateInstance("ImageButton", {
            Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(0, 110, 0, 110),
            BackgroundTransparency = 1, Image = "rbxassetid://6020299385", ZIndex = 2, Parent = PickerFrame
        })

        local WheelScope = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 1, ZIndex = 3, Parent = Wheel
        })
        AddCorner(WheelScope, UDim.new(1, 0))

        -- Value slider
        local ValueSlider = CreateInstance("Frame", {
            Position = UDim2.new(0, 132, 0, 30), Size = UDim2.new(0, 24, 0, 110),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2, Parent = PickerFrame
        })
        AddCorner(ValueSlider, CONFIG.SmallRadius)
        CreateInstance("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            }, Parent = ValueSlider
        })

        local ValueBar = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(1.2, 0, 0, 3), BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
            BorderSizePixel = 1, BorderColor3 = Color3.new(0, 0, 0), ZIndex = 3, Parent = ValueSlider
        })

        -- RGB text display
        local RGBLabel = CreateInstance("TextLabel", {
            Position = UDim2.new(0, 170, 0, 30), Size = UDim2.new(0, 100, 0, 110),
            BackgroundTransparency = 1, Text = string.format("R: %d\nG: %d\nB: %d",
                math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)),
            TextColor3 = CONFIG.TextSecondary, TextSize = 11, Font = CONFIG.FontRegular,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            Parent = PickerFrame
        })

        local colorData = { h = 0, s = 0, v = 1 }
        -- Init from default color
        do
            local h, s, v = default:ToHSV()
            colorData.h = h; colorData.s = s; colorData.v = v
        end

        local draggingWheel = false
        local draggingValue = false

        local function applyColor()
            local c = Color3.fromHSV(colorData.h, colorData.s, colorData.v)
            Preview.BackgroundColor3 = c
            RGBLabel.Text = string.format("R: %d\nG: %d\nB: %d",
                math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
            callback(c)
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
            applyColor()
        end

        local function updateValue(input)
            local y = input.Position.Y - ValueSlider.AbsolutePosition.Y
            local percent = math.clamp(y / ValueSlider.AbsoluteSize.Y, 0, 1)
            ValueBar.Position = UDim2.new(0.5, 0, percent, 0)
            colorData.v = 1 - percent
            applyColor()
        end

        Wheel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingWheel = true; updateWheel(input) end
        end)
        ValueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingValue = true; updateValue(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if draggingWheel then updateWheel(input) end
                if draggingValue then updateValue(input) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingWheel = false; draggingValue = false
            end
        end)

        local pickerObj = { Frame = PickerFrame, Preview = Preview }
        function pickerObj:SetColor(c)
            local h, s, v = c:ToHSV()
            colorData.h = h; colorData.s = s; colorData.v = v
            Preview.BackgroundColor3 = c
            RGBLabel.Text = string.format("R: %d\nG: %d\nB: %d",
                math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
        end
        return pickerObj
    end

    -- ─── Color Slot Grid (for custom color cycles) ───
    function Tab:AddColorSlots(count, colors, getCurrentColor, onSave, onClear)
        count = count or 10
        colors = colors or {}

        local GridFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0, LayoutOrder = #TabPage:GetChildren(), Parent = TabPage
        })
        AddCorner(GridFrame, CONFIG.SmallRadius)

        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(1, -24, 0, 14), BackgroundTransparency = 1,
            Text = "CUSTOM COLOR SLOTS (click to save current)", TextColor3 = CONFIG.TextMuted,
            TextSize = 9, Font = CONFIG.Font, TextXAlignment = Enum.TextXAlignment.Left, Parent = GridFrame
        })

        local slots = {}
        for i = 1, count do
            local slot = CreateInstance("TextButton", {
                Name = "Slot" .. i, Text = colors[i] and "" or tostring(i),
                TextColor3 = Color3.new(1, 1, 1), TextSize = 10, Font = CONFIG.FontRegular,
                BackgroundColor3 = colors[i] or Color3.fromRGB(40, 40, 40),
                Size = UDim2.new(0, 28, 0, 24),
                Position = UDim2.new(0, 12 + ((i - 1) % 5) * 33, 0, 22 + math.floor((i - 1) / 5) * 28),
                BorderSizePixel = 0, Parent = GridFrame
            })
            AddCorner(slot, CONFIG.SmallRadius)
            slot.MouseButton1Click:Connect(function()
                local c = getCurrentColor()
                colors[i] = c
                slot.BackgroundColor3 = c
                slot.Text = ""
                if onSave then onSave(i, c, colors) end
            end)
            table.insert(slots, slot)
        end

        -- Clear all button
        local ClearBtn = CreateInstance("TextButton", {
            Position = UDim2.new(0, 12 + 5 * 33 + 10, 0, 22),
            Size = UDim2.new(0, 55, 0, 24), BackgroundColor3 = Color3.fromRGB(60, 30, 30),
            BorderSizePixel = 0, Text = "Clear", TextColor3 = Color3.new(1, 1, 1),
            TextSize = 10, Font = CONFIG.FontMedium, Parent = GridFrame
        })
        AddCorner(ClearBtn, CONFIG.SmallRadius)
        ClearBtn.MouseButton1Click:Connect(function()
            for idx, s in ipairs(slots) do
                s.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                s.Text = tostring(idx)
                colors[idx] = nil
            end
            if onClear then onClear() end
        end)

        local slotsObj = { Frame = GridFrame, Slots = slots, Colors = colors }
        function slotsObj:Refresh(newColors)
            for idx, s in ipairs(slots) do
                if newColors[idx] then
                    s.BackgroundColor3 = newColors[idx]; s.Text = ""
                else
                    s.BackgroundColor3 = Color3.fromRGB(40, 40, 40); s.Text = tostring(idx)
                end
            end
        end
        return slotsObj
    end

    return Tab
end

-- ═══════════════════════════════════════
-- OPEN / CLOSE
-- ═══════════════════════════════════════
local isOpen = true

local function CloseUI()
    isOpen = false
    Tween(MainFrame, {Size = UDim2.new(0, CONFIG.WindowWidth, 0, 0)}, 0.35)
    Tween(Shadow, {ImageTransparency = 1}, 0.3)
    task.wait(0.35); MainFrame.Visible = false; Shadow.Visible = false
end

local function OpenUI()
    MainFrame.Visible = true; Shadow.Visible = true
    MainFrame.Size = UDim2.new(0, CONFIG.WindowWidth, 0, 0); isOpen = true
    Tween(MainFrame, {Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight)}, 0.4, Enum.EasingStyle.Back)
    Tween(Shadow, {ImageTransparency = 0.4}, 0.35)
end

CloseBtn.MouseButton1Click:Connect(CloseUI)
MinBtn.MouseButton1Click:Connect(CloseUI)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        if isOpen then CloseUI() else OpenUI() end
    end
end)

Library.Close = CloseUI
Library.Open = OpenUI
Library.Destroy = function() ScreenGui:Destroy() end

return Library
