--[[
  SUMMIT + GOPAY AUTO v6
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

pcall(function()
    for _, g in ipairs(player.PlayerGui:GetChildren()) do
        if g.Name == "SL6" then g:Destroy() end
    end
end)

-- ANTI-LAG
pcall(function() settings().Rendering.QualityLevel = 1 end)
pcall(function() workspace.GlobalShadows = false end)
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
end)

-- TELEPORT
local function tp(pos)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
end

local function getPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return p and p.Position
    end
end

local function notif(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title=t, Text=m, Duration=3})
    end)
end

-- DETECT CP
local function detectCP()
    local list, seen = {}, {}
    local function isCP(name)
        local n = name:lower()
        if tonumber(n) then return true end
        return n:match("check") or n:match("cp") or n:match("stage") or
               n:match("summit") or n:match("finish") or n:match("waypoint") or
               n:match("gate") or n:match("flag") or n:match("touch") or
               n:match("zone") or n:match("point") or n:match("goal") or
               n:match("node") or n:match("mark") or n:match("step") or
               n:match("level") or n:match("ring") or n:match("pad") or
               n:match("plate") or n:match("spawn") or n:match("end") or n:match("start")
    end
    local function add(obj)
        local pos = getPos(obj)
        if not pos then return end
        if obj:IsA("BasePart") then
            local s = obj.Size
            if s.X > 500 or s.Z > 500 then return end
        end
        local k = math.round(pos.X/4).."_"..math.round(pos.Y/4).."_"..math.round(pos.Z/4)
        if seen[k] then return end
        seen[k] = true
        table.insert(list, obj)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and isCP(obj.Name) then add(obj) end
    end
    table.sort(list, function(a, b)
        local nA = tonumber(a.Name:match("%d+") or a.Name) or 9999
        local nB = tonumber(b.Name:match("%d+") or b.Name) or 9999
        if nA ~= nB then return nA < nB end
        local function y(o)
            if o:IsA("BasePart") then return o.Position.Y end
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            return p and p.Position.Y or 0
        end
        return y(a) < y(b)
    end)
    return list
end

-- DETECT GOPAY
local function findGopay()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:match("gopay") or n:match("go_pay") or n:match("voucher") or
           n:match("gpay") or n:match("reward") or n:match("claim") then
            local pos = getPos(obj)
            if pos then return obj, pos end
        end
    end
    -- fallback: scan BillboardGui / SurfaceGui text
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local t = child.Text:lower()
                    if t:match("gopay") or t:match("voucher") or t:match("claim") then
                        local parent = obj.Parent
                        local pos = getPos(parent)
                        if pos then return parent, pos end
                    end
                end
            end
        end
    end
    return nil, nil
end

-- ══════════════════════════════
-- GUI
-- ══════════════════════════════
local W1 = Color3.fromRGB(225,225,225)
local G1 = Color3.fromRGB(70,70,70)
local BK = Color3.fromRGB(10,10,10)
local DK = Color3.fromRGB(17,17,17)
local CD = Color3.fromRGB(25,25,25)
local BD = Color3.fromRGB(38,38,38)
local GR = Color3.fromRGB(80,200,100)
local RD = Color3.fromRGB(210,70,70)
local YL = Color3.fromRGB(210,180,50)
local CY = Color3.fromRGB(0,185,230)  -- gopay cyan

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 7)
end
local function stroke(p, c, t)
    local s = Instance.new("UIStroke", p)
    s.Color = c or BD
    s.Thickness = t or 1
end

local sg = Instance.new("ScreenGui")
sg.Name = "SL6"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = player:WaitForChild("PlayerGui")

-- MAIN
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 230, 0, 370)
M.Position = UDim2.new(0.5, -115, 0.5, -185)
M.BackgroundColor3 = BK
M.BorderSizePixel = 0
M.Active = true
M.Draggable = true
M.Parent = sg
corner(M, 11)
stroke(M, BD, 1)

-- TOPBAR
local Top = Instance.new("Frame", M)
Top.Size = UDim2.new(1, 0, 0, 36)
Top.BackgroundColor3 = DK
Top.BorderSizePixel = 0
corner(Top, 11)
local TopFix = Instance.new("Frame", Top)
TopFix.Size = UDim2.new(1, 0, 0, 11)
TopFix.Position = UDim2.new(0, 0, 1, -11)
TopFix.BackgroundColor3 = DK
TopFix.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel", Top)
TitleLbl.Size = UDim2.new(1, -44, 1, 0)
TitleLbl.Position = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⛰  SUMMIT LITE"
TitleLbl.TextColor3 = W1
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 12
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local XBtn = Instance.new("TextButton", Top)
XBtn.Size = UDim2.new(0, 22, 0, 22)
XBtn.Position = UDim2.new(1, -28, 0.5, -11)
XBtn.Text = "✕"
XBtn.TextColor3 = G1
XBtn.BackgroundColor3 = CD
XBtn.Font = Enum.Font.GothamBold
XBtn.TextSize = 10
XBtn.BorderSizePixel = 0
corner(XBtn, 5)
XBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- STATUS
local StatLbl = Instance.new("TextLabel", M)
StatLbl.Size = UDim2.new(1, -20, 0, 16)
StatLbl.Position = UDim2.new(0, 10, 0, 44)
StatLbl.BackgroundTransparency = 1
StatLbl.Text = "Mendeteksi..."
StatLbl.TextColor3 = G1
StatLbl.Font = Enum.Font.Gotham
StatLbl.TextSize = 10
StatLbl.TextXAlignment = Enum.TextXAlignment.Left
StatLbl.TextTruncate = Enum.TextTruncate.AtEnd

-- PROGRESS BAR
local PBg = Instance.new("Frame", M)
PBg.Size = UDim2.new(1, -20, 0, 3)
PBg.Position = UDim2.new(0, 10, 0, 63)
PBg.BackgroundColor3 = CD
PBg.BorderSizePixel = 0
corner(PBg, 3)
local PFl = Instance.new("Frame", PBg)
PFl.Size = UDim2.new(0, 0, 1, 0)
PFl.BackgroundColor3 = W1
PFl.BorderSizePixel = 0
corner(PFl, 3)

local function setProg(d, t)
    TweenService:Create(PFl, TweenInfo.new(0.25), {
        Size = UDim2.new(t > 0 and d/t or 0, 0, 1, 0)
    }):Play()
end

-- BUTTON FACTORY
local btnY = 74
local function mkBtn(label, color, h)
    local b = Instance.new("TextButton", M)
    b.Size = UDim2.new(1, -20, 0, h or 30)
    b.Position = UDim2.new(0, 10, 0, btnY)
    b.BackgroundColor3 = color or CD
    b.Text = label
    b.TextColor3 = W1
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    corner(b, 7)
    stroke(b, BD, 1)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = BD}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = color or CD}):Play()
    end)
    btnY = btnY + (h or 30) + 6
    return b
end

local AutoBtn  = mkBtn("▶  AUTO SUMMIT", CD)
local SummitBtn= mkBtn("⬆  TELEPORT SUMMIT", CD)
local GopayBtn = mkBtn("💳  AUTO GOPAY DETECT", Color3.fromRGB(0,60,80))
local RefBtn   = mkBtn("↺  REFRESH CP", CD, 24)

-- DELAY ROW
local DRow = Instance.new("Frame", M)
DRow.Size = UDim2.new(1, -20, 0, 22)
DRow.Position = UDim2.new(0, 10, 0, btnY)
DRow.BackgroundTransparency = 1
btnY = btnY + 28

local DLbl = Instance.new("TextLabel", DRow)
DLbl.Size = UDim2.new(0.62, 0, 1, 0)
DLbl.BackgroundTransparency = 1
DLbl.Text = "Delay per CP (detik):"
DLbl.TextColor3 = G1
DLbl.Font = Enum.Font.Gotham
DLbl.TextSize = 10
DLbl.TextXAlignment = Enum.TextXAlignment.Left

local DBox = Instance.new("TextBox", DRow)
DBox.Size = UDim2.new(0.35, 0, 1, 0)
DBox.Position = UDim2.new(0.63, 0, 0, 0)
DBox.BackgroundColor3 = CD
DBox.Text = "0.5"
DBox.TextColor3 = W1
DBox.Font = Enum.Font.GothamBold
DBox.TextSize = 10
DBox.TextXAlignment = Enum.TextXAlignment.Center
DBox.BorderSizePixel = 0
corner(DBox, 5)
stroke(DBox, BD, 1)

-- DIVIDER
local Div = Instance.new("Frame", M)
Div.Size = UDim2.new(1, -20, 0, 1)
Div.Position = UDim2.new(0, 10, 0, btnY)
Div.BackgroundColor3 = BD
Div.BorderSizePixel = 0
btnY = btnY + 7

-- CP LIST HEADER
local CPHdr = Instance.new("TextLabel", M)
CPHdr.Size = UDim2.new(1, -20, 0, 14)
CPHdr.Position = UDim2.new(0, 10, 0, btnY)
CPHdr.BackgroundTransparency = 1
CPHdr.Text = "MANUAL TELEPORT"
CPHdr.TextColor3 = Color3.fromRGB(45, 45, 45)
CPHdr.Font = Enum.Font.GothamBold
CPHdr.TextSize = 9
CPHdr.TextXAlignment = Enum.TextXAlignment.Left
btnY = btnY + 18

-- CP SCROLL
local CSF = Instance.new("ScrollingFrame", M)
CSF.Size = UDim2.new(1, -20, 0, 370 - btnY - 20)
CSF.Position = UDim2.new(0, 10, 0, btnY)
CSF.BackgroundColor3 = DK
CSF.BorderSizePixel = 0
CSF.ScrollBarThickness = 2
CSF.ScrollBarImageColor3 = BD
CSF.CanvasSize = UDim2.new(0, 0, 0, 0)
corner(CSF, 6)
stroke(CSF, BD, 1)

local CLL = Instance.new("UIListLayout", CSF)
CLL.Padding = UDim.new(0, 2)
CLL.SortOrder = Enum.SortOrder.LayoutOrder
local CPPad = Instance.new("UIPadding", CSF)
CPPad.PaddingTop = UDim.new(0, 4)
CPPad.PaddingLeft = UDim.new(0, 4)
CPPad.PaddingRight = UDim.new(0, 4)
CPPad.PaddingBottom = UDim.new(0, 4)

CLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CSF.CanvasSize = UDim2.new(0, 0, 0, CLL.AbsoluteContentSize.Y + 8)
end)

-- ══════════════════════════════
-- LOGIC
-- ══════════════════════════════
local cpList = {}
local running = false
local selBtn2 = nil

local function buildList()
    for _, c in ipairs(CSF:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    cpList = detectCP()

    if #cpList == 0 then
        StatLbl.Text = "⚠  Tidak ada CP ditemukan"
        StatLbl.TextColor3 = RD
    else
        StatLbl.Text = "✓  " .. #cpList .. " CP terdeteksi"
        StatLbl.TextColor3 = GR
    end

    for i, cp in ipairs(cpList) do
        local b = Instance.new("TextButton", CSF)
        b.LayoutOrder = i
        b.Size = UDim2.new(1, 0, 0, 22)
        b.BackgroundColor3 = CD
        b.Text = string.format("[%02d]  %s", i, cp.Name)
        b.TextColor3 = G1
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        local bp = Instance.new("UIPadding", b)
        bp.PaddingLeft = UDim.new(0, 7)
        corner(b, 4)

        b.MouseButton1Click:Connect(function()
            if selBtn2 and selBtn2 ~= b then
                selBtn2.BackgroundColor3 = CD
                selBtn2.TextColor3 = G1
            end
            selBtn2 = b
            b.BackgroundColor3 = BD
            b.TextColor3 = W1
            local pos = getPos(cp)
            if pos then
                tp(pos)
                StatLbl.Text = string.format("[%d/%d]  %s", i, #cpList, cp.Name)
                StatLbl.TextColor3 = W1
                setProg(i, #cpList)
            end
        end)
    end
end

-- AUTO SUMMIT
AutoBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        AutoBtn.Text = "▶  AUTO SUMMIT"
        StatLbl.Text = "Dihentikan"
        StatLbl.TextColor3 = YL
        return
    end
    if #cpList == 0 then
        StatLbl.Text = "⚠  Tidak ada CP!"
        StatLbl.TextColor3 = RD
        return
    end
    running = true
    AutoBtn.Text = "■  STOP"

    task.spawn(function()
        local delay = math.max(tonumber(DBox.Text) or 0.5, 0.2)
        for i, cp in ipairs(cpList) do
            if not running then break end
            local pos = getPos(cp)
            if pos then
                tp(pos)
                StatLbl.Text = string.format("[%d/%d]  %s", i, #cpList, cp.Name)
                StatLbl.TextColor3 = W1
                setProg(i, #cpList)
                notif(i.."/"..#cpList, cp.Name)
            end
            task.wait(delay)
        end
        if running then
            StatLbl.Text = "✓  Summit selesai!"
            StatLbl.TextColor3 = GR
            setProg(#cpList, #cpList)
            notif("SELESAI!", "Semua checkpoint done 🏆")
        end
        running = false
        AutoBtn.Text = "▶  AUTO SUMMIT"
    end)
end)

-- TELEPORT SUMMIT
SummitBtn.MouseButton1Click:Connect(function()
    if #cpList == 0 then
        StatLbl.Text = "⚠  Tidak ada CP!"
        StatLbl.TextColor3 = RD
        return
    end
    local last = cpList[#cpList]
    local pos = getPos(last)
    if pos then
        tp(pos)
        StatLbl.Text = "⬆  Summit: " .. last.Name
        StatLbl.TextColor3 = GR
        setProg(#cpList, #cpList)
        notif("Summit!", last.Name)
    end
end)

-- GOPAY AUTO DETECT & TELEPORT
GopayBtn.MouseButton1Click:Connect(function()
    StatLbl.Text = "🔍  Mencari GoPay..."
    StatLbl.TextColor3 = CY

    task.spawn(function()
        local obj, pos = findGopay()
        if pos then
            tp(pos)
            StatLbl.Text = "💳  GoPay: " .. (obj and obj.Name or "found")
            StatLbl.TextColor3 = CY
            notif("GoPay!", "Teleport ke " .. (obj and obj.Name or "GoPay spot"))

            -- Auto-touch/click trigger jika ada ProximityPrompt
            task.wait(0.5)
            pcall(function()
                if obj then
                    for _, v in ipairs(obj:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            fireproximityprompt(v)
                        end
                    end
                    -- also check parent
                    local par = obj.Parent
                    if par then
                        for _, v in ipairs(par:GetDescendants()) do
                            if v:IsA("ProximityPrompt") then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end
            end)
        else
            StatLbl.Text = "⚠  GoPay tidak ditemukan"
            StatLbl.TextColor3 = RD
            notif("GoPay", "Tidak ditemukan di map ini")
        end
    end)
end)

-- REFRESH
RefBtn.MouseButton1Click:Connect(function()
    StatLbl.Text = "Memuat ulang..."
    StatLbl.TextColor3 = G1
    task.wait(0.3)
    buildList()
end)

-- F9 TOGGLE
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F9 then
        M.Visible = not M.Visible
    end
end)

-- INIT
task.spawn(function()
    task.wait(2)
    buildList()
end)

print("✅ Summit Lite v6 + GoPay | F9 toggle")
