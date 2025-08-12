local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "سكربت مايك العرب وادمن مجاني بنات وا اولاد",
    LoadingTitle = "يتم تحميل الواجهة...",
    LoadingSubtitle = " على حس ابو حسن",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("الرئيسية", 44833652458)

MainTab:CreateSlider({
    Name = "السرعة",
    Range = {16, 200},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

MainTab:CreateSlider({
    Name = "القفز",
    Range = {50, 200},
    Increment = 1,
    Suffix = "JP",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})

local SpeedSection = MainTab:CreateSection("anti afk + anti fling ")

MainTab:CreateToggle({
    Name = "anti afk  ",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            getgenv().AntiAFK = true
            local VirtualUser = game:GetService("VirtualUser")
            
            task.spawn(function()
                while getgenv().AntiAFK do
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    task.wait(30)
                end
            end)
            
            print("تم تفعيل منع الطرد")
        else
            getgenv().AntiAFK = false
            print("تم إيقاف منع الطرد")
        end
    end
})

MainTab:CreateToggle({
    Name = "Anti fling ",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            getgenv().AntiFlingEnabled = true
            
            local function makeNonCollidable(char)
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = true
                    end
                end
            end

            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    makeNonCollidable(player.Character)
                end
                player.CharacterAdded:Connect(function(char)
                    if getgenv().AntiFlingEnabled then
                        makeNonCollidable(char)
                    end
                end)
            end

            game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    if getgenv().AntiFlingEnabled then
                        makeNonCollidable(char)
                    end
                end)
            end)

            print("Anti-Fling enabled")
        else
            getgenv().AntiFlingEnabled = false
            
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                            part.Massless = false
                        end
                    end
                end
            end

            print("Anti-Fling disabled")
        end
    end
})

MainTab:CreateButton({
    Name = "مضاد بانق",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not humanoidRootPart then return end
        
        getgenv().OriginalPosition = humanoidRootPart.CFrame
        humanoidRootPart.CFrame = CFrame.new(0, 100000, 0)
        task.wait(0.5)
        humanoidRootPart.CFrame = getgenv().OriginalPosition
    end,
})

-- نظام كشف الرسائل الخاصة المعدل
local PrivateLoggerEnabled = false
local PrivateLoggerUI = nil
local ChatConnections = {}

local function CreatePrivateLoggerUI()
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("PrivateLoggerUI") then
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("PrivateLoggerUI"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PrivateLoggerUI"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.3, 0, 0.3, 0)
    mainFrame.Position = UDim2.new(0.01, 0, 0.69, 0)
    mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Text = "كشف الرسائل الخاصة"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -5, 0.9, -5)
    scrollFrame.Position = UDim2.new(0, 5, 0.1, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)

    return scrollFrame
end

local function AddPrivateMessage(scrollFrame, playerName, message)
    local messageFrame = Instance.new("Frame")
    messageFrame.Size = UDim2.new(1, 0, 0, 30)
    messageFrame.BackgroundTransparency = 1
    messageFrame.LayoutOrder = #scrollFrame:GetChildren()
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    nameLabel.Text = playerName .. ":"
    nameLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = messageFrame
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(0.6, 0, 1, 0)
    msgLabel.Position = UDim2.new(0.4, 0, 0, 0)
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 14
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.BackgroundTransparency = 1
    msgLabel.Parent = messageFrame
    
    messageFrame.Parent = scrollFrame
end

local function EnablePrivateLogger()
    PrivateLoggerUI = CreatePrivateLoggerUI()
    
    -- استخدام نظام الشات الجديد لاكتشاف الرسائل الخاصة
    local function setupPlayer(player)
        player.Chatted:Connect(function(message, recipient)
            if not PrivateLoggerEnabled then return end
            
            -- التحقق إذا كانت الرسالة خاصة للمستخدم الحالي
            if recipient and recipient == game.Players.LocalPlayer then
                AddPrivateMessage(PrivateLoggerUI, player.Name, message)
            end
        end)
    end

    -- كشف الرسائل من اللاعبين الحاليين
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            setupPlayer(player)
        end
    end
    
    -- كشف اللاعبين الجدد
    local newPlayerConn = game.Players.PlayerAdded:Connect(function(player)
        setupPlayer(player)
    end)
    table.insert(ChatConnections, newPlayerConn)
end

local function DisablePrivateLogger()
    for _, conn in ipairs(ChatConnections) do
        conn:Disconnect()
    end
    ChatConnections = {}
    
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("PrivateLoggerUI") then
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("PrivateLoggerUI"):Destroy()
    end
end

MainTab:CreateToggle({
    Name = "كشف الرسائل الخاصة",
    CurrentValue = false,
    Callback = function(Value)
        PrivateLoggerEnabled = Value
        if Value then
            EnablePrivateLogger()
        else
            DisablePrivateLogger()
        end
    end
})

local HackTab = Window:CreateTab("تخريب وفك الحمايات", 4483362458)

HackTab:CreateToggle({
	Name = "فك حمايه الماب عشان تقدر تطير الناس ",
	CurrentValue = false,
	Flag = "HackMode",
	Callback = function(state)
		local lp = game:GetService("Players").LocalPlayer
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		
		if state then
			local oldPos = hrp.CFrame

			-- ينزل تحت
			hrp.CFrame = hrp.CFrame - Vector3.new(0, 100, 0)
			wait(0.3)

			-- يطلع فوق
			hrp.CFrame = hrp.CFrame + Vector3.new(0, 1000, 0)
			wait(0.5)

			-- يرسل أوامر char/unchar
			game:GetService("Players"):Chat(";char me")
			wait(1)
			game:GetService("Players"):Chat(";unchar")
			wait(1)

			-- يرجع لمكانه
			hrp.CFrame = oldPos
		end
	end
})

HackTab:CreateButton({
	Name = "فعل اسكن تخريب ",
	Callback = function()
		game:GetService("Players"):Chat(";char me crazydalejrd")
	end,
})

HackTab:CreateButton({
	Name = " ارجع لي اسكنك الاصلي  ",
	Callback = function()
		game:GetService("Players"):Chat("unchar  ")
	end,
})

local ProtectionTab = Window:CreateTab("الحماية ", 13014546637) -- أيقونة درع

-- متغيرات النظام
local ShieldEnabled = false
local AntiSitEnabled = false
local ShieldPart = nil
local AntiSitConnection = nil

-- 1. حل مشكلة الطيران الجنوني (نظام الدرع المعدل)
local function CreateAdvancedShield()
   if ShieldPart then ShieldPart:Destroy() end
   
   ShieldPart = Instance.new("Part")
   ShieldPart.Name = "AdvancedAntiFlingShield"
   ShieldPart.Size = Vector3.new(12, 12, 12) -- حجم أصغر لتفادي المشاكل
   ShieldPart.Transparency = 0.8
   ShieldPart.Color = Color3.fromRGB(0, 255, 0) -- لون أخضر
   ShieldPart.Material = Enum.Material.Neon
   ShieldPart.Anchored = false -- غير مثبت لتفادي الطيران
   ShieldPart.CanCollide = false -- لا يصطدم مع اللاعب
   ShieldPart.CastShadow = false
   ShieldPart.Parent = workspace
   
   -- إضافة قوة طفو لمنع الطيران
   local BodyVelocity = Instance.new("BodyVelocity")
   BodyVelocity.Velocity = Vector3.new(0, 0, 0)
   BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
   BodyVelocity.Parent = ShieldPart
end

-- 2. نظام مضاد الجلوس المنفصل
local function ToggleAntiSit(value)
   AntiSitEnabled = value
   
   if AntiSitConnection then
      AntiSitConnection:Disconnect()
      AntiSitConnection = nil
   end
   
   if AntiSitEnabled then
      AntiSitConnection = game:GetService("RunService").Heartbeat:Connect(function()
         local character = game.Players.LocalPlayer.Character
         if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Sit then
               humanoid.Jump = true
               task.wait(0.1)
               humanoid.Jump = false
            end
         end
      end)
   end
end

-- زر التحكم في الدرع (بدون إشعارات)
ProtectionTab:CreateToggle({
   Name = "مضاد الكلبشة",
   CurrentValue = false,
   Flag = "AntiFlingToggle",
   Callback = function(Value)
      ShieldEnabled = Value
      if ShieldEnabled then
         CreateAdvancedShield()
      else
         if ShieldPart then
            ShieldPart:Destroy()
            ShieldPart = nil
         end
      end
   end,
})

-- زر منفصل لمضاد الجلوس (بدون إشعارات)
ProtectionTab:CreateToggle({
   Name = "مضاد الجلوس ",
   CurrentValue = false,
   Flag = "AntiSitToggle",
   Callback = function(Value)
      ToggleAntiSit(Value)
   end,
})

-- تحديث موقع الدرع بسلاسة
game:GetService("RunService").Heartbeat:Connect(function()
   if ShieldEnabled and ShieldPart then
      local character = game.Players.LocalPlayer.Character
      if character then
         local rootPart = character:FindFirstChild("HumanoidRootPart")
         if rootPart then
            ShieldPart.CFrame = rootPart.CFrame * CFrame.new(0, -1, 0) -- تعديل الموقع
         end
      end
   end
end)

-- زر إضافي للطوارئ
ProtectionTab:CreateButton({
   Name = "اذي صارت مشكله اضغط عليها  ",
   Callback = function()
      if ShieldPart then
         ShieldPart:Destroy()
         ShieldPart = nil
      end
      ToggleAntiSit(false)
      game.Players.LocalPlayer.Character:BreakJoints()
   end,
})

-- تفعيل النافذة
Rayfield:LoadConfiguration()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FriendsWithPower = {
    ["L71V2"] = true,
    ["L71V2"] = true,
    -- أضف أسماء أكثر
}

local function MakePlayerSink(player)
    local character = player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame - Vector3.new(0, 50, 0)
        end
    end
end

game:GetService("Players").PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if FriendsWithPower[player.Name] then
            local args = msg:split(" ")
            if args[1]:lower() == "killi" and args[2] then
                local targetName = args[2]
                local targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer and targetPlayer == LocalPlayer then
                    MakePlayerSink(targetPlayer)
                end
            end
        end
    end)
end)

