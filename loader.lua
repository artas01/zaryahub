local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Проверка Game ID
local supportedGameIds = {
    [2007050448] = true,  -- Ваш Game ID
    -- Добавляйте другие ID по необходимости
}

local currentGameId = game.GameId ~= 0 and game.GameId or game.PlaceId
print("Текущий Game ID:", currentGameId)

if not supportedGameIds[currentGameId] then
    warn("❌ Этот Game ID не поддерживается:", currentGameId)
    return
end

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Основной фрейм (центрированный)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromHex("#141921")
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Стилизация фрейма
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(128, 128, 128)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Элементы GUI
local title = Instance.new("TextLabel", mainFrame)
title.Text = "KEY SYSTEM"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

local keyInput = Instance.new("TextBox", mainFrame)
keyInput.Text = "" 
keyInput.PlaceholderText = "Enter your key here..."
keyInput.Size = UDim2.new(0.8, 0, 0, 40)
keyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
keyInput.BackgroundColor3 = Color3.fromHex("#000106")
keyInput.TextColor3 = Color3.new(1, 1, 1)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 18
keyInput.ClearTextOnFocus = false

Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", keyInput).Color = Color3.fromRGB(100, 100, 100)

local getKeyButton = Instance.new("TextButton", mainFrame)
getKeyButton.Text = "GET KEY"
getKeyButton.Size = UDim2.new(0.35, 0, 0, 40)
getKeyButton.Position = UDim2.new(0.1, 0, 0.6, 0)
getKeyButton.BackgroundColor3 = Color3.fromHex("#6375c8")
getKeyButton.TextColor3 = Color3.new(1, 1, 1)
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.TextSize = 18

local checkKeyButton = Instance.new("TextButton", mainFrame)
checkKeyButton.Text = "CHECK KEY"
checkKeyButton.Size = UDim2.new(0.35, 0, 0, 40)
checkKeyButton.Position = UDim2.new(0.55, 0, 0.6, 0)
checkKeyButton.BackgroundColor3 = Color3.fromHex("#6375c8")
checkKeyButton.TextColor3 = Color3.new(1, 1, 1)
checkKeyButton.Font = Enum.Font.GothamBold
checkKeyButton.TextSize = 18

Instance.new("UICorner", getKeyButton).CornerRadius = UDim.new(0, 6)
Instance.new("UICorner", checkKeyButton).CornerRadius = UDim.new(0, 6)

local footer = Instance.new("TextLabel", mainFrame)
footer.Text = "www.roblox-scripter.com"
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundTransparency = 1
footer.TextColor3 = Color3.new(1, 1, 1)
footer.Font = Enum.Font.Gotham
footer.TextSize = 14

-- Всплывающее уведомление (позиция выше основного GUI)
local notification = Instance.new("Frame", screenGui)
notification.Size = UDim2.new(0, 300, 0, 50)
notification.Position = UDim2.new(0.5, -150, 0.5, -220) -- Выше основного GUI
notification.AnchorPoint = Vector2.new(0.5, 0.5)
notification.BackgroundColor3 = Color3.fromHex("#141921")
notification.Visible = false

Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", notification).Color = Color3.fromRGB(128, 128, 128)

local notifText = Instance.new("TextLabel", notification)
notifText.Text = "Ссылка на ключ систему была скопирована"
notifText.Size = UDim2.new(1, -20, 1, -20)
notifText.Position = UDim2.new(0, 10, 0, 10)
notifText.BackgroundTransparency = 1
notifText.TextColor3 = Color3.new(1, 1, 1)
notifText.Font = Enum.Font.Gotham
notifText.TextSize = 14

-- Функционал перемещения GUI
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Обработчики кнопок
getKeyButton.MouseButton1Click:Connect(function()
    setclipboard("http://ya.ru")
    
    notification.Visible = true
    local tween = TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0.5, -180)})
    tween:Play()
    
    wait(3)
    
    TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0.5, -220)}):Play()
    wait(0.3)
    notification.Visible = false
end)

checkKeyButton.MouseButton1Click:Connect(function()
    if keyInput.Text:lower() == "pizza" then
        keyInput.Text = ""
        keyInput.PlaceholderText = "Ключ верный! Загрузка..."
        keyInput.PlaceholderColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Анимация исчезновения GUI
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        tween:Play()
        
        tween.Completed:Wait()
        screenGui:Destroy()
        
        -- Загрузка основного скрипта
        local success, err = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/artas01/artas01/refs/heads/main/OrdenHubs'))()
        end)
        
        if not success then
            warn("Ошибка загрузки скрипта:", err)
        end
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "Неверный ключ!"
        keyInput.PlaceholderColor3 = Color3.fromRGB(255, 0, 0)
        wait(2)
        keyInput.PlaceholderText = "Enter your key here..."
        keyInput.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
    end
end)
