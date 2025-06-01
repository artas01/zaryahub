local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local CascadeUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SquidGurr/CascadeUI/main/CascadeUI.lua'))()

local Config = {
    ESP = {
        Enabled = true,
        BoxESP = true,
        NameESP = true,
        SkeletonESP = true,
        DroneESP = true,
        
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(0, 255, 255),
        DroneColor = Color3.fromRGB(255, 0, 255),
        
        BoxThickness = 1,
        SkeletonThickness = 1,
        
        MaxDistance = 500,
        TeamCheck = true,
        
        TextSize = 14,
        TextOutline = true,
        
        RefreshRate = 0.05
    }
}

local Window = CascadeUI:CreateWindow({
    Title = "Operations Siege Script",
    Size = UDim2.new(0, 400, 0, 300),
    Position = UDim2.new(0.5, -200, 0.5, -150)
})

local ESPTab = Window:CreateTab("ESP")
local SettingsTab = Window:CreateTab("Settings")

local PlayerESP = {}
local DroneESP = {}

local SkeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}
}

local R15ToR6 = {
    ["Head"] = "Head",
    ["UpperTorso"] = "Torso",
    ["LowerTorso"] = "Torso",
    ["RightUpperArm"] = "Right Arm",
    ["RightLowerArm"] = "Right Arm",
    ["RightHand"] = "Right Arm",
    ["LeftUpperArm"] = "Left Arm",
    ["LeftLowerArm"] = "Left Arm",
    ["LeftHand"] = "Left Arm",
    ["RightUpperLeg"] = "Right Leg",
    ["RightLowerLeg"] = "Right Leg",
    ["RightFoot"] = "Right Leg",
    ["LeftUpperLeg"] = "Left Leg",
    ["LeftLowerLeg"] = "Left Leg",
    ["LeftFoot"] = "Left Leg"
}

local function CreateESP(player)
    local esp = {
        Player = player,
        Connections = {}
    }
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Config.ESP.BoxColor
    esp.Box.Thickness = Config.ESP.BoxThickness
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Color = Config.ESP.NameColor
    esp.Name.Size = Config.ESP.TextSize
    esp.Name.Center = true
    esp.Name.Outline = Config.ESP.TextOutline
    
    esp.Skeleton = {}
    
    return esp
end

local function CreateDroneESP(drone)
    local esp = {
        Drone = drone,
        Connections = {}
    }

    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Config.ESP.DroneColor
    esp.Box.Thickness = Config.ESP.BoxThickness
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Label = Drawing.new("Text")
    esp.Label.Visible = false
    esp.Label.Color = Config.ESP.DroneColor
    esp.Label.Size = Config.ESP.TextSize
    esp.Label.Center = true
    esp.Label.Outline = Config.ESP.TextOutline
    esp.Label.Text = "Drone"
    
    return esp
end

local function RemoveESP(player)
    local esp = PlayerESP[player]
    if not esp then return end
    
    if esp.Box then esp.Box:Remove() end
    if esp.Name then esp.Name:Remove() end
    
    for _, line in pairs(esp.Skeleton) do
        if line then line:Remove() end
    end

    for _, connection in pairs(esp.Connections) do
        if connection then connection:Disconnect() end
    end
    
    PlayerESP[player] = nil
end

local function RemoveDroneESP(drone)
    local esp = DroneESP[drone]
    if not esp then return end
    
    if esp.Box then esp.Box:Remove() end
    if esp.Label then esp.Label:Remove() end

    for _, connection in pairs(esp.Connections) do
        if connection then connection:Disconnect() end
    end
    
    DroneESP[drone] = nil
end

local function GetLimbPosition(character, limbName)
    local limb = character:FindFirstChild(limbName)
    if not limb then
        limb = character:FindFirstChild(R15ToR6[limbName])
    end
    
    if limb and limb:IsA("BasePart") then
        return limb.Position
    end
    return nil
end

local function UpdatePlayerESP()
    for player, esp in pairs(PlayerESP) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            RemoveESP(player)
            continue
        end
        
        if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
            esp.Box.Visible = false
            esp.Name.Visible = false
            for _, line in pairs(esp.Skeleton) do
                if line then line.Visible = false end
            end
            continue
        end
        
        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then continue end
        
        if humanoid.Health <= 0 then
            esp.Box.Visible = false
            esp.Name.Visible = false
            for _, line in pairs(esp.Skeleton) do
                if line then line.Visible = false end
            end
            continue
        end
        
        local position = humanoidRootPart.Position
        local screenPosition, onScreen = Camera:WorldToViewportPoint(position)
        
        local distance = (Camera.CFrame.Position - position).Magnitude
        if not onScreen or distance > Config.ESP.MaxDistance then
            esp.Box.Visible = false
            esp.Name.Visible = false
            for _, line in pairs(esp.Skeleton) do
                if line then line.Visible = false end
            end
            continue
        end
        
        if Config.ESP.BoxESP and Config.ESP.Enabled then
            local size = character:GetExtentsSize()
            local scaleFactor = 1 / (distance * 0.05)
            scaleFactor = math.clamp(scaleFactor, 0.1, 1)
            
            local boxSize = Vector2.new(
                math.max(10, size.X * scaleFactor),
                math.max(20, size.Y * scaleFactor)
            )
            
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(
                screenPosition.X - boxSize.X / 2,
                screenPosition.Y - boxSize.Y / 2
            )
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        if Config.ESP.NameESP and Config.ESP.Enabled then
            esp.Name.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            esp.Name.Position = Vector2.new(
                screenPosition.X,
                screenPosition.Y - (esp.Box.Size.Y / 2) - 15
            )
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Config.ESP.SkeletonESP and Config.ESP.Enabled then
            for i, connection in ipairs(SkeletonConnections) do
                local startLimb = connection[1]
                local endLimb = connection[2]
                
                local startPos = GetLimbPosition(character, startLimb)
                local endPos = GetLimbPosition(character, endLimb)
                
                if startPos and endPos then
                    local startScreenPos, startOnScreen = Camera:WorldToViewportPoint(startPos)
                    local endScreenPos, endOnScreen = Camera:WorldToViewportPoint(endPos)
                    
                    if not esp.Skeleton[i] then
                        esp.Skeleton[i] = Drawing.new("Line")
                        esp.Skeleton[i].Thickness = Config.ESP.SkeletonThickness
                        esp.Skeleton[i].Color = Config.ESP.SkeletonColor
                        esp.Skeleton[i].Transparency = 1
                    end
                    
                    if startOnScreen and endOnScreen then
                        esp.Skeleton[i].From = Vector2.new(startScreenPos.X, startScreenPos.Y)
                        esp.Skeleton[i].To = Vector2.new(endScreenPos.X, endScreenPos.Y)
                        esp.Skeleton[i].Visible = true
                    else
                        esp.Skeleton[i].Visible = false
                    end
                elseif esp.Skeleton[i] then
                    esp.Skeleton[i].Visible = false
                end
            end
        else
            for _, line in pairs(esp.Skeleton) do
                if line then line.Visible = false end
            end
        end
    end
end

local function FindDrones()
    for drone, esp in pairs(DroneESP) do
        if not drone or not drone:IsDescendantOf(game) then
            RemoveDroneESP(drone)
        end
    end
    
    if Config.ESP.DroneESP and Config.ESP.Enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj.Name:lower():find("drone") or obj.Name:lower():find("uav")) and 
               obj:IsA("Model") and 
               not DroneESP[obj] then
                
                local primaryPart = obj.PrimaryPart
                if not primaryPart then
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            primaryPart = part
                            break
                        end
                    end
                end
                
                if primaryPart then
                    DroneESP[obj] = CreateDroneESP(obj)
                end
            end
        end
    end
end

local function UpdateDroneESP()
    for drone, esp in pairs(DroneESP) do
        if not drone or not drone:IsDescendantOf(game) then
            RemoveDroneESP(drone)
            continue
        end
        
        local primaryPart = drone.PrimaryPart
        if not primaryPart then
            for _, part in pairs(drone:GetDescendants()) do
                if part:IsA("BasePart") then
                    primaryPart = part
                    break
                end
            end
            
            if not primaryPart then
                continue
            end
        end
        
        local position = primaryPart.Position
        local screenPosition, onScreen = Camera:WorldToViewportPoint(position)
        
        local distance = (Camera.CFrame.Position - position).Magnitude
        if not onScreen or distance > Config.ESP.MaxDistance or not Config.ESP.DroneESP then
            esp.Box.Visible = false
            esp.Label.Visible = false
            continue
        end
        
        local size = drone:GetExtentsSize()
        if size.Magnitude < 1 then
            size = Vector3.new(3, 3, 3)
        end
        
        local scaleFactor = 1 / (distance * 0.05)
        scaleFactor = math.clamp(scaleFactor, 0.1, 1)
        
        local boxSize = Vector2.new(
            math.max(10, size.X * scaleFactor),
            math.max(10, size.Y * scaleFactor)
        )
        
        esp.Box.Size = boxSize
        esp.Box.Position = Vector2.new(
            screenPosition.X - boxSize.X / 2,
            screenPosition.Y - boxSize.Y / 2
        )
        esp.Box.Visible = true
        
        esp.Label.Text = "Drone [" .. math.floor(distance) .. "m]"
        esp.Label.Position = Vector2.new(
            screenPosition.X,
            screenPosition.Y - boxSize.Y / 2 - 15
        )
        esp.Label.Visible = true
    end
end

local ESPSection = ESPTab:CreateSection("ESP Options")

local ESPToggle = ESPSection:CreateToggle({
    Name = "ESP Master Toggle",
    Default = Config.ESP.Enabled,
    Callback = function(Value)
        Config.ESP.Enabled = Value
    end
})

local BoxESPToggle = ESPSection:CreateToggle({
    Name = "Box ESP",
    Default = Config.ESP.BoxESP,
    Callback = function(Value)
        Config.ESP.BoxESP = Value
    end
})

local NameESPToggle = ESPSection:CreateToggle({
    Name = "Name ESP",
    Default = Config.ESP.NameESP,
    Callback = function(Value)
        Config.ESP.NameESP = Value
    end
})

local SkeletonESPToggle = ESPSection:CreateToggle({
    Name = "Skeleton ESP",
    Default = Config.ESP.SkeletonESP,
    Callback = function(Value)
        Config.ESP.SkeletonESP = Value
    end
})

local DroneESPToggle = ESPSection:CreateToggle({
    Name = "Drone ESP",
    Default = Config.ESP.DroneESP,
    Callback = function(Value)
        Config.ESP.DroneESP = Value
    end
})

local TeamCheckToggle = ESPSection:CreateToggle({
    Name = "Team Check",
    Default = Config.ESP.TeamCheck,
    Callback = function(Value)
        Config.ESP.TeamCheck = Value
    end
})

local BoxColorPicker = ESPSection:CreateColorPicker({
    Name = "Box Color",
    Default = Config.ESP.BoxColor,
    Callback = function(Color)
        Config.ESP.BoxColor = Color
    end
})

local SkeletonColorPicker = ESPSection:CreateColorPicker({
    Name = "Skeleton Color",
    Default = Config.ESP.SkeletonColor,
    Callback = function(Color)
        Config.ESP.SkeletonColor = Color
    end
})

local DroneColorPicker = ESPSection:CreateColorPicker({
    Name = "Drone Color",
    Default = Config.ESP.DroneColor,
    Callback = function(Color)
        Config.ESP.DroneColor = Color
    end
})

local ESPDistanceSlider = ESPSection:CreateSlider({
    Name = "ESP Distance",
    Min = 100,
    Max = 1000,
    Default = Config.ESP.MaxDistance,
    Callback = function(Value)
        Config.ESP.MaxDistance = Value
    end
})

local SettingsSection = SettingsTab:CreateSection("Settings")

local scriptRunning = true

local DestroyButton = SettingsSection:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        
        scriptRunning = false
        
        for player, esp in pairs(PlayerESP) do
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            for _, line in pairs(esp.Skeleton) do
                if line then line:Remove() end
            end
        end
        
        table.clear(PlayerESP)
        
        for drone, esp in pairs(DroneESP) do
            if esp.Box then esp.Box:Remove() end
            if esp.Label then esp.Label:Remove() end
        end
        
        table.clear(DroneESP)
        
        for _, connection in pairs(getconnections(RunService.RenderStepped)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(getconnections(RunService.Heartbeat)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(getconnections(UserInputService.InputBegan)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(getconnections(Players.PlayerAdded)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(getconnections(Players.PlayerRemoving)) do
            connection:Disconnect()
        end
        
        Window:Destroy()
        
        collectgarbage("collect")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Script Terminated",
            Text = "Operations Siege Script has been terminated",
            Duration = 3
        })
    end
})

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        PlayerESP[player] = CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        PlayerESP[player] = CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

local function SetupRoundChangeDetection()
    if ReplicatedStorage:FindFirstChild("RoundState") then
        ReplicatedStorage.RoundState.Changed:Connect(function()
            for player, esp in pairs(PlayerESP) do
                if player ~= LocalPlayer then
                    RemoveESP(player)
                    PlayerESP[player] = CreateESP(player)
                end
            end
            
            for drone, esp in pairs(DroneESP) do
                RemoveDroneESP(drone)
            end
            FindDrones()
        end)
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                if PlayerESP[player] then
                    RemoveESP(player)
                end
                PlayerESP[player] = CreateESP(player)
                
                character.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        task.delay(1, function()
                            if not PlayerESP[player] then
                                PlayerESP[player] = CreateESP(player)
                            end
                        end)
                    end
                end)
            end)
        end
    end
    
    spawn(function()
        while wait(5) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not PlayerESP[player] then
                    PlayerESP[player] = CreateESP(player)
                end
            end
            
            FindDrones()
        end
    end)
end

SetupRoundChangeDetection()

spawn(function()
    while scriptRunning do
        if Config.ESP.Enabled then
            UpdatePlayerESP()
            UpdateDroneESP()
        else
            for _, esp in pairs(PlayerESP) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                for _, line in pairs(esp.Skeleton) do
                    if line then line.Visible = false end
                end
            end
            
            for _, esp in pairs(DroneESP) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Label then esp.Label.Visible = false end
            end
        end
        wait(Config.ESP.RefreshRate)
    end
end)

spawn(function()
    while scriptRunning and wait(3) do
        if Config.ESP.DroneESP and Config.ESP.Enabled then
            FindDrones()
        end
    end
end)

spawn(function()
    while scriptRunning and wait(5) do
        for player, esp in pairs(PlayerESP) do
            if not player or not player:IsDescendantOf(game) then
                RemoveESP(player)
            end
        end
        
        collectgarbage("collect")
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        Window:Toggle()
    end
 end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Script Loaded",
    Text = "Operations Siege Script - Press K to toggle GUI",
    Duration = 5
})

print("Operations Siege Script loaded successfully!")
