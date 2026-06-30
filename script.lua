-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox + Ngôi Sao Cầu Vồng 3D Đập Bass Siêu Khớp 💟
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
local LeftStar = nil
local RightStar = nil
local VisualizerBars = {}
local loopConnection = nil 

local function CreateFakeBoombox()
    -- Dọn dẹp cũ tránh xung đột luồng
    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    if FakeBoombox then FakeBoombox:Destroy() FakeBoombox = nil end
    if LeftStar then LeftStar:Destroy() LeftStar = nil end
    if RightStar then RightStar:Destroy() RightStar = nil end
    for _, bar in pairs(VisualizerBars) do if bar.Part then bar.Part:Destroy() end end
    VisualizerBars = {}
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then return end
    
    local torso = character:WaitForChild("UpperTorso", 5) or character:WaitForChild("Torso", 5)
    if not torso then return end
    
    -- 1. Tạo Khối Boombox Chính
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
    
    -- 2. TẠO NGÔI SAO 3D ĐÍNH CHẶT VÀO MẶT TRƯỚC/SAU BOOMBOX
    local function CreateStarMesh(name, offsetCFrame)
        local star = Instance.new("SpecialMesh")
        star.MeshType = Enum.MeshType.FileMesh
        star.MeshId = "rbxassetid://6342045585" -- ID Mesh hình ngôi sao chuẩn 3D lấp lánh của Roblox
        
        local starPart = Instance.new("Part")
        starPart.Name = name
        starPart.Material = Enum.Material.Neon
        starPart.CanCollide = false
        starPart.Massless = true
        starPart.Size = Vector3.new(0.6, 0.6, 0.2)
        star.Parent = starPart
        starPart.Parent = character
        
        local starWeld = Instance.new("Weld")
        starWeld.Part0 = part
        starWeld.Part1 = starPart
        starWeld.C0 = offsetCFrame
        starWeld.Parent = starPart
        
        return starPart, starWeld
    end
    
    -- Đính 2 ngôi sao vào 2 bên rìa của Boombox nhìn cho cân đối và lấp lánh
    local leftStarPart, leftStarWeld = CreateStarMesh("LeftStar", CFrame.new(-0.6, 0, 0.22))
    local rightStarPart, rightStarWeld = CreateStarMesh("RightStar", CFrame.new(0.6, 0, 0.22))
    
    -- 3. Tạo các thanh sóng nhạc trên đỉnh loa
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
    
    -- 4. VÒNG LẶP XỬ LÝ ĐẬP BASS SIÊU KHỚP VÀ CHẠY MÀU CẦU VỒNG
    local hue = 0
    local starRotation = 0
    
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- Xử lý độ lớn âm thanh bằng thuật toán lọc Bass nhạy hơn
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp((loudness - 40) / 280, 0, 1) -- Lọc bỏ tạp âm, giữ lại Bass chính sâu hơn
        
        -- Đồng bộ màu sắc cầu vồng chạy nhanh hơn khi nhạc đập mạnh
        local speedMultiplier = 1 + (normLoudness * 4)
        hue = (hue + (0.5 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        local starColor = Color3.fromHSV((hue + 60) % 360, 1, 1) -- Ngôi sao lệch màu một chút để tạo điểm nhấn
        
        part.Color = mainColor
        
        -- ĐẬP BASS KHỚP 100%: Tăng mạnh tỉ lệ co giãn dựa theo nhịp Bass thực tế
        local scaleFactor = 1 + (normLoudness * 0.35) -- Tăng biên độ giật để loa đập rõ ràng từng nhịp
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * scaleFactor, baseSize.Z * scaleFactor)
        
        -- Xử lý 2 ngôi sao đính kèm (vừa tự xoay tròn vừa đập to nhỏ khớp theo loa)
        starRotation = (starRotation + 3) % 360
        if leftStarPart and leftStarPart.Parent then
            leftStarPart.Color = starColor
            leftStarPart.Size = Vector3.new(0.6 * scaleFactor, 0.6 * scaleFactor, 0.2)
            leftStarWeld.C0 = CFrame.new(-0.6 * scaleFactor, 0, 0.22) * CFrame.Angles(0, 0, math.rad(starRotation))
        end
        if rightStarPart and rightStarPart.Parent then
            rightStarPart.Color = starColor
            rightStarPart.Size = Vector3.new(0.6 * scaleFactor, 0.6 * scaleFactor, 0.2)
            rightStarWeld.C0 = CFrame.new(0.6 * scaleFactor, 0, 0.22) * CFrame.Angles(0, 0, math.rad(-starRotation))
        end
        
        -- Cập nhật thanh sóng nhạc nhấp nhô bám sát theo khối hộp khi co giãn
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                local waveFactor = math.sin(tick() * 16 + item.Index) * 0.15
                local targetHeight = math.clamp((normLoudness * 0.8) + waveFactor, 0.05, 0.9)
                
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

-- TỰ ĐỘNG ĐEO LẠI KHI DIE (Khóa chặt vĩnh viễn trên lưng, hồi sinh là xuất hiện lại ngay)
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
        print("Thanh Phuc đã cập nhật bài hát mới thành công, hiệu ứng ngôi sao đập cực khớp!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
