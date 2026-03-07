--[[
  GOPAY SCRIPT TALAMAU
  BY ALFIAN
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

pcall(function()
    for _, g in ipairs(player.PlayerGui:GetChildren()) do
        if g.Name == "GPAlfian" then g:Destroy() end
    end
end)

-- ══════════════════════════════
-- ANTI-LAG
-- ══════════════════════════════
local function applyAntiLag()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
    pcall(function() workspace.GlobalShadows = false end)
    pcall(function()
        settings().Rendering.FrameRateManager = 2
        settings().Rendering.MaxFrameRate = 15
    end)
    pcall(function()
        local L = game:GetService("Lighting")
        L.GlobalShadows = false
        L.Brightness = 1
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
        for _, v in ipairs(L:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or
               v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or
               v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
    end)
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or
               v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Beam") then
                v.Enabled = false
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end)
end

-- ══════════════════════════════
-- CORE
-- ══════════════════════════════
local TARGET  = Vector3.new(-527.5, 1062.0, 333.4)
local running = false
local statusCB = nil
local antilagOn = false

local function notif(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = t, Text = m, Duration = 3
        })
    end)
end

local function setStatus(msg, col)
    if statusCB then statusCB(msg, col) end
end

local function doTeleport(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    return true
end

local function findRedemption()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "RedemptionPointBasepart" then return v end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        local n = v.Name:lower()
        if n:match("redemption") or n:match("gopay") or
           n:match("voucher") or n:match("claim") then
            if v:IsA("BasePart") or v:IsA("Model") then return v end
        end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            for _, c in ipairs(v:GetDescendants()) do
                if c:IsA("TextLabel") or c:IsA("TextButton") then
                    local t = c.Text:lower()
                    if t:match("gopay") or t:match("claim") or t:match("voucher") then
                        local par = v.Parent
                        if par and (par:IsA("BasePart") or par:IsA("Model")) then
                            return par
                        end
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

local function firePrompts()
    local fired = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local n  = (v.ActionText or ""):lower()
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

local function runSequence()
    if running then return end
    running = true
    task.spawn(function()
        setStatus("CONNECTING", "wait")
        task.wait(0.4)
        doTeleport(TARGET)
        task.wait(0.8)

        setStatus("SCANNING", "wait")
        task.wait(0.4)
        local obj = findRedemption()

        if obj then
            local pos = getObjPos(obj)
            if pos then
                doTeleport(pos)
                task.wait(0.6)
            end
            setStatus("CLAIMING", "wait")
            task.wait(0.4)
            local fired = firePrompts()
            if fired > 0 then
                setStatus("SUCCESS", "done")
                notif("GoPay Talamau", "Claim berhasil")
            else
                setStatus("PROMPT NOT FOUND", "err")
            end
        else
            setStatus("OBJECT NOT FOUND", "err")
            notif("GoPay", "Objek tidak ditemukan")
        end
        running = false
    end)
end

-- ══════════════════════════════
-- GUI
-- ══════════════════════════════
local C1  = Color3.fromRGB(8,   8,   8)
local C2  = Color3.fromRGB(14,  14,  14)
local C3  = Color3.fromRGB(22,  22,  22)
local C4  = Color3.fromRGB(35,  35,  35)
local C5  = Color3.fromRGB(55,  55,  55)
local W1  = Color3.fromRGB(220, 220, 220)
local W2  = Color3.fromRGB(140, 140, 140)
local W3  = Color3.fromRGB(55,  55,  55)
local GR  = Color3.fromRGB(150, 255, 170)
local RD  = Color3.fromRGB(255, 100, 100)
local YL  = Color3.fromRGB(230, 200, 100)

local function cr(p, r)
    local u = Instance.new("UICorner", p)
    u.CornerRadius = UDim.new(0, r or 6)
end
local function sk(p, c, t)
    local s = Instance.new("UIStroke", p)
    s.Color = c or C4
    s.Thickness = t or 1
    return s
end

-- SCREEN GUI
local sg = Instance.new("ScreenGui")
sg.Name           = "GPAlfian"
sg.ResetOnSpawn   = false
sg.DisplayOrder   = 9999
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = player.PlayerGui

-- MAIN FRAME — draggable, no fixed position tricks
local F = Instance.new("Frame", sg)
F.Size             = UDim2.new(0, 240, 0, 340)
F.Position         = UDim2.new(0.5, -120, 0.5, -170)
F.BackgroundColor3 = C1
F.BorderSizePixel  = 0
F.Active           = true
F.Draggable        = true
F.ZIndex           = 10
cr(F, 10)
sk(F, C4, 1)

-- top accent line
local Accent = Instance.new("Frame", F)
Accent.Size             = UDim2.new(1, -2, 0, 1)
Accent.Position         = UDim2.new(0, 1, 0, 1)
Accent.BackgroundColor3 = W1
Accent.BorderSizePixel  = 0
Accent.ZIndex           = 14
cr(Accent, 1)

-- ── TOPBAR ──────────────────────────────────
local TB = Instance.new("Frame", F)
TB.Size             = UDim2.new(1, 0, 0, 42)
TB.Position         = UDim2.new(0, 0, 0, 0)
TB.BackgroundColor3 = C2
TB.BorderSizePixel  = 0
TB.ZIndex           = 11
cr(TB, 10)
-- fix bottom corners of topbar
local TBFix = Instance.new("Frame", TB)
TBFix.Size             = UDim2.new(1, 0, 0, 10)
TBFix.Position         = UDim2.new(0, 0, 1, -10)
TBFix.BackgroundColor3 = C2
TBFix.BorderSizePixel  = 0
TBFix.ZIndex           = 11

-- title inside topbar
local TTitle = Instance.new("TextLabel", TB)
TTitle.Size               = UDim2.new(1, -50, 0, 16)
TTitle.Position           = UDim2.new(0, 14, 0, 8)
TTitle.BackgroundTransparency = 1
TTitle.Text               = "GOPAY SCRIPT TALAMAU"
TTitle.TextColor3         = W1
TTitle.Font               = Enum.Font.GothamBold
TTitle.TextSize           = 11
TTitle.TextXAlignment     = Enum.TextXAlignment.Left
TTitle.ZIndex             = 13

local TBy = Instance.new("TextLabel", TB)
TBy.Size               = UDim2.new(1, -50, 0, 12)
TBy.Position           = UDim2.new(0, 14, 0, 26)
TBy.BackgroundTransparency = 1
TBy.Text               = "BY ALFIAN"
TBy.TextColor3         = W3
TBy.Font               = Enum.Font.GothamBold
TBy.TextSize           = 8
TBy.TextXAlignment     = Enum.TextXAlignment.Left
TBy.ZIndex             = 13

-- CLOSE BUTTON inside topbar
local XBtn = Instance.new("TextButton", TB)
XBtn.Size             = UDim2.new(0, 24, 0, 24)
XBtn.Position         = UDim2.new(1, -32, 0.5, -12)
XBtn.BackgroundColor3 = C3
XBtn.Text             = "X"
XBtn.TextColor3       = W3
XBtn.Font             = Enum.Font.GothamBold
XBtn.TextSize         = 10
XBtn.BorderSizePixel  = 0
XBtn.ZIndex           = 14
cr(XBtn, 6)
sk(XBtn, C5, 1)

XBtn.MouseEnter:Connect(function()
    TweenService:Create(XBtn, TweenInfo.new(0.15), {TextColor3 = W1}):Play()
end)
XBtn.MouseLeave:Connect(function()
    TweenService:Create(XBtn, TweenInfo.new(0.15), {TextColor3 = W3}):Play()
end)
XBtn.MouseButton1Click:Connect(function()
    TweenService:Create(F, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 240, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.25, function() sg:Destroy() end)
end)

-- separator under topbar
local Sep = Instance.new("Frame", F)
Sep.Size             = UDim2.new(1, -28, 0, 1)
Sep.Position         = UDim2.new(0, 14, 0, 42)
Sep.BackgroundColor3 = C4
Sep.BorderSizePixel  = 0
Sep.ZIndex           = 11

-- ── BODY ────────────────────────────────────
local Body = Instance.new("Frame", F)
Body.Size             = UDim2.new(1, -28, 1, -56)
Body.Position         = UDim2.new(0, 14, 0, 50)
Body.BackgroundTransparency = 1
Body.ZIndex           = 11

local BL = Instance.new("UIListLayout", Body)
BL.SortOrder = Enum.SortOrder.LayoutOrder
BL.Padding   = UDim.new(0, 7)

local function sp(order, h)
    local s = Instance.new("Frame", Body)
    s.LayoutOrder = order
    s.Size = UDim2.new(1, 0, 0, h or 6)
    s.BackgroundTransparency = 1
    s.ZIndex = 11
end

local function hl(order)
    local l = Instance.new("Frame", Body)
    l.LayoutOrder = order
    l.Size = UDim2.new(1, 0, 0, 1)
    l.BackgroundColor3 = C4
    l.BorderSizePixel = 0
    l.ZIndex = 12
end

local function seclbl(order, txt)
    local l = Instance.new("TextLabel", Body)
    l.LayoutOrder = order
    l.Size = UDim2.new(1, 0, 0, 12)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = W3
    l.Font = Enum.Font.GothamBold
    l.TextSize = 8
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 12
end

-- FEATURES
seclbl(1, "FEATURES")

local feats = {
    "Teleport to GoPay Claim",
    "Fast Travel System",
    "Auto Scan Redemption Point",
    "Auto Fire Claim Prompt",
    "Anti-Lag + Low Graphics",
}
for i, feat in ipairs(feats) do
    local row = Instance.new("Frame", Body)
    row.LayoutOrder = 1 + i
    row.Size = UDim2.new(1, 0, 0, 14)
    row.BackgroundTransparency = 1
    row.ZIndex = 12

    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0, 3, 0, 3)
    dot.Position = UDim2.new(0, 0, 0.5, -1)
    dot.BackgroundColor3 = W3
    dot.BorderSizePixel = 0
    dot.ZIndex = 13
    cr(dot, 3)

    local ft = Instance.new("TextLabel", row)
    ft.Size = UDim2.new(1, -10, 1, 0)
    ft.Position = UDim2.new(0, 10, 0, 0)
    ft.BackgroundTransparency = 1
    ft.Text = feat
    ft.TextColor3 = W2
    ft.Font = Enum.Font.Gotham
    ft.TextSize = 10
    ft.TextXAlignment = Enum.TextXAlignment.Left
    ft.ZIndex = 13
end

hl(8)

-- STATUS ROW
local StatCard = Instance.new("Frame", Body)
StatCard.LayoutOrder = 9
StatCard.Size = UDim2.new(1, 0, 0, 30)
StatCard.BackgroundColor3 = C2
StatCard.BorderSizePixel = 0
StatCard.ZIndex = 12
cr(StatCard, 6)
sk(StatCard, C4, 1)

local StatLbl = Instance.new("TextLabel", StatCard)
StatLbl.Size = UDim2.new(0, 60, 1, 0)
StatLbl.Position = UDim2.new(0, 10, 0, 0)
StatLbl.BackgroundTransparency = 1
StatLbl.Text = "STATUS"
StatLbl.TextColor3 = W3
StatLbl.Font = Enum.Font.GothamBold
StatLbl.TextSize = 8
StatLbl.TextXAlignment = Enum.TextXAlignment.Left
StatLbl.ZIndex = 13

local StatDot = Instance.new("Frame", StatCard)
StatDot.Size = UDim2.new(0, 5, 0, 5)
StatDot.Position = UDim2.new(0, 74, 0.5, -2)
StatDot.BackgroundColor3 = GR
StatDot.BorderSizePixel = 0
StatDot.ZIndex = 13
cr(StatDot, 5)

local StatVal = Instance.new("TextLabel", StatCard)
StatVal.Size = UDim2.new(1, -90, 1, 0)
StatVal.Position = UDim2.new(0, 86, 0, 0)
StatVal.BackgroundTransparency = 1
StatVal.Text = "READY"
StatVal.TextColor3 = GR
StatVal.Font = Enum.Font.GothamBold
StatVal.TextSize = 10
StatVal.TextXAlignment = Enum.TextXAlignment.Left
StatVal.ZIndex = 13

statusCB = function(msg, col)
    StatVal.Text = msg
    if col == "done" then
        StatVal.TextColor3 = GR StatDot.BackgroundColor3 = GR
    elseif col == "err" then
        StatVal.TextColor3 = RD StatDot.BackgroundColor3 = RD
    elseif col == "wait" then
        StatVal.TextColor3 = YL StatDot.BackgroundColor3 = YL
    else
        StatVal.TextColor3 = W1 StatDot.BackgroundColor3 = W1
    end
end

-- ANTI-LAG ROW
local ALCard = Instance.new("Frame", Body)
ALCard.LayoutOrder = 10
ALCard.Size = UDim2.new(1, 0, 0, 30)
ALCard.BackgroundColor3 = C2
ALCard.BorderSizePixel = 0
ALCard.ZIndex = 12
cr(ALCard, 6)
sk(ALCard, C4, 1)

local ALLbl = Instance.new("TextLabel", ALCard)
ALLbl.Size = UDim2.new(0.65, 0, 1, 0)
ALLbl.Position = UDim2.new(0, 10, 0, 0)
ALLbl.BackgroundTransparency = 1
ALLbl.Text = "ANTI-LAG / LOW GRAPHICS"
ALLbl.TextColor3 = W3
ALLbl.Font = Enum.Font.GothamBold
ALLbl.TextSize = 8
ALLbl.TextXAlignment = Enum.TextXAlignment.Left
ALLbl.ZIndex = 13

local ALBtn = Instance.new("TextButton", ALCard)
ALBtn.Size = UDim2.new(0, 40, 0, 18)
ALBtn.Position = UDim2.new(1, -46, 0.5, -9)
ALBtn.BackgroundColor3 = C3
ALBtn.Text = "OFF"
ALBtn.TextColor3 = W3
ALBtn.Font = Enum.Font.GothamBold
ALBtn.TextSize = 9
ALBtn.BorderSizePixel = 0
ALBtn.ZIndex = 13
cr(ALBtn, 5)
local ALStroke = sk(ALBtn, C5, 1)

ALBtn.MouseButton1Click:Connect(function()
    antilagOn = not antilagOn
    if antilagOn then
        applyAntiLag()
        ALBtn.Text = "ON"
        ALBtn.TextColor3 = W1
        ALStroke.Color = W2
        setStatus("ANTI-LAG ACTIVE", "done")
    else
        ALBtn.Text = "OFF"
        ALBtn.TextColor3 = W3
        ALStroke.Color = C5
        setStatus("READY", "done")
    end
end)

-- START BUTTON
local StartBtn = Instance.new("TextButton", Body)
StartBtn.LayoutOrder = 11
StartBtn.Size = UDim2.new(1, 0, 0, 38)
StartBtn.BackgroundColor3 = C3
StartBtn.Text = "START"
StartBtn.TextColor3 = W1
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 13
StartBtn.BorderSizePixel = 0
StartBtn.ZIndex = 12
cr(StartBtn, 8)
local StartStroke = sk(StartBtn, C5, 1)

-- idle pulse
local pulsing = true
task.spawn(function()
    while true do
        task.wait(0.05)
        if pulsing then
            TweenService:Create(StartBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
            task.wait(1.4)
            if pulsing then
                TweenService:Create(StartBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundColor3 = C3
                }):Play()
                task.wait(1.4)
            end
        else
            task.wait(0.2)
        end
    end
end)

StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    pulsing = false
    TweenService:Create(StartBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C3
    }):Play()
    StartBtn.Text = "RUNNING"
    StartBtn.TextColor3 = YL
    runSequence()
    task.spawn(function()
        while running do task.wait(0.1) end
        task.wait(0.3)
        StartBtn.Text = "START"
        StartBtn.TextColor3 = W1
        pulsing = true
    end)
end)

-- F9 TOGGLE
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F9 then
        F.Visible = not F.Visible
    end
end)

-- AUTO ANTILAG ON LOAD
task.spawn(function()
    task.wait(0.5)
    applyAntiLag()
    antilagOn = true
    ALBtn.Text = "ON"
    ALBtn.TextColor3 = W1
    ALStroke.Color = W2
end)

print("GoPay Script Talamau | By Alfian | F9 toggle")
