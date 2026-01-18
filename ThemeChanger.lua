local shared = odh_shared_plugins

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local section = shared.AddSection("THEME CHANGER")

local THEMES = {}

THEMES["Red"] = {
    toTheme = function(c)
        local b = math.max(c.R, c.G, c.B)
        b = math.clamp(b ^ 0.5, 0.55, 1)
        return Color3.new(b, b * 0.08, b * 0.08)
    end,
    isThemeColor = function(c)
        return c.R >= 0.55
            and math.abs(c.G - c.R * 0.08) <= 0.001
            and math.abs(c.B - c.R * 0.08) <= 0.001
    end,
}

THEMES["Blue"] = {
    toTheme = function(c)
        local b = math.max(c.R, c.G, c.B)
        b = math.clamp(b ^ 0.5, 0.55, 1)
        return Color3.new(b * 0.08, b * 0.08, b)
    end,
    isThemeColor = function(c)
        return c.B >= 0.55
            and math.abs(c.R - c.B * 0.08) <= 0.001
            and math.abs(c.G - c.B * 0.08) <= 0.001
    end,
}

THEMES["Green"] = {
    toTheme = function(c)
        local b = math.max(c.R, c.G, c.B)
        b = math.clamp(b ^ 0.5, 0.55, 1)
        return Color3.new(b * 0.08, b, b * 0.08)
    end,
    isThemeColor = function(c)
        return c.G >= 0.55
            and math.abs(c.R - c.G * 0.08) <= 0.001
            and math.abs(c.B - c.G * 0.08) <= 0.001
    end,
}

THEMES["Purple"] = {
    toTheme = function(c)
        local b = math.max(c.R, c.G, c.B)
        b = math.clamp(b ^ 0.5, 0.55, 1)
        return Color3.new(b, b * 0.12, b)
    end,
    isThemeColor = function(c)
        return c.R >= 0.55
            and math.abs(c.G - c.R * 0.12) <= 0.001
            and math.abs(c.B - c.R) <= 0.001
    end,
}

THEMES["Cyan"] = {
    toTheme = function(c)
        local b = math.max(c.R, c.G, c.B)
        b = math.clamp(b ^ 0.5, 0.55, 1)
        return Color3.new(b * 0.1, b, b)
    end,
    isThemeColor = function(c)
        return c.G >= 0.55 and c.B >= 0.55
            and math.abs(c.R - c.G * 0.1) <= 0.001
    end,
}

local currentTheme = "Red"
local themeEnabled = false

local originalColor = setmetatable({}, { __mode = "k" })
local originalGradient = setmetatable({}, { __mode = "k" })

local queue = {}
local scheduled = false

local function processQueue()
    scheduled = false
    if not themeEnabled then
        table.clear(queue)
        return
    end

    local theme = THEMES[currentTheme]
    if not theme then
        table.clear(queue)
        return
    end

    for obj in pairs(queue) do
        if obj:IsA("GuiObject") then
            local base = obj.BackgroundColor3
            if not theme.isThemeColor(base) then
                obj.BackgroundColor3 = theme.toTheme(base)
            end

        elseif obj:IsA("UIGradient") then
            local seq = obj.Color
            local themed = true
            for _, kp in ipairs(seq.Keypoints) do
                if not theme.isThemeColor(kp.Value) then
                    themed = false
                    break
                end
            end
            if not themed then
                local keys = {}
                for _, kp in ipairs(seq.Keypoints) do
                    table.insert(keys, ColorSequenceKeypoint.new(
                        kp.Time,
                        theme.toTheme(kp.Value)
                    ))
                end
                obj.Color = ColorSequence.new(keys)
            end
        end
    end

    table.clear(queue)
end

local function enqueue(obj)
    queue[obj] = true
    if not scheduled then
        scheduled = true
        task.defer(processQueue)
    end
end

local VALID_ROOT_NAMES = {
    ["\009\001"] = true,
    ["Maximize"] = true,
    ["NotificationContainer"] = true,
    ["VFX"] = true,
    ["привязываемая кнопка"] = true,
    ["@bubbles.elia"] = true,
    ["застрелить убийцу"] = true,
}

local SELF_RECOLOR = {
    ["\009\001"] = true,
    ["NotificationContainer"] = true,
    ["VFX"] = true,
    ["привязываемая кнопка"] = true,
    ["@bubbles.elia"] = true,
    ["застрелить убийцу"] = true,

    ["Maximize"] = false,
}

local function watch(obj)
    if obj:IsA("GuiObject") then
        if not originalColor[obj] then
            originalColor[obj] = obj.BackgroundColor3
        end
        obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            if themeEnabled then
                enqueue(obj)
            end
        end)

    elseif obj:IsA("UIGradient") then
        if not originalGradient[obj] then
            originalGradient[obj] = obj.Color
        end
        obj:GetPropertyChangedSignal("Color"):Connect(function()
            if themeEnabled then
                enqueue(obj)
            end
        end)
    end
end

local function processRoot(root)
    if SELF_RECOLOR[root.Name] then
        watch(root)
    end

    for _, d in ipairs(root:GetDescendants()) do
        watch(d)
    end

    root.DescendantAdded:Connect(watch)
end

local function scan(service)
    for _, obj in ipairs(service:GetDescendants()) do
        if obj.Name == "" then
            for _, child in ipairs(obj:GetChildren()) do
                if VALID_ROOT_NAMES[child.Name] then
                    processRoot(child)
                end
            end
        elseif VALID_ROOT_NAMES[obj.Name] then
            processRoot(obj)
        end
    end
end

scan(game.CoreGui)
scan(LP:WaitForChild("PlayerGui"))

local themeNames = {}
for name in pairs(THEMES) do
    table.insert(themeNames, name)
end

section:AddDropdown("Theme", themeNames, function(selected)
    currentTheme = selected
end)

section:AddButton("Apply Theme", function()
    themeEnabled = false
    for obj, c in pairs(originalColor) do
        if obj and obj.Parent then
            obj.BackgroundColor3 = c
        end
    end
    for g, seq in pairs(originalGradient) do
        if g and g.Parent then
            g.Color = seq
        end
    end

    themeEnabled = true
    for obj in pairs(originalColor) do
        enqueue(obj)
    end
    for obj in pairs(originalGradient) do
        enqueue(obj)
    end
end)

section:AddButton("Apply Default Theme", function()
    themeEnabled = false
    for obj, c in pairs(originalColor) do
        if obj and obj.Parent then
            obj.BackgroundColor3 = c
        end
    end
    for g, seq in pairs(originalGradient) do
        if g and g.Parent then
            g.Color = seq
        end
    end
end)
