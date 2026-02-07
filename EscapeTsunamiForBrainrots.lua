local s = odh_shared_plugins
local p = game:GetService("Players")
local w = game:GetService("Workspace")
local rs = game:GetService("RunService")

if s.game_name ~= "Escape Tsunami For Brainrots" then return end

local lp = p.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local sec = s.AddSection("TSUNAMI")

local function ch()
    local c = lp.Character or lp.CharacterAdded:Wait()
    return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

local function vip()
    local mapFolder = w:FindFirstChild("DefaultMap_SharedInstances")
    if not mapFolder then
        mapFolder = w:FindFirstChild("DefaultMap")
    end
    if not mapFolder then return end
    
    local vipWalls = mapFolder:FindFirstChild("VIPWalls")
    if not vipWalls then return end

    local function disablePart(x)
        if x:IsA("BasePart") then
            x.CanCollide = false
            x.CanTouch = false
            x.CanQuery = false
        elseif x:IsA("TouchTransmitter") or x:IsA("ClickDetector") then
            x:Destroy()
        end
    end

    for _, x in ipairs(vipWalls:GetDescendants()) do
        disablePart(x)
    end

    vipWalls.DescendantAdded:Connect(disablePart)

    mapFolder.DescendantAdded:Connect(function(child)
        if child.Name == "VIPWalls" then
            for _, x in ipairs(child:GetDescendants()) do
                disablePart(x)
            end
            child.DescendantAdded:Connect(disablePart)
        end
    end)
end

local spd = 2000
local busy = false

local function nc(v)
    local _,_,r = ch()
    r.CanCollide = not v
end

local function mv(pos)
    local _,_,r = ch()
    nc(true)

    local target = pos

    while true do
        local dt = rs.Heartbeat:Wait()
        local diff = target - r.Position
        local dist = diff.Magnitude

        if dist <= 2 then
            break
        end

        local step = math.min(spd * dt, dist)
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = CFrame.new(r.Position + diff.Unit * step)
    end

    r.AssemblyLinearVelocity = Vector3.zero
    r.CFrame = CFrame.new(target)
    nc(false)
end

local function fb()
    local n = lp.Name
    local bs = w:FindFirstChild("Bases")
    if not bs then return nil end
    for _,b in ipairs(bs:GetChildren()) do
        if not b:IsA("Model") and not b:IsA("Folder") then continue end
        local g = b:FindFirstChild("TitleGui", true)
        if not g then continue end
        local f = g:FindFirstChildWhichIsA("Frame")
        if not f then continue end
        local l = f:FindFirstChild("PlayerName")
        if not l then continue end
        if (l:IsA("TextLabel") or l:IsA("TextButton")) and l.Text == n then
            return b
        end
    end
    return nil
end

local ar = {
    Celestial = Vector3.new(2763,52,-140),
    Secret    = Vector3.new(2465,3,-137),
    Cosmic    = Vector3.new(1990,3,-137),
    Mythical  = Vector3.new(1365,3,-137),
    Legendary = Vector3.new(953,3,-137),
    Epic      = Vector3.new(679,3,-137),
    Rare      = Vector3.new(500,3,-137),
    Uncommon  = Vector3.new(360,3,-137),
    Common    = Vector3.new(257,3,-137),
}

local an = {
    "Celestial",
    "Secret",
    "Cosmic",
    "Mythical",
    "Legendary",
    "Epic",
    "Rare",
    "Uncommon",
    "Common"
}

local cur = "Celestial"

sec:AddDropdown("Area", an, function(v)
    cur = v
end)

local function na(pos)
    local b, d
    for k,v in pairs(ar) do
        local m = (v - pos).Magnitude
        if not d or m < d then
            d = m
            b = {key = k, pos = v}
        end
    end
    return b
end

local function tb()
    if busy then return end
    busy = true

    local _,_,r = ch()
    local nearest = na(r.Position)
    local nearest_pos = nearest.pos
    if nearest.key == "Celestial" then
        nearest_pos = Vector3.new(2617, 3, -139)
    end
    if nearest_pos then
        mv(nearest_pos)
    end
    local up_pos = Vector3.new(nearest_pos.X, 52, -140)
    mv(up_pos)
    mv(Vector3.new(152, 52, -140))
    local b = fb()
    if b then
        local cf = b:GetPivot()
        mv(cf.Position + Vector3.new(0,5,0))
    end

    busy = false
end

sec:AddButton("Teleport To Area + Unlock VIP Walls", function()
    if busy then return end
    busy = true
    vip()
    if cur == "Celestial" then
        mv(Vector3.new(152, 52, -140))
        mv(ar[cur])
        local old_spd = spd
        spd = 4000
        local down_pos = Vector3.new(ar[cur].X, -2, ar[cur].Z)
        mv(down_pos)
        spd = old_spd
        mv(Vector3.new(2617, -2, -69))
    else
        mv(Vector3.new(152, 52, -140))
        local high_pos = Vector3.new(ar[cur].X, 52, -140)
        mv(high_pos)
        mv(ar[cur])
    end
    busy = false
end)

sec:AddButton("Teleport To Base", tb)

sec:AddKeybind("Teleport To Base Key", Enum.KeyCode.B, tb)

local gui, btn
local drag, ds, sp = false, nil, nil

local function cg()
    if gui then gui:Destroy() end
    gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = pg

    btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,140,0,50)
    btn.Position = UDim2.new(0.5,-70,0.85,-60)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "Teleport Base"
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            ds = i.Position
            sp = btn.Position
            btn:TweenSize(UDim2.new(0,130,0,46), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        end
    end)

    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
            btn:TweenSize(UDim2.new(0,140,0,50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        end
    end)

    btn.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            btn.Position = UDim2.new(
                sp.X.Scale, sp.X.Offset + d.X,
                sp.Y.Scale, sp.Y.Offset + d.Y
            )
        end
    end)

    btn.MouseButton1Click:Connect(tb)
end

sec:AddToggle("Show Teleport Button", function(v)
    if v then
        cg()
    else
        if gui then gui:Destroy() gui = nil btn = nil end
    end
end)

local autoTakeBrainrots = false
local firedPrompts = {}

local function autoTake()
    firedPrompts = {}
    
    for _, obj in ipairs(w:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and not firedPrompts[obj] then
            local promptName = obj.Name
            local parentName = obj.Parent and obj.Parent.Name or ""
            
            local shouldFire = false
            
            if promptName == "TakePrompt" and parentName == "Root" then
                shouldFire = true
            elseif promptName == "ProximityPrompt" and parentName == "RootPart" then
                shouldFire = true
            end
            
            if shouldFire then
                pcall(function()
                    fireproximityprompt(obj)
                    firedPrompts[obj] = true
                end)
            end
        end
    end
end

sec:AddToggle("Auto Carry Brainrots", function(v)
    autoTakeBrainrots = v
    if v then
        task.spawn(function()
            while autoTakeBrainrots do
                autoTake()
                task.wait(0.3)
            end
        end)
    else
        firedPrompts = {}
    end
end)

w.DescendantAdded:Connect(function(desc)
    if autoTakeBrainrots and desc:IsA("ProximityPrompt") and not firedPrompts[desc] then
        local promptName = desc.Name
        local parentName = desc.Parent and desc.Parent.Name or ""
        
        local shouldFire = false
        
        if promptName == "TakePrompt" and parentName == "Root" then
            shouldFire = true
        elseif promptName == "ProximityPrompt" and parentName == "RootPart" then
            shouldFire = true
        end
        
        if shouldFire then
            task.spawn(function()
                task.wait(0.1)
                pcall(function()
                    fireproximityprompt(desc)
                    firedPrompts[desc] = true
                end)
            end)
        end
    end
end)

local bringGoldBar = false

local function bringGold()
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local moneyEventParts = w:FindFirstChild("MoneyEventParts")
    if moneyEventParts then
        for _, part in ipairs(moneyEventParts:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Main" and part.Parent and part.Parent.Name == "GoldBar" then
                pcall(function()
                    part.Anchored = false
                    part.CanCollide = false
                    part.AssemblyLinearVelocity = Vector3.new()
                    part.AssemblyAngularVelocity = Vector3.new()
                    part.CFrame = hrp.CFrame * CFrame.new(math.random(-5,5), 3, math.random(-5,5))
                end)
            end
        end
    end
    
    for _, part in ipairs(w:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Main" and part.Parent and part.Parent.Name == "GoldBar" then
            pcall(function()
                part.Anchored = false
                part.CanCollide = false
                part.AssemblyLinearVelocity = Vector3.new()
                part.AssemblyAngularVelocity = Vector3.new()
                part.CFrame = hrp.CFrame * CFrame.new(math.random(-5,5), 3, math.random(-5,5))
            end)
        end
    end
end

sec:AddToggle("Auto Bring All Gold (MoneyEvent)", function(v)
    bringGoldBar = v
    if v then
        task.spawn(function()
            while bringGoldBar do
                bringGold()
                task.wait(0.3)
            end
        end)
    end
end)

w.DescendantAdded:Connect(function(obj)
    if bringGoldBar and obj:IsA("BasePart") and obj.Name == "Main" and obj.Parent and obj.Parent.Name == "GoldBar" and obj.Parent.Parent and obj.Parent.Parent.Name == "MoneyEventParts" then
        task.spawn(function()
            task.wait(0.1)
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                pcall(function()
                    obj.Anchored = false
                    obj.CanCollide = false
                    obj.AssemblyLinearVelocity = Vector3.new()
                    obj.CFrame = hrp.CFrame * CFrame.new(math.random(-5,5), 3, math.random(-5,5))
                end)
            end
        end)
    end
end)
