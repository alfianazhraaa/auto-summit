--[[ MOUNTAIN TELEPORT PRO - AUTO SUMMIT EDITION ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ==============================
-- GUI SETUP
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MountainTeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 560)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = MainFrame

-- Stroke border
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 180)
stroke.Thickness = 1.5
stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "🏔️ MOUNTAIN TELEPORT PRO"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local closeCorn = Instance.new("UICorner")
closeCorn.CornerRadius = UDim.new(0, 8)
closeCorn.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- AUTO SUMMIT Button
local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(1, -20, 0, 38)
AutoBtn.Position = UDim2.new(0, 10, 0, 80)
AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
AutoBtn.Text = "⚡ AUTO SUMMIT ALL"
AutoBtn.TextColor3 = Color3.new(1, 1, 1)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 15
AutoBtn.Parent = MainFrame

local autoBtnCorn = Instance.new("UICorner")
autoBtnCorn.CornerRadius = UDim.new(0, 8)
autoBtnCorn.Parent = AutoBtn

-- Delay Input Label
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 150, 0, 25)
DelayLabel.Position = UDim2.new(0, 10, 0, 125)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Delay per CP (detik):"
DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DelayLabel.TextSize = 12
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = MainFrame

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0, 70, 0, 25)
DelayBox.Position = UDim2.new(0, 170, 0, 125)
DelayBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
DelayBox.Text = "1"
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.TextSize = 13
DelayBox.Font = Enum.Font.Gotham
DelayBox.Parent = MainFrame

local delayBoxCorn = Instance.new("UICorner")
delayBoxCorn.CornerRadius = UDim.new(0, 6)
delayBoxCorn.Parent = DelayBox

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 158)
Divider.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- CP List Label
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, -20, 0, 20)
ListLabel.Position = UDim2.new(0, 10, 0, 162)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "📋 Checkpoint List (Manual TP):"
ListLabel.TextColor3 = Color3.fromRGB(160, 160, 220)
ListLabel.TextSize = 12
ListLabel.Font = Enum.Font.GothamBold
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Parent = MainFrame

-- Scrolling CP List
local CPList = Instance.new("ScrollingFrame")
CPList.Size = UDim2.new(1, -20, 1, -195)
CPList.Position = UDim2.new(0, 10, 0, 185)
CPList.BackgroundTransparency = 1
CPList.ScrollBarThickness = 4
CPList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 200)
CPList.Parent = MainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = CPList

-- ==============================
-- CHECKPOINT DETECTION
-- ==============================
local checkpoints = {}

-- Cari semua BasePart dengan nama checkpoint/cp/summit
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        local name = obj.Name:lower()
        if name:find("checkpoint") or name:find("^cp%d") or name:find("summit") or name:find("stage") then
            table.insert(checkpoints, obj)
        end
    end
end

-- Sort berdasarkan nomor di nama (cp1, cp2, dst)
table.sort(checkpoints, function(a, b)
    local numA = tonumber(a.Name:match("%d+")) or 0
    local numB = tonumber(b.Name:match("%d+")) or 0
    return numA < numB
end)

-- Update canvas size otomatis
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CPList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- ==============================
-- FUNGSI TELEPORT
-- ==============================
local function teleportTo(cp)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(cp.Position + Vector3.new(0, 5, 0))
        return true
    end
    return false
end

local function sendNotif(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end)
end

-- ==============================
-- BUAT TOMBOL PER CHECKPOINT
-- ==============================
if #checkpoints == 0 then
    StatusLabel.Text = "⚠️ Tidak ada CP ditemukan!"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
else
    StatusLabel.Text = "✅ " .. #checkpoints .. " checkpoint ditemukan"
end

for i, cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton")
    btn.Name = "CP_" .. i
    btn.LayoutOrder = i
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = string.format("[%d] %s", i, cp.Name)
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.Parent = CPList

    local bCorn = Instance.new("UICorner")
    bCorn.CornerRadius = UDim.new(0, 6)
    bCorn.Parent = btn

    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end)

    btn.MouseButton1Click:Connect(function()
        if teleportTo(cp) then
            StatusLabel.Text = "📍 TP ke: " .. cp.Name
            sendNotif("Teleported!", "Ke " .. cp.Name)
        end
    end)
end

-- ==============================
-- AUTO SUMMIT (TELEPORT SEMUA CP BERURUTAN)
-- ==============================
local isRunning = false

AutoBtn.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        AutoBtn.Text = "⚡ AUTO SUMMIT ALL"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        StatusLabel.Text = "⛔ Auto Summit dihentikan"
        return
    end

    if #checkpoints == 0 then
        StatusLabel.Text = "⚠️ Tidak ada CP ditemukan!"
        return
    end

    isRunning = true
    AutoBtn.Text = "⛔ STOP AUTO SUMMIT"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

    local delay = tonumber(DelayBox.Text) or 1
    if delay < 0.3 then delay = 0.3 end -- minimum delay agar tidak terlalu cepat

    task.spawn(function()
        for i, cp in ipairs(checkpoints) do
            if not isRunning then break end

            StatusLabel.Text = string.format("🚀 Summit [%d/%d] %s", i, #checkpoints, cp.Name)
            teleportTo(cp)
            sendNotif("Auto Summit", string.format("[%d/%d] %s", i, #checkpoints, cp.Name))

            task.wait(delay)
        end

        if isRunning then
            StatusLabel.Text = "🏆 AUTO SUMMIT SELESAI!"
            sendNotif("Selesai!", "Semua checkpoint telah di-summit!")
        end

        isRunning = false
        AutoBtn.Text = "⚡ AUTO SUMMIT ALL"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
    end)
end)

-- ==============================
-- TOGGLE GUI (F9)
-- ==============================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("✅ Mountain Teleport Pro loaded! F9 = toggle GUI | " .. #checkpoints .. " CP ditemukan")
