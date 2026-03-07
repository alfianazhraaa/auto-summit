--[[
  GOPAY TELEPORT PANEL
  Target: RedemptionPointBasepart
  Coords from Motion Log
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

pcall(function()
    for _, g in ipairs(player.PlayerGui:GetChildren()) do
        if g.Name == "GPPanel" then g:Destroy() end
    end
end)

-- ══════════════════════════════
-- CORE FUNCTIONS
-- ══════════════════════════════
local TARGET = Vector3.new(-527.5, 1062.0, 333.4)
local status_cb = nil -- callback to update UI

local function notif(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title=t, Text=m, Duration=3})
    end)
end

local function setStatus(msg, color)
    if status_cb then status_cb(msg, color) end
end

local function findRedemption()
    -- Priority: exact name match
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "RedemptionPointBasepart" then return v end
    end
    -- Fallback: pattern
    for _, v in ipairs(workspace:GetDescendants()) do
        local n = v.Name:lower()
        if n:match("redemption") or n:match("gopay") or n:match("voucher") or n:match("claim") then
            if v:IsA("BasePart") or v:IsA("Model") then return v end
        end
    end
    -- Fallback: scan BillboardGui text
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            for _, c in ipairs(v:GetDescendants()) do
                if (c:IsA("TextLabel") or c:IsA("TextButton")) then
                    local t = c.Text:lower()
                    if t:match("gopay") or t:match("claim") or t:match("voucher") then
                        local par = v.Parent
                        if par and (par:IsA("BasePart") or par:IsA("Model")) then return par end
                    end
                end
            end
        end
    end
    return nil
end

local function getObjPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return p and p.Position
    end
end

local function doTeleport(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    return true
end

local function firePrompts(obj)
    local fired = 0
    -- Check object itself and descendants
    local targets = {obj}
    if obj then
        for _, v in ipairs(obj:GetDescendants()) do
            table.insert(targets, v)
        end
        -- Also check parent
        if obj.Parent then
            for _, v in ipairs(obj.Parent:GetDescendants()) do
                table.insert(targets, v)
            end
        end
    end
    -- Also scan whole workspace for claim prompts
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local n = (v.ActionText or ""):lower()
            local pn = (v.Parent and v.Parent.Name or ""):lower()
            if n:match("claim") or n:match("voucher") or n:match("gopay") or
               pn:match("redemption") or pn:match("gopay") or pn:match("claim") then
                pcall(function() fireproximityprompt(v) end)
                fired = fired + 1
            end
        end
    end
    return fired
end

-- MAIN SEQUENCE
local running = false
local function runSequence(useLog, useScan, autoFire)
    if running then return end
    running = true

    task.spawn(function()
        -- STEP 1: Teleport to log coordinates
        if useLog then
            setStatus("📍 Teleport ke koordinat log...", "yellow")
            task.wait(0.3)
            local ok = doTeleport(TARGET)
            if ok then
                setStatus("✓ Tiba di " .. string.format("(%.1f, %.1f, %.1f)", TARGET.X, TARGET.Y, TARGET.Z), "green")
                notif("Step 1", "Teleport ke koordinat log")
            else
                setStatus("⚠ Gagal teleport", "red")
                running = false
                return
            end
            task.wait(0.8)
        end

        -- STEP 2: Scan & teleport ke objek
        if useScan then
            setStatus("🔍 Mencari RedemptionPoint...", "yellow")
            task.wait(0.5)
            local obj = findRedemption()
            if obj then
                local pos = getObjPos(obj)
                if pos then
                    doTeleport(pos)
                    setStatus("✓ Ditemukan: " .. obj.Name, "green")
                    notif("Step 2", "Objek: " .. obj.Name)
                    task.wait(0.6)

                    -- STEP 3: Fire prompt
                    if autoFire then
                        setStatus("💳 Firing Claim Voucher...", "cyan")
                        task.wait(0.4)
                        local fired = firePrompts(obj)
                        if fired > 0 then
                            setStatus("✅ Voucher diklaim! (" .. fired .. " prompt)", "green")
                            notif("GoPay!", "Claim Voucher berhasil ✓")
                        else
                            setStatus("⚠ Prompt tidak ditemukan", "red")
                            notif("GoPay", "Coba klik manual di objek")
                        end
                    end
                else
                    setStatus("⚠ Posisi objek tidak valid", "red")
                end
            else
                setStatus("⚠ RedemptionPoint tidak ditemukan", "red")
                notif("Scan", "Objek tidak ada di map ini")
            end
        end

        running = false
    end)
end

-- ══════════════════════════════
-- GUI
-- ══════════════════════════════
local BK = Color3.fromRGB(8, 8, 8)
local DK = Color3.fromRGB(15, 15, 15)
local CD = Color3.fromRGB(23, 23, 23)
local BD = Color3.fromRGB(38, 38, 38)
local W1 = Color3.fromRGB(220, 220, 220)
local G1 = Color3.fromRGB(70, 70, 70)
local GR = Color3.fromRGB(70, 200, 100)
local RD = Color3.fromRGB(210, 70, 70)
local YL = Color3.fromRGB(210, 185, 50)
local CY = Color3.fromRGB(0, 185, 230)
local GP = Color3.fromRGB(0, 165, 210) -- gopay blue

local function cr(p, r)
    local u = Instance.new("UICorner", p)
    u.CornerRadius = UDim.new(0, r or 8)
end
local function sk(p, c, t)
    local s = Instance.new("UIStroke", p)
    s.Color = c or BD
    s.Thickness = t or 1
end

local sg = Instance.new("ScreenGui")
sg.Name           = "GPPanel"
sg.ResetOnSpawn   = false
sg.DisplayOrder   = 9999
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = player.PlayerGui

-- MAIN FRAME
local F = Instance.new("Frame", sg)
F.Size             = UDim2.new(0, 240, 0, 400)
F.Position         = UDim2.new(0, 16, 0, 70)
F.BackgroundColor3 = BK
F.BorderSizePixel  = 0
F.Active           = true
F.Draggable        = true
F.ZIndex           = 10
cr(F, 11) sk(F, BD, 1)

-- TOPBAR
local TB = Instance.new("Frame", F)
TB.Size             = UDim2.new(1, 0, 0, 38)
TB.BackgroundColor3 = DK
TB.BorderSizePixel  = 0
TB.ZIndex           = 11
cr(TB, 11)
local TBF = Instance.new("Frame", TB)
TBF.Size            = UDim2.new(1, 0, 0, 11)
TBF.Position        = UDim2.new(0, 0, 1, -11)
TBF.BackgroundColor3= DK
TBF.BorderSizePixel = 0
TBF.ZIndex          = 11

-- Gopay logo dot
local GPDot = Instance.new("Frame", TB)
GPDot.Size            = UDim2.new(0, 8, 0, 8)
GPDot.Position        = UDim2.new(0, 10, 0.5, -4)
GPDot.BackgroundColor3= GP
GPDot.BorderSizePixel = 0
GPDot.ZIndex          = 12
cr(GPDot, 8)

local TLbl = Instance.new("TextLabel", TB)
TLbl.Size               = UDim2.new(1, -50, 1, 0)
TLbl.Position           = UDim2.new(0, 24, 0, 0)
TLbl.BackgroundTransparency = 1
TLbl.Text               = "GOPAY CLAIMER"
TLbl.TextColor3         = W1
TLbl.Font               = Enum.Font.GothamBold
TLbl.TextSize           = 12
TLbl.TextXAlignment     = Enum.TextXAlignment.Left
TLbl.ZIndex             = 12

local XB = Instance.new("TextButton", TB)
XB.Size             = UDim2.new(0, 22, 0, 22)
XB.Position         = UDim2.new(1, -26, 0.5, -11)
XB.Text             = "✕"
XB.TextColor3       = G1
XB.BackgroundColor3 = CD
XB.Font             = Enum.Font.GothamBold
XB.TextSize         = 10
XB.BorderSizePixel  = 0
XB.ZIndex           = 12
cr(XB, 5)
XB.MouseButton1Click:Connect(function() sg:Destroy() end)

-- COORD CARD
local CoordCard = Instance.new("Frame", F)
CoordCard.Size             = UDim2.new(1, -20, 0, 54)
CoordCard.Position         = UDim2.new(0, 10, 0, 46)
CoordCard.BackgroundColor3 = CD
CoordCard.BorderSizePixel  = 0
CoordCard.ZIndex           = 11
cr(CoordCard, 8) sk(CoordCard, BD, 1)

local CoordTop = Instance.new("TextLabel", CoordCard)
CoordTop.Size               = UDim2.new(1, -10, 0, 16)
CoordTop.Position           = UDim2.new(0, 8, 0, 5)
CoordTop.BackgroundTransparency = 1
CoordTop.Text               = "TARGET KOORDINAT (dari Motion Log)"
CoordTop.TextColor3         = G1
CoordTop.Font               = Enum.Font.GothamBold
CoordTop.TextSize           = 8
CoordTop.TextXAlignment     = Enum.TextXAlignment.Left
CoordTop.ZIndex             = 12

local CoordVal = Instance.new("TextLabel", CoordCard)
CoordVal.Size               = UDim2.new(1, -10, 0, 22)
CoordVal.Position           = UDim2.new(0, 8, 0, 22)
CoordVal.BackgroundTransparency = 1
CoordVal.Text               = string.format("X: %.1f   Y: %.1f   Z: %.1f", TARGET.X, TARGET.Y, TARGET.Z)
CoordVal.TextColor3         = CY
CoordVal.Font               = Enum.Font.Code
CoordVal.TextSize           = 12
CoordVal.TextXAlignment     = Enum.TextXAlignment.Left
CoordVal.ZIndex             = 12

-- STATUS CARD
local StatCard = Instance.new("Frame", F)
StatCard.Size             = UDim2.new(1, -20, 0, 40)
StatCard.Position         = UDim2.new(0, 10, 0, 108)
StatCard.BackgroundColor3 = CD
StatCard.BorderSizePixel  = 0
StatCard.ZIndex           = 11
cr(StatCard, 8) sk(StatCard, BD, 1)

local StatIcon = Instance.new("TextLabel", StatCard)
StatIcon.Size               = UDim2.new(0, 30, 1, 0)
StatIcon.Position           = UDim2.new(0, 6, 0, 0)
StatIcon.BackgroundTransparency = 1
StatIcon.Text               = "◉"
StatIcon.TextColor3         = G1
StatIcon.Font               = Enum.Font.GothamBold
StatIcon.TextSize           = 14
StatIcon.TextXAlignment     = Enum.TextXAlignment.Center
StatIcon.ZIndex             = 12

local StatLbl = Instance.new("TextLabel", StatCard)
StatLbl.Size               = UDim2.new(1, -42, 1, 0)
StatLbl.Position           = UDim2.new(0, 36, 0, 0)
StatLbl.BackgroundTransparency = 1
StatLbl.Text               = "Siap — pilih mode di bawah"
StatLbl.TextColor3         = G1
StatLbl.Font               = Enum.Font.Gotham
StatLbl.TextSize           = 10
StatLbl.TextXAlignment     = Enum.TextXAlignment.Left
StatLbl.TextTruncate       = Enum.TextTruncate.AtEnd
StatLbl.ZIndex             = 12

-- update status callback
status_cb = function(msg, col)
    StatLbl.Text = msg
    local colors = {
        green  = GR,
        red    = RD,
        yellow = YL,
        cyan   = CY,
        white  = W1,
    }
    StatLbl.TextColor3 = colors[col] or W1
    StatIcon.TextColor3 = colors[col] or G1
end

-- DIVIDER + LABEL
local function divider(y, txt)
    local d = Instance.new("Frame", F)
    d.Size             = UDim2.new(1, -20, 0, 1)
    d.Position         = UDim2.new(0, 10, 0, y)
    d.BackgroundColor3 = BD
    d.BorderSizePixel  = 0
    d.ZIndex           = 11

    if txt then
        local l = Instance.new("TextLabel", F)
        l.Size               = UDim2.new(1, -20, 0, 14)
        l.Position           = UDim2.new(0, 10, 0, y + 4)
        l.BackgroundTransparency = 1
        l.Text               = txt
        l.TextColor3         = Color3.fromRGB(42, 42, 42)
        l.Font               = Enum.Font.GothamBold
        l.TextSize           = 9
        l.TextXAlignment     = Enum.TextXAlignment.Left
        l.ZIndex             = 11
    end
end

divider(156, "MODE")

-- CHECKBOX helper
local function mkCheck(y, label, default)
    local row = Instance.new("Frame", F)
    row.Size               = UDim2.new(1, -20, 0, 22)
    row.Position           = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.ZIndex             = 11

    local box = Instance.new("TextButton", row)
    box.Size               = UDim2.new(0, 16, 0, 16)
    box.Position           = UDim2.new(0, 0, 0.5, -8)
    box.BackgroundColor3   = default and GP or CD
    box.Text               = default and "✓" or ""
    box.TextColor3         = BK
    box.Font               = Enum.Font.GothamBold
    box.TextSize           = 10
    box.BorderSizePixel    = 0
    box.ZIndex             = 12
    cr(box, 4) sk(box, BD, 1)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(1, -22, 1, 0)
    lbl.Position           = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = G1
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 10
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 11

    local on = default
    box.MouseButton1Click:Connect(function()
        on = not on
        box.BackgroundColor3 = on and GP or CD
        box.Text             = on and "✓" or ""
        lbl.TextColor3       = on and W1 or G1
    end)
    return function() return on end
end

local getUseLog  = mkCheck(174, "Teleport ke koordinat log dulu",   true)
local getUseScan = mkCheck(198, "Scan & teleport ke objek GoPay",   true)
local getAutoFire= mkCheck(222, "Auto fire Claim Voucher prompt",    true)

divider(250, "ACTIONS")

-- BUTTONS
local function mkBtn(y, txt, h, bg)
    local b = Instance.new("TextButton", F)
    b.Size             = UDim2.new(1, -20, 0, h or 34)
    b.Position         = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = bg or CD
    b.Text             = txt
    b.TextColor3       = W1
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 12
    b.BorderSizePixel  = 0
    b.ZIndex           = 11
    cr(b, 8) sk(b, BD, 1)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = BD}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = bg or CD}):Play()
    end)
    return b
end

local RunBtn    = mkBtn(264, "▶  JALANKAN SEQUENCE",    36, Color3.fromRGB(0, 100, 140))
local TpOnlyBtn = mkBtn(306, "📍 TELEPORT LOG COORDS",  28, CD)
local ScanBtn   = mkBtn(340, "🔍 SCAN & TP KE OBJEK",   28, CD)
local FireBtn   = mkBtn(374, "💳 FIRE CLAIM PROMPT",     28, Color3.fromRGB(0, 60, 90))

-- BUTTON ACTIONS
RunBtn.MouseButton1Click:Connect(function()
    if running then return end
    runSequence(getUseLog(), getUseScan(), getAutoFire())
end)

TpOnlyBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    setStatus("📍 Teleport ke koordinat...", "yellow")
    task.spawn(function()
        local ok = doTeleport(TARGET)
        if ok then
            setStatus("✓ Tiba di koordinat log", "green")
            notif("Teleport", string.format("(%.1f, %.1f, %.1f)", TARGET.X, TARGET.Y, TARGET.Z))
        else
            setStatus("⚠ Gagal teleport", "red")
        end
        running = false
    end)
end)

ScanBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    setStatus("🔍 Scanning workspace...", "yellow")
    task.spawn(function()
        task.wait(0.3)
        local obj = findRedemption()
        if obj then
            local pos = getObjPos(obj)
            if pos then
                doTeleport(pos)
                setStatus("✓ " .. obj.Name, "green")
                notif("Ditemukan", obj.Name)
            end
        else
            setStatus("⚠ Objek tidak ditemukan", "red")
        end
        running = false
    end)
end)

FireBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    setStatus("💳 Firing prompts...", "cyan")
    task.spawn(function()
        local obj = findRedemption()
        local fired = firePrompts(obj)
        if fired > 0 then
            setStatus("✅ " .. fired .. " prompt fired!", "green")
            notif("GoPay!", "Claim Voucher fired ✓")
        else
            setStatus("⚠ Tidak ada prompt ditemukan", "red")
        end
        running = false
    end)
end)

-- F9 TOGGLE
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F9 then
        F.Visible = not F.Visible
    end
end)

print("✅ GoPay Claimer Panel | F9 toggle")
