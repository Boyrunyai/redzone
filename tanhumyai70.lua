repeat task.wait() until game:IsLoaded()

-- แก้หมดแล้วอย่าปรับเพิ่มไอหน้าหี By tanrunyai66/5
-- ===== Services =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- ===== BASE =====
local Map = workspace:WaitForChild("Christmas Village")
local BASE = Map:WaitForChild("Rooms"):WaitForChild("Spawn"):WaitForChild("BASE")
BASE.PrimaryPart = BASE.PrimaryPart or BASE:FindFirstChildWhichIsA("BasePart")

-- ===== FOLDERS =====
local PropsFolder = workspace:WaitForChild("Props")
local ItemsFolder = workspace:WaitForChild("Items")
local EntitiesFolder = workspace:WaitForChild("Entities") -- 👈 มอน

-- ===== CONFIG =====
local FollowOffset = CFrame.new(0, 10, 0)
local CollectRadius = 25

-- Obstacles
local ObstacleDetectRange = 120
local ObstacleAttackRange = 22
local TeleportOffset = 10

-- Monsters
local MonsterDetectRange = 40      -- ระยะที่ BASE ตรวจมอน
local MonsterAttackRange = 20
local MonsterTeleportOffset = 9

-- ===== INPUT =====
local function leftClick()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function pressKey(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

local function fullAttack()
    leftClick()
    task.wait(0.1)
    pressKey(Enum.KeyCode.Z)
    task.wait(0.1)
    pressKey(Enum.KeyCode.X)
    task.wait(0.1)
    pressKey(Enum.KeyCode.C)
    task.wait(0.1)
    pressKey(Enum.KeyCode.V)
end

-- ===== AUTO PICK CHECKPOINT =====
local function autoPickCheckpoint()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end

    for _, gui in pairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local title = gui:FindFirstChildWhichIsA("TextLabel", true)
            if title and title.Text:upper():find("CHOOSE") then
                for _, btn in pairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") then
                        if btn.Text:lower():find("speed") then
                            task.wait(0.2)
                            btn:Activate()
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- ===== COLLECT ITEMS =====
local function collectItems()
    for _, item in pairs(ItemsFolder:GetChildren()) do
        local part =
            item:IsA("BasePart") and item
            or (item:IsA("Model") and item:FindFirstChildWhichIsA("BasePart", true))

        if part and (part.Position - HRP.Position).Magnitude <= CollectRadius then
            HRP.CFrame = part.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.1)
        end
    end
end

-- ===== AUTO KILL MONSTERS =====
local function killMonstersNearBase()
    if not BASE.PrimaryPart then return false end

    for _, mob in pairs(EntitiesFolder:GetChildren()) do
        local part =
            (mob:IsA("Model") and (mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart", true)))
            or (mob:IsA("BasePart") and mob)

        if part then
            local distBase = (part.Position - BASE.PrimaryPart.Position).Magnitude
            if distBase <= MonsterDetectRange then
                local dir = (HRP.Position - part.Position).Unit
                local standPos = part.Position + (dir * MonsterTeleportOffset)

                HRP.CFrame = CFrame.new(standPos, part.Position)
                task.wait(0.05)

                if (HRP.Position - part.Position).Magnitude <= MonsterAttackRange then
                    repeat
                        HRP.CFrame = CFrame.new(HRP.Position, part.Position)
                        fullAttack()
                        task.wait(0.25)
                    until not mob.Parent
                end

                return true -- โฟกัสทีละตัว
            end
        end
    end
    return false
end

-- ===== BREAK OBSTACLES =====
local function breakObstacles()
    for _, prop in pairs(PropsFolder:GetChildren()) do
        local part =
            (prop:IsA("Model") and (prop.PrimaryPart or prop:FindFirstChildWhichIsA("BasePart", true)))
            or (prop:IsA("BasePart") and prop)

        if part then
            local dist = (HRP.Position - part.Position).Magnitude
            if dist <= ObstacleDetectRange then
                local dir = (HRP.Position - part.Position).Unit
                local standPos = part.Position + (dir * TeleportOffset)

                HRP.CFrame = CFrame.new(standPos, part.Position)

                if (HRP.Position - part.Position).Magnitude <= ObstacleAttackRange then
                    repeat
                        HRP.CFrame = CFrame.new(HRP.Position, part.Position)
                        fullAttack()
                        task.wait(0.25)
                    until not prop.Parent
                end
            end
        end
    end
end

--  ลูปหลักห้ามปรับไอสัด ใครปรับหำน้อย
RunService.Heartbeat:Connect(function()
    if not HRP or not BASE or not BASE.PrimaryPart then return end

    -- เคลียร์ checkpoint 
    if autoPickCheckpoint() then return end

    -- เคีลยร์prop
    breakObstacles()

    --  ฆ่ามอนที่ระยะ BASE
    if killMonstersNearBase() then return end

    collectItems()

    --  BASE หลัก
    HRP.CFrame = BASE.PrimaryPart.CFrame * FollowOffset
    HRP.AssemblyLinearVelocity = Vector3.zero
    HRP.AssemblyAngularVelocity = Vector3.zero
end)

