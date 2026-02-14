local shared = odh_shared_plugins

local flick_section = shared.AddSection("Flick to Murderer")

local flickEnabled = false
local flickSpeed = 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local murdererButton

local function findMurderer()
    if game.PlaceId == 142823291 then
        local success, roleData = pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
            if remote and remote:IsA("RemoteFunction") then
                return remote:InvokeServer()
            end
        end)
        if success and roleData then
            for playerName, data in pairs(roleData) do
                if data.Role == "Murderer" and not data.Killed and not data.Dead then
                    local p = Players:FindFirstChild(playerName)
                    if p then return p end
                end
            end
        end
        return nil
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    local bp = player:FindFirstChild("Backpack")
                    if bp and bp:FindFirstChild("Knife") then return player end
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == "Knife" then
                            return player
                        end
                    end
                end
            end
        end
        return nil
    end
end

local function flickToMurderer()
    if not flickEnabled then return end
    
    local murderer = findMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        shared.Notify("Murderer not found!", 3)
        return
    end
    
    local cam = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    local targetPos = murderer.Character.HumanoidRootPart.Position
    local oldCFrame = cam.CFrame
    local targetCFrame = CFrame.lookAt(oldCFrame.Position, targetPos)
    
    local steps = 8
    local waitTime = (flickSpeed / 1000) / steps
    
    for i = 1, steps do
        local alpha = i / steps
        local newCFrame = oldCFrame:Lerp(targetCFrame, alpha)
        cam.CFrame = newCFrame
        task.wait(waitTime)
    end
    
    for i = 1, steps do
        local alpha = i / steps
        local newCFrame = targetCFrame:Lerp(oldCFrame, alpha)
        cam.CFrame = newCFrame
        task.wait(waitTime * 0.7)
    end
    
    cam.CFrame = oldCFrame
end

flick_section:AddToggle("Enable Flick", function(state)
    flickEnabled = state
    if state then
        shared.Notify("Flick enabled", 1)
    else
        shared.Notify("Flick disabled", 3)
    end
end)

flick_section:AddSlider("Flick Speed (ms)", 1, 50, 1, function(value)
    flickSpeed = value
end)

flick_section:AddKeybind("Flick Key", "F", function()
    flickToMurderer()
end)

flick_section:AddToggle("Show Mobile Flick Button", function(state)
    if state then
        if murdererButton then murdererButton:Destroy() end
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "FlickMobileGui"
        gui.ResetOnSpawn = false
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        
        local button = Instance.new("TextButton")
        button.Text = "FLICK"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
        button.Size = UDim2.new(0, 100, 0, 50)
        button.Position = UDim2.new(0.8, 0, 0.3, 0)
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 24
        button.Parent = gui
        
        murdererButton = button
        
        local dragging, dragInput, dragStart, startPos
        
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Vector2.new(button.Position.X.Offset, button.Position.Y.Offset)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        button.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                local screenSize = workspace.CurrentCamera.ViewportSize
                button.Position = UDim2.new(
                    0, math.clamp(startPos.X + delta.X, 0, screenSize.X - button.AbsoluteSize.X),
                    0, math.clamp(startPos.Y + delta.Y, 0, screenSize.Y - button.AbsoluteSize.Y)
                )
            end
        end)
        
        button.MouseButton1Click:Connect(flickToMurderer)
    else
        if murdererButton then
            murdererButton:Destroy()
            murdererButton = nil
        end
    end
end)