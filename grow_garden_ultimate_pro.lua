-- GrowGarden Automation Script
-- โดย: YourName (แทนที่ด้วยชื่อคุณ)
-- เวอร์ชัน: 1.0

-- ประกาศตัวแปรหลัก
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- สร้าง UI หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowGardenAuto"
ScreenGui.Parent = CoreGui

-- ฟังก์ชันสร้างเฟรม UI
local function CreateFrame(name, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = transparency
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    return frame
end

-- สร้าง UI หลัก
local MainFrame = CreateFrame(
    "MainFrame",
    UDim2.new(0.3, 0, 0.6, 0),
    UDim2.new(0.35, 0, 0.2, 0),
    Color3.fromRGB(40, 180, 70),
    0.1
)
MainFrame.Parent = ScreenGui

-- สร้างส่วนหัว
local Header = CreateFrame(
    "Header",
    UDim2.new(1, 0, 0.15, 0),
    UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(25, 140, 50),
    0.3
)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "GROWGARDEN AUTOMATION"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Parent = Header

-- สร้างปุ่ม Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Text = "▶ START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Size = UDim2.new(0.2, 0, 0.15, 0)
ToggleButton.Position = UDim2.new(0.78, 0, 0.02, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 90)
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

-- ระบบ Anti-AFK
local function AntiAFK()
    coroutine.wrap(function()
        while true do
            wait(30)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            print("Anti-AFK activated")
        end
    end)()
end

-- ระบบ Auto-Reconnect
local function AutoReconnect()
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            syn.queue_on_teleport([[
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/scripts/main/growgarden.lua"))()
            ]])
        end
    end)
end

-- ระบบปลูกและเก็บเกี่ยวอัตโนมัติ
local function AutoFarm()
    coroutine.wrap(function()
        while AutoFarmEnabled do
            wait(5)
            -- ตรวจจับพืชพร้อมเก็บเกี่ยว
            local harvestable = workspace.Garden.Plants:FindFirstChild("ReadyToHarvest")
            if harvestable then
                -- จำลองการคลิกเก็บเกี่ยว
                fireclickdetector(harvestable.ClickDetector)
                print("Harvested: "..harvestable.Name)
            end
            
            -- ปลูกเมล็ดใหม่
            if Player.Storage.Seeds.Value > 0 then
                local emptyPlot = workspace.Garden.Plots:FindFirstChild("EmptyPlot")
                if emptyPlot then
                    fireclickdetector(emptyPlot.ClickDetector)
                    print("Planted new seed")
                end
            end
        end
    end)()
end

-- ระบบซื้อของอัตโนมัติ
local function AutoShop()
    coroutine.wrap(function()
        while AutoShopEnabled do
            wait(60)
            
            -- ซื้อเมล็ดเมื่อเหลือน้อย
            if Player.Storage.Seeds.Value < 10 then
                local shopSeeds = workspace.Shop.Items.Seeds
                fireclickdetector(shopSeeds.ClickDetector)
                print("Bought seeds")
            end
            
            -- ซื้อไข่เมื่อเหลือน้อย
            if Player.Storage.Eggs.Value < 5 then
                local shopEggs = workspace.Shop.Items.Eggs
                fireclickdetector(shopEggs.ClickDetector)
                print("Bought eggs")
            end
        end
    end)()
end

-- ระบบขายอัตโนมัติ
local function AutoSell()
    coroutine.wrap(function()
        while AutoSellEnabled do
            wait(120)
            
            -- ขายสินค้าเมื่อเก็บครบ
            if Player.Inventory:FindFirstChild("FullStack") then
                local sellBin = workspace.SellArea.Bin
                firetouchinterest(Player.Character.HumanoidRootPart, sellBin, 0)
                wait(0.1)
                firetouchinterest(Player.Character.HumanoidRootPart, sellBin, 1)
                print("Sold items")
            end
        end
    end)()
end

-- ระบบโหลด UI
local function CreateToggle(name, yPosition)
    local toggleFrame = CreateFrame(
        name.."Toggle",
        UDim2.new(0.9, 0, 0.1, 0),
        UDim2.new(0.05, 0, yPosition, 0),
        Color3.fromRGB(50, 50, 50),
        0.7
    )
    toggleFrame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0.2, 0, 0.8, 0)
    toggleButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = toggleFrame
    
    return toggleButton
end

-- สร้าง UI สำหรับแต่ละระบบ
local FarmToggle = CreateToggle("Auto Farming", 0.2)
local ShopToggle = CreateToggle("Auto Shopping", 0.35)
local SellToggle = CreateToggle("Auto Selling", 0.5)
local EggToggle = CreateToggle("Auto Incubate", 0.65)

-- ตัวแปรสถานะ
local AutoFarmEnabled = false
local AutoShopEnabled = false
local AutoSellEnabled = false
local AutoIncubateEnabled = false
local ScriptActive = false

-- ฟังก์ชัน Toggle หลัก
ToggleButton.MouseButton1Click:Connect(function()
    ScriptActive = not ScriptActive
    
    if ScriptActive then
        ToggleButton.Text = "■ STOP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        AntiAFK()
        AutoReconnect()
    else
        ToggleButton.Text = "▶ START"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 90)
    end
end)

-- ฟังก์ชัน Toggle สำหรับแต่ละระบบ
FarmToggle.MouseButton1Click:Connect(function()
    AutoFarmEnabled = not AutoFarmEnabled
    FarmToggle.BackgroundColor3 = AutoFarmEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
    FarmToggle.Text = AutoFarmEnabled and "ON" or "OFF"
    
    if AutoFarmEnabled then
        AutoFarm()
    end
end)

ShopToggle.MouseButton1Click:Connect(function()
    AutoShopEnabled = not AutoShopEnabled
    ShopToggle.BackgroundColor3 = AutoShopEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
    ShopToggle.Text = AutoShopEnabled and "ON" or "OFF"
    
    if AutoShopEnabled then
        AutoShop()
    end
end)

SellToggle.MouseButton1Click:Connect(function()
    AutoSellEnabled = not AutoSellEnabled
    SellToggle.BackgroundColor3 = AutoSellEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
    SellToggle.Text = AutoSellEnabled and "ON" or "OFF"
    
    if AutoSellEnabled then
        AutoSell()
    end
end)

EggToggle.MouseButton1Click:Connect(function()
    AutoIncubateEnabled = not AutoIncubateEnabled
    EggToggle.BackgroundColor3 = AutoIncubateEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
    EggToggle.Text = AutoIncubateEnabled and "ON" or "OFF"
end)

-- เพิ่มเอฟเฟกต์ให้ UI
local function AddHoverEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundTransparency = 0.2}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {BackgroundTransparency = 0.4}
        ):Play()
    end)
end

-- เรียกใช้เอฟเฟกต์
AddHoverEffect(ToggleButton)
AddHoverEffect(FarmToggle)
AddHoverEffect(ShopToggle)
AddHoverEffect(SellToggle)
AddHoverEffect(EggToggle)

-- สร้างเอฟเฟกต์พื้นหลัง
local BGPattern = Instance.new("ImageLabel")
BGPattern.Name = "BGPattern"
BGPattern.Image = "rbxassetid://10111751542"  -- แทนที่ด้วย ID รูปของคุณ
BGPattern.Size = UDim2.new(1, 0, 1, 0)
BGPattern.BackgroundTransparency = 1
BGPattern.ImageTransparency = 0.9
BGPattern.Parent = MainFrame
