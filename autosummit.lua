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

print("✅ Summit Lite v3.0 | F9 toggle")                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════
-- DETECT CHECKPOINTS (COMPREHENSIVE)
-- ══════════════════════════════════════
local function detectCheckpoints()
    local found = {}
    local seenPos = {}

    local patterns = {
        "checkpoint", "^cp%s*%d", "^cp%d", "stage", "summit",
        "finish", "start", "waypoint", "gate", "flag", "touch",
        "part%d", "zone%d", "area%d", "level%d", "node%d",
    }

    local function matchesCPPattern(name)
        local low = name:lower()
        for _, pat in ipairs(patterns) do
            if low:match(pat) then return true end
        end
        -- also catch things like "1", "2", ... numeric names
        if tonumber(name) then return true end
        return false
    end

    local function addIfNew(obj)
        local pos = nil
        if obj:IsA("BasePart") then
            pos = obj.Position
        elseif obj:IsA("Model") then
            local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if pp then pos = pp.Position end
        end
        if not pos then return end

        local key = math.floor(pos.X) .. "_" .. math.floor(pos.Y) .. "_" .. math.floor(pos.Z)
        if seenPos[key] then return end

        -- avoid obvious non-checkpoint parts
        if obj:IsA("BasePart") then
            local sz = obj.Size
            if sz.X > 800 or sz.Z > 800 then return end -- skip terrain-like
        end

        seenPos[key] = true
        table.insert(found, obj)
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and matchesCPPattern(obj.Name) then
            addIfNew(obj)
        end
    end

    -- Sort by number in name, then by Y position ascending
    table.sort(found, function(a, b)
        local nA = tonumber(a.Name:match("%d+") or a.Name) or 9999
        local nB = tonumber(b.Name:match("%d+") or b.Name) or 9999
        if nA ~= nB then return nA < nB end
        -- fallback: Y position
        local function getY(o)
            if o:IsA("BasePart") then return o.Position.Y end
            local pp = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            return pp and pp.Position.Y or 0
        end
        return getY(a) < getY(b)
    end)

    return found
end

-- ══════════════════════════════════════
-- TELEPORT HELPER
-- ══════════════════════════════════════
local function getObjPosition(obj)
    if obj:IsA("BasePart") then return obj.Position
    elseif obj:IsA("Model") then
        local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if pp then return pp.Position end
    end
    return nil
end

local function teleportTo(obj)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos = getObjPosition(obj)
    if not pos then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    return true
end

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 2
        })
    end)
end

-- ══════════════════════════════════════
-- FLY SYSTEM
-- ══════════════════════════════════════
local function enableFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = hrp
    state.flyBodyVel = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.D = 400
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    state.flyBodyGyro = bg

    state.flyEnabled = true

    RunService:BindToRenderStep("FlyStep", Enum.RenderPriority.Input.Value + 1, function()
        if not state.flyEnabled then return end
        local char2 = player.Character
        if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            dir = dir.Unit
        end

        if state.flyBodyVel and state.flyBodyVel.Parent then
            state.flyBodyVel.Velocity = dir * state.flySpeed
        end
        if state.flyBodyGyro and state.flyBodyGyro.Parent then
            state.flyBodyGyro.CFrame = cam.CFrame
        end
    end)
end

local function disableFly()
    state.flyEnabled = false
    RunService:UnbindFromRenderStep("FlyStep")
    if state.flyBodyVel and state.flyBodyVel.Parent then state.flyBodyVel:Destroy() end
    if state.flyBodyGyro and state.flyBodyGyro.Parent then state.flyBodyGyro:Destroy() end
    state.flyBodyVel = nil
    state.flyBodyGyro = nil

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- ══════════════════════════════════════
-- SUMMIT BADGE DETECTOR
-- ══════════════════════════════════════
local function watchForSummitBadge(callback)
    -- Watch chat / badge notification events
    task.spawn(function()
        -- Hook into StarterGui notifications
        local old = StarterGui.SetCore
        -- Monitor badge service
        local BadgeService = game:GetService("BadgeService")

        -- Also watch for "Selamat" in local events
        player.CharacterAdded:Connect(function() end)

        -- Watch ScreenGuis for summit text
        local function checkForSummitText(gui)
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    local t = v.Text:lower()
                    if t:match("selamat") or t:match("summit") or t:match("lencana") or t:match("badge") then
                        callback(v.Text)
                    end
                end
            end
        end

        player.PlayerGui.ChildAdded:Connect(function(child)
            task.wait(0.2)
            pcall(function() checkForSummitText(child) end)
        end)

        -- Also check existing
        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            pcall(function() checkForSummitText(gui) end)
        end
    end)
end

-- ══════════════════════════════════════
-- GUI BUILDER
-- ══════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitPRO"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Helper
local function makeCorner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end
local function makeStroke(parent, color, thick)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or BORDER
    s.Thickness = thick or 1
    return s
end
local function makePad(parent, t, r, b, l)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    return p
end

-- ─── MAIN FRAME ───────────────────────────────────────
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 520)
Main.Position = UDim2.new(1, -298, 0.5, -260)
Main.BackgroundColor3 = BLACK
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
makeCorner(Main, 12)
makeStroke(Main, BORDER, 1)

-- ─── TITLE BAR ────────────────────────────────────────
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = DARK
TitleBar.BorderSizePixel = 0
makeCorner(TitleBar, 12)

-- fix bottom corners of titlebar
local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = DARK
TitleFix.BorderSizePixel = 0

local TitleDot = Instance.new("Frame", TitleBar)
TitleDot.Size = UDim2.new(0, 4, 0, 4)
TitleDot.Position = UDim2.new(0, 12, 0.5, -2)
TitleDot.BackgroundColor3 = WHITE
TitleDot.BorderSizePixel = 0
makeCorner(TitleDot, 4)

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1, -90, 1, 0)
TitleLbl.Position = UDim2.new(0, 24, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "AUTO SUMMIT PRO"
TitleLbl.TextColor3 = WHITE
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 12
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local TitleSub = Instance.new("TextLabel", TitleBar)
TitleSub.Size = UDim2.new(0, 80, 1, 0)
TitleSub.Position = UDim2.new(1, -138, 0, 0)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "v2.0 ELITE"
TitleSub.TextColor3 = DIM
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextSize = 9
TitleSub.TextXAlignment = Enum.TextXAlignment.Right

-- Minimize & Close
local function makeIconBtn(parent, xPos, label, bgColor)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 20, 0, 20)
    b.Position = UDim2.new(1, xPos, 0.5, -10)
    b.Text = label
    b.TextColor3 = WHITE
    b.BackgroundColor3 = bgColor
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BorderSizePixel = 0
    makeCorner(b, 6)
    return b
end

local MinBtn   = makeIconBtn(TitleBar, -52, "—", PANEL)
local CloseBtn = makeIconBtn(TitleBar, -28, "✕", Color3.fromRGB(60, 20, 20))

-- Divider line under title
local TitleLine = Instance.new("Frame", Main)
TitleLine.Size = UDim2.new(1, -20, 0, 1)
TitleLine.Position = UDim2.new(0, 10, 0, 40)
TitleLine.BackgroundColor3 = BORDER
TitleLine.BorderSizePixel = 0

-- ─── BODY CONTAINER ───────────────────────────────────
local Body = Instance.new("ScrollingFrame", Main)
Body.Name = "Body"
Body.Size = UDim2.new(1, -16, 1, -50)
Body.Position = UDim2.new(0, 8, 0, 46)
Body.BackgroundTransparency = 1
Body.ScrollBarThickness = 0
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
Body.BorderSizePixel = 0
Body.ClipsDescendants = true

local BodyLayout = Instance.new("UIListLayout", Body)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.Padding = UDim.new(0, 6)

BodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Body.CanvasSize = UDim2.new(0, 0, 0, BodyLayout.AbsoluteContentSize.Y + 10)
end)

-- ─── SECTION MAKER ────────────────────────────────────
local function makeSection(order, labelText)
    local sec = Instance.new("Frame", Body)
    sec.LayoutOrder = order
    sec.Size = UDim2.new(1, 0, 0, 16)
    sec.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", sec)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = DIM
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return sec
end

-- ─── STATUS CARD ──────────────────────────────────────
local StatusCard = Instance.new("Frame", Body)
StatusCard.LayoutOrder = 1
StatusCard.Size = UDim2.new(1, 0, 0, 46)
StatusCard.BackgroundColor3 = PANEL
StatusCard.BorderSizePixel = 0
makeCorner(StatusCard, 8)
makeStroke(StatusCard, BORDER, 1)
makePad(StatusCard, 6, 10, 6, 10)

local StatusTop = Instance.new("TextLabel", StatusCard)
StatusTop.Size = UDim2.new(1, 0, 0, 14)
StatusTop.BackgroundTransparency = 1
StatusTop.Text = "STATUS"
StatusTop.TextColor3 = DIM
StatusTop.Font = Enum.Font.GothamBold
StatusTop.TextSize = 8
StatusTop.TextXAlignment = Enum.TextXAlignment.Left

local StatusLbl = Instance.new("TextLabel", StatusCard)
StatusLbl.Size = UDim2.new(1, 0, 0, 18)
StatusLbl.Position = UDim2.new(0, 0, 0, 16)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Mendeteksi checkpoint..."
StatusLbl.TextColor3 = GREY
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 11
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.TextTruncate = Enum.TextTruncate.AtEnd

-- ─── CP COUNTER CARD ──────────────────────────────────
local CPCountCard = Instance.new("Frame", Body)
CPCountCard.LayoutOrder = 2
CPCountCard.Size = UDim2.new(1, 0, 0, 32)
CPCountCard.BackgroundColor3 = PANEL
CPCountCard.BorderSizePixel = 0
makeCorner(CPCountCard, 8)
makeStroke(CPCountCard, BORDER, 1)

local CPCountLbl = Instance.new("TextLabel", CPCountCard)
CPCountLbl.Size = UDim2.new(0.6, 0, 1, 0)
CPCountLbl.Position = UDim2.new(0, 10, 0, 0)
CPCountLbl.BackgroundTransparency = 1
CPCountLbl.Text = "CP Terdeteksi"
CPCountLbl.TextColor3 = GREY
CPCountLbl.Font = Enum.Font.Gotham
CPCountLbl.TextSize = 11
CPCountLbl.TextXAlignment = Enum.TextXAlignment.Left

local CPCountNum = Instance.new("TextLabel", CPCountCard)
CPCountNum.Size = UDim2.new(0.35, 0, 1, 0)
CPCountNum.Position = UDim2.new(0.63, 0, 0, 0)
CPCountNum.BackgroundTransparency = 1
CPCountNum.Text = "0"
CPCountNum.TextColor3 = WHITE
CPCountNum.Font = Enum.Font.GothamBold
CPCountNum.TextSize = 14
CPCountNum.TextXAlignment = Enum.TextXAlignment.Right

-- ─── SECTION: FLIGHT ──────────────────────────────────
makeSection(3, "  FLIGHT SYSTEM")

local FlyCard = Instance.new("Frame", Body)
FlyCard.LayoutOrder = 4
FlyCard.Size = UDim2.new(1, 0, 0, 66)
FlyCard.BackgroundColor3 = PANEL
FlyCard.BorderSizePixel = 0
makeCorner(FlyCard, 8)
makeStroke(FlyCard, BORDER, 1)

local FlyBtn = Instance.new("TextButton", FlyCard)
FlyBtn.Size = UDim2.new(1, -12, 0, 30)
FlyBtn.Position = UDim2.new(0, 6, 0, 6)
FlyBtn.BackgroundColor3 = CARD
FlyBtn.Text = "FLY  OFF"
FlyBtn.TextColor3 = GREY
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 12
FlyBtn.BorderSizePixel = 0
makeCorner(FlyBtn, 6)
makeStroke(FlyBtn, BORDER, 1)

-- Speed row
local SpeedRow = Instance.new("Frame", FlyCard)
SpeedRow.Size = UDim2.new(1, -12, 0, 22)
SpeedRow.Position = UDim2.new(0, 6, 0, 40)
SpeedRow.BackgroundTransparency = 1

local SpeedLbl = Instance.new("TextLabel", SpeedRow)
SpeedLbl.Size = UDim2.new(0.6, 0, 1, 0)
SpeedLbl.BackgroundTransparency = 1
SpeedLbl.Text = "Speed: " .. state.flySpeed
SpeedLbl.TextColor3 = DIM
SpeedLbl.Font = Enum.Font.Gotham
SpeedLbl.TextSize = 10
SpeedLbl.TextXAlignment = Enum.TextXAlignment.Left

local SpeedMinus = Instance.new("TextButton", SpeedRow)
SpeedMinus.Size = UDim2.new(0, 22, 0, 18)
SpeedMinus.Position = UDim2.new(0.6, 0, 0, 2)
SpeedMinus.BackgroundColor3 = CARD
SpeedMinus.Text = "−"
SpeedMinus.TextColor3 = WHITE
SpeedMinus.Font = Enum.Font.GothamBold
SpeedMinus.TextSize = 13
SpeedMinus.BorderSizePixel = 0
makeCorner(SpeedMinus, 4)

local SpeedPlus = Instance.new("TextButton", SpeedRow)
SpeedPlus.Size = UDim2.new(0, 22, 0, 18)
SpeedPlus.Position = UDim2.new(0.6, 26, 0, 2)
SpeedPlus.BackgroundColor3 = CARD
SpeedPlus.Text = "+"
SpeedPlus.TextColor3 = WHITE
SpeedPlus.Font = Enum.Font.GothamBold
SpeedPlus.TextSize = 13
SpeedPlus.BorderSizePixel = 0
makeCorner(SpeedPlus, 4)

SpeedMinus.MouseButton1Click:Connect(function()
    state.flySpeed = math.max(5, state.flySpeed - 5)
    SpeedLbl.Text = "Speed: " .. state.flySpeed
end)
SpeedPlus.MouseButton1Click:Connect(function()
    state.flySpeed = math.min(200, state.flySpeed + 5)
    SpeedLbl.Text = "Speed: " .. state.flySpeed
end)

-- ─── SECTION: AUTO SUMMIT ─────────────────────────────
makeSection(5, "  AUTO SUMMIT")

local AutoCard = Instance.new("Frame", Body)
AutoCard.LayoutOrder = 6
AutoCard.Size = UDim2.new(1, 0, 0, 74)
AutoCard.BackgroundColor3 = PANEL
AutoCard.BorderSizePixel = 0
makeCorner(AutoCard, 8)
makeStroke(AutoCard, BORDER, 1)

local AutoBtn = Instance.new("TextButton", AutoCard)
AutoBtn.Size = UDim2.new(1, -12, 0, 30)
AutoBtn.Position = UDim2.new(0, 6, 0, 6)
AutoBtn.BackgroundColor3 = CARD
AutoBtn.Text = "AUTO SUMMIT  ▶"
AutoBtn.TextColor3 = WHITE
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 12
AutoBtn.BorderSizePixel = 0
makeCorner(AutoBtn, 6)
makeStroke(AutoBtn, BORDER, 1)

-- Delay row
local DelayRow = Instance.new("Frame", AutoCard)
DelayRow.Size = UDim2.new(1, -12, 0, 28)
DelayRow.Position = UDim2.new(0, 6, 0, 40)
DelayRow.BackgroundTransparency = 1

local DelayLbl = Instance.new("TextLabel", DelayRow)
DelayLbl.Size = UDim2.new(0.65, 0, 1, 0)
DelayLbl.BackgroundTransparency = 1
DelayLbl.Text = "Delay per CP (detik)"
DelayLbl.TextColor3 = DIM
DelayLbl.Font = Enum.Font.Gotham
DelayLbl.TextSize = 10
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left

local DelayBox = Instance.new("TextBox", DelayRow)
DelayBox.Size = UDim2.new(0.3, 0, 0.85, 0)
DelayBox.Position = UDim2.new(0.68, 0, 0.08, 0)
DelayBox.BackgroundColor3 = CARD
DelayBox.Text = "0.8"
DelayBox.TextColor3 = WHITE
DelayBox.Font = Enum.Font.GothamBold
DelayBox.TextSize = 11
DelayBox.TextXAlignment = Enum.TextXAlignment.Center
DelayBox.BorderSizePixel = 0
makeCorner(DelayBox, 5)
makeStroke(DelayBox, BORDER, 1)

-- Progress bar
local ProgBg = Instance.new("Frame", Body)
ProgBg.LayoutOrder = 7
ProgBg.Size = UDim2.new(1, 0, 0, 6)
ProgBg.BackgroundColor3 = CARD
ProgBg.BorderSizePixel = 0
makeCorner(ProgBg, 4)

local ProgFill = Instance.new("Frame", ProgBg)
ProgFill.Size = UDim2.new(0, 0, 1, 0)
ProgFill.BackgroundColor3 = WHITE
ProgFill.BorderSizePixel = 0
makeCorner(ProgFill, 4)

local function updateProgress(done, total)
    local pct = total > 0 and (done / total) or 0
    TweenService:Create(ProgFill, TweenInfo.new(0.3), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
end

-- ─── SECTION: QUICK ACTIONS ───────────────────────────
makeSection(8, "  QUICK ACTIONS")

local QuickRow = Instance.new("Frame", Body)
QuickRow.LayoutOrder = 9
QuickRow.Size = UDim2.new(1, 0, 0, 30)
QuickRow.BackgroundTransparency = 1

local QLayout = Instance.new("UIListLayout", QuickRow)
QLayout.FillDirection = Enum.FillDirection.Horizontal
QLayout.Padding = UDim.new(0, 6)
QLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeQuickBtn(order, label, bgColor)
    local b = Instance.new("TextButton", QuickRow)
    b.LayoutOrder = order
    b.Size = UDim2.new(0.5, -3, 1, 0)
    b.BackgroundColor3 = bgColor or CARD
    b.Text = label
    b.TextColor3 = WHITE
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.BorderSizePixel = 0
    makeCorner(b, 6)
    makeStroke(b, BORDER, 1)
    return b
end

local SummitBtn = makeQuickBtn(1, "TELEPORT SUMMIT", CARD)
local RefreshBtn = makeQuickBtn(2, "REFRESH CP", CARD)

-- Age bypass row
local BypassRow = Instance.new("Frame", Body)
BypassRow.LayoutOrder = 10
BypassRow.Size = UDim2.new(1, 0, 0, 30)
BypassRow.BackgroundColor3 = PANEL
BypassRow.BorderSizePixel = 0
makeCorner(BypassRow, 6)
makeStroke(BypassRow, BORDER, 1)

local BypassLbl = Instance.new("TextLabel", BypassRow)
BypassLbl.Size = UDim2.new(0.7, 0, 1, 0)
BypassLbl.Position = UDim2.new(0, 10, 0, 0)
BypassLbl.BackgroundTransparency = 1
BypassLbl.Text = "Age Bypass (3-day fix)"
BypassLbl.TextColor3 = GREY
BypassLbl.Font = Enum.Font.Gotham
BypassLbl.TextSize = 10
BypassLbl.TextXAlignment = Enum.TextXAlignment.Left

local BypassBtn = Instance.new("TextButton", BypassRow)
BypassBtn.Size = UDim2.new(0.28, 0, 0.7, 0)
BypassBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
BypassBtn.BackgroundColor3 = CARD
BypassBtn.Text = "BYPASS"
BypassBtn.TextColor3 = GREY
BypassBtn.Font = Enum.Font.GothamBold
BypassBtn.TextSize = 9
BypassBtn.BorderSizePixel = 0
makeCorner(BypassBtn, 5)
makeStroke(BypassBtn, BORDER, 1)

-- ─── SECTION: MANUAL CP LIST ──────────────────────────
makeSection(11, "  MANUAL CP LIST")

local CPScroll = Instance.new("ScrollingFrame", Body)
CPScroll.LayoutOrder = 12
CPScroll.Size = UDim2.new(1, 0, 0, 180)
CPScroll.BackgroundColor3 = PANEL
CPScroll.BorderSizePixel = 0
CPScroll.ScrollBarThickness = 3
CPScroll.ScrollBarImageColor3 = BORDER
CPScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
makeCorner(CPScroll, 8)
makeStroke(CPScroll, BORDER, 1)

local CPLayout = Instance.new("UIListLayout", CPScroll)
CPLayout.SortOrder = Enum.SortOrder.LayoutOrder
CPLayout.Padding = UDim.new(0, 3)

local CPPad = Instance.new("UIPadding", CPScroll)
CPPad.PaddingTop = UDim.new(0, 6)
CPPad.PaddingRight = UDim.new(0, 6)
CPPad.PaddingBottom = UDim.new(0, 6)
CPPad.PaddingLeft = UDim.new(0, 6)

CPLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CPScroll.CanvasSize = UDim2.new(0, 0, 0, CPLayout.AbsoluteContentSize.Y + 12)
end)

-- ─── SUMMIT REACHED BADGE ─────────────────────────────
local SummitBadge = Instance.new("Frame", Body)
SummitBadge.LayoutOrder = 13
SummitBadge.Size = UDim2.new(1, 0, 0, 0)
SummitBadge.BackgroundColor3 = PANEL
SummitBadge.BorderSizePixel = 0
SummitBadge.ClipsDescendants = true
makeCorner(SummitBadge, 8)
makeStroke(SummitBadge, BORDER, 1)

local SummitBadgeLbl = Instance.new("TextLabel", SummitBadge)
SummitBadgeLbl.Size = UDim2.new(1, -10, 1, 0)
SummitBadgeLbl.Position = UDim2.new(0, 5, 0, 0)
SummitBadgeLbl.BackgroundTransparency = 1
SummitBadgeLbl.Text = ""
SummitBadgeLbl.TextColor3 = GREEN
SummitBadgeLbl.Font = Enum.Font.Gotham
SummitBadgeLbl.TextSize = 10
SummitBadgeLbl.TextXAlignment = Enum.TextXAlignment.Left
SummitBadgeLbl.TextWrapped = true

-- Footer
local Footer = Instance.new("TextLabel", Body)
Footer.LayoutOrder = 14
Footer.Size = UDim2.new(1, 0, 0, 14)
Footer.BackgroundTransparency = 1
Footer.Text = "F9 Toggle  •  Drag to move"
Footer.TextColor3 = Color3.fromRGB(40, 40, 40)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.TextXAlignment = Enum.TextXAlignment.Center

-- ══════════════════════════════════════
-- POPULATE CP LIST
-- ══════════════════════════════════════
local currentHighlight = nil

local function buildCPList()
    -- Clear old buttons
    for _, c in ipairs(CPScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    state.cpList = detectCheckpoints()
    CPCountNum.Text = tostring(#state.cpList)

    if #state.cpList == 0 then
        StatusLbl.Text = "Tidak ada CP ditemukan"
        StatusLbl.TextColor3 = RED
    else
        StatusLbl.Text = #state.cpList .. " checkpoint terdeteksi"
        StatusLbl.TextColor3 = GREEN
    end

    for i, cp in ipairs(state.cpList) do
        local btn = Instance.new("TextButton", CPScroll)
        btn.LayoutOrder = i
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = CARD
        btn.Text = string.format("[%02d]  %s", i, cp.Name)
        btn.TextColor3 = GREY
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        makePad(btn, 0, 0, 0, 8)
        makeCorner(btn, 5)

        btn.MouseEnter:Connect(function()
            if currentHighlight ~= btn then
                btn.BackgroundColor3 = PANEL
                btn.TextColor3 = WHITE
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentHighlight ~= btn then
                btn.BackgroundColor3 = CARD
                btn.TextColor3 = GREY
            end
        end)

        btn.MouseButton1Click:Connect(function()
            if currentHighlight and currentHighlight ~= btn then
                currentHighlight.BackgroundColor3 = CARD
                currentHighlight.TextColor3 = GREY
            end
            currentHighlight = btn
            btn.BackgroundColor3 = DARK
            btn.TextColor3 = WHITE

            if teleportTo(cp) then
                state.currentCP = i
                StatusLbl.Text = string.format("[%d/%d] %s", i, #state.cpList, cp.Name)
                StatusLbl.TextColor3 = WHITE
                updateProgress(i, #state.cpList)
                notify("Teleport", cp.Name, 1.5)
            end
        end)
    end
end

-- ══════════════════════════════════════
-- BUTTONS LOGIC
-- ══════════════════════════════════════

-- FLY toggle
FlyBtn.MouseButton1Click:Connect(function()
    if state.flyEnabled then
        disableFly()
        FlyBtn.Text = "FLY  OFF"
        FlyBtn.TextColor3 = GREY
        makeStroke(FlyBtn, BORDER, 1)
        StatusLbl.Text = "Fly dinonaktifkan"
        StatusLbl.TextColor3 = GREY
    else
        enableFly()
        FlyBtn.Text = "FLY  ON"
        FlyBtn.TextColor3 = WHITE
        makeStroke(FlyBtn, WHITE, 1)
        StatusLbl.Text = "Fly aktif — WASD + Space/Shift"
        StatusLbl.TextColor3 = GREEN
    end
end)

-- Respawn safety
player.CharacterAdded:Connect(function()
    task.wait(1)
    if state.flyEnabled then
        disableFly()
        task.wait(0.5)
        enableFly()
    end
end)

-- AUTO SUMMIT
AutoBtn.MouseButton1Click:Connect(function()
    if state.autoRunning then
        state.autoRunning = false
        AutoBtn.Text = "AUTO SUMMIT  ▶"
        makeStroke(AutoBtn, BORDER, 1)
        AutoBtn.TextColor3 = WHITE
        StatusLbl.Text = "Dihentikan"
        StatusLbl.TextColor3 = YELLOW
        return
    end

    if #state.cpList == 0 then
        StatusLbl.Text = "Tidak ada CP ditemukan!"
        StatusLbl.TextColor3 = RED
        return
    end

    state.autoRunning = true
    AutoBtn.Text = "STOP  ■"
    makeStroke(AutoBtn, RED, 1)
    AutoBtn.TextColor3 = RED

    task.spawn(function()
        local delay = math.max(tonumber(DelayBox.Text) or 0.8, 0.2)
        for i, cp in ipairs(state.cpList) do
            if not state.autoRunning then break end
            StatusLbl.Text = string.format("[%d/%d] %s", i, #state.cpList, cp.Name)
            StatusLbl.TextColor3 = WHITE
            updateProgress(i, #state.cpList)
            teleportTo(cp)
            notify(string.format("%d/%d", i, #state.cpList), cp.Name, 1)
            task.wait(delay)
        end

        if state.autoRunning then
            StatusLbl.Text = "Summit selesai!"
            StatusLbl.TextColor3 = GREEN
            updateProgress(#state.cpList, #state.cpList)
            notify("Summit Complete!", "Semua CP selesai", 3)
        end

        state.autoRunning = false
        AutoBtn.Text = "AUTO SUMMIT  ▶"
        makeStroke(AutoBtn, BORDER, 1)
        AutoBtn.TextColor3 = WHITE
    end)
end)

-- TELEPORT SUMMIT (last CP)
SummitBtn.MouseButton1Click:Connect(function()
    if #state.cpList == 0 then
        StatusLbl.Text = "Tidak ada CP ditemukan!"
        StatusLbl.TextColor3 = RED
        return
    end
    local last = state.cpList[#state.cpList]
    if teleportTo(last) then
        StatusLbl.Text = "Summit: " .. last.Name
        StatusLbl.TextColor3 = GREEN
        updateProgress(#state.cpList, #state.cpList)
        notify("Summit!", "Teleport ke " .. last.Name, 2)
    end
end)

-- REFRESH CP
RefreshBtn.MouseButton1Click:Connect(function()
    StatusLbl.Text = "Memuat ulang CP..."
    StatusLbl.TextColor3 = GREY
    task.wait(0.3)
    buildCPList()
end)

-- AGE BYPASS
BypassBtn.MouseButton1Click:Connect(function()
    BypassBtn.Text = "..."
    BypassBtn.TextColor3 = YELLOW
    task.spawn(function()
        ageBypasser()
        task.wait(1)
        BypassBtn.Text = "DONE"
        BypassBtn.TextColor3 = GREEN
        StatusLbl.Text = "Age bypass diterapkan"
        StatusLbl.TextColor3 = GREEN
        notify("Bypass", "Age restriction dihapus", 2)
        task.wait(2)
        BypassBtn.Text = "BYPASS"
        BypassBtn.TextColor3 = GREY
    end)
end)

-- ── CLOSE / MINIMIZE ──────────────────────────────────
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    state.minimized = not state.minimized
    local targetH = state.minimized and 40 or 520
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 280, 0, targetH)
    }):Play()
    Body.Visible = not state.minimized
    TitleLine.Visible = not state.minimized
    MinBtn.Text = state.minimized and "□" or "—"
end)

-- ── F9 TOGGLE ─────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F9 then
        Main.Visible = not Main.Visible
    end
end)

-- ── SUMMIT BADGE WATCHER ──────────────────────────────
watchForSummitBadge(function(text)
    SummitBadgeLbl.Text = "🏆 " .. text:sub(1, 120)
    TweenService:Create(SummitBadge, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
    task.delay(8, function()
        TweenService:Create(SummitBadge, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
    end)
end)

-- ══════════════════════════════════════
-- INIT
-- ══════════════════════════════════════
task.spawn(function()
    task.wait(1) -- wait for workspace to load
    buildCPList()
    ageBypasser() -- auto run bypass on load

    -- Auto re-detect if new parts appear
    workspace.DescendantAdded:Connect(function()
        task.wait(2)
        if not state.autoRunning then
            buildCPList()
        end
    end)
end)

print("✅ AUTO SUMMIT PRO loaded | F9 to toggle")
