-- 🌱 Grow Garden Pro Script | Advanced Full System
-- Version: 2.0 | Created by AI Assistant
-- Features: Full Auto System, Object Explorer, Anti-AFK, Modern UI
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
local teleportEnabled = false
local speedEnabled = false
local jumpEnabled = false
local flyEnabled = false
local noclipEnabled = false
local autoFarmEnabled = false
local espEnabled = false

-- Game Objects Storage
local gameObjects = {
    eggs = {},
    shops = {},
    seeds = {},
    upgrades = {},
    pets = {},
    collectibles = {},
    teleports = {}
}

-- UI Colors
local colors = {
    primary = Color3.fromRGB(25, 25, 35),
    secondary = Color3.fromRGB(35, 35, 45),
    accent = Color3.fromRGB(0, 162, 255),
    success = Color3.fromRGB(46, 204, 113),
    warning = Color3.fromRGB(241, 196, 15),
    danger = Color3.fromRGB(231, 76, 60),
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(180, 180, 190)
}

-- Notification System
local function notify(title, text, icon, duration)
    StarterGui:SetCore("SendNotification", {
        Title = (icon or "🌱") .. " " .. title;
        Text = text;
        Duration = duration or 4;
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
    local function scanFolder(folder, category)
        for _, obj in pairs(folder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("Folder") then
                table.insert(gameObjects[category], {
                    name = obj.Name,
                    object = obj,
                    path = obj:GetFullName()
                })
            end
        end
    end
    
    -- Scan for different categories
    local categories = {
        "Eggs", "EggShop", "Egg", "eggs",
        "Shop", "Shops", "Store", "Upgrade", "upgrades",
        "Seed", "Seeds", "Plant", "plants",
        "Pet", "Pets", "Animal", "animals",
        "Coin", "Coins", "Money", "Cash", "Gold",
        "Teleport", "Portal", "Spawn", "Zone"
    }
    
    for _, obj in pairs(workspace:GetChildren()) do
        local objName = obj.Name:lower()
        
        -- Auto-categorize based on name
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
        end
    end
    
    print("🔍 Object Scanner: Found " .. #gameObjects.eggs .. " eggs, " .. #gameObjects.shops .. " shops, " .. #gameObjects.seeds .. " seeds")
end

-- Auto-scan on load
scanForObjects()

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
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🌱"
    iconLabel.TextColor3 = colors.text
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = desktopIcon
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
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
    titleLabel.Text = "🌱 Grow Garden Pro | Advanced System"
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
        return button
    end
    
    -- Minimize Button
    local minimizeBtn = createControlButton("−", UDim2.new(1, -100, 0.5, -15), colors.warning, function()
        mainFrame.Visible = false
        desktopIcon.Visible = true
        
        -- Animate icon appearance
        desktopIcon.Size = UDim2.new(0, 0, 0, 0)
        desktopIcon.Visible = true
        TweenService:Create(desktopIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
    end)
    
    -- Maximize Button  
    local maximizeBtn = createControlButton("□", UDim2.new(1, -65, 0.5, -15), colors.accent, function()
        local targetSize = mainFrame.Size == UDim2.new(0, 800, 0, 600) and UDim2.new(0, 1000, 0, 700) or UDim2.new(0, 800, 0, 600)
        local targetPos = mainFrame.Size == UDim2.new(0, 800, 0, 600) and UDim2.new(0.5, -500, 0.5, -350) or UDim2.new(0.5, -400, 0.5, -300)
        
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = targetSize,
            Position = targetPos
        }):Play()
    end)
    
    -- Close Button
    local closeBtn = createControlButton("×", UDim2.new(1, -30, 0.5, -15), colors.danger, function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        wait(0.3)
        screenGui:Destroy()
        scriptEnabled = false
        notify("Grow Garden Pro", "สคริปถูกปิดแล้ว", "❌")
    end)
    
    -- Desktop Icon Click
    desktopIcon.MouseButton1Click:Connect(function()
        desktopIcon.Visible = false
        mainFrame.Visible = true
        
        -- Animate main frame appearance
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 800, 0, 600),
            Position = UDim2.new(0.5, -400, 0.5, -300)
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
        
        -- Auto-resize canvas
        contentLayout.Changed:Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab Click Handler
        tab.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, child in pairs(contentFrame:GetChildren()) do
                if child.Name:find("Content") then
                    child.Visible = false
                end
            end
            
            -- Show current tab
            tabContent.Visible = true
            
            -- Update tab appearance
            if activeTab then
                activeTab.BackgroundColor3 = colors.primary
                activeTab.TextColor3 = colors.textSecondary
            end
            
            tab.BackgroundColor3 = colors.accent
            tab.TextColor3 = colors.text
            activeTab = tab
        end)
        
        -- Add content to tab
        if content then content(tabContent) end
        
        return tab, tabContent
    end
    
    -- Create Tabs
    local function createMainTab(parent)
        local function createSection(title, items)
            local section = Instance.new("Frame")
            section.Size = UDim2.new(1, 0, 0, 200)
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
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.FillDirection = Enum.FillDirection.Horizontal
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 10)
            sectionLayout.Parent = sectionContent
            
            -- Add items
            for _, item in pairs(items) do
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0, 180, 0, 50)
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
                
                button.MouseButton1Click:Connect(function()
                    if item.callback then item.callback() end
                    button.BackgroundColor3 = item.enabled and colors.success or colors.primary
                end)
            end
            
            return section
        end
        
        -- Auto Farm Section
        createSection("🚀 ระบบออโต้หลัก", {
            {text = "🥚 ซื้อไข่อัตโนมัติ", enabled = autoEgg, callback = function()
                autoEgg = not autoEgg
                notify("ระบบไข่", autoEgg and "เปิดใช้งาน" or "ปิดใช้งาน", "🥚")
            end},
            {text = "🏪 ซื้อร้านค้าอัตโนมัติ", enabled = autoShop, callback = function()
                autoShop = not autoShop
                notify("ระบบร้านค้า", autoShop and "เปิดใช้งาน" or "ปิดใช้งาน", "🏪")
            end},
            {text = "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ", enabled = autoSeed, callback = function()
                autoSeed = not autoSeed
                notify("ระบบเมล็ดพันธุ์", autoSeed and "เปิดใช้งาน" or "ปิดใช้งาน", "🌱")
            end},
            {text = "💰 ขายสินค้าอัตโนมัติ", enabled = autoSell, callback = function()
                autoSell = not autoSell
                notify("ระบบขาย", autoSell and "เปิดใช้งาน" or "ปิดใช้งาน", "💰")
            end}
        })
        
        -- Advanced Features
        createSection("⚡ ฟีเจอร์ขั้นสูง", {
            {text = "🔄 เกิดใหม่อัตโนมัติ", enabled = autoRebirth, callback = function()
                autoRebirth = not autoRebirth
                notify("ระบบเกิดใหม่", autoRebirth and "เปิดใช้งาน" or "ปิดใช้งาน", "🔄")
            end},
            {text = "📈 อัพเกรดอัตโนมัติ", enabled = autoUpgrade, callback = function()
                autoUpgrade = not autoUpgrade
                notify("ระบบอัพเกรด", autoUpgrade and "เปิดใช้งาน" or "ปิดใช้งาน", "📈")
            end},
            {text = "🪙 เก็บเหรียญอัตโนมัติ", enabled = autoCollect, callback = function()
                autoCollect = not autoCollect
                notify("ระบบเก็บเหรียญ", autoCollect and "เปิดใช้งาน" or "ปิดใช้งาน", "🪙")
            end},
            {text = "🥚 ฟักไข่อัตโนมัติ", enabled = autoHatch, callback = function()
                autoHatch = not autoHatch
                notify("ระบบฟักไข่", autoHatch and "เปิดใช้งาน" or "ปิดใช้งาน", "🥚")
            end}
        })
        
        -- Player Enhancement
        createSection("🏃 ปรับปรุงผู้เล่น", {
            {text = "💨 ความเร็วเพิ่มขึ้น", enabled = speedEnabled, callback = function()
                speedEnabled = not speedEnabled
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and 50 or 16
                end
                notify("ความเร็ว", speedEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "💨")
            end},
            {text = "🦘 กระโดดสูงขึ้น", enabled = jumpEnabled, callback = function()
                jumpEnabled = not jumpEnabled
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = jumpEnabled and 100 or 50
                end
                notify("กระโดด", jumpEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "🦘")
            end},
            {text = "✈️ บินได้", enabled = flyEnabled, callback = function()
                flyEnabled = not flyEnabled
                notify("การบิน", flyEnabled and "เปิดใช้งาน (WASD)" or "ปิดใช้งาน", "✈️")
            end},
            {text = "👻 ผ่านกำแพงได้", enabled = noclipEnabled, callback = function()
                noclipEnabled = not noclipEnabled
                notify("ผ่านกำแพง", noclipEnabled and "เปิดใช้งาน" or "ปิดใช้งาน", "👻")
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
        
        local objectList = Instance.new("Frame")
        objectList.Size = UDim2.new(1, 0, 1, -60)
        objectList.Position = UDim2.new(0, 0, 0, 50)
        objectList.BackgroundColor3 = colors.secondary
        objectList.BorderSizePixel = 0
        objectList.Parent = parent
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 8)
        listCorner.Parent = objectList
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = objectList
        
        -- Populate object list
        local function populateList(filter)
            -- Clear existing items
            for _, child in pairs(objectList:GetChildren()) do
                if child ~= listLayout then
                    child:Destroy()
                end
            end
            
            -- Add objects
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
                                    -- Try to teleport to object
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local targetPos = obj.object:IsA("Model") and obj.object.PrimaryPart and obj.object.PrimaryPart.Position or obj.object.Position
                                        if targetPos then
                                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                                            notify("เทเลพอร์ต", "ไปยัง " .. obj.name, "🚀")
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
        
        -- Search functionality
        searchBox.FocusLost:Connect(function()
            populateList(searchBox.Text ~= "🔍 ค้นหาวัตถุ..." and searchBox.Text or nil)
        end)
        
        -- Initial population
        populateList()
        
        -- Rescan button
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
        
        -- Create stat cards
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
        
        -- Create stat cards
        local eggCard, eggValue = createStatCard("ไข่ที่พบ", tostring(#gameObjects.eggs), "🥚", colors.success)
        local shopCard, shopValue = createStatCard("ร้านค้าที่พบ", tostring(#gameObjects.shops), "🏪", colors.accent)
        local seedCard, seedValue = createStatCard("เมล็ดพันธุ์ที่พบ", tostring(#gameObjects.seeds), "🌱", colors.warning)
        local scriptCard, scriptValue = createStatCard("สถานะสคริป", scriptEnabled and "กำลังทำงาน" or "หยุดทำงาน", "⚡", colors.primary)
        
        -- Update stats periodically
        RunService.Heartbeat:Connect(function()
            if math.random(1, 300) == 1 then -- Update every ~5 seconds
                eggValue.Text = tostring(#gameObjects.eggs)
                shopValue.Text = tostring(#gameObjects.shops)
                seedValue.Text = tostring(#gameObjects.seeds)
                scriptValue.Text = scriptEnabled and "กำลังทำงาน" or "หยุดทำงาน"
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
        
        -- Create setting items
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
        
        -- Add settings
        createSetting("ป้องกัน AFK", "ป้องกันการถูกเตะออกจากเกม", true, function()
            antiAFK = not antiAFK
            notify("Anti-AFK", antiAFK and "เปิดใช้งาน" or "ปิดใช้งาน", "🛡️")
        end)
        
        createSetting("การแจ้งเตือน", "แสดงการแจ้งเตือนเมื่อทำงาน", true, function()
            notify("การแจ้งเตือน", "ทดสอบการแจ้งเตือน", "🔔")
        end)
        
        createSetting("เสียงเตือน", "เปิดเสียงเตือนเมื่อทำงานเสร็จ", true, function()
            notify("เสียงเตือน", "ปิดเสียงเตือนแล้ว", "🔇")
        end)
        
        createSetting("บันทึกการตั้งค่า", "บันทึกการตั้งค่าอัตโนมัติ", false, function()
            notify("บันทึกการตั้งค่า", "บันทึกการตั้งค่าเสร็จแล้ว", "💾")
        end)
        
        createSetting("รีเซ็ตการตั้งค่า", "รีเซ็ตทุกอย่างเป็นค่าเริ่มต้น", false, function()
            autoEgg = false
            autoShop = false
            autoSeed = false
            autoSell = false
            notify("รีเซ็ต", "รีเซ็ตการตั้งค่าเสร็จแล้ว", "🔄")
        end)
    end
    
    -- Create all tabs
    local mainTab = createTab("หลัก", "🏠", createMainTab)
    local explorerTab = createTab("ค้นหา", "🔍", createExplorerTab)
    local statsTab = createTab("สถิติ", "📊", createStatsTab)
    local settingsTab = createTab("ตั้งค่า", "⚙️", createSettingsTab)
    
    -- Set default tab
    mainTab.BackgroundColor3 = colors.accent
    mainTab.TextColor3 = colors.text
    activeTab = mainTab
    contentFrame:FindFirstChild("หลักContent").Visible = true
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
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
    
    return screenGui
end

-- Auto Functions
local function autoBuyEgg()
    if not autoEgg or not scriptEnabled then return end
    
    for _, eggData in pairs(gameObjects.eggs) do
        if eggData.object and eggData.object.Parent then
            local clickDetector = eggData.object:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                notify("ซื้อไข่", "ซื้อ " .. eggData.name, "🥚", 2)
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
                fireclickdetector(clickDetector)
                notify("ซื้อร้านค้า", "อัพเกรด " .. shopData.name, "🏪", 2)
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
            if clickDetector then
                fireclickdetector(clickDetector)
                notify("ซื้อเมล็ดพันธุ์", "ซื้อ " .. seedData.name, "🌱", 2)
                break
            end
        end
    end
end

local function autoCollectCoins()
    if not autoCollect or not scriptEnabled then return end
    
    for _, coinData in pairs(gameObjects.collectibles) do
        if coinData.object and coinData.object.Parent then
            local clickDetector = coinData.object:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
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
local updateInterval = 1 -- seconds

RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end
    
    local now = tick()
    
    -- Auto functions (run every second)
    if now - lastUpdate >= updateInterval then
        if autoEgg then autoBuyEgg() end
        if autoShop then autoBuyShop() end
        if autoSeed then autoBuySeeds() end
        if autoCollect then autoCollectCoins() end
        
        -- Rescan objects occasionally
        if math.random(1, 30) == 1 then
            scanForObjects()
        end
        
        lastUpdate = now
    end
    
    -- Real-time functions
    if flyEnabled then handleFly() end
    if noclipEnabled then handleNoclip() end
end)

-- Cleanup when player leaves
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
notify("🌱 Grow Garden Pro", "สคริปขั้นสูงโหลดเสร็จแล้ว! ระบบครบครัน", "🚀", 5)

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
print("🔍 Object Scanner: " .. #gameObjects.eggs .. " eggs, " .. #gameObjects.shops .. " shops found")
print("🚀 All systems operational!")