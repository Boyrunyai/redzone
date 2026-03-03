repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ShopRemote = ReplicatedStorage
    :WaitForChild("requests")
    :WaitForChild("character")
    :WaitForChild("raid_shop")

local RaidTokens = LocalPlayer:WaitForChild("PlayerData")
    :WaitForChild("SlotData")
    :WaitForChild("RaidTokens")

local ItemName = "Lucky Arrow"
local ShopName = "Jotaro Kujo"

local ItemCost = 460 -- 🔥 ใส่ราคาจริงของ Lucky Arrow (ห้ามใส่ " ")

ItemCost = tonumber(ItemCost) or 0

local buyCount = 0

-- ===== UI แสดงจำนวนที่ซื้อ =====
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer.PlayerGui

local label = Instance.new("TextLabel")
label.Parent = gui
label.Size = UDim2.new(0,220,0,50)
label.Position = UDim2.new(0.5,-110,0.1,0)
label.BackgroundColor3 = Color3.fromRGB(25,25,25)
label.TextColor3 = Color3.fromRGB(0,255,0)
label.TextScaled = true
label.Text = "Bought: 0"
label.BorderSizePixel = 0

-- ===== ฟังก์ชันลองซื้อ =====
local function tryBuy()
    local currentTokens = tonumber(RaidTokens.Value) or 0
    
    if currentTokens >= ItemCost then
        ShopRemote:FireServer(ItemName, ShopName)
    end
end

-- ===== ดักตอน Token เปลี่ยน =====
local lastValue = tonumber(RaidTokens.Value) or 0

RaidTokens.Changed:Connect(function(newValue)
    
    newValue = tonumber(newValue) or 0
    
    -- ถ้า Token ลด = ซื้อสำเร็จ
    if newValue < lastValue then
        buyCount += 1
        label.Text = "Bought: "..buyCount
    end
    
    lastValue = newValue
    
    -- ถ้า Token เพิ่มและพอซื้อ → ลองซื้อ
    tryBuy()
end)

-- เช็คครั้งแรก
tryBuy()
