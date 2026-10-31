local TecX = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/emir986598-bit/TecX/refs/heads/main/TecX.lua"
))()

local Window = TecX:CreateWindow({
    Name = "TecX V4"
})

local Home = Window:CreateTab("Home")
local Settings = Window:CreateTab("Settings")
local PlayerTab = Window:CreateTab("Player")

Home:AddLabel("QUICK ACTIONS")

Home:AddButton("Test Button", function()
    print("Button clicked")

    TecX:Notify({
        Title = "TecX",
        Content = "Operation completed.",
        Type = "success",
        Duration = 3
    })
end)

Home:AddToggle("Enable System", false, function(value)
    print("Toggle:", value)
end)

Home:AddSlider("Speed", 0, 100, 48, function(value)
    print("Speed:", value)
end)

Home:AddDropdown("Select Mode", {
    "Normal",
    "Advanced",
    "Professional"
}, function(value)
    print("Selected:", value)
end)

Settings:AddLabel("INTERFACE SETTINGS")

Settings:AddToggle("Show Notifications", true, function(value)
    print("Notifications:", value)
end)

Settings:AddButton("Test Notification", function()
    TecX:Notify({
        Title = "Notification",
        Content = "TecX notification system is working.",
        Type = "info",
        Duration = 4
    })
end)

PlayerTab:AddLabel("PLAYER SETTINGS")

PlayerTab:AddSlider("Camera FOV", 60, 120, 70, function(value)
    print("FOV:", value)
end)

PlayerTab:AddButton("Close Window", function()
    Window:Destroy()
end)
