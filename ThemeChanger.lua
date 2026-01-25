local shared = odh_shared_plugins

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local section = shared.AddSection("THEME CHANGER")

local function brightness(c)
    return math.clamp(math.max(c.R, c.G, c.B) ^ 0.5, 0.55, 1)
end

local THEMES = {
    Red = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b, b * 0.08, b * 0.08)
        end,
        isThemeColor = function(c)
            return c.R >= 0.55
                and math.abs(c.G - c.R * 0.08) <= 0.001
                and math.abs(c.B - c.R * 0.08) <= 0.001
        end
    },
    Blue = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b * 0.08, b * 0.08, b)
        end,
        isThemeColor = function(c)
            return c.B >= 0.55
                and math.abs(c.R - c.B * 0.08) <= 0.001
                and math.abs(c.G - c.B * 0.08) <= 0.001
        end
    },
    Green = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b * 0.08, b, b * 0.08)
        end,
        isThemeColor = function(c)
            return c.G >= 0.55
                and math.abs(c.R - c.G * 0.08) <= 0.001
                and math.abs(c.B - c.G * 0.08) <= 0.001
        end
    },
    Purple = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b, b * 0.12, b)
        end,
        isThemeColor = function(c)
            return c.R >= 0.55
                and math.abs(c.G - c.R * 0.12) <= 0.001
                and math.abs(c.B - c.R) <= 0.001
        end
    },
    Cyan = {
        toTheme = function(c)
            local b = brightness(c)
            return Color3.new(b * 0.1, b, b)
        end,
        isThemeColor = function(c)
            return c.G >= 0.55 and c.B >= 0.55
                and math.abs(c.R - c.G * 0.1) <= 0.001
        end
    }
}

local currentTheme = "Red"
local themeEnabled = false
local applyingTheme = false

local baseColor = setmetatable({}, { __mode = "k" })
local baseGradient = setmetatable({}, { __mode = "k" })

local queue = {}
local scheduled = false

local function enqueue(obj)
    queue[obj] = true
    if scheduled then return end
    scheduled = true
    task.defer(function()
        scheduled = false
        if not themeEnabled then
            table.clear(queue)
            return
        end
        local theme = THEMES[currentTheme]
        applyingTheme = true
        for o in pairs(queue) do
            if o:IsA("GuiObject") then
                local base = baseColor[o]
                if base then
                    o.BackgroundColor3 = theme.toTheme(base)
                end
            elseif o:IsA("UIGradient") then
                local src = baseGradient[o]
                if src then
                    local keys = {}
                    for _, kp in ipairs(src.Keypoints) do
                        table.insert(keys, ColorSequenceKeypoint.new(
                            kp.Time,
                            theme.toTheme(kp.Value)
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
    ["@ripple.elia"] = true,
    ["@notificationcontainer.elia"] = true,
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
            if themeEnabled then enqueue(obj) end
        end)
        if themeEnabled then enqueue(obj) end

    elseif obj:IsA("UIGradient") then
        if not baseGradient[obj] then
            baseGradient[obj] = obj.Color
        end
        obj:GetPropertyChangedSignal("Color"):Connect(function()
            if applyingTheme then return end
            baseGradient[obj] = obj.Color
            if themeEnabled then enqueue(obj) end
        end)
        if themeEnabled then enqueue(obj) end
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
        if themeEnabled then enqueue(d) end
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
    currentTheme = v
end)

section:AddButton("Apply Theme", function()
    themeEnabled = true
    for o in pairs(baseColor) do enqueue(o) end
    for g in pairs(baseGradient) do enqueue(g) end
end)

section:AddButton("Apply Default Theme", function()
    themeEnabled = false
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
