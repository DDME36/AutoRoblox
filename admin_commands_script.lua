-- Admin Commands Script สำหรับ Roblox
-- รันด้วย: loadstring(game:HttpGet("URL"))()

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรสำหรับเก็บค่า
local originalFog = Lighting.FogEnd
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

-- ฟังก์ชันแจ้งเตือน
local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "👑 Admin Commands";
        Text = text;
        Duration = 3;
    })
end

-- ฟังก์ชันหาผู้เล่น
local function findPlayer(name)
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name) or player.DisplayName:lower():find(name) then
            return player
        end
    end
    return nil
end

-- สร้าง GUI Admin
local function createAdminGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminCommands"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- กรอบหลัก
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- หัวข้อ
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    titleLabel.Text = "👑 Admin Commands Panel"
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleLabel
    
    -- พื้นที่เนื้อหา
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    scrollFrame.Parent = mainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- ฟังก์ชันสร้างหมวดหมู่
    local function createCategory(name)
        local categoryLabel = Instance.new("TextLabel")
        categoryLabel.Size = UDim2.new(1, 0, 0, 30)
        categoryLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        categoryLabel.Text = name
        categoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        categoryLabel.TextScaled = true
        categoryLabel.Font = Enum.Font.GothamBold
        categoryLabel.Parent = scrollFrame
        
        local catCorner = Instance.new("UICorner")
        catCorner.CornerRadius = UDim.new(0, 8)
        catCorner.Parent = categoryLabel
    end
    
    -- ฟังก์ชันสร้างปุ่ม
    local function createButton(text, color, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.Gotham
        button.Parent = scrollFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    -- หมวดตัวละคร
    createCategory("🏃 การเคลื่อนไหว")
    
    createButton("💨 ความเร็ว x3", Color3.fromRGB(100, 150, 255), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 48
            notify("ความเร็ว x3 เปิดใช้งาน")
        end
    end)
    
    createButton("🚀 ความเร็ว x5", Color3.fromRGB(150, 100, 255), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 80
            notify("ความเร็ว x5 เปิดใช้งาน")
        end
    end)
    
    createButton("🦘 กระโดดสูงมาก", Color3.fromRGB(255, 150, 100), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 150
            notify("กระโดดสูงมาก เปิดใช้งาน")
        end
    end)
    
    createButton("🌙 กระโดดไปดวงจันทร์", Color3.fromRGB(200, 100, 255), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 300
            notify("กระโดดไปดวงจันทร์!")
        end
    end)
    
    -- หมวดสภาพแวดล้อม
    createCategory("🌍 สภาพแวดล้อม")
    
    createButton("🌅 กลางวัน", Color3.fromRGB(255, 200, 100), function()
        Lighting.TimeOfDay = "12:00:00"
        Lighting.Brightness = 2
        notify("เปลี่ยนเป็นกลางวันแล้ว")
    end)
    
    createButton("🌙 กลางคืน", Color3.fromRGB(50, 50, 100), function()
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Brightness = 0
        notify("เปลี่ยนเป็นกลางคืนแล้ว")
    end)
    
    createButton("🌈 ฟ้าสีรุ้ง", Color3.fromRGB(255, 100, 200), function()
        local sky = Lighting:FindFirstChild("Sky")
        if not sky then
            sky = Instance.new("Sky")
            sky.Parent = Lighting
        end
        sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.jpg"
        sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.jpg"
        sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.jpg"
        sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.jpg"
        sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.jpg"
        sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.jpg"
        notify("ฟ้าสีรุ้งแล้ว!")
    end)
    
    createButton("🌫️ หมอกหนา", Color3.fromRGB(150, 150, 150), function()
        Lighting.FogEnd = 50
        Lighting.FogColor = Color3.fromRGB(100, 100, 100)
        notify("เปิดหมอกหนาแล้ว")
    end)
    
    -- หมวดเอฟเฟกต์
    createCategory("✨ เอฟเฟกต์พิเศษ")
    
    createButton("💥 ระเบิดตัวเอง", Color3.fromRGB(255, 100, 100), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local explosion = Instance.new("Explosion")
            explosion.Position = LocalPlayer.Character.HumanoidRootPart.Position
            explosion.BlastRadius = 30
            explosion.BlastPressure = 1000000
            explosion.Parent = workspace
            notify("💥 บูม!")
        end
    end)
    
    createButton("🔥 ไฟรอบตัว", Color3.fromRGB(255, 150, 0), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local fire = Instance.new("Fire")
            fire.Size = 10
            fire.Heat = 15
            fire.Parent = LocalPlayer.Character.HumanoidRootPart
            notify("🔥 คุณติดไฟแล้ว!")
        end
    end)
    
    createButton("✨ ประกายแสง", Color3.fromRGB(255, 255, 100), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local sparkles = Instance.new("Sparkles")
            sparkles.Parent = LocalPlayer.Character.HumanoidRootPart
            notify("✨ ประกายแสงรอบตัว!")
        end
    end)
    
    createButton("💨 ควันขาว", Color3.fromRGB(200, 200, 200), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local smoke = Instance.new("Smoke")
            smoke.Size = 8
            smoke.Opacity = 0.7
            smoke.RiseVelocity = 5
            smoke.Parent = LocalPlayer.Character.HumanoidRootPart
            notify("💨 ควันขาวรอบตัว!")
        end
    end)
    
    -- หมวดเสียง
    createCategory("🔊 เสียง")
    
    createButton("🎵 เพลงสนุก", Color3.fromRGB(100, 255, 150), function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        sound.Volume = 0.5
        sound.Looped = true
        sound.Parent = workspace
        sound:Play()
        notify("🎵 เล่นเพลงแล้ว!")
    end)
    
    createButton("🔇 หยุดเสียงทั้งหมด", Color3.fromRGB(255, 100, 100), function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj:Stop()
            end
        end
        notify("🔇 หยุดเสียงทั้งหมดแล้ว")
    end)
    
    -- หมวดรีเซ็ต
    createCategory("🔄 รีเซ็ต")
    
    createButton("🔄 รีเซ็ตตัวละคร", Color3.fromRGB(255, 200, 100), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
            notify("รีเซ็ตตัวละครแล้ว")
        end
    end)
    
    createButton("🌍 รีเซ็ตสภาพแวดล้อม", Color3.fromRGB(100, 200, 255), function()
        Lighting.FogEnd = originalFog
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.TimeOfDay = "14:00:00"
        
        -- ลบเอฟเฟกต์
        local sky = Lighting:FindFirstChild("Sky")
        if sky then sky:Destroy() end
        
        notify("รีเซ็ตสภาพแวดล้อมแล้ว")
    end)
    
    createButton("✨ ลบเอฟเฟกต์ตัวละคร", Color3.fromRGB(200, 100, 200), function()
        if LocalPlayer.Character then
            for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
                if obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Smoke") then
                    obj:Destroy()
                end
            end
            notify("ลบเอฟเฟกต์ตัวละครแล้ว")
        end
    end)
    
    -- ปุ่มปิด
    createButton("❌ ปิด Admin Panel", Color3.fromRGB(200, 50, 50), function()
        screenGui:Destroy()
        notify("ปิด Admin Panel แล้ว")
    end)
    
    return screenGui
end

-- สร้าง GUI
createAdminGUI()

-- แจ้งเตือน
notify("Admin Commands โหลดเสร็จแล้ว! 👑")

print("Admin Commands Script loaded successfully!")