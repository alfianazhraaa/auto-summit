-- TELEPORT KE GOPAY REDEMPTION POINT
-- Koordinat dari Motion Log t=39.94 (posisi terakhir sebelum claim)
-- Prompt: "Claim Voucher" @ RedemptionPointBasepart

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function teleportToGopay()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    -- Koordinat final dari log (posisi swim terakhir tercatat)
    local TARGET = Vector3.new(-527.5, 1062.0, 333.4)

    hrp.CFrame = CFrame.new(TARGET + Vector3.new(0, 5, 0))

    -- Tunggu sebentar lalu cari dan trigger ProximityPrompt
    task.wait(0.8)

    -- Cari RedemptionPointBasepart di workspace
    local function findRedemption()
        for _, v in ipairs(workspace:GetDescendants()) do
            local n = v.Name:lower()
            if n:match("redemption") or n:match("gopay") or n:match("voucher") or n:match("claim") then
                return v
            end
        end
    end

    local obj = findRedemption()
    if obj then
        -- Teleport tepat ke objeknya
        local pos
        if obj:IsA("BasePart") then
            pos = obj.Position
        elseif obj:IsA("Model") then
            local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            pos = p and p.Position
        end
        if pos then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        end

        task.wait(0.5)

        -- Fire ProximityPrompt
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local par = v.Parent
                if par and (par.Name:lower():match("redemption") or par.Name:lower():match("gopay") or par.Name:lower():match("claim")) then
                    pcall(function() fireproximityprompt(v) end)
                    print("✅ ProximityPrompt fired: " .. v.ActionText)
                end
            end
        end
    end

    print("✅ Teleport selesai → " .. tostring(TARGET))
end

teleportToGopay()
