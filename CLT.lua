local shared = odh_shared_plugins

local section = shared.AddSection("Chat Language Translator")

local isOutgoingTranslatorActive = false
local isIncomingTranslatorActive = false
local yourLanguage = "en"
local targetLanguage = nil

local languageCategories = {
    {
        Name = "Global & Constructed",
        Languages = {
            ["English (USA/UK)"] = "en",
            ["Esperanto (Global)"] = "eo",
            ["Latin (Global)"] = "la"
        }
    },
    {
        Name = "African Languages",
        Languages = {
            ["Afrikaans (South Africa)"] = "af",
            ["Amharic (Ethiopia)"] = "am",
            ["Hausa (Nigeria)"] = "ha",
            ["Igbo (Nigeria)"] = "ig",
            ["Malagasy (Madagascar)"] = "mg",
            ["Sesotho (Lesotho)"] = "st",
            ["Shona (Zimbabwe)"] = "sn",
            ["Somali (Somalia)"] = "so",
            ["Swahili (Tanzania/Kenya)"] = "sw",
            ["Xhosa (South Africa)"] = "xh",
            ["Yoruba (Nigeria)"] = "yo",
            ["Zulu (South Africa)"] = "zu"
        }
    },
    {
        Name = "Asian Languages",
        Languages = {
            ["Armenian (Armenia)"] = "hy",
            ["Azerbaijani (Azerbaijan)"] = "az",
            ["Bengali (Bangladesh)"] = "bn",
            ["Burmese (Myanmar)"] = "my",
            ["Chinese (China)"] = "zh-cn",
            ["Georgian (Georgia)"] = "ka",
            ["Gujarati (India)"] = "gu",
            ["Hindi (India)"] = "hi",
            ["Hmong (China/Vietnam)"] = "hmn",
            ["Indonesian (Indonesia)"] = "id",
            ["Japanese (Japan)"] = "ja",
            ["Javanese (Indonesia)"] = "jw",
            ["Kannada (India)"] = "kn",
            ["Kazakh (Kazakhstan)"] = "kk",
            ["Khmer (Cambodia)"] = "km",
            ["Korean (South Korea)"] = "ko",
            ["Kurdish (Kurdistan)"] = "ku",
            ["Kyrgyz (Kyrgyzstan)"] = "ky",
            ["Lao (Laos)"] = "lo",
            ["Malay (Malaysia)"] = "ms",
            ["Malayalam (India)"] = "ml",
            ["Marathi (India)"] = "mr",
            ["Mongolian (Mongolia)"] = "mn",
            ["Nepali (Nepal)"] = "ne",
            ["Pashto (Afghanistan)"] = "ps",
            ["Punjabi (India/Pakistan)"] = "pa",
            ["Sindhi (Pakistan)"] = "sd",
            ["Sinhala (Sri Lanka)"] = "si",
            ["Sundanese (Indonesia)"] = "su",
            ["Tajik (Tajikistan)"] = "tg",
            ["Tamil (India/Sri Lanka)"] = "ta",
            ["Telugu (India)"] = "te",
            ["Thai (Thailand)"] = "th",
            ["Urdu (Pakistan/India)"] = "ur",
            ["Uzbek (Uzbekistan)"] = "uz",
            ["Vietnamese (Vietnam)"] = "vi"
        }
    },
    {
        Name = "European Languages",
        Languages = {
            ["Albanian (Albania)"] = "sq",
            ["Basque (Spain/France)"] = "eu",
            ["Belarusian (Belarus)"] = "be",
            ["Bosnian (Bosnia)"] = "bs",
            ["Bulgarian (Bulgaria)"] = "bg",
            ["Catalan (Spain)"] = "ca",
            ["Corsican (France)"] = "co",
            ["Croatian (Croatia)"] = "hr",
            ["Czech (Czechia)"] = "cs",
            ["Danish (Denmark)"] = "da",
            ["Dutch (Netherlands)"] = "nl",
            ["Estonian (Estonia)"] = "et",
            ["Finnish (Finland)"] = "fi",
            ["French (France/Canada)"] = "fr",
            ["Frisian (Netherlands)"] = "fy",
            ["Galician (Spain)"] = "gl",
            ["German (Germany)"] = "de",
            ["Greek (Greece)"] = "el",
            ["Hungarian (Hungary)"] = "hu",
            ["Icelandic (Iceland)"] = "is",
            ["Irish (Ireland)"] = "ga",
            ["Italian (Italy)"] = "it",
            ["Latvian (Latvia)"] = "lv",
            ["Lithuanian (Lithuania)"] = "lt",
            ["Luxembourgish (Luxembourg)"] = "lb",
            ["Macedonian (N. Macedonia)"] = "mk",
            ["Maltese (Malta)"] = "mt",
            ["Norwegian (Norway)"] = "no",
            ["Polish (Poland)"] = "pl",
            ["Portuguese (Portugal/Brazil)"] = "pt",
            ["Romanian (Romania)"] = "ro",
            ["Russian (Russia)"] = "ru",
            ["Scots Gaelic (Scotland)"] = "gd",
            ["Serbian (Serbia)"] = "sr",
            ["Slovak (Slovakia)"] = "sk",
            ["Slovenian (Slovenia)"] = "sl",
            ["Spanish (Spain/Mexico)"] = "es",
            ["Swedish (Sweden)"] = "sv",
            ["Ukrainian (Ukraine)"] = "uk",
            ["Welsh (Wales)"] = "cy"
        }
    },
    {
        Name = "Middle Eastern Languages",
        Languages = {
            ["Arabic (Saudi Arabia)"] = "ar",
            ["Hebrew (Israel)"] = "iw",
            ["Persian (Iran)"] = "fa",
            ["Turkish (Turkey)"] = "tr",
            ["Yiddish (Israel/USA)"] = "yi"
        }
    },
    {
        Name = "North & Central American",
        Languages = {
            ["Haitian Creole (Haiti)"] = "ht"
        }
    },
    {
        Name = "Oceanian Languages",
        Languages = {
            ["Cebuano (Philippines)"] = "ceb",
            ["Filipino (Philippines)"] = "tl",
            ["Hawaiian (USA)"] = "haw",
            ["Maori (New Zealand)"] = "mi",
            ["Samoan (Samoa)"] = "sm"
        }
    }
}

local languages = {}
local languageNames = {}

for _, category in ipairs(languageCategories) do
    for langName, langCode in pairs(category.Languages) do
        languages[langName] = langCode
        table.insert(languageNames, langName)
    end
end

table.sort(languageNames)

local HttpService     = game:GetService("HttpService")
local Players         = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local CoreGui         = game:GetService("CoreGui")
local LocalPlayer     = Players.LocalPlayer

local gv

local function getConsent(body)
    local t = {}
    for tag in body:gmatch('<input type="hidden" name=".-" value=".-">') do
        local k, v = tag:match('<input type="hidden" name="(.-)" value="(.-)">')
        t[k] = v
    end
    gv = t.v or ""
end

local function fetch(url, method, body)
    method = method or "GET"
    local res = request({
        Url = url,
        Method = method,
        Headers = { cookie = "CONSENT=YES+" .. (gv or "") },
        Body = body
    })
    local b = res.Body or ""
    if type(b) ~= "string" then b = tostring(b) end
    if b:match("https://consent.google.com/s") then
        getConsent(b)
        res = request({
            Url = url,
            Method = "GET",
            Headers = { cookie = "CONSENT=YES+" .. (gv or "") }
        })
    end
    return res
end

local function queryString(data)
    local s = ""
    for k, v in pairs(data) do
        if type(v) == "table" then
            for _, vv in pairs(v) do
                s = s .. "&" .. HttpService:UrlEncode(k) .. "=" .. HttpService:UrlEncode(vv)
            end
        else
            s = s .. "&" .. HttpService:UrlEncode(k) .. "=" .. HttpService:UrlEncode(v)
        end
    end
    return s:sub(2)
end

local jsonEncode = function(x) return HttpService:JSONEncode(x) end
local jsonDecode = function(x) return HttpService:JSONDecode(x) end

local rpc = "MkEWBc"
local rootUrl = "https://translate.google.com/"
local batchUrl = "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute"

local fsid, bl, requestId = nil, nil, math.random(1000, 9999)

do
    local response = fetch(rootUrl)
    local body = response.Body or ""
    fsid = body:match('"FdrFJe":"(.-)"')
    bl = body:match('"cfb2h":"(.-)"')
end

local function translate(text, targetLang, sourceLang)
    requestId = requestId + 10000
    sourceLang = sourceLang or "auto"
    local data = {{text, sourceLang, targetLang, true}, {nil}}
    local freq = {{{rpc, jsonEncode(data), nil, "generic"}}}
    local url = batchUrl .. "?" .. queryString{
        rpcids = rpc,
        ["f.sid"] = fsid,
        bl = bl,
        hl = "en",
        _reqID = requestId - 10000,
        rt = "c"
    }
    local body = queryString{["f.req"] = jsonEncode(freq)}
    local res = fetch(url, "POST", body)
    
    local success, result = pcall(function()
        local arr = jsonDecode((res.Body or ""):match("%[.-%]\n"))
        return jsonDecode(arr[1][3])
    end)
    
    if not success then return nil end
    return result[2][1][1][6][1][1]
end

local function translateWithInfo(text, targetLang, sourceLang)
    requestId = requestId + 10000
    sourceLang = sourceLang or "auto"
    local data = {{text, sourceLang, targetLang, true}, {nil}}
    local freq = {{{rpc, jsonEncode(data), nil, "generic"}}}
    local url = batchUrl .. "?" .. queryString{
        rpcids = rpc,
        ["f.sid"] = fsid,
        bl = bl,
        hl = "en",
        _reqID = requestId - 10000,
        rt = "c"
    }
    local body = queryString{["f.req"] = jsonEncode(freq)}
    local res = fetch(url, "POST", body)
    
    local success, result = pcall(function()
        local arr = jsonDecode((res.Body or ""):match("%[.-%]\n"))
        return jsonDecode(arr[1][3])
    end)
    
    if not success or not result then return nil, nil end
    return result[2][1][1][6][1][1], result[3]
end

local function showSystemMessage(msg)
    local channels = TextChatService:WaitForChild("TextChannels", 60)
    if not channels then return end
    local channel = channels:FindFirstChild("RBXSystem")
        or channels:FindFirstChild("RBXGeneral")
        or channels:GetChildren()[1]
    if channel and channel.DisplaySystemMessage then
        channel:DisplaySystemMessage(msg)
    end
end

local function getDefaultChannel()
    return TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        or TextChatService.TextChannels:FindFirstChild("General")
        or TextChatService.TextChannels:FindFirstChild("RBXSystem")
end

local function sendMessage(text)
    task.spawn(function()
        local channel = getDefaultChannel()
        if channel then
            channel:SendAsync(text)
        end
    end)
end

local function handleOutgoingMessage(message)
    if message:sub(1, 1) == "/" then return false end
    
    if isOutgoingTranslatorActive and targetLanguage then
        local translated = translate(message, targetLanguage, "auto") or message
        sendMessage(translated)
        return true
    end
    
    return false
end

local yourLangDropdown = section:AddDropdown("Your Language", languageNames, function(selected)
    yourLanguage = languages[selected]
    shared.Notify("Your language set to: " .. selected, 1)
end)
yourLangDropdown.Select("English (USA/UK)")

local targetLangDropdown = section:AddDropdown("Target Language", languageNames, function(selected)
    targetLanguage = languages[selected]
    shared.Notify("Target translation language set to: " .. selected, 1)
end)

section:AddToggle("Auto Translate My Messages", function(enabled)
    isOutgoingTranslatorActive = enabled
    if enabled then
        shared.Notify("Auto translate MY messages ENABLED", 1)
    else
        shared.Notify("Auto translate MY messages DISABLED", 1)
    end
end)

section:AddToggle("Translate Others' Messages", function(enabled)
    isIncomingTranslatorActive = enabled
    if enabled then
        shared.Notify("Translate OTHERS' messages ENABLED", 1)
    else
        shared.Notify("Translate OTHERS' messages DISABLED", 1)
    end
end)

task.spawn(function()
    repeat task.wait() until CoreGui:FindFirstChild("ExperienceChat")
    local expChat = CoreGui:WaitForChild("ExperienceChat")
    local app = expChat:WaitForChild("appLayout")
    local inputBar = app:WaitForChild("chatInputBar")
    local bg = inputBar:WaitForChild("Background")
    local container = bg:WaitForChild("Container")
    local textContainer = container:WaitForChild("TextContainer")
    local textBoxContainer = textContainer:WaitForChild("TextBoxContainer")
    local textBox = textBoxContainer:WaitForChild("TextBox")
    local sendBtn = container:WaitForChild("SendButton")

    local function onSend()
        local msg = textBox.Text
        if msg == "" then return end
        textBox.Text = ""
        
        if not handleOutgoingMessage(msg) then
            sendMessage(msg)
        end
    end

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then onSend() end
    end)
    
    sendBtn.MouseButton1Click:Connect(onSend)
end)

TextChatService.MessageReceived:Connect(function(message)
    if not message.TextSource or message.TextSource.UserId == LocalPlayer.UserId then
        return
    end
    
    if not isIncomingTranslatorActive then
        return
    end
    
    local source = message.TextSource
    local player = Players:GetPlayerByUserId(source.UserId)
    local display = player and player.DisplayName or tostring(source.UserId)
    local username = player and player.Name or tostring(source.UserId)
    local nameDisplay = (display == username) and ("@" .. username) or (display .. " (@" .. username .. ")")

    local translated, detected = translateWithInfo(message.Text, yourLanguage, "auto")
    
    if translated and translated ~= "" and translated ~= message.Text then
        local langCode = detected and detected:upper() or "AUTO"
        showSystemMessage("(" .. langCode .. ") [" .. nameDisplay .. "]: " .. translated)
    end
end)
