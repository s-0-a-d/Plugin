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

local on, off
local god = false
local hc

on = function()
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

off = function()
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

local function go(list)
    vip()
    for _,pos in ipairs(list) do
        tweenTo(pos)
    end
end

local function findBase()
    local name = lp.Name
    local bases = w:FindFirstChild("Bases")
    if not bases then return nil end

    for _,b in ipairs(bases:GetChildren()) do
        if not b:IsA("Model") and not b:IsA("Folder") then
            continue
        end

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

sec:AddButton("Teleport To Final Area + Unlock VIP Walls", function()
    go({
        Vector3.new(153, 4, -137),
        Vector3.new(256, 4, -139),
        Vector3.new(2465, 4, -139),
    })
end)

sec:AddButton("Teleport Back To Base", function()
    tweenTo(Vector3.new(2465, 4, -139))
    tweenTo(Vector3.new(256, 4, -139))
    tweenTo(Vector3.new(153, 4, -137))

    local b = findBase()
    if not b then return end

    local cf = b:GetPivot()
    tweenTo(cf.Position + Vector3.new(0, 5, 0))
end)
