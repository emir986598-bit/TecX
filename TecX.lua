local TecX = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(15, 16, 22),
    Secondary = Color3.fromRGB(21, 22, 30),
    Element = Color3.fromRGB(29, 30, 40),
    Accent = Color3.fromRGB(115, 85, 255),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(145, 145, 160),
    Border = Color3.fromRGB(42, 43, 55)
}

local function Create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

local function Corner(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color)
    Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = 1,
        Transparency = 0
    }, parent)
end

local function Tween(object, properties, duration)
    if not object or not object.Parent then
        return
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

    tween:Play()

    return tween
end

function TecX:CreateWindow(config)
    config = typeof(config) == "table" and config or {}

    local PlayerGui = Player:WaitForChild("PlayerGui")

    -- Eski kütüphane pencerelerini temizle.
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

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "TecX_UI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    }, nil)

    -- CoreGui öncelikli, PlayerGui yedek.
    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)

    if not success then
        ScreenGui.Parent = PlayerGui
    end

    -- Main Window
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(650, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, ScreenGui)

    Corner(Main, 12)
    Stroke(Main)

    -- Topbar
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
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

    -- Close Button
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
            BackgroundColor3 = Color3.fromRGB(180, 55, 65)
        })
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Element
        })
    end)

    -- Drag System
    local dragging = false
    local dragStart
    local startPosition

    local inputChangedConnection
    local inputEndedConnection

    Topbar.InputBegan:Connect(function(input)
        local inputType = input.UserInputType

        if inputType == Enum.UserInputType.MouseButton1
            or inputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        local inputType = input.UserInputType

        if inputType ~= Enum.UserInputType.MouseMovement
            and inputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        local inputType = input.UserInputType

        if inputType == Enum.UserInputType.MouseButton1
            or inputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    -- Window Data
    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,
        Tabs = {},
        CurrentTab = nil,
        Destroyed = false
    }

    -- Connection Cleanup
    local function Cleanup()
        if Window.Destroyed then
            return
        end

        Window.Destroyed = true
        dragging = false

        if inputChangedConnection then
            inputChangedConnection:Disconnect()
            inputChangedConnection = nil
        end

        if inputEndedConnection then
            inputEndedConnection:Disconnect()
            inputEndedConnection = nil
        end
    end

    ScreenGui.Destroying:Connect(Cleanup)

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    function Window:Destroy()
        if ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(0, 165, 1, -48),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    }, Sidebar)

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

    -- Tab Selection
    local function SelectTab(tab)
        if Window.CurrentTab == tab then
            return
        end

        if Window.CurrentTab then
            local previous = Window.CurrentTab

            previous.Container.Visible = false

            Tween(previous.Button, {
                BackgroundColor3 = Theme.Element,
                TextColor3 = Theme.SubText
            })
        end

        Window.CurrentTab = tab

        tab.Container.Visible = true
        tab.Container.CanvasPosition = Vector2.zero

        Tween(tab.Button, {
            BackgroundColor3 = Theme.Accent,
            TextColor3 = Theme.Text
        })
    end

    -- Create Tab
    function Window:CreateTab(tabName)
        if Window.Destroyed then
            return nil
        end

        tabName = tostring(tabName or "Tab")

        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            Text = tabName,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        }, Sidebar)

        Corner(TabButton, 7)

        local Container = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Position = UDim2.zero,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false
        }, Content)

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 18),
            PaddingRight = UDim.new(0, 18),
            PaddingBottom = UDim.new(0, 15)
        }, Container)

        local ListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Container)

        -- Manual Canvas Update
        -- Yalnızca içerik boyutu gerçekten değiştiğinde çalışır.
        local lastCanvasHeight = -1

        local function UpdateCanvas()
            local contentHeight = ListLayout.AbsoluteContentSize.Y + 30

            if contentHeight == lastCanvasHeight then
                return
            end

            lastCanvasHeight = contentHeight

            Container.CanvasSize = UDim2.new(
                0, 0,
                0, contentHeight
            )
        end

        local canvasConnection = ListLayout:GetPropertyChangedSignal(
            "AbsoluteContentSize"
        ):Connect(UpdateCanvas)

        UpdateCanvas()

        local Tab = {
            Button = TabButton,
            Container = Container
        }

        table.insert(self.Tabs, Tab)

        TabButton.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        -- Add Button
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
                    BackgroundColor3 = Color3.fromRGB(42, 39, 59)
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

                if typeof(callback) == "function" then
                    task.spawn(function()
                        local success, err = pcall(callback)

                        if not success then
                            warn("[TecX] Callback Error:", err)
                        end

                        if Button.Parent then
                            Tween(Button, {
                                BackgroundColor3 = Theme.Element
                            })
                        end
                    end)
                else
                    Tween(Button, {
                        BackgroundColor3 = Theme.Element
                    })
                end
            end)

            return Button
        end

        -- Add Label
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

        -- İlk sekmeyi otomatik aç.
        if #self.Tabs == 1 then
            SelectTab(Tab)
        end

        return Tab
    end

    return Window
end

return TecX
