local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")

-- อ้างอิง Remote Events (ต้องเปลี่ยนตามชื่อจริงในเกม)
local swingEvent = replicatedStorage:FindFirstChild("Swing") -- ชื่อ Remote สำหรับตี (อาจเป็น Swing, Attack)
local sellEvent = replicatedStorage:FindFirstChild("Sell") -- ชื่อ Remote สำหรับขาย
local buyEvent = replicatedStorage:FindFirstChild("BuyPet") -- ชื่อ Remote สำหรับซื้อ (อาจเป็น PurchasePet, BuyItem)
local collectEvent = replicatedStorage:FindFirstChild("Collect") -- ชื่อ Remote สำหรับเก็บทรัพยากร

-- ชื่อไอเทมที่ต้องการซื้อ
local itemToBuy = "CommonPet" -- แก้ไขตามชื่อในเกม เช่น "RarePet", "EpicSword"

-- สถานะฟีเจอร์
local autoSwingEnabled = false
local autoSellEnabled = false
local autoBuyEnabled = false
local autoCollectEnabled = false

-- โหลด Orion UI Library (UI ย่อ สวยงาม รองรับ Delta Executor)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Ninja Legends Auto",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "Ninja Auto Script",
    IntroIcon = "rbxassetid://7733964719" -- ไอคอนนินจา
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
                Content = "Swing Remote not found!",
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
                Content = "Sell Remote not found!",
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
                Content = "Buy Remote not found!",
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
                Content = "Collect Remote not found!",
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
        if state then
            spawn(autoSwing)
            OrionLib:MakeNotification({
                Name = "Auto Swing",
                Content = "Auto Swing Enabled",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Swing",
                Content = "Auto Swing Disabled",
                Time = 3
            })
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(state)
        autoSellEnabled = state
        if state then
            spawn(autoSell)
            OrionLib:MakeNotification({
                Name = "Auto Sell",
                Content = "Auto Sell Enabled",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Sell",
                Content = "Auto Sell Disabled",
                Time = 3
            })
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Buy (" .. itemToBuy .. ")",
    Default = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state then
            spawn(autoBuy)
            OrionLib:MakeNotification({
                Name = "Auto Buy",
                Content = "Auto Buy Enabled for " .. itemToBuy,
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Buy",
                Content = "Auto Buy Disabled",
                Time = 3
            })
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(state)
        autoCollectEnabled = state
        if state then
            spawn(autoCollect)
            OrionLib:MakeNotification({
                Name = "Auto Collect",
                Content = "Auto Collect Enabled",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Collect",
                Content = "Auto Collect Disabled",
                Time = 3
            })
        end
    end
})

-- UI: ตั้งค่าไอเทม
MainTab:AddTextbox({
    Name = "Item to Buy",
    Default = itemToBuy,
    TextDisappear = true,
    Callback = function(value)
        itemToBuy = value
        OrionLib:MakeNotification({
            Name = "Settings",
            Content = "Item to buy set to: " .. itemToBuy,
            Time = 3
        })
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
            Content = remotes ~= "" and remotes or "No Remotes found!",
            Time = 10
        })
    end
})

-- แจ้งว่าเริ่มรัน
OrionLib:MakeNotification({
    Name = "Ninja Legends Auto",
    Content = "Script Loaded! Use toggles to control.",
    Image = "rbxassetid://7733964719",
    Time = 5
})

OrionLib:Init()
