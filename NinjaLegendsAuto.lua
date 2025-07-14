local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")

-- อ้างอิง Remote Events (เปลี่ยนชื่อตาม Remote จริงในเกม)
local swingEvent = replicatedStorage:FindFirstChild("SwingEvent") -- ชื่อ Remote สำหรับตี
local sellEvent = replicatedStorage:FindFirstChild("SellEvent") -- ชื่อ Remote สำหรับขาย
local buyEvent = replicatedStorage:FindFirstChild("PurchasePetEvent") -- ชื่อ Remote สำหรับซื้อ

-- ชื่อไอเทมที่ต้องการซื้อ (แก้ไขตามต้องการ)
local itemToBuy = "CommonPet" -- ตัวอย่าง: "CommonPet", "RarePet", "LegendarySword"

-- สถานะการทำงานของแต่ละฟีเจอร์
local autoSwingEnabled = false
local autoSellEnabled = false
local autoBuyEnabled = false

-- โหลด Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Ninja Legends Auto Script", "Synapse")

-- ส่วน UI: Tab หลัก
local MainTab = Window:NewTab("Main Features")
local MainSection = MainTab:NewSection("Auto Features")

-- ฟังก์ชัน Auto Swing
local function autoSwing()
    while autoSwingEnabled do
        if swingEvent then
            swingEvent:FireServer()
            print("Swinging...")
        else
            warn("SwingEvent not found!")
            break
        end
        wait(0.1)
    end
end

-- ฟังก์ชัน Auto Sell
local function autoSell()
    while autoSellEnabled do
        if sellEvent then
            sellEvent:FireServer()
            print("Selling...")
        else
            warn("SellEvent not found!")
            break
        end
        wait(5)
    end
end

-- ฟังก์ชัน Auto Buy
local function autoBuy()
    while autoBuyEnabled do
        if buyEvent then
            buyEvent:FireServer(itemToBuy)
            print("Buying " .. itemToBuy)
        else
            warn("PurchasePetEvent not found!")
            break
        end
        wait(2)
    end
end

-- Anti-AFK
player.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
    print("Anti-AFK triggered")
end)

-- UI: ปุ่มควบคุม
MainSection:NewToggle("Auto Swing", "Toggle Auto Swing", function(state)
    autoSwingEnabled = state
    if state then
        spawn(autoSwing)
        Library:Notify("Auto Swing Enabled")
    else
        Library:Notify("Auto Swing Disabled")
    end
end)

MainSection:NewToggle("Auto Sell", "Toggle Auto Sell", function(state)
    autoSellEnabled = state
    if state then
        spawn(autoSell)
        Library:Notify("Auto Sell Enabled")
    else
        Library:Notify("Auto Sell Disabled")
    end
end)

MainSection:NewToggle("Auto Buy", "Toggle Auto Buy (" .. itemToBuy .. ")", function(state)
    autoBuyEnabled = state
    if state then
        spawn(autoBuy)
        Library:Notify("Auto Buy Enabled")
    else
        Library:Notify("Auto Buy Disabled")
    end
end)

-- UI: ส่วนตั้งค่า
local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("Customize")

SettingsSection:NewTextBox("Item to Buy", "Enter item name to buy", function(txt)
    itemToBuy = txt
    Library:Notify("Item to buy set to: " .. itemToBuy)
end)

-- แจ้งว่าเริ่มรันสคริปต์
Library:Notify("Ninja Legends Auto Script Loaded!", 5)
print("Ninja Legends Auto Script by YourName")