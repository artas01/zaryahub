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

-- Основной фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 320)  -- Увеличил высоту для нового заголовка
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromHex("#141921")
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Закругленные углы и обводка (остаётся без изменений)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(128, 128, 128)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Новый заголовок Zarya Hub
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 60)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundColor3 = Color3.fromHex("#6375c8")  -- Цвет как у кнопок
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = "ZARYA HUB"  -- Название хаба
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBlack  -- Более жирный шрифт
titleLabel.TextSize = 28
titleLabel.TextStrokeTransparency = 0.7  -- Лёгкая обводка текста
titleLabel.Parent = titleFrame

-- Поле ввода ключа (сдвигаем позицию ниже из-за нового заголовка)
local keyInput = Instance.new("TextBox")
keyInput.Name = ""
keyInput.PlaceholderText = "Enter your key here..."
keyInput.Size = UDim2.new(0.8, 0, 0, 40)
keyInput.Position = UDim2.new(0.1, 0, 0.4, 0)  -- Изменил Y с 0.3 на 0.4
-- ... (остальные свойства поля ввода)

-- Кнопки (также сдвигаем позиции)
local getKeyButton = Instance.new("TextButton")
getKeyButton.Text = "GET KEY"
getKeyButton.Position = UDim2.new(0.1, 0, 0.7, 0)  -- Было 0.6
-- ... (остальные свойства кнопки)

local checkKeyButton = Instance.new("TextButton")
checkKeyButton.Text = "CHECK KEY"
checkKeyButton.Position = UDim2.new(0.55, 0, 0.7, 0)  -- Было 0.6
-- ... (остальные свойства кнопки)

-- Футер (без изменений)
local footer = Instance.new("TextLabel")
footer.Text = "www.roblox-scripter.com"
-- ... (остальные свойства футера)

-- Модифицированный обработчик с анимацией
checkKeyButton.MouseButton1Click:Connect(function()
    if keyInput.Text:lower() == "pizza" then
        -- Устанавливаем текст успешного ввода
        keyInput.Text = ""
        keyInput.PlaceholderText = "SUCCESS! Loading Zarya Hub..."
        keyInput.PlaceholderColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Анимация растворения для всех элементов
        local fadeElements = {}
        for _, element in ipairs(mainFrame:GetDescendants()) do
            if element:IsA("GuiObject") then
                table.insert(fadeElements, element)
            end
        end
        
        -- Параллельное исчезновение всех элементов
        for _, element in ipairs(fadeElements) do
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                TweenService:Create(element, TweenInfo.new(0.7), {TextTransparency = 1}):Play()
            end
            if element:IsA("Frame") or element:IsA("TextButton") or element:IsA("TextBox") then
                TweenService:Create(element, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()
            end
            if element:IsA("UIStroke") then
                TweenService:Create(element, TweenInfo.new(0.7), {Transparency = 1}):Play()
            end
        end
        
        wait(0.8)
        screenGui:Destroy()
        
        -- Загрузка хаба
        loadstring(game:HttpGet('https://raw.githubusercontent.com/artas01/artas01/refs/heads/main/OrdenHubs'))()
    else
        -- Обработка неверного ключа (без изменений)
    end
end)
