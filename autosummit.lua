--[[
  GOPAY SCRIPT TALAMAU
  BY ALFIAN
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

pcall(function()
    for _, g in ipairs(player.PlayerGui:GetChildren()) do
        if g.Name == "GPAlfian" then g:Destroy() end
    end
end)

-- ══════════════════════════════
-- ANTI-LAG SYSTEM
-- ══════════════════════════════
local function applyAntiLag()
    -- Render quality lowest
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
    pcall(function() settings().Rendering.EagerBulkExecution = true end)

    -- Shadows off
    pcall(function() workspace.GlobalShadows = false end)
    pcall(function() workspace.StreamingEnabled = false end)

    -- FPS cap lowest (15fps)
    pcall(function()
        settings().Rendering.FrameRateManager = 2
        settings().Rendering.MaxFrameRate = 15
    end)

    -- Lighting lowest
    pcall(function()
        local L = game:GetService("Lighting")
        L.GlobalShadows      = false
        L.FogEnd             = 100000
        L.Brightness         = 1
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

    -- Disable particles, effects, decals
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or
               v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Beam") then
                v.Enabled = false
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
            if v:IsA("SpecialMesh") then
                pcall(function() v.TextureId = "" end)
            end
        end
    end)

    -- Camera distance minimal
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = 70 end
    end)
end

-- ══════════════════════════════
-- CORE LOGIC
-- ══════════════════════════════
local TARGET = Vector3.new(-527.5, 1062.0, 333.4)
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
local C0  = Color3.fromRGB(0,   0,   0)    -- pure black
local C1  = Color3.fromRGB(8,   8,   8)    -- base bg
local C2  = Color3.fromRGB(14,  14,  14)   -- card
local C3  = Color3.fromRGB(22,  22,  22)   -- elevated
local C4  = Color3.fromRGB(35,  35,  35)   -- border
local C5  = Color3.fromRGB(55,  55,  55)   -- muted border
local W0  = Color3.fromRGB(255, 255, 255)  -- white
local W1  = Color3.fromRGB(220, 220, 220)  -- primary text
local W2  = Color3.fromRGB(140, 140, 140)  -- secondary text
local W3  = Color3.fromRGB(60,  60,  60)   -- dim text
local GR  = Color3.fromRGB(160, 255, 180)  -- success
local RD  = Color3.fromRGB(255, 100, 100)  -- error
local YL  = Color3.fromRGB(230, 200, 100)  -- warning

local function cr(p, r)
    local u = Instance.new("UICorner", p)
    u.CornerRadius = UDim.new(0, r or 6)
    return u
end
local function sk(p, c, t)
    local s = Instance.new("UIStroke", p)
    s.Color = c or C4
    s.Thickness = t or 1
    return s
end
local function pad(p, a, b, c, d)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop    = UDim.new(0, a or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, c or 0)
    u.PaddingRight  = UDim.new(0, d or 0)
end

local sg = Instance.new("ScreenGui")
sg.Name           = "GPAlfian"
sg.ResetOnSpawn   = false
sg.DisplayOrder   = 9999
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = player.PlayerGui

-- ROOT
local Root = Instance.new("Frame", sg)
Root.Size             = UDim2.new(0, 248, 0, 0)
Root.Position         = UDim2.new(0.5, -124, 0.5, -180)
Root.BackgroundColor3 = C1
Root.BorderSizePixel  = 0
Root.Active           = true
Root.Draggable        = true
Root.ClipsDescendants = false
Root.ZIndex           = 10
cr(Root, 10)
sk(Root, C4, 1)

-- top accent
local Accent = Instance.new("Frame", Root)
Accent.Size             = UDim2.new(1, -2, 0, 1)
Accent.Position         = UDim2.new(0, 1, 0, 1)
Accent.BackgroundColor3 = W1
Accent.BorderSizePixel  = 0
Accent.ZIndex           = 14
cr(Accent, 1)

-- SCROLL (auto layout)
local Scroll = Instance.new("ScrollingFrame", Root)
Scroll.Size               = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel    = 0
Scroll.ScrollBarThickness = 0
Scroll.CanvasSize         = UDim2.new(0, 0, 0, 0)
Scroll.ZIndex             = 11

local SL = Instance.new("UIListLayout", Scroll)
SL.SortOrder = Enum.SortOrder.LayoutOrder
SL.Padding   = UDim.new(0, 0)
pad(Scroll, 20, 20, 20, 20)

SL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local h = SL.AbsoluteContentSize.Y + 40
    Root.Size = UDim2.new(0, 248, 0, h)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, h)
end)

local function sp(order, h)
    local f = Instance.new("Frame", Scroll)
    f.LayoutOrder = order
    f.Size = UDim2.new(1, 0, 0, h or 8)
    f.BackgroundTransparency = 1
    f.ZIndex = 11
end

local function hl(order, col, h)
    local f = Instance.new("Frame", Scroll)
    f.LayoutOrder = order
    f.Size = UDim2.new(1, 0, 0, h or 1)
    f.BackgroundColor3 = col or C4
    f.BorderSizePixel = 0
    f.ZIndex = 12
end

local function lbl(order, txt, sz, col, font, h, align)
    local l = Instance.new("TextLabel", Scroll)
    l.LayoutOrder = order
    l.Size = UDim2.new(1, 0, 0, h or sz + 6)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = col or W1
    l.Font = font or Enum.Font.Gotham
    l.TextSize = sz or 11
    l.TextXAlignment = align or Enum.TextXAlignment.Center
    l.ZIndex = 12
    return l
end

-- ── HEADER ──────────────────────────────────
lbl(1,  "GOPAY SCRIPT TALAMAU", 13, W1, Enum.Font.GothamBold, 18)
lbl(2,  "BY ALFIAN",             9, W3, Enum.Font.GothamBold, 13)
sp(3, 4)
hl(4,  C4, 1)
sp(5, 10)

-- ── FEATURES ────────────────────────────────
lbl(6, "FEATURES", 8, W3, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)
sp(7, 2)

local feats = {
    "Teleport to GoPay Claim",
    "Fast Travel System",
    "Auto Scan Redemption Point",
    "Auto Fire Claim Prompt",
    "Anti-Lag + Low Graphics",
}

for i, f in ipairs(feats) do
    local row = Instance.new("Frame", Scroll)
    row.LayoutOrder = 7 + i
    row.Size = UDim2.new(1, 0, 0, 16)
    row.BackgroundTransparency = 1
    row.ZIndex = 12

    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0, 3, 0, 3)
    dot.Position = UDim2.new(0, 0, 0.5, -1)
    dot.BackgroundColor3 = W2
    dot.BorderSizePixel = 0
    dot.ZIndex = 13
    cr(dot, 3)

    local ftxt = Instance.new("TextLabel", row)
    ftxt.Size = UDim2.new(1, -10, 1, 0)
    ftxt.Position = UDim2.new(0, 10, 0, 0)
    ftxt.BackgroundTransparency = 1
    ftxt.Text = f
    ftxt.TextColor3 = W2
    ftxt.Font = Enum.Font.Gotham
    ftxt.TextSize = 10
    ftxt.TextXAlignment = Enum.TextXAlignment.Left
    ftxt.ZIndex = 13
end

sp(13, 12)
hl(14, C4, 1)
sp(15, 10)

-- ── STATUS ──────────────────────────────────
local StatRow = Instance.new("Frame", Scroll)
StatRow.LayoutOrder = 16
StatRow.Size = UDim2.new(1, 0, 0, 30)
StatRow.BackgroundColor3 = C2
StatRow.BorderSizePixel = 0
StatRow.ZIndex = 12
cr(StatRow, 6)
sk(StatRow, C4, 1)

local StatKey = Instance.new("TextLabel", StatRow)
StatKey.Size = UDim2.new(0, 70, 1, 0)
StatKey.Position = UDim2.new(0, 10, 0, 0)
StatKey.BackgroundTransparency = 1
StatKey.Text = "STATUS"
StatKey.TextColor3 = W3
StatKey.Font = Enum.Font.GothamBold
StatKey.TextSize = 8
StatKey.TextXAlignment = Enum.TextXAlignment.Left
StatKey.ZIndex = 13

local StatDot = Instance.new("Frame", StatRow)
StatDot.Size = UDim2.new(0, 5, 0, 5)
StatDot.Position = UDim2.new(0, 82, 0.5, -2)
StatDot.BackgroundColor3 = GR
StatDot.BorderSizePixel = 0
StatDot.ZIndex = 13
cr(StatDot, 5)

local StatVal = Instance.new("TextLabel", StatRow)
StatVal.Size = UDim2.new(1, -100, 1, 0)
StatVal.Position = UDim2.new(0, 94, 0, 0)
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
        StatVal.TextColor3 = GR
        StatDot.BackgroundColor3 = GR
    elseif col == "err" then
        StatVal.TextColor3 = RD
        StatDot.BackgroundColor3 = RD
    elseif col == "wait" then
        StatVal.TextColor3 = YL
        StatDot.BackgroundColor3 = YL
    else
        StatVal.TextColor3 = W1
        StatDot.BackgroundColor3 = W1
    end
end

sp(17, 10)

-- ── ANTI-LAG TOGGLE ─────────────────────────
local ALRow = Instance.new("Frame", Scroll)
ALRow.LayoutOrder = 18
ALRow.Size = UDim2.new(1, 0, 0, 30)
ALRow.BackgroundColor3 = C2
ALRow.BorderSizePixel = 0
ALRow.ZIndex = 12
cr(ALRow, 6)
sk(ALRow, C4, 1)

local ALKey = Instance.new("TextLabel", ALRow)
ALKey.Size = UDim2.new(0.6, 0, 1, 0)
ALKey.Position = UDim2.new(0, 10, 0, 0)
ALKey.BackgroundTransparency = 1
ALKey.Text = "ANTI-LAG  /  LOW GRAPHICS"
ALKey.TextColor3 = W3
ALKey.Font = Enum.Font.GothamBold
ALKey.TextSize = 8
ALKey.TextXAlignment = Enum.TextXAlignment.Left
ALKey.ZIndex = 13

local ALBtn = Instance.new("TextButton", ALRow)
ALBtn.Size = UDim2.new(0, 46, 0, 18)
ALBtn.Position = UDim2.new(1, -54, 0.5, -9)
ALBtn.BackgroundColor3 = C3
ALBtn.Text = "OFF"
ALBtn.TextColor3 = W3
ALBtn.Font = Enum.Font.GothamBold
ALBtn.TextSize = 9
ALBtn.BorderSizePixel = 0
ALBtn.ZIndex = 13
cr(ALBtn, 5)
sk(ALBtn, C5, 1)

ALBtn.MouseButton1Click:Connect(function()
    antilagOn = not antilagOn
    if antilagOn then
        applyAntiLag()
        ALBtn.Text = "ON"
        ALBtn.TextColor3 = W1
        sk(ALBtn, W3, 1)
        setStatus("ANTI-LAG ON", "done")
    else
        ALBtn.Text = "OFF"
        ALBtn.TextColor3 = W3
        sk(ALBtn, C5, 1)
        setStatus("READY", "done")
    end
end)

sp(19, 10)

-- ── START BUTTON ────────────────────────────
local StartBtn = Instance.new("TextButton", Scroll)
StartBtn.LayoutOrder = 20
StartBtn.Size = UDim2.new(1, 0, 0, 40)
StartBtn.BackgroundColor3 = C3
StartBtn.Text = "START"
StartBtn.TextColor3 = W1
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 13
StartBtn.BorderSizePixel = 0
StartBtn.ZIndex = 12
cr(StartBtn, 8)
sk(StartBtn, C5, 1)

-- letter-spacing via RichText
StartBtn.RichText = false

-- pulse
local pulsing = true
task.spawn(function()
    while true do
        task.wait(0)
        if not pulsing then task.wait(0.5) end
        if pulsing then
            TweenService:Create(StartBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            }):Play()
            task.wait(1.4)
        end
        if pulsing then
            TweenService:Create(StartBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = C3
            }):Play()
            task.wait(1.4)
        end
    end
end)

StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    pulsing = false
    TweenService:Create(StartBtn, TweenInfo.new(0.2), {BackgroundColor3 = C3}):Play()
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

sp(21, 6)

-- ── CLOSE ───────────────────────────────────
local ClsBtn = Instance.new("TextButton", Scroll)
ClsBtn.LayoutOrder = 22
ClsBtn.Size = UDim2.new(1, 0, 0, 18)
ClsBtn.BackgroundTransparency = 1
ClsBtn.Text = "CLOSE"
ClsBtn.TextColor3 = W3
ClsBtn.Font = Enum.Font.Gotham
ClsBtn.TextSize = 9
ClsBtn.ZIndex = 12
ClsBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
ClsBtn.MouseEnter:Connect(function() ClsBtn.TextColor3 = W2 end)
ClsBtn.MouseLeave:Connect(function() ClsBtn.TextColor3 = W3 end)

-- F9
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F9 then
        Root.Visible = not Root.Visible
    end
end)

-- auto apply antilag on load
task.spawn(function()
    task.wait(0.5)
    applyAntiLag()
    antilagOn = true
    ALBtn.Text = "ON"
    ALBtn.TextColor3 = W1
    sk(ALBtn, W3, 1)
end)

print("GoPay Script Talamau | By Alfian | F9 toggle")
