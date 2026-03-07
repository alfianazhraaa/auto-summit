--[[ MOUNTAIN TELEPORT PRO - MINIMALIST EDITION ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- DESTROY OLD GUI
pcall(function()
    player.PlayerGui:FindFirstChild("MountainTeleportGUI"):Destroy()
end)

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MountainTeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 420)
Main.Position = UDim2.new(1, -280, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(60, 60, 120)
stroke.Thickness = 1

-- Top Bar
local topBar = Instance.new("Frame", Main)
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1, 0, 0.5, 0)
topFix.Position = UDim2.new(0, 0, 0.5, 0)
topFix.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
topFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", topBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🏔  SUMMIT TELEPORT"
Title.TextColor3 = Color3.fromRGB(210, 210, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", topBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Body
local Body = Instance.new("Frame", Main)
Body.Size = UDim2.new(1, -16, 1, -46)
Body.Position = UDim2.new(0, 8, 0, 40)
Body.BackgroundTransparency = 1

local bodyLayout = Instance.new("UIListLayout", Body)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Padding = UDim.new(0, 6)

-- Status
local StatusLabel = Instance.new("TextLabel", Body)
StatusLabel.LayoutOrder = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⏳ Mencari checkpoint..."
StatusLabel.TextColor3 = Color3.fromRGB(140, 200, 140)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Delay Row
local DelayRow = Instance.new("Frame", Body)
DelayRow.LayoutOrder = 2
DelayRow.Size = UDim2.new(1, 0, 0, 28)
DelayRow.BackgroundTransparency = 1

local DelayLbl = Instance.new("TextLabel", DelayRow)
DelayLbl.Size = UDim2.new(0.65, 0, 1, 0)
DelayLbl.BackgroundTransparency = 1
DelayLbl.Text = "⏱ Delay per CP (detik)"
DelayLbl.TextColor3 = Color3.fromRGB(140, 140, 160)
DelayLbl.TextSize = 11
DelayLbl.Font = Enum.Font.Gotham
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left

local DelayBox = Instance.new("TextBox", DelayRow)
DelayBox.Size = UDim2.new(0.3, 0, 0.85, 0)
DelayBox.Position = UDim2.new(0.68, 0, 0.08, 0)
DelayBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
DelayBox.Text = "0.8"
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.TextSize = 12
DelayBox.Font = Enum.Font.GothamBold
DelayBox.TextXAlignment = Enum.TextXAlignment.Center
DelayBox.BorderSizePixel = 0
Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 6)

-- Auto Summit Button
local AutoBtn = Instance.new("TextButton", Body)
AutoBtn.LayoutOrder = 3
AutoBtn.Size = UDim2.new(1, 0, 0, 36)
AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
AutoBtn.Text = "⚡  AUTO SUMMIT ALL"
AutoBtn.TextColor3 = Color3.new(1, 1, 1)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 13
AutoBtn.BorderSizePixel = 0
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 8)

-- Teleport ke Summit Button
local SummitBtn = Instance.new("TextButton", Body)
SummitBtn.LayoutOrder = 4
SummitBtn.Size = UDim2.new(1, 0, 0, 36)
SummitBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 20)
SummitBtn.Text = "🏁  TELEPORT KE SUMMIT"
SummitBtn.TextColor3 = Color3.new(1, 1, 1)
SummitBtn.Font = Enum.Font.GothamBold
SummitBtn.TextSize = 13
SummitBtn.BorderSizePixel = 0
Instance.new("UICorner", SummitBtn).CornerRadius = UDim.new(0, 8)

-- Divider
local Div = Instance.new("Frame", Body)
Div.LayoutOrder = 5
Div.Size = UDim2.new(1, 0, 0, 1)
Div.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
Div.BorderSizePixel = 0

-- CP List Label
local ListLbl = Instance.new("TextLabel", Body)
ListLbl.LayoutOrder = 6
ListLbl.Size = UDim2.new(1, 0, 0, 18)
ListLbl.BackgroundTransparency = 1
ListLbl.Text = "MANUAL TELEPORT"
ListLbl.TextColor3 = Color3.fromRGB(100, 100, 140)
ListLbl.TextSize = 10
ListLbl.Font = Enum.Font.GothamBold
ListLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Scroll List
local CPScroll = Instance.new("ScrollingFrame", Body)
CPScroll.LayoutOrder = 7
CPScroll.Size = UDim2.new(1, 0, 1, -155)
CPScroll.BackgroundTransparency = 1
CPScroll.ScrollBarThickness = 3
CPScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 160)
CPScroll.BorderSizePixel = 0

local scrollLayout = Instance.new("UIListLayout", CPScroll)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 4)

scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CPScroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 8)
end)

-- ==============================
-- CHECKPOINT DETECTION
-- ==============================
local checkpoints = {}

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("Model") then
        local name = obj.Name:lower()
        if name:match("checkpoint") or name:match("^cp%s*%d") or name:match("summit") or name:match("finish") or name:match("stage") then
            local duplicate = false
            for _, existing in ipairs(checkpoints) do
                if existing.Name == obj.Name then duplicate = true break end
            end
            if not duplicate then
                table.insert(checkpoints, obj)
            end
        end
    end
end

-- Sort ascending berdasarkan angka di nama
table.sort(checkpoints, function(a, b)
    local nA = tonumber(a.Name:match("%d+")) or 9999
    local nB = tonumber(b.Name:match("%d+")) or 9999
    return nA < nB
end)

-- ==============================
-- HELPER FUNCTIONS
-- ==============================
local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if p then return p.Position end
    end
    return nil
end

local function teleportTo(obj)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = getPosition(obj)
        if pos then
            char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            return true
        end
    end
    return false
end

local function sendNotif(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = 2
        })
    end)
end

-- ==============================
-- POPULATE STATUS & LIST
-- ==============================
if #checkpoints == 0 then
    StatusLabel.Text = "⚠️ Tidak ada CP ditemukan"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
else
    StatusLabel.Text = "✅  " .. #checkpoints .. " checkpoint ditemukan"
end

for i, cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton", CPScroll)
    btn.LayoutOrder = i
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
    btn.Text = string.format(" [%d]  %s", i, cp.Name)
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(22, 22, 36) end)

    btn.MouseButton1Click:Connect(function()
        if teleportTo(cp) then
            StatusLabel.Text = "📍 " .. cp.Name
            sendNotif("Teleported", cp.Name)
        end
    end)
end

-- ==============================
-- TELEPORT KE SUMMIT (CP TERAKHIR)
-- ==============================
SummitBtn.MouseButton1Click:Connect(function()
    if #checkpoints == 0 then
        StatusLabel.Text = "⚠️ Tidak ada CP ditemukan"
        return
    end
    local lastCP = checkpoints[#checkpoints]
    if teleportTo(lastCP) then
        StatusLabel.Text = "🏁 Summit: " .. lastCP.Name
        sendNotif("Summit!", "Teleport ke " .. lastCP.Name)
    end
end)

-- ==============================
-- AUTO SUMMIT ALL (BERURUTAN)
-- ==============================
local isRunning = false

AutoBtn.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        AutoBtn.Text = "⚡  AUTO SUMMIT ALL"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
        StatusLabel.Text = "⛔ Dihentikan"
        return
    end

    if #checkpoints == 0 then
        StatusLabel.Text = "⚠️ Tidak ada CP ditemukan"
        return
    end

    isRunning = true
    AutoBtn.Text = "⛔  STOP"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

    local delay = math.max(tonumber(DelayBox.Text) or 0.8, 0.3)

    task.spawn(function()
        for i, cp in ipairs(checkpoints) do
            if not isRunning then break end
            StatusLabel.Text = string.format("🚀 [%d/%d] %s", i, #checkpoints, cp.Name)
            teleportTo(cp)
            sendNotif(string.format("[%d/%d]", i, #checkpoints), cp.Name)
            task.wait(delay)
        end

        if isRunning then
            StatusLabel.Text = "🏆 Summit selesai!"
            sendNotif("Selesai!", "Semua checkpoint selesai 🏆")
        end

        isRunning = false
        AutoBtn.Text = "⚡  AUTO SUMMIT ALL"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
    end)
end)

-- ==============================
-- F9 TOGGLE
-- ==============================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        Main.Visible = not Main.Visible
    end
end)

print("✅ Summit Teleport loaded | " .. #checkpoints .. " CP | F9 toggle")
