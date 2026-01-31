local s = odh_shared_plugins
local p = game:GetService("Players")
local t = game:GetService("TweenService")
local w = game:GetService("Workspace")

if s.game_name ~= "Escape Tsunami For Brainrots" then
    return
end

local lp = p.LocalPlayer
local sec = s.AddSection("TSUNAMI")

local function ch()
    local c = lp.Character or lp.CharacterAdded:Wait()
    return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

local function vip()
    local v = w:FindFirstChild("VIPWalls")
    if not v then return end
    for _,x in ipairs(v:GetDescendants()) do
        if x:IsA("BasePart") then
            x.CanCollide = false
        elseif x:IsA("TouchTransmitter") then
            x:Destroy()
        end
    end
end

local god = false
local hc

local on = function()
    local _,h = ch()
    h.MaxHealth = math.huge
    h.Health = math.huge
    h.BreakJointsOnDeath = false

    if hc then hc:Disconnect() end
    hc = h.HealthChanged:Connect(function()
        if god and h.Health < h.MaxHealth then
            h.Health = h.MaxHealth
        end
    end)
end

local off = function()
    if hc then
        hc:Disconnect()
        hc = nil
    end
end

sec:AddToggle(
    'God Mode <font color="rgb(255,0,0)">(1 Extra Life)</font>',
    function(v)
        god = v
        if v then on() else off() end
    end
)

lp.CharacterAdded:Connect(function()
    task.wait(1)
    if god then on() end
end)

local spd = 2000
local busy = false

local function tweenTo(pos)
    local _,_,r = ch()
    local d = (pos - r.Position).Magnitude
    local tw = t:Create(
        r,
        TweenInfo.new(d / spd, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos, pos + r.CFrame.LookVector)}
    )
    tw:Play()
    tw.Completed:Wait()
end

local function findBase()
    local name = lp.Name
    local bases = w:FindFirstChild("Bases")
    if not bases then return nil end

    for _,b in ipairs(bases:GetChildren()) do
        if not b:IsA("Model") and not b:IsA("Folder") then continue end

        local gui = b:FindFirstChild("TitleGui", true)
        if not gui then continue end

        local f = gui:FindFirstChildWhichIsA("Frame")
        if not f then continue end

        local lbl = f:FindFirstChild("PlayerName")
        if not lbl then continue end
        if not lbl:IsA("TextLabel") and not lbl:IsA("TextButton") then continue end

        if lbl.Text == name then
            return b
        end
    end

    return nil
end

local areas = {
    Secret     = Vector3.new(2465, 4, -139),
    Cosmic     = Vector3.new(1990, 4, -139),
    Mythical   = Vector3.new(1365, 4, -139),
    Legendary  = Vector3.new(953, 4, -139),
    Epic       = Vector3.new(679, 4, -139),
    Rare       = Vector3.new(500, 4, -139),
    Uncommon   = Vector3.new(360, 4, -139),
    Common     = Vector3.new(257, 4, -139),
}

local areaNames = {
    "Secret",
    "Cosmic",
    "Mythical",
    "Legendary",
    "Epic",
    "Rare",
    "Uncommon",
    "Common",
}

local current = "Secret"

sec:AddDropdown("Area", areaNames, function(v)
    current = v
end)

local function nearestArea(pos)
    local best, dist
    for _,v in pairs(areas) do
        local d = (v - pos).Magnitude
        if not dist or d < dist then
            dist = d
            best = v
        end
    end
    return best
end

local function teleportBack()
    if busy then return end
    busy = true

    local _,_,r = ch()
    local start = nearestArea(r.Position)
    if start then
        tweenTo(start)
    end

    tweenTo(Vector3.new(153, 4, -137))

    local b = findBase()
    if b then
        local cf = b:GetPivot()
        tweenTo(cf.Position + Vector3.new(0, 5, 0))
    end

    busy = false
end

sec:AddButton("Teleport To Area + Unlock VIP Walls", function()
    if busy then return end
    busy = true
    vip()
    tweenTo(Vector3.new(153, 4, -137))
    tweenTo(areas[current])
    busy = false
end)

sec:AddButton("Teleport Back To Base", teleportBack)
