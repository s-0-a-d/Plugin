local s = odh_shared_plugins
local p = game:GetService("Players")
local w = game:GetService("Workspace")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")

if s.game_name ~= "Escape Tsunami For Brainrots" then return end

local lp = p.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local sec = s.AddSection("TSUNAMI")

task.spawn(function()
    local targetPos = Vector3.new(2384.8999, 32.0000153, 134.975052)
    
    local currentDM = nil
    local currentShared = nil
    
    local function applyChanges(dm, sharedFolder)
        if not dm or not dm.Parent then return end
        
        if dm:FindFirstChild("RightWalls") then
            dm.RightWalls:Destroy()
        end
        
        local vipFolder = sharedFolder or dm
        if vipFolder:FindFirstChild("VIPWalls") then
            vipFolder.VIPWalls:Destroy()
        end
        
        local gaps = dm:FindFirstChild("Gaps")
        if gaps then
            for i = 1, 9 do
                local gap = gaps:FindFirstChild("Gap" .. i)
                if gap and gap:FindFirstChild("Mud") then
                    local mud = gap.Mud
                    if not mud:FindFirstChild("Script_Generated") then
                        local bridge = Instance.new("Part")
                        bridge.Name = "Script_Generated"
                        bridge.Size = Vector3.new(mud.Size.X, mud.Size.Y, mud.Size.Z * 800)
                        bridge.Anchored = true
                        bridge.CanCollide = true
                        bridge.Material = mud.Material
                        bridge.Color = mud.Color
                        bridge.CFrame = mud.CFrame * CFrame.new(0, 0, mud.Size.Z * 2)
                        bridge.TopSurface = Enum.SurfaceType.Studs
                        bridge.BottomSurface = Enum.SurfaceType.Inlet
                        bridge.FrontSurface = Enum.SurfaceType.Smooth
                        bridge.BackSurface = Enum.SurfaceType.Smooth
                        bridge.LeftSurface = Enum.SurfaceType.Smooth
                        bridge.RightSurface = Enum.SurfaceType.Smooth
                        bridge.Parent = mud.Parent
                    end
                end
            end
        end
        
        local function createWall(x)
            local wallName = "Script_Generated_Wall_" .. x
            if dm:FindFirstChild(wallName) then return end
            local wall = Instance.new("Part")
            wall.Name = wallName
            wall.Size = Vector3.new(100000, 100, 5)
            wall.Position = Vector3.new(x, 7.93, -138.8)
            wall.Anchored = true
            wall.CanCollide = true
            wall.Material = Enum.Material.Plastic
            wall.Color = Color3.fromRGB(255, 170, 0)
            wall.TopSurface = Enum.SurfaceType.Studs
            wall.BottomSurface = Enum.SurfaceType.Inlet
            wall.FrontSurface = Enum.SurfaceType.Smooth
            wall.BackSurface = Enum.SurfaceType.Smooth
            wall.LeftSurface = Enum.SurfaceType.Smooth
            wall.RightSurface = Enum.SurfaceType.Smooth
            wall.Parent = dm
        end
        
        createWall(1180.3)
        createWall(2000.3)
        createWall(3000.3)
        createWall(4000.3)
        createWall(5000.3)
    end
    
    local function destroyAtTarget(obj)
        if obj.Name:match("^Script_Generated") then return end
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local pos = obj:GetPivot().Position
            if (pos - targetPos).Magnitude < 0.5 then
                obj:Destroy()
            end
        end
    end
    
    local function findCurrentMap()
        for _, child in ipairs(w:GetChildren()) do
            if child:IsA("Folder") and child.Name:match("_SharedInstances$") then
                local mapName = child.Name:gsub("_SharedInstances$", "")
                local dm = w:FindFirstChild(mapName)
                if dm then
                    currentDM = dm
                    currentShared = child
                    return true
                end
            end
        end
        return false
    end
    
    local function initialDestroy()
        for _, v in ipairs(w:GetDescendants()) do
            destroyAtTarget(v)
        end
    end
    
    if findCurrentMap() then
        applyChanges(currentDM, currentShared)
        initialDestroy()
    end
    
    w.ChildAdded:Connect(function(child)
        if child.Name:match("_SharedInstances$") or (currentDM and child.Name == currentDM.Name) then
            task.wait(0.8)
            if findCurrentMap() then
                applyChanges(currentDM, currentShared)
                initialDestroy()
            end
        end
    end)
    
    w.DescendantAdded:Connect(function(desc)
        if currentDM and (desc:IsA("BasePart") or desc:IsA("Model")) then
            task.delay(0.15, function()
                if desc and desc.Parent then
                    destroyAtTarget(desc)
                end
            end)
        end
    end)
    
    task.spawn(function()
        while true do
            task.wait(1)
            if not currentDM or not currentDM.Parent then
                findCurrentMap()
            end
            if currentDM then
                applyChanges(currentDM, currentShared)
            end
        end
    end)
end)

local function ch()
    local c = lp.Character or lp.CharacterAdded:Wait()
    return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

local spd = 2000
local busy = false

local function mv(pos)
    local _, hum, r = ch()
    spd = math.min(hum.WalkSpeed * 6, 2000)
    local target = pos
    while true do
        local dt = rs.Heartbeat:Wait()
        local diff = target - r.Position
        local dist = diff.Magnitude
        if dist <= 2 then break end
        local step = math.min(spd * dt, dist)
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = CFrame.new(r.Position + diff.Unit * step)
    end
    r.AssemblyLinearVelocity = Vector3.zero
    r.CFrame = CFrame.new(target)
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
    ["Celestial"]   = Vector3.new(4184, 3, -136),
    ["Secret 3"]    = Vector3.new(3850, 3, -136),
    ["Secret 2"]    = Vector3.new(3518, 3, -136),
    ["Secret"]      = Vector3.new(3154, 3, -136),
    ["Cosmic 2"]    = Vector3.new(2543, 3, -136),
    ["Cosmic"]      = Vector3.new(1920, 3, -136),
    ["Mythical"]    = Vector3.new(1365, 3, -137),
    ["Legendary"]   = Vector3.new(953,  3, -137),
    ["Epic"]        = Vector3.new(679,  3, -137),
    ["Rare"]        = Vector3.new(500,  3, -137),
    ["Uncommon"]    = Vector3.new(360,  3, -137),
    ["Common"]      = Vector3.new(257,  3, -137),
}

local an = {"Celestial","Secret 3","Secret 2","Secret","Cosmic 2","Cosmic","Mythical","Legendary","Epic","Rare","Uncommon","Common"}
local cur = "Celestial"

sec:AddDropdown("Area", an, function(v) cur = v end)

local function na(pos)
    local b, d
    for k,v in pairs(ar) do
        local m = (v - pos).Magnitude
        if not d or m < d then d = m b = {key = k, pos = v} end
    end
    return b
end

local function tb()
    if busy then return end
    busy = true
    local _,_,r = ch()
    local nearest = na(r.Position)
    local nearest_pos = nearest.pos
    mv(nearest_pos)
    mv(Vector3.new(nearest_pos.X, 3, -137))
    mv(Vector3.new(152, 3, -137))
    local b = fb()
    if b then mv(b:GetPivot().Position + Vector3.new(0,5,0)) end
    busy = false
end

sec:AddButton("Teleport To Area + Unlock VIP Walls", function()
    if busy then return end
    busy = true
    mv(Vector3.new(152, 3, -137))
    mv(Vector3.new(ar[cur].X, 3, -137))
    mv(ar[cur])
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
            if (pn == "TakePrompt" and pp == "Root") or (pn == "ProximityPrompt" and pp == "RootPart") then
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
        if (pn == "TakePrompt" and pp == "Root") or (pn == "ProximityPrompt" and pp == "RootPart") then
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

sec:AddLabel("Auto Farm")

local raritiesList = {
    "Infinity", "Divine", "Celestial", "Secret", "Cosmic", "Mythical", "Legendary",
    "Epic", "Rare", "Uncommon", "Common"
}

local selectedRarity = raritiesList[1]

sec:AddDropdown("Rarity", raritiesList, function(v)
    selectedRarity = v
end)

local function getCharData()
    local c = lp.Character or lp.CharacterAdded:Wait()
    local h = c:WaitForChild("Humanoid", 5)
    local r = c:WaitForChild("HumanoidRootPart", 5)
    return c, h, r
end

local function isCarrying()
    local c = lp.Character
    if not c then return false end
    return c:FindFirstChild("RenderedBrainrot") ~= nil or c:FindFirstChildWhichIsA("Tool") ~= nil
end

sec:AddToggle("Auto Farm", function(state)
    autoFarm = state
    if autoFarm then
        task.spawn(function()
            while autoFarm do
                pcall(function()
                    local char, hum, root = getCharData()
                    
                    if not char or not hum or hum.Health <= 0 then 
                        busy = false
                        task.wait(3)
                        return 
                    end

                    if busy then 
                        task.wait(0.1)
                        return 
                    end

                    busy = true
                    local safeY = -80
                    
                    mv(Vector3.new(root.Position.X, safeY, root.Position.Z))

                    if isCarrying() then
                        local base = fb()
                        if base then
                            local bPos = base:GetPivot().Position
                            mv(Vector3.new(bPos.X, safeY, bPos.Z))
                            mv(bPos + Vector3.new(0, 8, 0))
                            local startTime = tick()
                            repeat task.wait(0.05) until not isCarrying() or (tick() - startTime > 4) or not autoFarm
                            task.wait(0.2)
                            mv(Vector3.new(bPos.X, safeY, bPos.Z))
                        end
                    else
                        local folder = w:FindFirstChild("ActiveBrainrots") and w.ActiveBrainrots:FindFirstChild(selectedRarity)
                        if folder then
                            local targets = {}
                            for _, model in ipairs(folder:GetChildren()) do
                                if model.Name == "RenderedBrainrot" and model:FindFirstChild("Root") then
                                    local prompt = model.Root:FindFirstChild("TakePrompt")
                                    if prompt and prompt.Enabled then
                                        table.insert(targets, {
                                            obj = model.Root, 
                                            pos = model.Root.Position, 
                                            dist = (model.Root.Position - root.Position).Magnitude
                                        })
                                    end
                                end
                            end
                            
                            table.sort(targets, function(a, b) return a.dist < b.dist end)
                            
                            local target = targets[1]
                            if target and autoFarm and target.obj and target.obj.Parent then
                                local safePos = Vector3.new(target.pos.X, safeY, target.pos.Z)
                                mv(safePos)
                                mv(target.pos)
                                
                                task.wait(0.1)
                                local prompt = target.obj:FindFirstChild("TakePrompt")
                                if prompt then
                                    for i = 1, 5 do
                                        fireproximityprompt(prompt)
                                        task.wait(0.05)
                                        if isCarrying() then break end
                                    end
                                end
                                
                                local startTime = tick()
                                repeat task.wait(0.05) until isCarrying() or (tick() - startTime > 4) or not autoFarm
                                
                                mv(safePos)
                            end
                        end
                    end
                    busy = false
                end)
                
                task.wait(0.1)
            end
        end)
    else
        busy = false
    end
end)
