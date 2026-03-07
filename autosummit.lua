--[[
  SUMMIT LITE v5 - FIXED & VISIBLE
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- DESTROY OLD
pcall(function()
    for _, g in ipairs(player.PlayerGui:GetChildren()) do
        if g.Name == "SL5" then g:Destroy() end
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
               n:match("level") or n:match("ring") or n:match("orb") or
               n:match("beacon") or n:match("spawn") or n:match("respawn") or
               n:match("pad") or n:match("plate") or n:match("tile") or
               n:match("end") or n:match("start") or n:match("part%d")
    end
    local function getPos(obj)
        if obj:IsA("BasePart") then return obj.Position end
        if obj:IsA("Model") then
            local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            return p and p.Position
        end
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
        if (obj:IsA("BasePart") or obj:IsA("Model")) and isCP(obj.Name) then
            add(obj)
        end
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

-- TELEPORT
local function tp(obj)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos
    if obj:IsA("BasePart") then pos = obj.Position
    elseif obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        pos = p and p.Position
    end
    if not pos then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    return true
end

local function notif(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title=t, Text=m, Duration=2})
    end)
end

-- ══════════════════════════════
-- GUI - FIXED VISIBLE PANEL
-- ══════════════════════════════

local sg = Instance.new("ScreenGui")
sg.Name = "SL5"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = player:WaitForChild("PlayerGui")

-- MAIN FRAME - center screen, fixed size
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 240, 0, 400)
M.Position = UDim2.new(0.5, -120, 0.5, -200)
M.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
M.BorderSizePixel = 0
M.Active = true
M.Draggable = true
M.Parent = sg

local MC = Instance.new("UICorner", M)
MC.CornerRadius = UDim.new(0, 10)

local MS = Instance.new("UIStroke", M)
MS.Color = Color3.fromRGB(50, 50, 50)
MS.Thickness = 1

-- TITLE BAR
local TB = Instance.new("Frame", M)
TB.Size = UDim2.new(1, 0, 0, 38)
TB.Position = UDim2.new(0, 0, 0, 0)
TB.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TB.BorderSizePixel = 0

local TBC = Instance.new("UICorner", TB)
TBC.CornerRadius = UDim.new(0, 10)

-- fix bottom of topbar
local TBFix = Instance.new("Frame", TB)
TBFix.Size = UDim2.new(1, 0, 0, 10)
TBFix.Position = UDim2.new(0, 0, 1, -10)
TBFix.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TBFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TB)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⛰  SUMMIT LITE"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TB)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.BorderSizePixel = 0
local CBC = Instance.new("UICorner", CloseBtn)
CBC.CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- SEPARATOR
local Sep = Instance.new("Frame", M)
Sep.Size = UDim2.new(1, -20, 0, 1)
Sep.Position = UDim2.new(0, 10, 0, 38)
Sep.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Sep.BorderSizePixel = 0

-- STATUS
local StatusLbl = Instance.new("TextLabel", M)
StatusLbl.Size = UDim2.new(1, -20, 0, 18)
StatusLbl.Position = UDim2.new(0, 10, 0, 46)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Mendeteksi checkpoint..."
StatusLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 11
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.TextTruncate = Enum.TextTruncate.AtEnd

-- PROGRESS BAR
local PBG = Instance.new("Frame", M)
PBG.Size = UDim2.new(1, -20, 0, 4)
PBG.Position = UDim2.new(0, 10, 0, 68)
PBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PBG.BorderSizePixel = 0
local PBGC = Instance.new("UICorner", PBG)
PBGC.CornerRadius = UDim.new(0, 3)

local PBF = Instance.new("Frame", PBG)
PBF.Size = UDim2.new(0, 0, 1, 0)
PBF.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
PBF.BorderSizePixel = 0
local PBFC = Instance.new("UICorner", PBF)
PBFC.CornerRadius = UDim.new(0, 3)

local function setProg(d, t)
    local p = t > 0 and d/t or 0
    TweenService:Create(PBF, TweenInfo.new(0.25), {Size = UDim2.new(p, 0, 1, 0)}):Play()
end

-- HELPER: make button
local function makeBtn(yPos, txt, h)
    local b = Instance.new("TextButton", M)
    b.Size = UDim2.new(1, -20, 0, h or 32)
    b.Position = UDim2.new(0, 10, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    local bc = Instance.new("UICorner", b)
    bc.CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", b)
    bs.Color = Color3.fromRGB(40, 40, 40)
    bs.Thickness = 1
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(32, 32, 32) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(22, 22, 22) end)
    return b, bs
end

local AutoBtn, AutoStroke = makeBtn(80, "▶  AUTO SUMMIT", 32)
local JumpBtn, JumpStroke = makeBtn(118, "↑  TELEPORT KE SUMMIT", 32)
local RefBtn,  RefStroke  = makeBtn(156, "↺  REFRESH CP", 26)

-- DELAY ROW
local DelayFrame = Instance.new("Frame", M)
DelayFrame.Size = UDim2.new(1, -20, 0, 24)
DelayFrame.Position = UDim2.new(0, 10, 0, 188)
DelayFrame.BackgroundTransparency = 1

local DelayLbl = Instance.new("TextLabel", DelayFrame)
DelayLbl.Size = UDim2.new(0.6, 0, 1, 0)
DelayLbl.BackgroundTransparency = 1
DelayLbl.Text = "Delay per CP (detik):"
DelayLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
DelayLbl.Font = Enum.Font.Gotham
DelayLbl.TextSize = 10
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left

local DelayBox = Instance.new("TextBox", DelayFrame)
DelayBox.Size = UDim2.new(0.35, 0, 1, 0)
DelayBox.Position = UDim2.new(0.63, 0, 0, 0)
DelayBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
DelayBox.Text = "0.5"
DelayBox.TextColor3 = Color3.fromRGB(220, 220, 220)
DelayBox.Font = Enum.Font.GothamBold
DelayBox.TextSize = 10
DelayBox.TextXAlignment = Enum.TextXAlignment.Center
DelayBox.BorderSizePixel = 0
local DBC = Instance.new("UICorner", DelayBox)
DBC.CornerRadius = UDim.new(0, 5)
local DBS = Instance.new("UIStroke", DelayBox)
DBS.Color = Color3.fromRGB(40, 40, 40)
DBS.Thickness = 1

-- SEPARATOR 2
local Sep2 = Instance.new("Frame", M)
Sep2.Size = UDim2.new(1, -20, 0, 1)
Sep2.Position = UDim2.new(0, 10, 0, 218)
Sep2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sep2.BorderSizePixel = 0

-- CP LIST LABEL
local CPLbl = Instance.new("TextLabel", M)
CPLbl.Size = UDim2.new(1, -20, 0, 16)
CPLbl.Position = UDim2.new(0, 10, 0, 224)
CPLbl.BackgroundTransparency = 1
CPLbl.Text = "MANUAL — klik CP untuk teleport"
CPLbl.TextColor3 = Color3.fromRGB(55, 55, 55)
CPLbl.Font = Enum.Font.GothamBold
CPLbl.TextSize = 9
CPLbl.TextXAlignment = Enum.TextXAlignment.Left

-- CP SCROLL
local CSF = Instance.new("ScrollingFrame", M)
CSF.Size = UDim2.new(1, -20, 0, 130)
CSF.Position = UDim2.new(0, 10, 0, 244)
CSF.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
CSF.BorderSizePixel = 0
CSF.ScrollBarThickness = 2
CSF.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
CSF.CanvasSize = UDim2.new(0, 0, 0, 0)
local CSFC = Instance.new("UICorner", CSF)
CSFC.CornerRadius = UDim.new(0, 6)
local CSFS = Instance.new("UIStroke", CSF)
CSFS.Color = Color3.fromRGB(30, 30, 30)
CSFS.Thickness = 1

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

-- FOOTER
local Footer = Instance.new("TextLabel", M)
Footer.Size = UDim2.new(1, 0, 0, 14)
Footer.Position = UDim2.new(0, 0, 1, -16)
Footer.BackgroundTransparency = 1
Footer.Text = "F9 sembunyikan  •  drag untuk pindah"
Footer.TextColor3 = Color3.fromRGB(35, 35, 35)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.TextXAlignment = Enum.TextXAlignment.Center

-- ══════════════════════════════
-- STATE & LOGIC
-- ══════════════════════════════
local cpList = {}
local running = false
local selBtn = nil

local function buildList()
    for _, c in ipairs(CSF:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    cpList = detectCP()

    if #cpList == 0 then
        StatusLbl.Text = "⚠  Tidak ada CP ditemukan"
        StatusLbl.TextColor3 = Color3.fromRGB(200, 80, 80)
    else
        StatusLbl.Text = "✓  " .. #cpList .. " checkpoint terdeteksi"
        StatusLbl.TextColor3 = Color3.fromRGB(80, 200, 100)
    end

    for i, cp in ipairs(cpList) do
        local b = Instance.new("TextButton", CSF)
        b.LayoutOrder = i
        b.Size = UDim2.new(1, 0, 0, 22)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.Text = string.format("[%02d]  %s", i, cp.Name)
        b.TextColor3 = Color3.fromRGB(85, 85, 85)
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        local bpad = Instance.new("UIPadding", b)
        bpad.PaddingLeft = UDim.new(0, 6)
        local bc = Instance.new("UICorner", b)
        bc.CornerRadius = UDim.new(0, 4)

        b.MouseEnter:Connect(function()
            if selBtn ~= b then b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        end)
        b.MouseLeave:Connect(function()
            if selBtn ~= b then b.BackgroundColor3 = Color3.fromRGB(20, 20, 20) end
        end)
        b.MouseButton1Click:Connect(function()
            if selBtn and selBtn ~= b then
                selBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                selBtn.TextColor3 = Color3.fromRGB(85, 85, 85)
            end
            selBtn = b
            b.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            b.TextColor3 = Color3.fromRGB(220, 220, 220)
            if tp(cp) then
                StatusLbl.Text = string.format("[%d/%d]  %s", i, #cpList, cp.Name)
                StatusLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
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
        AutoStroke.Color = Color3.fromRGB(40, 40, 40)
        StatusLbl.Text = "Dihentikan"
        StatusLbl.TextColor3 = Color3.fromRGB(200, 180, 60)
        return
    end
    if #cpList == 0 then
        StatusLbl.Text = "⚠  Tidak ada CP!"
        StatusLbl.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    running = true
    AutoBtn.Text = "■  STOP"
    AutoStroke.Color = Color3.fromRGB(200, 70, 70)

    task.spawn(function()
        local delay = math.max(tonumber(DelayBox.Text) or 0.5, 0.2)
        for i, cp in ipairs(cpList) do
            if not running then break end
            StatusLbl.Text = string.format("[%d/%d]  %s", i, #cpList, cp.Name)
            StatusLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            setProg(i, #cpList)
            tp(cp)
            notif(i .. "/" .. #cpList, cp.Name)
            task.wait(delay)
        end
        if running then
            StatusLbl.Text = "✓  Summit selesai!"
            StatusLbl.TextColor3 = Color3.fromRGB(80, 200, 100)
            setProg(#cpList, #cpList)
            notif("SELESAI", "Semua CP done!")
        end
        running = false
        AutoBtn.Text = "▶  AUTO SUMMIT"
        AutoStroke.Color = Color3.fromRGB(40, 40, 40)
    end)
end)

JumpBtn.MouseButton1Click:Connect(function()
    if #cpList == 0 then
        StatusLbl.Text = "⚠  Tidak ada CP!"
        StatusLbl.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    local last = cpList[#cpList]
    if tp(last) then
        StatusLbl.Text = "↑  Summit: " .. last.Name
        StatusLbl.TextColor3 = Color3.fromRGB(80, 200, 100)
        setProg(#cpList, #cpList)
        notif("Summit!", last.Name)
    end
end)

RefBtn.MouseButton1Click:Connect(function()
    StatusLbl.Text = "Memuat ulang..."
    StatusLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
    task.wait(0.3)
    buildList()
end)

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

print("✅ Summit Lite v5 loaded | F9 toggle")
