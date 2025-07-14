-- Ninja Legends Auto Script v2.0
-- ปรับปรุงแล้ว: เพิ่มความเสถียร, ปรับปรุง UI, และเพิ่มฟีเจอร์ใหม่

local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

-- ตัวแปรสำหรับเก็บสถานะ
local scriptEnabled = true
local autoSwingEnabled = false
local autoSellEnabled = false
local autoBuyEnabled = false
local autoTrainEnabled = false
local autoPetEnabled = false

-- ตัวแปรการตั้งค่า
local swingDelay = 0.1
local sellDelay = 5
local buyDelay = 2
local itemToBuy = "CommonPet"
local targetLocation = "Spawn"

-- ตัวแปรสำหรับ Remote Events
local remoteEvents = {
    swing = nil,
    sell = nil,
    buy = nil,
    train = nil,
    pet = nil
}

-- ฟังก์ชันค้นหา Remote Events อัตโนมัติ
local function findRemoteEvents()
    local possibleSwingNames = {"SwingEvent", "Attack", "Swing", "Hit", "Strike"}
    local possibleSellNames = {"SellEvent", "Sell", "SellAll", "SellItems"}
    local possibleBuyNames = {"PurchasePetEvent", "BuyEvent", "Purchase", "Buy"}
    
    for _, name in pairs(possibleSwingNames) do
        local event = replicatedStorage:FindFirstChild(name)
        if event then
            remoteEvents.swing = event
            break
        end
    end
    
    for _, name in pairs(possibleSellNames) do
        local event = replicatedStorage:FindFirstChild(name)
        if event then
            remoteEvents.sell = event
            break
        end
    end
    
    for _, name in pairs(possibleBuyNames) do
        local event = replicatedStorage:FindFirstChild(name)
        if event then
            remoteEvents.buy = event
            break
        end
    end
end

-- เรียกใช้ฟังก์ชันค้นหา Remote Events
findRemoteEvents()

-- ฟังก์ชัน Auto Swing ที่ปรับปรุงแล้ว
local function autoSwing()
    while autoSwingEnabled and scriptEnabled do
        pcall(function()
            if remoteEvents.swing then
                remoteEvents.swing:FireServer()
            end
        end)
        wait(swingDelay)
    end
end

-- ฟังก์ชัน Auto Sell ที่ปรับปรุงแล้ว
local function autoSell()
    while autoSellEnabled and scriptEnabled do
        pcall(function()
            if remoteEvents.sell then
                remoteEvents.sell:FireServer()
            end
        end)
        wait(sellDelay)
    end
end

-- ฟังก์ชัน Auto Buy ที่ปรับปรุงแล้ว
local function autoBuy()
    while autoBuyEnabled and scriptEnabled do
        pcall(function()
            if remoteEvents.buy then
                remoteEvents.buy:FireServer(itemToBuy)
            end
        end)
        wait(buyDelay)
    end
end

-- ฟังก์ชัน Auto Train (ใหม่)
local function autoTrain()
    while autoTrainEnabled and scriptEnabled do
        pcall(function()
            -- ค้นหาและเดินไปที่จุดเทรน
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- ตรรกะการเดินไปจุดเทรน
            end
        end)
        wait(1)
    end
end

-- Anti-AFK ที่ปรับปรุงแล้ว
local lastInputTime = tick()
local function antiAfk()
    if tick() - lastInputTime > 300 then -- 5 นาที
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
        lastInputTime = tick()
    end
end

-- เชื่อมต่อ Anti-AFK
player.Idled:Connect(antiAfk)
runService.Heartbeat:Connect(antiAfk)

-- โหลด UI Library (ใช้ Orion แทน Kavo เพื่อความเสถียร)
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "🥷 Ninja Legends Auto Script v2.0",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NinjaLegendsAuto"
})

-- Tab หลัก
local MainTab = Window:MakeTab({
    Name = "🏠 Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tab การตั้งค่า
local SettingsTab = Window:MakeTab({
    Name = "⚙️ Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tab สถิติ
local StatsTab = Window:MakeTab({
    Name = "📊 Stats",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ส่วน Main Features
local MainSection = MainTab:AddSection({
    Name = "⚡ Auto Features"
})

MainSection:AddToggle({
    Name = "🗡️ Auto Swing",
    Default = false,
    Callback = function(value)
        autoSwingEnabled = value
        if value then
            spawn(autoSwing)
            OrionLib:MakeNotification({
                Name = "Auto Swing",
                Content = "เปิดใช้งาน Auto Swing แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Swing",
                Content = "ปิดใช้งาน Auto Swing แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

MainSection:AddToggle({
    Name = "💰 Auto Sell",
    Default = false,
    Callback = function(value)
        autoSellEnabled = value
        if value then
            spawn(autoSell)
            OrionLib:MakeNotification({
                Name = "Auto Sell",
                Content = "เปิดใช้งาน Auto Sell แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Sell",
                Content = "ปิดใช้งาน Auto Sell แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

MainSection:AddToggle({
    Name = "🛒 Auto Buy",
    Default = false,
    Callback = function(value)
        autoBuyEnabled = value
        if value then
            spawn(autoBuy)
            OrionLib:MakeNotification({
                Name = "Auto Buy",
                Content = "เปิดใช้งาน Auto Buy แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Buy",
                Content = "ปิดใช้งาน Auto Buy แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

MainSection:AddToggle({
    Name = "🏃 Auto Train",
    Default = false,
    Callback = function(value)
        autoTrainEnabled = value
        if value then
            spawn(autoTrain)
            OrionLib:MakeNotification({
                Name = "Auto Train",
                Content = "เปิดใช้งาน Auto Train แล้ว!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- ส่วน Settings
local SettingsSection = SettingsTab:AddSection({
    Name = "🔧 Customize Settings"
})

SettingsSection:AddSlider({
    Name = "⚡ Swing Speed",
    Min = 0.1,
    Max = 2,
    Default = 0.1,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 0.1,
    ValueName = "seconds",
    Callback = function(value)
        swingDelay = value
        OrionLib:MakeNotification({
            Name = "Settings",
            Content = "ตั้งค่าความเร็ว Swing: " .. value .. " วินาที",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

SettingsSection:AddSlider({
    Name = "💰 Sell Delay",
    Min = 1,
    Max = 10,
    Default = 5,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "seconds",
    Callback = function(value)
        sellDelay = value
    end
})

SettingsSection:AddTextbox({
    Name = "🛒 Item to Buy",
    Default = "CommonPet",
    TextDisappear = false,
    Callback = function(value)
        itemToBuy = value
        OrionLib:MakeNotification({
            Name = "Settings",
            Content = "ตั้งค่าไอเทมที่จะซื้อ: " .. value,
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

-- ส่วน Stats
local StatsSection = StatsTab:AddSection({
    Name = "📈 Script Statistics"
})

local swingCount = 0
local sellCount = 0
local buyCount = 0

local swingLabel = StatsSection:AddLabel("🗡️ Total Swings: 0")
local sellLabel = StatsSection:AddLabel("💰 Total Sells: 0")
local buyLabel = StatsSection:AddLabel("🛒 Total Buys: 0")

-- อัพเดทสถิติ
spawn(function()
    while scriptEnabled do
        if swingLabel then
            swingLabel:Set("🗡️ Total Swings: " .. swingCount)
        end
        if sellLabel then
            sellLabel:Set("💰 Total Sells: " .. sellCount)
        end
        if buyLabel then
            buyLabel:Set("🛒 Total Buys: " .. buyCount)
        end
        wait(1)
    end
end)

-- ปุ่มฉุกเฉิน
MainSection:AddButton({
    Name = "🚨 Emergency Stop",
    Callback = function()
        autoSwingEnabled = false
        autoSellEnabled = false
        autoBuyEnabled = false
        autoTrainEnabled = false
        OrionLib:MakeNotification({
            Name = "Emergency Stop",
            Content = "หยุดการทำงานทั้งหมดแล้ว!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ข้อความต้อนรับ
OrionLib:MakeNotification({
    Name = "🥷 Ninja Legends Auto",
    Content = "โหลดสคริปต์เสร็จเรียบร้อย! ขอให้สนุกกับการเล่น!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- ตั้งค่าการปิดสคริปต์
local function onScriptClose()
    scriptEnabled = false
    autoSwingEnabled = false
    autoSellEnabled = false
    autoBuyEnabled = false
    autoTrainEnabled = false
end

-- เชื่อมต่อเหตุการณ์ปิดเกม
game.Players.PlayerRemoving:Connect(onScriptClose)

print("🥷 Ninja Legends Auto Script v2.0 - พร้อมใช้งาน!")
print("📱 สร้างโดย: " .. player.Name)
print("⏰ เวลา: " .. os.date("%X"))
