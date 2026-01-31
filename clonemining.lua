local player = game.Players.LocalPlayer

local vim = game:GetService("VirtualInputManager")

local HttpService = game:GetService("HttpService")

local CoreGui = game:GetService("CoreGui")



-- [[ 0. ระบบ Save/Load Settings ]] --

local fileName = "MinerTycoon_Advanced_Config.json"



_G.TeleportEnabled = false

_G.RebirthEnabled = false

_G.MinerEnabled = false

_G.SelectedPickaxe = "Void Alloy"

_G.SelectedBackpack = "Quantumn"

_G.AutoBuyItems = false



local function SaveSettings()
    local data = {
        TeleportEnabled = _G.TeleportEnabled,
        RebirthEnabled = _G.RebirthEnabled,
        MinerEnabled = _G.MinerEnabled,
        SelectedPickaxe = _G.SelectedPickaxe,
        SelectedBackpack = _G.SelectedBackpack,
        AutoBuyItems = _G.AutoBuyItems
    }
    writefile(fileName, HttpService:JSONEncode(data))
end

local function LoadSettings()
    if isfile(fileName) then
        local status, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        
        if status and decoded then
            _G.TeleportEnabled = decoded.TeleportEnabled
            _G.RebirthEnabled = decoded.RebirthEnabled
            _G.MinerEnabled = decoded.MinerEnabled
            _G.SelectedPickaxe = decoded.SelectedPickaxe
            _G.SelectedBackpack = decoded.SelectedBackpack
            _G.AutoBuyItems = decoded.AutoBuyItems
            print("Miner Hub: Settings Loaded Successfully!")
        end
    else
        print("Miner Hub: No Config Found, Using Defaults.")
    end
end

-- เรียกใช้ Load ทันทีที่รันสคริปต์
LoadSettings()

-- [[ 1. สร้าง UI ]] --

if CoreGui:FindFirstChild("MinerTycoon_Hybrid_Final") then

    CoreGui:FindFirstChild("MinerTycoon_Hybrid_Final"):Destroy()

end



local screenGui = Instance.new("ScreenGui", CoreGui)

screenGui.Name = "MinerTycoon_Hybrid_Final"



local mainFrame = Instance.new("Frame", screenGui)

mainFrame.Size = UDim2.new(0, 180, 0, 380)

mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)

mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

mainFrame.Active = true

mainFrame.Draggable = true

Instance.new("UICorner", mainFrame)



local title = Instance.new("TextLabel", mainFrame)

title.Size = UDim2.new(1, -30, 0, 35)

title.Text = "  MINER HUB"

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



local content = Instance.new("ScrollingFrame", mainFrame)

content.Size = UDim2.new(1, 0, 1, -40)

content.Position = UDim2.new(0, 0, 0, 40)

content.BackgroundTransparency = 1

content.CanvasSize = UDim2.new(0, 0, 0, 450)

content.ScrollBarThickness = 2



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



local function createSelector(titleText, options, globalVar)

    local label = Instance.new("TextLabel", content)

    label.Size = UDim2.new(0, 160, 0, 20)

    label.Text = titleText

    label.TextColor3 = Color3.fromRGB(200, 200, 200)

    label.BackgroundTransparency = 1

    label.Font = Enum.Font.Gotham

    local btn = Instance.new("TextButton", content)

    btn.Size = UDim2.new(0, 160, 0, 35)

    btn.Text = _G[globalVar]

    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    btn.TextColor3 = Color3.new(1, 1, 1)

    btn.Font = Enum.Font.GothamBold

    Instance.new("UICorner", btn)

    local currentIdx = 1

    btn.MouseButton1Click:Connect(function()

        currentIdx = currentIdx + 1

        if currentIdx > #options then currentIdx = 1 end

        _G[globalVar] = options[currentIdx]

        btn.Text = _G[globalVar]

        SaveSettings()

    end)

end



-- [[ จุดแก้ไข 1: เพิ่ม local isCollapsed ]] --

local isCollapsed = false

toggleMenu.MouseButton1Click:Connect(function()

    isCollapsed = not isCollapsed

    content.Visible = not isCollapsed

    mainFrame.Size = isCollapsed and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 380)

    toggleMenu.Text = isCollapsed and "+" or "-"

end)



createToggle("Auto Farm", "TeleportEnabled")

createToggle("Auto Rebirth", "RebirthEnabled")

createToggle("Buy Miner", "MinerEnabled")

createToggle("Auto Buy Items", "AutoBuyItems")



local backpacks = {"Small", "Leather", "Travel", "Premium", "Large", "Heavy Duty", "Steel Beam", "Quarry", "Hauler", "Overload", "Voidcrawler", "Quantumn", "Vaultpack", "MythrilSatchel", "MonarchBackpack"}

createSelector("--- SELECT BACKPACK ---", backpacks, "SelectedBackpack")



local pickaxes = {"Wooden", "Stone", "Iron", "Gold", "Ruby", "Sapphire", "Platinum", "Titanium", "Diamond", "Adamantite", "Hellstone", "Void Alloy", "Steel Breaker", "Mythril Edge", "MonarchPickaxe"}

createSelector("--- SELECT PICKAXE ---", pickaxes, "SelectedPickaxe")



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



-- [[ 3. Auto Buy ]] --

task.spawn(function()

    while task.wait(5) do

        if _G.AutoBuyItems then

            pcall(function()

                local requests = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UIDataRequests")

                if _G.MinerEnabled then requests.BuyMiner:InvokeServer() end

                local minersFolder = workspace:FindFirstChild("Miners", true)

                if minersFolder then

                    for _, miner in pairs(minersFolder:GetChildren()) do

                        local id = tonumber(miner.Name)

                        if id then

                            requests.BuyClonePickaxe:InvokeServer(_G.SelectedPickaxe, id)

                            task.wait(0.1)

                            requests.BuyCloneBackpack:InvokeServer(_G.SelectedBackpack, id)

                            task.wait(0.1)

                        end

                    end

                end

            end)

        end

    end

end)



-- [[ 4. Teleport Farm ]] --

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

                        else minerIdleTimes[m.Name] = 0 end

                    end

                end



                if trigger and vehicle then

                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hrp.CFrame = spotWait task.wait(1)

                        hrp.CFrame = spotCar task.wait(2)

                        -- ปลดล็อกก่อนวาร์ปเพื่ออัปเดตตำแหน่ง
                        for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = false end end
                        vehicle:PivotTo(spotFreeze)
                        task.wait(1)
                        
                        for _, v in pairs(vehicle:GetDescendants()) do if v:IsA("BasePart") then v.Anchored = true end end
                        

                        -- [[ จุดแก้ไข 2: เพิ่มแรงดีด Velocity ]] -- 
                        hrp.CFrame = spotFreeze * CFrame.new(0, 5, 0)

                        vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)

                        task.wait(0.1)

                        vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

                        

                        task.wait(1)

                        table.clear(minerIdleTimes)  task.wait(0.5)

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



-- [[ 5. Anti-AFK ]] --

player.Idled:Connect(function()

    game:GetService("VirtualUser"):CaptureController()

    game:GetService("VirtualUser"):ClickButton2(Vector2.new())

end)



print("Miner Hub Fixed: UI and Jump Force Ready!")
