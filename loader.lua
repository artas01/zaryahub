local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Таблица соответствия Game ID и скриптов
local GameScripts = {
    [2007050448] = {
        name = "Ragdoll Engine",
        script = "https://raw.githubusercontent.com/artas01/zaryahub/main/loader.lua"
    },
    [7523893339] = {
        name = "Windy City RP",
        script = "https://raw.githubusercontent.com/artas01/zaryahub/refs/heads/main/windycityrp"
    },
    [987654321] = {
        name = "Example Game 2",
        script = "https://example.com/script2.lua"
    }
}

-- Получаем текущий Game ID
local currentGameId = game.GameId ~= 0 and game.GameId or game.PlaceId
print("Текущий Game ID:", currentGameId)

-- Проверяем, поддерживается ли игра
local gameData = GameScripts[currentGameId]
if not gameData then
    warn("❌ Этот Game ID не поддерживается:", currentGameId)
    return
end

print("Загружается Zarya Hub для:", gameData.name)

-- Создаем основной экран
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZaryaHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Основной фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 320)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromHex("#141921")
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Закругленные углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Обводка
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(128, 128, 128)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Заголовок с названием игры
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 40)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundColor3 = Color3.new(0.000000, 0.000000, 0.000000)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = "ZARYA HUB | " .. gameData.name
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 24
titleLabel.TextStrokeTransparency = 0.7
titleLabel.Parent = titleFrame

-- Поле ввода ключа
local keyInput = Instance.new("TextBox")
keyInput.Name = ""
keyInput.PlaceholderText = "Enter your key here..."
keyInput.Size = UDim2.new(0.8, 0, 0, 40)
keyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
keyInput.BackgroundColor3 = Color3.fromHex("#000106")
keyInput.TextColor3 = Color3.new(1, 1, 1)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 18
keyInput.Text = ""
keyInput.ClearTextOnFocus = false
keyInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = keyInput

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(100, 100, 100)
inputStroke.Thickness = 1
inputStroke.Parent = keyInput

-- Кнопка Get Key
local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKeyButton"
getKeyButton.Text = "GET KEY"
getKeyButton.Size = UDim2.new(0.35, 0, 0, 40)
getKeyButton.Position = UDim2.new(0.1, 0, 0.7, 0)
getKeyButton.BackgroundColor3 = Color3.fromHex("#6375c8")
getKeyButton.TextColor3 = Color3.new(1, 1, 1)
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.TextSize = 18
getKeyButton.Parent = mainFrame

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 6)
getKeyCorner.Parent = getKeyButton

-- Кнопка Check Key
local checkKeyButton = Instance.new("TextButton")
checkKeyButton.Name = "CheckKeyButton"
checkKeyButton.Text = "CHECK KEY"
checkKeyButton.Size = UDim2.new(0.35, 0, 0, 40)
checkKeyButton.Position = UDim2.new(0.55, 0, 0.7, 0)
checkKeyButton.BackgroundColor3 = Color3.fromHex("#6375c8")
checkKeyButton.TextColor3 = Color3.new(1, 1, 1)
checkKeyButton.Font = Enum.Font.GothamBold
checkKeyButton.TextSize = 18
checkKeyButton.Parent = mainFrame

local checkKeyCorner = Instance.new("UICorner")
checkKeyCorner.CornerRadius = UDim.new(0, 6)
checkKeyCorner.Parent = checkKeyButton

-- Футер
local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Text = "www.roblox-scripter.com"
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundTransparency = 1
footer.TextColor3 = Color3.new(1, 1, 1)
footer.Font = Enum.Font.Gotham
footer.TextSize = 14
footer.Parent = mainFrame

-- Всплывающее уведомление
local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.Size = UDim2.new(0, 300, 0, 50)
notification.Position = UDim2.new(0.5, -150, 0.5, -220)
notification.AnchorPoint = Vector2.new(0.5, 0.5)
notification.BackgroundColor3 = Color3.fromHex("#141921")
notification.BorderSizePixel = 0
notification.Visible = false
notification.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notification

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = Color3.fromRGB(128, 128, 128)
notifStroke.Thickness = 2
notifStroke.Parent = notification

local notifText = Instance.new("TextLabel")
notifText.Name = "Text"
notifText.Text = "Ссылка на ключ систему была скопирована"
notifText.Size = UDim2.new(1, -20, 1, -20)
notifText.Position = UDim2.new(0, 10, 0, 10)
notifText.BackgroundTransparency = 1
notifText.TextColor3 = Color3.new(1, 1, 1)
notifText.Font = Enum.Font.Gotham
notifText.TextSize = 14
notifText.Parent = notification

-- Функционал для перемещения GUI
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

-- Функционал кнопки Get Key
getKeyButton.MouseButton1Click:Connect(function()
    setclipboard("http://ya.ru")
    
    notification.Visible = true
    local tween = TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -150, 0.5, -180)}
    )
    tween:Play()
    
    wait(3)
    
    TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, -150, 0.5, -220)}
    ):Play()
    wait(0.3)
    notification.Visible = false
end)

-- Функционал кнопки Check Key
checkKeyButton.MouseButton1Click:Connect(function()
    if keyInput.Text:lower() == "pizza" then
        keyInput.Text = ""
        keyInput.PlaceholderText = "SUCCESS! Loading "..gameData.name.."..."
        keyInput.PlaceholderColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Анимация растворения
        local fadeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad),
            {BackgroundTransparency = 1}
        )
        
        for _, element in ipairs(mainFrame:GetDescendants()) do
            if element:IsA("GuiObject") then
                if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                    TweenService:Create(element, TweenInfo.new(0.7), {TextTransparency = 1}):Play()
                end
                TweenService:Create(element, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()
            end
            if element:IsA("UIStroke") then
                TweenService:Create(element, TweenInfo.new(0.7), {Transparency = 1}):Play()
            end
        end
        
        fadeTween:Play()
        fadeTween.Completed:Wait()
        screenGui:Destroy()
        
        -- Загрузка скрипта для текущей игры
        local success, err = pcall(function()
            loadstring(game:HttpGet(gameData.script))()
        end)
        
        if not success then
            warn("Ошибка загрузки скрипта для", gameData.name..":", err)
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
