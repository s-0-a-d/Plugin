local shared = odh_shared_plugins

local __INSERT = table.insert
local __PCLR = Color3.new
local __RGB = Color3.fromRGB
local __UD2 = UDim2.new
local __UD = UDim.new
local __V2 = Vector2.new

local function getfserv(s)
    local ok, svc = pcall(function() return game:GetService(s) end)
    if ok and svc then return svc end
    ok, svc = pcall(function() return game:FindService(s) end)
    if ok and svc then return svc end
    return game[s]
end

local __RS   = getfserv("RunService")
local __UIS  = getfserv("UserInputService")
local __PLRS = getfserv("Players")
local __TS   = getfserv("TweenService")

local SAVE_FILE = "FlickButtonPositions.json"

local function savePositions(data)
    pcall(function()
        if writefile then
            writefile(SAVE_FILE, game:GetService("HttpService"):JSONEncode(data))
        end
    end)
end

local function loadPositions()
    local ok, result = pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            return game:GetService("HttpService"):JSONDecode(readfile(SAVE_FILE))
        end
    end)
    if ok and type(result) == "table" then return result end
    return {}
end

local savedPositions = loadPositions()

local DEFAULT_POSITIONS = {
    big  = { xs = 0.5, xo = 0, ys = 0.5, yo = 0 },
    bind = { xs = 0.1, xo = 0, ys = 0.9, yo = 0 },
}

local BBSystem = {Buttons = {}, Connections = {}}

local function bb_safecallback(callback)
    if not callback then return end
    local ok, err = xpcall(callback, function(e) return debug.traceback(e) end)
    if not ok then warn("[BB ERROR] " .. tostring(err)) end
end

local function BB_GetStorage()
    local parent = gethui and gethui()
    if not parent or typeof(parent) ~= "Instance" then
        parent = getfserv("CoreGui")
    end
    if not parent or typeof(parent) ~= "Instance" then
        parent = __PLRS.LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    if typeof(parent) ~= "Instance" then
        parent = __PLRS.LocalPlayer:WaitForChild("PlayerGui")
    end
    local sg = parent:FindFirstChild("@BBStorage")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "@BBStorage"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.ScreenInsets = Enum.ScreenInsets.None end)
        sg.Parent = parent
    end
    return sg
end

local __BB_GRAD_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    __PCLR(0.0784314, 0.0784314, 0.0784314)),
    ColorSequenceKeypoint.new(0.75, __PCLR(0.0784314, 0.0784314, 0.54902)),
    ColorSequenceKeypoint.new(1,    __PCLR(0.470588,  0.156863,  0.470588))
})

local function BB_MakeDraggable(gui, func, ripple, sound, getSizeFunc)
    local dragging, dragInput, dragStart, startPos
    local hasMoved = false
    local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function getNormalSize()
        return getSizeFunc and getSizeFunc() or __UD2(0, 200, 0, 75)
    end

    local function getBigSize()
        local ns = getNormalSize()
        return __UD2(ns.X.Scale, ns.X.Offset * 1.1, ns.Y.Scale, ns.Y.Offset * 1.1)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            hasMoved  = false
            dragStart = input.Position
            startPos  = gui.Position
            __TS:Create(gui, tInfo, {Size = getBigSize()}):Play()
            local absPos = gui.AbsolutePosition
            ripple.Position = __UD2(0, input.Position.X - absPos.X, 0, input.Position.Y - absPos.Y)
            ripple.Size = __UD2(0, 0, 0, 0)
            ripple.BackgroundTransparency = 0.5
            ripple.Visible = true
            sound:Play()
            __TS:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = __UD2(0, 300, 0, 300),
                BackgroundTransparency = 1
            }):Play()
            local rel
            rel = __UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    __TS:Create(gui, tInfo, {Size = getNormalSize()}):Play()
                    if not hasMoved then bb_safecallback(func) end
                    savedPositions.big = {
                        xs = gui.Position.X.Scale, xo = gui.Position.X.Offset,
                        ys = gui.Position.Y.Scale, yo = gui.Position.Y.Offset
                    }
                    savePositions(savedPositions)
                    rel:Disconnect()
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    __UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 7 then hasMoved = true end
            gui.Position = __UD2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function AddBigButton(id, text, func, getSizeFunc)
    if BBSystem.Buttons[id] then return end
    local storage = BB_GetStorage()
    local bb = Instance.new("TextButton")
    bb.Name = id
    bb.Size = getSizeFunc and getSizeFunc() or __UD2(0, 200, 0, 75)
    local sp = savedPositions.big or DEFAULT_POSITIONS.big
    bb.Position = __UD2(sp.xs, sp.xo, sp.ys, sp.yo)
    bb.AnchorPoint = __V2(0.5, 0.5)
    bb.BackgroundColor3 = __RGB(255, 255, 255)
    bb.BackgroundTransparency = 0.9
    bb.BorderSizePixel = 0
    bb.Font = Enum.Font.Jura
    bb.Text = text
    bb.TextSize = 24
    bb.TextColor3 = __RGB(255, 255, 255)
    bb.TextWrapped = true
    bb.ClipsDescendants = true
    bb.AutoButtonColor = false
    bb.ZIndex = 5
    bb.Visible = true
    bb.Parent = storage

    Instance.new("UICorner", bb).CornerRadius = __UD(0, 5)
    local stroke = Instance.new("UIStroke")
    stroke.Color = __RGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = bb
    local gradient = Instance.new("UIGradient")
    gradient.Color = __BB_GRAD_SEQ
    gradient.Parent = stroke

    local ripple = Instance.new("Frame")
    ripple.Name = "@ripple"
    ripple.BackgroundColor3 = __RGB(0, 155, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.ZIndex = 4
    ripple.Size = __UD2(0, 0, 0, 0)
    ripple.AnchorPoint = __V2(0.5, 0.5)
    ripple.Visible = false
    ripple.Parent = bb
    Instance.new("UICorner", ripple).CornerRadius = __UD(1, 0)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3868133279"
    sound.Volume = 0.5
    sound.Parent = bb

    BB_MakeDraggable(bb, func, ripple, sound, getSizeFunc)
    BBSystem.Connections[id] = __RS.RenderStepped:Connect(function()
        gradient.Rotation = (gradient.Rotation + 1) % 360
    end)
    BBSystem.Buttons[id] = bb
end

local function SetBigButtonVisible(id, visible)
    local btn = BBSystem.Buttons[id]
    if btn then btn.Visible = visible end
end

local function DeleteBigButton(id)
    if BBSystem.Buttons[id] then
        if BBSystem.Connections[id] then
            BBSystem.Connections[id]:Disconnect()
            BBSystem.Connections[id] = nil
        end
        BBSystem.Buttons[id]:Destroy()
        BBSystem.Buttons[id] = nil
    end
end

local Maid = {}
Maid.__index = Maid
function Maid.new() return setmetatable({_tasks = {}, _destroyed = false}, Maid) end
function Maid:GiveTask(t)
    if self._destroyed then
        if typeof(t) == "RBXScriptConnection" then t:Disconnect()
        elseif typeof(t) == "Instance" then t:Destroy()
        elseif type(t) == "function" then t()
        elseif type(t) == "table" and type(t.Destroy) == "function" then t:Destroy() end
        return
    end
    __INSERT(self._tasks, t)
    return t
end
function Maid:DoCleaning()
    if self._destroyed then return end
    self._destroyed = true
    for _, t in pairs(self._tasks) do
        if typeof(t) == "RBXScriptConnection" then t:Disconnect()
        elseif typeof(t) == "Instance" then t:Destroy()
        elseif type(t) == "function" then t()
        elseif type(t) == "table" and type(t.Destroy) == "function" then t:Destroy() end
    end
    self._tasks = {}
end
function Maid:Destroy() self:DoCleaning() end

local BindableButtons = {Buttons = {}, Maids = {}, Count = 0}
local __RootMaid = Maid.new()

local __SHAPES = {
    [0] = "rbxassetid://86221076925479",
    [1] = "rbxassetid://96242665417546",
    [2] = "rbxassetid://97129189935336",
    [3] = "rbxassetid://76165862027868",
    [4] = "rbxassetid://125868092127496"
}

local __NORMAL_COLOR = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   __PCLR(0.133333, 0.827451, 0.494118)),
    ColorSequenceKeypoint.new(0.6, __PCLR(0.231373, 0.509804, 0.498039)),
    ColorSequenceKeypoint.new(1,   __PCLR(0.501961, 0.501961, 0.501961))
})

local function bind_safecallback(callback)
    if not callback then return end
    local ok, err = xpcall(callback, function(e) return debug.traceback(e) end)
    if not ok then warn("[BIND ERROR] " .. tostring(err)) end
end

local function Bind_GetStorage()
    local parent = gethui and gethui()
    if not parent or typeof(parent) ~= "Instance" then
        parent = getfserv("CoreGui")
    end
    if not parent or typeof(parent) ~= "Instance" then
        parent = __PLRS.LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    if typeof(parent) ~= "Instance" then
        parent = __PLRS.LocalPlayer:WaitForChild("PlayerGui")
    end
    local sg = parent:FindFirstChild("@bindstorage")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "@bindstorage"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.ScreenInsets = Enum.ScreenInsets.None end)
        sg.Parent = parent
        __RootMaid:GiveTask(sg)
    end
    return sg
end

local function Bind_MakeDraggable(gui, maid, ripple, sound, clickFunc)
    local dragging, dragInput, dragStart, startPos
    local hasMoved = false

    maid:GiveTask(gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, gui.Position
            hasMoved = false
            sound:Play()
            local absPos = gui.AbsolutePosition
            ripple.Position = __UD2(0, input.Position.X - absPos.X, 0, input.Position.Y - absPos.Y)
            ripple.Size = __UD2(0, 0, 0, 0)
            ripple.BackgroundTransparency = 0.5
            ripple.Visible = true
            __TS:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = __UD2(0, 45, 0, 45),
                BackgroundTransparency = 1
            }):Play()
            local rel
            rel = __UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    if not hasMoved then
                        bind_safecallback(clickFunc)
                    else
                        savedPositions.bind = {
                            xs = gui.Position.X.Scale, xo = gui.Position.X.Offset,
                            ys = gui.Position.Y.Scale, yo = gui.Position.Y.Offset
                        }
                        savePositions(savedPositions)
                    end
                    rel:Disconnect()
                end
            end)
        end
    end))

    maid:GiveTask(gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    maid:GiveTask(__UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 7 then hasMoved = true end
            local screen = gui.Parent.AbsoluteSize
            gui.Position = __UD2(startPos.X.Scale + (delta.X / screen.X), 0, startPos.Y.Scale + (delta.Y / screen.Y), 0)
        end
    end))
end

function BindableButtons.AddBButton(id, text, clickFunc)
    if BindableButtons.Buttons[id] then return end

    local buttonMaid = Maid.new()
    local camera = workspace.CurrentCamera
    local screen = camera.ViewportSize
    local buttonSizeY = 0.11
    local widthScale = buttonSizeY * (screen.Y / screen.X)

    local sp = savedPositions.bind
    local xPos, yPos
    if sp then
        xPos = sp.xs
        yPos = sp.ys
    else
        xPos = 0.1 + ((BindableButtons.Count % 8) * (widthScale + 0.005))
        yPos = 0.9 - (math.floor(BindableButtons.Count / 8) * (buttonSizeY + 0.015))
    end

    local ImageButton = Instance.new("ImageButton")
    ImageButton.Name = id
    ImageButton.Size = __UD2(widthScale, 0, buttonSizeY, 0)
    ImageButton.Position = __UD2(xPos, 0, yPos, 0)
    ImageButton.AnchorPoint = __V2(0.5, 0.5)
    ImageButton.Image = __SHAPES[0]
    ImageButton.BackgroundTransparency = 1
    ImageButton.BorderSizePixel = 0
    ImageButton.ClipsDescendants = false
    ImageButton.AutoButtonColor = false
    ImageButton.Visible = true
    ImageButton.Parent = Bind_GetStorage()
    buttonMaid:GiveTask(ImageButton)

    local TextLabel = Instance.new("TextLabel", ImageButton)
    TextLabel.Name = "@Text"
    TextLabel.Size = __UD2(0.8, 0, 0.8, 0)
    TextLabel.Position = __UD2(0.5, 0, 0.5, 0)
    TextLabel.AnchorPoint = __V2(0.5, 0.5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.Jura
    TextLabel.Text = text
    TextLabel.TextColor3 = __PCLR(1, 1, 1)
    TextLabel.TextSize = 10
    TextLabel.TextWrapped = true
    TextLabel.ZIndex = 3

    local Aspect = Instance.new("UIAspectRatioConstraint", ImageButton)
    Aspect.AspectRatio = 1
    Aspect.AspectType = Enum.AspectType.ScaleWithParentSize

    local Stroke = Instance.new("UIGradient", ImageButton)
    Stroke.Name = "@Stroke"
    Stroke.Color = __NORMAL_COLOR

    local ripple = Instance.new("Frame")
    ripple.Name = "@ripple"
    ripple.BackgroundColor3 = __RGB(0, 155, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.Size = __UD2(0, 0, 0, 0)
    ripple.AnchorPoint = __V2(0.5, 0.5)
    ripple.Visible = false
    ripple.ZIndex = 2
    ripple.Parent = ImageButton
    Instance.new("UICorner", ripple).CornerRadius = __UD(1, 0)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3868133279"
    sound.Volume = 0.5
    sound.Parent = ImageButton

    Bind_MakeDraggable(ImageButton, buttonMaid, ripple, sound, clickFunc)
    buttonMaid:GiveTask(__RS.RenderStepped:Connect(function()
        Stroke.Rotation = (Stroke.Rotation + 1) % 360
    end))

    BindableButtons.Buttons[id] = ImageButton
    BindableButtons.Maids[id] = buttonMaid
    BindableButtons.Count = BindableButtons.Count + 1
end

local function SetBindButtonVisible(id, visible)
    local btn = BindableButtons.Buttons[id]
    if btn then btn.Visible = visible end
end

function BindableButtons.DeleteBButton(id)
    if BindableButtons.Maids[id] then
        BindableButtons.Maids[id]:Destroy()
        BindableButtons.Maids[id] = nil
        BindableButtons.Buttons[id] = nil
    end
end

local flick_section = shared.AddSection("Flick to Murderer")

local flickEnabled     = false
local flickSpeed       = 1
local autoShootEnabled = false
local bigButtonSize    = 200
local bindButtonSize   = 0.11

local bigButtonCreated  = false
local bindButtonCreated = false

local Players           = __PLRS
local LocalPlayer       = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
                local hum  = char:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    local bp = player:FindFirstChild("Backpack")
                    if bp and bp:FindFirstChild("Knife") then return player end
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == "Knife" then return player end
                    end
                end
            end
        end
        return nil
    end
end

local function findShootRemote()
    local ns = ReplicatedStorage:FindFirstChild("Axioria Solver was here.")
    if not ns then return nil end
    for _, v in ipairs(ns:GetChildren()) do
        if v:IsA("RemoteEvent") then return v end
    end
    return nil
end

local function autoShoot(murderer)
    if not autoShootEnabled then return end
    if not murderer or not murderer.Character then return end
    local remote = findShootRemote()
    if not remote then return end
    local murdererRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererRoot then return end
    pcall(function()
        remote:FireServer(table.unpack({
            [1] = workspace.CurrentCamera.CFrame,
            [2] = CFrame.new(murdererRoot.Position),
        }))
    end)
end

local function flickToMurderer()
    if not flickEnabled then
        shared.Notify("Flick is disabled!", 3)
        return
    end
    local murderer = findMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        shared.Notify("Murderer not found!", 3)
        return
    end
    local cam  = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local targetPos    = murderer.Character.HumanoidRootPart.Position
    local oldCFrame    = cam.CFrame
    local targetCFrame = CFrame.lookAt(oldCFrame.Position, targetPos)

    local currentLook  = oldCFrame.LookVector
    local targetLook   = (targetPos - oldCFrame.Position).Unit
    local dot          = math.clamp(currentLook:Dot(targetLook), -1, 1)
    local angleDist    = math.acos(dot)
    local angularSpeed = flickSpeed * 0.5 * math.pi
    local totalTime    = math.max(angleDist / angularSpeed, 0.016)
    local steps        = 8
    local waitTime     = totalTime / steps

    for i = 1, steps do
        cam.CFrame = oldCFrame:Lerp(targetCFrame, i / steps)
        task.wait(waitTime)
    end
    autoShoot(murderer)
    for i = 1, steps do
        cam.CFrame = targetCFrame:Lerp(oldCFrame, i / steps)
        task.wait(waitTime * 0.7)
    end
    cam.CFrame = oldCFrame
end

local function getBBSize()
    return __UD2(0, bigButtonSize, 0, bigButtonSize * 0.375)
end

flick_section:AddToggle("Enable Flick", function(state)
    flickEnabled = state
    shared.Notify(state and "Flick enabled" or "Flick disabled", state and 1 or 3)
end)

flick_section:AddSlider("Flick Speed (ms)", 1, 50, 1, function(value)
    flickSpeed = value
end)

flick_section:AddKeybind("Flick Key", "F", function()
    flickToMurderer()
end)

flick_section:AddToggle("Auto Shoot on Flick", function(state)
    autoShootEnabled = state
    shared.Notify(state and "Auto Shoot ON" or "Auto Shoot OFF", state and 1 or 3)
end)

flick_section:AddToggle("Show Big Button", function(state)
    if state then
        if not bigButtonCreated then
            AddBigButton("flick_big", "FLICK", flickToMurderer, getBBSize)
            bigButtonCreated = true
        else
            SetBigButtonVisible("flick_big", true)
        end
        local btn = BBSystem.Buttons["flick_big"]
        if btn then btn.Size = getBBSize() end
    else
        SetBigButtonVisible("flick_big", false)
    end
end)

flick_section:AddSlider("Big Button Size", 100, 400, 200, function(value)
    bigButtonSize = value
    local btn = BBSystem.Buttons["flick_big"]
    if btn and btn.Visible then
        btn.Size = getBBSize()
    end
end)

flick_section:AddButton("Reset Big Button Position", function()
    savedPositions.big = nil
    savePositions(savedPositions)
    local btn = BBSystem.Buttons["flick_big"]
    if btn then
        local dp = DEFAULT_POSITIONS.big
        btn.Position = __UD2(dp.xs, dp.xo, dp.ys, dp.yo)
    end
    shared.Notify("Big button position reset", 2)
end)

flick_section:AddToggle("Show Bind Button", function(state)
    if state then
        if not bindButtonCreated then
            BindableButtons.AddBButton("flick_bind", "FLICK", flickToMurderer)
            bindButtonCreated = true
        else
            SetBindButtonVisible("flick_bind", true)
        end
        local btn = BindableButtons.Buttons["flick_bind"]
        if btn then
            local screen = workspace.CurrentCamera.ViewportSize
            btn.Size = __UD2(bindButtonSize * (screen.Y / screen.X), 0, bindButtonSize, 0)
        end
    else
        SetBindButtonVisible("flick_bind", false)
    end
end)

flick_section:AddSlider("Bind Button Size", 5, 25, 11, function(value)
    bindButtonSize = value / 100
    local btn = BindableButtons.Buttons["flick_bind"]
    if btn and btn.Visible then
        local screen = workspace.CurrentCamera.ViewportSize
        btn.Size = __UD2(bindButtonSize * (screen.Y / screen.X), 0, bindButtonSize, 0)
    end
end)

flick_section:AddButton("Reset Bind Button Position", function()
    savedPositions.bind = nil
    savePositions(savedPositions)
    local btn = BindableButtons.Buttons["flick_bind"]
    if btn then
        local dp = DEFAULT_POSITIONS.bind
        btn.Position = __UD2(dp.xs, dp.xo, dp.ys, dp.yo)
    end
    shared.Notify("Bind button position reset", 2)
end)
