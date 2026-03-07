--[[
    AUTO SUMMIT LITE - ULTRA MINIMAL
    Anti-lag | Smart CP Detection | v3.0
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- DESTROY OLD
pcall(function()
    for _, g in ipairs(player.PlayerGui:GetChildren()) do
        if g.Name:match("Summit") or g.Name:match("Mountain") or g.Name:match("Teleport") then
            g:Destroy()
        end
    end
end)

-- ══════════════════════════════════════
-- ANTI-LAG SYSTEM
-- ══════════════════════════════════════
local function applyAntiLag()
    -- Reduce render quality
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
    
    -- Disable shadows, decorations
    pcall(function()
        workspace.GlobalShadows = false
        workspace.StreamingEnabled = false
    end)
    
    -- Lower LOD for non-essential parts
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end)
    
    -- Low FPS cap friendly
    pcall(function() settings().Rendering.FrameRateManager = 2 end)
end

-- ══════════════════════════════════════
-- CP DETECTION - ULTRA WIDE SCAN
-- ══════════════════════════════════════
local function detectAllCP()
    local found = {}
    local seenKey = {}

    -- EXTREMELY wide pattern matching
    local function isCP(name)
        local n = name:lower()
        return n:match("check") or n:match("^cp") or n:match("cp%d") or
               n:match("stage") or n:match("summit") or n:match("finish") or
               n:match("waypoint") or n:match("gate") or n:match("flag") or
               n:match("touch") or n:match("start") or n:match("end") or
               n:match("zone") or n:match("point") or n:match("goal") or
               n:match("target") or n:match("node") or n:match("mark") or
               n:match("step") or n:match("level") or n:match("lap") or
               n:match("trial") or n:match("ring") or n:match("orb") or
               n:match("beacon") or n:match("spawn") or n:match("respawn") or
               tonumber(n) ~= nil -- pure number names like "1","2","50"
    end

    local function getPos(obj)
        if obj:IsA("BasePart") then return obj.Position
        elseif obj:IsA("Model") then
            local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            return pp and pp.Position or nil
        end
        return nil
    end

    local function tryAdd(obj)
        local pos = getPos(obj)
        if not pos then return end
        -- Skip if too large (terrain/base)
        if obj:IsA("BasePart") then
            local s = obj.Size
            if s.X > 500 or s.Z > 500 then return end
        end
        local key = math.round(pos.X/3).."_"..math.round(pos.Y/3).."_"..math.round(pos.Z/3)
        if seenKey[key] then return end
        seenKey[key] = true
        table.insert(found, obj)
    end

    -- Scan ALL descendants
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if isCP(obj.Name) then
                tryAdd(obj)
            end
        end
    end

    -- ALSO scan children of named folders/models
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:match("cp") or n:match("check") or n:match("stage") or n:match("map") or n:match("mount") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("Model") then
                    tryAdd(child)
                end
            end
        end
    end

    -- Sort: first by number in name, then by Y position
    table.sort(found, function(a, b)
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

    return found
end

-- ══════════════════════════════════════
-- TELEPORT
-- ══════════════════════════════════════
local function tp(obj)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos
    if obj:IsA("BasePart") then pos = obj.Position
    elseif obj:IsA("Model") then
        local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        pos = pp and pp.Position
    end
    if not pos then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    return true
end

local function notify(t, msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=msg,Duration=2})
    end)
end

-- ══════════════════════════════════════
-- GUI — ULTRA MINIMAL
-- ══════════════════════════════════════
local B = Color3.fromRGB(10,10,10)
local D = Color3.fromRGB(18,18,18)
local C = Color3.fromRGB(26,26,26)
local W = Color3.fromRGB(230,230,230)
local G = Color3.fromRGB(90,90,90)
local GR = Color3.fromRGB(70,200,100)
local RD = Color3.fromRGB(200,70,70)
local YL = Color3.fromRGB(200,180,60)
local BR = Color3.fromRGB(45,45,45)

local function cc(p,r) local u=Instance.new("UICorner",p) u.CornerRadius=UDim.new(0,r or 6) end
local function cs(p,c,t) local s=Instance.new("UIStroke",p) s.Color=c or BR s.Thickness=t or 1 end

local sg = Instance.new("ScreenGui")
sg.Name = "SummitLite"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = player:WaitForChild("PlayerGui")

-- MAIN FRAME
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 220, 0, 36) -- starts collapsed, expands
M.Position = UDim2.new(1, -234, 0.5, -18)
M.BackgroundColor3 = B
M.BorderSizePixel = 0
M.Active = true
M.Draggable = true
M.ClipsDescendants = true
M.Parent = sg
cc(M, 10)
cs(M, BR, 1)

-- TITLE ROW
local TR = Instance.new("Frame", M)
TR.Size = UDim2.new(1, 0, 0, 36)
TR.BackgroundColor3 = D
TR.BorderSizePixel = 0
cc(TR, 10)

-- fix bottom of title
local TF = Instance.new("Frame", TR)
TF.Size = UDim2.new(1, 0, 0.5, 0)
TF.Position = UDim2.new(0, 0, 0.5, 0)
TF.BackgroundColor3 = D
TF.BorderSizePixel = 0

local TL = Instance.new("TextLabel", TR)
TL.Size = UDim2.new(1, -70, 1, 0)
TL.Position = UDim2.new(0, 10, 0, 0)
TL.BackgroundTransparency = 1
TL.Text = "SUMMIT LITE"
TL.TextColor3 = W
TL.Font = Enum.Font.GothamBold
TL.TextSize = 11
TL.TextXAlignment = Enum.TextXAlignment.Left

-- Expand/collapse toggle
local EXP = Instance.new("TextButton", TR)
EXP.Size = UDim2.new(0, 18, 0, 18)
EXP.Position = UDim2.new(1, -44, 0.5, -9)
EXP.Text = "▼"
EXP.TextColor3 = G
EXP.BackgroundColor3 = C
EXP.Font = Enum.Font.GothamBold
EXP.TextSize = 9
EXP.BorderSizePixel = 0
cc(EXP, 4)

local XB = Instance.new("TextButton", TR)
XB.Size = UDim2.new(0, 18, 0, 18)
XB.Position = UDim2.new(1, -22, 0.5, -9)
XB.Text = "✕"
XB.TextColor3 = G
XB.BackgroundColor3 = C
XB.Font = Enum.Font.GothamBold
XB.TextSize = 9
XB.BorderSizePixel = 0
cc(XB, 4)
XB.MouseButton1Click:Connect(function() sg:Destroy() end)

-- BODY
local BD = Instance.new("Frame", M)
BD.Size = UDim2.new(1, -12, 0, 0)
BD.Position = UDim2.new(0, 6, 0, 40)
BD.BackgroundTransparency = 1

local BL = Instance.new("UIListLayout", BD)
BL.SortOrder = Enum.SortOrder.LayoutOrder
BL.Padding = UDim.new(0, 5)

-- Status
local SL = Instance.new("TextLabel", BD)
SL.LayoutOrder = 1
SL.Size = UDim2.new(1, 0, 0, 18)
SL.BackgroundTransparency = 1
SL.Text = "Mendeteksi CP..."
SL.TextColor3 = G
SL.Font = Enum.Font.Gotham
SL.TextSize = 10
SL.TextXAlignment = Enum.TextXAlignment.Left
SL.TextTruncate = Enum.TextTruncate.AtEnd

-- Progress bar
local PB = Instance.new("Frame", BD)
PB.LayoutOrder = 2
PB.Size = UDim2.new(1, 0, 0, 3)
PB.BackgroundColor3 = C
PB.BorderSizePixel = 0
cc(PB, 2)
local PF = Instance.new("Frame", PB)
PF.Size = UDim2.new(0, 0, 1, 0)
PF.BackgroundColor3 = W
PF.BorderSizePixel = 0
cc(PF, 2)

local function setProgress(d, t)
    local p = t > 0 and d/t or 0
    TweenService:Create(PF, TweenInfo.new(0.25), {Size = UDim2.new(p, 0, 1, 0)}):Play()
end

-- Buttons row
local BR2 = Instance.new("Frame", BD)
BR2.LayoutOrder = 3
BR2.Size = UDim2.new(1, 0, 0, 28)
BR2.BackgroundTransparency = 1
local BRL = Instance.new("UIListLayout", BR2)
BRL.FillDirection = Enum.FillDirection.Horizontal
BRL.Padding = UDim.new(0, 5)

local function mkBtn(order, txt, w)
    local b = Instance.new("TextButton", BR2)
    b.LayoutOrder = order
    b.Size = UDim2.new(w or 0.5, order == 2 and -3 or -2, 1, 0)
    b.BackgroundColor3 = C
    b.Text = txt
    b.TextColor3 = W
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.BorderSizePixel = 0
    cc(b, 5)
    cs(b, BR, 1)
    return b
end

local AUTO = mkBtn(1, "AUTO ▶", 0.5)
local JUMP = mkBtn(2, "SUMMIT ↑", 0.5)

-- Delay row
local DR = Instance.new("Frame", BD)
DR.LayoutOrder = 4
DR.Size = UDim2.new(1, 0, 0, 22)
DR.BackgroundTransparency = 1
local DRL = Instance.new("UIListLayout", DR)
DRL.FillDirection = Enum.FillDirection.Horizontal
DRL.Padding = UDim.new(0, 4)
DRL.VerticalAlignment = Enum.VerticalAlignment.Center

local DLB = Instance.new("TextLabel", DR)
DLB.LayoutOrder = 1
DLB.Size = UDim2.new(0.55, 0, 1, 0)
DLB.BackgroundTransparency = 1
DLB.Text = "Delay (s):"
DLB.TextColor3 = G
DLB.Font = Enum.Font.Gotham
DLB.TextSize = 9
DLB.TextXAlignment = Enum.TextXAlignment.Left

local DBX = Instance.new("TextBox", DR)
DBX.LayoutOrder = 2
DBX.Size = UDim2.new(0.42, 0, 0.85, 0)
DBX.BackgroundColor3 = C
DBX.Text = "0.5"
DBX.TextColor3 = W
DBX.Font = Enum.Font.GothamBold
DBX.TextSize = 10
DBX.TextXAlignment = Enum.TextXAlignment.Center
DBX.BorderSizePixel = 0
cc(DBX, 4)
cs(DBX, BR, 1)

-- Anti-lag toggle
local ALR = Instance.new("Frame", BD)
ALR.LayoutOrder = 5
ALR.Size = UDim2.new(1, 0, 0, 22)
ALR.BackgroundColor3 = D
ALR.BorderSizePixel = 0
cc(ALR, 5)

local ALL = Instance.new("TextLabel", ALR)
ALL.Size = UDim2.new(0.7, 0, 1, 0)
ALL.Position = UDim2.new(0, 8, 0, 0)
ALL.BackgroundTransparency = 1
ALL.Text = "Anti-Lag"
ALL.TextColor3 = G
ALL.Font = Enum.Font.Gotham
ALL.TextSize = 9
ALL.TextXAlignment = Enum.TextXAlignment.Left

local ALB = Instance.new("TextButton", ALR)
ALB.Size = UDim2.new(0.28, 0, 0.7, 0)
ALB.Position = UDim2.new(0.7, 0, 0.15, 0)
ALB.BackgroundColor3 = C
ALB.Text = "ON"
ALB.TextColor3 = GR
ALB.Font = Enum.Font.GothamBold
ALB.TextSize = 9
ALB.BorderSizePixel = 0
cc(ALB, 4)

-- CP SCROLL LIST
local CS = Instance.new("ScrollingFrame", BD)
CS.LayoutOrder = 6
CS.Size = UDim2.new(1, 0, 0, 130)
CS.BackgroundColor3 = D
CS.BorderSizePixel = 0
CS.ScrollBarThickness = 2
CS.ScrollBarImageColor3 = G
CS.CanvasSize = UDim2.new(0, 0, 0, 0)
cc(CS, 6)
cs(CS, BR, 1)

local CL = Instance.new("UIListLayout", CS)
CL.Padding = UDim.new(0, 2)
CL.SortOrder = Enum.SortOrder.LayoutOrder
local CP2 = Instance.new("UIPadding", CS)
CP2.PaddingTop = UDim.new(0,4) CP2.PaddingLeft = UDim.new(0,4)
CP2.PaddingRight = UDim.new(0,4) CP2.PaddingBottom = UDim.new(0,4)

CL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CS.CanvasSize = UDim2.new(0,0,0,CL.AbsoluteContentSize.Y+8)
end)

-- Footer
local FL = Instance.new("TextLabel", BD)
FL.LayoutOrder = 7
FL.Size = UDim2.new(1, 0, 0, 12)
FL.BackgroundTransparency = 1
FL.Text = "F9 hide • drag to move"
FL.TextColor3 = Color3.fromRGB(35,35,35)
FL.Font = Enum.Font.Gotham
FL.TextSize = 8
FL.TextXAlignment = Enum.TextXAlignment.Center

-- ══════════════════════════════════════
-- EXPAND / COLLAPSE
-- ══════════════════════════════════════
local expanded = false
local FULL_H = 36 + 8 + 18+5 + 3+5 + 28+5 + 22+5 + 22+5 + 130+5 + 12 + 10
-- ≈ 36 titlebar + body content

local function updateSize()
    BL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() end) -- dummy
    local h = expanded and (36 + BL.AbsoluteContentSize.Y + 14) or 36
    TweenService:Create(M, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 220, 0, h)
    }):Play()
    EXP.Text = expanded and "▲" or "▼"
    BD.Visible = expanded
end

EXP.MouseButton1Click:Connect(function()
    expanded = not expanded
    BD.Visible = expanded
    task.wait(0.01)
    local h = expanded and (36 + BL.AbsoluteContentSize.Y + 14) or 36
    TweenService:Create(M, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 220, 0, h)
    }):Play()
    EXP.Text = expanded and "▲" or "▼"
end)

-- Auto expand on load
task.wait(0.1)
expanded = true
BD.Visible = true

-- ══════════════════════════════════════
-- STATE
-- ══════════════════════════════════════
local cpList = {}
local running = false
local lagOn = true

-- ══════════════════════════════════════
-- BUILD LIST
-- ══════════════════════════════════════
local activeBtn = nil
local function buildList()
    for _, c in ipairs(CS:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    cpList = detectAllCP()
    CPCountNum = #cpList -- reference for display

    if #cpList == 0 then
        SL.Text = "Tidak ada CP ditemukan"
        SL.TextColor3 = RD
    else
        SL.Text = #cpList .. " CP terdeteksi"
        SL.TextColor3 = GR
    end

    for i, cp in ipairs(cpList) do
        local b = Instance.new("TextButton", CS)
        b.LayoutOrder = i
        b.Size = UDim2.new(1, 0, 0, 22)
        b.BackgroundColor3 = C
        b.Text = string.format("[%02d] %s", i, cp.Name)
        b.TextColor3 = G
        b.Font = Enum.Font.Gotham
        b.TextSize = 9
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        local pp = Instance.new("UIPadding", b)
        pp.PaddingLeft = UDim.new(0, 6)
        cc(b, 4)

        b.MouseButton1Click:Connect(function()
            if activeBtn and activeBtn ~= b then
                activeBtn.BackgroundColor3 = C
                activeBtn.TextColor3 = G
            end
            activeBtn = b
            b.BackgroundColor3 = BR
            b.TextColor3 = W
            tp(cp)
            SL.Text = string.format("[%d/%d] %s", i, #cpList, cp.Name)
            SL.TextColor3 = W
            setProgress(i, #cpList)
        end)
    end

    -- resize panel
    task.wait(0.05)
    local h = 36 + BL.AbsoluteContentSize.Y + 14
    M.Size = UDim2.new(0, 220, 0, h)
end

-- ══════════════════════════════════════
-- AUTO SUMMIT
-- ══════════════════════════════════════
AUTO.MouseButton1Click:Connect(function()
    if running then
        running = false
        AUTO.Text = "AUTO ▶"
        AUTO.TextColor3 = W
        cs(AUTO, BR, 1)
        SL.Text = "Dihentikan"
        SL.TextColor3 = YL
        return
    end
    if #cpList == 0 then
        SL.Text = "Tidak ada CP!"
        SL.TextColor3 = RD
        return
    end
    running = true
    AUTO.Text = "STOP ■"
    AUTO.TextColor3 = RD
    cs(AUTO, RD, 1)

    task.spawn(function()
        local delay = math.max(tonumber(DBX.Text) or 0.5, 0.2)
        for i, cp in ipairs(cpList) do
            if not running then break end
            SL.Text = string.format("[%d/%d] %s", i, #cpList, cp.Name)
            SL.TextColor3 = W
            setProgress(i, #cpList)
            tp(cp)
            notify(i.."/"..#cpList, cp.Name)
            task.wait(delay)
        end
        if running then
            SL.Text = "Summit selesai!"
            SL.TextColor3 = GR
            setProgress(#cpList, #cpList)
            notify("SELESAI", "Semua CP done!")
        end
        running = false
        AUTO.Text = "AUTO ▶"
        AUTO.TextColor3 = W
        cs(AUTO, BR, 1)
    end)
end)

-- SUMMIT JUMP (last CP)
JUMP.MouseButton1Click:Connect(function()
    if #cpList == 0 then SL.Text = "Tidak ada CP!" SL.TextColor3 = RD return end
    local last = cpList[#cpList]
    tp(last)
    SL.Text = "Summit: " .. last.Name
    SL.TextColor3 = GR
    setProgress(#cpList, #cpList)
    notify("Summit!", last.Name)
end)

-- ANTI-LAG toggle
local lagApplied = false
ALB.MouseButton1Click:Connect(function()
    lagApplied = not lagApplied
    if lagApplied then
        applyAntiLag()
        ALB.Text = "ON"
        ALB.TextColor3 = GR
        SL.Text = "Anti-lag aktif"
        SL.TextColor3 = GR
    else
        ALB.Text = "OFF"
        ALB.TextColor3 = G
        SL.Text = "Anti-lag nonaktif"
        SL.TextColor3 = G
    end
end)
-- auto apply on load
applyAntiLag()
lagApplied = true

-- F9 toggle
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F9 then M.Visible = not M.Visible end
end)

-- ══════════════════════════════════════
-- INIT
-- ══════════════════════════════════════
task.spawn(function()
    task.wait(1.5)
    buildList()
end)

print("✅ Summit Lite v3.0 | F9 toggle")
