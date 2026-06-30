-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox + Hiệu Ứng Ngôi Sao Cầu Vồng Bay Phấp Phới Đập Bass Khớp 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2
LocalSound.Looped = true

-- QUẢN LÝ BOOMBOX VÀ HIỆU ỨNG
local FakeBoombox = nil
local StarEmitter = nil -- Bộ phát ngôi sao phấp phới
local VisualizerBars = {}
local loopConnection = nil 

local function CreateFakeBoombox()
    -- Dọn dẹp cũ tránh xung đột luồng khi reset nhân vật hoặc đổi bài
    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    if FakeBoombox then FakeBoombox:Destroy() FakeBoombox = nil end
    for _, bar in pairs(VisualizerBars) do if bar.Part then bar.Part:Destroy() end end
    VisualizerBars = {}
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then return end
    
    local torso = character:WaitForChild("UpperTorso", 5) or character:WaitForChild("Torso", 5)
    if not torso then return end
    
    -- 1. Tạo Khối Boombox Chính (Neon Cầu Vồng)
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Massless = true
    part.Parent = character
    FakeBoombox = part
    
    local baseSize = Vector3.new(1.8, 1.2, 0.4)
    part.Size = baseSize
    
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- =======================================================
    -- [CẢI TIẾN]: TẠO HẠT NGÔI SAO BAY PHẤP PHỚI LẤP LÁNH XUNG QUANH
    -- =======================================================
    StarEmitter = Instance.new("ParticleEmitter")
    StarEmitter.Texture = "rbxassetid://258128363" -- ID hạt lấp lánh/ngôi sao chuẩn, hiển thị 100% không lo bị lỗi
    StarEmitter.LightEmission = 0.8 -- Độ phát sáng lung linh
    StarEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),   -- Lúc vừa sinh ra hơi mờ nhẹ
        NumberSequenceKeypoint.new(0.2, 0), -- Hiện rõ ràng lấp lánh
        NumberSequenceKeypoint.new(0.8, 0.3),-- Mờ dần khi bay xa
        NumberSequenceKeypoint.new(1, 1)    -- Biến mất hẳn phấp phới
    })
    StarEmitter.Lifetime = NumberRange.new(0.8, 1.8) -- Thời gian sao bay lơ lửng trước khi tan biến
    StarEmitter.Rate = 15 -- Số lượng sao bay mặc định khi nhạc nhẹ
    StarEmitter.Speed = NumberRange.new(1.5, 3.5) -- Tốc độ bay thoang thoảng phấp phới
    StarEmitter.SpreadAngle = Vector2.new(60, 60) -- Tỏa rộng ra xung quanh người và loa
    StarEmitter.VelocityDiagonalRotation = true -- Giúp hạt tự xoay nghiêng lấp lánh khi bay
    StarEmitter.Parent = part
    -- =======================================================

    -- 2. Tạo các thanh sóng nhạc trên đỉnh loa
    local barCount = 5 
    local barWidth = baseSize.X / barCount 
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        bar.Size = Vector3.new(barWidth, 0.1, 0.2)
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        local xOffset = -(baseSize.X / 2) + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, baseSize.Y / 2, 0) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- 3. VÒNG LẶP XỬ LÝ ĐẬP BASS KHỚP 100% + ĐỔI MÀU CẦU VỒNG HẠT
    local hue = 0
    
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- Thuật toán bóc tách nhịp Bass (Lọc bỏ âm cực nhỏ, khuếch đại nhịp trống)
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp((loudness - 50) / 270, 0, 1) 
        
        -- Cầu vồng đổi màu mượt mà theo thời gian
        local speedMultiplier = 1 + (normLoudness * 3.5)
        hue = (hue + (0.5 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        
        -- Áp màu cho Boombox
        part.Color = mainColor
        
        -- ĐẬP BASS SIÊU KHỚP: Loa giật nảy cực mạnh theo nhịp trống thực tế
        local scaleFactor = 1 + (normLoudness * 0.38) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * scaleFactor, baseSize.Z * scaleFactor)
        
        -- ĐỒNG BỘ HIỆU ỨNG HẠT NGÔI SAO THEO BASS
        if StarEmitter then
            -- Khi Bass đập mạnh, sao phóng ra dồn dập (lên tới 60 hạt/giây), nhạc tắt thì bay lai rai phấp phới
            StarEmitter.Rate = 12 + (normLoudness * 48)
            -- Kích thước hạt ngôi sao tự động to lên theo nhịp Bass
            StarEmitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.25 * scaleFactor),
                NumberSequenceKeypoint.new(1, 0.55 * scaleFactor)
            })
            -- Ép các ngôi sao đổi màu cầu vồng liên tục giống hệt màu loa!
            StarEmitter.Color = ColorSequence.new(mainColor)
        end
        
        -- Cập nhật thanh sóng nhạc nhấp nhô nhạy bén
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                local waveFactor = math.sin(tick() * 16 + item.Index) * 0.15
                local targetHeight = math.clamp((normLoudness * 0.75) + waveFactor, 0.05, 0.85)
                
                item.Part.Size = Vector3.new(barWidth * scaleFactor, targetHeight, item.Part.Size.Z)
                
                local currentTop = (baseSize.Y * scaleFactor) / 2
                local currentXOffset = (-(baseSize.X / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, currentTop + (targetHeight / 2), 0)
                
                local barHue = (hue + (item.Index * 18)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE (Khóa dính mãi mãi, hồi sinh tự tạo lại vòng hạt ngôi sao)
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) 
    CreateFakeBoombox() 
end)

-- GIAO DIỆN GUI (Giữ nguyên menu điều khiển cũ của bạn)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", HideBtn)
HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "TP 🎵"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        CreateFakeBoombox()
        print("Thanh Phuc đã kích hoạt hiệu ứng Ngôi sao bay phấp phới cầu vồng thành công!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)

