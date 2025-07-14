-- Grow a Garden Auto Script by Assistant
-- รันด้วย: loadstring(game:HttpGet("URL_TO_THIS_SCRIPT"))()

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ตัวแปรสำหรับการทำงาน
local autoEgg = false
local autoShop = false
local autoSeed = false
local autoAll = false

-- ฟังก์ชันแจ้งเตือน
local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 3;
    })
end

-- สร้าง GUI หลัก
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GrowGardenScript"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- กรอบหลัก
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- มุมโค้ง
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- แถบหัวข้อ
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = headerFrame
    
    -- ชื่อสคริป
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🌱 Grow Garden Script"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = headerFrame
    
    -- ปุ่มย่อ/ขยาย
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 30, 0, 30)
    toggleButton.Position = UDim2.new(1, -40, 0, 5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "-"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = headerFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 5)
    toggleCorner.Parent = toggleButton
    
    -- พื้นที่เนื้อหา
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- ScrollingFrame สำหรับปุ่มต่างๆ
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    scrollFrame.Parent = contentFrame
    
    -- Layout สำหรับปุ่ม
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = scrollFrame
    
    -- ฟังก์ชันสร้างปุ่ม
    local function createButton(name, text, color, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, 0, 0, 40)
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.Gotham
        button.Parent = scrollFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = button
        
        -- เอฟเฟกต์เมื่อกด
        button.MouseButton1Click:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 35)})
            tween:Play()
            tween.Completed:Connect(function()
                local tween2 = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)})
                tween2:Play()
            end)
            if callback then callback() end
        end)
        
        return button
    end
    
    -- สร้างปุ่มต่างๆ
    local eggButton = createButton("EggButton", "🥚 ซื้อไข่อัตโนมัติ (ปิด)", Color3.fromRGB(100, 150, 255), function()
        autoEgg = not autoEgg
        eggButton.Text = autoEgg and "🥚 ซื้อไข่อัตโนมัติ (เปิด)" or "🥚 ซื้อไข่อัตโนมัติ (ปิด)"
        eggButton.BackgroundColor3 = autoEgg and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 150, 255)
        notify("ระบบซื้อไข่", autoEgg and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว")
    end)
    
    local shopButton = createButton("ShopButton", "🏪 ซื้อร้านค้าเทียร์อัตโนมัติ (ปิด)", Color3.fromRGB(255, 150, 100), function()
        autoShop = not autoShop
        shopButton.Text = autoShop and "🏪 ซื้อร้านค้าเทียร์อัตโนมัติ (เปิด)" or "🏪 ซื้อร้านค้าเทียร์อัตโนมัติ (ปิด)"
        shopButton.BackgroundColor3 = autoShop and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(255, 150, 100)
        notify("ระบบซื้อร้านค้า", autoShop and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว")
    end)
    
    local seedButton = createButton("SeedButton", "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ (ปิด)", Color3.fromRGB(100, 255, 150), function()
        autoSeed = not autoSeed
        seedButton.Text = autoSeed and "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ (เปิด)" or "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ (ปิด)"
        seedButton.BackgroundColor3 = autoSeed and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 255, 150)
        notify("ระบบซื้อเมล็ดพันธุ์", autoSeed and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว")
    end)
    
    -- เส้นแบ่ง
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 2)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BorderSizePixel = 0
    divider.Parent = scrollFrame
    
    local allButton = createButton("AllButton", "⚡ เปิดทุกฟังก์ชัน", Color3.fromRGB(255, 100, 255), function()
        autoAll = not autoAll
        autoEgg = autoAll
        autoShop = autoAll
        autoSeed = autoAll
        
        eggButton.Text = autoEgg and "🥚 ซื้อไข่อัตโนมัติ (เปิด)" or "🥚 ซื้อไข่อัตโนมัติ (ปิด)"
        eggButton.BackgroundColor3 = autoEgg and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 150, 255)
        
        shopButton.Text = autoShop and "🏪 ซื้อร้านค้าเทียร์อัตโนมัติ (เปิด)" or "🏪 ซื้อร้านค้าเทียร์อัตโนมัติ (ปิด)"
        shopButton.BackgroundColor3 = autoShop and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(255, 150, 100)
        
        seedButton.Text = autoSeed and "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ (เปิด)" or "🌱 ซื้อเมล็ดพันธุ์อัตโนมัติ (ปิด)"
        seedButton.BackgroundColor3 = autoSeed and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 255, 150)
        
        allButton.Text = autoAll and "⚡ ปิดทุกฟังก์ชัน" or "⚡ เปิดทุกฟังก์ชัน"
        allButton.BackgroundColor3 = autoAll and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(255, 100, 255)
        
        notify("ระบบทั้งหมด", autoAll and "เปิดใช้งานทุกฟังก์ชันแล้ว" or "ปิดใช้งานทุกฟังก์ชันแล้ว")
    end)
    
    -- ปุ่มอื่นๆ
    createButton("TeleportButton", "🚀 เทเลพอร์ตไปยังจุดต่างๆ", Color3.fromRGB(150, 100, 255), function()
        notify("เทเลพอร์ต", "ฟีเจอร์นี้ยังไม่พร้อมใช้งาน")
    end)
    
    createButton("SpeedButton", "💨 เพิ่มความเร็ว", Color3.fromRGB(255, 200, 100), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed == 16 and 50 or 16
            notify("ความเร็ว", LocalPlayer.Character.Humanoid.WalkSpeed == 50 and "เพิ่มความเร็วแล้ว" or "คืนค่าความเร็วปกติแล้ว")
        end
    end)
    
    createButton("JumpButton", "🦘 เพิ่มความสูงกระโดด", Color3.fromRGB(100, 255, 255), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = LocalPlayer.Character.Humanoid.JumpPower == 50 and 100 or 50
            notify("กระโดด", LocalPlayer.Character.Humanoid.JumpPower == 100 and "เพิ่มความสูงกระโดดแล้ว" or "คืนค่าความสูงกระโดดปกติแล้ว")
        end
    end)
    
    createButton("DestroyButton", "❌ ปิดสคริป", Color3.fromRGB(200, 50, 50), function()
        autoEgg = false
        autoShop = false
        autoSeed = false
        autoAll = false
        screenGui:Destroy()
        notify("สคริป", "ปิดสคริปแล้ว")
    end)
    
    -- ฟังก์ชันย่อ/ขยาย GUI
    local isMinimized = false
    toggleButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 400)
        local targetText = isMinimized and "+" or "-"
        
        toggleButton.Text = targetText
        
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize})
        tween:Play()
        
        contentFrame.Visible = not isMinimized
    end)
    
    -- ทำให้ GUI สามารถลากได้
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    headerFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    headerFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return screenGui
end

-- ฟังก์ชันหาวัตถุในเกม (ต้องปรับแต่งตามเกมจริง)
local function findGameObjects()
    -- นี่คือตัวอย่าง - ต้องปรับแต่งตามโครงสร้างของเกม Grow a Garden จริง
    local workspace = game:GetService("Workspace")
    
    -- ค้นหาร้านไข่
    local eggShop = workspace:FindFirstChild("EggShop") or workspace:FindFirstChild("Eggs")
    
    -- ค้นหาร้านค้าอัพเกรด
    local upgradeShop = workspace:FindFirstChild("UpgradeShop") or workspace:FindFirstChild("Shop")
    
    -- ค้นหาร้านเมล็ดพันธุ์
    local seedShop = workspace:FindFirstChild("SeedShop") or workspace:FindFirstChild("Seeds")
    
    return eggShop, upgradeShop, seedShop
end

-- ฟังก์ชันซื้อไข่อัตโนมัติ
local function autoBuyEgg()
    if not autoEgg then return end
    
    -- นี่คือตัวอย่าง - ต้องปรับแต่งตามการทำงานจริงของเกม
    local eggShop = findGameObjects()
    if eggShop then
        -- ลองค้นหาปุ่มซื้อหรือฟังก์ชันซื้อ
        -- ตัวอย่าง: fireclient หรือการจำลองการคลิก
        notify("ซื้อไข่", "กำลังซื้อไข่...")
    end
end

-- ฟังก์ชันซื้อร้านค้าอัตโนมัติ
local function autoBuyShop()
    if not autoShop then return end
    
    local _, upgradeShop = findGameObjects()
    if upgradeShop then
        notify("ซื้อร้านค้า", "กำลังอัพเกรดร้านค้า...")
    end
end

-- ฟังก์ชันซื้อเมล็ดพันธุ์อัตโนมัติ
local function autoBuySeeds()
    if not autoSeed then return end
    
    local _, _, seedShop = findGameObjects()
    if seedShop then
        notify("ซื้อเมล็ดพันธุ์", "กำลังซื้อเมล็ดพันธุ์...")
    end
end

-- สร้าง GUI และเริ่มทำงาน
local gui = createGUI()

-- ลูปหลักสำหรับการทำงานอัตโนมัติ
RunService.Heartbeat:Connect(function()
    if autoEgg or autoAll then
        autoBuyEgg()
    end
    
    if autoShop or autoAll then
        autoBuyShop()
    end
    
    if autoSeed or autoAll then
        autoBuySeeds()
    end
    
    wait(1) -- รอ 1 วินาทีระหว่างการทำงาน
end)

-- แจ้งเตือนว่าสคริปโหลดเสร็จแล้ว
notify("🌱 Grow Garden Script", "โหลดสคริปเสร็จแล้ว! พร้อมใช้งาน")

print("Grow Garden Script loaded successfully!")