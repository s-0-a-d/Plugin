local shared = odh_shared_plugins

local __INSERT = table.insert
local __FLOOR = math.floor
local __PCLR = Color3.new
local __RGB = Color3.fromRGB
local __UD2 = UDim2.new
local __UD = UDim.new
local __V2 = Vector2.new

local function getfserv(s)
    local success, service = pcall(function() return game:GetService(s) end)
    if success and service then return service end
    success, service = pcall(function() return game:FindService(s) end)
    if success and service then return service end
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

local DEFAULT_BIG_POS  = { xs = 0.5, xo = 0, ys = 0.5, yo = 0 }
local DEFAULT_BIND_POS = { xs = 0.1, xo = 0, ys = 0.9, yo = 0 }

local bigButtonInvisible  = false
local bindButtonInvisible = false

local bigButtonSize   = 200
local bindButtonSize  = 0.11

local function safecallback(callback)
    if not callback then return end
    local success, err = xpcall(callback, function(e) return debug.traceback(e) end)
    if not success then
        warn("[ERROR] " .. tostring(err))
    end
end

local BBSystem = {Buttons = {}, Connections = {}}

local function BB_GetStorage()
    local storageParent
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui and typeof(hui) == "Instance" then
        storageParent = hui
    else
        local ok2, cg = pcall(function() return getfserv("CoreGui") end)
        if ok2 and cg and typeof(cg) == "Instance" then
            storageParent = cg
        else
            storageParent = __PLRS.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    local sg = storageParent:FindFirstChild("@BBStorage")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "@BBStorage"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.ScreenInsets = Enum.ScreenInsets.None end)
        sg.Parent = storageParent
    end
    return sg
end

local __BB_GRAD_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    __PCLR(0.0784314, 0.0784314, 0.0784314)),
    ColorSequenceKeypoint.new(0.75, __PCLR(0.0784314, 0.0784314, 0.54902)),
    ColorSequenceKeypoint.new(1,    __PCLR(0.470588,  0.156863,  0.470588))
})

local function BB_MakeDraggable(gui, func, ripple, sound)
    local dragging, dragInput, dragStart, startPos
    local hasMoved = false
    local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            hasMoved  = false
            dragStart = input.Position
            startPos  = gui.Position

            local w = bigButtonSize
            local h = w * (75/200)
            __TS:Create(gui, tInfo, {Size = __UD2(0, w * 1.1, 0, h * 1.1), TextSize = 24 * 1.1}):Play()

            if not bigButtonInvisible then
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
            end

            local releaseConn
            releaseConn = __UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    local w2 = bigButtonSize
                    local h2 = w2 * (75/200)
                    __TS:Create(gui, tInfo, {Size = __UD2(0, w2, 0, h2), TextSize = 24}):Play()
                    if not hasMoved then task.spawn(safecallback, func) end
                    savedPositions.big = {
                        xs = gui.Position.X.Scale, xo = gui.Position.X.Offset,
                        ys = gui.Position.Y.Scale, yo = gui.Position.Y.Offset
                    }
                    savePositions(savedPositions)
                    releaseConn:Disconnect()
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

local function AddBigButton(id, text, func)
    if BBSystem.Buttons[id] then return end
    local storage = BB_GetStorage()
    if not storage then return end

    local w = bigButtonSize
    local h = w * (75/200)

    local bb = Instance.new("TextButton")
    bb.Name = id
    bb.Size = __UD2(0, w, 0, h)
    local sp = savedPositions.big or DEFAULT_BIG_POS
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

    BB_MakeDraggable(bb, func, ripple, sound)

    BBSystem.Connections[id] = __RS.RenderStepped:Connect(function()
        gradient.Rotation = (gradient.Rotation + 1) % 360
    end)

    BBSystem.Buttons[id] = bb

    if bigButtonInvisible then
        bb.BackgroundTransparency = 1
        bb.TextTransparency = 1
        local s = bb:FindFirstChildOfClass("UIStroke")
        if s then s.Transparency = 1 end
    end
end

local function SetBigButtonInvisible(hidden)
    local btn = BBSystem.Buttons["flick_big"]
    if not btn then return end
    btn.BackgroundTransparency = hidden and 1 or 0.9
    btn.TextTransparency       = hidden and 1 or 0
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Transparency = hidden and 1 or 0 end
end

local function SetBigButtonSize(px)
    bigButtonSize = px
    local btn = BBSystem.Buttons["flick_big"]
    if not btn then return end
    local h = px * (75/200)
    btn.Size = __UD2(0, px, 0, h)
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
        elseif type(t) == "table" and type(t.Destroy) == "function" then t:Destroy()
        end
        return t
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
        elseif type(t) == "table" and type(t.Destroy) == "function" then t:Destroy()
        end
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

local __TOGGLED_COLOR = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    __PCLR(0.0784314, 0.0784314, 0.0784314)),
    ColorSequenceKeypoint.new(0.75, __PCLR(0.0784314, 0.0784314, 0.54902)),
    ColorSequenceKeypoint.new(1,    __PCLR(0.470588,  0.156863,  0.470588))
})

local function Bind_GetStorage()
    local storageParent
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui and typeof(hui) == "Instance" then
        storageParent = hui
    else
        local ok2, cg = pcall(function() return getfserv("CoreGui") end)
        if ok2 and cg and typeof(cg) == "Instance" then
            storageParent = cg
        else
            storageParent = __PLRS.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    local sg = storageParent:FindFirstChild("@bindstorage")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "@bindstorage"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.ScreenInsets = Enum.ScreenInsets.None end)
        sg.Parent = storageParent
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

            if not bindButtonInvisible then
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
            end

            local releaseConn
            releaseConn = __UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    if not hasMoved then clickFunc() end
                    savedPositions.bind = {
                        xs = gui.Position.X.Scale, xo = gui.Position.X.Offset,
                        ys = gui.Position.Y.Scale, yo = gui.Position.Y.Offset
                    }
                    savePositions(savedPositions)
                    releaseConn:Disconnect()
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

local function AddBindButton(id, text, onFunc, offFunc)
    if BindableButtons.Buttons[id] then return BindableButtons.Buttons[id]:FindFirstChild("BindValue") end

    local buttonMaid = Maid.new()
    local camera = workspace.CurrentCamera
    local screen = camera.ViewportSize

    local buttonSizeY = bindButtonSize
    local widthScale  = buttonSizeY * (screen.Y / screen.X)
    local sp = savedPositions.bind or DEFAULT_BIND_POS

    local ImageButton = Instance.new("ImageButton")
    ImageButton.Name = id
    ImageButton.Size = __UD2(widthScale, 0, buttonSizeY, 0)
    ImageButton.Position = __UD2(sp.xs, sp.xo, sp.ys, sp.yo)
    ImageButton.AnchorPoint = __V2(0.5, 0.5)
    ImageButton.Image = __SHAPES[0]
    ImageButton.BackgroundTransparency = 1
    ImageButton.BorderSizePixel = 0
    ImageButton.ClipsDescendants = false
    ImageButton.AutoButtonColor = false
    ImageButton.Parent = Bind_GetStorage()
    buttonMaid:GiveTask(ImageButton)

    local BindValue = Instance.new("BoolValue", ImageButton)
    BindValue.Name = "BindValue"

    local TextLabel = Instance.new("TextLabel", ImageButton)
    TextLabel.Name = "@Text"
    TextLabel.Size              = __UD2(0.8, 0, 0.8, 0)
    TextLabel.Position          = __UD2(0.5, 0, 0.5, 0)
    TextLabel.AnchorPoint       = __V2(0.5, 0.5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font              = Enum.Font.Jura
    TextLabel.Text              = text
    TextLabel.TextColor3        = __PCLR(1, 1, 1)
    TextLabel.TextSize          = 10
    TextLabel.TextWrapped       = true
    TextLabel.ZIndex            = 3

    local Aspect = Instance.new("UIAspectRatioConstraint", ImageButton)
    Aspect.AspectRatio = 1
    Aspect.AspectType  = Enum.AspectType.ScaleWithParentSize

    local Stroke = Instance.new("UIGradient", ImageButton)
    Stroke.Name  = "@Stroke"
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

    local debounce = false
    local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

    local function onClick()
        if debounce then return end
        debounce = true

        BindValue.Value = not BindValue.Value
        Stroke.Color = BindValue.Value and __TOGGLED_COLOR or __NORMAL_COLOR

        if BindValue.Value then
            task.spawn(safecallback, onFunc)
        else
            task.spawn(safecallback, offFunc)
        end

        if not bindButtonInvisible then
            task.spawn(function()
                local fOut = __TS:Create(ImageButton, tInfo, {ImageTransparency = 1})
                fOut:Play()
                fOut.Completed:Wait()
                local fIn = __TS:Create(ImageButton, tInfo, {ImageTransparency = 0})
                fIn:Play()
                fIn.Completed:Wait()
                debounce = false
            end)
        else
            debounce = false
        end
    end

    Bind_MakeDraggable(ImageButton, buttonMaid, ripple, sound, onClick)
    buttonMaid:GiveTask(__RS.RenderStepped:Connect(function()
        Stroke.Rotation = (Stroke.Rotation + 1) % 360
    end))

    if bindButtonInvisible then
        ImageButton.ImageTransparency = 1
        local lbl = ImageButton:FindFirstChild("@Text")
        if lbl then lbl.TextTransparency = 1 end
    end

    BindableButtons.Buttons[id] = ImageButton
    BindableButtons.Maids[id]   = buttonMaid
    BindableButtons.Count       = BindableButtons.Count + 1
    return BindValue
end

local function SetBindButtonInvisible(hidden)
    local btn = BindableButtons.Buttons["flick_bind"]
    if not btn then return end
    btn.ImageTransparency = hidden and 1 or 0
    local lbl = btn:FindFirstChild("@Text")
    if lbl then lbl.TextTransparency = hidden and 1 or 0 end
end

local function SetBindButtonSize(scale)
    bindButtonSize = scale
    local btn = BindableButtons.Buttons["flick_bind"]
    if not btn then return end
    local camera = workspace.CurrentCamera
    local screen = camera.ViewportSize
    local widthScale = scale * (screen.Y / screen.X)
    btn.Size = __UD2(widthScale, 0, scale, 0)
end

local function DeleteBindButton(id)
    if BindableButtons.Maids[id] then
        BindableButtons.Maids[id]:Destroy()
        BindableButtons.Maids[id]   = nil
        BindableButtons.Buttons[id] = nil
    end
end

local flick_section = shared.AddSection("Flick to Murderer")

local flickEnabled     = false
local flickSpeed       = 1
local autoShootEnabled = false
local flickMode        = "Normal"

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

local function flickToMurdererNormal()
    if not flickEnabled then return end
    local murderer = findMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then return end
    local cam  = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local targetPos    = murderer.Character.HumanoidRootPart.Position
    local oldCFrame    = cam.CFrame
    local targetCFrame = CFrame.lookAt(oldCFrame.Position, targetPos)
    local dot          = math.clamp(oldCFrame.LookVector:Dot((targetPos - oldCFrame.Position).Unit), -1, 1)
    local angleDist    = math.acos(dot)
    local angularSpeed = flickSpeed * 0.4 * math.pi
    local totalTime    = math.max(angleDist / angularSpeed, 0.016)
    local steps        = 8
    local waitTime     = totalTime / steps

    for i = 1, steps do
        cam.CFrame = oldCFrame:Lerp(targetCFrame, i / steps)
        task.wait(waitTime)
    end
    autoShoot()
    for i = 1, steps do
        cam.CFrame = targetCFrame:Lerp(oldCFrame, i / steps)
        task.wait(waitTime * 0.7)
    end
    cam.CFrame = oldCFrame
end

local function flickToMurdererInstant()
    if not flickEnabled then return end
    local murderer = findMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then return end
    local cam  = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not char then return end
    if not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end

    local targetPos    = murderer.Character.HumanoidRootPart.Position
    local oldCFrame    = cam.CFrame
    local targetCFrame = CFrame.lookAt(oldCFrame.Position, targetPos)

    task.wait(0.05)
    cam.CFrame = targetCFrame
    autoShoot()
    task.wait(0.15)
    cam.CFrame = oldCFrame
end

local function flickToMurderer()
    if flickMode == "Normal" then
        flickToMurdererNormal()
    else
        flickToMurdererInstant()
    end
end

flick_section:AddToggle("Enable Flick", function(state)
    flickEnabled = state
end)

flick_section:AddSlider("Flick Speed", 1, 100, 1, function(value)
    flickSpeed = value
end)

flick_section:AddKeybind("Flick Key", "F", function()
    task.spawn(flickToMurderer)
end)

flick_section:AddDropdown("Flick Mode", {"Normal", "Instant"}, function(selected)
    flickMode = selected
end)

flick_section:AddToggle("Show Big Button", function(state)
    if state then
        if not bigButtonCreated then
            AddBigButton("flick_big", "FLICK", function() task.spawn(flickToMurderer) end)
            bigButtonCreated = true
        else
            local btn = BBSystem.Buttons["flick_big"]
            if btn then btn.Visible = true end
        end
    else
        local btn = BBSystem.Buttons["flick_big"]
        if btn then btn.Visible = false end
    end
end)

flick_section:AddToggle("Big Button Invisible", function(state)
    bigButtonInvisible = state
    SetBigButtonInvisible(state)
end)

flick_section:AddSlider("Big Button Size", 80, 400, 200, function(value)
    SetBigButtonSize(value)
end)

flick_section:AddButton("Reset Big Button Position", function()
    savedPositions.big = nil
    savePositions(savedPositions)
    local btn = BBSystem.Buttons["flick_big"]
    if btn then
        btn.Position = __UD2(DEFAULT_BIG_POS.xs, DEFAULT_BIG_POS.xo, DEFAULT_BIG_POS.ys, DEFAULT_BIG_POS.yo)
    end
end)

flick_section:AddToggle("Show Bind Button", function(state)
    if state then
        if not bindButtonCreated then
            AddBindButton("flick_bind", "FLICK",
                function() task.spawn(flickToMurderer) end,
                function() task.spawn(flickToMurderer) end
            )
            bindButtonCreated = true
        else
            local btn = BindableButtons.Buttons["flick_bind"]
            if btn then btn.Visible = true end
        end
    else
        local btn = BindableButtons.Buttons["flick_bind"]
        if btn then btn.Visible = false end
    end
end)

flick_section:AddToggle("Bind Button Invisible", function(state)
    bindButtonInvisible = state
    SetBindButtonInvisible(state)
end)

flick_section:AddSlider("Bind Button Size", 5, 25, 11, function(value)
    SetBindButtonSize(value / 100)
end)

flick_section:AddButton("Reset Bind Button Position", function()
    savedPositions.bind = nil
    savePositions(savedPositions)
    local btn = BindableButtons.Buttons["flick_bind"]
    if btn then
        btn.Position = __UD2(DEFAULT_BIND_POS.xs, DEFAULT_BIND_POS.xo, DEFAULT_BIND_POS.ys, DEFAULT_BIND_POS.yo)
    end
end)
