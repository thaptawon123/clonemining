local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")

-- [ ตัวแปรสถานะ แยกแต่ละระบบ ] --
_G.AutoTeleport = false
_G.AutoRebirth = false
_G.AutoHire = false

-- [[ 1. ระบบ ANTI-AFK (คงเดิม) ]] --
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

-- [[ 2. สร้าง UI Control Panel ]] --
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "ControlPanel"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 150, 0, 180)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 0, 30)
label.Text = "HACK MENU"
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1

local function createBtn(name, pos, color)
    local btn = Instance.new("TextButton", frame)
    btn.Name = name
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    return btn
end

local btnTele = createBtn("Teleport", UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(200, 50, 50))
local btnRebirth = createBtn("Rebirth", UDim2.new(0.05, 0, 0.45, 0), Color3.fromRGB(200, 50, 50))
local btnHire = createBtn("HireMiner", UDim2.new(0.05, 0, 0.7, 0), Color3.fromRGB(200, 50, 50))

-- [[ 3. ฟังก์ชันปุ่มกด ]] --
btnTele.MouseButton1Click:Connect(function()
    _G.AutoTeleport = not _G.AutoTeleport
    btnTele.Text = "Teleport: " .. (_G.AutoTeleport and "ON" or "OFF")
    btnTele.BackgroundColor3 = _G.AutoTeleport and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

btnRebirth.MouseButton1Click:Connect(function()
    _G.AutoRebirth = not _G.AutoRebirth
    btnRebirth.Text = "Rebirth: " .. (_G.AutoRebirth and "ON" or "OFF")
    btnRebirth.BackgroundColor3 = _G.AutoRebirth and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

btnHire.MouseButton1Click:Connect(function()
    _G.AutoHire = not _G.AutoHire
    btnHire.Text = "HireMiner: " .. (_G.AutoHire and "ON" or "OFF")
    btnHire.BackgroundColor3 = _G.AutoHire and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- [[ 4. ระบบ Teleport (โค้ดชุดแรกของคุณ - ไม่แก้ไขโครงสร้าง) ]] --
local spot1 = CFrame.new(1462.61182, 8, 1585.5) 
local spot2 = CFrame.new(152.182297, 185, 1934.83044) 
local spot3 = CFrame.new(165.94252, 188.178406, 1914.70117, 0, 0, 1, 0, 1, -0, -1, 0, 0) 
local targetPos = Vector3.new(1450.85229, 10.5002451, 1595.5697) 
local minerIdleTimes = {}

task.spawn(function()
    while task.wait(1) do
        if _G.AutoTeleport then
            local root = workspace:FindFirstChild("TycoonModels") and workspace.TycoonModels:FindFirstChild("4030205055")
            local miners = (root and root:FindFirstChild("Miners")) or workspace:FindFirstChild("Miners", true)
            local trigger = false
            if miners then
                for _, m in pairs(miners:GetChildren()) do
                    local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if p and (p.Position - targetPos).Magnitude < 15 then 
                        minerIdleTimes[m.Name] = (minerIdleTimes[m.Name] or 0) + 1
                        if minerIdleTimes[m.Name] >= 20 then trigger = true break end
                    else minerIdleTimes[m.Name] = 0 end
                end
            end
            if trigger then
                -- Teleport Sequence
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local vehicle = (root and root:FindFirstChild("MinecartVehicles") and root.MinecartVehicles:FindFirstChild("MinecartVehicle")) or workspace:FindFirstChild("MinecartVehicle", true)
                if hrp and vehicle then
                    for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                    vehicle:PivotTo(spot2) hrp.CFrame = spot2 * CFrame.new(0, 3, 0)
                    task.wait(1.5)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game) task.wait(0.1) vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    task.wait(4) hrp.CFrame = spot3 task.wait(4)
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game) task.wait(0.2) vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(4) vim:SendKeyEvent(true, Enum.KeyCode.One, false, game) task.wait(0.2) vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    task.wait(1) hrp.CFrame = spot1
                    minerIdleTimes = {}
                end
            end
        end
    end
end)

-- [[ 5. ระบบ Direct Rebirth (แยกส่วน) ]] --
task.spawn(function()
    while task.wait(3) do
        if _G.AutoRebirth then
            local openBtn = player.PlayerGui:FindFirstChild("Rebirth", true)
            if openBtn and openBtn.Visible then
                events.Rebirth:FireServer()
                print("Direct Rebirth Sent!")
                task.wait(2)
            end
        end
    end
end)

-- [[ 6. ระบบ Direct HireMiner (แยกส่วน) ]] --
task.spawn(function()
    while task.wait(3) do
        if _G.AutoHire then
            for i = 1, 12 do -- จ้าง ID 1 ถึง 12
                events.HireMiner:FireServer(i)
            end
        end
    end
end)
