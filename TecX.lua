local TecX = {}

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

assert(Player, "[TecX] This library must run on the client.")

--// Theme
local Theme = {
    Background = Color3.fromRGB(15, 16, 22),
    Secondary = Color3.fromRGB(21, 22, 30),
    Element = Color3.fromRGB(29, 30, 40),
    ElementHover = Color3.fromRGB(42, 39, 59),

    Accent = Color3.fromRGB(115, 85, 255),
    AccentDark = Color3.fromRGB(79, 58, 190),

    Success = Color3.fromRGB(65, 190, 125),
    Error = Color3.fromRGB(220, 75, 85),
    Warning = Color3.fromRGB(235, 170, 65),

    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(145, 145, 160),
    Border = Color3.fromRGB(42, 43, 55)
}

--// Tween Manager
local ActiveTweens = setmetatable({}, {
    __mode = "k"
})

local function Tween(object, properties, duration)
    if not object or not object.Parent then
        return nil
    end

    local previous = ActiveTweens[object]

    if previous then
        previous:Cancel()
    end

    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    ActiveTweens[object] = tween

    tween.Completed:Connect(function()
        if ActiveTweens[object] == tween then
            ActiveTweens[object] = nil
        end
    end)

    tween:Play()

    return tween
end

--// Instance Creator
local function Create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    if parent then
        object.Parent = parent
    end

    return object
end

--// UI Utilities
local function Corner(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color, transparency)
    Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = 1,
        Transparency = transparency or 0
    }, parent)
end

local function Gradient(parent)
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 210, 225))
        }),
        Rotation = 0
    }, parent)
end

local function AddPadding(parent, left, right, top, bottom)
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0)
    }, parent)
end

local function SafeCallback(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    local arguments = table.pack(...)

    task.spawn(function()
        local success, err = pcall(
            callback,
            table.unpack(arguments, 1, arguments.n)
        )

        if not success then
            warn("[TecX] Callback Error:", err)
        end
    end)
end

local function FormatNumber(value)
    if math.abs(value - math.floor(value)) < 0.000001 then
        return tostring(math.floor(value))
    end

    local formatted = string.format("%.4f", value)
    formatted = formatted:gsub("0+$", "")
    formatted = formatted:gsub("%.$", "")

    return formatted
end

--// GUI Parent
local function CreateScreenGui(name, displayOrder)
    local screenGui = Create("ScreenGui", {
        Name = name,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = displayOrder or 10
    })

    local playerGui = Player:WaitForChild("PlayerGui")

    local success = pcall(function()
        screenGui.Parent = CoreGui
    end)

    if not success then
        screenGui.Parent = playerGui
    end

    return screenGui
end

--==================================================
-- WINDOW
--==================================================

function TecX:CreateWindow(config)
    config = typeof(config) == "table" and config or {}

    local PlayerGui = Player:WaitForChild("PlayerGui")

    -- Remove previous window
    pcall(function()
        local old = CoreGui:FindFirstChild("TecX_UI")

        if old then
            old:Destroy()
        end
    end)

    local oldPlayerGui = PlayerGui:FindFirstChild("TecX_UI")

    if oldPlayerGui then
        oldPlayerGui:Destroy()
    end

    local ScreenGui = CreateScreenGui("TecX_UI", 10)

    -- Main
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(650, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),

        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,

        ClipsDescendants = true,
        Active = true
    }, ScreenGui)

    Corner(Main, 12)
    Stroke(Main)

    -- Topbar
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),

        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Active = true
    }, Main)

    local Title = Create("TextLabel", {
        Name = "Title",

        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -75, 1, 0),

        BackgroundTransparency = 1,

        Text = tostring(config.Name or "TecX"),
        TextColor3 = Theme.Text,

        TextSize = 16,
        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Topbar)

    -- Close
    local Close = Create("TextButton", {
        Name = "Close",

        Position = UDim2.new(1, -43, 0, 7),
        Size = UDim2.fromOffset(34, 34),

        BackgroundColor3 = Theme.Element,

        Text = "×",
        TextColor3 = Theme.SubText,

        TextSize = 23,
        Font = Enum.Font.GothamMedium,

        AutoButtonColor = false
    }, Topbar)

    Corner(Close, 8)

    Close.MouseEnter:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Error
        })
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Element
        })
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",

        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(0, 165, 1, -48),

        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    AddPadding(Sidebar, 10, 10, 12, 10)

    Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Sidebar)

    -- Content
    local Content = Create("Frame", {
        Name = "Content",

        Position = UDim2.new(0, 165, 0, 48),
        Size = UDim2.new(1, -165, 1, -48),

        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,

        ClipsDescendants = true
    }, Main)

    -- Window Object
    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,

        Tabs = {},
        CurrentTab = nil,

        Destroyed = false
    }

    --==================================================
    -- CENTRAL INPUT MANAGER
    --==================================================

    local draggingInput = nil
    local dragStart = nil
    local startPosition = nil

    local activeSlider = nil

    local inputConnections = {}

    local function IsPointerMovement(input, initialInput)
        if not initialInput then
            return false
        end

        if initialInput.UserInputType == Enum.UserInputType.MouseButton1 then
            return input.UserInputType == Enum.UserInputType.MouseMovement
        end

        return input == initialInput
    end

    local function IsPointerEnded(input, initialInput)
        if not initialInput then
            return false
        end

        if initialInput.UserInputType == Enum.UserInputType.MouseButton1 then
            return input.UserInputType == Enum.UserInputType.MouseButton1
        end

        return input == initialInput
    end

    -- Window dragging
    Topbar.InputBegan:Connect(function(input)
        local inputType = input.UserInputType

        if inputType == Enum.UserInputType.MouseButton1
            or inputType == Enum.UserInputType.Touch then

            draggingInput = input
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    -- Shared InputChanged
    inputConnections.InputChanged =
        UserInputService.InputChanged:Connect(function(input)

            if Window.Destroyed then
                return
            end

            -- Dragging
            if draggingInput and IsPointerMovement(input, draggingInput) then
                local delta = input.Position - dragStart

                Main.Position = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,

                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )
            end

            -- Slider
            if activeSlider and IsPointerMovement(input, activeSlider.Input) then
                activeSlider.Update(input.Position.X)
            end
        end)

    -- Shared InputEnded
    inputConnections.InputEnded =
        UserInputService.InputEnded:Connect(function(input)

            if draggingInput and IsPointerEnded(input, draggingInput) then
                draggingInput = nil
            end

            if activeSlider and IsPointerEnded(input, activeSlider.Input) then
                activeSlider = nil
            end
        end)

    -- RightShift UI visibility
    inputConnections.InputBegan =
        UserInputService.InputBegan:Connect(function(input, gameProcessed)

            if Window.Destroyed or gameProcessed then
                return
            end

            if UserInputService:GetFocusedTextBox() then
                return
            end

            if input.KeyCode == Enum.KeyCode.RightShift then
                Main.Visible = not Main.Visible
            end
        end)

    --==================================================
    -- CLEANUP
    --==================================================

    local function Cleanup()
        if Window.Destroyed then
            return
        end

        Window.Destroyed = true

        draggingInput = nil
        activeSlider = nil

        for _, connection in pairs(inputConnections) do
            if connection then
                connection:Disconnect()
            end
        end

        table.clear(inputConnections)
    end

    ScreenGui.Destroying:Connect(Cleanup)

    function Window:Destroy()
        if Window.Destroyed then
            return
        end

        Cleanup()
        ScreenGui:Destroy()
    end

    function Window:ToggleVisibility()
        if Window.Destroyed then
            return
        end

        Main.Visible = not Main.Visible
    end

    Close.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    --==================================================
    -- TAB SYSTEM
    --==================================================

    local function SelectTab(tab)
        if Window.Destroyed or Window.CurrentTab == tab then
            return
        end

        local previousTab = Window.CurrentTab

        Window.CurrentTab = tab

        -- Previous tab fade out
        if previousTab then
            local fadeOut = Tween(previousTab.Page, {
                GroupTransparency = 1
            }, 0.16)

            if fadeOut then
                fadeOut.Completed:Connect(function(state)
                    if state == Enum.PlaybackState.Completed
                        and Window.CurrentTab ~= previousTab
                        and previousTab.Page.Parent then

                        previousTab.Page.Visible = false
                    end
                end)
            end

            Tween(previousTab.Button, {
                BackgroundColor3 = Theme.Element,
                TextColor3 = Theme.SubText
            }, 0.15)
        end

        -- New tab fade in
        tab.Page.Visible = true
        tab.Page.GroupTransparency = 1

        Tween(tab.Page, {
            GroupTransparency = 0
        }, 0.2)

        Tween(tab.Button, {
            BackgroundColor3 = Theme.Accent,
            TextColor3 = Theme.Text
        }, 0.15)
    end

    --==================================================
    -- CREATE TAB
    --==================================================

    function Window:CreateTab(tabName)
        if Window.Destroyed then
            return nil
        end

        tabName = tostring(tabName or "Tab")

        local tabNumber = #Window.Tabs + 1

        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. tabNumber,

            Size = UDim2.new(1, 0, 0, 36),

            BackgroundColor3 = Theme.Element,

            Text = tabName,
            TextColor3 = Theme.SubText,

            TextSize = 13,
            Font = Enum.Font.GothamMedium,

            AutoButtonColor = false
        }, Sidebar)

        Corner(TabButton, 7)

        -- CanvasGroup for Fade
        local Page = Create("CanvasGroup", {
            Name = "Page_" .. tabNumber,

            Size = UDim2.new(1, 0, 1, 0),

            BackgroundTransparency = 1,
            GroupTransparency = 1,

            ClipsDescendants = true,
            Visible = false
        }, Content)

        -- Scroll
        local Container = Create("ScrollingFrame", {
            Name = tabName .. "_Content",

            Size = UDim2.new(1, 0, 1, 0),

            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,

            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.None,

            ScrollingDirection = Enum.ScrollingDirection.Y
        }, Page)

        AddPadding(Container, 18, 18, 15, 15)

        local ListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Container)

        -- Manual Canvas Management
        local lastCanvasHeight = -1

        local function UpdateCanvas()
            if not Container.Parent then
                return
            end

            local height = ListLayout.AbsoluteContentSize.Y + 30

            if math.abs(height - lastCanvasHeight) < 0.5 then
                return
            end

            lastCanvasHeight = height

            Container.CanvasSize = UDim2.new(
                0, 0,
                0, height
            )
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
            UpdateCanvas
        )

        UpdateCanvas()

        local Tab = {
            Button = TabButton,
            Container = Container,
            Page = Page
        }

        table.insert(Window.Tabs, Tab)

        TabButton.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        --==================================================
        -- BUTTON
        --==================================================

        function Tab:AddButton(buttonName, callback)
            if Window.Destroyed then
                return nil
            end

            local Button = Create("TextButton", {
                Name = tostring(buttonName),

                Size = UDim2.new(1, 0, 0, 42),

                BackgroundColor3 = Theme.Element,

                Text = tostring(buttonName),
                TextColor3 = Theme.Text,

                TextSize = 13,
                Font = Enum.Font.GothamMedium,

                AutoButtonColor = false
            }, Container)

            Corner(Button, 8)
            Stroke(Button)

            Button.MouseEnter:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.ElementHover
                })
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.Element
                })
            end)

            Button.MouseButton1Click:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.Accent
                }, 0.1)

                SafeCallback(callback)

                task.delay(0.14, function()
                    if Button.Parent then
                        Tween(Button, {
                            BackgroundColor3 = Theme.Element
                        })
                    end
                end)
            end)

            return Button
        end

        --==================================================
        -- LABEL
        --==================================================

        function Tab:AddLabel(labelText)
            if Window.Destroyed then
                return nil
            end

            local Label = Create("TextLabel", {
                Name = "Label",

                Size = UDim2.new(1, 0, 0, 35),

                BackgroundTransparency = 1,

                Text = tostring(labelText or ""),
                TextColor3 = Theme.SubText,

                TextSize = 13,
                Font = Enum.Font.Gotham,

                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,

                TextWrapped = true
            }, Container)

            return Label
        end

        --==================================================
        -- TOGGLE
        --==================================================

        function Tab:AddToggle(toggleName, defaultState, callback)
            if Window.Destroyed then
                return nil
            end

            local state = defaultState == true

            local ToggleFrame = Create("Frame", {
                Name = "Toggle",

                Size = UDim2.new(1, 0, 0, 44),

                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0
            }, Container)

            Corner(ToggleFrame, 8)

            local ToggleLabel = Create("TextLabel", {
                Name = "Title",

                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -75, 1, 0),

                BackgroundTransparency = 1,

                Text = tostring(toggleName),
                TextColor3 = Theme.Text,

                TextSize = 13,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left
            }, ToggleFrame)

            -- Switch Track
            local Track = Create("TextButton", {
                Name = "Track",

                Position = UDim2.new(1, -56, 0.5, -12),
                Size = UDim2.fromOffset(44, 24),

                BackgroundColor3 = state and Theme.Accent or Theme.Secondary,

                Text = "",
                AutoButtonColor = false
            }, ToggleFrame)

            Corner(Track, 20)
            Stroke(Track)

            Gradient(Track)

            -- Switch Knob
            local Knob = Create("Frame", {
                Name = "Knob",

                Size = UDim2.fromOffset(16, 16),

                Position = state
                    and UDim2.new(1, -19, 0.5, -8)
                    or UDim2.new(0, 3, 0.5, -8),

                BackgroundColor3 = Color3.fromRGB(245, 245, 250),
                BorderSizePixel = 0
            }, Track)

            Corner(Knob, 20)

            local function SetState(newState, fireCallback)
                newState = newState == true

                if state == newState then
                    return
                end

                state = newState

                Tween(Track, {
                    BackgroundColor3 = state and Theme.Accent or Theme.Secondary
                }, 0.2)

                Tween(Knob, {
                    Position = state
                        and UDim2.new(1, -19, 0.5, -8)
                        or UDim2.new(0, 3, 0.5, -8)
                }, 0.2)

                if fireCallback then
                    SafeCallback(callback, state)
                end
            end

            Track.MouseButton1Click:Connect(function()
                SetState(not state, true)
            end)

            local ToggleObject = {}

            function ToggleObject:Set(value)
                SetState(value, true)
            end

            function ToggleObject:Get()
                return state
            end

            return ToggleObject
        end

        --==================================================
        -- SLIDER
        --==================================================

        function Tab:AddSlider(sliderName, min, max, defaultVal, callback, step)
            if Window.Destroyed then
                return nil
            end

            local minimum = tonumber(min) or 0
            local maximum = tonumber(max) or 100

            if minimum > maximum then
                minimum, maximum = maximum, minimum
            end

            local range = maximum - minimum

            local sliderStep = tonumber(step)

            if not sliderStep or sliderStep <= 0 then
                if minimum % 1 == 0 and maximum % 1 == 0 then
                    sliderStep = 1
                else
                    sliderStep = range > 0 and range / 100 or 1
                end
            end

            local currentValue = minimum
            local pendingCallbackValue
            local callbackScheduled = false

            local SliderFrame = Create("Frame", {
                Name = "Slider",

                Size = UDim2.new(1, 0, 0, 62),

                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0
            }, Container)

            Corner(SliderFrame, 8)

            local SliderTitle = Create("TextLabel", {
                Position = UDim2.fromOffset(12, 5),
                Size = UDim2.new(1, -105, 0, 22),

                BackgroundTransparency = 1,

                Text = tostring(sliderName),
                TextColor3 = Theme.Text,

                TextSize = 13,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left
            }, SliderFrame)

            local ValueLabel = Create("TextLabel", {
                Position = UDim2.new(1, -90, 0, 5),
                Size = UDim2.fromOffset(78, 22),

                BackgroundTransparency = 1,

                Text = tostring(minimum),
                TextColor3 = Theme.Accent,

                TextSize = 13,
                Font = Enum.Font.GothamBold,

                TextXAlignment = Enum.TextXAlignment.Right
            }, SliderFrame)

            -- Slider Background
            local SliderBar = Create("Frame", {
                Name = "SliderBar",

                Position = UDim2.new(0, 12, 0, 39),
                Size = UDim2.new(1, -24, 0, 6),

                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,

                Active = true
            }, SliderFrame)

            Corner(SliderBar, 10)

            -- Slider Fill
            local Fill = Create("Frame", {
                Name = "Fill",

                Size = UDim2.new(0, 0, 1, 0),

                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,

                Active = false
            }, SliderBar)

            Corner(Fill, 10)

            -- Slider Knob
            local SliderKnob = Create("Frame", {
                Name = "Knob",

                Size = UDim2.fromOffset(14, 14),

                Position = UDim2.new(0, -7, 0.5, -7),

                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,

                Active = false
            }, SliderBar)

            Corner(SliderKnob, 20)
            Stroke(SliderKnob, Theme.Accent)

            local function QueueCallback(value)
                pendingCallbackValue = value

                if callbackScheduled then
                    return
                end

                callbackScheduled = true

                task.defer(function()
                    callbackScheduled = false

                    if Window.Destroyed then
                        return
                    end

                    SafeCallback(callback, pendingCallbackValue)
                end)
            end

            local function UpdateVisuals()
                local ratio = 0

                if range > 0 then
                    ratio = (currentValue - minimum) / range
                end

                ratio = math.clamp(ratio, 0, 1)

                Fill.Size = UDim2.new(ratio, 0, 1, 0)

                SliderKnob.Position = UDim2.new(
                    ratio, -7,
                    0.5, -7
                )

                ValueLabel.Text = FormatNumber(currentValue)
            end

            local function SetValue(value, fireCallback)
                value = tonumber(value)

                if not value or value ~= value then
                    return
                end

                value = math.clamp(value, minimum, maximum)

                if range > 0 then
                    local steps = math.floor(
                        ((value - minimum) / sliderStep) + 0.5
                    )

                    value = minimum + steps * sliderStep
                    value = math.clamp(value, minimum, maximum)
                end

                value = tonumber(string.format("%.4f", value))

                if currentValue == value then
                    return
                end

                currentValue = value

                UpdateVisuals()

                if fireCallback then
                    QueueCallback(currentValue)
                end
            end

            local function UpdateFromPosition(positionX)
                if SliderBar.AbsoluteSize.X <= 0 then
                    return
                end

                local relative = (
                    positionX - SliderBar.AbsolutePosition.X
                ) / SliderBar.AbsoluteSize.X

                relative = math.clamp(relative, 0, 1)

                SetValue(
                    minimum + range * relative,
                    true
                )
            end

            -- Shared Input Manager
            SliderBar.InputBegan:Connect(function(input)
                local inputType = input.UserInputType

                if inputType == Enum.UserInputType.MouseButton1
                    or inputType == Enum.UserInputType.Touch then

                    activeSlider = {
                        Input = input,
                        Update = UpdateFromPosition
                    }

                    UpdateFromPosition(input.Position.X)
                end
            end)

            -- Default Value
            SetValue(defaultVal or minimum, false)
            UpdateVisuals()

            local SliderObject = {}

            function SliderObject:Set(value)
                SetValue(value, true)
            end

            function SliderObject:Get()
                return currentValue
            end

            return SliderObject
        end

        --==================================================
        -- DROPDOWN
        --==================================================

        function Tab:AddDropdown(dropdownName, optionsList, callback)
            if Window.Destroyed then
                return nil
            end

            local options = typeof(optionsList) == "table" and optionsList or {}

            local selectedOption = nil
            local isOpen = false

            local headerHeight = 44
            local maximumDropdownHeight = 150

            -- Main Frame
            local DropdownFrame = Create("Frame", {
                Name = "Dropdown",

                Size = UDim2.new(1, 0, 0, headerHeight),

                BackgroundTransparency = 1,
                ClipsDescendants = true
            }, Container)

            -- Header
            local Header = Create("TextButton", {
                Name = "Header",

                Size = UDim2.new(1, 0, 0, 40),

                BackgroundColor3 = Theme.Element,

                Text = tostring(dropdownName) .. "   •   Seçiniz",
                TextColor3 = Theme.Text,

                TextSize = 12,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left,

                AutoButtonColor = false
            }, DropdownFrame)

            Corner(Header, 8)

            AddPadding(Header, 12, 35, 0, 0)

            local Arrow = Create("TextLabel", {
                Name = "Arrow",

                Position = UDim2.new(1, -30, 0, 0),
                Size = UDim2.fromOffset(22, 40),

                BackgroundTransparency = 1,

                Text = "⌄",
                TextColor3 = Theme.SubText,

                TextSize = 18,
                Font = Enum.Font.GothamBold
            }, Header)

            -- Options Container
            local OptionsContainer = Create("ScrollingFrame", {
                Name = "Options",

                Position = UDim2.fromOffset(0, headerHeight),
                Size = UDim2.new(1, 0, 0, 0),

                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0,

                BorderSizePixel = 0,

                CanvasSize = UDim2.new(0, 0, 0, 0),

                ScrollingDirection = Enum.ScrollingDirection.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,

                AutomaticCanvasSize = Enum.AutomaticSize.None
            }, DropdownFrame)

            Corner(OptionsContainer, 8)

            AddPadding(OptionsContainer, 5, 5, 5, 5)

            local OptionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, OptionsContainer)

            local function UpdateOptionsCanvas()
                OptionsContainer.CanvasSize = UDim2.new(
                    0, 0,
                    0, OptionsLayout.AbsoluteContentSize.Y + 10
                )
            end

            local function UpdateHeader()
                local selectedText = selectedOption == nil
                    and "Seçiniz"
                    or tostring(selectedOption)

                Header.Text = tostring(dropdownName)
                    .. "   •   "
                    .. selectedText
            end

            -- Build Options
            if #options == 0 then
                local emptyLabel = Create("TextLabel", {
                    Name = "Empty",

                    Size = UDim2.new(1, -6, 0, 28),

                    BackgroundTransparency = 1,

                    Text = "Seçenek bulunamadı",
                    TextColor3 = Theme.SubText,

                    TextSize = 12,
                    Font = Enum.Font.Gotham
                }, OptionsContainer)
            else
                for index, option in ipairs(options) do
                    local optionValue = option
                    local optionIndex = index

                    local OptionButton = Create("TextButton", {
                        Name = "Option_" .. index,

                        Size = UDim2.new(1, -6, 0, 28),

                        BackgroundColor3 = Theme.Element,

                        Text = tostring(optionValue),
                        TextColor3 = Theme.SubText,

                        TextSize = 12,
                        Font = Enum.Font.Gotham,

                        TextXAlignment = Enum.TextXAlignment.Left,

                        AutoButtonColor = false,
                        LayoutOrder = index
                    }, OptionsContainer)

                    Corner(OptionButton, 6)
                    AddPadding(OptionButton, 9, 5, 0, 0)

                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {
                            BackgroundColor3 = Theme.ElementHover,
                            TextColor3 = Theme.Text
                        })
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {
                            BackgroundColor3 = Theme.Element,
                            TextColor3 = Theme.SubText
                        })
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        selectedOption = optionValue

                        UpdateHeader()

                        isOpen = false

                        Tween(DropdownFrame, {
                            Size = UDim2.new(1, 0, 0, headerHeight)
                        }, 0.18)

                        Tween(OptionsContainer, {
                            Size = UDim2.new(1, 0, 0, 0)
                        }, 0.18)

                        Tween(Arrow, {
                            Rotation = 0
                        }, 0.18)

                        SafeCallback(callback, optionValue, optionIndex)
                    end)
                end
            end

            UpdateOptionsCanvas()

            local contentHeight = OptionsLayout.AbsoluteContentSize.Y + 10
            local visibleHeight = math.min(
                contentHeight,
                maximumDropdownHeight
            )

            OptionsContainer.ScrollingEnabled =
                contentHeight > maximumDropdownHeight

            local function SetOpen(value)
                isOpen = value

                local targetHeight = isOpen and visibleHeight or 0
                local frameHeight = headerHeight + targetHeight

                Tween(DropdownFrame, {
                    Size = UDim2.new(1, 0, 0, frameHeight)
                }, 0.2)

                Tween(OptionsContainer, {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                }, 0.2)

                Tween(Arrow, {
                    Rotation = isOpen and 180 or 0
                }, 0.2)
            end

            Header.MouseButton1Click:Connect(function()
                SetOpen(not isOpen)
            end)

            local DropdownObject = {}

            function DropdownObject:Get()
                return selectedOption
            end

            function DropdownObject:Set(value, fireCallback)
                for index, option in ipairs(options) do
                    if option == value then
                        selectedOption = option

                        UpdateHeader()

                        if fireCallback then
                            SafeCallback(callback, option, index)
                        end

                        return true
                    end
                end

                return false
            end

            return DropdownObject
        end

        -- Select first tab automatically
        if #Window.Tabs == 1 then
            SelectTab(Tab)
        end

        return Tab
    end

    return Window
end

--==================================================
-- NOTIFICATION SYSTEM
--==================================================

local NotificationGui = nil
local NotificationRoot = nil

local ActiveNotifications = {}
local NotificationSequence = 0

local function CreateNotificationSystem()
    if NotificationGui and NotificationGui.Parent then
        return
    end

    local PlayerGui = Player:WaitForChild("PlayerGui")

    pcall(function()
        local old = CoreGui:FindFirstChild("TecX_Notifications")

        if old then
            old:Destroy()
        end
    end)

    local oldPlayerGui = PlayerGui:FindFirstChild("TecX_Notifications")

    if oldPlayerGui then
        oldPlayerGui:Destroy()
    end

    NotificationGui = CreateScreenGui("TecX_Notifications", 100)

    NotificationRoot = Create("Frame", {
        Name = "NotificationRoot",

        Position = UDim2.new(1, -16, 0, 16),
        AnchorPoint = Vector2.new(1, 0),

        Size = UDim2.fromOffset(320, 430),

        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, NotificationGui)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),

        SortOrder = Enum.SortOrder.LayoutOrder,

        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top
    }, NotificationRoot)
end

local function RemoveNotification(card, instant)
    if not card or not card.Parent then
        return
    end

    for index = #ActiveNotifications, 1, -1 do
        if ActiveNotifications[index] == card then
            table.remove(ActiveNotifications, index)
            break
        end
    end

    if instant then
        card:Destroy()
        return
    end

    Tween(card, {
        GroupTransparency = 1
    }, 0.18)

    task.delay(0.2, function()
        if card.Parent then
            card:Destroy()
        end
    end)
end

function TecX:Notify(config, content, duration)
    if typeof(config) ~= "table" then
        config = {
            Title = tostring(config or "TecX"),
            Content = tostring(content or ""),
            Duration = duration or 4
        }
    end

    CreateNotificationSystem()

    NotificationSequence += 1

    local title = tostring(config.Title or "TecX")
    local message = tostring(config.Content or config.Text or "")

    local displayDuration = math.max(
        0.1,
        tonumber(config.Duration) or 4
    )

    local notificationType = string.lower(
        tostring(config.Type or "info")
    )

    local accentColor = Theme.Accent

    if notificationType == "success" then
        accentColor = Theme.Success
    elseif notificationType == "error" then
        accentColor = Theme.Error
    elseif notificationType == "warning" then
        accentColor = Theme.Warning
    end

    -- Limit active notifications
    while #ActiveNotifications >= 5 do
        RemoveNotification(ActiveNotifications[1], true)
    end

    -- Notification Card
    local Card = Create("CanvasGroup", {
        Name = "Notification",

        Size = UDim2.fromOffset(300, 82),

        BackgroundColor3 = Theme.Secondary,
        GroupTransparency = 1,

        BorderSizePixel = 0,

        LayoutOrder = -NotificationSequence,

        ClipsDescendants = true
    }, NotificationRoot)

    Corner(Card, 9)
    Stroke(Card)

    -- Accent
    local Accent = Create("Frame", {
        Name = "Accent",

        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(3, 82),

        BackgroundColor3 = accentColor,
        BorderSizePixel = 0
    }, Card)

    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",

        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -25, 0, 21),

        BackgroundTransparency = 1,

        Text = title,
        TextColor3 = Theme.Text,

        TextSize = 13,
        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Card)

    -- Content
    local ContentLabel = Create("TextLabel", {
        Name = "Content",

        Position = UDim2.fromOffset(14, 30),
        Size = UDim2.new(1, -25, 0, 38),

        BackgroundTransparency = 1,

        Text = message,
        TextColor3 = Theme.SubText,

        TextSize = 11,
        Font = Enum.Font.Gotham,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,

        TextWrapped = true
    }, Card)

    -- Progress Background
    local ProgressBackground = Create("Frame", {
        Name = "ProgressBackground",

        Position = UDim2.new(0, 14, 1, -5),
        Size = UDim2.new(1, -26, 0, 2),

        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    }, Card)

    Corner(ProgressBackground, 5)

    -- Progress
    local Progress = Create("Frame", {
        Name = "Progress",

        Size = UDim2.new(1, 0, 1, 0),

        BackgroundColor3 = accentColor,
        BorderSizePixel = 0
    }, ProgressBackground)

    Corner(Progress, 5)

    table.insert(ActiveNotifications, Card)

    -- Fade In
    Tween(Card, {
        GroupTransparency = 0
    }, 0.2)

    -- Progress Animation
    Tween(Progress, {
        Size = UDim2.new(0, 0, 1, 0)
    }, displayDuration)

    -- Auto Remove
    task.delay(displayDuration, function()
        if Card.Parent then
            RemoveNotification(Card, false)
        end
    end)

    return Card
end

-- Optional notification cleanup
function TecX:DestroyNotifications()
    if NotificationGui then
        NotificationGui:Destroy()
    end

    NotificationGui = nil
    NotificationRoot = nil

    table.clear(ActiveNotifications)
end

return TecX
