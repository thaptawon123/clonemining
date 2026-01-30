local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

-- [[ 0. ระบบ Save/Load Settings ]] --
local fileName = "MinerTycoon_Config_Final.json"

local function SaveSettings()
    local data = {
        TeleportEnabled = _G.TeleportEnabled,
        RebirthEnabled = _G.RebirthEnabled,
        MinerEnabled = _G.MinerEnabled,
        PickaxeEnabled = _G.PickaxeEnabled,
        BackpackEnabled = _G.BackpackEnabled
    }
    writefile(fileName, HttpService:JSONEncode(data))
end

local function LoadSettings()
    if isfile(fileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if success then
            _G.TeleportEnabled = data.TeleportEnabled or false
            _G.RebirthEnabled = data.RebirthEnabled or false
            _G.MinerEnabled = data.MinerEnabled or false
            _G.PickaxeEnabled = data.PickaxeEnabled or false
            _G.BackpackEnabled = data.BackpackEnabled or false
        end
    else
        _G.TeleportEnabled = false
        _G.RebirthEnabled = false
        _G.MinerEnabled = false
        _G.PickaxeEnabled = false
        _G.BackpackEnabled = false
    end
end

LoadSettings()

-- [[ 1. สร้าง UI Control Panel ]] --
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MinerTycoon_Hybrid_Final"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 160, 0, 325) -- ขนาดรองรับ 5 ปุ่ม
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Draggable = true
mainFrame.Active = true
Instance.new("UICorner", mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Text = "  CONTROL"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

local toggleMenu = Instance.new("TextButton", mainFrame)
toggleMenu.Size = UDim2.new(0, 25, 0, 25)
toggleMenu.Position = UDim2.new(1, -28, 0, 3)
toggleMenu.Text = "-"
toggleMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleMenu.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleMenu)

local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, 0, 1, -35)
content.Position = UDim2.new(0, 0, 0, 35)
content.BackgroundTransparency = 1

local isCollapsed = false
toggleMenu.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    content.Visible = not isCollapsed
    mainFrame.Size = isCollapsed and UDim2.new(0, 160, 0, 32) or UDim2.new(0, 160, 0, 325)
    toggleMenu.Text = isCollapsed and "+" or "-"
end)

local function createToggle(name, pos, globalVar)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0, 140, 0, 45)
    btn.Position = pos
    
    local function updateVisuals()
        btn.Text = name .. ": " .. (_G[globalVar] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
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

-- สร้างปุ่มควบคุม
createToggle("Auto Farm", UDim2.new(0, 10, 0, 5), "TeleportEnabled")
createToggle("Auto Rebirth", UDim2.new(0, 10, 0, 60), "RebirthEnabled")
createToggle("Buy Miner", UDim2.new(0, 10, 0, 115), "MinerEnabled")
createToggle("Buy Pickaxe", UDim2.new(0, 10, 0, 170), "PickaxeEnabled")
createToggle("Buy Backpack", UDim2.new(0, 10, 0, 225), "BackpackEnabled")

-- [[ 2. ระบบ DIRECT AUTO REBIRTH (คงเดิม 100%) ]] --
task.spawn(function()
    while task.wait(2) do
        if _G.RebirthEnabled then
            local pGui = player:FindFirstChild("PlayerGui")
            local leftHud = pGui and pGui:FindFirstChild("LeftHUD")
            local rebirthScreen = pGui and pGui:FindFirstChild("RebirthScreen")
            local rebirthFrame = rebirthScreen and rebirthScreen:FindFirstChild("Rebirth")

            local isReady = (leftHud and leftHud:FindFirstChild("Rebirth", true) and leftHud:FindFirstChild("Rebirth", true).Visible) 
                            or (rebirthFrame and rebirthFrame.Visible)

            if isReady then
                local rbRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Rebirth", true)
                if rbRemote and rbRemote:IsA("RemoteEvent") then
                    rbRemote:FireServer()
                end

                local container = rebirthFrame and rebirthFrame:FindFirstChild("ButtonContainer")
                if container then
                    for _, btn in pairs(container:GetChildren()) do
                        if btn:IsA("GuiButton") and btn.Name ~= "Close" and btn.Name ~= "Back" then
                            if firesignal then
                                firesignal(btn.MouseButton1Click)
                            else
                                local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2)
                                local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2) + 58
                                vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
                                task.wait(0.1)
                                vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
                            end
                            break
                        end
                    end
                end
                task.wait(3)
            end
        end
    end
end)

-- [[ 3. ระบบ TELEPORT FARM (คงเดิม 100%) ]] --
task.spawn(function()
    local spotWait = CFrame.new(1462.61182, 8, 1585.5) 
    local spotCar = CFrame.new(1420.23901, 12.1875057, 1602.05542) 
    local spotFreeze = CFrame.new(152.182297, 186, 1934.83044) 
    local spotButton = CFrame.new(166.94252, 188.178406, 1915.70117) 
    local targetPos = Vector3.new(1450.85229, 10.5002451, 1595.5697) 
    local minerIdleTimes = {}

    while task.wait(1) do
        if _G.TeleportEnabled then
            local vehicle = workspace:FindFirstChild("MinecartVehicle", true)
            local miners = workspace:FindFirstChild("Miners", true)
            
            local trigger = false
            if miners then
                for _, m in pairs(miners:GetChildren()) do
                    local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if p and (p.Position - targetPos).Magnitude < 15 then 
                        minerIdleTimes[m.Name] = (minerIdleTimes[m.Name] or 0) + 1
                        if minerIdleTimes[m.Name] >= 15 then trigger = true break end
                    else minerIdleTimes[m.Name] = 0 end
                end
            end

            if trigger and vehicle then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = spotCar task.wait(0.6)
                    vehicle:PivotTo(spotFreeze)
                    for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = false end end
                    task.wait(0.6)
                    for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = true end end
                    hrp.CFrame = spotFreeze * CFrame.new(0, 4, 0) task.wait(0.4)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game) task.wait(0.1) vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    task.wait(0.2)
                    vim:SendKeyEvent(true, Enum.KeyCode.W, false, game) task.wait(2) vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                    hrp.CFrame = spotButton task.wait(1.5)
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game) task.wait(0.2) vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(3)
                    vim:SendKeyEvent(true, Enum.KeyCode.One, false, game) task.wait(0.2) vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    task.wait(4)
                    hrp.CFrame = spotWait
                    for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = false end end
                    minerIdleTimes = {}
                end
            end
        end
    end
end)

-- [[ 4. ระบบ AUTO BUY (Miner + Pickaxe + Backpack) ]] --
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local requests = rs:WaitForChild("Remotes"):WaitForChild("UIDataRequests")
            
            -- ซื้อคนงาน
            if _G.MinerEnabled then
                local buyMinerRemote = requests:FindFirstChild("BuyMiner")
                if buyMinerRemote then buyMinerRemote:InvokeServer() end
            end
            
            -- อัปเกรดไอเทมคนงานทุกคนที่เจอใน Workspace
            local minersFolder = workspace:FindFirstChild("Miners", true)
            if minersFolder then
                for _, miner in pairs(minersFolder:GetChildren()) do
                    local minerID = tonumber(miner.Name)
                    if minerID then
                        -- ซื้อที่ขุด Void Alloy
                        if _G.PickaxeEnabled then
                            local buyPickaxe = requests:FindFirstChild("BuyClonePickaxe")
                            if buyPickaxe then buyPickaxe:InvokeServer("Premium", minerID) end
                            task.wait(0.1)
                        end
                        -- ซื้อกระเป๋า Quantumn
                        if _G.BackpackEnabled then
                            local buyBackpack = requests:FindFirstChild("BuyCloneBackpack")
                            if buyBackpack then buyBackpack:InvokeServer("Quantumn", minerID) end
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end
end)

-- [[ 5. ระบบ Anti-AFK (คงเดิม 100%) ]] --
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    print("Anti-AFK Working")
end)

print("MinerTycoon Hybrid Final: All Features Loaded!")
