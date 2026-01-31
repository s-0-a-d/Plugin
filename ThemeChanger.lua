local shared = odh_shared_plugins

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local section = shared.AddSection("THEME CHANGER")

local function brightness(c)
    return math.clamp(math.max(c.R, c.G, c.B) ^ 0.5, 0.55, 1)
end

local function isBlackOrWhite(c)
    local maxv = math.max(c.R, c.G, c.B)
    local minv = math.min(c.R, c.G, c.B)
    if maxv <= 0.05 then return true end
    if minv >= 0.95 then return true end
    if math.abs(c.R - c.G) < 0.01
        and math.abs(c.G - c.B) < 0.01
        and math.abs(c.R - c.B) < 0.01 then
        return true
    end
    return false
end

local THEMES = {
    Red = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b, b * 0.08, b * 0.08)
        end
    },
    Blue = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b * 0.08, b * 0.08, b)
        end
    },
    Green = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b * 0.08, b, b * 0.08)
        end
    },
    Purple = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b, b * 0.12, b)
        end
    },
    Cyan = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b * 0.1, b, b)
        end
    }
}

local selectedTheme = "Red"
local appliedTheme = nil
local themeEnabled = false
local applyingTheme = false

local baseColor = setmetatable({}, { __mode = "k" })
local baseGradient = setmetatable({}, { __mode = "k" })

local queue = {}
local scheduled = false

local function enqueue(obj)
    if not themeEnabled or not appliedTheme then return end
    queue[obj] = true
    if scheduled then return end
    scheduled = true
    task.defer(function()
        scheduled = false
        local theme = THEMES[appliedTheme]
        if not theme then
            table.clear(queue)
            return
        end
        applyingTheme = true
        for o in pairs(queue) do
            if o:IsA("GuiObject") then
                local base = baseColor[o]
                if base and not isBlackOrWhite(base) then
                    o.BackgroundColor3 = theme.toTheme(base)
                end
            elseif o:IsA("UIGradient") then
                local src = baseGradient[o]
                if src then
                    local keys = {}
                    for _, kp in ipairs(src.Keypoints) do
                        table.insert(keys, ColorSequenceKeypoint.new(
                            kp.Time,
                            isBlackOrWhite(kp.Value) and kp.Value or theme.toTheme(kp.Value)
                        ))
                    end
                    o.Color = ColorSequence.new(keys)
                end
            end
        end
        applyingTheme = false
        table.clear(queue)
    end)
end

local VALID_ROOT = {
    ["\009\001"] = true,
    ["Maximize"] = true,
    ["@notificationcontainer.elia"] = true,
    ["@ripple.elia"] = true,
    ["привязываемая кнопка"] = true,
    ["@bubbles.elia"] = true,
    ["застрелить убийцу"] = true,
    ["информация о сервере"] = true,
}

local SELF = {
    ["Maximize"] = false
}

local function watch(obj)
    if obj:IsA("GuiObject") then
        if not baseColor[obj] then
            baseColor[obj] = obj.BackgroundColor3
        end
        obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            if applyingTheme then return end
            baseColor[obj] = obj.BackgroundColor3
            enqueue(obj)
        end)

    elseif obj:IsA("UIGradient") then
        if not baseGradient[obj] then
            baseGradient[obj] = obj.Color
        end
        obj:GetPropertyChangedSignal("Color"):Connect(function()
            if applyingTheme then return end
            baseGradient[obj] = obj.Color
            enqueue(obj)
        end)
    end
end

local function processRoot(root)
    if SELF[root.Name] ~= false then
        watch(root)
    end
    for _, d in ipairs(root:GetDescendants()) do
        watch(d)
    end
    root.DescendantAdded:Connect(function(d)
        watch(d)
        enqueue(d)
    end)
end

local function scan(service)
    for _, obj in ipairs(service:GetDescendants()) do
        if VALID_ROOT[obj.Name] then
            processRoot(obj)
        end
    end
end

scan(game.CoreGui)
scan(LP:WaitForChild("PlayerGui"))

local themeNames = {}
for k in pairs(THEMES) do
    table.insert(themeNames, k)
end

section:AddDropdown("Theme", themeNames, function(v)
    selectedTheme = v
end)

section:AddButton("Apply Theme", function()
    appliedTheme = selectedTheme
    themeEnabled = true
    for o in pairs(baseColor) do enqueue(o) end
    for g in pairs(baseGradient) do enqueue(g) end
end)

section:AddButton("Apply Default Theme", function()
    themeEnabled = false
    appliedTheme = nil
    applyingTheme = true
    for o, c in pairs(baseColor) do
        if o and o.Parent then
            o.BackgroundColor3 = c
        end
    end
    for g, seq in pairs(baseGradient) do
        if g and g.Parent then
            g.Color = seq
        end
    end
    applyingTheme = false
end)
