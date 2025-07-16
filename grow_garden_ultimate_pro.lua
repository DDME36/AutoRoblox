--[[
    Grow a Garden Script - V2.0 Full System by Gemini
    Features:
    - Infinity UI: A beautiful and modern UI library.
    - Smart Farming: Auto buy cheapest seeds, harvest only mature plants.
    - Full Auto Functions: Farming, Buying, Pet Equipping.
    - Stability: Anti-AFK, Reconnect concepts, Error Handling.
    - Customization: Adjustable farm speed.
]]

\-- =================================================================================================
\-- || Infinity UI Library - Created by Gemini for a better user experience ||
\-- =================================================================================================

local InfinityUI = {}
InfinityUI.\_\_index = InfinityUI

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function InfinityUI.CreateWindow(title)
local screenGui = Instance.new("ScreenGui")
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.Name = "InfinityUI\_" .. math.random(1000, 9999)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 550, 0, 350)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderColor3 = Color3.fromRGB(85, 85, 125)
mainFrame.BorderSizePixel = 1
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
header.BorderColor3 = Color3.fromRGB(85, 85, 125)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.Text = title or "Infinity Hub"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 120, 1, -30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -120, 1, -30)
contentContainer.Position = UDim2.new(0, 120, 0, 30)
contentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

local tabs = {}
local contents = {}

-- Desktop Icon / Toggle Button
local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
toggleButton.Image = "rbxassetid://6033422449" -- A nice gear icon
toggleButton.ImageColor3 = Color3.fromRGB(150, 150, 250)
toggleButton.Draggable = true
toggleButton.Parent = screenGui

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
mainFrame.Visible = not mainFrame.Visible
end)
mainFrame.Visible = false -- Start hidden

local window = {
_screenGui = screenGui,
_mainFrame = mainFrame,
_tabContainer = tabContainer,
_contentContainer = contentContainer,
_tabLayout = tabLayout,
_tabs = tabs,
_contents = contents,
_activeTab = nil
}

function window:AddTab(name)
local tabButton = Instance.new("TextButton")
tabButton.Name = name
tabButton.Size = UDim2.new(1, -10, 0, 30)
tabButton.Position = UDim2.new(0, 5, 0, 0)
tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
tabButton.Font = Enum.Font.SourceSans
tabButton.Text = name
tabButton.Parent = self._tabContainer
tabButton.LayoutOrder = #self._tabs + 1

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 4)
tabCorner.Parent = tabButton

local contentPage = Instance.new("ScrollingFrame")
contentPage.Size = UDim2.new(1, -10, 1, -10)
contentPage.Position = UDim2.new(0, 5, 0, 5)
contentPage.BackgroundColor3 = self._contentContainer.BackgroundColor3
contentPage.BorderSizePixel = 0
contentPage.Visible = false
contentPage.CanvasSize = UDim2.new(0,0,0,0)
contentPage.ScrollBarImageColor3 = Color3.fromRGB(85, 85, 125)
contentPage.Parent = self._contentContainer

local pageLayout = Instance.new("UIListLayout")
pageLayout.Padding = UDim.new(0, 8)
pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
pageLayout.Parent = contentPage

table.insert(self._tabs, tabButton)
table.insert(self._contents, contentPage)

local tabObject = {}

function tabObject:AddToggle(text, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 25)
    toggleFrame.BackgroundColor3 = Color3.new(1,1,1)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = contentPage
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.Position = UDim2.new(0, 0, 0.5, -10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 6)
    tbCorner.Parent = toggleButton
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0.5, 0, 0.5, 0)
    toggleIndicator.Position = UDim2.new(0.25, 0, 0.25, 0)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggleButton
    local tiCorner = Instance.new("UICorner")
    tiCorner.CornerRadius = UDim.new(0, 4)
    tiCorner.Parent = toggleIndicator
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -30, 1, 0)
    toggleLabel.Position = UDim2.new(0, 30, 0, 0)
    toggleLabel.BackgroundColor3 = Color3.new(1,1,1)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.SourceSans
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleLabel.Text = text
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggled = false
    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        local color = toggled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 70)
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        pcall(callback, toggled)
    end)
end

function tabObject:AddButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.SourceSansSemibold
    button.Text = text
    button.Parent = contentPage
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

function tabObject:AddSlider(text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = contentPage

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    sliderLabel.Text = text .. ": " .. default
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, 0, 0, 8)
    sliderBack.Position = UDim2.new(0, 0, 0, 25)
    sliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBack.Parent = sliderFrame
    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(1, 0)
    sbCorner.Parent = sliderBack

    local sliderFill = Instance.new("Frame")
    local progress = (default - min) / (max - min)
    sliderFill.Size = UDim2.new(progress, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(85, 85, 125)
    sliderFill.Parent = sliderBack
    local sfCorner = Instance.new("UICorner")
    sfCorner.CornerRadius = UDim.new(1, 0)
    sfCorner.Parent = sliderFill

    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new(progress, -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    sliderHandle.Text = ""
    sliderHandle.Parent = sliderFill
    local shCorner = Instance.new("UICorner")
    shCorner.CornerRadius = UDim.new(1, 0)
    shCorner.Parent = sliderHandle

    local dragging = false
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    sliderHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos.X - sliderBack.AbsolutePosition.X
            local percentage = math.clamp(relativePos / sliderBack.AbsoluteSize.X, 0, 1)
            
            local value = math.floor((min + (max - min) * percentage) * 100) / 100
            sliderLabel.Text = text .. ": " .. string.format("%.2f", value)
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderHandle.Position = UDim2.new(percentage, -8, 0.5, -8)
            pcall(callback, value)
        end
    end)
end

tabButton.MouseButton1Click:Connect(function()
    for i, v in ipairs(self._tabs) do
        local content = self._contents[i]
        local active = (v == tabButton)
        
        v.BackgroundColor3 = active and Color3.fromRGB(85, 85, 125) or Color3.fromRGB(50, 50, 60)
        content.Visible = active
        if active then
            self._activeTab = v
            content.CanvasSize = UDim2.new(0, 0, 0, content.UIListLayout.AbsoluteContentSize.Y + 10)
        end
    end
end)

-- Auto-select first tab
if #self._tabs == 1 then
    tabButton:Invoke()
end

return tabObject
end

function window:SetParent(parent)
self._screenGui.Parent = parent
end

return window


end

\-- =================================================================================================
\-- || Script Configuration & Core Logic ||
\-- =================================================================================================

local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

local Config = {
\-- Farming
AutoPlant = false,
AutoHarvest = false,
AutoSell = false,
FarmSpeed = 1.0,
\-- Buying
AutoBuyCheapestSeed = false,
AutoBuyEgg = false,
\-- Player
AutoEquipBestPet = false,
\-- Misc
AntiAFK = false,
}

local GameData = {
Remotes = {},
Plots = nil,
Crops = nil,
Shops = nil,
SellPoint = nil
}

\-- Utility functions
local function Notify(title, text)
\-- In a real scenario, you'd use the UI to show a notification.
\-- For now, we'll just print.
print(string.format("[GEMINI HUB | %s] %s", title, text))
end

local function GetPlayer()
return game:GetService("Players").LocalPlayer
end

local function GetCharacter()
local p = GetPlayer()
return p and p.Character
end

local function Teleport(position)
local char = GetCharacter()
if char and char:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.CFrame = CFrame.new(position)
end
end

local function FindRemote(name)
if GameData.Remotes[name] then
return GameData.Remotes[name]
end
\-- This is a simple search. A more advanced script would "spy" on remote calls.
local replicatedStorage = game:GetService("ReplicatedStorage")
local remote = replicatedStorage:FindFirstChild(name, true)
if remote then
GameData.Remotes[name] = remote
return remote
end
Notify("Error", "ไม่เจอ RemoteEvent ชื่อ: " .. name)
return nil
end

local function SafeFireServer(remoteName, ...)
local remote = FindRemote(remoteName)
if remote then
pcall(function()
remote:FireServer(...)
end)
end
end

\-- Function to find game-specific folders and parts
function FindGameAssets()
GameData.Plots = Workspace:FindFirstChild("Plots", true)
GameData.Crops = Workspace:FindFirstChild("Crops", true) -- Assuming crops are in a folder
GameData.Shops = Workspace:FindFirstChild("Shops", true)
GameData.SellPoint = Workspace:FindFirstChild("SellPart", true) or Workspace:FindFirstChild("SellPoint", true)

if not GameData.Plots then Notify("Warning", "หาโฟลเดอร์ 'Plots' ไม่เจอ!") end
if not GameData.Crops then GameData.Crops = Workspace end -- Fallback to searching entire workspace
if not GameData.Shops then Notify("Warning", "หาโซน 'Shops' ไม่เจอ!") end
if not GameData.SellPoint then Notify("Warning", "หาจุด 'SellPoint' ไม่เจอ!") end


end

\-- =================================================================================================
\-- || Automation Functions ||
\-- =================================================================================================

\-- \#\# FARMING \#\#
function AutoPlantLoop()
task.spawn(function()
while Config.AutoPlant and task.wait(Config.FarmSpeed) do
if not GameData.Plots then continue end
local char = GetCharacter()
if not char then continue end

    local plots = GameData.Plots:GetChildren()
    for _, plot in ipairs(plots) do
        -- This condition needs to be specific to the game
        -- e.g., checking if a plot is owned by the player and is empty
        if plot:FindFirstChild("Owner") and plot.Owner.Value == Player.Name and not plot:FindFirstChild("Crop") then
            local plotPosition = plot.Position
            Teleport(plotPosition + Vector3.new(0, 3, 0))
            -- The remote and arguments are game-specific. This is a guess.
            -- A better way is to find the seed in inventory and pass it.
            SafeFireServer("PlantSeed", plot, "CheapestSeedName") 
            Notify("ฟาร์ม", "ปลูกผักที่แปลง: " .. tostring(plot.Name))
            task.wait(0.2) -- Small delay after planting
            break -- Plant one at a time
        end
    end
end
end)


end

function AutoHarvestLoop()
task.spawn(function()
while Config.AutoHarvest and task.wait(Config.FarmSpeed) do
if not GameData.Crops then continue end
local char = GetCharacter()
if not char then continue end

    for _, crop in ipairs(GameData.Crops:GetChildren()) do
        -- This condition needs to be specific to the game
        -- e.g., checking the crop's "Stage" or "Size" property
        -- Let's assume a fully grown crop has a specific size or property
        local isMature = (crop.Size.Y > 5) -- Example condition
        if crop.Name == "Plant" and isMature then
             local cropPosition = crop.Position
             Teleport(cropPosition + Vector3.new(0, 3, 0))
             SafeFireServer("HarvestCrop", crop)
             Notify("ฟาร์ม", "เก็บเกี่ยว: " .. tostring(crop.Name))
             task.wait(0.2)
             break -- Harvest one at a time
        end
    end
end
end)


end

function AutoSellLoop()
task.spawn(function()
while Config.AutoSell and task.wait(Config.FarmSpeed + 1) do -- Selling can be slower
if not GameData.SellPoint then
Notify("ขายของ", "หาจุดขายไม่เจอ\!")
continue
end
Teleport(GameData.SellPoint.Position + Vector3.new(0, 5, 0))
SafeFireServer("SellCrops")
Notify("ขายของ", "ขายของทั้งหมดแล้ว\!")
end
end)
end

\-- \#\# BUYING \#\#
function AutoBuyCheapestSeedLoop()
task.spawn(function()
while Config.AutoBuyCheapestSeed and task.wait(Config.FarmSpeed + 1) do
\-- This is complex and highly game-specific.
\-- It requires reading the shop's GUI to find the cheapest item.
local seedShopUI = Player.PlayerGui:FindFirstChild("SeedShop", true)
if not seedShopUI or not seedShopUI.Visible then
\-- Teleport to shop if needed
local shopPart = GameData.Shops and GameData.Shops:FindFirstChild("SeedShop")
if shopPart then Teleport(shopPart.Position) end
Notify("ซื้อของ", "กำลังเปิดร้านค้าเมล็ด...")
task.wait(2) -- Wait for UI to load
seedShopUI = Player.PlayerGui:FindFirstChild("SeedShop", true)
if not seedShopUI then
Notify("Error", "หาร้านค้าเมล็ด UI ไม่เจอ\!")
continue
end
end

    local cheapestSeed = {button = nil, price = math.huge}
    
    -- Scan UI for items
    local itemFrame = seedShopUI:FindFirstChild("ItemsFrame", true)
    if itemFrame then
        for _, itemButton in ipairs(itemFrame:GetChildren()) do
            if itemButton:IsA("TextButton") or itemButton:IsA("ImageButton") then
                local priceLabel = itemButton:FindFirstChild("PriceLabel")
                local price = priceLabel and tonumber(priceLabel.Text)
                if price and price < cheapestSeed.price then
                    cheapestSeed.button = itemButton
                    cheapestSeed.price = price
                end
            end
        end
    end
    
    if cheapestSeed.button then
        Notify("ซื้อของ", "เจอเมล็ดที่ถูกที่สุด! ราคา: " .. cheapestSeed.price)
        -- The remote might need the item name or the button itself.
        SafeFireServer("BuyItem", cheapestSeed.button.Name)
    else
        Notify("ซื้อของ", "ไม่สามารถหาเมล็ดที่ถูกที่สุดได้")
    end
end
end)


end

\-- \#\# PLAYER \#\#
function AutoEquipBestPetLoop()
task.spawn(function()
while Config.AutoEquipBestPet and task.wait(5) do -- No need to run this too fast
local petInventory = Player:FindFirstChild("PetInventory")
if not petInventory then
Notify("สัตว์เลี้ยง", "หา Pet Inventory ไม่เจอ\!")
continue
end

    local bestPet = {instance = nil, multiplier = 0}
    
    for _, pet in ipairs(petInventory:GetChildren()) do
        local multiplierValue = pet:FindFirstChild("Multiplier")
        if multiplierValue and multiplierValue.Value > bestPet.multiplier then
            bestPet.instance = pet
            bestPet.multiplier = multiplierValue.Value
        end
    end
    
    if bestPet.instance then
        Notify("สัตว์เลี้ยง", "กำลังสวมใส่: " .. bestPet.instance.Name .. " (x" .. bestPet.multiplier .. ")")
        SafeFireServer("EquipPet", bestPet.instance)
    end
end
end)


end

\-- \#\# MISC \#\#
function AntiAFKLoop()
task.spawn(function()
local VirtualUser = game:GetService('VirtualUser')
Player.Idled:Connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
while Config.AntiAFK and task.wait(120) do
Notify("Anti-AFK", "ป้องกันการหลุดจากเกม...")
end
end)
end

\-- =================================================================================================
\-- || UI Construction ||
\-- =================================================================================================

FindGameAssets()

local window = InfinityUI.CreateWindow("Grow a Garden | Gemini Hub V2")
window:SetParent(getcoregui() or Player.PlayerGui)

\-- Tab: ฟาร์ม
local farmTab = window:AddTab("🏡 ฟาร์ม")
farmTab:AddToggle("🌱 ปลูกผักอัตโนมัติ", function(toggled)
Config.AutoPlant = toggled
if toggled then AutoPlantLoop() end
end)
farmTab:AddToggle("✂️ เก็บเกี่ยวอัตโนมัติ", function(toggled)
Config.AutoHarvest = toggled
if toggled then AutoHarvestLoop() end
end)
farmTab:AddToggle("💰 ขายของอัตโนมัติ", function(toggled)
Config.AutoSell = toggled
if toggled then AutoSellLoop() end
end)
farmTab:AddSlider("⏱️ ความเร็วฟาร์ม (วินาที)", 0.2, 5, Config.FarmSpeed, function(value)
Config.FarmSpeed = value
end)

\-- Tab: ซื้อของ
local buyTab = window:AddTab("🛒 ซื้อของ")
buyTab:AddToggle("💸 ซื้อเมล็ดพันธุ์ถูกสุด", function(toggled)
Config.AutoBuyCheapestSeed = toggled
if toggled then AutoBuyCheapestSeedLoop() end
end)
buyTab:AddButton("🥚 ซื้อไข่ทั้งหมด (เร็วๆ นี้)", function()
Notify("Info", "ฟังก์ชันนี้ยังไม่เปิดใช้งาน")
end)
buyTab:AddButton("🏪 ซื้อร้านค้าทั้งหมด (เร็วๆ นี้)", function()
Notify("Info", "ฟังก์ชันนี้ยังไม่เปิดใช้งาน")
end)

\-- Tab: ผู้เล่น
local playerTab = window:AddTab("👤 ผู้เล่น")
playerTab:AddToggle("🐶 สวมใส่สัตว์เลี้ยงดีสุด", function(toggled)
Config.AutoEquipBestPet = toggled
if toggled then AutoEquipBestPetLoop() end
end)
playerTab:AddButton("♻️ รีเฟรชหาจุดต่างๆ ในเกม", function()
Notify("System", "กำลังสแกนหาจุดสำคัญในเกมใหม่...")
FindGameAssets()
Notify("System", "สแกนเสร็จสิ้น\!")
end)

\-- Tab: เบ็ดเตล็ด
local miscTab = window:AddTab("⚙️ เบ็ดเตล็ด")
miscTab:AddToggle("🚫 กันหลุด (Anti-AFK)", function(toggled)
Config.AntiAFK = toggled
if toggled then AntiAFKLoop() end
end)

Notify("System", "สคริปต์ Grow a Garden โดย Gemini โหลดเสร็จสมบูรณ์\!")
Notify("System", "คลิกไอคอนรูปเฟือง ⚙️ เพื่อเปิด/ปิดหน้าต่าง")
