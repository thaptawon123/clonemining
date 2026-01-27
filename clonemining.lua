local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- [ 1. ระบบ Anti-AFK ] --
local GC = getconnections or get_signal_connections
if GC then
    for i, v in pairs(GC(player.Idled)) do
        if v["Disable"] then v["Disable"](v)
        elseif v["Disconnect"] then v["Disconnect"](v) end
    end
else
    player.Idled:Connect(function()
        vim:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
        task.wait(0.1)
        vim:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
    end)
end

-- [ 2. ตั้งค่าพิกัด ] --
local spot1 = CFrame.new(1462.61182, 8, 1585.5) 
local spot2 = CFrame.new(152.182297, 186, 1934.83044) 
local spot3 = CFrame.new(165.94252, 188.178406, 1914.70117, 0, 0, 1, 0, 1, -0, -1, 0, 0) 
local targetPos = Vector3.new(1450.85229, 10.5002451, 1595.5697) 

local isChecking = false
local minerIdleTimes = {}

-- [ 3. ฟังก์ชันค้นหา ] --
local function getMinersFolder()
    local root = workspace:FindFirstChild("TycoonModels") and workspace.TycoonModels:FindFirstChild("4030205055")
    return (root and root:FindFirstChild("Miners")) or workspace:FindFirstChild("Miners", true)
end

local function findMinecart()
    local root = workspace:FindFirstChild("TycoonModels") and workspace.TycoonModels:FindFirstChild("4030205055")
    return (root and root:FindFirstChild("MinecartVehicles") and root.MinecartVehicles:FindFirstChild("MinecartVehicle")) or workspace:FindFirstChild("MinecartVehicle", true)
end

-- [ 4. ฟังก์ชันวาร์ปรถแบบนิ่งสนิท ] --
local function teleportSafe(vehicle, char, targetCF)
    if not vehicle or not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- ปิดการชนกันชั่วคราวเพื่อไม่ให้ตัวละครดีดรถ
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.AssemblyLinearVelocity = Vector3.new(0,0,0)
            part.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end
    
    vehicle:PivotTo(targetCF)
    if hrp then hrp.CFrame = targetCF * CFrame.new(0, 3, 0) end -- วาร์ปตัวละครลอยเหนือรถนิดนึง
    
    task.wait(1) -- รอให้ฟิสิกส์นิ่ง
    
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

-- [ 5. ลูปการทำงาน ] --
local function runTeleportSequence()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    -- ไปจุด 2 และจัดการรถ
    task.wait(2)
    local vehicle = findMinecart()
    teleportSafe(vehicle, char, spot2)

    -- บังคับกระโดด (ใช้ Velocity + KeyPress)
    task.wait(1.5)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 50, 0) -- ดีดตัวขึ้น
    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    
    -- ไปจุด 3
    task.wait(4)
    hrp.CFrame = spot3
    
    -- กดปุ่ม E และ 1
    local function press(k)
        vim:SendKeyEvent(true, k, false, game)
        task.wait(0.2)
        vim:SendKeyEvent(false, k, false, game)
    end

    task.wait(4)
    press(Enum.KeyCode.E)
    task.wait(4)
    press(Enum.KeyCode.One)
    
    -- กลับจุด 1
    task.wait(1)
    hrp.CFrame = spot1
end

-- [ 6. UI ] --
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.ResetOnSpawn = false
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
toggleBtn.Text = "SYSTEM: READY"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Instance.new("UICorner", toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
    isChecking = not isChecking
    toggleBtn.Text = isChecking and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = isChecking and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    if isChecking and player.Character then player.Character.HumanoidRootPart.CFrame = spot1 end
end)

-- [ 7. ลูปเช็ค ] --
task.spawn(function()
    while true do
        if isChecking then
            local miners = getMinersFolder()
            local trigger = false
            if miners then
                for _, m in pairs(miners:GetChildren()) do
                    local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if p and (p.Position - targetPos).Magnitude < 10 then 
                        minerIdleTimes[m.Name] = (minerIdleTimes[m.Name] or 0) + 1
                        if minerIdleTimes[m.Name] >= 10 then trigger = true break end
                    else minerIdleTimes[m.Name] = 0 end
                end
            end
            if trigger then runTeleportSequence() minerIdleTimes = {} end
        end
        task.wait(1)
    end
end)
