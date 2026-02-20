local s = odh_shared_plugins
local p = game:GetService("Players")
local w = game:GetService("Workspace")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")

if s.game_name ~= "Escape Tsunami For Brainrots" then return end

local lp = p.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local sec = s.AddSection("TSUNAMI")

local function ch()
    local c = lp.Character or lp.CharacterAdded:Wait()
    return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

local function computeTweenSpeedFromWalkSpeed(walkSpeed)
    if not walkSpeed then return defaultSpeed end

    local speed
    if walkSpeed <= 40 then
        speed = walkSpeed * 10
    elseif walkSpeed <= 120 then
        speed = 400 + (walkSpeed - 40) * 6
    else
        speed = 880 + (walkSpeed - 120) * 3
    end

    speed = math.floor(speed + 0.5)
    if speed > 2000 then speed = 2000 end
    if speed < 50 then speed = 50 end
    return speed
end

local pussy = false

local defaultSpeed = 1300
local activeTween = nil

local MAX_TWEEN_SPEED = 1555

local function lockCharacter(hum, root)
    hum.AutoRotate = false
    hum.PlatformStand = true
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function unlockCharacter(hum)
    hum.PlatformStand = false
    hum.AutoRotate = true
end

local function mv(pos, speed)
    local c, hum, r = ch()
    if not r or not r.Parent then return end

    if not speed then
        local ws = hum and hum.WalkSpeed
        speed = computeTweenSpeedFromWalkSpeed(ws)
    end

    speed = math.clamp(speed, 50, MAX_TWEEN_SPEED)

    local dist = (r.Position - pos).Magnitude
    if dist <= 2 then
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = CFrame.new(pos)
        return
    end

    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end

    local duration = math.max(0.03, dist / speed)

    lockCharacter(hum, r)

    local ok, tween = pcall(function()
        return ts:Create(
            r,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(pos)}
        )
    end)

    if ok and tween then
        activeTween = tween
        tween:Play()

        local t0 = tick()
        while tick() - t0 < duration do
            if not r.Parent then break end
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            rs.Heartbeat:Wait()
        end

        pcall(function() tween:Cancel() end)
        activeTween = nil
    else
        while true do
            local dt = rs.Heartbeat:Wait()
            if not r.Parent then break end

            local diff = pos - r.Position
            local d = diff.Magnitude
            if d <= 2 then break end

            local step = math.min(speed * dt, d)
            r.CFrame = CFrame.new(r.Position + diff.Unit * step)
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end

    if r.Parent then
        r.CFrame = CFrame.new(pos)
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end

    unlockCharacter(hum)
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

local gr = {
    ["Gap 12"] = Vector3.new(4024, -3, 12),
    ["Gap 11"] = Vector3.new(3668, -3, 5),
    ["Gap 10"] = Vector3.new(3309, -3, 0),
    ["Gap 9"]  = Vector3.new(2958, -3, 31),
    ["Gap 8"]  = Vector3.new(2249, -3, 15),
    ["Gap 7"]  = Vector3.new(1554, -3, 15),
    ["Gap 6"]  = Vector3.new(1072, -3, 1),
    ["Gap 5"]  = Vector3.new(756, -3, -4),
    ["Gap 4"]  = Vector3.new(543, -3, -7),
    ["Gap 3"]  = Vector3.new(398, -3, -10),
    ["Gap 2"]  = Vector3.new(285, -3, -13),
    ["Gap 1"]  = Vector3.new(199, -3, -17),
}

local gn = {"Gap 12","Gap 11","Gap 10","Gap 9","Gap 8","Gap 7","Gap 6","Gap 5","Gap 4","Gap 3","Gap 2","Gap 1"}
local cur_gap = "Gap 1"

sec:AddDropdown("Gap", gn, function(v) cur_gap = v end)

sec:AddButton("Teleport To Gap", function()
    if pussy then return end
    pussy = true
    local _,_,r = ch()
    local current_pos = r.Position
    mv(Vector3.new(current_pos.X, -7, current_pos.Z))
    local target = gr[cur_gap]
    mv(Vector3.new(target.X, -7, target.Z))
    mv(target)
    pussy = false
end)

local function tb()
    if pussy then return end
    pussy = true
    local _,_,r = ch()
    local current_pos = r.Position
    mv(Vector3.new(current_pos.X, -7, current_pos.Z))
    mv(Vector3.new(152, -7, -133))
    mv(Vector3.new(152, 3, -133))
    local b = fb()
    if b then mv(b:GetPivot().Position + Vector3.new(0,5,0)) end
    pussy = false
end

sec:AddButton("Teleport To Base", tb)
sec:AddKeybind("Teleport To Base Key", "B", tb)

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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true ds = i.Position sp = btn.Position
            btn:TweenSize(UDim2.new(0,130,0,46), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
            btn:TweenSize(UDim2.new(0,140,0,50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        end
    end)
    btn.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    btn.MouseButton1Click:Connect(tb)
end

sec:AddToggle("Show Teleport Button", function(v)
    if v then cg() else if gui then gui:Destroy() gui = nil btn = nil end end
end)

local autoTakeBrainrots = false
local firedPrompts = {}

local function autoTake()
    firedPrompts = {}
    for _, obj in ipairs(w:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and not firedPrompts[obj] then
            local pn = obj.Name
            local pp = obj.Parent and obj.Parent.Name or ""
            if (pn == "TakePrompt" and pp == "Root") then
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
        local pn = desc.Name
        local pp = desc.Parent and desc.Parent.Name or ""
        if pn == "TakePrompt" and pp == "Root" then
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

local autoFarmEnabled = false
local rarityList = {
    "Infinity",
    "Divine",
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

local selectedRarity = rarityList[#rarityList]

sec:AddDropdown("Rarity Auto Farm", rarityList, function(v)
    selectedRarity = v
end)

local ab = workspace:FindFirstChild("ActiveBrainrots")
if ab then
    for _,v in ipairs(ab:GetChildren()) do
        if v:IsA("Folder") then
            table.insert(rarityList, v.Name)
        end
    end
end

local function isBrainrotAlive(m, rarityFolder)
    if not m then return false end
    if not m.Parent or m.Parent ~= rarityFolder then return false end
    if not m:IsDescendantOf(workspace) then return false end

    local root = m:FindFirstChild("Root")
    if not root or not root.Parent then return false end
    if not root:IsDescendantOf(workspace) then return false end

    local prompt = root:FindFirstChild("TakePrompt")
    if not prompt or not prompt.Parent then return false end
    if not prompt.Enabled then return false end

    if root:FindFirstChildWhichIsA("Weld") then return false end
    if m:FindFirstChild("Carried") then return false end

    return true, root, prompt
end

local function findNextBrainrot(rarityFolder)
    if not rarityFolder then return nil end

    local candidates = {}
    for _, m in ipairs(rarityFolder:GetChildren()) do
        if m:IsA("Model") and m.Name == "RenderedBrainrot" then
            local alive, root, prompt = isBrainrotAlive(m, rarityFolder)
            if alive then
                table.insert(candidates, {model = m, root = root, prompt = prompt, pos = root.Position})
            end
        end
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b)
        return a.pos.X < b.pos.X
    end)

    local nearest = candidates[1]
    return nearest.model, nearest.root, nearest.prompt
end

local function sampleZ(rarityFolder)
    if not rarityFolder then return -133 end
    for _,m in ipairs(rarityFolder:GetChildren()) do
        if m:IsA("Model") and m.Name == "RenderedBrainrot" then
            local root = m:FindFirstChild("Root") or m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart")
            if root then
                return root:GetPivot().Position.Z
            end
        end
    end
    return -133
end

local function takeOne(rarityFolder)
    local m, root, prompt = findNextBrainrot(rarityFolder)
    if not m then return false end

    local pos = root.Position
    local z = sampleZ(rarityFolder)

    mv(Vector3.new(152, -7, z))

    local alive, r2, pr2 = isBrainrotAlive(m, rarityFolder)
    if not alive then
        return false
    end

    mv(Vector3.new(pos.X, -7, pos.Z))

    alive, r2, pr2 = isBrainrotAlive(m, rarityFolder)
    if not alive then
        return false
    end

    local c, hum, hrp = ch()
    if not hrp then return false end

    lockCharacter(hum, hrp)

    local taken = false
    local max_attempts = 20
    for i = 1, max_attempts do
        alive, r2, pr2 = isBrainrotAlive(m, rarityFolder)
        if not alive then
            taken = true
            break
        end

        if not hrp.Parent then break end

        local dist = (hrp.Position - r2.Position).Magnitude
        if dist <= (pr2.MaxActivationDistance + 5) then
            pcall(function()
                fireproximityprompt(pr2, 0)
            end)
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        task.wait(0.05)
    end

    unlockCharacter(hum)

    if not taken then
        return false
    end

    mv(Vector3.new(152, -7, z))
    task.wait(0.1)
    mv(Vector3.new(152, 3, z))

    return true
end

local function autoFarmLoop()
    task.spawn(function()
        while autoFarmEnabled do
            local ab = workspace:FindFirstChild("ActiveBrainrots")
            if not ab then task.wait(0.5) continue end
            local rf = ab:FindFirstChild(selectedRarity)
            if not rf then task.wait(0.5) continue end
            local ok = false
            pcall(function() ok = takeOne(rf) end)
            if not ok then task.wait(0.3) else task.wait(0.15) end
        end
    end)
end

sec:AddToggle("Auto Farm Brainrots", function(v)
    autoFarmEnabled = v
    if v then
        if not selectedRarity and #rarityList > 0 then
            selectedRarity = rarityList[1]
        end
        autoFarmLoop()
    end
end)
