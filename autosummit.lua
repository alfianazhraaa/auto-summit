--[[ SUMMIT TELEPORT + GOPAY FINDER - ULTRA MINIMALIST ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

pcall(function()
    player.PlayerGui:FindFirstChild("SummitUI"):Destroy()
end)

-- ==============================
-- THEME
-- ==============================
local C = {
    bg      = Color3.fromRGB(10, 10, 16),
    panel   = Color3.fromRGB(18, 18, 28),
    accent  = Color3.fromRGB(88, 88, 200),
    green   = Color3.fromRGB(50, 190, 100),
    orange  = Color3.fromRGB(220, 110, 30),
    gopay   = Color3.fromRGB(0, 170, 100),  -- warna khas GoPay
    red     = Color3.fromRGB(200, 55, 55),
    text    = Color3.fromRGB(220, 220, 240),
    sub     = Color3.fromRGB(110, 110, 140),
    white   = Color3.new(1,1,1),
}

local function makeCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function makeStroke(p, col, th)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.accent
    s.Thickness = th or 1
    return s
end

-- ==============================
-- SCREEN GUI
-- ==============================
local Gui = Instance.new("ScreenGui")
Gui.Name = "SummitUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = player:WaitForChild("PlayerGui")

-- Main window
local Win = Instance.new("Frame", Gui)
Win.Size = UDim2.new(0, 230, 0, 400)
Win.Position = UDim2.new(1, -248, 0.5, -200)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
makeCorner(Win, 14)
makeStroke(Win, C.accent, 1)

-- Header
local Header = Instance.new("Frame", Win)
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = C.panel
Header.BorderSizePixel = 0
makeCorner(Header, 14)

-- fix sudut bawah header
local hFix = Instance.new("Frame", Header)
hFix.Size = UDim2.new(1, 0, 0.5, 0)
hFix.Position = UDim2.new(0, 0, 0.5, 0)
hFix.BackgroundColor3 = C.panel
hFix.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size = UDim2.new(1, -36, 1, 0)
TitleLbl.Position = UDim2.new(0, 10, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "🏔  SUMMIT TP"
TitleLbl.TextColor3 = C.text
TitleLbl.TextSize = 12
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local XBtn = Instance.new("TextButton", Header)
XBtn.Size = UDim2.new(0, 20, 0, 20)
XBtn.Position = UDim2.new(1, -26, 0.5, -10)
XBtn.Text = "✕"
XBtn.TextColor3 = C.sub
XBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
XBtn.Font = Enum.Font.GothamBold
XBtn.TextSize = 10
XBtn.BorderSizePixel = 0
makeCorner(XBtn, 5)
XBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- Body dengan padding
local Body = Instance.new("Frame", Win)
Body.Size = UDim2.new(1, -14, 1, -40)
Body.Position = UDim2.new(0, 7, 0, 36)
Body.BackgroundTransparency = 1

local BL = Instance.new("UIListLayout", Body)
BL.SortOrder = Enum.SortOrder.LayoutOrder
BL.Padding = UDim.new(0, 5)

-- Helper buat button
local function makeBtn(parent, order, text, bg)
    local b = Instance.new("TextButton", parent)
    b.LayoutOrder = order
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = bg or C.panel
    b.Text = text
    b.TextColor3 = C.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    makeCorner(b, 7)
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.new(
            b.BackgroundColor3.R + 0.06,
            b.BackgroundColor3.G + 0.06,
            b.BackgroundColor3.B + 0.06
        )
    end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = bg or C.panel end)
    return b
end

-- Status bar
local Status = Instance.new("TextLabel", Body)
Status.LayoutOrder = 1
Status.Size = UDim2.new(1, 0, 0, 20)
Status.BackgroundTransparency = 1
Status.Text = "⏳ Mendeteksi..."
Status.TextColor3 = C.green
Status.TextSize = 10
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left

-- Delay row
local DR = Instance.new("Frame", Body)
DR.LayoutOrder = 2
DR.Size = UDim2.new(1, 0, 0, 26)
DR.BackgroundTransparency = 1

local DL = Instance.new("TextLabel", DR)
DL.Size = UDim2.new(0.62, 0, 1, 0)
DL.BackgroundTransparency = 1
DL.Text = "⏱ Delay (s)"
DL.TextColor3 = C.sub
DL.TextSize = 10
DL.Font = Enum.Font.Gotham
DL.TextXAlignment = Enum.TextXAlignment.Left

local DB = Instance.new("TextBox", DR)
DB.Size = UDim2.new(0.34, 0, 0.85, 0)
DB.Position = UDim2.new(0.64, 0, 0.08, 0)
DB.BackgroundColor3 = C.panel
DB.Text = "0.8"
DB.TextColor3 = C.white
DB.TextSize = 11
DB.Font = Enum.Font.GothamBold
DB.TextXAlignment = Enum.TextXAlignment.Center
DB.BorderSizePixel = 0
makeCorner(DB, 5)

-- Buttons
local AutoBtn   = makeBtn(Body, 3, "⚡  AUTO SUMMIT ALL", C.green)
local SummitBtn = makeBtn(Body, 4, "🏁  LANGSUNG KE SUMMIT", C.orange)

-- GOPAY SECTION
local GopayDiv = Instance.new("Frame", Body)
GopayDiv.LayoutOrder = 5
GopayDiv.Size = UDim2.new(1, 0, 0, 1)
GopayDiv.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
GopayDiv.BorderSizePixel = 0

local GopayLbl = Instance.new("TextLabel", Body)
GopayLbl.LayoutOrder = 6
GopayLbl.Size = UDim2.new(1, 0, 0, 16)
GopayLbl.BackgroundTransparency = 1
GopayLbl.Text = "GOPAY VOUCHER"
GopayLbl.TextColor3 = C.gopay
GopayLbl.TextSize = 9
GopayLbl.Font = Enum.Font.GothamBold
GopayLbl.TextXAlignment = Enum.TextXAlignment.Left

local GopayBtn  = makeBtn(Body, 7, "💚  TELEPORT KE GOPAY", C.gopay)
local GopayStatus = Instance.new("TextLabel", Body)
GopayStatus.LayoutOrder = 8
GopayStatus.Size = UDim2.new(1, 0, 0, 18)
GopayStatus.BackgroundTransparency = 1
GopayStatus.Text = "🔍 Belum terdeteksi"
GopayStatus.TextColor3 = C.sub
GopayStatus.TextSize = 9
GopayStatus.Font = Enum.Font.Gotham
GopayStatus.TextXAlignment = Enum.TextXAlignment.Left

-- Divider CP list
local Div2 = Instance.new("Frame", Body)
Div2.LayoutOrder = 9
Div2.Size = UDim2.new(1, 0, 0, 1)
Div2.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
Div2.BorderSizePixel = 0

local CPLbl = Instance.new("TextLabel", Body)
CPLbl.LayoutOrder = 10
CPLbl.Size = UDim2.new(1, 0, 0, 14)
CPLbl.BackgroundTransparency = 1
CPLbl.Text = "MANUAL TP"
CPLbl.TextColor3 = C.sub
CPLbl.TextSize = 9
CPLbl.Font = Enum.Font.GothamBold
CPLbl.TextXAlignment = Enum.TextXAlignment.Left

-- CP Scroll
local Scroll = Instance.new("ScrollingFrame", Body)
Scroll.LayoutOrder = 11
Scroll.Size = UDim2.new(1, 0, 1, -185)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = C.accent
Scroll.BorderSizePixel = 0

local SL = Instance.new("UIListLayout", Scroll)
SL.SortOrder = Enum.SortOrder.LayoutOrder
SL.Padding = UDim.new(0, 3)
SL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, SL.AbsoluteContentSize.Y + 6)
end)

-- ==============================
-- HELPERS
-- ==============================
local function getPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if p then return p.Position end
    end
    return nil
end

local function tpTo(obj)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local pos = getPos(obj)
    if not pos then return false end

    -- Smooth teleport: naikkan dulu lalu turunkan ke posisi
    local hrp = char.HumanoidRootPart
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 6, 0))
    return true
end

local function notif(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = 2
        })
    end)
end

-- ==============================
-- DETECT CHECKPOINTS
-- ==============================
local cps = {}
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("Model") then
        local n = obj.Name:lower()
        if n:match("checkpoint") or n:match("^cp%s*%d") or n:match("summit") or n:match("finish") or n:match("stage") then
            local dup = false
            for _, e in ipairs(cps) do
                if e.Name == obj.Name then dup = true break end
            end
            if not dup then table.insert(cps, obj) end
        end
    end
end

table.sort(cps, function(a, b)
    local nA = tonumber(a.Name:match("%d+")) or 9999
    local nB = tonumber(b.Name:match("%d+")) or 9999
    return nA < nB
end)

if #cps == 0 then
    Status.Text = "⚠️ CP tidak ditemukan"
    Status.TextColor3 = C.red
else
    Status.Text = "✅  " .. #cps .. " checkpoint"
end

for i, cp in ipairs(cps) do
    local b = Instance.new("TextButton", Scroll)
    b.LayoutOrder = i
    b.Size = UDim2.new(1, -2, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    b.Text = string.format(" [%d] %s", i, cp.Name)
    b.TextColor3 = C.text
    b.TextSize = 10
    b.Font = Enum.Font.Gotham
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    makeCorner(b, 5)

    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(35, 35, 58) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(20, 20, 32) end)

    b.MouseButton1Click:Connect(function()
        if tpTo(cp) then
            Status.Text = "📍 " .. cp.Name
            notif("TP", cp.Name)
        end
    end)
end

-- ==============================
-- DETECT GOPAY OBJECT
-- ==============================
local gopayTarget = nil

local function scanGopay()
    gopayTarget = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        -- Deteksi berbagai kemungkinan nama objek GoPay
        if n:match("gopay") or n:match("go.pay") or n:match("voucher") or n:match("claim") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                gopayTarget = obj
                break
            end
        end
        -- Deteksi dari BillboardGui / SurfaceGui yang berisi teks gopay
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    if child.Text:lower():match("gopay") or child.Text:lower():match("voucher") then
                        -- ambil parent Part dari billboard
                        local adornee = obj.Adornee or obj.Parent
                        if adornee and (adornee:IsA("BasePart") or adornee:IsA("Model")) then
                            gopayTarget = adornee
                            break
                        end
                    end
                end
            end
        end
        if gopayTarget then break end
    end

    if gopayTarget then
        GopayStatus.Text = "✅ " .. gopayTarget.Name
        GopayStatus.TextColor3 = C.gopay
        GopayBtn.BackgroundColor3 = C.gopay
    else
        GopayStatus.Text = "🔍 Tidak ditemukan di map"
        GopayStatus.TextColor3 = C.sub
        GopayBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end

-- Scan saat load + re-scan tiap 5 detik (objek mungkin muncul belakangan)
scanGopay()
task.spawn(function()
    while Gui.Parent do
        task.wait(5)
        if not gopayTarget then scanGopay() end
    end
end)

-- ==============================
-- GOPAY BUTTON
-- ==============================
GopayBtn.MouseButton1Click:Connect(function()
    -- Re-scan dulu kalau belum ada
    if not gopayTarget then scanGopay() end

    if gopayTarget then
        if tpTo(gopayTarget) then
            GopayStatus.Text = "🚀 Teleported!"
            notif("GoPay", "Teleport ke " .. gopayTarget.Name)
        end
    else
        GopayStatus.Text = "⚠️ Objek GoPay tidak ada"
        notif("GoPay", "Objek tidak ditemukan di map")
    end
end)

-- ==============================
-- SUMMIT DIRECT (CP TERAKHIR)
-- ==============================
SummitBtn.MouseButton1Click:Connect(function()
    if #cps == 0 then Status.Text = "⚠️ CP tidak ada" return end
    local last = cps[#cps]
    if tpTo(last) then
        Status.Text = "🏁 " .. last.Name
        notif("Summit!", last.Name)
    end
end)

-- ==============================
-- AUTO SUMMIT ALL
-- ==============================
local running = false

AutoBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        AutoBtn.Text = "⚡  AUTO SUMMIT ALL"
        AutoBtn.BackgroundColor3 = C.green
        Status.Text = "⛔ Dihentikan"
        return
    end
    if #cps == 0 then Status.Text = "⚠️ CP tidak ada" return end

    running = true
    AutoBtn.Text = "⛔  STOP"
    AutoBtn.BackgroundColor3 = C.red

    local delay = math.max(tonumber(DB.Text) or 0.8, 0.3)

    task.spawn(function()
        for i, cp in ipairs(cps) do
            if not running then break end
            Status.Text = string.format("🚀 [%d/%d] %s", i, #cps, cp.Name)
            tpTo(cp)
            notif(string.format("[%d/%d]", i, #cps), cp.Name)
            task.wait(delay)
        end
        if running then
            Status.Text = "🏆 Selesai!"
            notif("Done", "Semua CP selesai 🏆")
        end
        running = false
        AutoBtn.Text = "⚡  AUTO SUMMIT ALL"
        AutoBtn.BackgroundColor3 = C.green
    end)
end)

-- ==============================
-- F9 TOGGLE
-- ==============================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        Win.Visible = not Win.Visible
    end
end)

print("✅ Summit TP loaded | " .. #cps .. " CP | GoPay: " .. tostring(gopayTarget ~= nil))a
