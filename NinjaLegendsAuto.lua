local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")

-- อ้างอิง Remote Events (ต้องเปลี่ยนตามชื่อจริงในเกม)
local swingEvent = replicatedStorage:FindFirstChild("Swing") -- ชื่อ Remote สำหรับตี
local sellEvent = replicatedStorage:FindFirstChild("Sell") -- ชื่อ Remote สำหรับขาย
local buyEvent = replicatedStorage:FindFirstChild("BuyPet") -- ชื่อ Remote สำหรับซื้อ
local collectEvent = replicatedStorage:FindFirstChild("Collect") -- ชื่อ Remote สำหรับเก็บ

-- ชื่อไอเทมที่ต้องการซื้อ
local itemToBuy = "CommonPet" -- แก้ไขตามชื่อในเกม เช่น "RarePet", "EpicSword"

-- สถานะฟีเจอร์
local autoSwingEnabled = false
local autoSellEnabled = false
local autoBuyEnabled = false
local autoCollectEnabled = false

-- โหลด Orion UI Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "Ninja Auto",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "Ninja Legends",
    IntroIcon = "rbxassetid://7733964719",
    Size = UDim2.new(0, 300, 0, 200)
})

-- Tab หลัก
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ฟังก์ชัน Auto Swing
local function autoSwing()
    while autoSwingEnabled do
        if swingEvent then
            swingEvent:FireServer()
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Swing Remote not found! Check Remote Events.",
                Time = 5
            })
            break
        end
        wait(0.05)
    end
end

-- ฟังก์ชัน Auto Sell
local function autoSell()
    while autoSellEnabled do
        if sellEvent then
            sellEvent:FireServer()
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Sell Remote not found! Check Remote Events.",
                Time = 5
            })
            break
        end
        wait(3)
    end
end

-- ฟังก์ชัน Auto Buy
local function autoBuy()
    while autoBuyEnabled do
        if buyEvent then
            buyEvent:FireServer(itemToBuy)
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Buy Remote not found! Check Remote Events.",
                Time = 5
            })
            break
        end
        wait(1)
    end
end

-- ฟังก์ชัน Auto Collect
local function autoCollect()
    while autoCollectEnabled do
        if collectEvent then
            collectEvent:FireServer()
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Collect Remote not found! Check Remote Events.",
                Time = 5
            })
            break
        end
        wait(0.5)
    end
end

-- Anti-AFK
player.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
    OrionLib:MakeNotification({
        Name = "Anti-AFK",
        Content = "Prevented AFK kick!",
        Time = 3
    })
end)

-- UI: ปุ่มควบคุม
MainTab:AddToggle({
    Name = "Auto Swing",
    Default = false,
    Callback = function(state)
        autoSwingEnabled = state
        if state พิมพ์ว่า "เปิดใช้งาน Auto Swing" else พิมพ์ว่า "ปิดใช้งาน Auto Swing" end
    end
})

MainTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(state)
        autoSellEnabled = state
        if state พิมพ์ว่า "เปิดใช้งาน Auto Sell" else พิมพ์ว่า "ปิดใช้งาน Auto Sell" end
    end
})

MainTab:AddToggle({
    Name = "Auto Buy (" .. itemToBuy .. ")",
    Default = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state พิมพ์ว่า "เปิดใช้งาน Auto Buy สำหรับ " .. itemToBuy else พิมพ์ว่า "ปิดใช้งาน Auto Buy" end
    end
})

MainTab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(state)
        autoCollectEnabled = state
        if state พิมพ์ว่า "เปิดใช้งาน Auto Collect" else พิมพ์ว่า "ปิดใช้งาน Auto Collect" end
    end
})

-- UI: ตั้งค่าไอเทม
MainTab:AddTextbox({
    Name = "Item to Buy",
    Default = itemToBuy,
    TextDisappear = true,
    Callback = function(value)
        itemToBuy = value
        พิมพ์ว่า "ตั้งค่าไอเทมที่จะซื้อเป็น: " .. itemToBuy
    end
})

-- UI: ปุ่มตรวจสอบ Remote Events
MainTab:AddButton({
    Name = "Check Remote Events",
    Callback = function()
        local remotes = ""
        for _, v in pairs(replicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                remotes = remotes .. v.Name .. "\n"
            end
        end
        OrionLib:MakeNotification({
            Name = "Remote Events",
            Content = remotes ~= "" and remotes or "ไม่พบ Remote!",
            Time = 10
        })
    end
})

-- แจ้งว่าเริ่มรัน
OrionLib:MakeNotification({
    Name = "Ninja Legends Auto",
    Content = "สคริปต์โหลดสำเร็จ! ใช้ toggle เพื่อควบคุม",
    Image = "rbxassetid://7733964719",
    Time = 5
})

OrionLib:Init()
