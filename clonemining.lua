local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- [[ 0. ระบบ Save/Load Settings ]] --
local fileName = "MinerTycoon_Lite_Config.json"

_G.TeleportEnabled = false
_G.RebirthEnabled = false

local function SaveSettings()
    local data = {
        TeleportEnabled = _G.TeleportEnabled,
        RebirthEnabled = _G.RebirthEnabled,
    }
    writefile(fileName, HttpService:JSONEncode(data))
end

local function LoadSettings()
    if isfile(fileName) then
        local status, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if status and decoded then
            _G.TeleportEnabled = decoded.TeleportEnabled or false
            _G.RebirthEnabled = decoded.RebirthEnabled or false
            print("Miner Hub: Settings Loaded!")
        end
    end
end

LoadSettings()

-- [[ 1. สร้าง UI ]] --
if CoreGui:FindFirstChild("MinerTycoon_Lite") then
    CoreGui:FindFirstChild("MinerTycoon_Lite"):Destroy()
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "MinerTycoon_Lite"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 180, 0, 150) -- ปรับขนาดให้เล็กลงตามฟีเจอร์ที่เหลือ
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -30, 0, 35)
title.Text = "  MINER LITE"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local toggleMenu = Instance.new("TextButton", mainFrame)
toggleMenu.Size = UDim2.new(0, 25, 0, 25)
toggleMenu.Position = UDim2.new(1, -28, 0, 5)
toggleMenu.Text = "-"
toggleMenu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleMenu.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleMenu)

local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", content)
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createToggle(name, globalVar)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0, 160, 0, 35)
    local function updateVisuals()
        btn.Text = name .. ": " .. (_G[globalVar] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 50, 50)
    end
    updateVisuals()
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        updateVisuals()
        SaveSettings()
    end)
end

local isCollapsed = false
toggleMenu.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    content.Visible = not isCollapsed
    mainFrame.Size = isCollapsed and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 150)
    toggleMenu.Text = isCollapsed and "+" or "-"
end)

createToggle("Auto Farm (TP)", "TeleportEnabled")
createToggle("Auto Rebirth", "RebirthEnabled")

-- [[ 2. Rebirth ]] --
task.spawn(function()
    while task.wait(2) do
        if _G.RebirthEnabled then
            pcall(function()
                local rb = game:GetService("ReplicatedStorage"):FindFirstChild("Rebirth", true)
                if rb then rb:FireServer() end
            end)
        end
    end
end)

-- [[ 3. Teleport Farm ]] --
task.spawn(function()
    local spotWait = CFrame.new(1462.61, 8, 1585.5)
    local spotCar = CFrame.new(1420.23, 12.18, 1602.05)
    local spotFreeze = CFrame.new(162.18, 186, 1930.83)
    local spotButton = CFrame.new(166.94, 188.17, 1915.70)
    local targetPos = Vector3.new(1450.85, 10.5, 1595.56)
    local minerIdleTimes = {}

    while task.wait(1) do
        if _G.TeleportEnabled then
            pcall(function()
                local vehicle = workspace:FindFirstChild("MinecartVehicle", true)
                local miners = workspace:FindFirstChild("Miners", true)
                local trigger = false
                
                if miners then
                    for _, m in pairs(miners:GetChildren()) do
                        local p = m:FindFirstChild("HumanoidRootPart")
                        if p and (p.Position - targetPos).Magnitude < 15 then
                            minerIdleTimes[m.Name] = (minerIdleTimes[m.Name] or 0) + 1
                            if minerIdleTimes[m.Name] >= 20 then trigger = true break end
                        else 
                            minerIdleTimes[m.Name] = 0 
                        end
                    end
                end

                if trigger and vehicle then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = spotWait task.wait(1)
                        hrp.CFrame = spotCar task.wait(2)
                        
                        for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = false end end
                        vehicle:PivotTo(spotFreeze)
                        task.wait(1)
                        for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = true end end
                        
                        hrp.CFrame = spotFreeze * CFrame.new(0, 5, 0)
                        vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        
                        task.wait(1)
                        table.clear(minerIdleTimes) task.wait(0.5)
                        vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                        task.wait(1)
                        vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)

                        hrp.CFrame = spotButton task.wait(2)
                        vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.3)
                        vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        
                        task.wait(4)
                        vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        task.wait(0.3)
                        vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)

                        task.wait(4)
                        hrp.CFrame = spotWait
                        for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = false end end
                        task.wait(1)
                    end
                end
            end)
        end
    end
end)

-- [[ 4. Anti-AFK ]] --
player.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("Miner Hub Lite: Only TP and Rebirth active.")
