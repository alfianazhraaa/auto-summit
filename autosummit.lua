--[[
╔══════════════════════════════════════════════════════════════════╗
║                    MOUNTAIN TELEPORT PRO v1.0                    ║
║                     Auto Summit / CP Teleporter                  ║
║                         by: Riski Ganteng                        ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local guiLibrary = {}

-- UI Settings
local UI = {
    Theme = {
        Primary = Color3.fromRGB(30, 144, 255),      -- Biru terang
        Secondary = Color3.fromRGB(25, 25, 35),      -- Dark
        Background = Color3.fromRGB(18, 18, 22),     -- Lebih gelap
        Text = Color3.fromRGB(255, 255, 255),        -- Putih
        TextMuted = Color3.fromRGB(150, 150, 160),   -- Abu-abu
        Success = Color3.fromRGB(50, 205, 50),       -- Hijau
        Danger = Color3.fromRGB(255, 70, 70),        -- Merah
        Warning = Color3.fromRGB(255, 165, 0),       -- Oranye
        Glass = Color3.fromRGB(255, 255, 255),       -- Untuk efek glassmorphism
        Accent = Color3.fromRGB(147, 112, 219)       -- Ungu
    },
    
    Fonts = {
        Regular = Enum.Font.Gotham,
        Bold = Enum.Font.GothamBold,
        SemiBold = Enum.Font.GothamSemibold,
        Code = Enum.Font.Code
    }
}

-- Functions
function CreateUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MountainTeleportPro"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Blur Effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = camera
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    mainFrame.BackgroundColor3 = UI.Theme.Background
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = mainFrame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    -- Stroke (Border)
    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.Theme.Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.8
    stroke.Parent = mainFrame
    
    -- Gradient Effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, UI.Theme.Primary),
        ColorSequenceKeypoint.new(0.5, UI.Theme.Background),
        ColorSequenceKeypoint.new(1, UI.Theme.Secondary)
    })
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new(0.95)
    gradient.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundTransparency = 1
    header.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "MOUNTAIN TELEPORT PRO"
    title.TextColor3 = UI.Theme.Text
    title.TextScaled = false
    title.TextSize = 24
    title.Font = UI.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = header
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Auto Summit & CP Teleporter"
    subtitle.TextColor3 = UI.Theme.TextMuted
    subtitle.TextSize = 14
    subtitle.Font = UI.Fonts.Regular
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = header
    
    -- Close Button
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 20)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://6031094678"
    closeButton.ImageColor3 = UI.Theme.TextMuted
    closeButton.Parent = header
    
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {ImageColor3 = UI.Theme.Danger}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {ImageColor3 = UI.Theme.TextMuted}):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -200, 1.5, 0)}):Play()
        wait(0.3)
        screenGui:Destroy()
    end)
    
    -- Divider
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0.9, 0, 0, 2)
    divider.Position = UDim2.new(0.05, 0, 0, 70)
    divider.BackgroundColor3 = UI.Theme.Primary
    divider.BackgroundTransparency = 0.7
    divider.Parent = mainFrame
    
    -- Corner untuk divider
    local dividerCorner = Instance.new("UICorner")
    dividerCorner.CornerRadius = UDim.new(0, 2)
    dividerCorner.Parent = divider
    
    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -140)
    contentFrame.Position = UDim2.new(0, 0, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = UI.Theme.Primary
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame
    
    -- Padding untuk content
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.Parent = contentFrame
    
    -- List Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Spacing = UDim.new(0, 12)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = contentFrame
    
    -- Status Frame
    local statusFrame = CreateStatusFrame(contentFrame)
    -- CP List Frame
    local cpFrame = CreateCPFrame(contentFrame)
    -- Settings Frame
    local settingsFrame = CreateSettingsFrame(contentFrame)
    -- Action Buttons
    local actionsFrame = CreateActionsFrame(contentFrame)
    
    -- Update canvas size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 32)
    
    -- Drag functionality
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Animation
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = 10}):Play()
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -200, 0.5, -300)
    }):Play()
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ContentFrame = contentFrame,
        Blur = blur
    }
end

function CreateStatusFrame(parent)
    local frame = Instance.new("Frame")
    frame.Name = "StatusFrame"
    frame.Size = UDim2.new(1, 0, 0, 100)
    frame.BackgroundColor3 = UI.Theme.Secondary
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.Theme.Primary
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, UI.Theme.Primary),
        ColorSequenceKeypoint.new(1, UI.Theme.Secondary)
    })
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new(0.9)
    gradient.Parent = frame
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.5, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 16, 0, 12)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS"
    statusLabel.TextColor3 = UI.Theme.TextMuted
    statusLabel.TextSize = 12
    statusLabel.Font = UI.Fonts.SemiBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame
    
    -- Status Value
    local statusValue = Instance.new("TextLabel")
    statusValue.Name = "StatusValue"
    statusValue.Size = UDim2.new(0.5, -32, 0, 25)
    statusValue.Position = UDim2.new(0.5, 16, 0, 12)
    statusValue.BackgroundTransparency = 1
    statusValue.Text = "READY"
    statusValue.TextColor3 = UI.Theme.Success
    statusValue.TextSize = 14
    statusValue.Font = UI.Fonts.Bold
    statusValue.TextXAlignment = Enum.TextXAlignment.Right
    statusValue.Parent = frame
    
    -- Position Info
    local posLabel = Instance.new("TextLabel")
    posLabel.Name = "PosLabel"
    posLabel.Size = UDim2.new(0.5, 0, 0, 20)
    posLabel.Position = UDim2.new(0, 16, 0, 45)
    posLabel.BackgroundTransparency = 1
    posLabel.Text = "Current Position:"
    posLabel.TextColor3 = UI.Theme.TextMuted
    posLabel.TextSize = 12
    posLabel.Font = UI.Fonts.Regular
    posLabel.TextXAlignment = Enum.TextXAlignment.Left
    posLabel.Parent = frame
    
    local posValue = Instance.new("TextLabel")
    posValue.Name = "PosValue"
    posValue.Size = UDim2.new(0.5, -32, 0, 20)
    posValue.Position = UDim2.new(0.5, 16, 0, 45)
    posValue.BackgroundTransparency = 1
    posValue.Text = "0, 0, 0"
    posValue.TextColor3 = UI.Theme.Text
    posValue.TextSize = 12
    posValue.Font = UI.Fonts.Code
    posValue.TextXAlignment = Enum.TextXAlignment.Right
    posValue.Parent = frame
    
    -- Nearest CP
    local cpLabel = Instance.new("TextLabel")
    cpLabel.Name = "CPLabel"
    cpLabel.Size = UDim2.new(0.5, 0, 0, 20)
    cpLabel.Position = UDim2.new(0, 16, 0, 70)
    cpLabel.BackgroundTransparency = 1
    cpLabel.Text = "Nearest CP:"
    cpLabel.TextColor3 = UI.Theme.TextMuted
    cpLabel.TextSize = 12
    cpLabel.Font = UI.Fonts.Regular
    cpLabel.TextXAlignment = Enum.TextXAlignment.Left
    cpLabel.Parent = frame
    
    local cpValue = Instance.new("TextLabel")
    cpValue.Name = "CPValue"
    cpValue.Size = UDim2.new(0.5, -32, 0, 20)
    cpValue.Position = UDim2.new(0.5, 16, 0, 70)
    cpValue.BackgroundTransparency = 1
    cpValue.Text = "None"
    cpValue.TextColor3 = UI.Theme.Warning
    cpValue.TextSize = 12
    cpValue.Font = UI.Fonts.SemiBold
    cpValue.TextXAlignment = Enum.TextXAlignment.Right
    cpValue.Parent = frame
    
    -- Update loop
    spawn(function()
        while frame and frame.Parent do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = player.Character.HumanoidRootPart.Position
                posValue.Text = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
                
                -- Cari CP terdekat
                local nearest = FindNearestCheckpoint(pos)
                if nearest then
                    local dist = (pos - nearest.Position).Magnitude
                    cpValue.Text = string.format("CP%d (%.1f studs)", nearest.Number or 0, dist)
                    cpValue.TextColor3 = dist < 20 and UI.Theme.Success or UI.Theme.Warning
                else
                    cpValue.Text = "None"
                    cpValue.TextColor3 = UI.Theme.Warning
                end
            end
            wait(0.1)
        end
    end)
    
    return frame
end

function CreateCPFrame(parent)
    local frame = Instance.new("Frame")
    frame.Name = "CPFrame"
    frame.Size = UDim2.new(1, 0, 0, 200)
    frame.BackgroundColor3 = UI.Theme.Secondary
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.Theme.Primary
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -32, 0, 25)
    title.Position = UDim2.new(0, 16, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "CHECKPOINTS LIST"
    title.TextColor3 = UI.Theme.Text
    title.TextSize = 14
    title.Font = UI.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    -- Search Box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -32, 0, 35)
    searchBox.Position = UDim2.new(0, 16, 0, 45)
    searchBox.BackgroundColor3 = UI.Theme.Background
    searchBox.BackgroundTransparency = 0.3
    searchBox.PlaceholderText = "Search checkpoints..."
    searchBox.PlaceholderColor3 = UI.Theme.TextMuted
    searchBox.Text = ""
    searchBox.TextColor3 = UI.Theme.Text
    searchBox.TextSize = 14
    searchBox.Font = UI.Fonts.Regular
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = frame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox
    
    -- CP List
    local cpList = Instance.new("ScrollingFrame")
    cpList.Name = "CPList"
    cpList.Size = UDim2.new(1, -32, 1, -100)
    cpList.Position = UDim2.new(0, 16, 0, 90)
    cpList.BackgroundTransparency = 1
    cpList.ScrollBarThickness = 4
    cpList.ScrollBarImageColor3 = UI.Theme.Primary
    cpList.CanvasSize = UDim2.new(0, 0, 0, 0)
    cpList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    cpList.Parent = frame
    
    local cpPadding = Instance.new("UIPadding")
    cpPadding.PaddingLeft = UDim.new(0, 4)
    cpPadding.PaddingRight = UDim.new(0, 4)
    cpPadding.Parent = cpList
    
    local cpLayout = Instance.new("UIListLayout")
    cpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cpLayout.Spacing = UDim.new(0, 8)
    cpLayout.Parent = cpList
    
    -- Load checkpoints
    LoadCheckpointsToList(cpList)
    
    -- Search functionality
    searchBox.Changed:Connect(function()
        FilterCheckpoints(cpList, searchBox.Text)
    end)
    
    return frame
end

function CreateSettingsFrame(parent)
    local frame = Instance.new("Frame")
    frame.Name = "SettingsFrame"
    frame.Size = UDim2.new(1, 0, 0, 150)
    frame.BackgroundColor3 = UI.Theme.Secondary
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.Theme.Primary
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -32, 0, 25)
    title.Position = UDim2.new(0, 16, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "SETTINGS"
    title.TextColor3 = UI.Theme.Text
    title.TextSize = 14
    title.Font = UI.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    -- Auto Teleport Toggle
    local autoTeleport = CreateToggle(frame, "Auto Teleport", 45)
    autoTeleport.Toggle.Value = false
    
    -- Smooth Teleport Toggle
    local smoothTeleport = CreateToggle(frame, "Smooth Teleport", 80)
    smoothTeleport.Toggle.Value = true
    
    -- Teleport Speed Slider
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0.5, -24, 0, 20)
    speedLabel.Position = UDim2.new(0, 16, 0, 115)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Teleport Speed: 50"
    speedLabel.TextColor3 = UI.Theme.Text
    speedLabel.TextSize = 12
    speedLabel.Font = UI.Fonts.Regular
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = frame
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(0.5, -32, 0, 4)
    speedSlider.Position = UDim2.new(0.5, 16, 0, 123)
    speedSlider.BackgroundColor3 = UI.Theme.Background
    speedSlider.BackgroundTransparency = 0.5
    speedSlider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = speedSlider
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = UI.Theme.Primary
    sliderFill.Parent = speedSlider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("ImageButton")
    sliderButton.Name = "Button"
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(0.5, -8, 0.5, -8)
    sliderButton.BackgroundColor3 = UI.Theme.Text
    sliderButton.Image = "rbxassetid://6031094678"
    sliderButton.ImageColor3 = UI.Theme.Primary
    sliderButton.Parent = sliderFill
    
    -- Slider functionality
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = mouse.X - speedSlider.AbsolutePosition.X
            local percent = math.clamp(pos / speedSlider.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            local speed = math.floor(percent * 190 + 10)
            speedLabel.Text = "Teleport Speed: " .. speed
        end
    end)
    
    return frame
end

function CreateActionsFrame(parent)
    local frame = Instance.new("Frame")
    frame.Name = "ActionsFrame"
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = UI.Theme.Secondary
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.Theme.Primary
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    -- Teleport to Summit Button
    local summitBtn = CreateButton(frame, "🏔️ SUMMIT", UDim2.new(0.5, -28, 0, 40), UDim2.new(0, 16, 0, 10))
    summitBtn.BackgroundColor3 = UI.Theme.Success
    summitBtn.TextColor3 = UI.Theme.Text
    
    summitBtn.MouseButton1Click:Connect(function()
        TeleportToSummit()
    end)
    
    -- Teleport to First CP Button
    local firstCPBtn = CreateButton(frame, "📍 FIRST CP", UDim2.new(0.5, -28, 0, 40), UDim2.new(0.5, 12, 0, 10))
    firstCPBtn.BackgroundColor3 = UI.Theme.Warning
    firstCPBtn.TextColor3 = UI.Theme.Text
    
    firstCPBtn.MouseButton1Click:Connect(function()
        TeleportToFirstCP()
    end)
    
    return frame
end

function CreateToggle(parent, text, yPos)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(1, -32, 0, 30)
    toggleFrame.Position = UDim2.new(0, 16, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = UI.Theme.Text
    label.TextSize = 14
    label.Font = UI.Fonts.Regular
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("ImageButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -50, 0.5, -12)
    toggle.BackgroundColor3 = UI.Theme.Background
    toggle.BackgroundTransparency = 0.5
    toggle.Image = "rbxassetid://3570695787"
    toggle.ImageColor3 = UI.Theme.TextMuted
    toggle.ScaleType = Enum.ScaleType.Slice
    toggle.SliceCenter = Rect.new(24, 24, 24, 24)
    toggle.Parent = toggleFrame
    
    toggle.Value = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        toggle.Value = not toggle.Value
        if toggle.Value then
            toggle.ImageColor3 = UI.Theme.Success
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Success}):Play()
        else
            toggle.ImageColor3 = UI.Theme.TextMuted
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Background}):Play()
        end
    end)
    
    return {
        Frame = toggleFrame,
        Toggle = toggle
    }
end

function CreateButton(parent, text, size, position)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = UI.Theme.Primary
    button.Text = text
    button.TextColor3 = UI.Theme.Text
    button.TextSize = 14
    button.Font = UI.Fonts.Bold
    button.AutoButtonColor = false
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Primary:Lerp(UI.Theme.Text, 0.2)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Primary}):Play()
    end)
    
    return button
end

function FindAllCheckpoints()
    local checkpoints = {}
    
    -- Cari part dengan nama "Checkpoint" atau "CP" di seluruh workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(obj.Name, "Checkpoint") or string.find(obj.Name, "CP") or string.find(obj.Name, "cp")) then
            table.insert(checkpoints, obj)
        end
    end
    
    -- Urutkan berdasarkan nomor CP (kalo ada)
    table.sort(checkpoints, function(a, b)
        local numA = string.match(a.Name, "%d+") or "0"
        local numB = string.match(b.Name, "%d+") or "0"
        return tonumber(numA) < tonumber(numB)
    end)
    
    return checkpoints
end

function FindNearestCheckpoint(position)
    local nearest = nil
    local shortestDist = math.huge
    
    for _, cp in ipairs(FindAllCheckpoints()) do
        local dist = (position - cp.Position).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            nearest = cp
        end
    end
    
    return nearest
end

function LoadCheckpointsToList(cpList)
    local checkpoints = FindAllCheckpoints()
    
    for i, cp in ipairs(checkpoints) do
        local cpNumber = string.match(cp.Name, "%d+") or i
        
        local cpButton = Instance.new("TextButton")
        cpButton.Name = "CPButton"
        cpButton.Size = UDim2.new(1, 0, 0, 40)
        cpButton.BackgroundColor3 = UI.Theme.Background
        cpButton.BackgroundTransparency = 0.3
        cpButton.Text = ""
        cpButton.AutoButtonColor = false
        cpButton.Parent = cpList
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = cpButton
        
        local numberLabel = Instance.new("TextLabel")
        numberLabel.Name = "Number"
        numberLabel.Size = UDim2.new(0, 40, 1, 0)
        numberLabel.BackgroundColor3 = UI.Theme.Primary
        numberLabel.BackgroundTransparency = 0.5
        numberLabel.Text = "#" .. tostring(cpNumber)
        numberLabel.TextColor3 = UI.Theme.Text
        numberLabel.TextSize = 14
        numberLabel.Font = UI.Fonts.Bold
        numberLabel.Parent = cpButton
        
        local numCorner = Instance.new("UICorner")
        numCorner.CornerRadius = UDim.new(0, 8)
        numCorner.Parent = numberLabel
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, -120, 1, 0)
        nameLabel.Position = UDim2.new(0, 45, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = cp.Name
        nameLabel.TextColor3 = UI.Theme.Text
        nameLabel.TextSize = 14
        nameLabel.Font = UI.Fonts.Regular
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = cpButton
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "Distance"
        distLabel.Size = UDim2.new(0, 70, 1, 0)
        distLabel.Position = UDim2.new(1, -75, 0, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "?? studs"
        distLabel.TextColor3 = UI.Theme.TextMuted
        distLabel.TextSize = 12
        distLabel.Font = UI.Fonts.Code
        distLabel.Parent = cpButton
        
        -- Update distance
        spawn(function()
            while cpButton and cpButton.Parent do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - cp.Position).Magnitude
                    distLabel.Text = string.format("%.0f studs", dist)
                    
                    if dist < 20 then
                        distLabel.TextColor3 = UI.Theme.Success
                        cpButton.BackgroundColor3 = UI.Theme.Success:Lerp(UI.Theme.Background, 0.8)
                    else
                        distLabel.TextColor3 = UI.Theme.TextMuted
                        cpButton.BackgroundColor3 = UI.Theme.Background
                    end
                end
                wait(0.2)
            end
        end)
        
        -- Teleport on click
        cpButton.MouseButton1Click:Connect(function()
            TeleportToPosition(cp.Position)
        end)
        
        cpButton.MouseEnter:Connect(function()
            TweenService:Create(cpButton, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Secondary}):Play()
            TweenService:Create(numberLabel, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end)
        
        cpButton.MouseLeave:Connect(function()
            TweenService:Create(cpButton, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Background}):Play()
            TweenService:Create(numberLabel, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        end)
    end
    
    cpList.CanvasSize = UDim2.new(0, 0, 0, #checkpoints * 48)
end

function FilterCheckpoints(cpList, searchText)
    searchText = searchText:lower()
    
    for _, child in ipairs(cpList:GetChildren()) do
        if child:IsA("TextButton") and child.Name == "CPButton" then
            local nameLabel = child:FindFirstChild("Name")
            if nameLabel then
                local visible = searchText == "" or string.find(nameLabel.Text:lower(), searchText)
                child.Visible = visible
            end
        end
    end
end

function TeleportToPosition(position)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        warn("Character not found!")
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character.HumanoidRootPart
    
    -- Smooth teleport animation
    local speed = 50 -- Default speed
    local distance = (position - rootPart.Position).Magnitude
    local duration = distance / speed
    
    if duration > 0.5 then
        -- Tween animation for long distances
        local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(position)
        })
        tween:Play()
        
        -- Platform animation (kayak lagi terbang)
        if humanoid then
            humanoid.PlatformStand = true
            wait(duration)
            humanoid.PlatformStand = false
        end
    else
        -- Instant teleport for short distances
        rootPart.CFrame = CFrame.new(position)
    end
    
    -- Notifikasi
    StarterGui:SetCore("SendNotification", {
        Title = "Mountain Teleport",
        Text = "Teleported to checkpoint!",
        Icon = "rbxassetid://6031094678",
        Duration = 3
    })
end

function TeleportToSummit()
    -- Cari titik tertinggi di map (biasanya puncak)
    local highestY = -math.huge
    local summitPos = nil
    
    for _, cp in ipairs(FindAllCheckpoints()) do
        if cp.Position.Y > highestY then
            highestY = cp.Position.Y
            summitPos = cp.Position
        end
    end
    
    if summitPos then
        TeleportToPosition(summitPos)
    else
        warn("No summit found!")
    end
end

function TeleportToFirstCP()
    local checkpoints = FindAllCheckpoints()
    if #checkpoints > 0 then
        TeleportToPosition(checkpoints[1].Position)
    else
        warn("No checkpoints found!")
    end
end

-- Initialize UI
local ui = CreateUI()

-- Hotkey (F9 to toggle)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F9 then
        if ui.ScreenGui then
            ui.ScreenGui:Destroy()
        else
            ui = CreateUI()
        end
    end
end)

-- Welcome notification
StarterGui:SetCore("SendNotification", {
    Title = "Mountain Teleport Pro",
    Text = "Loaded successfully! Press F9 to toggle GUI",
    Icon = "rbxassetid://6031094678",
    Duration = 5
})

print("✅ Mountain Teleport Pro loaded!")
print("Press F9 to toggle GUI")
