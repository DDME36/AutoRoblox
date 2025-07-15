local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================================
-- CORE VARIABLES & SETTINGS
-- ============================================================================

local UltimateGarden = {
    -- Version Info
    version = "3.0",
    title = "🌱 Grow Garden Ultimate Pro",
    
    -- Core Settings
    enabled = true,
    debugMode = false,
    
    -- Feature Toggles
    features = {
        autoEgg = false,
        autoShop = false,
        autoSeed = false,
        autoPlant = false,
        autoHarvest = false,
        autoSell = false,
        autoRebirth = false,
        autoEquipPet = false,
        autoClaimRewards = false,
        smartFarming = false,
        antiAFK = true
    },
    
    -- Performance Settings
    performance = {
        farmSpeed = 1.0, -- 0.1 = เร็วมาก, 2.0 = ช้า
        scanInterval = 30, -- วินาที
        maxActions = 5, -- การกระทำสูงสุดต่อรอบ
        debounceTime = 0.5 -- วินาที
    },
    
    -- Smart Settings
    smart = {
        maxSeedPrice = 1000, -- ราคาเมล็ดสูงสุดที่จะซื้อ
        minCropValue = 100, -- มูลค่าพืชขั้นต่ำที่จะเก็บเกี่ยว
        priorityNPC = nil, -- NPC ที่ให้ความสำคัญ
        farmPriority = {"plant", "harvest", "sell", "upgrade"} -- ลำดับการฟาร์ม
    },
    
    -- UI Settings
    ui = {
        theme = "dark", -- dark, light, custom
        windowSize = {800, 600},
        showNotifications = true,
        showStats = true
    },
    
    -- Data Storage
    data = {
        gameObjects = {
            eggs = {},
            shops = {},
            seeds = {},
            plants = {},
            npcs = {},
            pets = {},
            rewards = {}
        },
        remoteEvents = {},
        playerStats = {
            money = 0,
            eggs = 0,
            plants = 0,
            harvests = 0
        },
        cache = {}
    }
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local Utils = {}

-- Notification System
function Utils.notify(title, text, duration, icon)
    if not UltimateGarden.ui.showNotifications then return end
    
    StarterGui:SetCore("SendNotification", {
        Title = (icon or "🌱") .. " " .. title;
        Text = text;
        Duration = duration or 3;
    })
end

-- Debug Logging
function Utils.log(message, type)
    if not UltimateGarden.debugMode then return end
    
    local prefix = type and "[" .. type:upper() .. "]" or "[INFO]"
    print(prefix .. " " .. message)
end

-- Safe Function Call
function Utils.safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        Utils.log("Error in function: " .. tostring(result), "error")
        Utils.notify("Error", "เกิดข้อผิดพลาด: " .. tostring(result), 5, "❌")
    end
    return success, result
end

-- Debounce System
local debounces = {}
function Utils.debounce(key, func, time)
    time = time or UltimateGarden.performance.debounceTime
    
    if debounces[key] and tick() - debounces[key] < time then
        return false
    end
    
    debounces[key] = tick()
    return Utils.safeCall(func)
end

-- Resource Checker
function Utils.hasResources(requiredMoney)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 1)
    if not playerGui then return false end
    
    -- Try to find money display in UI
    local function findMoneyDisplay(obj)
        for _, child in pairs(obj:GetDescendants()) do
            if child:IsA("TextLabel") and child.Text:find("$") then
                local money = child.Text:match("%d+")
                if money then
                    UltimateGarden.data.playerStats.money = tonumber(money) or 0
                    return tonumber(money) >= (requiredMoney or 0)
                end
            end
        end
        return true -- Assume we have resources if can't detect
    end
    
    return findMoneyDisplay(playerGui)
end

-- ============================================================================
-- ADVANCED OBJECT DETECTION SYSTEM
-- ============================================================================

local ObjectDetector = {}

-- Object Categories with Smart Detection
ObjectDetector.categories = {
    eggs = {"egg", "ไข", "หอย"},
    shops = {"shop", "store", "upgrade", "ร้าน", "อัพเกรด"},
    seeds = {"seed", "เมล็ด", "พันธุ"},
    plants = {"plant", "crop", "ผัก", "พืช", "ต้น"},
    npcs = {"npc", "villager", "merchant", "คน", "พ่อค้า"},
    pets = {"pet", "animal", "สัตว์", "เลี้ยง"},
    rewards = {"reward", "chest", "gift", "รางวัล", "กล่อง", "ของขวัญ"}
}

-- Smart Object Scanner
function ObjectDetector:scan()
    if not Utils.debounce("object_scan", function() end, 5) then return end
    
    Utils.log("Starting smart object scan...", "scanner")
    
    -- Clear old data
    for category, _ in pairs(UltimateGarden.data.gameObjects) do
        UltimateGarden.data.gameObjects[category] = {}
    end
    
    local workspace = game:GetService("Workspace")
    local scannedCount = 0
    
    -- Scan all objects in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if scannedCount > 1000 then break end -- Limit scan for performance
        
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local objName = obj.Name:lower()
            local objPosition = self:getObjectPosition(obj)
            
            if objPosition then
                -- Categorize object
                for category, keywords in pairs(self.categories) do
                    for _, keyword in pairs(keywords) do
                        if objName:find(keyword) then
                            table.insert(UltimateGarden.data.gameObjects[category], {
                                name = obj.Name,
                                object = obj,
                                position = objPosition,
                                value = self:calculateObjectValue(obj, category),
                                lastUpdate = tick()
                            })
                            scannedCount = scannedCount + 1
                            break
                        end
                    end
                end
            end
        end
    end
    
    Utils.log("Scan complete. Found " .. scannedCount .. " objects", "scanner")
    Utils.notify("Object Scanner", "พบวัตถุ " .. scannedCount .. " รายการ", 3, "🔍")
end

-- Get Object Position Safely
function ObjectDetector:getObjectPosition(obj)
    if obj:IsA("Model") then
        local primaryPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("Part")
        return primaryPart and primaryPart.Position or nil
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

-- Calculate Object Value (for smart selection)
function ObjectDetector:calculateObjectValue(obj, category)
    local value = 1
    
    -- Distance factor (closer = better)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        local objPos = self:getObjectPosition(obj)
        if objPos then
            local distance = (playerPos - objPos).Magnitude
            value = value / math.max(distance / 100, 1) -- Closer objects have higher value
        end
    end
    
    -- Size factor (bigger might be better for some categories)
    if category == "shops" or category == "npcs" then
        local size = 1
        if obj:IsA("Model") then
            local _, boundingBox = obj:GetBoundingBox()
            size = boundingBox.Magnitude
        elseif obj:IsA("BasePart") then
            size = obj.Size.Magnitude
        end
        value = value * math.min(size / 10, 2) -- Bigger shops/NPCs might be more important
    end
    
    return value
end

-- Find Best Object in Category
function ObjectDetector:findBest(category, filter)
    local objects = UltimateGarden.data.gameObjects[category] or {}
    local best = nil
    local bestValue = 0
    
    for _, obj in pairs(objects) do
        if obj.object and obj.object.Parent then
            local valid = true
            
            -- Apply filter if provided
            if filter and not filter(obj) then
                valid = false
            end
            
            if valid and obj.value > bestValue then
                best = obj
                bestValue = obj.value
            end
        end
    end
    
    return best
end

-- ============================================================================
-- ADVANCED REMOTE EVENT SYSTEM
-- ============================================================================

local RemoteSystem = {}

-- Auto-detect RemoteEvents
function RemoteSystem:detectRemotes()
    Utils.log("Detecting RemoteEvents...", "remote")
    
    UltimateGarden.data.remoteEvents = {}
    
    -- Scan ReplicatedStorage
    if ReplicatedStorage then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local remoteName = obj.Name:lower()
                
                -- Categorize remotes by name patterns
                local category = "other"
                if remoteName:find("buy") or remoteName:find("purchase") or remoteName:find("ซื้อ") then
                    category = "buy"
                elseif remoteName:find("sell") or remoteName:find("ขาย") then
                    category = "sell"
                elseif remoteName:find("plant") or remoteName:find("ปลูก") then
                    category = "plant"
                elseif remoteName:find("harvest") or remoteName:find("เก็บ") then
                    category = "harvest"
                elseif remoteName:find("equip") or remoteName:find("สวม") then
                    category = "equip"
                end
                
                if not UltimateGarden.data.remoteEvents[category] then
                    UltimateGarden.data.remoteEvents[category] = {}
                end
                
                table.insert(UltimateGarden.data.remoteEvents[category], {
                    name = obj.Name,
                    remote = obj,
                    lastUsed = 0,
                    success = 0,
                    failures = 0
                })
                
                Utils.log("Found " .. category .. " remote: " .. obj.Name, "remote")
            end
        end
    end
end

-- Smart Remote Caller
function RemoteSystem:call(category, action, ...)
    local remotes = UltimateGarden.data.remoteEvents[category]
    if not remotes or #remotes == 0 then return false end
    
    -- Try remotes in order of success rate
    table.sort(remotes, function(a, b)
        local aRate = a.success / math.max(a.success + a.failures, 1)
        local bRate = b.success / math.max(b.success + b.failures, 1)
        return aRate > bRate
    end)
    
    for _, remoteData in pairs(remotes) do
        if remoteData.remote and remoteData.remote.Parent then
            local success = Utils.safeCall(function()
                remoteData.remote:FireServer(...)
                remoteData.lastUsed = tick()
                remoteData.success = remoteData.success + 1
                return true
            end)
            
            if success then
                Utils.log("Called " .. remoteData.name .. " successfully", "remote")
                return true
            else
                remoteData.failures = remoteData.failures + 1
            end
        end
    end
    
    return false
end

-- ============================================================================
-- SMART FARMING SYSTEM
-- ============================================================================

local SmartFarm = {}

-- Farming Queue System
SmartFarm.queue = {}
SmartFarm.currentAction = nil

-- Add Action to Queue
function SmartFarm:addAction(action, priority, data)
    table.insert(self.queue, {
        action = action,
        priority = priority or 1,
        data = data or {},
        timestamp = tick()
    })
    
    -- Sort by priority
    table.sort(self.queue, function(a, b) return a.priority > b.priority end)
end

-- Process Queue
function SmartFarm:processQueue()
    if #self.queue == 0 or self.currentAction then return end
    
    local nextAction = table.remove(self.queue, 1)
    if not nextAction then return end
    
    self.currentAction = nextAction
    
    Utils.log("Processing action: " .. nextAction.action, "farm")
    
    -- Execute action
    local success = false
    if nextAction.action == "plant" then
        success = self:executePlant(nextAction.data)
    elseif nextAction.action == "harvest" then
        success = self:executeHarvest(nextAction.data)
    elseif nextAction.action == "sell" then
        success = self:executeSell(nextAction.data)
    elseif nextAction.action == "upgrade" then
        success = self:executeUpgrade(nextAction.data)
    end
    
    -- Clear current action
    self.currentAction = nil
    
    if success then
        Utils.notify("Smart Farm", "ทำ " .. nextAction.action .. " สำเร็จ", 2, "🤖")
    end
end

-- Execute Plant Action
function SmartFarm:executePlant(data)
    if not UltimateGarden.features.autoPlant then return false end
    
    local bestSeed = ObjectDetector:findBest("seeds", function(obj)
        return obj.value <= UltimateGarden.smart.maxSeedPrice
    end)
    
    if bestSeed and Utils.hasResources(UltimateGarden.smart.maxSeedPrice) then
        return self:clickObject(bestSeed.object)
    end
    
    return false
end

-- Execute Harvest Action
function SmartFarm:executeHarvest(data)
    if not UltimateGarden.features.autoHarvest then return false end
    
    local bestPlant = ObjectDetector:findBest("plants", function(obj)
        -- Check if plant is ready (this might need game-specific logic)
        return obj.value >= UltimateGarden.smart.minCropValue
    end)
    
    if bestPlant then
        return self:clickObject(bestPlant.object)
    end
    
    return false
end

-- Execute Sell Action
function SmartFarm:executeSell(data)
    if not UltimateGarden.features.autoSell then return false end
    
    -- Try to use RemoteEvent first
    if RemoteSystem:call("sell", "sell_all") then
        return true
    end
    
    -- Fallback to clicking sell NPCs
    local sellNPC = ObjectDetector:findBest("npcs", function(obj)
        return obj.name:lower():find("sell") or obj.name:lower():find("ขาย")
    end)
    
    if sellNPC then
        return self:clickObject(sellNPC.object)
    end
    
    return false
end

-- Execute Upgrade Action
function SmartFarm:executeUpgrade(data)
    if not UltimateGarden.features.autoShop then return false end
    
    local bestShop = ObjectDetector:findBest("shops")
    
    if bestShop and Utils.hasResources(1000) then -- Minimum money for upgrade
        return self:clickObject(bestShop.object)
    end
    
    return false
end

-- Smart Click with Multiple Methods
function SmartFarm:clickObject(obj)
    if not obj or not obj.Parent then return false end
    
    -- Method 1: ClickDetector
    local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
    if clickDetector then
        Utils.safeCall(function()
            fireclickdetector(clickDetector)
        end)
        return true
    end
    
    -- Method 2: ProximityPrompt
    local proximityPrompt = obj:FindFirstChildOfClass("ProximityPrompt")
    if proximityPrompt then
        Utils.safeCall(function()
            fireproximityprompt(proximityPrompt)
        end)
        return true
    end
    
    -- Method 3: RemoteEvent
    if RemoteSystem:call("buy", "click", obj.Name) then
        return true
    end
    
    return false
end

-- Generate Smart Actions
function SmartFarm:generateActions()
    if not UltimateGarden.features.smartFarming then return end
    
    -- Clear old actions
    self.queue = {}
    
    -- Add actions based on priority
    local priorities = UltimateGarden.smart.farmPriority
    
    for i, action in pairs(priorities) do
        local priority = #priorities - i + 1 -- Higher index = lower priority
        
        if action == "plant" and UltimateGarden.features.autoPlant then
            self:addAction("plant", priority)
        elseif action == "harvest" and UltimateGarden.features.autoHarvest then
            self:addAction("harvest", priority)
        elseif action == "sell" and UltimateGarden.features.autoSell then
            self:addAction("sell", priority)
        elseif action == "upgrade" and UltimateGarden.features.autoShop then
            self:addAction("upgrade", priority)
        end
    end
end

-- ============================================================================
-- PET MANAGEMENT SYSTEM
-- ============================================================================

local PetManager = {}

-- Auto-Equip Best Pet
function PetManager:equipBestPet()
    if not UltimateGarden.features.autoEquipPet then return end
    
    local bestPet = ObjectDetector:findBest("pets", function(obj)
        -- This would need game-specific logic to determine pet stats
        return true
    end)
    
    if bestPet then
        -- Try to equip via RemoteEvent
        if RemoteSystem:call("equip", "equip_pet", bestPet.name) then
            Utils.notify("Pet Manager", "สวมสัตว์เลี้ยง: " .. bestPet.name, 3, "🐾")
            return true
        end
        
        -- Fallback to clicking
        return SmartFarm:clickObject(bestPet.object)
    end
    
    return false
end

-- ============================================================================
-- REWARDS SYSTEM
-- ============================================================================

local RewardManager = {}

-- Auto-Claim Rewards
function RewardManager:claimRewards()
    if not UltimateGarden.features.autoClaimRewards then return end
    
    local rewards = UltimateGarden.data.gameObjects.rewards or {}
    
    for _, reward in pairs(rewards) do
        if reward.object and reward.object.Parent then
            SmartFarm:clickObject(reward.object)
            wait(0.5) -- Small delay between claims
        end
    end
end

-- ============================================================================
-- MODERN UI SYSTEM
-- ============================================================================

local ModernUI = {}

-- Color Themes
ModernUI.themes = {
    dark = {
        primary = Color3.fromRGB(30, 30, 40),
        secondary = Color3.fromRGB(40, 40, 50),
        accent = Color3.fromRGB(0, 162, 255),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        danger = Color3.fromRGB(231, 76, 60),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 190)
    },
    light = {
        primary = Color3.fromRGB(245, 245, 250),
        secondary = Color3.fromRGB(235, 235, 240),
        accent = Color3.fromRGB(0, 122, 255),
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 149, 0),
        danger = Color3.fromRGB(255, 69, 58),
        text = Color3.fromRGB(0, 0, 0),
        textSecondary = Color3.fromRGB(60, 60, 67)
    }
}

-- Get Current Theme
function ModernUI:getTheme()
    return self.themes[UltimateGarden.ui.theme] or self.themes.dark
end

-- Create Main UI
function ModernUI:create()
    -- Remove existing UI
    local existing = PlayerGui:FindFirstChild("UltimateGardenUI")
    if existing then existing:Destroy() end
    
    local theme = self:getTheme()
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateGardenUI"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, UltimateGarden.ui.windowSize[1], 0, UltimateGarden.ui.windowSize[2])
    mainFrame.Position = UDim2.new(0.5, -UltimateGarden.ui.windowSize[1]/2, 0.5, -UltimateGarden.ui.windowSize[2]/2)
    mainFrame.BackgroundColor3 = theme.primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = self:createTitleBar(mainFrame, theme)
    
    -- Content Area with Tabs
    local contentArea = self:createContentArea(mainFrame, theme)
    
    -- Create Tabs
    self:createTabs(contentArea, theme)
    
    -- Make draggable
    self:makeDraggable(titleBar, mainFrame)
    
    Utils.notify("Ultimate Garden", "UI โหลดเสร็จแล้ว! เวอร์ชั่น " .. UltimateGarden.version, 5, "🎨")
    
    return screenGui
end

-- Create Title Bar
function ModernUI:createTitleBar(parent, theme)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = theme.secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = parent
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = UltimateGarden.title .. " v" .. UltimateGarden.version
    titleText.TextColor3 = theme.text
    titleText.TextScaled = true
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Control Buttons
    local closeBtn = self:createButton("×", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0.5, -15), theme.danger, titleBar)
    closeBtn.MouseButton1Click:Connect(function()
        UltimateGarden.enabled = false
        parent.Parent:Destroy()
        Utils.notify("Ultimate Garden", "สคริปถูกปิดแล้ว", 3, "❌")
    end)
    
    local minimizeBtn = self:createButton("−", UDim2.new(0, 30, 0, 30), UDim2.new(1, -75, 0.5, -15), theme.warning, titleBar)
    minimizeBtn.MouseButton1Click:Connect(function()
        local isMinimized = parent.Size.Y.Offset <= 60
        local targetSize = isMinimized and 
            UDim2.new(0, UltimateGarden.ui.windowSize[1], 0, UltimateGarden.ui.windowSize[2]) or 
            UDim2.new(0, UltimateGarden.ui.windowSize[1], 0, 50)
        
        TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)
    
    return titleBar
end

-- Create Content Area
function ModernUI:createContentArea(parent, theme)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -70)
    contentArea.Position = UDim2.new(0, 10, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = parent
    
    return contentArea
end

-- Create Tabs System
function ModernUI:createTabs(parent, theme)
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = parent
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, -50)
    contentContainer.Position = UDim2.new(0, 0, 0, 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = parent
    
    -- Create Individual Tabs
    local tabs = {
        {name = "🚀 Auto Farm", content = function(p) return self:createAutoFarmTab(p, theme) end},
        {name = "🔧 Smart Config", content = function(p) return self:createSmartConfigTab(p, theme) end},
        {name = "🎯 Objects", content = function(p) return self:createObjectsTab(p, theme) end},
        {name = "📊 Stats", content = function(p) return self:createStatsTab(p, theme) end},
        {name = "⚙️ Settings", content = function(p) return self:createSettingsTab(p, theme) end}
    }
    
    local activeTab = nil
    
    for i, tab in pairs(tabs) do
        local tabButton = self:createButton(tab.name, UDim2.new(0, 150, 1, 0), UDim2.new(0, 0, 0, 0), theme.secondary, tabContainer)
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.Gotham
        tabButton.LayoutOrder = i
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tab.name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundColor3 = theme.secondary
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 8
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = i == 1 -- Show first tab by default
        tabContent.Parent = contentContainer
        
        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 12)
        contentCorner.Parent = tabContent
        
        -- Add content to tab
        tab.content(tabContent)
        
        -- Tab click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, child in pairs(contentContainer:GetChildren()) do
                if child.Name:find("Content") then
                    child.Visible = false
                end
            end
            
            -- Show current tab
            tabContent.Visible = true
            
            -- Update button appearance
            if activeTab then
                activeTab.BackgroundColor3 = theme.secondary
            end
            tabButton.BackgroundColor3 = theme.accent
            activeTab = tabButton
        end)
        
        -- Set first tab as active
        if i == 1 then
            tabButton.BackgroundColor3 = theme.accent
            activeTab = tabButton
        end
    end
end

-- Create Auto Farm Tab
function ModernUI:createAutoFarmTab(parent, theme)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = parent
    
    -- Auto-resize canvas
    layout.Changed:Connect(function()
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Farm Controls Section
    local farmSection = self:createSection("🤖 การฟาร์มอัตโนมัติ", parent, theme)
    
    -- Toggle Buttons
    local toggles = {
        {name = "Auto Plant", key = "autoPlant", desc = "ปลูกเมล็ดพันธุ์อัตโนมัติ"},
        {name = "Auto Harvest", key = "autoHarvest", desc = "เก็บเกี่ยวผลผลิตอัตโนมัติ"},
        {name = "Auto Sell", key = "autoSell", desc = "ขายผลผลิตอัตโนมัติ"},
        {name = "Smart Farming", key = "smartFarming", desc = "ฟาร์มแบบอัจฉริยะ (แนะนำ)"}
    }
    
    for _, toggle in pairs(toggles) do
        local toggleFrame = self:createToggle(toggle.name, toggle.desc, UltimateGarden.features[toggle.key], farmSection, theme)
        toggleFrame.Button.MouseButton1Click:Connect(function()
            UltimateGarden.features[toggle.key] = not UltimateGarden.features[toggle.key]
            self:updateToggle(toggleFrame, UltimateGarden.features[toggle.key], theme)
            Utils.notify("Auto Farm", toggle.name .. (UltimateGarden.features[toggle.key] and " เปิด" or " ปิด"), 2, "🤖")
        end)
    end
    
    -- Shop Controls Section
    local shopSection = self:createSection("🏪 ร้านค้าและอัพเกรด", parent, theme)
    
    local shopToggles = {
        {name = "Auto Egg", key = "autoEgg", desc = "ซื้อไข่อัตโนมัติ"},
        {name = "Auto Shop", key = "autoShop", desc = "อัพเกรดร้านค้าอัตโนมัติ"},
        {name = "Auto Seed", key = "autoSeed", desc = "ซื้อเมล็ดพันธุ์อัตโนมัติ"},
        {name = "Auto Rebirth", key = "autoRebirth", desc = "เกิดใหม่อัตโนมัติ"}
    }
    
    for _, toggle in pairs(shopToggles) do
        local toggleFrame = self:createToggle(toggle.name, toggle.desc, UltimateGarden.features[toggle.key], shopSection, theme)
        toggleFrame.Button.MouseButton1Click:Connect(function()
            UltimateGarden.features[toggle.key] = not UltimateGarden.features[toggle.key]
            self:updateToggle(toggleFrame, UltimateGarden.features[toggle.key], theme)
            Utils.notify("Auto Shop", toggle.name .. (UltimateGarden.features[toggle.key] and " เปิด" or " ปิด"), 2, "🏪")
        end)
    end
    
    -- Pet & Rewards Section
    local extraSection = self:createSection("🐾 สัตว์เลี้ยงและรางวัล", parent, theme)
    
    local extraToggles = {
        {name = "Auto Equip Pet", key = "autoEquipPet", desc = "สวมสัตว์เลี้ยงที่ดีที่สุดอัตโนมัติ"},
        {name = "Auto Claim Rewards", key = "autoClaimRewards", desc = "เก็บรางวัลอัตโนมัติ"}
    }
    
    for _, toggle in pairs(extraToggles) do
        local toggleFrame = self:createToggle(toggle.name, toggle.desc, UltimateGarden.features[toggle.key], extraSection, theme)
        toggleFrame.Button.MouseButton1Click:Connect(function()
            UltimateGarden.features[toggle.key] = not UltimateGarden.features[toggle.key]
            self:updateToggle(toggleFrame, UltimateGarden.features[toggle.key], theme)
            Utils.notify("Auto Extra", toggle.name .. (UltimateGarden.features[toggle.key] and " เปิด" or " ปิด"), 2, "🐾")
        end)
    end
end

-- Create Smart Config Tab
function ModernUI:createSmartConfigTab(parent, theme)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = parent
    
    layout.Changed:Connect(function()
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Speed Control
    local speedSection = self:createSection("⚡ ควบคุมความเร็ว", parent, theme)
    local speedSlider = self:createSlider("Farm Speed", "ความเร็วการฟาร์ม", 0.1, 3.0, UltimateGarden.performance.farmSpeed, speedSection, theme)
    speedSlider.Changed:Connect(function(value)
        UltimateGarden.performance.farmSpeed = value
        Utils.notify("Speed", "ตั้งความเร็วเป็น " .. string.format("%.1f", value), 2, "⚡")
    end)
    
    -- Resource Limits
    local resourceSection = self:createSection("💰 การจัดการทรัพยากร", parent, theme)
    
    local maxSeedInput = self:createNumberInput("Max Seed Price", "ราคาเมล็ดพันธุ์สูงสุด", UltimateGarden.smart.maxSeedPrice, resourceSection, theme)
    maxSeedInput.Changed:Connect(function(value)
        UltimateGarden.smart.maxSeedPrice = value
    end)
    
    local minCropInput = self:createNumberInput("Min Crop Value", "มูลค่าพืชขั้นต่ำ", UltimateGarden.smart.minCropValue, resourceSection, theme)
    minCropInput.Changed:Connect(function(value)
        UltimateGarden.smart.minCropValue = value
    end)
    
    -- Priority System
    local prioritySection = self:createSection("🎯 ระบบลำดับความสำคัญ", parent, theme)
    local priorityList = self:createPriorityList(UltimateGarden.smart.farmPriority, prioritySection, theme)
end

-- Create Objects Tab
function ModernUI:createObjectsTab(parent, theme)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = parent
    
    layout.Changed:Connect(function()
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Search Box
    local searchSection = self:createSection("🔍 ค้นหาวัตถุ", parent, theme)
    local searchBox = self:createTextInput("Search Objects", "พิมพ์ชื่อวัตถุที่ต้องการค้นหา...", searchSection, theme)
    
    -- Scan Button
    local scanBtn = self:createButton("🔄 สแกนวัตถุใหม่", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 0), theme.accent, searchSection)
    scanBtn.MouseButton1Click:Connect(function()
        ObjectDetector:scan()
    end)
    
    -- Object Lists
    local categories = {"eggs", "shops", "seeds", "plants", "npcs", "pets", "rewards"}
    local categoryNames = {
        eggs = "🥚 ไข่",
        shops = "🏪 ร้านค้า",
        seeds = "🌱 เมล็ดพันธุ์",
        plants = "🌿 พืช",
        npcs = "👤 NPC",
        pets = "🐾 สัตว์เลี้ยง",
        rewards = "🎁 รางวัล"
    }
    
    for _, category in pairs(categories) do
        local categorySection = self:createSection(categoryNames[category], parent, theme)
        local objectList = self:createObjectList(category, categorySection, theme)
        
        -- Update list when objects change
        spawn(function()
            while UltimateGarden.enabled do
                self:updateObjectList(objectList, category, theme)
                wait(5)
            end
        end)
    end
end

-- Create Stats Tab
function ModernUI:createStatsTab(parent, theme)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = parent
    
    layout.Changed:Connect(function()
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Performance Stats
    local perfSection = self:createSection("⚡ ประสิทธิภาพ", parent, theme)
    local perfStats = self:createStatsDisplay(perfSection, theme, {
        {"FPS", "60"},
        {"Memory", "0 MB"},
        {"Ping", "0 ms"},
        {"Uptime", "0m"}
    })
    
    -- Farm Stats
    local farmSection = self:createSection("🚜 การฟาร์ม", parent, theme)
    local farmStats = self:createStatsDisplay(farmSection, theme, {
        {"Plants Grown", "0"},
        {"Harvests", "0"},
        {"Sales", "0"},
        {"Profit", "$0"}
    })
    
    -- Object Stats
    local objSection = self:createSection("📊 วัตถุที่พบ", parent, theme)
    local objStats = self:createStatsDisplay(objSection, theme, {
        {"Eggs", "0"},
        {"Shops", "0"},
        {"Seeds", "0"},
        {"NPCs", "0"}
    })
    
    -- Update stats periodically
    spawn(function()
        local startTime = tick()
        while UltimateGarden.enabled do
            -- Update performance stats
            local uptime = tick() - startTime
            local uptimeStr = math.floor(uptime / 60) .. "m " .. math.floor(uptime % 60) .. "s"
            
            self:updateStatsDisplay(perfStats, {
                {"FPS", tostring(math.floor(1 / RunService.Heartbeat:Wait()))},
                {"Memory", math.floor(collectgarbage("count") / 1024) .. " MB"},
                {"Ping", math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms"},
                {"Uptime", uptimeStr}
            })
            
            -- Update object stats
            local data = UltimateGarden.data.gameObjects
            self:updateStatsDisplay(objStats, {
                {"Eggs", tostring(#(data.eggs or {}))},
                {"Shops", tostring(#(data.shops or {}))},
                {"Seeds", tostring(#(data.seeds or {}))},
                {"NPCs", tostring(#(data.npcs or {}))}
            })
            
            wait(1)
        end
    end)
end

-- Create Settings Tab
function ModernUI:createSettingsTab(parent, theme)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = parent
    
    layout.Changed:Connect(function()
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- UI Settings
    local uiSection = self:createSection("🎨 การตั้งค่า UI", parent, theme)
    
    -- Theme Selector
    local themeDropdown = self:createDropdown("Theme", {"dark", "light"}, UltimateGarden.ui.theme, uiSection, theme)
    themeDropdown.Changed:Connect(function(newTheme)
        UltimateGarden.ui.theme = newTheme
        Utils.notify("UI", "เปลี่ยนธีมเป็น " .. newTheme, 2, "🎨")
        -- Recreate UI with new theme
        spawn(function()
            wait(0.5)
            ModernUI:create()
        end)
    end)
    
    -- Notification Toggle
    local notifToggle = self:createToggle("Notifications", "แสดงการแจ้งเตือน", UltimateGarden.ui.showNotifications, uiSection, theme)
    notifToggle.Button.MouseButton1Click:Connect(function()
        UltimateGarden.ui.showNotifications = not UltimateGarden.ui.showNotifications
        self:updateToggle(notifToggle, UltimateGarden.ui.showNotifications, theme)
    end)
    
    -- Debug Settings
    local debugSection = self:createSection("🔧 การตั้งค่าขั้นสูง", parent, theme)
    
    local debugToggle = self:createToggle("Debug Mode", "โหมดแสดงข้อมูลแก้ไขจุดบกพร่อง", UltimateGarden.debugMode, debugSection, theme)
    debugToggle.Button.MouseButton1Click:Connect(function()
        UltimateGarden.debugMode = not UltimateGarden.debugMode
        self:updateToggle(debugToggle, UltimateGarden.debugMode, theme)
        Utils.notify("Debug", "Debug Mode " .. (UltimateGarden.debugMode and "เปิด" or "ปิด"), 2, "🔧")
    end)
    
    -- Anti-AFK Toggle
    local afkToggle = self:createToggle("Anti-AFK", "ป้องกันการถูกเตะออกจากเกม", UltimateGarden.features.antiAFK, debugSection, theme)
    afkToggle.Button.MouseButton1Click:Connect(function()
        UltimateGarden.features.antiAFK = not UltimateGarden.features.antiAFK
        self:updateToggle(afkToggle, UltimateGarden.features.antiAFK, theme)
        Utils.notify("Anti-AFK", UltimateGarden.features.antiAFK and "เปิดใช้งาน" or "ปิดใช้งาน", 2, "🛡️")
    end)
    
    -- Action Buttons
    local actionSection = self:createSection("🔄 การกระทำ", parent, theme)
    
    local resetBtn = self:createButton("Reset All Settings", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 0), theme.danger, actionSection)
    resetBtn.MouseButton1Click:Connect(function()
        -- Reset to defaults
        UltimateGarden.performance.farmSpeed = 1.0
        UltimateGarden.smart.maxSeedPrice = 1000
        UltimateGarden.smart.minCropValue = 100
        Utils.notify("Settings", "รีเซ็ตการตั้งค่าเรียบร้อย", 3, "🔄")
    end)
    
    local rescanBtn = self:createButton("Rescan All Objects", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 0), theme.accent, actionSection)
    rescanBtn.MouseButton1Click:Connect(function()
        ObjectDetector:scan()
        RemoteSystem:detectRemotes()
    end)
end

-- Helper Functions for UI Components

function ModernUI:createSection(title, parent, theme)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 200)
    section.Position = UDim2.new(0, 10, 0, 0)
    section.BackgroundColor3 = theme.primary
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 12)
    sectionCorner.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -30, 1, -60)
    contentFrame.Position = UDim2.new(0, 15, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = section
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentFrame
    
    -- Auto-resize section
    contentLayout.Changed:Connect(function()
        section.Size = UDim2.new(1, -20, 0, math.max(contentLayout.AbsoluteContentSize.Y + 80, 100))
    end)
    
    return contentFrame
end

function ModernUI:createButton(text, size, position, color, parent)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(color.R + 0.1, color.G + 0.1, color.B + 0.1)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    return button
end

function ModernUI:createToggle(name, description, enabled, parent, theme)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 60)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 0, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = theme.text
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = toggleFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = theme.textSecondary
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 80, 0, 30)
    toggleButton.Position = UDim2.new(1, -80, 0.5, -15)
    toggleButton.BackgroundColor3 = enabled and theme.success or theme.danger
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = enabled and "เปิด" or "ปิด"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 15)
    toggleCorner.Parent = toggleButton
    
    toggleFrame.Button = toggleButton
    return toggleFrame
end

function ModernUI:updateToggle(toggleFrame, enabled, theme)
    local button = toggleFrame.Button
    button.BackgroundColor3 = enabled and theme.success or theme.danger
    button.Text = enabled and "เปิด" or "ปิด"
end

function ModernUI:createSlider(name, description, minVal, maxVal, currentVal, parent, theme)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 80)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 0, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name .. ": " .. string.format("%.1f", currentVal)
    nameLabel.TextColor3 = theme.text
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = sliderFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = theme.textSecondary
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = sliderFrame
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, 0, 0, 6)
    sliderBG.Position = UDim2.new(0, 0, 0, 55)
    sliderBG.BackgroundColor3 = theme.secondary
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = sliderFrame
    
    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(0, 3)
    sliderBGCorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = theme.accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 3)
    sliderFillCorner.Parent = sliderFill
    
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new((currentVal - minVal) / (maxVal - minVal), -10, 0, -7)
    sliderHandle.BackgroundColor3 = theme.accent
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Text = ""
    sliderHandle.Parent = sliderBG
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 10)
    handleCorner.Parent = sliderHandle
    
    -- Slider functionality
    local dragging = false
    
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBG.AbsolutePosition
            local sliderSize = sliderBG.AbsoluteSize
            
            local relativePos = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = minVal + (maxVal - minVal) * relativePos
            
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            sliderHandle.Position = UDim2.new(relativePos, -10, 0, -7)
            nameLabel.Text = name .. ": " .. string.format("%.1f", value)
            
            if sliderFrame.Changed then
                sliderFrame.Changed(value)
            end
        end
    end)
    
    return sliderFrame
end

function ModernUI:createNumberInput(name, description, currentVal, parent, theme)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 0, 80)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 0, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = theme.text
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = inputFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = theme.textSecondary
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.3, 0, 0, 30)
    textBox.Position = UDim2.new(0.7, 0, 0, 0)
    textBox.BackgroundColor3 = theme.secondary
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(currentVal)
    textBox.TextColor3 = theme.text
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = "ใส่ตัวเลข..."
    textBox.Parent = inputFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 6)
    textBoxCorner.Parent = textBox
    
    textBox.FocusLost:Connect(function()
        local value = tonumber(textBox.Text) or currentVal
        textBox.Text = tostring(value)
        if inputFrame.Changed then
            inputFrame.Changed(value)
        end
    end)
    
    return inputFrame
end

function ModernUI:createDropdown(name, options, currentValue, parent, theme)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = theme.text
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = dropdownFrame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.35, 0, 0, 35)
    dropdown.Position = UDim2.new(0.65, 0, 0.5, -17)
    dropdown.BackgroundColor3 = theme.secondary
    dropdown.BorderSizePixel = 0
    dropdown.Text = currentValue .. " ▼"
    dropdown.TextColor3 = theme.text
    dropdown.TextSize = 14
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = dropdownFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    local expanded = false
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(1, 0, 0, #options * 30)
    optionFrame.Position = UDim2.new(0, 0, 1, 5)
    optionFrame.BackgroundColor3 = theme.secondary
    optionFrame.BorderSizePixel = 0
    optionFrame.Visible = false
    optionFrame.Parent = dropdown
    
    local optionCorner = Instance.new("UICorner")
    optionCorner.CornerRadius = UDim.new(0, 6)
    optionCorner.Parent = optionFrame
    
    local optionLayout = Instance.new("UIListLayout")
    optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionLayout.Parent = optionFrame
    
    for i, option in pairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 30)
        optionBtn.BackgroundColor3 = theme.secondary
        optionBtn.BorderSizePixel = 0
        optionBtn.Text = option
        optionBtn.TextColor3 = theme.text
        optionBtn.TextSize = 14
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.Parent = optionFrame
        
        optionBtn.MouseButton1Click:Connect(function()
            dropdown.Text = option .. " ▼"
            optionFrame.Visible = false
            expanded = false
            if dropdownFrame.Changed then
                dropdownFrame.Changed(option)
            end
        end)
        
        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = theme.accent
        end)
        
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundColor3 = theme.secondary
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionFrame.Visible = expanded
        dropdown.Text = string.gsub(dropdown.Text, " [▼▲]", "") .. (expanded and " ▲" or " ▼")
    end)
    
    return dropdownFrame
end

function ModernUI:createTextInput(name, placeholder, parent, theme)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 0, 50)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = parent
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.BackgroundColor3 = theme.secondary
    textBox.BorderSizePixel = 0
    textBox.Text = ""
    textBox.TextColor3 = theme.text
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = theme.textSecondary
    textBox.Parent = inputFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 8)
    textBoxCorner.Parent = textBox
    
    return textBox
end

function ModernUI:createObjectList(category, parent, theme)
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 150)
    listFrame.BackgroundColor3 = theme.secondary
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 6
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.Parent = parent
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = listFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame
    
    listLayout.Changed:Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    return listFrame
end

function ModernUI:updateObjectList(listFrame, category, theme)
    -- Clear existing items
    for _, child in pairs(listFrame:GetChildren()) do
        if child.Name == "ObjectItem" then
            child:Destroy()
        end
    end
    
    local objects = UltimateGarden.data.gameObjects[category] or {}
    
    for i, obj in pairs(objects) do
        if i > 20 then break end -- Limit to 20 items for performance
        
        local item = Instance.new("TextButton")
        item.Name = "ObjectItem"
        item.Size = UDim2.new(1, 0, 0, 25)
        item.BackgroundColor3 = theme.primary
        item.BorderSizePixel = 0
        item.Text = "• " .. obj.name .. " (Value: " .. string.format("%.1f", obj.value) .. ")"
        item.TextColor3 = theme.text
        item.TextSize = 12
        item.Font = Enum.Font.Gotham
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.Parent = listFrame
        
        item.MouseButton1Click:Connect(function()
            -- Teleport to object
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and obj.position then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(obj.position + Vector3.new(0, 5, 0))
                Utils.notify("Teleport", "เทเลพอร์ตไปยัง " .. obj.name, 2, "🚀")
            end
        end)
        
        item.MouseEnter:Connect(function()
            item.BackgroundColor3 = theme.accent
        end)
        
        item.MouseLeave:Connect(function()
            item.BackgroundColor3 = theme.primary
        end)
    end
end

function ModernUI:createStatsDisplay(parent, theme, stats)
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, 0, 0, #stats * 30 + 20)
    statsFrame.BackgroundColor3 = theme.secondary
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = parent
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 8)
    statsCorner.Parent = statsFrame
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Padding = UDim.new(0, 5)
    statsLayout.Parent = statsFrame
    
    local statLabels = {}
    
    for i, stat in pairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(1, -20, 0, 25)
        statFrame.Position = UDim2.new(0, 10, 0, 0)
        statFrame.BackgroundTransparency = 1
        statFrame.Parent = statsFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = stat[1] .. ":"
        nameLabel.TextColor3 = theme.text
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = statFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = stat[2]
        valueLabel.TextColor3 = theme.accent
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = statFrame
        
        statLabels[stat[1]] = valueLabel
    end
    
    return statLabels
end

function ModernUI:updateStatsDisplay(statLabels, stats)
    for _, stat in pairs(stats) do
        if statLabels[stat[1]] then
            statLabels[stat[1]].Text = stat[2]
        end
    end
end

function ModernUI:makeDraggable(dragHandle, frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================================================
-- MAIN EXECUTION SYSTEM
-- ============================================================================

-- Main Loop
local function mainLoop()
    Utils.log("Starting main loop...", "main")
    
    local lastScan = 0
    local lastRemoteScan = 0
    local actionCount = 0
    
    while UltimateGarden.enabled do
        local currentTime = tick()
        
        -- Scan for objects periodically
        if currentTime - lastScan > UltimateGarden.performance.scanInterval then
            ObjectDetector:scan()
            lastScan = currentTime
        end
        
        -- Scan for remotes less frequently
        if currentTime - lastRemoteScan > 120 then -- Every 2 minutes
            RemoteSystem:detectRemotes()
            lastRemoteScan = currentTime
        end
        
        -- Generate smart farming actions
        if UltimateGarden.features.smartFarming then
            SmartFarm:generateActions()
        end
        
        -- Process farming queue
        SmartFarm:processQueue()
        
        -- Auto-equip pet
        if UltimateGarden.features.autoEquipPet then
            Utils.debounce("auto_pet", function()
                PetManager:equipBestPet()
            end, 30) -- Every 30 seconds
        end
        
        -- Auto-claim rewards
        if UltimateGarden.features.autoClaimRewards then
            Utils.debounce("auto_rewards", function()
                RewardManager:claimRewards()
            end, 60) -- Every minute
        end
        
        -- Rate limiting
        actionCount = actionCount + 1
        if actionCount >= UltimateGarden.performance.maxActions then
            actionCount = 0
            wait(UltimateGarden.performance.farmSpeed)
        else
            wait(0.1)
        end
    end
    
    Utils.log("Main loop stopped.", "main")
end

-- Anti-AFK System
local function setupAntiAFK()
    Players.LocalPlayer.Idled:Connect(function()
        if UltimateGarden.features.antiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            Utils.log("Anti-AFK triggered", "antiaFK")
        end
    end)
end

-- Error Handler
local function setupErrorHandler()
    local function handleError(err)
        Utils.log("Unhandled error: " .. tostring(err), "error")
        Utils.notify("Error", "เกิดข้อผิดพลาด: " .. tostring(err), 5, "❌")
    end
    
    -- Wrap main functions in error handlers
    spawn(function()
        local success, err = pcall(mainLoop)
        if not success then
            handleError(err)
        end
    end)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

local function initialize()
    Utils.log("Initializing Ultimate Garden Pro v" .. UltimateGarden.version, "init")
    
    -- Setup core systems
    setupAntiAFK()
    setupErrorHandler()
    
    -- Initial scans
    ObjectDetector:scan()
    RemoteSystem:detectRemotes()
    
    -- Create UI
    ModernUI:create()
    
    -- Start main loop
    spawn(mainLoop)
    
    -- Welcome message
    Utils.notify("🌱 Ultimate Garden Pro", "เวอร์ชั่น " .. UltimateGarden.version .. " พร้อมใช้งาน!", 5, "🚀")
    Utils.log("Initialization complete!", "init")
end

-- Start the script
initialize()

-- ============================================================================
-- CLEANUP ON SCRIPT END
-- ============================================================================

local function cleanup()
    UltimateGarden.enabled = false
    Utils.log("Script cleanup completed", "cleanup")
end

-- Register cleanup
game:GetService("Players").PlayerRemoving:Connect(cleanup)

print("🌱 Grow Garden Ultimate Pro v" .. UltimateGarden.version .. " loaded successfully!")
print("📊 Features: Smart Farming, Auto-Equip Pet, Auto-Claim Rewards, Modern UI")
print("🔧 Performance: Optimized scanning, debounced actions, error handling")
print("🎨 UI: Modern design, theme system, responsive layout")
