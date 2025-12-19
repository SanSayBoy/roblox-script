-- GrinchiHUB - ESP + АИМБОТ НА ГОЛОВУ + ПЕРЕМЕЩАЕМЫЙ ИНТЕРФЕЙС + БОТЫ
-- Версия 1.2

local function Main()
    -- Ожидаем загрузку игры
    repeat task.wait() until game:IsLoaded()
    
    -- Подключаем сервисы
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    
    -- Ждем игрока
    local player = Players.LocalPlayer
    while not player do
        player = Players.LocalPlayer
        task.wait(0.1)
    end
    
    -- Ждем PlayerGui
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старые GUI
    for _, gui in pairs({playerGui, CoreGui, game.StarterGui}) do
        local old = gui:FindFirstChild("GrinchiHUB")
        if old then
            old:Destroy()
        end
    end
    
    -- СОЗДАЕМ ОСНОВНОЙ GUI ЭКРАНА
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GrinchiHUB"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    -- НАСТРОКИ
    local Settings = {
        ShowESP = true,
        ShowBox = true,
        ShowTracer = true,
        ShowInfo = true,
        Aimbot = true,
        TeamCheck = true,
        MaxDistance = 500,
        FOV = 250,
        Smoothness = 0.3,
        AutoShoot = false,
        ShowBots = true,   -- Новое: показывать ботов
        AimAtBots = true,  -- Новое: аим на ботов
        
        -- Цвета
        EnemyColor = Color3.fromRGB(255, 50, 50),
        TeamColor = Color3.fromRGB(50, 150, 255),
        VisibleColor = Color3.fromRGB(0, 255, 0),
        HiddenColor = Color3.fromRGB(150, 150, 150),
        TargetColor = Color3.fromRGB(255, 255, 0),
        BotColor = Color3.fromRGB(255, 100, 200)  -- Новый цвет для ботов
    }
    
    -- Переменные
    local Camera = Workspace.CurrentCamera
    local ESPObjects = {}
    local IsMenuOpen = false
    local TargetPlayer = nil
    local IsAiming = false
    local IsDragging = false
    local DragOffset = Vector2.new(0, 0)
    
    -- ================== СОЗДАЕМ ПЕРЕМЕЩАЕМУЮ КНОПКУ МЕНЮ ==================
    local menuButton = Instance.new("Frame")
    menuButton.Name = "MenuButton"
    menuButton.Size = UDim2.new(0, 130, 0, 45) -- Немного шире для текста
    menuButton.Position = UDim2.new(0, 20, 0, 20)
    menuButton.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    menuButton.BorderSizePixel = 2
    menuButton.BorderColor3 = Color3.fromRGB(0, 180, 80)
    menuButton.Active = true
    menuButton.ZIndex = 100
    menuButton.Parent = screenGui
    
    -- Текст кнопки
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "ButtonText"
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = "GrinchiHUB 👽"
    buttonText.TextColor3 = Color3.fromRGB(0, 255, 150)
    buttonText.Font = Enum.Font.GothamBold
    buttonText.TextSize = 18
    buttonText.TextStrokeTransparency = 0.5
    buttonText.TextStrokeColor3 = Color3.fromRGB(0, 100, 50)
    buttonText.Parent = menuButton
    
    -- Глоу эффект
    local glowEffect = Instance.new("UIStroke")
    glowEffect.Name = "GlowEffect"
    glowEffect.Color = Color3.fromRGB(0, 255, 150)
    glowEffect.Thickness = 2
    glowEffect.Transparency = 0.7
    glowEffect.Parent = menuButton
    
    -- Обработчики для кнопки
    local isMouseDown = false
    local mouseDownTime = 0
    local mouseDownPosition = Vector2.new(0, 0)
    
    menuButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMouseDown = true
            mouseDownTime = tick()
            mouseDownPosition = UserInputService:GetMouseLocation()
            
            -- Запоминаем смещение для перетаскивания
            DragOffset = Vector2.new(
                menuButton.AbsolutePosition.X - mouseDownPosition.X,
                menuButton.AbsolutePosition.Y - mouseDownPosition.Y
            )
            
            -- Визуальная обратная связь
            menuButton.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
            glowEffect.Transparency = 0.3
        end
    end)
    
    menuButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMouseDown = false
            
            -- Возвращаем нормальный цвет
            menuButton.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
            glowEffect.Transparency = 0.7
            
            -- Проверяем был ли это клик (не перетаскивание)
            local mouseUpPosition = UserInputService:GetMouseLocation()
            local distanceMoved = (mouseUpPosition - mouseDownPosition).Magnitude
            local timeHeld = tick() - mouseDownTime
            
            -- Если перемещение было маленькое и время удержания короткое - это клик
            if distanceMoved < 5 and timeHeld < 0.3 then
                OpenMenu()
            end
        end
    end)
    
    -- Обработка перетаскивания
    UserInputService.InputChanged:Connect(function(input)
        if isMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local newPos = UDim2.new(
                0, mousePos.X + DragOffset.X,
                0, mousePos.Y + DragOffset.Y
            )
            
            -- Ограничиваем в пределах экрана
            local maxX = screenGui.AbsoluteSize.X - menuButton.AbsoluteSize.X
            local maxY = screenGui.AbsoluteSize.Y - menuButton.AbsoluteSize.Y
            
            newPos = UDim2.new(
                0, math.clamp(mousePos.X + DragOffset.X, 0, maxX),
                0, math.clamp(mousePos.Y + DragOffset.Y, 0, maxY)
            )
            
            menuButton.Position = newPos
        end
    end)
    
    -- Анимация при наведении
    menuButton.MouseEnter:Connect(function()
        if not isMouseDown then
            buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
            glowEffect.Thickness = 3
            
            -- Плавное увеличение
            local tween = TweenService:Create(menuButton, TweenInfo.new(0.15), {
                Size = UDim2.new(0, 135, 0, 48)
            })
            tween:Play()
        end
    end)
    
    menuButton.MouseLeave:Connect(function()
        if not isMouseDown then
            buttonText.TextColor3 = Color3.fromRGB(0, 255, 150)
            glowEffect.Thickness = 2
            
            -- Возвращаем к исходному размеру
            local tween = TweenService:Create(menuButton, TweenInfo.new(0.15), {
                Size = UDim2.new(0, 130, 0, 45)
            })
            tween:Play()
        end
    end)
    
    -- ================== СОЗДАЕМ МЕНЮ ==================
    local mainMenu = Instance.new("Frame")
    mainMenu.Name = "MainMenu"
    mainMenu.Size = UDim2.new(0, 350, 0, 500) -- Увеличил высоту для новых настроек
    mainMenu.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainMenu.BorderSizePixel = 2
    mainMenu.BorderColor3 = Color3.fromRGB(0, 200, 100)
    mainMenu.Visible = false
    mainMenu.ZIndex = 50
    mainMenu.Active = true
    mainMenu.Draggable = true
    mainMenu.Parent = screenGui
    
    -- Заголовок меню
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    title.Text = "GrinchiHUB 👽 v1.2"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.fromRGB(0, 255, 150)
    title.Parent = mainMenu
    
    -- Кнопка закрытия меню
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = mainMenu
    
    -- Контейнер для настроек
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "SettingsScroll"
    scrollFrame.Size = UDim2.new(1, -20, 1, -90)
    scrollFrame.Position = UDim2.new(0, 10, 0, 70)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 100)
    scrollFrame.Parent = mainMenu
    
    -- Создаем улучшенные переключатели
    local function CreateToggle(name, description, yPos, settingName)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = settingName .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 60)
        toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        toggleFrame.BorderSizePixel = 1
        toggleFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
        toggleFrame.Parent = scrollFrame
        
        local labelFrame = Instance.new("Frame")
        labelFrame.Size = UDim2.new(0.7, 0, 1, 0)
        labelFrame.BackgroundTransparency = 1
        labelFrame.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0.6, 0)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = labelFrame
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -10, 0.4, 0)
        desc.Position = UDim2.new(0, 10, 0.6, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(180, 180, 180)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 12
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = labelFrame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = settingName .. "Button"
        toggleBtn.Size = UDim2.new(0, 60, 0, 30)
        toggleBtn.Position = UDim2.new(1, -70, 0.5, -15)
        toggleBtn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150, 50, 50)
        toggleBtn.Text = Settings[settingName] and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 14
        toggleBtn.Parent = toggleFrame
        
        -- Анимация при наведении
        toggleBtn.MouseEnter:Connect(function()
            local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 65, 0, 32)
            })
            tween:Play()
        end)
        
        toggleBtn.MouseLeave:Connect(function()
            local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 60, 0, 30)
            })
            tween:Play()
        end)
        
        toggleBtn.MouseButton1Click:Connect(function()
            Settings[settingName] = not Settings[settingName]
            
            -- Анимация переключения
            local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150, 50, 50),
                Text = Settings[settingName] and "ON" or "OFF"
            })
            tween:Play()
            
            print("[GrinchiHUB] " .. name .. ": " .. (Settings[settingName] and "ВКЛ" or "ВЫКЛ"))
        end)
        
        return toggleFrame
    end
    
    -- Добавляем переключатели
    local yPos = 0
    local toggles = {
        {"ESP Обводка", "Показывать обводку игроков", "ShowESP"},
        {"ESP Бокс", "Показывать бокс вокруг игрока", "ShowBox"},
        {"ESP Линия", "Линия от центра экрана к игроку", "ShowTracer"},
        {"ESP Инфо", "Показывать имя и дистанцию", "ShowInfo"},
        {"Аимбот", "Автоматическое наведение на голову", "Aimbot"},
        {"Проверка команды", "Игнорировать своих", "TeamCheck"},
        {"Автострельба", "Автоматическая стрельба по цели", "AutoShoot"},
        {"ESP Боты", "Показывать ботов", "ShowBots"},
        {"Аим на ботов", "Целиться в ботов", "AimAtBots"}
    }
    
    for i, toggleData in ipairs(toggles) do
        CreateToggle(toggleData[1], toggleData[2], yPos, toggleData[3])
        yPos = yPos + 65
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    
    -- ================== ФУНКЦИИ УПРАВЛЕНИЯ МЕНЮ ==================
    local function OpenMenu()
        if IsMenuOpen then return end
        
        IsMenuOpen = true
        
        -- Показываем меню
        mainMenu.Visible = true
        
        -- Анимация открытия
        mainMenu.Size = UDim2.new(0, 0, 0, 0)
        mainMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainMenu.BackgroundTransparency = 1
        
        local tween = TweenService:Create(mainMenu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 350, 0, 450),
            Position = UDim2.new(0.5, -175, 0.5, -225),
            BackgroundTransparency = 0
        })
        tween:Play()
        
        print("[GrinchiHUB] Меню открыто")
    end
    
    local function CloseMenu()
        if not IsMenuOpen then return end
        
        -- Анимация закрытия
        local tween = TweenService:Create(mainMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        
        tween.Completed:Wait()
        IsMenuOpen = false
        mainMenu.Visible = false
        
        print("[GrinchiHUB] Меню закрыто")
    end
    
    -- Кнопка закрытия меню
    closeBtn.MouseButton1Click:Connect(CloseMenu)
    
    -- Закрытие меню по ESC
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape and IsMenuOpen then
            CloseMenu()
        end
    end)
    
    -- ================== ФУНКЦИЯ ПОИСКА БОТОВ ==================
    local function GetAllBots()
        local bots = {}
        
        for _, model in pairs(Workspace:GetChildren()) do
            if model:IsA("Model") then
                local humanoid = model:FindFirstChild("Humanoid")
                local head = model:FindFirstChild("Head")
                
                -- Проверяем, это NPC (бот) а не игрок
                if humanoid and head and not Players:GetPlayerFromCharacter(model) then
                    table.insert(bots, {
                        model = model,
                        name = model.Name,
                        humanoid = humanoid,
                        head = head
                    })
                end
            end
        end
        
        return bots
    end
    
    -- ================== ФУНКЦИЯ ПРОВЕРКИ ВИДИМОСТИ ==================
    local function IsVisible(targetPart)
        if not player.Character then return false end
        
        local origin = Camera.CFrame.Position
        local target = targetPart.Position
        local direction = (target - origin).Unit
        local ray = Ray.new(origin, direction * Settings.MaxDistance)
        
        local ignoreList = {player.Character}
        
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(ignoreList, part)
                end
            end
        end
        
        local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
        
        if hit then
            local targetCharacter = targetPart:FindFirstAncestorOfClass("Model")
            if targetCharacter and (hit:IsDescendantOf(targetCharacter) or hit == targetPart) then
                return true
            end
        end
        
        return hit == nil or (position - origin).Magnitude > (target - origin).Magnitude
    end
    
    -- ================== ПОИСК ЦЕЛИ (ИГРОКИ + БОТЫ) ==================
    local function GetClosestTarget()
        local closestTarget = nil
        local closestDistance = Settings.FOV
        local mousePos = UserInputService:GetMouseLocation()
        
        -- Проверяем игроков
        for _, target in pairs(Players:GetPlayers()) do
            if target == player then continue end
            if not target.Character then continue end
            
            local humanoid = target.Character:FindFirstChild("Humanoid")
            local head = target.Character:FindFirstChild("Head")
            
            if not humanoid or humanoid.Health <= 0 then continue end
            if not head then continue end
            
            if Settings.TeamCheck then
                if target.Team and player.Team and target.Team == player.Team then
                    continue
                end
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if not onScreen then continue end
            
            if not IsVisible(head) then continue end
            
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local distance = (playerRoot.Position - head.Position).Magnitude
                if distance > Settings.MaxDistance then continue end
            end
            
            local distanceToMouse = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            
            if distanceToMouse < closestDistance then
                closestDistance = distanceToMouse
                closestTarget = target
            end
        end
        
        -- Проверяем ботов (если включено)
        if Settings.AimAtBots then
            local allBots = GetAllBots()
            
            for _, bot in pairs(allBots) do
                local head = bot.head
                local humanoid = bot.humanoid
                
                if not humanoid or humanoid.Health <= 0 then continue end
                if not head then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if not onScreen then continue end
                
                if not IsVisible(head) then continue end
                
                local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if playerRoot then
                    local distance = (playerRoot.Position - head.Position).Magnitude
                    if distance > Settings.MaxDistance then continue end
                end
                
                local distanceToMouse = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                
                if distanceToMouse < closestDistance then
                    closestDistance = distanceToMouse
                    closestTarget = bot.model
                end
            end
        end
        
        return closestTarget
    end
    
    -- ================== АИМБОТ ==================
    task.spawn(function()
        while screenGui and screenGui.Parent do
            RunService.RenderStepped:Wait()
            
            if Settings.Aimbot and player.Character then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local closest = GetClosestTarget()
                    
                    if closest then
                        TargetPlayer = closest
                        
                        -- Проверяем, это игрок или бот
                        local head = nil
                        
                        if typeof(closest) == "Instance" and closest:IsA("Model") then
                            -- Это может быть бот или модель игрока
                            head = closest:FindFirstChild("Head")
                        elseif closest:IsA("Player") and closest.Character then
                            -- Это игрок
                            head = closest.Character:FindFirstChild("Head")
                        end
                        
                        if head then
                            local currentCF = Camera.CFrame
                            local targetCF = CFrame.new(Camera.CFrame.Position, head.Position)
                            Camera.CFrame = currentCF:Lerp(targetCF, Settings.Smoothness)
                        end
                    else
                        TargetPlayer = nil
                    end
                else
                    TargetPlayer = nil
                end
            end
        end
    end)
    
    -- ================== ESP СИСТЕМА ==================
    local function CreateESP(target, isBot)
        if target == player then return end
        
        local espData = {
            target = target,
            isBot = isBot,
            box = nil,
            tracer = nil,
            info = nil,
            isVisible = true
        }
        
        -- Бокс
        if Settings.ShowBox then
            local box = Instance.new("Frame")
            box.Name = (isBot and "Bot_" or "Player_") .. target.Name .. "_Box"
            box.Size = UDim2.new(0, 50, 0, 80)
            box.BackgroundTransparency = 0.8
            box.BackgroundColor3 = isBot and Settings.BotColor or Settings.EnemyColor
            box.BorderSizePixel = 2
            box.BorderColor3 = Color3.fromRGB(255, 255, 255)
            box.ZIndex = 5
            box.Visible = Settings.ShowESP and Settings.ShowBox and (isBot and Settings.ShowBots or true)
            box.Parent = screenGui
            
            espData.box = box
        end
        
        -- Трассер
        if Settings.ShowTracer then
            local tracer = Instance.new("Frame")
            tracer.Name = (isBot and "Bot_" or "Player_") .. target.Name .. "_Tracer"
            tracer.BackgroundColor3 = isBot and Settings.BotColor or Settings.EnemyColor
            tracer.BorderSizePixel = 0
            tracer.ZIndex = 4
            tracer.Visible = Settings.ShowESP and Settings.ShowTracer and (isBot and Settings.ShowBots or true)
            tracer.Parent = screenGui
            
            espData.tracer = tracer
        end
        
        -- Информация
        if Settings.ShowInfo then
            local info = Instance.new("Frame")
            info.Name = (isBot and "Bot_" or "Player_") .. target.Name .. "_Info"
            info.Size = UDim2.new(0, 150, 0, 40)
            info.BackgroundTransparency = 0.7
            info.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            info.BorderSizePixel = 1
            info.BorderColor3 = Color3.fromRGB(100, 100, 100)
            info.ZIndex = 6
            info.Visible = Settings.ShowESP and Settings.ShowInfo and (isBot and Settings.ShowBots or true)
            info.Parent = screenGui
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -10, 0.5, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = (isBot and "[BOT] " or "") .. target.Name
            nameLabel.TextColor3 = isBot and Settings.BotColor or Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = info
            
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, -10, 0.5, 0)
            distanceLabel.Position = UDim2.new(0, 5, 0.5, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Text = "0m"
            distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = 12
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
            distanceLabel.Parent = info
            
            espData.info = info
            espData.nameLabel = nameLabel
            espData.distanceLabel = distanceLabel
        end
        
        ESPObjects[target] = espData
    end
    
    local function RemoveESP(target)
        if ESPObjects[target] then
            if ESPObjects[target].box then
                ESPObjects[target].box:Destroy()
            end
            if ESPObjects[target].tracer then
                ESPObjects[target].tracer:Destroy()
            end
            if ESPObjects[target].info then
                ESPObjects[target].info:Destroy()
            end
            ESPObjects[target] = nil
        end
    end
    
    -- Функция обновления ESP для ботов
    local function UpdateBotESP()
        if not Settings.ShowBots then return end
        
        local allBots = GetAllBots()
        local currentBots = {}
        
        -- Создаем ESP для новых ботов
        for _, bot in pairs(allBots) do
            if not ESPObjects[bot.model] then
                CreateESP(bot.model, true)
            end
            currentBots[bot.model] = true
        end
        
        -- Удаляем ESP для исчезнувших ботов
        for target, espData in pairs(ESPObjects) do
            if espData.isBot and not currentBots[target] then
                RemoveESP(target)
            end
        end
    end
    
    -- ================== ОБНОВЛЕНИЕ ESP ==================
    task.spawn(function()
        while screenGui and screenGui.Parent do
            task.wait(0.033)
            
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local playerPos = playerRoot and playerRoot.Position
            
            -- Обновляем ESP для ботов
            UpdateBotESP()
            
            for target, espData in pairs(ESPObjects) do
                local character = espData.isBot and target or target.Character
                
                if character then
                    local head = character:FindFirstChild("Head")
                    local root = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChild("Humanoid")
                    
                    if head and root and (not humanoid or humanoid.Health > 0) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        local isVisible = IsVisible(head)
                        
                        espData.isVisible = isVisible and onScreen
                        
                        local color = espData.isBot and Settings.BotColor or Settings.EnemyColor
                        
                        if not espData.isBot and Settings.TeamCheck and target.Team and player.Team and target.Team == player.Team then
                            color = Settings.TeamColor
                        elseif not isVisible then
                            color = Settings.HiddenColor
                        elseif TargetPlayer == target then
                            color = Settings.TargetColor
                        elseif isVisible then
                            color = espData.isBot and Settings.BotColor or Settings.VisibleColor
                        end
                        
                        -- Бокс
                        if espData.box and espData.box.Parent then
                            espData.box.BackgroundColor3 = color
                            espData.box.BorderColor3 = Color3.fromRGB(
                                math.min(color.R * 255 + 50, 255),
                                math.min(color.G * 255 + 50, 255),
                                math.min(color.B * 255 + 50, 255)
                            )
                            
                            local shouldShow = Settings.ShowESP and Settings.ShowBox and 
                                              (espData.isBot and Settings.ShowBots or true)
                            
                            if onScreen and shouldShow then
                                espData.box.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 40)
                                espData.box.Visible = true
                            else
                                espData.box.Visible = false
                            end
                        end
                        
                        -- Трассер
                        if espData.tracer and espData.tracer.Parent then
                            espData.tracer.BackgroundColor3 = color
                            
                            local shouldShow = Settings.ShowESP and Settings.ShowTracer and 
                                              (espData.isBot and Settings.ShowBots or true)
                            
                            if onScreen and shouldShow then
                                local center = Vector2.new(
                                    screenGui.AbsoluteSize.X / 2,
                                    screenGui.AbsoluteSize.Y / 2
                                )
                                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                                
                                local length = (center - targetPos).Magnitude
                                local angle = math.atan2(targetPos.Y - center.Y, targetPos.X - center.X)
                                
                                espData.tracer.Size = UDim2.new(0, length, 0, 2)
                                espData.tracer.Position = UDim2.new(0, center.X, 0, center.Y)
                                espData.tracer.Rotation = math.deg(angle)
                                espData.tracer.Visible = true
                            else
                                espData.tracer.Visible = false
                            end
                        end
                        
                        -- Информация
                        if espData.info and espData.info.Parent then
                            local shouldShow = Settings.ShowESP and Settings.ShowInfo and 
                                              (espData.isBot and Settings.ShowBots or true)
                            
                            if onScreen and shouldShow then
                                if playerPos then
                                    local distance = (playerPos - root.Position).Magnitude
                                    espData.distanceLabel.Text = math.floor(distance) .. "m"
                                    espData.nameLabel.TextColor3 = color
                                end
                                
                                espData.info.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y + 50)
                                espData.info.Visible = true
                            else
                                espData.info.Visible = false
                            end
                        end
                    else
                        if espData.box then espData.box.Visible = false end
                        if espData.tracer then espData.tracer.Visible = false end
                        if espData.info then espData.info.Visible = false end
                    end
                else
                    if espData.box then espData.box.Visible = false end
                    if espData.tracer then espData.tracer.Visible = false end
                    if espData.info then espData.info.Visible = false end
                end
            end
        end
    end)
    
    -- ================== ОБРАБОТКА ИГРОКОВ ==================
    Players.PlayerAdded:Connect(function(newPlayer)
        CreateESP(newPlayer, false)
    end)
    
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        RemoveESP(leavingPlayer)
    end)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            CreateESP(otherPlayer, false)
        end
    end
    
    -- ================== ИНФОРМАЦИОННАЯ ПАНЕЛЬ ==================
    local infoPanel = Instance.new("Frame")
    infoPanel.Name = "InfoPanel"
    infoPanel.Size = UDim2.new(0, 220, 0, 120) -- Увеличил высоту
    infoPanel.Position = UDim2.new(1, -230, 0, 10)
    infoPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoPanel.BackgroundTransparency = 0.6
    infoPanel.BorderSizePixel = 2
    infoPanel.BorderColor3 = Color3.fromRGB(0, 200, 100)
    infoPanel.Visible = true
    infoPanel.ZIndex = 80
    infoPanel.Parent = screenGui
    
    local hubTitle = Instance.new("TextLabel")
    hubTitle.Size = UDim2.new(1, -10, 0.25, 0)
    hubTitle.Position = UDim2.new(0, 5, 0, 5)
    hubTitle.BackgroundTransparency = 1
    hubTitle.Text = "GrinchiHUB 👽 v1.2"
    hubTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
    hubTitle.Font = Enum.Font.GothamBold
    hubTitle.TextSize = 18
    hubTitle.TextStrokeTransparency = 0.5
    hubTitle.TextStrokeColor3 = Color3.fromRGB(0, 100, 50)
    hubTitle.Parent = infoPanel
    
    local aimStatus = Instance.new("TextLabel")
    aimStatus.Name = "AimStatus"
    aimStatus.Size = UDim2.new(1, -10, 0.2, 0)
    aimStatus.Position = UDim2.new(0, 5, 0.25, 0)
    aimStatus.BackgroundTransparency = 1
    aimStatus.Text = "Аимбот: ВЫКЛ"
    aimStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
    aimStatus.Font = Enum.Font.GothamBold
    aimStatus.TextSize = 14
    aimStatus.Parent = infoPanel
    
    local targetStatus = Instance.new("TextLabel")
    targetStatus.Name = "TargetStatus"
    targetStatus.Size = UDim2.new(1, -10, 0.2, 0)
    targetStatus.Position = UDim2.new(0, 5, 0.45, 0)
    targetStatus.BackgroundTransparency = 1
    targetStatus.Text = "Цель: НЕТ"
    targetStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetStatus.Font = Enum.Font.Gotham
    targetStatus.TextSize = 14
    targetStatus.Parent = infoPanel
    
    local playerCount = Instance.new("TextLabel")
    playerCount.Name = "PlayerCount"
    playerCount.Size = UDim2.new(1, -10, 0.2, 0)
    playerCount.Position = UDim2.new(0, 5, 0.65, 0)
    playerCount.BackgroundTransparency = 1
    playerCount.Text = "Игроков: 0 | Ботов: 0"
    playerCount.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerCount.Font = Enum.Font.Gotham
    playerCount.TextSize = 12
    playerCount.Parent = infoPanel
    
    local fpsCounter = Instance.new("TextLabel")
    fpsCounter.Name = "FPSCounter"
    fpsCounter.Size = UDim2.new(1, -10, 0.2, 0)
    fpsCounter.Position = UDim2.new(0, 5, 0.85, 0)
    fpsCounter.BackgroundTransparency = 1
    fpsCounter.Text = "FPS: 60"
    fpsCounter.TextColor3 = Color3.fromRGB(150, 200, 255)
    fpsCounter.Font = Enum.Font.Gotham
    fpsCounter.TextSize = 12
    fpsCounter.Parent = infoPanel
    
    -- Обновление информационной панели
    local frameCount = 0
    local lastTime = tick()
    
    task.spawn(function()
        while screenGui and screenGui.Parent do
            task.wait(0.5)
            
            -- FPS
            frameCount = frameCount + 1
            local currentTime = tick()
            if currentTime - lastTime >= 1 then
                local fps = math.floor(frameCount / (currentTime - lastTime))
                fpsCounter.Text = "FPS: " .. fps
                frameCount = 0
                lastTime = currentTime
            end
            
            aimStatus.Text = "Аимбот: " .. (Settings.Aimbot and "ВКЛ" or "ВЫКЛ")
            aimStatus.TextColor3 = Settings.Aimbot and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            
            if TargetPlayer then
                local isBot = false
                for target, espData in pairs(ESPObjects) do
                    if target == TargetPlayer then
                        isBot = espData.isBot
                        break
                    end
                end
                
                targetStatus.Text = "Цель: " .. TargetPlayer.Name .. (isBot and " [BOT]" or "")
                targetStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                targetStatus.Text = "Цель: НЕТ"
                targetStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
            
            local playerCountNum = 0
            local botCountNum = 0
            
            for target, espData in pairs(ESPObjects) do
                if espData.isBot then
                    botCountNum = botCountNum + 1
                else
                    playerCountNum = playerCountNum + 1
                end
            end
            
            playerCount.Text = "Игроков: " .. playerCountNum .. " | Ботов: " .. botCountNum
        end
    end)
    
    -- ================== ВЫВОД ИНФОРМАЦИИ ==================
    print("\n")
    print("╔══════════════════════════════════════════════════╗")
    print("║            GrinchiHUB 👽 v1.2 - ЗАГРУЖЕН!       ║")
    print("╚══════════════════════════════════════════════════╝")
    print("🎯 Аимбот: Зажми ПРАВУЮ кнопку мыши")
    print("🤖 Добавлена поддержка БОТОВ!")
    print("🔧 ESP для ботов: Розовый цвет")
    print("🎨 Настройки ботов в меню")
    print("📊 Инфопанель: Показывает количество ботов")
    print("⚡ Наслаждайся игрой!")
    print("\n")
    
    return {
        OpenMenu = OpenMenu,
        CloseMenu = CloseMenu,
        GetSettings = function() return Settings end
    }
end

-- Запускаем с обработкой ошибок
local success, err = pcall(Main)

if not success then
    warn("❌ GrinchiHUB: Ошибка загрузки:", err)
else
    print("✅ GrinchiHUB успешно загружен!")
end