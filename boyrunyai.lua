repeat task.wait() until game:IsLoaded()

-- ===== Services =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ===== REMOTE =====
local RequestQuest = ReplicatedStorage
    :WaitForChild("RemoteServices")
    :WaitForChild("QuestsV2Service")
    :WaitForChild("RF")
    :WaitForChild("RequestQuest")

-- ===== STATE =====
local AutoQuest = false
local CurrentQuest = nil
local Buttons = {}

-- ===== CHECK QUEST =====
local function HasQuest()
    local data = LocalPlayer:FindFirstChild("QuestData")
    return data and #data:GetChildren() > 0
end

local function TakeQuest(name)
    RequestQuest:InvokeServer(name)
end

-- ===== AUTO LOOP =====
task.spawn(function()
    while task.wait(2) do
        if AutoQuest and CurrentQuest and not HasQuest() then
            pcall(function()
                TakeQuest(CurrentQuest)
            end)
        end
    end
end)

-- ===== UI =====
local Gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
Gui.Name = "AutoQuest_UI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(260, 360)
Main.Position = UDim2.fromScale(0.05, 0.35)
Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Auto Quest"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

-- ===== MINIMIZE STATE =====
local Minimized = false
local NormalSize = Main.Size

-- ===== MINIMIZE BUTTON =====
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.fromOffset(30, 30)
MinBtn.Position = UDim2.fromScale(1, 0)
MinBtn.AnchorPoint = Vector2.new(1, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BorderSizePixel = 0
MinBtn.TextScaled = true

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    if Minimized then
        -- ย่อ
        Main.Size = UDim2.fromOffset(260, 40)
        MinBtn.Text = "+"
        for b in pairs(Buttons) do
            b.Visible = false
        end
    else
        -- ขยาย
        Main.Size = NormalSize
        MinBtn.Text = "-"
        for b in pairs(Buttons) do
            b.Visible = true
        end
    end
end)

-- ===== FUNCTION CREATE SWITCH =====
local function CreateSwitch(label, questName, yPos)
    local Btn = Instance.new("TextButton", Main)
    Btn.Position = UDim2.fromOffset(10, yPos)
    Btn.Size = UDim2.fromOffset(240, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.BorderSizePixel = 0
    Btn.Text = label .. " : OFF"

    Buttons[Btn] = questName

    Btn.MouseButton1Click:Connect(function()
        if AutoQuest and CurrentQuest == questName then
            -- ปิด
            AutoQuest = false
            CurrentQuest = nil
            Btn.Text = label .. " : OFF"
            Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        else
            -- ปิดอันอื่นก่อน
            for b, q in pairs(Buttons) do
                b.Text = b.Text:match("(.+) :") .. " : OFF"
                b.BackgroundColor3 = Color3.fromRGB(60,60,60)
            end

            -- เปิดอันนี้
            AutoQuest = true
            CurrentQuest = questName
            Btn.Text = label .. " : ON"
            Btn.BackgroundColor3 = Color3.fromRGB(60,120,60)
        end
    end)
end

-- ===== QUEST SWITCHES (ครบตามที่สั่ง) =====
CreateSwitch("🌴 Jungle", "Jungle", 50)
CreateSwitch("❄ SnowForest", "SnowForest", 95)
CreateSwitch("🏜 Desert", "Desert", 140)
CreateSwitch("🕷 SpiderCave", "SpiderCave", 185)
CreateSwitch("🚇 Subway", "Subway", 230)
CreateSwitch("⛏ Caves", "Caves", 275)
