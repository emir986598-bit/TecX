local TecX = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Background = Color3.fromRGB(15, 16, 22),
    Secondary = Color3.fromRGB(21, 22, 30),
    Element = Color3.fromRGB(29, 30, 40),
    Accent = Color3.fromRGB(115, 85, 255),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(145, 145, 160),
    Border = Color3.fromRGB(42, 43, 55)
}

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties) do
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

local function Stroke(parent, color, transparency)
    Create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1
    }, parent)
end

local function Tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    ):Play()
end

function TecX:CreateWindow(config)
    config = config or {}

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local ScreenGui = Create("ScreenGui", {
        Name = "TecX",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

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

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    local Title = Create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "TecX",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Topbar)

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
        Tween(Close, {BackgroundColor3 = Color3.fromRGB(180, 55, 65)})
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {BackgroundColor3 = Theme.Element})
    end)

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Draggable window
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(0, 165, 1, -48),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    local SidebarPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    }, Sidebar)

    local TabList = Create("UIListLayout", {
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

    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,
        Tabs = {},
        CurrentTab = nil
    }

    local function SelectTab(tab)
        if Window.CurrentTab == tab then
            return
        end

        Window.CurrentTab = tab

        for _, existingTab in ipairs(Window.Tabs) do
            local selected = existingTab == tab

            Tween(existingTab.Button, {
                BackgroundColor3 = selected and Theme.Accent or Theme.Element
            })

            Tween(existingTab.Button, {
                TextColor3 = selected and Theme.Text or Theme.SubText
            })

            existingTab.Container.Visible = selected
        end
    end

    function Window:CreateTab(tabName)
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0,
            Text = tabName,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        }, Sidebar)

        Corner(TabButton, 7)

        local Container = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        }, Content)

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 18),
            PaddingRight = UDim.new(0, 18),
            PaddingBottom = UDim.new(0, 15)
        }, Container)

        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Container)

        local Tab = {
            Button = TabButton,
            Container = Container
        }

        table.insert(self.Tabs, Tab)

        TabButton.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        function Tab:AddButton(buttonName, callback)
            local Button = Create("TextButton", {
                Name = buttonName,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                Text = buttonName,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                AutoButtonColor = false
            }, Container)

            Corner(Button, 8)
            Stroke(Button, Theme.Border)

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

                task.spawn(function()
                    if typeof(callback) == "function" then
                        local success, err = pcall(callback)

                        if not success then
                            warn("[TecX] Button callback error:", err)
                        end
                    end

                    if Button.Parent then
                        Tween(Button, {
                            BackgroundColor3 = Theme.Element
                        }, 0.2)
                    end
                end)
            end)

            return Button
        end

        function Tab:AddLabel(labelText)
            local Label = Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Text = labelText,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            }, Container)

            return Label
        end

        if #self.Tabs == 1 then
            SelectTab(Tab)
        end

        return Tab
    end

    return Window
end

return TecX
