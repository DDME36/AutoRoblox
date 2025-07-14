-- สคริปต์ Grow a Garden Auto-Buy สำหรับ Delta Executor
-- ผู้เขียน: Grok (ปรับแต่งจาก Speed Hub X)
-- วันที่: 15 กรกฎาคม 2568

-- โหลด Rayfield Interface Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- สร้างหน้าต่าง GUI
local Window = Rayfield:CreateWindow({
    Name = "สคริปต์ Grow a Garden ออโต้",
    LoadingTitle = "กำลังโหลดสคริปต์...",
    LoadingSubtitle = "สำหรับ Delta Executor",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GrowAGarden_AutoBuy",
        FileName = "Config"
    }
})

-- ตัวแปรการตั้งค่า
_G.AutoBuyConfig = {
    AutoBuyEggs = false,
    AutoBuyTierShop = false,
    AutoBuySeeds = false,
    AutoBuyAll = false
}

-- บริการ Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lplr = Players.LocalPlayer

-- รีโมทสำหรับการซื้อ
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local BuyEggRemote = GameEvents:WaitForChild("BuyEggRemote")
local BuyTierShopRemote = GameEvents:WaitForChild("BuyTierShopRemote")
local BuySeedRemote = GameEvents:WaitForChild("BuySeedRemote")

-- รายการไอเทม
local EggList = {"Bug Egg", "Flower Egg", "Mystic Egg"} -- ปรับแต่งตามไข่ที่มีในเกม
local TierShopItems = {"Tier 1 Upgrade", "Tier 2 Upgrade", "Tier 3 Upgrade"} -- ปรับแต่งตามร้านค้าเทียร์
local SeedList = {"Basic Seed", "Rare Seed", "Epic Seed"} -- ปรับแต่งตามเมล็ดพันธุ์

-- ฟังก์ชันซื้อไข่
local function AutoBuyEggs()
    while _G.AutoBuyConfig.AutoBuyEggs do
        for _, egg in pairs(EggList) do
            pcall(function()
                BuyEggRemote:FireServer(egg)
            end)
            wait(0.5) -- ดีเลย์เพื่อป้องกันการสแปม
        end
        wait(1)
    end
end

-- ฟังก์ชันซื้อร้านค้าเทียร์
local function AutoBuyTierShop()
    while _G.AutoBuyConfig.AutoBuyTierShop do
        for _, item in pairs(TierShopItems) do
            pcall(function()
                BuyTierShopRemote:FireServer(item)
            end)
            wait(0.5)
        end
        wait(1)
    end
end

-- ฟังก์ชันซื้อเมล็ดพันธุ์
local function AutoBuySeeds()
    while _G.AutoBuyConfig.AutoBuySeeds do
        for _, seed in pairs(SeedList) do
            pcall(function()
                BuySeedRemote:FireServer(seed)
            end)
            wait(0.5)
        end
        wait(1)
    end
end

-- ฟังก์ชันซื้อทุกอย่าง
local function AutoBuyAll()
    while _G.AutoBuyConfig.AutoBuyAll do
        for _, egg in pairs(EggList) do
            pcall(function()
                BuyEggRemote:FireServer(egg)
            end)
            wait(0.5)
        end
        for _, item in pairs(TierShopItems) do
            pcall(function()
                BuyTierShopRemote:FireServer(item)
            end)
            wait(0.5)
        end
        for _, seed in pairs(SeedList) do
            pcall(function()
                BuySeedRemote:FireServer(seed)
            end)
            wait(0.5)
        end
        wait(1)
    end
end

-- แท็บหลักใน GUI
local MainTab = Window:CreateTab("เมนูหลัก", 4483362458) -- รูปไอคอน (ถ้ามี)

-- ปุ่มซื้อไข่อัตโนมัติ
MainTab:CreateToggle({
    Name = "ซื้อไข่อัตโนมัติ",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoBuyConfig.AutoBuyEggs = Value
        if Value then
            spawn(AutoBuyEggs)
        end
    end
})

-- ปุ่มซื้อร้านค้าเทียร์อัตโนมัติ
MainTab:CreateToggle({
    Name = "ซื้อร้านค้าเทียร์อัตโนมัติ",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoBuyConfig.AutoBuyTierShop = Value
        if Value then
            spawn(AutoBuyTierShop)
        end
    end
})

-- ปุ่มซื้อเมล็ดพันธุ์อัตโนมัติ
MainTab:CreateToggle({
    Name = "ซื้อเมล็ดพันธุ์อัตโนมัติ",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoBuyConfig.AutoBuySeeds = Value
        if Value then
            spawn(AutoBuySeeds)
        end
    end
})

-- ปุ่มซื้อทุกอย่างอัตโนมัติ
MainTab:CreateButton({
    Name = "ซื้อทุกอย่างอัตโนมัติ",
    Callback = function()
        _G.AutoBuyConfig.AutoBuyAll = not _G.AutoBuyConfig.AutoBuyAll
        if _G.AutoBuyConfig.AutoBuyAll then
            Rayfield:Notify({
                Title = "เริ่มซื้อทุกอย่าง",
                Content = "กำลังซื้อไข่, ร้านค้าเทียร์, และเมล็ดพันธุ์ทั้งหมด!",
                Duration = 3
            })
            spawn(AutoBuyAll)
        else
            Rayfield:Notify({
                Title = "หยุดซื้อทุกอย่าง",
                Content = "หยุดการซื้ออัตโนมัติทั้งหมดแล้ว",
                Duration = 3
            })
        end
    end
})

-- แจ้งเตือนเมื่อโหลดสคริปต์สำเร็จ
Rayfield:Notify({
    Title = "สคริปต์โหลดสำเร็จ",
    Content = "สคริปต์ Grow a Garden ออโต้พร้อมใช้งานแล้ว!",
    Duration = 5
})

-- ป้องกัน AFK
local VirtualUser = game:GetService("VirtualUser")
VirtualUser:CaptureController()
VirtualUser:SetKeyDown('0x20')
wait(0.1)
VirtualUser:SetKeyUp('0x20')

-- การตั้งค่าเพิ่มเติมเพื่อประสิทธิภาพ
_G.PerformanceMode = "Fast"
_G.RenderDistance = 50
_G.OptimizeRendering = true
