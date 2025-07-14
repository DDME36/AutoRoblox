-- 🌱 Grow Garden Pro Script | Ultimate Farming System
-- Version: 3.0 | Created by AI Assistant
-- Features: Full Auto Farming, ESP, Auto-Pathfinding, Modern UI, NPC Management
-- Usage: loadstring(game:HttpGet("URL"))()

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Anti-AFK System
local antiAFK = true
Players.LocalPlayer.Idled:Connect(function()
    if antiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Anti-AFK: Prevented idle kick")
    end
end)

-- Global Variables
local scriptEnabled = true
local autoEgg = false
local autoShop = false
local autoSeed = false
local autoSell = false
local autoRebirth = false
local autoUpgrade = false
local autoCollect = false
local autoHatch = false
local autoNPC = false
local autoPlant = false -- New: Auto-plant seeds
local autoHarvest = false -- New: Auto-harvest crops
local teleportEnabled = false
local speedEnabled = false
local jumpEnabled = false
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false -- New: ESP for objects
local autoPathfinding = false -- New: Auto-pathfinding
local selectedNPC = nil -- New: Selected NPC for auto-buy

-- Game Objects Storage
local gameObjects = {
    eggs = {},
    shops = {},
    seeds = {},
    upgrades = {},
    pets = {},
    collectibles = {},
    teleports = {},
    npcs = {},
    plots = {}, -- New: Farming plots
    crops = {} -- New: Harvestable crops
}

-- UI Themes
local themes = {
    dark = {
        primary = Color3.fromRGB(25, 25, 35),
        secondary = Color3.fromRGB(35, 35, 45),
        accent = Color3.fromRGB(0, 162, 255),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        danger = Color3.fromRGB(231, 76, 60),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 190)
    },
    light = {
        primary = Color3.fromRGB(200, 200, 200),
        secondary = Color3.fromRGB(220, 220, 220),
        accent = Color3.fromRGB(0, 120, 255),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        danger = Color3.fromRGB(231, 76, 60),
        text = Color3.fromRGB(0, 0, 0),
        textSecondary = Color3.fromRGB(100, 100, 100)
    }
}
local currentTheme = "dark"
local colors = themes[currentTheme]

-- Notification System
local function notify(title, text, icon, duration)
    StarterGui:SetCore("SendNotification", {
        Title = (icon or "🌱") .. " " .. title,
        Text = text,
        Duration = duration or 4
    })
end

-- Object Scanner System
local function scanForObjects()
    local workspace = game:GetService("Workspace")
    
    -- Clear previous data
    for key, _ in pairs(gameObjects) do
        gameObjects[key] = {}
    end
    
    -- Scan workspace for objects
    for _, obj in pairs(workspace:GetChildren()) do
        local objName = obj.Name:lower()
        if objName:find("egg") then
            table.insert(gameObjects.eggs, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("shop") or objName:find("store") or objName:find("upgrade") then
            table.insert(gameObjects.shops, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("seed") or objName:find("plant") then
            table.insert(gameObjects.seeds, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("pet") or objName:find("animal") then
            table.insert(gameObjects.pets, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("coin") or objName:find("money") or objName:find("cash") or objName:find("gold") then
            table.insert(gameObjects.collectibles, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("teleport") or objName:find("portal") or objName:find("spawn") then
            table.insert(gameObjects.teleports, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("npc") or objName:find("vendor") or objName:find("merchant") then
            table.insert(gameObjects.npcs, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("plot") or objName:find("farm") then
            table.insert(gameObjects.plots, {name = obj.Name, object = obj, path = obj:GetFullName()})
        elseif objName:find("crop") or objName:find("harvest") then
            table.insert(gameObjects.crops, {name = obj.Name, object = obj, path = obj:GetFullName()})
        end
    end
    
    print("🔍 Object Scanner: Found " .. #gameObjects.eggs .. " eggs, " .. #gameObjects.shops .. " shops, " .. #gameObjects.seeds .. " seeds, " .. #gameObjects.npcs .. " NPCs, " .. #gameObjects.plots .. " plots, " .. #gameObjects.crops .. " crops")
end

-- Auto-scan on load
scanForObjects()

-- ESP System
local function createESP(object, color, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. object.Name
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or object.Name
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = billboard
    
    return billboard
end

local function toggleESP(enabled)
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("ESP_") then
            gui:Destroy()
        end
    end
    
    if enabled then
        for _, npc in pairs(gameObjects.npcs) do
            if npc.object and npc.object.Parent then
                createESP(npc.object, colors.accent, "NPC: " .. npc.name)
            end
        end
        for _, crop in pairs(gameObjects.crops) do
            if crop.object and crop.object.Parent then
                createESP(crop.object, colors.success, "Crop: " .. crop.name)
            end
        end
        for _, plot in pairs(gameObjects.plots) do
            if plot.object and plot.object.Parent then
                createESP(plot.object, colors.warning, "Plot: " .. plot.name)
            end
        end
    end
end

-- Pathfinding System
local function moveToPosition(targetPos)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    
    local humanoid = LocalPlayer.Character.Humanoid
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
    
    local waypoints = path:GetWaypoints()
    for _, waypoint in pairs(waypoints) do
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait()
    end
end

-- Modern UI Creation
local function createModernUI()
    -- Remove existing GUI
    local existingGui = PlayerGui:FindFirstChild("GrowGardenPro")
    if existingGui then existingGui:Destroy() end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GrowGardenPro"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Desktop Icon (Minimized State)
    local desktopIcon = Instance.new("ImageButton")
    desktopIcon.Name = "DesktopIcon"
    desktopIcon.Size = UDim2.new(0, 60, 0, 60)
    desktopIcon.Position = UDim2.new(0, 20, 0, 20)
    desktopIcon.BackgroundColor3 = colors.primary
    desktopIcon.BorderSizePixel = 0
    desktopIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    desktopIcon.Parent = screenGui
    desktopIcon.Visible = false
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 15)
    iconCorner.Parent = desktopIcon
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0,-Struct, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🌱"
    iconLabel.TextColor3 = colors.text
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = desktopIcon
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 850, 0, 650)
    mainFrame.Position = UDim2.new(0.5, -425, 0.5, -325)
    mainFrame.BackgroundColor3 = colors.primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame
    
    -- Drop Shadow Effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = colors.secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 20)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🌱 Grow Garden Pro | Ultimate System"
    titleLabel.TextColor3 = colors.text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Status Indicator
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(0, 200, 0.5, -5)
    statusDot.BackgroundColor3 = colors.success
    statusDot.BorderSizePixel = 0
    statusDot.Parent = titleBar
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 5)
    statusCorner.Parent = statusDot
    
    -- Control Buttons
    local dragging, dragStart, startPos
    local function createControlButton(text, position, color, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 30, 0, 30)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = colors.text
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = titleBar
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        return button
    end
    
    -- Minimize Button
    createControlButton("−", UDim2.new(1, -100, 0.5, -15), colors.warning, function()
        mainFrame.Visible = false
        desktopIcon.Visible = true
        
        desktopIcon.Size = UDim2.new(0, 0, 0, 0)
       protectorate
        desktopIcon.Visible = true
        TweenService:Create(desktopIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
    end)
    
    -- Maximize Button
    createControlButton("□", UDim2.new(1, -65, 0.5, -15), colors.accent, function()
        local targetSize = mainFrame.Size == UDim2.new(0, 850, 0, 650) and UDim2.new(0, 1000, 0, 750) or UDim2.new(0, 850, 0, 650)
        local targetPos = mainFrame.Size == UDim2.new(0, 850, 0, 650) and UDim2.new(0.5, -500, 0.5, -375) or UDim2.new(0.5, -425, 0.5, -325)
        
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = targetSize,
            Position = targetPos
        }):Play()
    end)
    
    -- Close Button
    createControlButton("×", UDim2.new(1, -30, 0.5, -15), colors.danger, function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        wait(0.3)
        screenGui:Destroy()
        scriptEnabled = false
        notify("Grow Garden Pro", "สคริปต์ถูกปิดแล้ว", "❌")
    end)
    
    -- Desktop Icon Click
    desktopIcon.MouseButton1Click:Connect(function()
        desktopIcon.Visible = false
        mainFrame.Visible = true
        
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 850, 0, 650),
            Position = UDim2.new(0.5, -425, 0.5, -325)
        }):Play()
    end)
    
    -- Tab System
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = colors.secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer
    
    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -110)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Tab Creation Function
    local activeTab = nil
    local function createTab(name, icon, content)
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.new(0, 150, 1, 0)
        tab.BackgroundColor3 = colors.primary
        tab.BorderSizePixel = 0
        tab.Text = icon .. " " .. name
        tab.TextColor3 = colors.textSecondary
        tab.TextScaled = true
        tab.Font = Enum.Font.Gotham
        tab.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tab
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 6
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        contentLayout.Changed:Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        tab.MouseButton1Click:Connect(function()
            for _, child in pairs(contentFrame:GetChildren()) do
                if child.Name:find("Content") then
                    child.Visible = false
                end
            end
            tabContent.Visible = true
            if activeTab then
                activeTab.BackgroundColor3 = colors.primary
                activeTab.TextColor3 = colors.textSecondary
            end
            tab.BackgroundColor3 = colors.accent
            tab.TextColor3 = colors.text
            activeTab = tab
        end)
        
        if content then content(tabContent) end
        return tab, tabContent
    end
    
    -- Main Tab
    local function createMainTab(parent)
        local function createSection(title, items)
            local section = Instance.new("Frame")
            section.Size = UDim2.new(1, 0, 0, 220)
            section.BackgroundColor3 = colors.secondary
            section.BorderSizePixel = 0
            section.Parent = parent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 12)
            sectionCorner.Parent = section
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, 0, 0, 40)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = title
            sectionTitle.TextColor3 = colors.text
            sectionTitle.TextScaled = true
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = section
            
            local sectionContent = Instance.new("Frame")
            sectionContent.Size = UDim2.new(1, -20, 1, -50)
            sectionContent.Position = UDim2.new(0, 10, 0, 45)
            sectionContent.BackgroundTransparency = 1
            sectionContent.Parent = section
            
            local sectionLayout = Instance.new("UIGridLayout")
            sectionLayout.CellSize = UDim2.new(0, 180, 0, 50)
            sectionLayout.CellPadding = UDim2.new(0, 10, 0, 10)
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Parent = sectionContent
            
            for _, item in pairs(items) do
                local button = Instance.new("TextButton")
                button.BackgroundColor3 = item.enabled and colors.success or colors.primary
                button.BorderSizePixel = 0
                button.Text = item.text
                button.TextColor3 = colors.text
                button.TextScaled = true
                button.Font = Enum.Font.Gotham
                button.Parent = sectionContent
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)
                buttonCorner.Parent = button
                
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new(item.enabled and colors.success or colors.primary, colors.secondary)
                gradient.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    item.enabled = not item.enabled
                    if item.callback then item.callback(item.enabled) end
                    button.BackgroundColor3 = item.enabled and colors.success or colors.primary
                    gradient.Color = ColorSequence.new(item.enabled and colors.success or colors.primary, colors.secondary)
                end)
                
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
                end)
                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = item.enabled and colors.success or colors.primary}):Play()
                end)
            end
            return section
        end
        
        createSection("🚜 ระบบฟาร์มอัตโนมัติ", {
            {text = "🌱 ปลูกผักอัตโนมัติ", enabled = autoPlant, callback = function(state)
                autoPlant = state
                notify("ระบบปลูกผัก", autoPlant and "เปิดใช้งาน" or "ปิดใช้งาน", "🌱")
            end},
            {text = "🌾 เก็บเกี่ยวอัตโนมัติ", enabled = autoHarvest, callback = function(state)
                autoHarvest = state
                notify("ระบบเก็บเกี่ยว", autoHarvest and "เปิดใช้งาน" or "ปิดใช้งาน", "🌾")
            end},
            {text = "💰 ขายผักอัตโนมัติ", enabled = autoSell, callback = function(state)
                autoSell = state
                notify("ระบบขาย", autoSell and "เปิดใช้งาน" or "ปิดใช้งาน", "💰")
            end},
            {text = "🥚 ซื้อไข่อัตโนมัติ", enabled = autoEgg, callback = function(state)
                autoEgg = state
                notify("ระบบไข่", autoEgg and "เปิดใช้งาน" or "ปิดใช้งาน", "🥚")
            end},
            {text = "🧑‍🌾 ซื้อจาก NPC อัตโนมัติ", enabled = autoNPC, callback = function(state)
                autoNPC = state
                notify("ระบบ NPC", autoNPC and "เปิดใช้งาน" or "ปิดใช้งาน", "🧑‍🌾")
            end}
        })
        
        createSection("⚡ ฟีเจอร์ขั้นสูง", {
            {text = "🏪 ซื้อร้านค้าอัตโนมัติ", enabled = autoShop, callback = function(state)
                autoShop = state
                notify("ระบบร้านค้า", autoShop and "เปิดใช้งาน" or "ปิดใช้งาน", "🏪")
            end},
            {text = "🔄 เกิดใหม่อัตโนมัติ", enabled = autoRebirth, callback = function(state)
                autoRebirth = state
                notify("ระบบเกิดใหม่", autoRebirth and "เปิดใช้งาน" or "ปิดใช้งาน", "🔄")
            end},
            {text = "📈 อัปเกรดอัตโนมัติ", enabled = autoUpgrade, callback = function(state)
                autoUpgrade = state
                notify("ระบบอัปเกรด", autoUpgrade and "เปิดใช้งาน" or "ปิดใช้งาน", "📈")
            end},
            {text = "🪙 เก็บเหรียญอัตโนมัติ", enabled = autoCollect, callback = function(state)
                autoCollect = state
                notify("ระบบเก็บเหรียญ", autoCollect and "เปิดใช้งาน" or "ปิดใช้งาน", "🪙")
            end},
            {text = "🥚 ฟักไข่อัตโนมัติ", enabled = autoHatch, callback = function(state)
                autoHatch = state
                notify("ระบบฟักไข่", autoHatch and "เปิดใช้งาน" or "ปิดใช้งาน", "🥚")
            end}
        })
        
        createSection("🏃 การเคลื่อนไหว", {
            {text = "💨 ความเร็วเพิ่ม", enabled = speedEnabled, callback = function(state)
                speedEnabled = state
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and 50 or 16
                end
                notify("ความเร็ว", speedEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "💨")
            end},
            {text = "🦘 กระโดดสูง", enabled = jumpEnabled, callback = function(state)
                jumpEnabled = state
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = jumpEnabled and 100 or 50
                end
                notify("กระโดด", jumpEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "🦘")
            end},
            {text = "✈️ บินได้", enabled = flyEnabled, callback = function(state)
                flyEnabled = state
                notify("การบิน", flyEnabled and "เปิดใช้งาน (WASD)" or "ปิดใช้งาน", "✈️")
            end},
            {text = "👻 ผ่านกำแพง", enabled = noclipEnabled, callback = function(state)
                noclipEnabled = state
                notify("ผ่านกำแพง", noclipEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "👻")
            end},
            {text = "🚶 Pathfinding", enabled = autoPathfinding, callback = function(state)
                autoPathfinding = state
                notify("Pathfinding", autoPathfinding and "เปิดใช้งาน" or "ปิดใช้งาน", "🚶")
            end}
        })
        
        createSection("👁️‍🗨️ การมองเห็น", {
            {text = "🔦 ESP", enabled = espEnabled, callback = function(state)
                espEnabled = state
                toggleESP(espEnabled)
                notify("ESP", espEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "🔦")
            end}
        })
    end
    
    -- Object Explorer Tab
    local function createExplorerTab(parent)
        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, 0, 0, 40)
        searchBox.BackgroundColor3 = colors.secondary
        searchBox.BorderSizePixel = 0
        searchBox.Text = "🔍 ค้นหาวัตถุ..."
        searchBox.TextColor3 = colors.text
        searchBox.TextScaled = true
        searchBox.Font = Enum.Font.Gotham
        searchBox.Parent = parent
        
        local searchCorner = Instance.new("UICorner")
        searchCorner.CornerRadius = UDim.new(0, 8)
        searchCorner.Parent = searchBox
        
        local npcDropdown = Instance.new("TextButton")
        npcDropdown.Size = UDim2.new(1, 0, 0, 40)
        npcDropdown.Position = UDim2.new(0, 0, 0, 50)
        npcDropdown.BackgroundColor3 = colors.accent
        npcDropdown.BorderSizePixel = 0
        npcDropdown.Text = "เลือก NPC..."
        npcDropdown.TextColor3 = colors.text
        npcDropdown.TextScaled = true
        npcDropdown.Font = Enum.Font.Gotham
        npcDropdown.Parent = parent
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 8)
        dropdownCorner.Parent = npcDropdown
        
        local dropdownList = Instance.new("ScrollingFrame")
        dropdownList.Size = UDim2.new(1, 0, 0, 150)
        dropdownList.Position = UDim2.new(0, 0, 0, 90)
        dropdownList.BackgroundColor3 = colors.secondary
        dropdownList.BorderSizePixel = 0
        dropdownList.Visible = false
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
        dropdownList.Parent = parent
        
        local dropdownLayout = Instance.new("UIListLayout")
        dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownLayout.Padding = UDim.new(0, 2)
        dropdownLayout.Parent = dropdownList
        
        local function populateDropdown()
            for _, child in pairs(dropdownList:GetChildren()) do
                if child ~= dropdownLayout then
                    child:Destroy()
                end
            end
            
            for _, npc in pairs(gameObjects.npcs) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 30)
                item.BackgroundColor3 = selectedNPC == npc.name and colors.success or colors.primary
                item.BorderSizePixel = 0
                item.Text = npc.name
                item.TextColor3 = colors.text
                item.TextScaled = true
                item.Font = Enum.Font.Gotham
                item.Parent = dropdownList
                
                item.MouseButton1Click:Connect(function()
                    selectedNPC = npc.name
                    npcDropdown.Text = "NPC: " .. npc.name
                    dropdownList.Visible = false
                    for _, btn in pairs(dropdownList:GetChildren()) do
                        if btn ~= dropdownLayout then
                            btn.BackgroundColor3 = btn.Text == npc.name and colors.success or colors.primary
                        end
                    end
                end)
            end
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
        end
        
        npcDropdown.MouseButton1Click:Connect(function()
            dropdownList.Visible = not dropdownList.Visible
            populateDropdown()
        end)
        
        local objectList = Instance.new("ScrollingFrame")
        objectList.Size = UDim2.new(1, 0, 1, -140)
        objectList.Position = UDim2.new(0, 0, 0, 140)
        objectList.BackgroundColor3 = colors.secondary
        objectList.BorderSizePixel = 0
        objectList.Parent = parent
        objectList.ScrollBarThickness = 6
        objectList.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = objectList
        
        local function populateList(filter)
            for _, child in pairs(objectList:GetChildren()) do
                if child ~= listLayout then
                    child:Destroy()
                end
            end
            
            for category, objects in pairs(gameObjects) do
                if #objects > 0 then
                    local categoryHeader = Instance.new("TextLabel")
                    categoryHeader.Size = UDim2.new(1, 0, 0, 30)
                    categoryHeader.BackgroundColor3 = colors.primary
                    categoryHeader.BorderSizePixel = 0
                    categoryHeader.Text = "📁 " .. category:upper()
                    categoryHeader.TextColor3 = colors.accent
                    categoryHeader.TextScaled = true
                    categoryHeader.Font = Enum.Font.GothamBold
                    categoryHeader.TextXAlignment = Enum.TextXAlignment.Left
                    categoryHeader.Parent = objectList
                    
                    for _, obj in pairs(objects) do
                        if not filter or obj.name:lower():find(filter:lower()) then
                            local item = Instance.new("TextButton")
                            item.Size = UDim2.new(1, 0, 0, 25)
                            item.BackgroundColor3 = colors.primary
                            item.BorderSizePixel = 0
                            item.Text = "  • " .. obj.name
                            item.TextColor3 = colors.text
                            item.TextScaled = true
                            item.Font = Enum.Font.Gotham
                            item.TextXAlignment = Enum.TextXAlignment.Left
                            item.Parent = objectList
                            
                            item.MouseButton1Click:Connect(function()
                                if obj.object and obj.object.Parent then
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local targetPos = obj.object:IsA("Model") and obj.object.PrimaryPart and obj.object.PrimaryPart.Position or obj.object.Position
                                        if targetPos then
                                            if autoPathfinding then
                                                moveToPosition(targetPos)
                                            else
                                                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                                            end
                                            notify("เทเลพอร์ต", "ไปยัง " .. obj.name, "🚀")
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
            objectList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end
        
        searchBox.FocusLost:Connect(function()
            populateList(searchBox.Text ~= "🔍 ค้นหาวัตถุ..." and searchBox.Text or nil)
        end)
        
        populateList()
        
        local rescanBtn = Instance.new("TextButton")
        rescanBtn.Size = UDim2.new(1, 0, 0, 40)
        rescanBtn.Position = UDim2.new(0, 0, 1, -40)
        rescanBtn.BackgroundColor3 = colors.accent
        rescanBtn.BorderSizePixel = 0
        rescanBtn.Text = "🔄 สแกนใหม่"
        rescanBtn.TextColor3 = colors.text
        rescanBtn.TextScaled = true
        rescanBtn.Font = Enum.Font.GothamBold
        rescanBtn.Parent = parent
        
        local rescanCorner = Instance.new("UICorner")
        rescanCorner.CornerRadius = UDim.new(0, 8)
        rescanCorner.Parent = rescanBtn
        
        rescanBtn.MouseButton1Click:Connect(function()
            scanForObjects()
            populateList()
            populateDropdown()
            notify("Object Scanner", "สแกนเสร็จแล้ว", "🔍")
        end)
    end
    
    -- Stats Tab
    local function createStatsTab(parent)
        local statsContainer = Instance.new("Frame")
        statsContainer.Size = UDim2.new(1, 0, 1, 0)
        statsContainer.BackgroundTransparency = 1
        statsContainer.Parent = parent
        
        local statsLayout = Instance.new("UIListLayout")
        statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        statsLayout.Padding = UDim.new(0, 15)
        statsLayout.Parent = statsContainer
        
        local function createStatCard(title, value, icon, color)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 80)
            card.BackgroundColor3 = color
            card.BorderSizePixel = 0
            card.Parent = statsContainer
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 12)
            cardCorner.Parent = card
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(0, 60, 1, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = icon
            iconLabel.TextColor3 = colors.text
            iconLabel.TextScaled = true
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.Parent = card
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -80, 0, 30)
            titleLabel.Position = UDim2.new(0, 70, 0, 10)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = colors.text
            titleLabel.TextScaled = true
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = card
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, -80, 0, 30)
            valueLabel.Position = UDim2.new(0, 70, 0, 40)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = value
            valueLabel.TextColor3 = colors.textSecondary
            valueLabel.TextScaled = true
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.Parent = card
            
            return card, valueLabel
        end
        
        local statCards = {
            createStatCard("ไข่ที่พบ", tostring(#gameObjects.eggs), "🥚", colors.success),
            createStatCard("ร้านค้าที่พบ", tostring(#gameObjects.shops), "🏪", colors.accent),
            createStatCard("เมล็ดพันธุ์ที่พบ", tostring(#gameObjects.seeds), "🌱", colors.warning),
            createStatCard("NPC ที่พบ", tostring(#gameObjects.npcs), "🧑‍🌾", colors.danger),
            createStatCard("แปลงปลูกที่พบ", tostring(#gameObjects.plots), "🚜", colors.primary),
            createStatCard("พืชที่เก็บได้", tostring(#gameObjects.crops), "🌾", colors.success),
            createStatCard("สถานะสคริปต์", scriptEnabled and "กำลังทำงาน" or "หยุดทำงาน", "⚡", colors.primary)
        }
        
        RunService.Heartbeat:Connect(function()
            if math.random(1, 300) == 1 then
                statCards[1][2].Text = tostring(#gameObjects.eggs)
                statCards[2][2].Text = tostring(#gameObjects.shops)
                statCards[3][2].Text = tostring(#gameObjects.seeds)
                statCards[4][2].Text = tostring(#gameObjects.npcs)
                statCards[5][2].Text = tostring(#gameObjects.plots)
                statCards[6][2].Text = tostring(#gameObjects.crops)
                statCards[7][2].Text = scriptEnabled and "กำลังทำงาน" or "หยุดทำงาน"
            end
        end)
    end
    
    -- Settings Tab
    local function createSettingsTab(parent)
        local settingsContainer = Instance.new("Frame")
        settingsContainer.Size = UDim2.new(1, 0, 1, 0)
        settingsContainer.BackgroundTransparency = 1
        settingsContainer.Parent = parent
        
        local settingsLayout = Instance.new("UIListLayout")
        settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        settingsLayout.Padding = UDim.new(0, 15)
        settingsLayout.Parent = settingsContainer
        
        local function createSetting(name, description, isToggle, callback)
            local setting = Instance.new("Frame")
            setting.Size = UDim2.new(1, 0, 0, 80)
            setting.BackgroundColor3 = colors.secondary
            setting.BorderSizePixel = 0
            setting.Parent = settingsContainer
            
            local settingCorner = Instance.new("UICorner")
            settingCorner.CornerRadius = UDim.new(0, 12)
            settingCorner.Parent = setting
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.7, 0, 0, 30)
            nameLabel.Position = UDim2.new(0, 15, 0, 10)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = colors.text
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = setting
            
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(0.7, 0, 0, 30)
            descLabel.Position = UDim2.new(0, 15, 0, 40)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = colors.textSecondary
            descLabel.TextScaled = true
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = setting
            
            if isToggle then
                local toggle = Instance.new("TextButton")
                toggle.Size = UDim2.new(0, 60, 0, 30)
                toggle.Position = UDim2.new(1, -80, 0.5, -15)
                toggle.BackgroundColor3 = colors.success
                toggle.BorderSizePixel = 0
                toggle.Text = "เปิด"
                toggle.TextColor3 = colors.text
                toggle.TextScaled = true
                toggle.Font = Enum.Font.GothamBold
                toggle.Parent = setting
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 15)
                toggleCorner.Parent = toggle
                
                toggle.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                
                return setting, toggle
            else
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0, 80, 0, 30)
                button.Position = UDim2.new(1, -95, 0.5, -15)
                button.BackgroundColor3 = colors.accent
                button.BorderSizePixel = 0
                button.Text = "ตั้งค่า"
                button.TextColor3 = colors.text
                button.TextScaled = true
                button.Font = Enum.Font.GothamBold
                button.Parent = setting
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)
                buttonCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                
                return setting, button
            end
        end
        
        createSetting("ป้องกัน AFK", "ป้องกันการถูกเตะออกจากเกม", true, function()
            antiAFK = not antiAFK
            notify("Anti-AFK", antiAFK and "เปิดใช้งาน" or "ปิดใช้งาน", "🛡️")
        end)
        
        createSetting("การแจ้งเตือน", "แสดงการแจ้งเตือนเมื่อทำงาน", true, function()
            notify("การแจ้งเตือน", "ทดสอบการแจ้งเตือน", "🔔")
        end)
        
        createSetting("ธีม", "เปลี่ยนระหว่าง Dark/Light Theme", true, function()
            currentTheme = currentTheme == "dark" and "light" or "dark"
            colors = themes[currentTheme]
            mainFrame.BackgroundColor3 = colors.primary
            tabContainer.BackgroundColor3 = colors.secondary
            notify("ธีม", "เปลี่ยนเป็น " .. currentTheme, "🎨")
        end)
        
        createSetting("บันทึกการตั้งค่า", "บันทึกการตั้งค่าอัตโนมัติ", false, function()
            local settings = {
                autoPlant = autoPlant,
                autoHarvest = autoHarvest,
                autoSell = autoSell,
                autoEgg = autoEgg,
                autoNPC = autoNPC,
                autoShop = autoShop,
                autoRebirth = autoRebirth,
                autoUpgrade = autoUpgrade,
                autoCollect = autoCollect,
                autoHatch = autoHatch,
                speedEnabled = speedEnabled,
                jumpEnabled = jumpEnabled,
                flyEnabled = flyEnabled,
                noclipEnabled = noclipEnabled,
                espEnabled = espEnabled,
                autoPathfinding = autoPathfinding,
                theme = currentTheme
            }
            local json = HttpService:JSONEncode(settings)
            notify("บันทึกการตั้งค่า", "บันทึกการตั้งค่าเสร็จแล้ว", "💾")
            -- Note: Actual saving to server requires external storage
        end)
        
        createSetting("รีเซ็ตการตั้งค่า", "รีเซ็ตทุกอย่างเป็นค่าเริ่มต้น", false, function()
            autoPlant = false
            autoHarvest = false
            autoSell = false
            autoEgg = false
            autoNPC = false
            autoShop = false
            autoRebirth = false
            autoUpgrade = false
            autoCollect = false
            autoHatch = false
            speedEnabled = false
            jumpEnabled = false
            flyEnabled = false
            noclipEnabled = false
            espEnabled = false
            autoPathfinding = false
            selectedNPC = nil
            currentTheme = "dark"
            colors = themes[currentTheme]
            notify("รีเซ็ต", "รีเซ็ตการตั้งค่าเสร็จแล้ว", "🔄")
        end)
    end
    
    -- Create all tabs
    local mainTab = createTab("ฟาร์ม", "🌾", createMainTab)
    local explorerTab = createTab("ค้นหา", "🔍", createExplorerTab)
    local statsTab = createTab("สถิติ", "📊", createStatsTab)
    local settingsTab = createTab("ตั้งค่า", "⚙️", createSettingsTab)
    
    mainTab.BackgroundColor3 = colors.accent
    mainTab.TextColor3 = colors.text
    activeTab = mainTab
    contentFrame:FindFirstChild("ฟาร์มContent").Visible = true
    
    -- Draggable window
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Initial animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 850, 0, 650),
        Position = UDim2.new(0.5, -425, 0.5, -325)
    }):Play()
    
    return screenGui
end

-- Auto Functions
local function autoBuyEgg()
    if not autoEgg or not scriptEnabled then return end
    for _, eggData in pairs(gameObjects.eggs) do
        if eggData.object and eggData.object.Parent then
            local clickDetector = eggData.object:FindFirstChild("ClickDetector")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(eggData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("ซื้อไข่", "ซื้อ " .. eggData.name, "🥚", 2)
                wait(0.5)
                break
            end
        end
    end
end

local function autoBuyShop()
    if not autoShop or not scriptEnabled then return end
    for _, shopData in pairs(gameObjects.shops) do
        if shopData.object and shopData.object.Parent then
            local clickDetector = shopData.object:FindFirstChild("ClickDetector")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(shopData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("ซื้อร้านค้า", "อัปเกรด " .. shopData.name, "🏪", 2)
                wait(0.5)
                break
            end
        end
    end
end

local function autoBuySeeds()
    if not autoSeed or not scriptEnabled then return end
    for _, seedData in pairs(gameObjects.seeds) do
        if seedData.object and seedData.object.Parent then
            local clickDetector = seedData.object:FindFirstChild("ClickDetector")
            local proximityPrompt = seedData.object:FindFirstChildOfClass("ProximityPrompt")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(seedData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("ซื้อเมล็ดพันธุ์", "ซื้อ " .. seedData.name, "🌱", 2)
                wait(0.5)
                break
            elseif proximityPrompt then
                if autoPathfinding then
                    moveToPosition(seedData.object.Position)
                end
                fireproximityprompt(proximityPrompt)
                notify("ซื้อเมล็ดพันธุ์", "ซื้อ " .. seedData.name, "🌱", 2)
                wait(0.5)
                break
            end
        end
    end
end

local function autoPlantCrops()
    if not autoPlant or not scriptEnabled then return end
    for _, plotData in pairs(gameObjects.plots) do
        if plotData.object and plotData.object.Parent then
            local clickDetector = plotData.object:FindFirstChild("ClickDetector")
            local proximityPrompt = plotData.object:FindFirstChildOfClass("ProximityPrompt")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(plotData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("ปลูกผัก", "ปลูกที่แปลง " .. plotData.name, "🌱", 2)
                wait(0.5)
                break
            elseif proximityPrompt then
                if autoPathfinding then
                    moveToPosition(plotData.object.Position)
                end
                fireproximityprompt(proximityPrompt)
                notify("ปลูกผัก", "ปลูกที่แปลง " .. plotData.name, "🌱", 2)
                wait(0.5)
                break
            end
        end
    end
end

local function autoHarvestCrops()
    if not autoHarvest or not scriptEnabled then return end
    for _, cropData in pairs(gameObjects.crops) do
        if cropData.object and cropData.object.Parent then
            local clickDetector = cropData.object:FindFirstChild("ClickDetector")
            local proximityPrompt = cropData.object:FindFirstChildOfClass("ProximityPrompt")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(cropData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("เก็บเกี่ยว", "เก็บ " .. cropData.name, "🌾", 2)
                wait(0.5)
                break
            elseif proximityPrompt then
                if autoPathfinding then
                    moveToPosition(cropData.object.Position)
                end
                fireproximityprompt(proximityPrompt)
                notify("เก็บเกี่ยว", "เก็บ " .. cropData.name, "🌾", 2)
                wait(0.5)
                break
            end
        end
    end
end

local function autoSellCrops()
    if not autoSell or not scriptEnabled then return end
    for _, npcData in pairs(gameObjects.npcs) do
        if npcData.object and npcData.object.Parent and (not selectedNPC or npcData.name == selectedNPC) then
            local clickDetector = npcData.object:FindFirstChild("ClickDetector")
            local proximityPrompt = npcData.object:FindFirstChildOfClass("ProximityPrompt")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(npcData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("ขายผัก", "ขายให้ " .. npcData.name, "💰", 2)
                wait(0.5)
                break
            elseif proximityPrompt then
                if autoPathfinding then
                    moveToPosition(npcData.object.Position)
                end
                fireproximityprompt(proximityPrompt)
                notify("ขายผัก", "ขายให้ " .. npcData.name, "💰", 2)
                wait(0.5)
                break
            end
        end
    end
end

local function autoBuyNPC()
    if not autoNPC or not scriptEnabled then return end
    for _, npcData in pairs(gameObjects.npcs) do
        if npcData.object and npcData.object.Parent and (not selectedNPC or npcData.name == selectedNPC) then
            local clickDetector = npcData.object:FindFirstChild("ClickDetector")
            local proximityPrompt = npcData.object:FindFirstChildOfClass("ProximityPrompt")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(npcData.object.Position)
                end
                fireclickdetector(clickDetector)
                notify("ซื้อจาก NPC", "โต้ตอบกับ " .. npcData.name, "🧑‍🌾", 2)
                wait(0.5)
                break
            elseif proximityPrompt then
                if autoPathfinding then
                    moveToPosition(npcData.object.Position)
                end
                fireproximityprompt(proximityPrompt)
                notify("ซื้อจาก NPC", "โต้ตอบกับ " .. npcData.name, "🧑‍🌾", 2)
                wait(0.5)
                break
            end
        end
    end
    
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("purchase") or remote.Name:lower():find("buy") or remote.Name:lower():find("shop")) then
            remote:FireServer(selectedNPC or "DefaultNPC")
            notify("Remote NPC", "ส่งคำสั่งไปยัง " .. remote.Name, "📡", 2)
            wait(0.5)
            break
        end
    end
end

local function autoCollectCoins()
    if not autoCollect or not scriptEnabled then return end
    for _, coinData in pairs(gameObjects.collectibles) do
        if coinData.object and coinData.object.Parent then
            local clickDetector = coinData.object:FindFirstChild("ClickDetector")
            if clickDetector then
                if autoPathfinding then
                    moveToPosition(coinData.object.Position)
                end
                fireclickdetector(clickDetector)
                wait(0.5)
            end
        end
    end
end

-- Player Enhancement Functions
local function handleFly()
    if not flyEnabled then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local bodyVelocity = humanoidRootPart:FindFirstChild("FlyVelocity")
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.Parent = humanoidRootPart
    end
    
    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    
    bodyVelocity.Velocity = moveVector * 50
end

local function handleNoclip()
    if not noclipEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Main Loop
local lastUpdate = tick()
local updateInterval = 0.5 -- Faster updates for farming

RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end
    
    local now = tick()
    if now - lastUpdate >= updateInterval then
        if autoPlant then autoPlantCrops() end
        if autoHarvest then autoHarvestCrops() end
        if autoSell then autoSellCrops() end
        if autoEgg then autoBuyEgg() end
        if autoNPC then autoBuyNPC() end
        if autoShop then autoBuyShop() end
        if autoSeed then autoBuySeeds() end
        if autoCollect then autoCollectCoins() end
        if autoRebirth then
            for _, remote in pairs(ReplicatedStorage:GetChildren()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("rebirth") then
                    remote:FireServer()
                    notify("เกิดใหม่", "ทำการเกิดใหม่", "🔄", 2)
                    break
                end
            end
        end
        if autoUpgrade then
            for _, upgrade in pairs(gameObjects.upgrades) do
                if upgrade.object and upgrade.object.Parent then
                    local clickDetector = upgrade.object:FindFirstChild("ClickDetector")
                    if clickDetector then
                        if autoPathfinding then
                            moveToPosition(upgrade.object.Position)
                        end
                        fireclickdetector(clickDetector)
                        notify("อัปเกรด", "อัปเกรด " .. upgrade.name, "📈", 2)
                        wait(0.5)
                        break
                    end
                end
            end
        end
        if autoHatch then
            for _, egg in pairs(gameObjects.eggs) do
                if egg.object and egg.object.Parent then
                    local clickDetector = egg.object:FindFirstChild("ClickDetector")
                    if clickDetector then
                        if autoPathfinding then
                            moveToPosition(egg.object.Position)
                        end
                        fireclickdetector(clickDetector)
                        notify("ฟักไข่", "ฟัก " .. egg.name, "🥚", 2)
                        wait(0.5)
                        break
                    end
                end
            end
        end
        if math.random(1, 60) == 1 then
            scanForObjects()
        end
        lastUpdate = now
    end
    
    if flyEnabled then handleFly() end
    if noclipEnabled then handleNoclip() end
end)

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local flyVelocity = humanoidRootPart:FindFirstChild("FlyVelocity")
            if flyVelocity then
                flyVelocity:Destroy()
            end
        end
    end
end)

-- Initialize
local gui = createModernUI()
notify("🌱 Grow Garden Pro", "สคริปต์ขั้นสูงสุดโหลดเสร็จแล้ว! ฟาร์มเต็มระบบ", "🚀", 5)

-- Auto-detect remotes
spawn(function()
    wait(5)
    if ReplicatedStorage then
        local remotes = ReplicatedStorage:GetChildren()
        print("🔍 พบ RemoteEvent ทั้งหมด " .. #remotes .. " รายการ")
        for _, remote in pairs(remotes) do
            if remote:IsA("RemoteEvent") then
                print("📡 RemoteEvent: " .. remote.Name)
            end
        end
    end
end)

print("🌱 Grow Garden Pro Script loaded successfully!")
print("🔍 Object Scanner: " .. #gameObjects.eggs .. " eggs, " .. #gameObjects.shops .. " shops, " .. #gameObjects.npcs .. " NPCs, " .. #gameObjects.plots .. " plots, " .. #gameObjects.crops .. " crops found")
print("🚀 All systems operational!")
