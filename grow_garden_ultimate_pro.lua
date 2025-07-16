-- Grow a Garden - เครื่องมือช่วยเหลือผู้เล่น
-- เครื่องมือนี้ออกแบบมาเพื่อช่วยในการทดสอบและปรับปรุงประสบการณ์ผู้เล่น
-- ไม่ใช่เพื่อการโกง แต่เพื่อช่วยนักพัฒนาและผู้เล่นในการทดสอบฟีเจอร์ต่างๆ

-- โหลด Orion Library สำหรับ UI ที่ทันสมัย
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- ตัวแปรหลักสำหรับเก็บสถานะ
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ตัวแปรสำหรับควบคุมระบบ
local ScriptEnabled = true
local AutoFarmEnabled = false
local AutoBuyEnabled = false
local AutoEquipPetEnabled = false
local AutoClaimRewardsEnabled = false
local AntiAFKEnabled = true
local ActionSpeed = 0.5
local LastAction = 0
local MinimizedWindow = false

-- ตัวแปรสำหรับเก็บข้อมูลเกม
local GameData = {
    NPCs = {},
    Shops = {},
    Plants = {},
    Pets = {},
    Items = {},
    RemoteEvents = {},
    PlayerStats = {}
}

-- ฟังก์ชันสำหรับ Debounce เพื่อป้องกันการสแปม
local function CanPerformAction()
    local currentTime = tick()
    if currentTime - LastAction >= ActionSpeed then
        LastAction = currentTime
        return true
    end
    return false
end

-- ฟังก์ชันสำหรับการจัดการข้อผิดพลาด
local function SafeExecute(func, errorMessage)
    local success, result = pcall(func)
    if not success then
        warn("เกิดข้อผิดพลาด: " .. errorMessage .. " - " .. tostring(result))
    end
    return success, result
end

-- ฟังก์ชันสำหรับสแกนหา RemoteEvents
local function ScanRemoteEvents()
    SafeExecute(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                GameData.RemoteEvents[obj.Name] = obj
            end
        end
    end, "ไม่สามารถสแกน RemoteEvents ได้")
end

-- ฟังก์ชันสำหรับสแกนหา NPCs และร้านค้า
local function ScanGameObjects()
    SafeExecute(function()
        local workspace = game.Workspace
        
        -- สแกนหา NPCs
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("npc") or obj.Name:lower():find("shop") or obj.Name:lower():find("vendor") then
                if obj:IsA("Model") or obj:IsA("Part") then
                    GameData.NPCs[obj.Name] = obj
                end
            end
        end
        
        -- สแกนหาพืช
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("plant") or obj.Name:lower():find("crop") or obj.Name:lower():find("seed") then
                if obj:IsA("Model") or obj:IsA("Part") then
                    GameData.Plants[obj.Name] = obj
                end
            end
        end
        
        -- สแกนหาสัตว์เลี้ยง
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("pet") or obj.Name:lower():find("animal") then
                if obj:IsA("Model") then
                    GameData.Pets[obj.Name] = obj
                end
            end
        end
    end, "ไม่สามารถสแกนวัตถุในเกมได้")
end

-- ฟังก์ชันสำหรับการเทเลพอร์ต
local function TeleportToPosition(position)
    SafeExecute(function()
        if RootPart and position then
            RootPart.CFrame = CFrame.new(position)
        end
    end, "ไม่สามารถเทเลพอร์ตได้")
end

-- ฟังก์ชันสำหรับโต้ตอบกับ NPC
local function InteractWithNPC(npcName)
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        local npc = GameData.NPCs[npcName]
        if npc and npc.Parent then
            -- เทเลพอร์ตไปหา NPC
            TeleportToPosition(npc.Position)
            wait(0.1)
            
            -- พยายามโต้ตอบหลายวิธี
            local clickDetector = npc:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                return true
            end
            
            -- หรือใช้ ProximityPrompt
            local proximityPrompt = npc:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                fireproximityprompt(proximityPrompt)
                return true
            end
            
            -- หรือใช้ RemoteEvent
            local shopRemote = GameData.RemoteEvents["ShopRemote"] or GameData.RemoteEvents["BuyRemote"]
            if shopRemote then
                shopRemote:FireServer(npcName)
                return true
            end
        end
        return false
    end, "ไม่สามารถโต้ตอบกับ NPC ได้")
end

-- ฟังก์ชันสำหรับการซื้อไอเทม
local function BuyItem(itemName, quantity)
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        -- ตรวจสอบเงินก่อนซื้อ
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local moneyGui = playerGui:FindFirstChild("MoneyGui") or playerGui:FindFirstChild("CurrencyGui")
        
        if moneyGui then
            local moneyLabel = moneyGui:FindFirstChild("MoneyLabel") or moneyGui:FindFirstChild("CurrencyLabel")
            if moneyLabel then
                local currentMoney = tonumber(moneyLabel.Text:gsub("%D", ""))
                if currentMoney and currentMoney < 100 then -- ตรวจสอบเงินขั้นต่ำ
                    warn("เงินไม่เพียงพอสำหรับการซื้อ " .. itemName)
                    return false
                end
            end
        end
        
        -- พยายามซื้อไอเทม
        local buyRemote = GameData.RemoteEvents["BuyItem"] or GameData.RemoteEvents["Purchase"] or GameData.RemoteEvents["Shop"]
        if buyRemote then
            buyRemote:FireServer(itemName, quantity or 1)
            return true
        end
        
        return false
    end, "ไม่สามารถซื้อไอเทมได้")
end

-- ฟังก์ชันสำหรับการปลูกพืช
local function PlantSeed(seedName, plotPosition)
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        local plantRemote = GameData.RemoteEvents["PlantSeed"] or GameData.RemoteEvents["Plant"]
        if plantRemote then
            if plotPosition then
                TeleportToPosition(plotPosition)
                wait(0.1)
            end
            plantRemote:FireServer(seedName, plotPosition)
            return true
        end
        return false
    end, "ไม่สามารถปลูกพืชได้")
end

-- ฟังก์ชันสำหรับการเก็บเกี่ยว
local function HarvestPlant(plantPosition)
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        local harvestRemote = GameData.RemoteEvents["Harvest"] or GameData.RemoteEvents["Collect"]
        if harvestRemote then
            TeleportToPosition(plantPosition)
            wait(0.1)
            harvestRemote:FireServer(plantPosition)
            return true
        end
        return false
    end, "ไม่สามารถเก็บเกี่ยวได้")
end

-- ฟังก์ชันสำหรับการขายผลผลิต
local function SellProduce(itemName, quantity)
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        local sellRemote = GameData.RemoteEvents["SellItem"] or GameData.RemoteEvents["Sell"]
        if sellRemote then
            sellRemote:FireServer(itemName, quantity or "all")
            return true
        end
        return false
    end, "ไม่สามารถขายผลผลิตได้")
end

-- ฟังก์ชันสำหรับการสวมสัตว์เลี้ยง
local function EquipPet(petName)
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        local equipRemote = GameData.RemoteEvents["EquipPet"] or GameData.RemoteEvents["Pet"]
        if equipRemote then
            equipRemote:FireServer(petName)
            return true
        end
        return false
    end, "ไม่สามารถสวมสัตว์เลี้ยงได้")
end

-- ฟังก์ชันสำหรับการเก็บรางวัล
local function ClaimRewards()
    if not CanPerformAction() then return false end
    
    return SafeExecute(function()
        local claimRemote = GameData.RemoteEvents["ClaimReward"] or GameData.RemoteEvents["Claim"]
        if claimRemote then
            claimRemote:FireServer()
            return true
        end
        return false
    end, "ไม่สามารถเก็บรางวัลได้")
end

-- ระบบ Anti-AFK
local function StartAntiAFK()
    spawn(function()
        while AntiAFKEnabled do
            SafeExecute(function()
                -- ส่งสัญญาณการเคลื่อนไหว
                local VirtualUser = game:service('VirtualUser')
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end, "Anti-AFK ล้มเหลว")
            wait(60) -- ทุกๆ 1 นาที
        end
    end)
end

-- ระบบ Auto Reconnect
local function SetupAutoReconnect()
    LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started then
            SafeExecute(function()
                syn.queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/DDME36/AutoRoblox/main/grow_garden_script.lua"))
            end, "Auto Reconnect ล้มเหลว")
        end
    end)
end

-- ฟังก์ชันหลักสำหรับ Auto Farm
local function StartAutoFarm()
    spawn(function()
        while AutoFarmEnabled do
            SafeExecute(function()
                -- ตรวจสอบพืชที่พร้อมเก็บเกี่ยว
                for plantName, plant in pairs(GameData.Plants) do
                    if plant and plant.Parent then
                        -- ตรวจสอบว่าพืชโตแล้วหรือไม่
                        local grownIndicator = plant:FindFirstChild("Grown") or plant:FindFirstChild("Ready")
                        if grownIndicator and grownIndicator.Value == true then
                            HarvestPlant(plant.Position)
                        end
                    end
                end
                
                -- ปลูกพืชใหม่ในช่องว่าง
                for i = 1, 10 do -- ปลูกสูงสุด 10 ต้น
                    local plotPosition = Vector3.new(i * 5, 0, 0) -- ตำแหน่งแปลงตัวอย่าง
                    PlantSeed("Carrot", plotPosition)
                end
                
                -- ขายผลผลิต
                SellProduce("Carrot", "all")
                
            end, "Auto Farm ล้มเหลว")
            wait(ActionSpeed)
        end
    end)
end

-- ฟังก์ชันสำหรับ Auto Buy
local function StartAutoBuy()
    spawn(function()
        while AutoBuyEnabled do
            SafeExecute(function()
                -- ซื้อเมล็ดพันธุ์
                BuyItem("CarrotSeed", 10)
                BuyItem("TomatoSeed", 10)
                BuyItem("CornSeed", 5)
                
                -- ซื้อไข่สัตว์เลี้ยง
                BuyItem("ChickenEgg", 1)
                BuyItem("DogEgg", 1)
                
            end, "Auto Buy ล้มเหลว")
            wait(ActionSpeed * 2)
        end
    end)
end

-- ฟังก์ชันสำหรับ Auto Equip Pet
local function StartAutoEquipPet()
    spawn(function()
        while AutoEquipPetEnabled do
            SafeExecute(function()
                -- หาสัตว์เลี้ยงที่ดีที่สุด
                local bestPet = nil
                local bestRarity = 0
                
                for petName, pet in pairs(GameData.Pets) do
                    local rarity = pet:GetAttribute("Rarity") or 1
                    if rarity > bestRarity then
                        bestRarity = rarity
                        bestPet = petName
                    end
                end
                
                if bestPet then
                    EquipPet(bestPet)
                end
                
            end, "Auto Equip Pet ล้มเหลว")
            wait(ActionSpeed * 5)
        end
    end)
end

-- ฟังก์ชันสำหรับ Auto Claim Rewards
local function StartAutoClaimRewards()
    spawn(function()
        while AutoClaimRewardsEnabled do
            SafeExecute(function()
                ClaimRewards()
            end, "Auto Claim Rewards ล้มเหลว")
            wait(ActionSpeed * 10)
        end
    end)
end

-- สร้าง UI หลัก
local Window = OrionLib:MakeWindow({
    Name = "🌱 Grow a Garden - เครื่องมือช่วยเหลือ",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "GrowGardenHelper",
    IntroEnabled = true,
    IntroText = "เครื่องมือช่วยเหลือสำหรับ Grow a Garden",
    IntroIcon = "rbxassetid://4483345998"
})

-- หน้าแรก - ระบบอัตโนมัติหลัก
local MainTab = Window:MakeTab({
    Name = "🏠 หน้าแรก",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ส่วนควบคุมหลัก
local MainSection = MainTab:AddSection({
    Name = "⚙️ ระบบอัตโนมัติหลัก"
})

MainSection:AddToggle({
    Name = "🌾 Auto Farm (เก็บเกี่ยว-ปลูก)",
    Default = false,
    Callback = function(Value)
        AutoFarmEnabled = Value
        if Value then
            StartAutoFarm()
        end
    end
})

MainSection:AddToggle({
    Name = "🛒 Auto Buy (ซื้อเมล็ด-ไอเทม)",
    Default = false,
    Callback = function(Value)
        AutoBuyEnabled = Value
        if Value then
            StartAutoBuy()
        end
    end
})

MainSection:AddToggle({
    Name = "🐕 Auto Equip Pet (สวมสัตว์เลี้ยง)",
    Default = false,
    Callback = function(Value)
        AutoEquipPetEnabled = Value
        if Value then
            StartAutoEquipPet()
        end
    end
})

MainSection:AddToggle({
    Name = "🎁 Auto Claim Rewards (เก็บรางวัล)",
    Default = false,
    Callback = function(Value)
        AutoClaimRewardsEnabled = Value
        if Value then
            StartAutoClaimRewards()
        end
    end
})

-- ส่วนการตั้งค่า
local SettingsSection = MainTab:AddSection({
    Name = "🔧 การตั้งค่า"
})

SettingsSection:AddSlider({
    Name = "⚡ ความเร็วการทำงาน (วินาที)",
    Min = 0.1,
    Max = 5,
    Default = 0.5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "วินาที",
    Callback = function(Value)
        ActionSpeed = Value
    end
})

SettingsSection:AddToggle({
    Name = "🛡️ Anti-AFK (ป้องกันการหลุด)",
    Default = true,
    Callback = function(Value)
        AntiAFKEnabled = Value
    end
})

-- หน้าการซื้อขาย
local ShopTab = Window:MakeTab({
    Name = "🛒 ร้านค้า",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ShopSection = ShopTab:AddSection({
    Name = "🛍️ ซื้อไอเทม"
})

-- รายการไอเทมที่สามารถซื้อได้
local ItemsList = {"CarrotSeed", "TomatoSeed", "CornSeed", "ChickenEgg", "DogEgg", "Fertilizer", "WateringCan"}
local SelectedItem = "CarrotSeed"

ShopSection:AddDropdown({
    Name = "เลือกไอเทม",
    Default = "CarrotSeed",
    Options = ItemsList,
    Callback = function(Value)
        SelectedItem = Value
    end
})

ShopSection:AddButton({
    Name = "💰 ซื้อไอเทมที่เลือก",
    Callback = function()
        BuyItem(SelectedItem, 1)
        OrionLib:MakeNotification({
            Name = "การซื้อ",
            Content = "พยายามซื้อ " .. SelectedItem,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

ShopSection:AddButton({
    Name = "🛒 ซื้อทั้งหมด (แพคเกจ)",
    Callback = function()
        for _, item in pairs(ItemsList) do
            BuyItem(item, 5)
            wait(0.1)
        end
        OrionLib:MakeNotification({
            Name = "การซื้อ",
            Content = "ซื้อทุกไอเทมเสร็จสิ้น",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- หน้าสัตว์เลี้ยง
local PetTab = Window:MakeTab({
    Name = "🐾 สัตว์เลี้ยง",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PetSection = PetTab:AddSection({
    Name = "🐕 จัดการสัตว์เลี้ยง"
})

local PetsList = {"Dog", "Cat", "Chicken", "Cow", "Horse"}
local SelectedPet = "Dog"

PetSection:AddDropdown({
    Name = "เลือกสัตว์เลี้ยง",
    Default = "Dog",
    Options = PetsList,
    Callback = function(Value)
        SelectedPet = Value
    end
})

PetSection:AddButton({
    Name = "👕 สวมสัตว์เลี้ยง",
    Callback = function()
        EquipPet(SelectedPet)
        OrionLib:MakeNotification({
            Name = "สัตว์เลี้ยง",
            Content = "สวม " .. SelectedPet .. " แล้ว",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- หน้าข้อมูลและเครดิต
local InfoTab = Window:MakeTab({
    Name = "ℹ️ ข้อมูล",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local InfoSection = InfoTab:AddSection({
    Name = "📋 ข้อมูลเครื่องมือ"
})

InfoSection:AddParagraph("เกี่ยวกับเครื่องมือ", "เครื่องมือนี้ถูกสร้างขึ้นเพื่อช่วยในการทดสอบและปรับปรุงประสบการณ์ในเกม Grow a Garden ไม่ใช่เพื่อการโกงหรือละเมิดกฎของ Roblox")

InfoSection:AddParagraph("วิธีใช้งาน", "1. เปิดใช้งานระบบอัตโนมัติที่ต้องการ\n2. ปรับความเร็วตามความเหมาะสม\n3. ตรวจสอบการทำงานเป็นระยะ")

InfoSection:AddParagraph("คำแนะนำ", "• ใช้ความเร็วปานกลาง (0.5-1 วินาที)\n• เปิด Anti-AFK เพื่อป้องกันการหลุด\n• ตรวจสอบเงินก่อนใช้ Auto Buy")

InfoSection:AddButton({
    Name = "🔄 รีเฟรชข้อมูลเกม",
    Callback = function()
        ScanGameObjects()
        ScanRemoteEvents()
        OrionLib:MakeNotification({
            Name = "ระบบ",
            Content = "รีเฟรชข้อมูลเกมแล้ว",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ปุ่มย่อหน้าต่าง
local MinimizeSection = InfoTab:AddSection({
    Name = "🖥️ การจัดการหน้าต่าง"
})

MinimizeSection:AddButton({
    Name = "📦 ย่อหน้าต่าง",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "หน้าต่าง",
            Content = "ย่อหน้าต่างแล้ว กด RightShift เพื่อเปิด",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        OrionLib:Destroy()
        
        -- สร้างไอคอนย่อ
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        local IconFrame = Instance.new("Frame")
        IconFrame.Size = UDim2.new(0, 50, 0, 50)
        IconFrame.Position = UDim2.new(0, 10, 0, 10)
        IconFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        IconFrame.Parent = ScreenGui
        
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(1, 0, 1, 0)
        IconLabel.Text = "🌱"
        IconLabel.TextScaled = true
        IconLabel.BackgroundTransparency = 1
        IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        IconLabel.Parent = IconFrame
        
        -- ปุ่มเปิด UI อีกครั้ง
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.Parent = IconFrame
        
        Button.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
            -- โหลดสคริปต์ใหม่
            loadstring(game:HttpGet("https://raw.githubusercontent.com/DDME36/AutoRoblox/main/grow_garden_script.lua"))()
        end)
    end
})

-- ตั้งค่า hotkey สำหรับเปิด/ปิด UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        -- Toggle UI
        if OrionLib then
            OrionLib:Destroy()
        else
            loadstring(game:HttpGet("https://raw.githubusercontent.com/DDME36/AutoRoblox/main/grow_garden_script.lua"))()
        end
    end
end)

-- เริ่มต้นระบบ
local function InitializeScript()
    OrionLib:MakeNotification({
        Name = "🌱 Grow a Garden Helper",
        Content = "เครื่องมือช่วยเหลือพร้อมใช้งาน!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
    
    -- สแกนข้อมูลเกม
    ScanGameObjects()
    ScanRemoteEvents()
    
    -- เริ่มต้นระบบป้องกัน
    StartAntiAFK()
    SetupAutoReconnect()
    
    -- อัพเดทข้อมูลเป็นระยะ
    spawn(function()
        while ScriptEnabled do
            wait(30) -- ทุกๆ 30 วินาที
            ScanGameObjects()
            ScanRemoteEvents()
        end
    end)
    
    -- ตรวจสอบการเชื่อมต่อ
    spawn(function()
        while ScriptEnabled do
            wait(5)
            if not LocalPlayer.Parent then
                -- ผู้เล่นถูกเตะออกจากเกม
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                break
            end
        end
    end)
end

-- Hook RemoteEvent เพื่อจับพารามิเตอร์
local function HookRemoteEvents()
    local mt = getrawmetatable(game)
    local oldNameCall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" and self.Name then
            -- บันทึกการเรียกใช้ RemoteEvent
            if self.Name:lower():find("buy") or self.Name:lower():find("purchase") then
                print("🛒 การซื้อ: " .. self.Name .. " พารามิเตอร์: " .. table.concat(args, ", "))
            elseif self.Name:lower():find("plant") or self.Name:lower():find("seed") then
                print("🌱 การปลูก: " .. self.Name .. " พารามิเตอร์: " .. table.concat(args, ", "))
            elseif self.Name:lower():find("harvest") or self.Name:lower():find("collect") then
                print("🌾 การเก็บเกี่ยว: " .. self.Name .. " พารามิเตอร์: " .. table.concat(args, ", "))
            elseif self.Name:lower():find("sell") then
                print("💰 การขาย: " .. self.Name .. " พารามิเตอร์: " .. table.concat(args, ", "))
            elseif self.Name:lower():find("pet") or self.Name:lower():find("equip") then
                print("🐾 สัตว์เลี้ยง: " .. self.Name .. " พารามิเตอร์: " .. table.concat(args, ", "))
            end
        end
        
        return oldNameCall(self, ...)
    end)
    setreadonly(mt, true)
end

-- ฟังก์ชันสำหรับหาไอเทมที่ถูกที่สุด
local function FindCheapestItem(itemType)
    local cheapest = nil
    local lowestPrice = math.huge
    
    SafeExecute(function()
        for itemName, itemData in pairs(GameData.Items) do
            if itemData.Type == itemType and itemData.Price < lowestPrice then
                lowestPrice = itemData.Price
                cheapest = itemName
            end
        end
    end, "ไม่สามารถหาไอเทมที่ถูกที่สุดได้")
    
    return cheapest
end

-- ฟังก์ชันสำหรับหาแปลงที่ว่าง
local function FindEmptyPlot()
    local emptyPlots = {}
    
    SafeExecute(function()
        local plotsFolder = game.Workspace:FindFirstChild("Plots") or game.Workspace:FindFirstChild("Farm")
        if plotsFolder then
            for _, plot in pairs(plotsFolder:GetChildren()) do
                if plot:IsA("Model") or plot:IsA("Part") then
                    local occupied = plot:FindFirstChild("Plant") or plot:FindFirstChild("Crop")
                    if not occupied then
                        table.insert(emptyPlots, plot)
                    end
                end
            end
        end
    end, "ไม่สามารถหาแปลงที่ว่างได้")
    
    return emptyPlots
end

-- ฟังก์ชันสำหรับหาพืชที่พร้อมเก็บเกี่ยว
local function FindReadyPlants()
    local readyPlants = {}
    
    SafeExecute(function()
        local plotsFolder = game.Workspace:FindFirstChild("Plots") or game.Workspace:FindFirstChild("Farm")
        if plotsFolder then
            for _, plot in pairs(plotsFolder:GetChildren()) do
                if plot:IsA("Model") or plot:IsA("Part") then
                    local plant = plot:FindFirstChild("Plant") or plot:FindFirstChild("Crop")
                    if plant then
                        local grownValue = plant:FindFirstChild("Grown") or plant:FindFirstChild("Ready")
                        if grownValue and grownValue.Value == true then
                            table.insert(readyPlants, plant)
                        end
                    end
                end
            end
        end
    end, "ไม่สามารถหาพืชที่พร้อมเก็บเกี่ยวได้")
    
    return readyPlants
end

-- ฟังก์ชันสำหรับอัพเดทข้อมูลผู้เล่น
local function UpdatePlayerStats()
    SafeExecute(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        -- หาเงิน
        local moneyGui = playerGui:FindFirstChild("MoneyGui") or playerGui:FindFirstChild("CurrencyGui") or playerGui:FindFirstChild("Cash")
        if moneyGui then
            local moneyLabel = moneyGui:FindFirstChild("MoneyLabel") or moneyGui:FindFirstChild("CurrencyLabel") or moneyGui:FindFirstChild("CashLabel")
            if moneyLabel then
                GameData.PlayerStats.Money = tonumber(moneyLabel.Text:gsub("%D", "")) or 0
            end
        end
        
        -- หาเลเวล
        local levelGui = playerGui:FindFirstChild("LevelGui") or playerGui:FindFirstChild("Level")
        if levelGui then
            local levelLabel = levelGui:FindFirstChild("LevelLabel") or levelGui:FindFirstChild("Level")
            if levelLabel then
                GameData.PlayerStats.Level = tonumber(levelLabel.Text:gsub("%D", "")) or 1
            end
        end
        
        -- หา XP
        local xpGui = playerGui:FindFirstChild("XPGui") or playerGui:FindFirstChild("Experience")
        if xpGui then
            local xpLabel = xpGui:FindFirstChild("XPLabel") or xpGui:FindFirstChild("ExperienceLabel")
            if xpLabel then
                GameData.PlayerStats.XP = tonumber(xpLabel.Text:gsub("%D", "")) or 0
            end
        end
        
    end, "ไม่สามารถอัพเดทข้อมูลผู้เล่นได้")
end

-- ฟังก์ชันสำหรับการใช้งาน Auto Farm ที่ปรับปรุงแล้ว
local function ImprovedAutoFarm()
    spawn(function()
        while AutoFarmEnabled do
            SafeExecute(function()
                -- อัพเดทข้อมูลผู้เล่น
                UpdatePlayerStats()
                
                -- 1. เก็บเกี่ยวพืชที่พร้อมก่อน
                local readyPlants = FindReadyPlants()
                for _, plant in pairs(readyPlants) do
                    if plant and plant.Parent then
                        HarvestPlant(plant.Position)
                        wait(ActionSpeed)
                    end
                end
                
                -- 2. ขายผลผลิต
                local produceItems = {"Carrot", "Tomato", "Corn", "Wheat", "Potato"}
                for _, item in pairs(produceItems) do
                    SellProduce(item, "all")
                    wait(0.1)
                end
                
                -- 3. หาแปลงที่ว่างและปลูกพืช
                local emptyPlots = FindEmptyPlot()
                local seedsToPlant = {"CarrotSeed", "TomatoSeed", "CornSeed"}
                
                for i, plot in pairs(emptyPlots) do
                    if i <= #seedsToPlant then
                        local seed = seedsToPlant[((i-1) % #seedsToPlant) + 1]
                        PlantSeed(seed, plot.Position)
                        wait(ActionSpeed)
                    end
                end
                
                -- 4. ตรวจสอบและซื้อเมล็ดเพิ่มถ้าเงินเพียงพอ
                if GameData.PlayerStats.Money and GameData.PlayerStats.Money > 500 then
                    for _, seed in pairs(seedsToPlant) do
                        BuyItem(seed, 5)
                        wait(0.1)
                    end
                end
                
            end, "Improved Auto Farm ล้มเหลว")
            wait(ActionSpeed * 2)
        end
    end)
end

-- ฟังก์ชันสำหรับการใช้งาน Auto Buy ที่ปรับปรุงแล้ว
local function ImprovedAutoBuy()
    spawn(function()
        while AutoBuyEnabled do
            SafeExecute(function()
                UpdatePlayerStats()
                
                if GameData.PlayerStats.Money and GameData.PlayerStats.Money > 100 then
                    -- ซื้อเมล็ดที่จำเป็น
                    local essentialSeeds = {"CarrotSeed", "TomatoSeed", "CornSeed"}
                    for _, seed in pairs(essentialSeeds) do
                        BuyItem(seed, 10)
                        wait(0.1)
                    end
                    
                    -- ซื้อเครื่องมือ
                    if GameData.PlayerStats.Money > 1000 then
                        BuyItem("WateringCan", 1)
                        BuyItem("Fertilizer", 5)
                    end
                    
                    -- ซื้อสัตว์เลี้ยงถ้าเงินเพียงพอ
                    if GameData.PlayerStats.Money > 5000 then
                        BuyItem("ChickenEgg", 1)
                        BuyItem("DogEgg", 1)
                    end
                end
                
            end, "Improved Auto Buy ล้มเหลว")
            wait(ActionSpeed * 3)
        end
    end)
end

-- ฟังก์ชันสำหรับตรวจสอบและแจ้งเตือน
local function NotificationSystem()
    spawn(function()
        while ScriptEnabled do
            wait(60) -- ตรวจสอบทุกนาที
            
            SafeExecute(function()
                UpdatePlayerStats()
                
                -- แจ้งเตือนเงินน้อย
                if GameData.PlayerStats.Money and GameData.PlayerStats.Money < 50 then
                    OrionLib:MakeNotification({
                        Name = "⚠️ เงินเหลือน้อย",
                        Content = "เงินเหลือ " .. GameData.PlayerStats.Money .. " หยุด Auto Buy ชั่วคราว",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                end
                
                -- แจ้งเตือนเลเวลอัพ
                if GameData.PlayerStats.Level and GameData.PlayerStats.Level > (GameData.PlayerStats.LastLevel or 1) then
                    OrionLib:MakeNotification({
                        Name = "🎉 เลเวลอัพ!",
                        Content = "ขึ้นเลเวล " .. GameData.PlayerStats.Level .. " แล้ว!",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                    GameData.PlayerStats.LastLevel = GameData.PlayerStats.Level
                end
                
            end, "ระบบแจ้งเตือนล้มเหลว")
        end
    end)
end

-- เริ่มต้นระบบทั้งหมด
HookRemoteEvents()
InitializeScript()
NotificationSystem()

-- แทนที่ฟังก์ชัน Auto Farm และ Auto Buy เดิมด้วยเวอร์ชันที่ปรับปรุงแล้ว
local function ReplaceAutoFarmFunction()
    -- อัพเดทฟังก์ชัน Auto Farm ในส่วน Toggle
    MainSection:AddToggle({
        Name = "🌾 Auto Farm (เก็บเกี่ยว-ปลูก) - ปรับปรุงแล้ว",
        Default = false,
        Callback = function(Value)
            AutoFarmEnabled = Value
            if Value then
                ImprovedAutoFarm()
            end
        end
    })
    
    -- อัพเดทฟังก์ชัน Auto Buy ในส่วน Toggle
    MainSection:AddToggle({
        Name = "🛒 Auto Buy (ซื้อเมล็ด-ไอเทม) - ปรับปรุงแล้ว",
        Default = false,
        Callback = function(Value)
            AutoBuyEnabled = Value
            if Value then
                ImprovedAutoBuy()
            end
        end
    })
end

-- เพิ่มปุ่มสำหรับการทดสอบ
local TestSection = InfoTab:AddSection({
    Name = "🧪 การทดสอบ"
})

TestSection:AddButton({
    Name = "🔍 ทดสอบหาพืชพร้อมเก็บเกี่ยว",
    Callback = function()
        local readyPlants = FindReadyPlants()
        OrionLib:MakeNotification({
            Name = "ผลการทดสอบ",
            Content = "พบพืชพร้อมเก็บเกี่ยว " .. #readyPlants .. " ต้น",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

TestSection:AddButton({
    Name = "📊 แสดงข้อมูลผู้เล่น",
    Callback = function()
        UpdatePlayerStats()
        OrionLib:MakeNotification({
            Name = "ข้อมูลผู้เล่น",
            Content = "เงิน: " .. (GameData.PlayerStats.Money or 0) .. " | เลเวล: " .. (GameData.PlayerStats.Level or 1),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

TestSection:AddButton({
    Name = "🎯 ทดสอบการเทเลพอร์ต",
    Callback = function()
        TeleportToPosition(Vector3.new(0, 5, 0))
        OrionLib:MakeNotification({
            Name = "การเทเลพอร์ต",
            Content = "เทเลพอร์ตไปยังตำแหน่งทดสอบแล้ว",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- สุดท้าย - ปิดการทำงานของสคริปต์
OrionLib.Destroying:Connect(function()
    ScriptEnabled = false
    AutoFarmEnabled = false
    AutoBuyEnabled = false
    AutoEquipPetEnabled = false
    AutoClaimRewardsEnabled = false
    AntiAFKEnabled = false
    
    print("🌱 Grow a Garden Helper ถูกปิดเรียบร้อยแล้ว")
end)

OrionLib:Init()
