local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local function getLuckyArrowAmount()
    local invString = localPlayer
        .PlayerData.SlotData.Inventory.Value
    
    local data = HttpService:JSONDecode(invString)

    local total = 0
    
    for _, item in ipairs(data) do
        if item.Name == "Lucky Arrow" then
            if item.Amount then
                total += item.Amount
            else
                total += 1
            end
        end
    end
    
    return total
end

local function updateHorst()
    local success, err = pcall(function()

        local luckyArrow = getLuckyArrowAmount()

        local jsonData = {
            LuckyArrow = luckyArrow
        }

        local description = "🏹 Lucky Arrow : " .. luckyArrow

        if _G.Horst_SetDescription then
            _G.Horst_SetDescription(description, HttpService:JSONEncode(jsonData))
        end
    end)

    if not success then
        warn("Horst Error:", err)
    end
end

-- เรียกครั้งแรก
updateHorst()

-- อัปเดตทุก 15 วิ
task.spawn(function()
    while task.wait(15) do
        updateHorst()
    end
end)
