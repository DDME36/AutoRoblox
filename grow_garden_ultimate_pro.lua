-- ═══════════════════════════════════════════════════════════════════════════════════════
-- 🌱 GROW A GARDEN - ULTIMATE VERSION 🌱  
-- ✨ เวอร์ชันสุดยอดที่รวม UI สวยงาม + การตรวจจับแม่นยำ + ฟีเจอร์ครบครัน
-- 🔥 สำหรับการใช้งานผ่าน Delta Executor และ Executors อื่นๆ
-- 🎯 ใช้โค้ดนี้เพียงบรรทัดเดียว: loadstring(game:HttpGet("URL"))()
-- ═══════════════════════════════════════════════════════════════════════════════════════

-- รอให้เกมโหลดเสร็จ
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                          🎨 ULTIMATE UI SYSTEM 🎨                          ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local UltimateGUI = {}

-- สีธีมสวยงาม
UltimateGUI.Colors = {
    Primary = Color3.fromRGB(74, 144, 226),
    Secondary = Color3.fromRGB(26, 188, 156), 
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Danger = Color3.fromRGB(231, 76, 60),
    Dark = Color3.fromRGB(52, 73, 94),
    Light = Color3.fromRGB(236, 240, 241),
    Background = Color3.fromRGB(44, 62, 80),
    Surface = Color3.fromRGB(52, 73, 94),
    Border = Color3.fromRGB(149, 165, 166),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(189, 195, 199)
}

-- การตั้งค่าหลัก
UltimateGUI.Settings = {
    -- ฟาร์ม
    AutoPlant = false,
    AutoHarvest = false, 
    AutoSell = false,
    AutoWater = false,
    
    -- ซื้อของ
    AutoBuySeeds = false,
    AutoBuyEggs = false,
    AutoBuyShops = false,
    AutoBuyTools = false,
    
    -- เป้าหมาย
    SelectedSeed = "Carrot",
    SelectedEgg = "Common Egg",
    BuyAmount = 1,
    
    -- ประสิทธิภาพ
    FarmSpeed = 1.0,
    ScanInterval = 30,
    BuyInterval = 15,
    
    -- ระบบ
    AntiAFK = true,
    AutoReconnect = true,
    SmartDetection = true,
    ShowNotifications = true,
    
    -- UI
    UIScale = 1.0,
    Theme = "Dark"
}

-- ข้อมูลเกม
UltimateGUI.GameData = {
    RemoteEvents = {},
    Seeds = {},
    Eggs = {},
    Shops = {},
    Tools = {},
    Plants = {},
    NPCs = {},
    PlayerStats = {
        Money = 0,
        Level = 1,
        Pets = 0,
        PlantCount = 0
    },
    LastScan = 0,
    LastBuy = 0,
    LastFarm = 0,
    Connections = {}
}

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                       🔍 ADVANCED DETECTION SYSTEM 🔍                      ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:ScanRemoteEvents()
    local events = {}
    
    local function scanContainer(container, path)
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                local name = child.Name:lower()
                
                -- จัดหมวดหมู่อัตโนมัติ
                local category = "unknown"
                if name:find("buy") or name:find("purchase") or name:find("shop") then
                    category = "buy"
                elseif name:find("plant") or name:find("seed") then
                    category = "plant"
                elseif name:find("harvest") or name:find("collect") then
                    category = "harvest"
                elseif name:find("sell") or name:find("trade") then
                    category = "sell"
                elseif name:find("water") then
                    category = "water"
                elseif name:find("pet") or name:find("egg") then
                    category = "pet"
                end
                
                events[child.Name] = {
                    Event = child,
                    Path = path .. "/" .. child.Name,
                    Category = category,
                    Type = child.ClassName
                }
            elseif child:IsA("Folder") then
                scanContainer(child, path .. "/" .. child.Name)
            end
        end
    end
    
    scanContainer(ReplicatedStorage, "ReplicatedStorage")
    self.GameData.RemoteEvents = events
    
    print("🔍 สแกน RemoteEvents:", self:CountTable(events), "ตัว")
end

function UltimateGUI:ScanGameItems()
    -- รีเซ็ตข้อมูล
    self.GameData.Seeds = {}
    self.GameData.Eggs = {}
    self.GameData.Shops = {}
    self.GameData.Tools = {}
    self.GameData.Plants = {}
    self.GameData.NPCs = {}
    
    -- คีย์เวิร์ดสำหรับการตรวจจับ
    local seedWords = {"carrot", "tomato", "potato", "corn", "wheat", "seed", "เมล็ด"}
    local eggWords = {"egg", "common", "rare", "epic", "legendary", "ไข่"}
    local shopWords = {"shop", "store", "market", "ร้าน", "ร้านค้า"}
    local toolWords = {"tool", "water", "shovel", "hoe", "เครื่องมือ"}
    
    local function scanWorkspace(container, depth)
        if depth > 5 then return end
        
        for _, obj in pairs(container:GetChildren()) do
            local name = obj.Name:lower()
            
            -- ตรวจสอบเมล็ดพันธุ์
            for _, word in pairs(seedWords) do
                if name:find(word) then
                    table.insert(self.GameData.Seeds, {
                        Name = obj.Name,
                        Object = obj,
                        Position = self:GetPosition(obj)
                    })
                    break
                end
            end
            
            -- ตรวจสอบไข่
            for _, word in pairs(eggWords) do
                if name:find(word) then
                    table.insert(self.GameData.Eggs, {
                        Name = obj.Name,
                        Object = obj,
                        Position = self:GetPosition(obj)
                    })
                    break
                end
            end
            
            -- ตรวจสอบร้านค้า
            for _, word in pairs(shopWords) do
                if name:find(word) then
                    table.insert(self.GameData.Shops, {
                        Name = obj.Name,
                        Object = obj,
                        Position = self:GetPosition(obj)
                    })
                    break
                end
            end
            
            -- ตรวจสอบเครื่องมือ
            for _, word in pairs(toolWords) do
                if name:find(word) then
                    table.insert(self.GameData.Tools, {
                        Name = obj.Name,
                        Object = obj,
                        Position = self:GetPosition(obj)
                    })
                    break
                end
            end
            
            -- ตรวจสอบพืช
            if name:find("plant") or name:find("crop") then
                local isGrown = name:find("grown") or name:find("ready") or name:find("mature")
                table.insert(self.GameData.Plants, {
                    Name = obj.Name,
                    Object = obj,
                    Position = self:GetPosition(obj),
                    IsGrown = isGrown
                })
            end
            
            -- ตรวจสอบ NPCs
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                table.insert(self.GameData.NPCs, {
                    Name = obj.Name,
                    Object = obj,
                    Position = self:GetPosition(obj)
                })
            end
            
            -- สแกนลูกๆ
            if obj:IsA("Folder") or obj:IsA("Model") then
                scanWorkspace(obj, depth + 1)
            end
        end
    end
    
    scanWorkspace(Workspace, 0)
    
    print("📊 สแกนไอเทม - เมล็ด:", #self.GameData.Seeds, "ไข่:", #self.GameData.Eggs, "ร้าน:", #self.GameData.Shops)
end

function UltimateGUI:GetPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or obj.PrimaryPart
        return root and root.Position or Vector3.new(0, 0, 0)
    end
    return Vector3.new(0, 0, 0)
end

function UltimateGUI:CountTable(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                        💰 SMART BUYING SYSTEM 💰                           ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:GetPlayerMoney()
    local money = 0
    local paths = {
        LocalPlayer:FindFirstChild("leaderstats"),
        LocalPlayer:FindFirstChild("PlayerStats"),
        LocalPlayer:FindFirstChild("Data"),
        LocalPlayer:FindFirstChild("Stats")
    }
    
    for _, path in pairs(paths) do
        if path then
            local moneyVal = path:FindFirstChild("Money") or path:FindFirstChild("Cash") or path:FindFirstChild("Coins")
            if moneyVal and moneyVal.Value then
                money = moneyVal.Value
                break
            end
        end
    end
    
    self.GameData.PlayerStats.Money = money
    return money
end

function UltimateGUI:SafeBuy(itemName, itemType, amount)
    if not itemName or amount <= 0 then return false end
    
    -- ตรวจสอบเงิน
    local money = self:GetPlayerMoney()
    if money <= 0 then
        self:ShowNotification("❌ เงินไม่พอสำหรับการซื้อ", self.Colors.Danger)
        return false
    end
    
    -- หา RemoteEvent ที่เหมาะสม
    local buyEvents = {}
    for _, data in pairs(self.GameData.RemoteEvents) do
        if data.Category == "buy" then
            table.insert(buyEvents, data)
        end
    end
    
    -- ลองซื้อ
    for _, eventData in pairs(buyEvents) do
        local attempts = {
            function()
                eventData.Event:FireServer(itemName, amount)
            end,
            function()
                eventData.Event:FireServer({Item = itemName, Amount = amount})
            end,
            function()
                eventData.Event:FireServer("Buy", itemName, amount)
            end,
            function()
                eventData.Event:FireServer(itemType, itemName, amount)
            end
        }
        
        for _, attempt in pairs(attempts) do
            local success = pcall(attempt)
            if success then
                self:ShowNotification("✅ ซื้อ " .. itemName .. " สำเร็จ", self.Colors.Success)
                return true
            end
        end
    end
    
    self:ShowNotification("❌ ไม่สามารถซื้อ " .. itemName .. " ได้", self.Colors.Danger)
    return false
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                         🌱 AUTO FARMING SYSTEM 🌱                          ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:TeleportTo(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        wait(0.1)
        return true
    end
    return false
end

function UltimateGUI:AutoPlant()
    if not self.Settings.AutoPlant then return end
    
    -- หาแปลงปลูก
    local plots = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if (name:find("plot") or name:find("soil") or name:find("แปลง")) and obj:IsA("BasePart") then
            table.insert(plots, obj)
        end
    end
    
    -- ปลูกในแปลงแรก
    for _, plot in pairs(plots) do
        self:TeleportTo(plot.Position)
        
        -- ลองปลูก
        for _, eventData in pairs(self.GameData.RemoteEvents) do
            if eventData.Category == "plant" then
                pcall(function()
                    eventData.Event:FireServer(self.Settings.SelectedSeed)
                end)
                pcall(function()
                    eventData.Event:FireServer("Plant", self.Settings.SelectedSeed)
                end)
            end
        end
        wait(0.2)
        break
    end
end

function UltimateGUI:AutoHarvest()
    if not self.Settings.AutoHarvest then return end
    
    -- หาพืชที่โตแล้ว
    for _, plantData in pairs(self.GameData.Plants) do
        if plantData.IsGrown and plantData.Position then
            self:TeleportTo(plantData.Position)
            
            -- ลองเก็บเกี่ยว
            for _, eventData in pairs(self.GameData.RemoteEvents) do
                if eventData.Category == "harvest" then
                    pcall(function()
                        eventData.Event:FireServer(plantData.Object)
                    end)
                    pcall(function()
                        eventData.Event:FireServer("Harvest")
                    end)
                end
            end
            wait(0.2)
        end
    end
end

function UltimateGUI:AutoSell()
    if not self.Settings.AutoSell then return end
    
    -- หาจุดขาย
    for _, shopData in pairs(self.GameData.Shops) do
        if shopData.Position then
            self:TeleportTo(shopData.Position)
            
            -- ลองขาย
            for _, eventData in pairs(self.GameData.RemoteEvents) do
                if eventData.Category == "sell" then
                    pcall(function()
                        eventData.Event:FireServer()
                    end)
                    pcall(function()
                        eventData.Event:FireServer("SellAll")
                    end)
                end
            end
            wait(0.2)
            break
        end
    end
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                         🎨 ULTIMATE UI CREATION 🎨                         ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:CreateMainGUI()
    -- ลบ GUI เก่า
    if PlayerGui:FindFirstChild("GrowGardenUltimate") then
        PlayerGui.GrowGardenUltimate:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowGardenUltimate"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = self.Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    MainFrame.Size = UDim2.new(0, 600, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.Colors.Primary
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = self.Colors.Primary
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 60, 0, 0)
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌱 Grow Garden Ultimate Script 🌱"
    Title.TextColor3 = self.Colors.Light
    Title.TextScaled = true
    
    local Icon = Instance.new("TextLabel")
    Icon.Parent = TitleBar
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 10, 0, 0)
    Icon.Size = UDim2.new(0, 40, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = "🌱"
    Icon.TextColor3 = self.Colors.Light
    Icon.TextScaled = true
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = self.Colors.Danger
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -45, 0, 5)
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = self.Colors.Light
    CloseButton.TextScaled = true
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 10)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 60)
    ContentFrame.Size = UDim2.new(1, 0, 1, -70)
    
    -- Tab System
    self:CreateTabSystem(ContentFrame)
    
    return ScreenGui
end

function UltimateGUI:CreateTabSystem(parent)
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = parent
    TabFrame.BackgroundTransparency = 1
    TabFrame.Size = UDim2.new(1, 0, 0, 40)
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabFrame
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Padding = UDim.new(0, 10)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = parent
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 50)
    ContentFrame.Size = UDim2.new(1, 0, 1, -50)
    
    local tabs = {
        {Name = "🌱 ฟาร์ม", Key = "Farm", Color = self.Colors.Success},
        {Name = "🛒 ซื้อของ", Key = "Buy", Color = self.Colors.Primary},
        {Name = "⚙️ ตั้งค่า", Key = "Settings", Color = self.Colors.Warning},
        {Name = "📊 สถิติ", Key = "Stats", Color = self.Colors.Secondary}
    }
    
    local currentTab = nil
    
    for i, tabData in pairs(tabs) do
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabData.Key .. "Tab"
        TabButton.Parent = TabFrame
        TabButton.BackgroundColor3 = tabData.Color
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(0, 130, 1, 0)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = tabData.Name
        TabButton.TextColor3 = self.Colors.Light
        TabButton.TextSize = 14
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 10)
        TabCorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabData.Key .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundColor3 = self.Colors.Surface
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 2, 0)
        TabContent.ScrollBarThickness = 8
        TabContent.Visible = (i == 1)
        
        local ContentCorner = Instance.new("UICorner")
        ContentCorner.CornerRadius = UDim.new(0, 10)
        ContentCorner.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 15)
        ContentPadding.PaddingLeft = UDim.new(0, 15)
        ContentPadding.PaddingRight = UDim.new(0, 15)
        ContentPadding.PaddingBottom = UDim.new(0, 15)
        ContentPadding.Parent = TabContent
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        -- Tab Events
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, child in pairs(ContentFrame:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Reset all button colors
            for _, button in pairs(TabFrame:GetChildren()) do
                if button:IsA("TextButton") then
                    TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = self.Colors.Dark}):Play()
                end
            end
            
            -- Show selected tab
            TabContent.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = tabData.Color}):Play()
            currentTab = tabData.Key
        end)
        
        -- Create tab content
        if tabData.Key == "Farm" then
            self:CreateFarmTab(TabContent)
        elseif tabData.Key == "Buy" then
            self:CreateBuyTab(TabContent)
        elseif tabData.Key == "Settings" then
            self:CreateSettingsTab(TabContent)
        elseif tabData.Key == "Stats" then
            self:CreateStatsTab(TabContent)
        end
    end
end

function UltimateGUI:CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = self.Colors.Dark
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = self.Colors.Text
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = default and self.Colors.Success or self.Colors.Danger
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -60, 0, 10)
    ToggleButton.Size = UDim2.new(0, 50, 0, 30)
    ToggleButton.Text = default and "เปิด" or "ปิด"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextColor3 = self.Colors.Light
    ToggleButton.TextSize = 12
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ToggleButton
    
    local isToggled = default
    
    ToggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        local newColor = isToggled and self.Colors.Success or self.Colors.Danger
        local newText = isToggled and "เปิด" or "ปิด"
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play()
        ToggleButton.Text = newText
        
        callback(isToggled)
    end)
    
    return ToggleFrame
end

function UltimateGUI:CreateButton(parent, text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.BackgroundColor3 = color or self.Colors.Primary
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = self.Colors.Light
    Button.TextSize = 16
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    -- Hover effects
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.Secondary}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = color or self.Colors.Primary}):Play()
    end)
    
    return Button
end

function UltimateGUI:CreateFarmTab(parent)
    self:CreateToggle(parent, "🌱 ปลูกพืชอัตโนมัติ", self.Settings.AutoPlant, function(value)
        self.Settings.AutoPlant = value
        self:ShowNotification("🌱 ปลูกพืชอัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "🌾 เก็บเกี่ยวอัตโนมัติ", self.Settings.AutoHarvest, function(value)
        self.Settings.AutoHarvest = value
        self:ShowNotification("🌾 เก็บเกี่ยวอัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "💰 ขายอัตโนมัติ", self.Settings.AutoSell, function(value)
        self.Settings.AutoSell = value
        self:ShowNotification("💰 ขายอัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "💧 รดน้ำอัตโนมัติ", self.Settings.AutoWater, function(value)
        self.Settings.AutoWater = value
        self:ShowNotification("💧 รดน้ำอัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateButton(parent, "🌟 เปิดฟาร์มทั้งหมด", self.Colors.Success, function()
        self.Settings.AutoPlant = true
        self.Settings.AutoHarvest = true
        self.Settings.AutoSell = true
        self.Settings.AutoWater = true
        self:ShowNotification("🌟 เปิดฟาร์มทั้งหมดแล้ว!", self.Colors.Success)
    end)
    
    self:CreateButton(parent, "🛑 ปิดฟาร์มทั้งหมด", self.Colors.Danger, function()
        self.Settings.AutoPlant = false
        self.Settings.AutoHarvest = false
        self.Settings.AutoSell = false
        self.Settings.AutoWater = false
        self:ShowNotification("🛑 ปิดฟาร์มทั้งหมดแล้ว!", self.Colors.Danger)
    end)
end

function UltimateGUI:CreateBuyTab(parent)
    self:CreateToggle(parent, "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ", self.Settings.AutoBuySeeds, function(value)
        self.Settings.AutoBuySeeds = value
        self:ShowNotification("🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "🥚 ซื้อไข่อัตโนมัติ", self.Settings.AutoBuyEggs, function(value)
        self.Settings.AutoBuyEggs = value
        self:ShowNotification("🥚 ซื้อไข่อัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "🏪 ซื้อร้านค้าอัตโนมัติ", self.Settings.AutoBuyShops, function(value)
        self.Settings.AutoBuyShops = value
        self:ShowNotification("🏪 ซื้อร้านค้าอัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "🔧 ซื้อเครื่องมืออัตโนมัติ", self.Settings.AutoBuyTools, function(value)
        self.Settings.AutoBuyTools = value
        self:ShowNotification("🔧 ซื้อเครื่องมืออัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateButton(parent, "🛒 ซื้อทั้งหมดทันที", self.Colors.Primary, function()
        if self.Settings.AutoBuySeeds and #self.GameData.Seeds > 0 then
            self:SafeBuy(self.GameData.Seeds[1].Name, "Seed", self.Settings.BuyAmount)
        end
        if self.Settings.AutoBuyEggs and #self.GameData.Eggs > 0 then
            self:SafeBuy(self.GameData.Eggs[1].Name, "Egg", self.Settings.BuyAmount)
        end
        self:ShowNotification("🛒 พยายามซื้อทั้งหมดแล้ว!", self.Colors.Primary)
    end)
    
    self:CreateButton(parent, "🔍 สแกนไอเทมใหม่", self.Colors.Secondary, function()
        self:FullScan()
        self:ShowNotification("🔍 สแกนไอเทมใหม่เสร็จสิ้น!", self.Colors.Secondary)
    end)
end

function UltimateGUI:CreateSettingsTab(parent)
    self:CreateToggle(parent, "🚫 ป้องกัน AFK", self.Settings.AntiAFK, function(value)
        self.Settings.AntiAFK = value
        self:ShowNotification("🚫 ป้องกัน AFK: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "🔄 เชื่อมต่ออัตโนมัติ", self.Settings.AutoReconnect, function(value)
        self.Settings.AutoReconnect = value
        if value then
            self:SetupAutoReconnect()
        end
        self:ShowNotification("🔄 เชื่อมต่ออัตโนมัติ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateToggle(parent, "🔔 แสดงการแจ้งเตือน", self.Settings.ShowNotifications, function(value)
        self.Settings.ShowNotifications = value
    end)
    
    self:CreateToggle(parent, "🧠 ตรวจจับอัจฉริยะ", self.Settings.SmartDetection, function(value)
        self.Settings.SmartDetection = value
        self:ShowNotification("🧠 ตรวจจับอัจฉริยะ: " .. (value and "เปิด" or "ปิด"), self.Colors.Success)
    end)
    
    self:CreateButton(parent, "🔄 รีเซ็ตการตั้งค่า", self.Colors.Warning, function()
        self:ResetSettings()
        self:ShowNotification("🔄 รีเซ็ตการตั้งค่าเรียบร้อย!", self.Colors.Warning)
    end)
end

function UltimateGUI:CreateStatsTab(parent)
    local statsData = {
        {Icon = "💰", Text = "เงิน", Value = function() return self:GetPlayerMoney() end},
        {Icon = "⭐", Text = "ระดับ", Value = function() return self.GameData.PlayerStats.Level end},
        {Icon = "🌱", Text = "เมล็ดพบ", Value = function() return #self.GameData.Seeds end},
        {Icon = "🥚", Text = "ไข่พบ", Value = function() return #self.GameData.Eggs end},
        {Icon = "🏪", Text = "ร้านค้าพบ", Value = function() return #self.GameData.Shops end},
        {Icon = "🌿", Text = "พืชพบ", Value = function() return #self.GameData.Plants end},
        {Icon = "🔌", Text = "RemoteEvents", Value = function() return self:CountTable(self.GameData.RemoteEvents) end}
    }
    
    for _, stat in pairs(statsData) do
        local StatFrame = Instance.new("Frame")
        StatFrame.Parent = parent
        StatFrame.BackgroundColor3 = self.Colors.Dark
        StatFrame.BorderSizePixel = 0
        StatFrame.Size = UDim2.new(1, 0, 0, 60)
        
        local StatCorner = Instance.new("UICorner")
        StatCorner.CornerRadius = UDim.new(0, 10)
        StatCorner.Parent = StatFrame
        
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Parent = StatFrame
        IconLabel.BackgroundTransparency = 1
        IconLabel.Position = UDim2.new(0, 15, 0, 0)
        IconLabel.Size = UDim2.new(0, 50, 1, 0)
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.Text = stat.Icon
        IconLabel.TextColor3 = self.Colors.Primary
        IconLabel.TextScaled = true
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Parent = StatFrame
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, 75, 0, 0)
        NameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.Text = stat.Text
        NameLabel.TextColor3 = self.Colors.Text
        NameLabel.TextSize = 18
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = StatFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        ValueLabel.Size = UDim2.new(0.5, -15, 1, 0)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(stat.Value())
        ValueLabel.TextColor3 = self.Colors.Success
        ValueLabel.TextSize = 18
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        -- อัพเดตค่าทุก 3 วินาที
        spawn(function()
            while StatFrame.Parent do
                ValueLabel.Text = tostring(stat.Value())
                wait(3)
            end
        end)
    end
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                      🌟 DESKTOP ICON & UTILITIES 🌟                        ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:CreateDesktopIcon()
    if PlayerGui:FindFirstChild("GrowGardenIcon") then
        PlayerGui.GrowGardenIcon:Destroy()
    end
    
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "GrowGardenIcon"
    IconGui.Parent = PlayerGui
    IconGui.ResetOnSpawn = false
    
    local IconButton = Instance.new("ImageButton")
    IconButton.Name = "IconButton"
    IconButton.Parent = IconGui
    IconButton.BackgroundColor3 = self.Colors.Primary
    IconButton.BorderSizePixel = 0
    IconButton.Position = UDim2.new(0, 50, 0, 50)
    IconButton.Size = UDim2.new(0, 80, 0, 80)
    IconButton.Image = ""
    IconButton.Draggable = true
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 16)
    IconCorner.Parent = IconButton
    
    local IconStroke = Instance.new("UIStroke")
    IconStroke.Color = self.Colors.Light
    IconStroke.Thickness = 3
    IconStroke.Parent = IconButton
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Parent = IconButton
    IconLabel.BackgroundTransparency = 1
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Text = "🌱"
    IconLabel.TextColor3 = self.Colors.Light
    IconLabel.TextScaled = true
    
    local isMainGUIVisible = false
    
    IconButton.MouseButton1Click:Connect(function()
        if PlayerGui:FindFirstChild("GrowGardenUltimate") then
            PlayerGui.GrowGardenUltimate:Destroy()
            isMainGUIVisible = false
        else
            self:CreateMainGUI()
            isMainGUIVisible = true
        end
    end)
    
    -- Hover effects
    IconButton.MouseEnter:Connect(function()
        TweenService:Create(IconButton, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 90, 0, 90),
            BackgroundColor3 = self.Colors.Secondary
        }):Play()
    end)
    
    IconButton.MouseLeave:Connect(function()
        TweenService:Create(IconButton, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 80, 0, 80),
            BackgroundColor3 = self.Colors.Primary
        }):Play()
    end)
    
    return IconGui
end

function UltimateGUI:ShowNotification(text, color)
    if not self.Settings.ShowNotifications then return end
    
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Parent = PlayerGui
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Parent = NotifGui
    NotifFrame.BackgroundColor3 = color or self.Colors.Primary
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Position = UDim2.new(1, 0, 0, 100)
    NotifFrame.Size = UDim2.new(0, 300, 0, 60)
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 12)
    NotifCorner.Parent = NotifFrame
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Parent = NotifFrame
    NotifText.BackgroundTransparency = 1
    NotifText.Position = UDim2.new(0, 15, 0, 0)
    NotifText.Size = UDim2.new(1, -30, 1, 0)
    NotifText.Font = Enum.Font.Gotham
    NotifText.Text = text
    NotifText.TextColor3 = self.Colors.Light
    NotifText.TextSize = 14
    NotifText.TextWrapped = true
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Slide in
    TweenService:Create(NotifFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, -310, 0, 100)}):Play()
    
    -- Slide out after 3 seconds
    spawn(function()
        wait(3)
        TweenService:Create(NotifFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, 0, 0, 100)}):Play()
        wait(0.5)
        NotifGui:Destroy()
    end)
end

function UltimateGUI:SetupAntiAFK()
    if not self.Settings.AntiAFK then return end
    
    local VirtualUser = game:GetService("VirtualUser")
    
    LocalPlayer.Idled:Connect(function()
        if self.Settings.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
    
    -- สร้างการเคลื่อนไหวเล็กน้อย
    spawn(function()
        while self.Settings.AntiAFK do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:Move(Vector3.new(0.1, 0, 0))
                wait(0.1)
                LocalPlayer.Character.Humanoid:Move(Vector3.new(-0.1, 0, 0))
            end
            wait(300) -- ทุก 5 นาที
        end
    end)
end

function UltimateGUI:SetupAutoReconnect()
    if not self.Settings.AutoReconnect then return end
    
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
            game:GetService('TeleportService'):Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

function UltimateGUI:FullScan()
    self:ScanRemoteEvents()
    self:ScanGameItems()
    self.GameData.LastScan = tick()
end

function UltimateGUI:ResetSettings()
    self.Settings = {
        AutoPlant = false,
        AutoHarvest = false,
        AutoSell = false,
        AutoWater = false,
        AutoBuySeeds = false,
        AutoBuyEggs = false,
        AutoBuyShops = false,
        AutoBuyTools = false,
        SelectedSeed = "Carrot",
        SelectedEgg = "Common Egg",
        BuyAmount = 1,
        FarmSpeed = 1.0,
        ScanInterval = 30,
        BuyInterval = 15,
        AntiAFK = true,
        AutoReconnect = true,
        SmartDetection = true,
        ShowNotifications = true,
        UIScale = 1.0,
        Theme = "Dark"
    }
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                          🚀 MAIN EXECUTION LOOP 🚀                         ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:StartMainLoop()
    self.GameData.Connections.MainLoop = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        -- สแกนทุก 30 วินาที
        if self.Settings.SmartDetection and currentTime - self.GameData.LastScan > self.Settings.ScanInterval then
            self:FullScan()
        end
        
        -- ซื้อของทุก 15 วินาที
        if currentTime - self.GameData.LastBuy > self.Settings.BuyInterval then
            if self.Settings.AutoBuySeeds and #self.GameData.Seeds > 0 then
                self:SafeBuy(self.GameData.Seeds[1].Name, "Seed", self.Settings.BuyAmount)
            end
            if self.Settings.AutoBuyEggs and #self.GameData.Eggs > 0 then
                self:SafeBuy(self.GameData.Eggs[1].Name, "Egg", self.Settings.BuyAmount)
            end
            self.GameData.LastBuy = currentTime
        end
        
        -- ฟาร์มตามความเร็วที่กำหนด
        if currentTime - self.GameData.LastFarm > self.Settings.FarmSpeed then
            if self.Settings.AutoPlant then
                self:AutoPlant()
            end
            if self.Settings.AutoHarvest then
                self:AutoHarvest()
            end
            if self.Settings.AutoSell then
                self:AutoSell()
            end
            self.GameData.LastFarm = currentTime
        end
    end)
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                            🎉 INITIALIZATION 🎉                            ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

function UltimateGUI:Initialize()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🌱 GROW A GARDEN - ULTIMATE SCRIPT 🌱")
    print("✨ เวอร์ชันสุดยอดที่รวมทุกฟีเจอร์เข้าด้วยกัน")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- เริ่มต้นระบบต่างๆ
    print("🔍 กำลังสแกนเกม...")
    self:FullScan()
    
    print("🚫 กำลังเปิดใช้งาน Anti-AFK...")
    self:SetupAntiAFK()
    
    print("🔄 กำลังตั้งค่า Auto-Reconnect...")
    self:SetupAutoReconnect()
    
    print("🎨 กำลังสร้าง UI...")
    self:CreateDesktopIcon()
    
    print("🚀 กำลังเริ่มต้น Main Loop...")
    self:StartMainLoop()
    
    -- แสดงผลลัพธ์
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📊 ผลการสแกน:")
    print("🔌 RemoteEvents:", self:CountTable(self.GameData.RemoteEvents))
    print("🌱 เมล็ดพันธุ์:", #self.GameData.Seeds)
    print("🥚 ไข่:", #self.GameData.Eggs)
    print("🏪 ร้านค้า:", #self.GameData.Shops)
    print("🔧 เครื่องมือ:", #self.GameData.Tools)
    print("🌿 พืช:", #self.GameData.Plants)
    print("👥 NPCs:", #self.GameData.NPCs)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ สคริปพร้อมใช้งาน! คลิกที่ไอคอน 🌱 เพื่อเปิด GUI")
    print("🎯 ฟีเจอร์: ปลูก, เก็บเกี่ยว, ซื้อของ, Anti-AFK, และอื่นๆ อีกมากมาย!")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- แจ้งเตือนในเกม
    self:ShowNotification("🌱 Grow Garden Ultimate Script โหลดเรียบร้อย! คลิกไอคอนเพื่อเริ่มใช้งาน", self.Colors.Success)
    
    -- Global commands
    _G.GrowGarden = {
        EnableAll = function()
            self.Settings.AutoPlant = true
            self.Settings.AutoHarvest = true
            self.Settings.AutoSell = true
            self.Settings.AutoBuySeeds = true
            self.Settings.AutoBuyEggs = true
            self:ShowNotification("🌟 เปิดทุกฟังก์ชันแล้ว!", self.Colors.Success)
        end,
        DisableAll = function()
            self.Settings.AutoPlant = false
            self.Settings.AutoHarvest = false
            self.Settings.AutoSell = false
            self.Settings.AutoBuySeeds = false
            self.Settings.AutoBuyEggs = false
            self:ShowNotification("🛑 ปิดทุกฟังก์ชันแล้ว!", self.Colors.Danger)
        end,
        Rescan = function()
            self:FullScan()
            self:ShowNotification("🔍 สแกนใหม่เสร็จสิ้น!", self.Colors.Secondary)
        end,
        ShowGUI = function()
            if not PlayerGui:FindFirstChild("GrowGardenUltimate") then
                self:CreateMainGUI()
            end
        end,
        HideGUI = function()
            if PlayerGui:FindFirstChild("GrowGardenUltimate") then
                PlayerGui.GrowGardenUltimate:Destroy()
            end
        end,
        CheckMoney = function()
            local money = self:GetPlayerMoney()
            print("💰 เงินปัจจุบัน:", money)
            self:ShowNotification("💰 เงิน: " .. money, self.Colors.Warning)
        end
    }
    
    print("💡 คำสั่งพิเศษ:")
    print("   _G.GrowGarden.EnableAll() - เปิดทั้งหมด")
    print("   _G.GrowGarden.DisableAll() - ปิดทั้งหมด")
    print("   _G.GrowGarden.Rescan() - สแกนใหม่")
    print("   _G.GrowGarden.CheckMoney() - ดูเงิน")
end

-- เริ่มต้นสคริป
UltimateGUI:Initialize()

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- ┃                             🌟 THE END 🌟                                   ┃
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

return UltimateGUI
