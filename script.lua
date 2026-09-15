--[[
    ===================================================================
    🥚 STEAL & HATCH ANIME EGGS! - ULTIMATE AUTO HUB V2.1 (ULTRA SMOOTH)
    Tối ưu hóa hiệu năng 60 FPS: Loại bỏ hoàn toàn giật lag, di chuyển mượt mà!
    Tương thích 100% Delta Executor (Android & PC), Wave, Codex, Fluxus.
    ===================================================================
--]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ── Safe GUI Container Helper ──
local function getGuiContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        elseif syn and syn.protect_gui then
            local f = Instance.new("Folder")
            syn.protect_gui(f)
            f.Parent = game:GetService("CoreGui")
            container = f
        elseif game:GetService("CoreGui") then
            container = game:GetService("CoreGui")
        end
    end)
    if not container then
        pcall(function()
            container = LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    return container
end

-- Clear old GUI instances
pcall(function()
    local c = getGuiContainer()
    if c and c:FindFirstChild("StealAnimeEggsGui") then
        c.StealAnimeEggsGui:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("StealAnimeEggsGui") then
        game:GetService("CoreGui").StealAnimeEggsGui:Destroy()
    end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("StealAnimeEggsGui") then
        LocalPlayer.PlayerGui.StealAnimeEggsGui:Destroy()
    end
end)

-- ── State Variables ──
local State = {
    AutoSteal = false,
    AutoBringPlot = false,
    AutoPlaceEggs = false,
    InstantHatch = true,
    
    AntiTrap = true,
    AntiStun = true,
    FlyAboveGround = true,
    
    AutoTrain = false,
    AutoClickTrain = false,
    
    AutoCollectCoins = false,
    AutoRebirth = false,
    AutoUpgradeStats = false,
    
    EggESP = false,
    FPSBoost = false,
    
    SpeedEnabled = false,
    WalkSpeed = 150,
    CFrameBoost = true,
    CFrameSpeed = 6,
    InfiniteJump = false,
    Noclip = false,
    
    AntiAFK = true
}

local ESPHighlights = {}

-- ── High-Performance Event-Driven Cache (Zero Lag, 60 FPS) ──
local Cache = {
    Traps = {},
    Eggs = {},
    Drops = {},
    Prompts = {}
}

local function classifyInstance(obj)
    if not obj or not obj.Parent then return end
    pcall(function()
        local name = obj.Name:lower()
        if obj:IsA("ProximityPrompt") then
            table.insert(Cache.Prompts, obj)
            if State.InstantHatch then
                obj.RequiresLineOfSight = false
                obj.HoldDuration = 0
            end
        end
        if name:find("trap") or name:find("spike") or name:find("mine") or name:find("laser") or name:find("hazard") or name:find("bear") then
            table.insert(Cache.Traps, obj)
            if State.AntiTrap then
                if obj:IsA("BasePart") then
                    obj.CanTouch = false
                    obj.CanCollide = false
                    local t = obj:FindFirstChildOfClass("TouchTransmitter")
                    if t then t:Destroy() end
                elseif obj:IsA("Model") then
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanTouch = false
                            p.CanCollide = false
                            local t = p:FindFirstChildOfClass("TouchTransmitter")
                            if t then t:Destroy() end
                        end
                    end
                end
            end
        elseif name:find("egg") or obj:FindFirstChildOfClass("ProximityPrompt") then
            table.insert(Cache.Eggs, obj)
        elseif obj:IsA("BasePart") and (name:find("coin") or name:find("gem") or name:find("orb") or name:find("drop")) then
            table.insert(Cache.Drops, obj)
        end
    end)
end

local function cleanCacheTable(t)
    local i = 1
    while i <= #t do
        if not t[i] or not t[i].Parent then
            table.remove(t, i)
        else
            i = i + 1
        end
    end
end

-- Initialize Cache asynchronously without causing lag spike
task.defer(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        classifyInstance(obj)
    end
end)

Workspace.DescendantAdded:Connect(function(descendant)
    classifyInstance(descendant)
end)

-- Periodic light cleanup every 5s
task.spawn(function()
    while true do
        task.wait(5)
        cleanCacheTable(Cache.Traps)
        cleanCacheTable(Cache.Eggs)
        cleanCacheTable(Cache.Drops)
        cleanCacheTable(Cache.Prompts)
    end
end)

-- ── Helper Functions (Safe & Non-Yielding) ──
local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getPlayerPlot()
    local plots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Tycoons")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
            if owner and (owner.Value == LocalPlayer or owner.Value == LocalPlayer.Name) then
                return plot
            end
        end
    end
    return nil
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt)
        end
    end)
end

-- ── Anti-AFK Setup ──
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end)
end)

-- ── Silky-Smooth Movement & CFrame Engine (Delta-Time Normalized) ──
local lastTick = tick()
RunService.RenderStepped:Connect(function()
    local currentTick = tick()
    local dt = currentTick - lastTick
    lastTick = currentTick
    if dt > 0.1 then dt = 0.016 end -- clamp any lag spike

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Smooth WalkSpeed enforcement
    if State.SpeedEnabled then
        if hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end

    -- Delta-time normalized smooth CFrame boost (siêu mượt không khựng)
    if State.CFrameBoost and hum.MoveDirection.Magnitude > 0 then
        local boostFactor = State.CFrameSpeed * 18 * dt
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * boostFactor)
    end

    -- Hover trên không né trap dưới đất
    if State.FlyAboveGround and hum.MoveDirection.Magnitude > 0 then
        if hrp.Velocity.Y < 0 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        end
    end

    -- Noclip nhẹ nhàng
    if State.Noclip and hum.MoveDirection.Magnitude > 0 then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ── Infinite Jump ──
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎨 GIAO DIỆN ĐIỀU KHIỂN CHUẨN MOBILE & PC (DELTA COMPACT)
-- ═══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnimeEggsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiContainer()

-- Main Frame (Kích thước tối ưu gọn gàng cho Mobile & PC)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 440)
MainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 140, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Topbar Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(26, 32, 48)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🥚 TRỘM & ẤP TRỨNG ANIME HUB"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Buttons on TopBar (Minimize & Close)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -64, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(220, 230, 250)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 13
MinBtn.Parent = TopBar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar
local clsCorner = Instance.new("UICorner")
clsCorner.CornerRadius = UDim.new(0, 6)
clsCorner.Parent = CloseBtn

-- Floating Icon (Bật/Tắt thu nhỏ cho Mobile)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 15, 0.35, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
FloatingBtn.Text = "🥚"
FloatingBtn.TextSize = 24
FloatingBtn.Visible = false
FloatingBtn.Parent = ScreenGui
local fltCorner = Instance.new("UICorner")
fltCorner.CornerRadius = UDim.new(1, 0)
fltCorner.Parent = FloatingBtn
local fltStroke = Instance.new("UIStroke")
fltStroke.Color = Color3.fromRGB(255, 255, 255)
fltStroke.Thickness = 2
fltStroke.Parent = FloatingBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingBtn.Visible = true
end)

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Draggable Helper Function
local function makeDraggable(guiObject, handle)
    handle = handle or guiObject
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame, TopBar)
makeDraggable(FloatingBtn)

-- Live Status Bar
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, -20, 0, 26)
StatusFrame.Position = UDim2.new(0, 10, 0, 46)
StatusFrame.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame
local sfCorner = Instance.new("UICorner")
sfCorner.CornerRadius = UDim.new(0, 6)
sfCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -12, 1, 0)
StatusLabel.Position = UDim2.new(0, 6, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "🟢 Trạng thái: Siêu Mượt 60 FPS"
StatusLabel.TextColor3 = Color3.fromRGB(0, 230, 180)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

local function setStatus(msg)
    StatusLabel.Text = "🟢 " .. msg
end

-- Scroll Content Frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -85)
Scroll.Position = UDim2.new(0, 10, 0, 78)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.Parent = Scroll

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
end)

-- Component Helper: Section Header
local function createSectionHeader(titleText)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = "─── " .. string.upper(titleText) .. " ───"
    lbl.TextColor3 = Color3.fromRGB(255, 165, 0)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 12
    lbl.Parent = Scroll
end

-- Component Helper: Toggle Button
local function createToggle(titleText, defaultVal, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = defaultVal and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(28, 35, 50)
    btn.Text = titleText .. ": " .. (defaultVal and "BẬT" or "TẮT")
    btn.TextColor3 = defaultVal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 215, 230)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = defaultVal and Color3.fromRGB(0, 220, 120) or Color3.fromRGB(50, 62, 85)
    bStroke.Parent = btn

    local state = defaultVal
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(28, 35, 50)
        btn.Text = titleText .. ": " .. (state and "BẬT" or "TẮT")
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 215, 230)
        bStroke.Color = state and Color3.fromRGB(0, 220, 120) or Color3.fromRGB(50, 62, 85)
        callback(state)
    end)

    return btn
end

-- Component Helper: Action Button
local function createButton(titleText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(38, 48, 70)
    btn.Text = titleText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(255, 140, 0)
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return btn
end

-- ═══════════════════════════════════════════════════════════
-- 🎛️ BUILD CONTROLS & FEATURES
-- ═══════════════════════════════════════════════════════════

-- SECTION 1: TRỘM & ẤP TRỨNG
createSectionHeader("🥚 Trộm & Ấp Trứng")
createToggle("Tự Động Trộm Trứng (Auto Steal)", State.AutoSteal, function(v)
    State.AutoSteal = v
    setStatus(v and "Đang trộm trứng mượt mà..." or "Đã dừng trộm trứng.")
end)
createToggle("Tự Đem Trứng Về Base & Xếp Máy", State.AutoPlaceEggs, function(v) State.AutoPlaceEggs = v end)
createToggle("Mở Trứng Tức Thì (0s Hold Prompt)", State.InstantHatch, function(v)
    State.InstantHatch = v
    for _, prompt in ipairs(Cache.Prompts) do
        if prompt and prompt.Parent then
            prompt.RequiresLineOfSight = false
            prompt.HoldDuration = 0
        end
    end
end)

-- SECTION 2: NÉ TRAP & BẢO VỆ
createSectionHeader("🛡️ Né Trap & Bảo Vệ")
createToggle("Né & Vô Hiệu Hóa Mọi Trap (Bẫy/Gai)", State.AntiTrap, function(v) State.AntiTrap = v end)
createToggle("Chống Kẹp Bẫy / Khựng (Anti-Stun)", State.AntiStun, function(v) State.AntiStun = v end)
createToggle("Bay Lơ Lửng Trên Không (Tránh Bẫy)", State.FlyAboveGround, function(v) State.FlyAboveGround = v end)

-- SECTION 3: CÀY TẬP & TIỀN TÀI
createSectionHeader("⚡ Cày Tập & Tiền Tài")
createToggle("Tự Động Tập Luyện (Treadmill)", State.AutoTrain, function(v)
    State.AutoTrain = v
    setStatus(v and "Đang tự động luyện tập..." or "Đã dừng luyện tập.")
end)
createToggle("Tự Động Nhấn Remote Tập Luyện", State.AutoClickTrain, function(v) State.AutoClickTrain = v end)
createToggle("Hút Toàn Bộ Tiền & Kim Cương", State.AutoCollectCoins, function(v) State.AutoCollectCoins = v end)
createToggle("Tự Động Trùng Sinh (Auto Rebirth)", State.AutoRebirth, function(v) State.AutoRebirth = v end)
createToggle("Tự Động Nâng Cấp Chỉ Số (Upgrade)", State.AutoUpgradeStats, function(v) State.AutoUpgradeStats = v end)

-- SECTION 4: SIÊU TỐC ĐỘ & CFRAME
createSectionHeader("🏃 Siêu Tốc Độ & CFrame")
createToggle("Bật Tốc Độ Chạy (WalkSpeed)", State.SpeedEnabled, function(v)
    State.SpeedEnabled = v
    if not v then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
end)
createButton("⚡ Chọn Tốc Độ: 150 Speed", function()
    State.WalkSpeed = 150
    State.SpeedEnabled = true
    setStatus("Đã đặt tốc độ: 150 Speed")
end)
createButton("🚀 Chọn Tốc Độ: 300 Speed", function()
    State.WalkSpeed = 300
    State.SpeedEnabled = true
    setStatus("Đã đặt tốc độ: 300 Speed")
end)
createButton("🌪️ Chọn Tốc Độ: 500 Speed", function()
    State.WalkSpeed = 500
    State.SpeedEnabled = true
    setStatus("Đã đặt tốc độ: 500 Speed")
end)

createToggle("Lướt CFrame Siêu Mượt (Không Giật)", State.CFrameBoost, function(v) State.CFrameBoost = v end)
createButton("🔹 Lướt CFrame: x4 (Mượt Mà)", function()
    State.CFrameSpeed = 4
    State.CFrameBoost = true
    setStatus("Đã đặt CFrame: x4")
end)
createButton("⚡ Lướt CFrame: x8 (Cực Nhanh)", function()
    State.CFrameSpeed = 8
    State.CFrameBoost = true
    setStatus("Đã đặt CFrame: x8")
end)
createButton("🌪️ Lướt CFrame: x15 (Thần Tốc)", function()
    State.CFrameSpeed = 15
    State.CFrameBoost = true
    setStatus("Đã đặt CFrame: x15")
end)

createToggle("Nhảy Vô Hạn Trên Không", State.InfiniteJump, function(v) State.InfiniteJump = v end)
createToggle("Đi Xuyên Tường (Noclip)", State.Noclip, function(v) State.Noclip = v end)

-- SECTION 5: ESP & DỊCH CHUYỂN
createSectionHeader("🔍 ESP & Dịch Chuyển")
createToggle("Bật ESP Trứng Hiếm Xuyên Tường", State.EggESP, function(v) State.EggESP = v end)
createButton("🏠 Dịch Chuyển Về Căn Cứ (Plot)", function()
    local plot = getPlayerPlot()
    local hrp = getRootPart()
    if plot and hrp then
        local spawnPad = plot:FindFirstChild("Spawn") or plot:FindFirstChildWhichIsA("BasePart")
        if spawnPad then
            hrp.CFrame = spawnPad.CFrame * CFrame.new(0, 5, 0)
            setStatus("Đã dịch chuyển về Base!")
        end
    end
end)
createButton("⚡ Dịch Chuyển Đến Khu Tập Luyện", function()
    local train = Workspace:FindFirstChild("Treadmills") or Workspace:FindFirstChild("Training")
    local hrp = getRootPart()
    if train and hrp then
        local part = train:IsA("BasePart") and train or train:FindFirstChildWhichIsA("BasePart")
        if part then
            hrp.CFrame = part.CFrame * CFrame.new(0, 5, 0)
            setStatus("Đã dịch chuyển đến Khu Tập Luyện!")
        end
    end
end)

-- SECTION 6: CÀI ĐẶT & TỐI ƯU FPS
createSectionHeader("⚙️ Cài Đặt & Chống Lag")
createToggle("⚡ Chế Độ Siêu Mượt 60 FPS (Giảm Lag)", State.FPSBoost, function(v)
    State.FPSBoost = v
    if v then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("PostEffect") then fx.Enabled = false end
            end
            settings().Rendering.QualityLevel = 1
        end)
        setStatus("Đã bật chế độ Siêu Mượt 60 FPS!")
    end
end)
createToggle("Chống Văng Game Anti-AFK 24/7", State.AntiAFK, function(v) State.AntiAFK = v end)
createButton("🔄 Vào Lại Server Hiện Tại", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)
createButton("🌐 Đổi Server Mới (Server Hop)", function()
    pcall(function()
        local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local req = game:HttpGet(sfUrl)
        if req then
            local data = game:GetService("HttpService"):JSONDecode(req)
            if data and data.data then
                for _, server in pairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        break
                    end
                end
            end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- 🔄 BACKGROUND AUTO WORKERS (SỬ DỤNG CACHE - ZERO LAG)
-- ═══════════════════════════════════════════════════════════

-- 1. Auto Steal Eggs Worker (Sử dụng Cache, không quét toàn bộ map)
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoSteal then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end

                local hoverOffset = (State.FlyAboveGround or State.AntiTrap) and 4.5 or 3

                for _, egg in ipairs(Cache.Eggs) do
                    if not State.AutoSteal then break end
                    if egg and egg.Parent then
                        local prompt = egg:IsA("ProximityPrompt") and egg or egg:FindFirstChildOfClass("ProximityPrompt") or egg:FindFirstChild("Prompt", true)
                        if prompt and prompt.Enabled then
                            local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
                            if part then
                                hrp.CFrame = part.CFrame * CFrame.new(0, hoverOffset, 0)
                                task.wait(0.08)
                                triggerPrompt(prompt)
                                task.wait(0.12)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Place Eggs at Plot Worker
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoPlaceEggs or State.AutoBringPlot then
            pcall(function()
                local plot = getPlayerPlot()
                local hrp = getRootPart()
                if plot and hrp then
                    local hatchers = plot:FindFirstChild("Hatchers") or plot:FindFirstChild("Incubators") or plot:FindFirstChild("EggPads")
                    if hatchers then
                        for _, pad in ipairs(hatchers:GetChildren()) do
                            local prompt = pad:FindFirstChildOfClass("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                local part = pad:IsA("BasePart") and pad or pad:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.08)
                                    triggerPrompt(prompt)
                                end
                            end
                        end
                    else
                        local spawnPad = plot:FindFirstChild("Spawn") or plot:FindFirstChildWhichIsA("BasePart")
                        if spawnPad then
                            hrp.CFrame = spawnPad.CFrame * CFrame.new(0, 4, 0)
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Anti-Trap Worker (Tắt bẫy ngay lập tức từ Cache)
task.spawn(function()
    while true do
        task.wait(1.0)
        if State.AntiTrap then
            pcall(function()
                for _, obj in ipairs(Cache.Traps) do
                    if obj and obj.Parent then
                        if obj:IsA("BasePart") then
                            obj.CanTouch = false
                            obj.CanCollide = false
                        elseif obj:IsA("Model") then
                            for _, part in ipairs(obj:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanTouch = false
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Anti-Stun Worker (Nhẹ nhàng & không khựng)
task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AntiStun then
            pcall(function()
                local hum = getHumanoid()
                if hum then
                    hum.PlatformStand = false
                    local s = hum:GetState()
                    if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.PlatformStanding then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
    end
end)

-- 5. Auto Train Worker
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoTrain then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end

                local trainArea = Workspace:FindFirstChild("Treadmills") or Workspace:FindFirstChild("Training") or Workspace:FindFirstChild("Machines")
                if trainArea then
                    for _, machine in ipairs(trainArea:GetChildren()) do
                        local prompt = machine:FindFirstChildOfClass("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            local part = machine:IsA("BasePart") and machine or machine:FindFirstChildWhichIsA("BasePart")
                            if part then
                                hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                task.wait(0.08)
                                triggerPrompt(prompt)
                                break
                            end
                        end
                    end
                end

                if State.AutoClickTrain then
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("train") or remote.Name:lower():find("click")) then
                            remote:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Collect Coins & Drops Worker (Từ Cache Drops)
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoCollectCoins then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end

                for _, obj in ipairs(Cache.Drops) do
                    if obj and obj.Parent and obj:IsA("BasePart") then
                        obj.CFrame = hrp.CFrame
                    end
                end
            end)
        end
    end
end)

-- 7. Auto Rebirth & Upgrade Worker
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoRebirth then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        if remote.Name:lower():find("rebirth") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer()
                            else
                                remote:InvokeServer()
                            end
                        end
                    end
                end
            end)
        end
        if State.AutoUpgradeStats then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():find("upgrade") or remote.Name:lower():find("buy")) then
                        remote:FireServer("Speed")
                        remote:FireServer("Storage")
                        remote:FireServer("Multiplier")
                    end
                end
            end)
        end
    end
end)

-- 8. Egg ESP Worker
task.spawn(function()
    while true do
        task.wait(2.5)
        for obj, hl in pairs(ESPHighlights) do
            if not obj or not obj.Parent or not State.EggESP then
                pcall(function() hl:Destroy() end)
                ESPHighlights[obj] = nil
            end
        end
        if State.EggESP then
            pcall(function()
                for _, obj in ipairs(Cache.Eggs) do
                    if obj and obj.Parent and not ESPHighlights[obj] then
                        if obj:IsA("Model") or obj:IsA("BasePart") then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = obj
                            hl.FillColor = Color3.fromRGB(255, 170, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Parent = getGuiContainer()
                            ESPHighlights[obj] = hl
                        end
                    end
                end
            end)
        end
    end
end)

-- ── Load Notification ──
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Trộm & Ấp Trứng Anime",
        Text = "Bản V2.1 Siêu Mượt 60 FPS Đã Sẵn Sàng!",
        Duration = 4
    })
end)

print("🥚 [STEAL & HATCH ANIME EGGS] Ultimate Auto Hub V2.1 (Ultra Smooth) Loaded Successfully!")
