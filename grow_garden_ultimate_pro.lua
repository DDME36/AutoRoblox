--!nocheck
-- Script for Grow a Garden - Auto Buy
-- Updated: 2025-07-15

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- UI Library (Simplified for demonstration, based on common patterns)
local UI = {
    ScreenGui = Instance.new("ScreenGui"),
    MainFrame = Instance.new("Frame"),
    ScrollingFrame = Instance.new("ScrollingFrame"),
    UIListLayout = Instance.new("UIListLayout"),
}

UI.ScreenGui.Name = "GrowAGardenAutoBuyUI"
UI.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
UI.ScreenGui.IgnoreGuiInset = true

UI.MainFrame.Name = "MainFrame"
UI.MainFrame.Size = UDim2.new(0, 300, 0, 400)
UI.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
UI.MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
UI.MainFrame.BorderSizePixel = 1
UI.MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
UI.MainFrame.Active = true
UI.MainFrame.Draggable = true
UI.MainFrame.Parent = UI.ScreenGui

UI.ScrollingFrame.Name = "Content"
UI.ScrollingFrame.Size = UDim2.new(1, 0, 1, -30) -- Leave space for title
UI.ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
UI.ScrollingFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
UI.ScrollingFrame.BorderSizePixel = 0
UI.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
UI.ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
UI.ScrollingFrame.ScrollBarThickness = 6
UI.ScrollingFrame.Parent = UI.MainFrame

UI.UIListLayout.Name = "ListLayout"
UI.UIListLayout.Parent = UI.ScrollingFrame
UI.UIListLayout.FillDirection = Enum.FillDirection.Vertical
UI.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UI.UIListLayout.Padding = UDim.new(0, 5)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Text = "Grow a Garden - สคริปต์ซื้ออัตโนมัติ"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = UI.MainFrame

-- Function to create a button
local function CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Parent = UI.ScrollingFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Function to create a toggle button
local function CreateToggle(text, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    frame.BorderSizePixel = 0
    frame.Parent = UI.ScrollingFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.25, 0, 0.8, 0)
    toggleButton.Position = UDim2.new(0.72, 0, 0.1, 0)
    toggleButton.Text = defaultState and "เปิด" or "ปิด"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 16
    toggleButton.Parent = frame

    local currentState = defaultState

    toggleButton.MouseButton1Click:Connect(function()
        currentState = not currentState
        toggleButton.Text = currentState and "เปิด" or "ปิด"
        toggleButton.BackgroundColor3 = currentState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        callback(currentState)
    end)
    return frame, currentState
end

-- Placeholder for RemoteEvents. These need to be found by inspecting the game.
-- Common paths: game.ReplicatedStorage.RemoteEventName, game.Workspace.RemoteEventName, etc.
-- You MUST replace these with the actual RemoteEvents found in the game.
local BuyEggRemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("BuyEgg")
local BuySeedRemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("BuySeed")
local BuyShopTierRemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("BuyShopTier")

-- Function to simulate buying an item
-- This is a generic function. The actual parameters depend on the game's RemoteEvent.
-- You will need to inspect the game's network traffic (e.g., using a network sniffer or Roblox's developer console) 
-- to find the exact RemoteEvent names and the arguments they expect.
local function BuyItem(remoteEvent, itemType, itemName, quantity)
    if remoteEvent and remoteEvent:IsA("RemoteEvent") then
        print("Attempting to buy: " .. itemName .. " (Type: " .. itemType .. ", Quantity: " .. tostring(quantity) .. ")")
        -- Example: FireServer with item name and quantity
        -- The actual arguments might be different! For example, some games might only need the item name.
        -- remoteEvent:FireServer(itemName, quantity)
        -- Or just the item name:
        -- remoteEvent:FireServer(itemName)
        -- Or a table of data:
        -- remoteEvent:FireServer({Item = itemName, Quantity = quantity})
        
        -- *** IMPORTANT: You need to find the correct arguments by inspecting the game! ***
        -- For demonstration, we'll assume it takes item name and quantity.
        -- If the game uses a single generic buy event, you might need to pass the shop type as well.
        
        -- Example for buying an egg (assuming 'BuyEgg' RemoteEvent exists and takes egg name)
        if itemType == "Egg" then
            remoteEvent:FireServer(itemName)
        -- Example for buying a seed (assuming 'BuySeed' RemoteEvent exists and takes seed name and quantity)
        elseif itemType == "Seed" then
            remoteEvent:FireServer(itemName, quantity)
        -- Example for buying a shop tier (assuming 'BuyShopTier' RemoteEvent exists and takes tier name/ID)
        elseif itemType == "ShopTier" then
            remoteEvent:FireServer(itemName)
        else
            warn("Unknown item type or RemoteEvent not found for: " .. itemType)
        end
        
        print("Fired RemoteEvent for " .. itemName)
    else
        warn("RemoteEvent not found or invalid for " .. (remoteEvent and remoteEvent.Name or "N/A") .. ". Cannot buy " .. itemName .. ".")
        print("Please ensure the RemoteEvent path is correct in the script.")
    end
end

-- Auto Buy Toggles (placeholders - actual item names need to be found in-game)
local autoBuyEggsEnabled = false
local autoBuySeedsEnabled = false
local autoBuyShopTiersEnabled = false

CreateToggle("ซื้อไข่อัตโนมัติ", autoBuyEggsEnabled, function(state)
    autoBuyEggsEnabled = state
    print("Auto Buy Eggs: " .. tostring(state))
    -- Implement logic to continuously try buying eggs if enabled
    if state then
        -- Example: Buy a specific egg. You need to know the exact egg name.
        -- task.spawn(function()
        --     while autoBuyEggsEnabled do
        --         BuyItem(BuyEggRemoteEvent, "Egg", "Common Egg", 1) -- Replace "Common Egg" with actual egg name
        --         task.wait(5) -- Wait before trying again
        --     end
        -- end)
    end
end)

CreateToggle("ซื้อเมล็ดพันธุ์อัตโนมัติ", autoBuySeedsEnabled, function(state)
    autoBuySeedsEnabled = state
    print("Auto Buy Seeds: " .. tostring(state))
    -- Implement logic to continuously try buying seeds if enabled
    if state then
        -- Example: Buy a specific seed. You need to know the exact seed name.
        -- task.spawn(function()
        --     while autoBuySeedsEnabled do
        --         BuyItem(BuySeedRemoteEvent, "Seed", "Basic Seed", 1) -- Replace "Basic Seed" with actual seed name
        --         task.wait(5) -- Wait before trying again
        --     end
        -- end)
    end
end)

CreateToggle("ซื้อร้านค้าเทียร์อัตโนมัติ", autoBuyShopTiersEnabled, function(state)
    autoBuyShopTiersEnabled = state
    print("Auto Buy Shop Tiers: " .. tostring(state))
    -- Implement logic to continuously try buying shop tiers if enabled
    if state then
        -- Example: Buy a specific shop tier. You need to know the exact tier name/ID.
        -- task.spawn(function()
        --     while autoBuyShopTiersEnabled do
        --         BuyItem(BuyShopTierRemoteEvent, "ShopTier", "Tier 2 Shop", 1) -- Replace "Tier 2 Shop" with actual tier name
        --         task.wait(10) -- Wait before trying again
        --     end
        -- end)
    end
end)

-- Buy All Button (This will attempt to buy all known items)
CreateButton("ซื้อทั้งหมด (ทุกอย่าง)", function()
    print("Attempting to buy all items...")
    -- Example: Buy a few common items. You MUST replace these with actual in-game item names.
    -- Eggs
    BuyItem(BuyEggRemoteEvent, "Egg", "Common Egg", 1)
    BuyItem(BuyEggRemoteEvent, "Egg", "Rare Egg", 1)
    
    -- Seeds
    BuyItem(BuySeedRemoteEvent, "Seed", "Basic Seed", 1)
    BuyItem(BuySeedRemoteEvent, "Seed", "Carrot Seed", 1)
    
    -- Shop Tiers
    BuyItem(BuyShopTierRemoteEvent, "ShopTier", "Tier 1 Shop", 1)
    BuyItem(BuyShopTierRemoteEvent, "ShopTier", "Tier 2 Shop", 1)
    
    print("Finished attempting to buy all items. Check game for results.")
end)

-- Important Note:
-- The RemoteEvents and item names used in this script are placeholders.
-- You need to find the actual RemoteEvent names and the exact item names/IDs 
-- that the game uses for purchasing. This usually involves:
-- 1. Using a network sniffer (like Fiddler or Wireshark) while playing the game and buying an item manually.
-- 2. Using Roblox's built-in developer console (F9) to look for RemoteEvent calls when you buy something.
-- 3. Decompiling the game's client-side scripts (advanced, not recommended for beginners).

-- Once you find the correct RemoteEvent and its parameters, update the 'BuyItem' function
-- and the calls to it with the accurate information.

-- Example of how a RemoteEvent might be structured in ReplicatedStorage:
-- game.ReplicatedStorage.Events.PurchaseItem:FireServer("Egg", "Common Egg", 1)
-- game.ReplicatedStorage.ShopEvents.BuySeed:FireServer("Tomato Seed", 5)

-- The `Stockbot.lua` you provided earlier suggests `ReplicatedStorage.GameEvents.DataStream`
-- is used for data updates. It's possible the purchase events are in the same `GameEvents` folder
-- or a similar location. Look for events like "BuyItem", "Purchase", "ShopBuy", etc.

-- Good luck, and happy gardening!


