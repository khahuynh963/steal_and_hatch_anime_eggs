--[[
    ===================================================================
    🥚 STEAL & HATCH ANIME EGGS! - ULTIMATE AUTO HUB V1.0
    Tự động chơi toàn diện tiếng Việt cho tựa game Steal and Hatch Anime Eggs trên Roblox!
    
    Tính năng chính:
    1. 🥚 Auto Steal Eggs (Tự động trộm trứng từ tất cả Biome / Trùm)
    2. 🏠 Auto Teleport Plot & Auto Place (Tự động ấp trứng tại Plot)
    3. ⚡ Instant Hatch 0s Hold (Mở trứng siêu tốc không cần giữ)
    4. 🏃 Auto Train & Treadmill Farm (Tự động chạy máy tập luyện tăng Speed)
    5. 💰 Auto Magnet Coins & Gems (Tự động hút toàn bộ Tiền & Kim cương)
    6. 🔄 Auto Rebirth & Auto Upgrades (Tự động Trùng sinh & Nâng cấp)
    7. 🔍 Egg ESP & Biome Teleports (Hiển thị vị trí Trứng Hiếm & Dịch chuyển)
    8. 🚀 Speed Slider, CFrame Step Boost, Noclip, Infinite Jump
    9. 🛡️ Anti-AFK 24/7 Treo máy xuyên đêm
    10. ➖ Nút Thu Nhỏ Cửa Sổ & Tắt Hẳn GUI
    ===================================================================
--]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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

-- ── Global State Settings ──
local State = {
    AutoSteal = false,
    StealPriority = "All", -- All, Mythic, Divine, Secret
    SelectedBiome = "All",
    AutoBringPlot = false,
    AutoPlaceEggs = false,
    InstantHatch = true,
    
    AutoTrain = false,
    AutoClickTrain = false,
    
    AutoCollectCoins = false,
    AutoRebirth = false,
    AutoUpgradeStats = false,
    
    EggESP = false,
    
    WalkSpeed = 16,
    EnableWalkSpeed = false,
    CFrameBoost = false,
    CFrameSpeed = 2,
    InfiniteJump = false,
    Noclip = false,
    
    AntiAFK = true
}

-- ESP Storage
local ESPHighlights = {}

-- ── Instant ProximityPrompt Hook ──
local function applyInstantPrompts()
    pcall(function()
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if State.InstantHatch then
                    prompt.HoldDuration = 0
                end
            end
        end
    end)
end

Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") and State.InstantHatch then
        descendant.HoldDuration = 0
    end
end)

-- ── Helper Functions ──
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Find Player Plot
local function getPlayerPlot()
    local plots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Tycoons")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
            if owner and (owner.Value == LocalPlayer or owner.Value == LocalPlayer.Name) then
                return plot
            end
        end
    end
    return nil
end

-- ── Main Auto Loops ──

-- 1. Anti-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end)
end)

-- 2. Fast CFrame Movement
RunService.Stepped:Connect(function()
    pcall(function()
        local char = getCharacter()
        local hrp = getRootPart()
        local hum = getHumanoid()

        if hum and State.EnableWalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end

        if hrp and hum and State.CFrameBoost and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * State.CFrameSpeed)
        end

        if State.Noclip and char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- 3. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 4. Auto Steal Eggs Loop
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoSteal then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end

                applyInstantPrompts()

                local eggSpawns = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("EggSpawns") or Workspace:FindFirstChild("Spawns")
                if not eggSpawns then
                    -- Scan Workspace for interactable eggs
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if State.AutoSteal and (obj.Name:lower():find("egg") or obj:FindFirstChildOfClass("ProximityPrompt")) then
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                            if prompt and prompt.Enabled then
                                local targetPart = obj:IsA("BasePart") and obj or (obj.Parent:IsA("BasePart") and obj.Parent or nil)
                                if targetPart then
                                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.1)
                                    fireproximityprompt(prompt)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                else
                    for _, egg in pairs(eggSpawns:GetChildren()) do
                        if not State.AutoSteal then break end
                        local prompt = egg:FindFirstChildOfClass("ProximityPrompt") or egg:FindFirstChild("Prompt", true)
                        if prompt and prompt.Enabled then
                            local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
                            if part then
                                hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                task.wait(0.1)
                                fireproximityprompt(prompt)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Auto Place Eggs at Plot
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoPlaceEggs or State.AutoBringPlot then
            pcall(function()
                local plot = getPlayerPlot()
                local hrp = getRootPart()
                if plot and hrp then
                    local hatchers = plot:FindFirstChild("Hatchers") or plot:FindFirstChild("Incubators") or plot:FindFirstChild("EggPads")
                    if hatchers then
                        for _, pad in pairs(hatchers:GetChildren()) do
                            local prompt = pad:FindFirstChildOfClass("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                local part = pad:IsA("BasePart") and pad or pad:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.1)
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    else
                        -- Teleport to plot center
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

-- 6. Auto Train / Treadmill
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoTrain then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end
                
                -- Find Treadmills or Training gear
                local trainArea = Workspace:FindFirstChild("Treadmills") or Workspace:FindFirstChild("Training") or Workspace:FindFirstChild("Machines")
                if trainArea then
                    for _, machine in pairs(trainArea:GetChildren()) do
                        local prompt = machine:FindFirstChildOfClass("ProximityPrompt", true)
                        local seat = machine:FindFirstChildOfClass("Seat", true)
                        if prompt and prompt.Enabled then
                            local part = machine:IsA("BasePart") and machine or machine:FindFirstChildWhichIsA("BasePart")
                            if part then
                                hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                task.wait(0.1)
                                fireproximityprompt(prompt)
                                break
                            end
                        end
                    end
                end
                
                -- Auto Click Train Remote if exists
                if State.AutoClickTrain then
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("train") or remote.Name:lower():find("click")) then
                            remote:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. Auto Collect Coins & Gems (Magnet)
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoCollectCoins then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("orb") or obj.Name:lower():find("drop")) then
                        obj.CFrame = hrp.CFrame
                    end
                end
            end)
        end
    end
end)

-- 8. Auto Rebirth & Auto Upgrade
task.spawn(function()
    while task.wait(1) do
        if State.AutoRebirth then
            pcall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
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
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
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

-- 9. Egg ESP System
local function updateESP()
    for obj, highlight in pairs(ESPHighlights) do
        if not obj or not obj.Parent or not State.EggESP then
            highlight:Destroy()
            ESPHighlights[obj] = nil
        end
    end

    if State.EggESP then
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if (obj.Name:lower():find("egg") or obj:FindFirstChildOfClass("ProximityPrompt")) and not ESPHighlights[obj] then
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

task.spawn(function()
    while task.wait(2) do
        if State.EggESP then
            updateESP()
        end
    end
end)

-- ── MODERN MOBILE & PC DRAGGABLE GUI ──
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnimeEggsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiContainer()

-- Main Outer Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(255, 120, 0)
MainUIStroke.Thickness = 2
MainUIStroke.Parent = MainFrame

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -125, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🥚 TRỘM & ẤP TRỨNG ANIME - HUB V1.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Minimize Button (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -72, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.Parent = TopBar

local MinimizeBtnCorner = Instance.new("UICorner")
MinimizeBtnCorner.CornerRadius = UDim.new(0, 6)
MinimizeBtnCorner.Parent = MinimizeBtn

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = Color3.fromRGB(100, 110, 140)
MinStroke.Thickness = 1
MinStroke.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Đã thu nhỏ!",
            Text = "Bấm icon quả trứng 🥚 bên trái màn hình để mở lại giao diện!",
            Duration = 3
        })
    end)
end)

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Toggle GUI Floating Button (Mobile Support & Restore GUI)
local MobileToggleBtn = Instance.new("TextButton")
MobileToggleBtn.Name = "MobileToggleBtn"
MobileToggleBtn.Size = UDim2.new(0, 50, 0, 50)
MobileToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
MobileToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
MobileToggleBtn.Text = "🥚"
MobileToggleBtn.TextSize = 24
MobileToggleBtn.Parent = ScreenGui

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(1, 0)
MobileCorner.Parent = MobileToggleBtn

local MobileStroke = Instance.new("UIStroke")
MobileStroke.Color = Color3.fromRGB(255, 255, 255)
MobileStroke.Thickness = 2
MobileStroke.Parent = MobileToggleBtn

MobileToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Make Main UI Draggable
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar Tabs Container
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.PaddingLeft = UDim.new(0, 6)
SidebarPadding.PaddingRight = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

-- Content Pages Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -140, 1, -42)
ContentFrame.Position = UDim2.new(0, 140, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
    page.Visible = false
    page.Parent = ContentFrame

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 10)
    pagePadding.PaddingLeft = UDim.new(0, 10)
    pagePadding.PaddingRight = UDim.new(0, 10)
    pagePadding.PaddingBottom = UDim.new(0, 10)
    pagePadding.Parent = page

    Pages[name] = page
    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for tName, pFrame in pairs(Pages) do
            pFrame.Visible = (tName == name)
            TabButtons[tName].BackgroundColor3 = (tName == name) and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(24, 28, 40)
            TabButtons[tName].TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 190, 210)
        end
    end)

    return page
end

-- Helper: Toggle UI Component
local function addToggle(page, text, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 235, 245)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 44, 0, 24)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 65, 80)
    toggleBtn.Text = defaultState and "BẬT" or "TẮT"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.Parent = frame

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 12)
    tCorner.Parent = toggleBtn

    local state = defaultState
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 65, 80)
        toggleBtn.Text = state and "BẬT" or "TẮT"
        callback(state)
    end)
end

-- Helper: Action Button Component
local function addButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 140, 0)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- ── BUILD TABS (TIẾNG VIỆT) ──
local StealPage = createTab("Trộm & Ấp", "🥚")
local FarmPage = createTab("Cày & Tập", "⚡")
local ESPPage = createTab("ESP & Teleport", "🔍")
local PlayerPage = createTab("Chỉ Số Nhân Vật", "🏃")
local SettingsPage = createTab("Cài Đặt", "⚙️")

-- Select first tab by default
Pages["Trộm & Ấp"].Visible = true
TabButtons["Trộm & Ấp"].BackgroundColor3 = Color3.fromRGB(255, 120, 0)
TabButtons["Trộm & Ấp"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ── TAB 1: TRỘM & ẤP ──
addToggle(StealPage, "Tự Động Trộm Trứng (Auto Teleport)", State.AutoSteal, function(v) State.AutoSteal = v end)
addToggle(StealPage, "Tự Động Mang Về Base & Đặt Vào Máy Ấp", State.AutoPlaceEggs, function(v) State.AutoPlaceEggs = v end)
addToggle(StealPage, "Mở Trứng Tức Thì (0 Giây Hold Prompt)", State.InstantHatch, function(v)
    State.InstantHatch = v
    applyInstantPrompts()
end)

-- ── TAB 2: CÀY & TẬP ──
addToggle(FarmPage, "Tự Động Luyện Tập (Máy Tập/Treadmill)", State.AutoTrain, function(v) State.AutoTrain = v end)
addToggle(FarmPage, "Tự Động Nhấn Remote Luyện Tập", State.AutoClickTrain, function(v) State.AutoClickTrain = v end)
addToggle(FarmPage, "Tự Động Hút Tiền Xu & Kim Cương", State.AutoCollectCoins, function(v) State.AutoCollectCoins = v end)
addToggle(FarmPage, "Tự Động Trùng Sinh (Auto Rebirth)", State.AutoRebirth, function(v) State.AutoRebirth = v end)
addToggle(FarmPage, "Tự Động Nâng Cấp Chỉ Số (Auto Upgrade)", State.AutoUpgradeStats, function(v) State.AutoUpgradeStats = v end)

-- ── TAB 3: ESP & DỊCH CHUYỂN ──
addToggle(ESPPage, "Bật ESP Trứng (Nhìn Xuyên Tường Trứng Hiếm)", State.EggESP, function(v)
    State.EggESP = v
    updateESP()
end)

addButton(ESPPage, "🏠 Dịch Chuyển Về Căn Cứ (Plot / Base)", function()
    local plot = getPlayerPlot()
    local hrp = getRootPart()
    if plot and hrp then
        local spawnPad = plot:FindFirstChild("Spawn") or plot:FindFirstChildWhichIsA("BasePart")
        if spawnPad then
            hrp.CFrame = spawnPad.CFrame * CFrame.new(0, 4, 0)
        end
    end
end)

addButton(ESPPage, "⚡ Dịch Chuyển Đến Khu Luyện Tập", function()
    local train = Workspace:FindFirstChild("Treadmills") or Workspace:FindFirstChild("Training")
    local hrp = getRootPart()
    if train and hrp then
        local part = train:IsA("BasePart") and train or train:FindFirstChildWhichIsA("BasePart")
        if part then
            hrp.CFrame = part.CFrame * CFrame.new(0, 4, 0)
        end
    end
end)

-- ── TAB 4: CHỈ SỐ NHÂN VẬT ──
addToggle(PlayerPage, "Bật Tốc Độ Chạy Tùy Chỉnh", State.EnableWalkSpeed, function(v)
    State.EnableWalkSpeed = v
    if not v then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
end)

addButton(PlayerPage, "🚀 Nâng Tốc Độ: 50 Speed", function()
    State.WalkSpeed = 50
    State.EnableWalkSpeed = true
end)

addButton(PlayerPage, "⚡ Siêu Tốc Độ: 120 Speed", function()
    State.WalkSpeed = 120
    State.EnableWalkSpeed = true
end)

addToggle(PlayerPage, "Lướt CFrame Siêu Mượt (CFrame Step)", State.CFrameBoost, function(v) State.CFrameBoost = v end)
addToggle(PlayerPage, "Nhảy Vô Hạn (Infinite Jump)", State.InfiniteJump, function(v) State.InfiniteJump = v end)
addToggle(PlayerPage, "Đi Xuyên Tường (Noclip)", State.Noclip, function(v) State.Noclip = v end)

-- ── TAB 5: CÀI ĐẶT ──
addToggle(SettingsPage, "Chống Văng Game Anti-AFK 24/7", State.AntiAFK, function(v) State.AntiAFK = v end)

addButton(SettingsPage, "🔄 Vào Lại Server Hiện Tại", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

addButton(SettingsPage, "🌐 Chuyển Server Mới (Server Hop)", function()
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

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Trộm & Ấp Trứng Anime",
        Text = "Phiên bản Tiếng Việt V1.1 đã sẵn sàng!",
        Duration = 4
    })
end)

print("🥚 [STEAL & HATCH ANIME EGGS] Ultimate Auto Hub V1.1 Tiếng Việt Đã Sẵn Sàng!")
