local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration (ตั้งค่า)
local Config = {
    AutoBuyEggs = false,
    AutoBuyShopItems = false,
    AutoBuySeeds = false,
    BuyAllOnce = false, -- สำหรับปุ่ม 'ซื้อทั้งหมด'
    
    -- การตั้งค่าเฉพาะรายการ (ผู้ใช้สามารถแก้ไขได้)
    PreferredEgg = "Normal Egg", -- เช่น "Normal Egg", "Rare Egg"
    PreferredShopItem = "Tier 1 Shop", -- เช่น "Tier 1 Shop", "Tier 2 Shop"
    PreferredSeed = "Carrot Seed", -- เช่น "Carrot Seed", "Tomato Seed"
    
    DelayBetweenBuys = 1, -- ดีเลย์ระหว่างการซื้อ (วินาที)
}

-- UI Elements (องค์ประกอบ UI) - จะถูกสร้างและอ้างอิงที่นี่
local UI = {
    ScreenGui = nil,
    MainWindow = nil,
    ToggleEggsBtn = nil,
    ToggleShopItemsBtn = nil,
    ToggleSeedsBtn = nil,
    BuyAllBtn = nil,
    StatusLabel = nil,
}

-- Utility Functions (ฟังก์ชันอำนวยความสะดวก)

-- ฟังก์ชันจำลองการรับเงินของผู้เล่น (คุณต้องแก้ไขส่วนนี้ให้ตรงกับเกมจริง)
local function GetPlayerMoney()
    -- ตัวอย่าง: ดึงจาก Leaderstats
    if LocalPlayer and LocalPlayer.leaderstats and LocalPlayer.leaderstats.Money then
        return LocalPlayer.leaderstats.Money.Value
    end
    return 0 -- ค่าเริ่มต้นหากหาไม่พบ
end

-- ฟังก์ชันจำลองการรับรายการสินค้าจากร้านค้า (คุณต้องแก้ไขส่วนนี้ให้ตรงกับเกมจริง)
-- โดยปกติแล้ว คุณจะต้องหา RemoteEvent ที่เกมใช้ในการโหลดรายการสินค้า
local function GetShopItems(shopName)
    -- นี่คือตัวอย่าง คุณต้องหา RemoteEvent หรือ Location ในเกมที่เก็บข้อมูลร้านค้า
    -- เช่น: ReplicatedStorage.ShopData:InvokeServer(shopName)
    print("กำลังดึงรายการสินค้าจาก: " .. shopName)
    -- คืนค่าเป็นตารางของชื่อสินค้าที่พร้อมซื้อ
    if shopName == "Egg Shop" then
        return {"Normal Egg", "Rare Egg", "Legendary Egg"}
    elseif shopName == "General Shop" then
        return {"Tier 1 Shop", "Tier 2 Shop", "Tier 3 Shop"}
    elseif shopName == "Seed Shop" then
        return {"Carrot Seed", "Tomato Seed", "Pumpkin Seed"}
    end
    return {}
end

-- ฟังก์ชันจำลองการซื้อสินค้า (คุณต้องแก้ไขส่วนนี้ให้ตรงกับเกมจริง)
-- คุณต้องหา RemoteEvent ที่เกมใช้ในการซื้อสินค้า และพารามิเตอร์ที่ถูกต้อง
local function BuyItem(itemName, itemType)
    -- ตัวอย่าง: สมมติว่ามี RemoteEvent ชื่อ "BuyItemEvent" ใน ReplicatedStorage
    local success, err = pcall(function()
        -- ReplicatedStorage.RemoteEvent.BuyItemEvent:FireServer(itemName, itemType)
        print(string.format("พยายามซื้อ: %s (ประเภท: %s)", itemName, itemType))
        UI.StatusLabel.Text = string.format("กำลังซื้อ: %s...", itemName)
    end)
    if not success then
        warn("เกิดข้อผิดพลาดในการซื้อ: " .. tostring(err))
        UI.StatusLabel.Text = "ซื้อไม่สำเร็จ!"
    end
    task.wait(Config.DelayBetweenBuys)
end

-- UI Creation (สร้าง UI)
local function CreateUI()
    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "GrowaGardenAutoBuyUI"
    UI.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    UI.MainWindow = Instance.new("Frame")
    UI.MainWindow.Size = UDim2.new(0, 300, 0, 400)
    UI.MainWindow.Position = UDim2.new(0.5, -150, 0.5, -200)
    UI.MainWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    UI.MainWindow.BorderSizePixel = 1
    UI.MainWindow.BorderColor3 = Color3.fromRGB(20, 20, 20)
    UI.MainWindow.Active = true
    UI.MainWindow.Draggable = true
    UI.MainWindow.Parent = UI.ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Title.Text = "Grow a Garden - สคริปต์อัตโนมัติ"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = UI.MainWindow

    -- Status Label
    UI.StatusLabel = Instance.new("TextLabel")
    UI.StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    UI.StatusLabel.Position = UDim2.new(0, 0, 0, 30)
    UI.StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    UI.StatusLabel.Text = "สถานะ: พร้อมใช้งาน"
    UI.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    UI.StatusLabel.Font = Enum.Font.SourceSans
    UI.StatusLabel.TextSize = 14
    UI.StatusLabel.Parent = UI.MainWindow

    -- Function Buttons
    local function CreateToggleButton(text, yPos, configKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = UI.MainWindow

        local function updateButtonText()
            btn.Text = text .. " : " .. (Config[configKey] and "เปิด" or "ปิด")
            btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 80)
        end

        btn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            updateButtonText()
            UI.StatusLabel.Text = text .. " ถูก " .. (Config[configKey] and "เปิด" or "ปิด") .. " แล้ว"
        end)
        updateButtonText()
        return btn
    end

    UI.ToggleEggsBtn = CreateToggleButton("ซื้อไข่อัตโนมัติ", 60, "AutoBuyEggs")
    UI.ToggleShopItemsBtn = CreateToggleButton("ซื้อร้านค้าอัตโนมัติ", 110, "AutoBuyShopItems")
    UI.ToggleSeedsBtn = CreateToggleButton("ซื้อเมล็ดพันธุ์อัตโนมัติ", 160, "AutoBuySeeds")

    -- Buy All Button
    UI.BuyAllBtn = Instance.new("TextButton")
    UI.BuyAllBtn.Size = UDim2.new(0.9, 0, 0, 50)
    UI.BuyAllBtn.Position = UDim2.new(0.05, 0, 0, 250)
    UI.BuyAllBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    UI.BuyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UI.BuyAllBtn.Font = Enum.Font.SourceSansBold
    UI.BuyAllBtn.TextSize = 20
    UI.BuyAllBtn.Text = "ซื้อทั้งหมด (ครั้งเดียว)"
    UI.BuyAllBtn.Parent = UI.MainWindow

    UI.BuyAllBtn.MouseButton1Click:Connect(function()
        Config.BuyAllOnce = true
        UI.StatusLabel.Text = "กำลังดำเนินการซื้อทั้งหมด..."
    end)

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 18
    CloseBtn.Text = "X"
    CloseBtn.Parent = UI.MainWindow
    CloseBtn.MouseButton1Click:Connect(function()
        UI.ScreenGui:Destroy()
    end)

    print("UI สร้างเสร็จสมบูรณ์")
end

-- Auto-Buy Logic (ตรรกะการซื้ออัตโนมัติ)

local function AutoBuyEggsLoop()
    while true do
        if Config.AutoBuyEggs or Config.BuyAllOnce then
            local playerMoney = GetPlayerMoney()
            local eggsInShop = GetShopItems("Egg Shop")
            
            if #eggsInShop > 0 then
                local eggToBuy = Config.PreferredEgg
                if not table.find(eggsInShop, eggToBuy) then
                    eggToBuy = eggsInShop[1] -- ซื้อไข่แรกที่มีหากไข่ที่ต้องการไม่มี
                end
                
                -- คุณต้องเพิ่มเงื่อนไขการตรวจสอบราคาไข่ที่นี่
                -- ตัวอย่าง: if playerMoney >= eggPrice then
                BuyItem(eggToBuy, "Egg")
                -- end
            else
                UI.StatusLabel.Text = "ไม่พบไข่ในร้านค้า"
            end
        end
        if Config.BuyAllOnce then break end -- หยุดถ้าเป็นโหมดซื้อทั้งหมดครั้งเดียว
        task.wait(Config.DelayBetweenBuys + math.random() * 0.5) -- เพิ่มความสุ่มเล็กน้อย
    end
end

local function AutoBuyShopItemsLoop()
    while true do
        if Config.AutoBuyShopItems or Config.BuyAllOnce then
            local playerMoney = GetPlayerMoney()
            local shopItems = GetShopItems("General Shop")

            if #shopItems > 0 then
                local itemToBuy = Config.PreferredShopItem
                if not table.find(shopItems, itemToBuy) then
                    itemToBuy = shopItems[1] -- ซื้อรายการแรกที่มีหากรายการที่ต้องการไม่มี
                end

                -- คุณต้องเพิ่มเงื่อนไขการตรวจสอบราคาสินค้าที่นี่
                -- ตัวอย่าง: if playerMoney >= itemPrice then
                BuyItem(itemToBuy, "ShopItem")
                -- end
            else
                UI.StatusLabel.Text = "ไม่พบสินค้าในร้านค้าทั่วไป"
            end
        end
        if Config.BuyAllOnce then break end
        task.wait(Config.DelayBetweenBuys + math.random() * 0.5)
    end
end

local function AutoBuySeedsLoop()
    while true do
        if Config.AutoBuySeeds or Config.BuyAllOnce then
            local playerMoney = GetPlayerMoney()
            local seedsInShop = GetShopItems("Seed Shop")

            if #seedsInShop > 0 then
                local seedToBuy = Config.PreferredSeed
                if not table.find(seedsInShop, seedToBuy) then
                    seedToBuy = seedsInShop[1] -- ซื้อเมล็ดพันธุ์แรกที่มีหากเมล็ดพันธุ์ที่ต้องการไม่มี
                end

                -- คุณต้องเพิ่มเงื่อนไขการตรวจสอบราคาเมล็ดพันธุ์ที่นี่
                -- ตัวอย่าง: if playerMoney >= seedPrice then
                BuyItem(seedToBuy, "Seed")
                -- end
            else
                UI.StatusLabel.Text = "ไม่พบเมล็ดพันธุ์ในร้านค้า"
            end
        end
        if Config.BuyAllOnce then break end
        task.wait(Config.DelayBetweenBuys + math.random() * 0.5)
    end
end

-- Main Execution (การทำงานหลัก)
CreateUI()

-- เริ่มต้นลูปการซื้ออัตโนมัติใน Coroutines เพื่อให้ทำงานพร้อมกันและไม่บล็อก UI
coroutine.wrap(AutoBuyEggsLoop)()
coroutine.wrap(AutoBuyShopItemsLoop)()
coroutine.wrap(AutoBuySeedsLoop)()

-- ตรวจสอบและรีเซ็ต BuyAllOnce หลังจากทุกฟังก์ชันซื้อทั้งหมดทำงานเสร็จ
RunService.Heartbeat:Connect(function()
    if Config.BuyAllOnce then
        -- ตรวจสอบว่าลูปซื้อทั้งหมดเสร็จสิ้นแล้วหรือไม่ (อาจต้องมีกลไกที่ซับซ้อนกว่านี้)
        -- สำหรับตอนนี้ เราจะถือว่าการเรียกฟังก์ชัน BuyItem() เสร็จสิ้นแล้ว
        Config.BuyAllOnce = false
        UI.StatusLabel.Text = "ซื้อทั้งหมดเสร็จสิ้น!"
    end
end)

