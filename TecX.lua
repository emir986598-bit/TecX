local TecX = {}

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

assert(Player, "[TecX] Client environment required.")

--==================================================
-- THEME
--==================================================

local Theme = {
    Background = Color3.fromRGB(10, 10, 12),
    Surface = Color3.fromRGB(17, 17, 20),
    Element = Color3.fromRGB(25, 25, 29),
    Hover = Color3.fromRGB(34, 34, 39),

    Accent = Color3.fromRGB(225, 225, 230),
    AccentDark = Color3.fromRGB(150, 150, 158),

    Text = Color3.fromRGB(245, 245, 247),
    SubText = Color3.fromRGB(145, 145, 153),

    Border = Color3.fromRGB(43, 43, 48),
    Success = Color3.fromRGB(90, 190, 125),
    Error = Color3.fromRGB(215, 75, 85),
    Warning = Color3.fromRGB(220, 165, 75)
}

--==================================================
-- UTILITIES
--==================================================

local ActiveTweens = setmetatable({}, {
    __mode = "k"
})

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

local function Tween(object, properties, duration)
    if not object or not object.Parent then
        return
    end

    local previous = ActiveTweens[object]

    if previous then
        previous:Cancel()
    end

    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.18,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    ActiveTweens[object] = animation
    animation:Play()

    return animation
end

local function Corner(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 9)
    }, parent)
end

local function Stroke(parent, transparency)
    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Transparency = transparency or 0
    }, parent)
end

local function Padding(parent, left, right, top, bottom)
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
        local success, err = pcall(function()
            callback(table.unpack(arguments, 1, arguments.n))
        end)

        if not success then
            warn("[TecX] Callback Error:", err)
        end
    end)
end

local function FormatNumber(value)
    if math.abs(value - math.floor(value)) < 0.000001 then
        return tostring(math.floor(value))
    end

    return string.format("%.4f", value)
        :gsub("0+$", "")
        :gsub("%.$", "")
end

local function GetGuiParent()
    local success = pcall(function()
        local test = CoreGui.Name
    end)

    if success then
        return CoreGui
    end

    return Player:WaitForChild("PlayerGui")
end

local function CreateScreenGui(name, order)
    local gui = Create("ScreenGui", {
        Name = name,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = order or 10
    }, nil)

    local parent = GetGuiParent()

    local success = pcall(function()
        gui.Parent = parent
    end)

    if not success then
        gui.Parent = Player:WaitForChild("PlayerGui")
    end

    return gui
end

local function RemoveOldGui(name)
    pcall(function()
        local old = CoreGui:FindFirstChild(name)

        if old then
            old:Destroy()
        end
    end)

    local playerGui = Player:FindFirstChildOfClass("PlayerGui")

    if playerGui then
        local old = playerGui:FindFirstChild(name)

        if old then
            old:Destroy()
        end
    end
end

--==================================================
-- WINDOW
--==================================================

function TecX:CreateWindow(config)

    config = typeof(config) == "table" and config or {}

    RemoveOldGui("TecX_UI")

    local ScreenGui = CreateScreenGui("TecX_UI", 10)

    -- Main Window

    local Main = Create("Frame", {
        Name = "Main",

        Size = UDim2.fromOffset(590, 425),

        Position = UDim2.new(0.5, -295, 0.5, -212),

        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,

        ClipsDescendants = true,
        Active = true
    }, ScreenGui)

    Corner(Main, 13)
    Stroke(Main)

    --==================================================
    -- TOPBAR
    --==================================================

    local Topbar = Create("Frame", {
        Name = "Topbar",

        Size = UDim2.new(1, 0, 0, 49),

        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,

        Active = true
    }, Main)

    local Title = Create("TextLabel", {
        Name = "Title",

        Position = UDim2.fromOffset(19, 0),
        Size = UDim2.new(1, -85, 1, 0),

        BackgroundTransparency = 1,

        Text = tostring(config.Name or "TecX"),
        TextColor3 = Theme.Text,

        TextSize = 15,
        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Topbar)

    local Close = Create("TextButton", {
        Name = "Close",

        Position = UDim2.new(1, -42, 0, 8),
        Size = UDim2.fromOffset(30, 30),

        BackgroundColor3 = Theme.Element,

        Text = "×",
        TextColor3 = Theme.SubText,

        TextSize = 21,
        Font = Enum.Font.Gotham,

        AutoButtonColor = false
    }, Topbar)

    Corner(Close, 8)

    Close.MouseEnter:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Error,
            TextColor3 = Theme.Text
        })
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Element,
            TextColor3 = Theme.SubText
        })
    end)

    Create("Frame", {
        Name = "TopbarLine",

        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),

        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    }, Topbar)

    --==================================================
    -- WINDOW OBJECT
    --==================================================

    local Window = {
        Main = Main,
        ScreenGui = ScreenGui,

        Tabs = {},
        CurrentTab = nil,

        Destroyed = false
    }

    --==================================================
    -- INPUT MANAGER
    --==================================================

    local connections = {}

    local dragging = nil
    local activeSlider = nil

    local function IsPointerMove(input, initial)
        if not initial then
            return false
        end

        if initial.UserInputType == Enum.UserInputType.MouseButton1 then
            return input.UserInputType == Enum.UserInputType.MouseMovement
        end

        return input == initial
    end

    local function IsPointerEnd(input, initial)
        if not initial then
            return false
        end

        if initial.UserInputType == Enum.UserInputType.MouseButton1 then
            return input.UserInputType == Enum.UserInputType.MouseButton1
        end

        return input == initial
    end

    -- Window Dragging

    local function IsInsideCloseButton(position)
        local p = Close.AbsolutePosition
        local s = Close.AbsoluteSize

        return position.X >= p.X
            and position.X <= p.X + s.X
            and position.Y >= p.Y
            and position.Y <= p.Y + s.Y
    end

    Topbar.InputBegan:Connect(function(input)
        local inputType = input.UserInputType

        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then
            return
        end

        if IsInsideCloseButton(input.Position) then
            return
        end

        dragging = {
            Input = input,
            Start = input.Position,
            Position = Main.Position
        }
    end)

    -- Shared InputChanged

    connections.InputChanged = UserInputService.InputChanged:Connect(function(input)

        if Window.Destroyed then
            return
        end

        if dragging and IsPointerMove(input, dragging.Input) then

            local delta = input.Position - dragging.Start

            Main.Position = UDim2.new(
                dragging.Position.X.Scale,
                dragging.Position.X.Offset + delta.X,

                dragging.Position.Y.Scale,
                dragging.Position.Y.Offset + delta.Y
            )
        end

        if activeSlider and IsPointerMove(input, activeSlider.Input) then
            activeSlider.Update(input.Position.X)
        end
    end)

    -- Shared InputEnded

    connections.InputEnded = UserInputService.InputEnded:Connect(function(input)

        if dragging and IsPointerEnd(input, dragging.Input) then
            dragging = nil
        end

        if activeSlider and IsPointerEnd(input, activeSlider.Input) then
            activeSlider = nil
        end
    end)

    -- RightShift

    connections.InputBegan = UserInputService.InputBegan:Connect(function(input, processed)

        if Window.Destroyed or processed then
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

        dragging = nil
        activeSlider = nil

        for _, connection in pairs(connections) do
            connection:Disconnect()
        end

        table.clear(connections)
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
    -- PAGE CONTENT
    --==================================================

    local Content = Create("Frame", {
        Name = "Content",

        Position = UDim2.new(0, 0, 0, 49),
        Size = UDim2.new(1, 0, 1, -104),

        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,

        ClipsDescendants = true
    }, Main)

    --==================================================
    -- BOTTOM NAVIGATION
    --==================================================

    local Navigation = Create("Frame", {
        Name = "Navigation",

        Position = UDim2.new(0, 0, 1, -55),
        Size = UDim2.new(1, 0, 0, 55),

        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0
    }, Main)

    Create("Frame", {
        Name = "NavigationLine",

        Size = UDim2.new(1, 0, 0, 1),

        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    }, Navigation)

    local NavScroll = Create("ScrollingFrame", {
        Name = "NavScroll",

        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 1, 0),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,

        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None
    }, Navigation)

    local NavLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,

        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,

        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, NavScroll)

    NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NavScroll.CanvasSize = UDim2.new(
            0,
            NavLayout.AbsoluteContentSize.X + 5,
            0,
            0
        )
    end)

    --==================================================
    -- TAB SELECTION
    --==================================================

    local function SelectTab(tab)

        if Window.Destroyed or Window.CurrentTab == tab then
            return
        end

        local previous = Window.CurrentTab

        Window.CurrentTab = tab

        if previous then

            local fadeOut = Tween(previous.Page, {
                GroupTransparency = 1
            }, 0.12)

            Tween(previous.Button, {
                BackgroundColor3 = Theme.Surface,
                TextColor3 = Theme.SubText
            }, 0.12)

            if fadeOut then
                fadeOut.Completed:Connect(function(state)

                    if state == Enum.PlaybackState.Completed
                        and Window.CurrentTab ~= previous
                        and previous.Page.Parent then

                        previous.Page.Visible = false
                    end
                end)
            end
        end

        tab.Page.Visible = true
        tab.Page.GroupTransparency = 1

        Tween(tab.Page, {
            GroupTransparency = 0
        }, 0.2)

        Tween(tab.Button, {
            BackgroundColor3 = Theme.Element,
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

        local index = #Window.Tabs + 1

        -- Navigation Button

        local TabButton = Create("TextButton", {
            Name = "Tab_" .. index,

            Size = UDim2.fromOffset(115, 34),

            BackgroundColor3 = Theme.Surface,

            Text = tabName,
            TextColor3 = Theme.SubText,

            TextSize = 12,
            Font = Enum.Font.GothamMedium,

            AutoButtonColor = false
        }, NavScroll)

        Corner(TabButton, 8)

        -- Canvas Group

        local Page = Create("CanvasGroup", {
            Name = "Page_" .. index,

            Size = UDim2.new(1, 0, 1, 0),

            BackgroundTransparency = 1,

            GroupTransparency = 1,
            ClipsDescendants = true,

            Visible = false
        }, Content)

        -- Scrolling Content

        local Container = Create("ScrollingFrame", {
            Name = "Container_" .. index,

            Size = UDim2.new(1, 0, 1, 0),

            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.AccentDark,

            ScrollingDirection = Enum.ScrollingDirection.Y,

            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.None
        }, Page)

        Padding(Container, 17, 17, 16, 16)

        local ListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Container)

        -- Manual Canvas Management

        local lastCanvasHeight = -1

        local function UpdateCanvas()
            if not Container.Parent then
                return
            end

            local height = ListLayout.AbsoluteContentSize.Y + 32

            if math.abs(height - lastCanvasHeight) < 0.5 then
                return
            end

            lastCanvasHeight = height

            Container.CanvasSize = UDim2.new(0, 0, 0, height)
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        UpdateCanvas()

        -- Tab Object

        local Tab = {
            Button = TabButton,
            Page = Page,
            Container = Container
        }

        table.insert(Window.Tabs, Tab)

        TabButton.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        --==================================================
        -- ADD BUTTON
        --==================================================

        function Tab:AddButton(buttonName, callback)

            if Window.Destroyed then
                return nil
            end

            local Button = Create("TextButton", {
                Name = "Button",

                Size = UDim2.new(1, 0, 0, 43),

                BackgroundColor3 = Theme.Element,

                Text = tostring(buttonName or "Button"),
                TextColor3 = Theme.Text,

                TextSize = 12,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left,

                AutoButtonColor = false
            }, Container)

            Padding(Button, 13, 10, 0, 0)

            Corner(Button, 8)
            Stroke(Button, 0.35)

            Button.MouseEnter:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.Hover
                })
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.Element
                })
            end)

            Button.MouseButton1Click:Connect(function()

                Tween(Button, {
                    BackgroundColor3 = Theme.Hover
                }, 0.1)

                SafeCallback(callback)

                task.delay(0.15, function()
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
        -- ADD LABEL
        --==================================================

        function Tab:AddLabel(labelText)

            if Window.Destroyed then
                return nil
            end

            local Label = Create("TextLabel", {
                Name = "Label",

                Size = UDim2.new(1, 0, 0, 34),

                BackgroundTransparency = 1,

                Text = tostring(labelText or ""),
                TextColor3 = Theme.SubText,

                TextSize = 12,
                Font = Enum.Font.Gotham,

                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,

                TextWrapped = true
            }, Container)

            return Label
        end

        --==================================================
        -- ADD TOGGLE
        --==================================================

        function Tab:AddToggle(toggleName, defaultState, callback)

            if Window.Destroyed then
                return nil
            end

            local state = defaultState == true

            local Frame = Create("Frame", {
                Name = "Toggle",

                Size = UDim2.new(1, 0, 0, 44),

                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0
            }, Container)

            Corner(Frame, 8)
            Stroke(Frame, 0.5)

            local Label = Create("TextLabel", {
                Position = UDim2.fromOffset(13, 0),
                Size = UDim2.new(1, -75, 1, 0),

                BackgroundTransparency = 1,

                Text = tostring(toggleName),
                TextColor3 = Theme.Text,

                TextSize = 12,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left
            }, Frame)

            -- Switch

            local Track = Create("TextButton", {
                Name = "Switch",

                Position = UDim2.new(1, -53, 0.5, -11),
                Size = UDim2.fromOffset(41, 22),

                BackgroundColor3 = state and Theme.AccentDark or Theme.Background,

                Text = "",
                AutoButtonColor = false
            }, Frame)

            Corner(Track, 20)

            -- Knob

            local Knob = Create("Frame", {
                Name = "Knob",

                Size = UDim2.fromOffset(16, 16),

                Position = state
                    and UDim2.new(1, -19, 0.5, -8)
                    or UDim2.new(0, 3, 0.5, -8),

                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0
            }, Track)

            Corner(Knob, 20)

            local function SetState(value, fireCallback)

                value = value == true

                if state == value then
                    return
                end

                state = value

                Tween(Track, {
                    BackgroundColor3 = state
                        and Theme.AccentDark
                        or Theme.Background
                }, 0.18)

                Tween(Knob, {
                    Position = state
                        and UDim2.new(1, -19, 0.5, -8)
                        or UDim2.new(0, 3, 0.5, -8)
                }, 0.18)

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
        -- ADD SLIDER
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

            step = tonumber(step)

            if not step or step <= 0 then
                step = (minimum % 1 == 0 and maximum % 1 == 0)
                    and 1
                    or (range > 0 and range / 100 or 1)
            end

            local currentValue = minimum

            local callbackPending = false
            local pendingValue

            local Frame = Create("Frame", {
                Name = "Slider",

                Size = UDim2.new(1, 0, 0, 61),

                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0
            }, Container)

            Corner(Frame, 8)
            Stroke(Frame, 0.5)

            local Label = Create("TextLabel", {
                Position = UDim2.fromOffset(13, 5),
                Size = UDim2.new(1, -100, 0, 20),

                BackgroundTransparency = 1,

                Text = tostring(sliderName),
                TextColor3 = Theme.Text,

                TextSize = 12,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left
            }, Frame)

            local ValueLabel = Create("TextLabel", {
                Position = UDim2.new(1, -85, 0, 5),
                Size = UDim2.fromOffset(72, 20),

                BackgroundTransparency = 1,

                Text = tostring(minimum),
                TextColor3 = Theme.SubText,

                TextSize = 12,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Right
            }, Frame)

            -- Bar

            local Bar = Create("TextButton", {
                Name = "Bar",

                Position = UDim2.new(0, 13, 0, 37),
                Size = UDim2.new(1, -26, 0, 5),

                BackgroundColor3 = Theme.Background,

                Text = "",
                AutoButtonColor = false
            }, Frame)

            Corner(Bar, 10)

            -- Fill

            local Fill = Create("Frame", {
                Name = "Fill",

                Size = UDim2.new(0, 0, 1, 0),

                BackgroundColor3 = Theme.AccentDark,
                BorderSizePixel = 0
            }, Bar)

            Corner(Fill, 10)

            -- Knob

            local Knob = Create("Frame", {
                Name = "Knob",

                Size = UDim2.fromOffset(13, 13),

                Position = UDim2.new(0, -6, 0.5, -6),

                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0
            }, Bar)

            Corner(Knob, 20)

            -- Callback Queue

            local function QueueCallback(value)

                pendingValue = value

                if callbackPending then
                    return
                end

                callbackPending = true

                task.defer(function()

                    callbackPending = false

                    if Window.Destroyed then
                        return
                    end

                    SafeCallback(callback, pendingValue)
                end)
            end

            -- Visual Update

            local function UpdateVisuals()

                local ratio = 0

                if range > 0 then
                    ratio = math.clamp(
                        (currentValue - minimum) / range,
                        0,
                        1
                    )
                end

                Fill.Size = UDim2.new(ratio, 0, 1, 0)

                Knob.Position = UDim2.new(
                    ratio, -6,
                    0.5, -6
                )

                ValueLabel.Text = FormatNumber(currentValue)
            end

            -- Set Value

            local function SetValue(value, fireCallback)

                value = tonumber(value)

                if not value or value ~= value then
                    return
                end

                value = math.clamp(value, minimum, maximum)

                if range > 0 then
                    local steps = math.floor(
                        ((value - minimum) / step) + 0.5
                    )

                    value = minimum + steps * step
                    value = math.clamp(value, minimum, maximum)
                end

                value = math.floor(value * 10000 + 0.5) / 10000

                if currentValue == value then
                    return
                end

                currentValue = value

                UpdateVisuals()

                if fireCallback then
                    QueueCallback(value)
                end
            end

            -- Drag

            local function UpdateFromPosition(positionX)

                if Bar.AbsoluteSize.X <= 0 then
                    return
                end

                local relative = (
                    positionX - Bar.AbsolutePosition.X
                ) / Bar.AbsoluteSize.X

                relative = math.clamp(relative, 0, 1)

                SetValue(
                    minimum + relative * range,
                    true
                )
            end

            Bar.InputBegan:Connect(function(input)

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
        -- ADD DROPDOWN
        --==================================================

        function Tab:AddDropdown(dropdownName, optionsList, callback)

            if Window.Destroyed then
                return nil
            end

            local options = typeof(optionsList) == "table"
                and optionsList
                or {}

            local selectedOption = nil
            local selectedIndex = nil
            local opened = false

            local headerHeight = 44
            local maximumHeight = 150

            local Frame = Create("Frame", {
                Name = "Dropdown",

                Size = UDim2.new(1, 0, 0, headerHeight),

                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,

                ClipsDescendants = true
            }, Container)

            Corner(Frame, 8)
            Stroke(Frame, 0.5)

            -- Header

            local Header = Create("TextButton", {
                Name = "Header",

                Size = UDim2.new(1, 0, 0, 44),

                BackgroundTransparency = 1,

                Text = "",
                AutoButtonColor = false
            }, Frame)

            local HeaderText = Create("TextLabel", {
                Position = UDim2.fromOffset(13, 0),
                Size = UDim2.new(1, -60, 1, 0),

                BackgroundTransparency = 1,

                Text = tostring(dropdownName) .. "  /  Seçiniz",
                TextColor3 = Theme.Text,

                TextSize = 12,
                Font = Enum.Font.GothamMedium,

                TextXAlignment = Enum.TextXAlignment.Left
            }, Header)

            local Arrow = Create("TextLabel", {
                Position = UDim2.new(1, -35, 0, 0),
                Size = UDim2.fromOffset(25, 44),

                BackgroundTransparency = 1,

                Text = "⌄",
                TextColor3 = Theme.SubText,

                TextSize = 17,
                Font = Enum.Font.Gotham
            }, Header)

            -- Options

            local OptionsContainer = Create("ScrollingFrame", {
                Name = "Options",

                Position = UDim2.fromOffset(0, headerHeight),
                Size = UDim2.new(1, 0, 0, 0),

                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,

                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.AccentDark,

                ScrollingDirection = Enum.ScrollingDirection.Y,

                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.None
            }, Frame)

            Padding(OptionsContainer, 6, 6, 5, 5)

            local OptionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, OptionsContainer)

            local function UpdateOptionsCanvas()

                local height = OptionsLayout.AbsoluteContentSize.Y + 10

                OptionsContainer.CanvasSize = UDim2.new(
                    0, 0,
                    0, height
                )
            end

            local function UpdateHeader()

                local value = selectedOption == nil
                    and "Seçiniz"
                    or tostring(selectedOption)

                HeaderText.Text = tostring(dropdownName)
                    .. "  /  "
                    .. value
            end

            -- Create Options

            if #options == 0 then

                Create("TextLabel", {
                    Size = UDim2.new(1, -8, 0, 28),

                    BackgroundTransparency = 1,

                    Text = "Seçenek bulunamadı",
                    TextColor3 = Theme.SubText,

                    TextSize = 11,
                    Font = Enum.Font.Gotham
                }, OptionsContainer)

            else

                for index, option in ipairs(options) do

                    local optionValue = option
                    local optionIndex = index

                    local OptionButton = Create("TextButton", {
                        Name = "Option_" .. index,

                        Size = UDim2.new(1, -8, 0, 29),

                        BackgroundColor3 = Theme.Element,

                        Text = tostring(optionValue),
                        TextColor3 = Theme.SubText,

                        TextSize = 11,
                        Font = Enum.Font.Gotham,

                        TextXAlignment = Enum.TextXAlignment.Left,

                        AutoButtonColor = false
                    }, OptionsContainer)

                    Padding(OptionButton, 10, 5, 0, 0)
                    Corner(OptionButton, 6)

                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {
                            BackgroundColor3 = Theme.Hover,
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
                        selectedIndex = optionIndex

                        UpdateHeader()

                        opened = false

                        Tween(Frame, {
                            Size = UDim2.new(1, 0, 0, headerHeight)
                        }, 0.16)

                        Tween(OptionsContainer, {
                            Size = UDim2.new(1, 0, 0, 0)
                        }, 0.16)

                        Tween(Arrow, {
                            Rotation = 0
                        }, 0.16)

                        SafeCallback(callback, optionValue, optionIndex)
                    end)
                end
            end

            UpdateOptionsCanvas()

            local contentHeight = OptionsLayout.AbsoluteContentSize.Y + 10
            local visibleHeight = math.min(contentHeight, maximumHeight)

            OptionsContainer.ScrollingEnabled =
                contentHeight > maximumHeight

            -- Open / Close

            local function SetOpen(value)

                opened = value

                local height = opened and visibleHeight or 0

                Tween(Frame, {
                    Size = UDim2.new(
                        1, 0,
                        0, headerHeight + height
                    )
                }, 0.18)

                Tween(OptionsContainer, {
                    Size = UDim2.new(1, 0, 0, height)
                }, 0.18)

                Tween(Arrow, {
                    Rotation = opened and 180 or 0
                }, 0.18)
            end

            Header.MouseButton1Click:Connect(function()
                SetOpen(not opened)
            end)

            local DropdownObject = {}

            function DropdownObject:Get()
                return selectedOption
            end

            function DropdownObject:Set(value, fireCallback)

                for index, option in ipairs(options) do

                    if option == value then

                        selectedOption = value
                        selectedIndex = index

                        UpdateHeader()

                        if fireCallback then
                            SafeCallback(callback, value, index)
                        end

                        return true
                    end
                end

                return false
            end

            return DropdownObject
        end

        --==================================================
        -- INITIAL TAB
        --==================================================

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

    RemoveOldGui("TecX_Notifications")

    NotificationGui = CreateScreenGui(
        "TecX_Notifications",
        100
    )

    NotificationRoot = Create("Frame", {
        Name = "Root",

        Position = UDim2.new(1, -15, 0, 15),
        AnchorPoint = Vector2.new(1, 0),

        Size = UDim2.fromOffset(310, 400),

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

    if card:GetAttribute("Removing") then
        return
    end

    card:SetAttribute("Removing", true)

    for i = #ActiveNotifications, 1, -1 do

        if ActiveNotifications[i] == card then
            table.remove(ActiveNotifications, i)
            break
        end
    end

    if instant then
        card:Destroy()
        return
    end

    Tween(card, {
        GroupTransparency = 1,
        Position = UDim2.new(1, 20, 0, 0)
    }, 0.17)

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

    local accent = Theme.AccentDark

    if notificationType == "success" then
        accent = Theme.Success
    elseif notificationType == "error" then
        accent = Theme.Error
    elseif notificationType == "warning" then
        accent = Theme.Warning
    end

    -- Maximum 4 Notifications

    while #ActiveNotifications >= 4 do
        RemoveNotification(ActiveNotifications[1], true)
    end

    -- Card

    local Card = Create("CanvasGroup", {
        Name = "Notification",

        Size = UDim2.fromOffset(295, 78),

        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0,

        GroupTransparency = 1,

        LayoutOrder = -NotificationSequence,

        BorderSizePixel = 0,
        ClipsDescendants = true
    }, NotificationRoot)

    Corner(Card, 9)
    Stroke(Card, 0.2)

    -- Accent Line

    Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 3, 1, 0),

        BackgroundColor3 = accent,
        BorderSizePixel = 0
    }, Card)

    -- Title

    Create("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -22, 0, 20),

        BackgroundTransparency = 1,

        Text = title,
        TextColor3 = Theme.Text,

        TextSize = 12,
        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Card)

    -- Content

    Create("TextLabel", {
        Position = UDim2.fromOffset(13, 29),
        Size = UDim2.new(1, -23, 0, 37),

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
        Position = UDim2.new(0, 13, 1, -5),
        Size = UDim2.new(1, -24, 0, 2),

        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    }, Card)

    Corner(ProgressBackground, 5)

    local Progress = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),

        BackgroundColor3 = accent,
        BorderSizePixel = 0
    }, ProgressBackground)

    Corner(Progress, 5)

    table.insert(ActiveNotifications, Card)

    -- Fade In

    Tween(Card, {
        GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
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

function TecX:DestroyNotifications()

    if NotificationGui then
        NotificationGui:Destroy()
    end

    NotificationGui = nil
    NotificationRoot = nil

    table.clear(ActiveNotifications)
end

return TecX
