-- ============================================
-- WEBHOOK.lua - Discord webhook notifications
-- ============================================
local Webhook = {}
local Config = nil

local function httpRequest(options)
    local req = (syn and syn.request)
        or (http and http.request)
        or http_request
        or (fluxus and fluxus.request)
        or request
    if req then
        req(options)
    else
        pcall(function()
            Config.Services.HttpService:PostAsync(options.Url, options.Body, options.Headers)
        end)
    end
end

function Webhook.Send(isDisconnect, customReason)
    if not Config then return end
    if Config.Settings.Webhook.URL == "" or not Config.Settings.Webhook.Enabled then return end

    local elapsed = tick() - Config.Farm.StartTime
    local hours = math.floor(elapsed / 3600)
    local mins  = math.floor((elapsed % 3600) / 60)
    local secs  = math.floor(elapsed % 60)
    local perHour = elapsed > 0 and math.floor((Config.Farm.TotalCollected / elapsed) * 3600) or 0
    local timeStr = string.format("%02d:%02d:%02d", hours, mins, secs)
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Config.Player.UserId .. "&width=420&height=420&format=png"

    local contentStr = ""
    if isDisconnect then
        contentStr = "||@everyone|| **Disconnected or Kicked!**\nReason: " .. (customReason or "Unknown")
    end

    local data = {
        ["content"] = contentStr,
        ["embeds"] = {{
            ["title"]  = isDisconnect and "🚨 DISCONNECT TRIGGERED 🚨" or "💖 Heart Farm Update 💖",
            ["color"]  = isDisconnect and 16711680 or 16738740,
            ["author"] = {
                ["name"]     = Config.Player.DisplayName .. " (@" .. Config.Player.Name .. ")",
                ["icon_url"] = avatarUrl,
            },
            ["thumbnail"] = { ["url"] = avatarUrl },
            ["fields"] = {
                { ["name"] = "💖 Total Hearts",  ["value"] = "```ini\n[" .. tostring(Config.Farm.TotalCollected) .. "]\n```", ["inline"] = true },
                { ["name"] = "📈 Est. Per Hour",  ["value"] = "```ini\n[" .. tostring(perHour) .. "]\n```", ["inline"] = true },
                { ["name"] = "⏱️ Time Elapsed",  ["value"] = "```bash\n\"" .. timeStr .. "\"\n```", ["inline"] = true },
                { ["name"] = "📡 Status",         ["value"] = isDisconnect and "🔴 **Connection Lost / Kicked**" or "🟢 **Farming Active**", ["inline"] = false },
            },
            ["footer"]    = { ["text"] = "Candy Zone V18 Ultimate" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }},
    }

    httpRequest({
        Url     = Config.Settings.Webhook.URL,
        Body    = Config.Services.HttpService:JSONEncode(data),
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
    })
end

function Webhook.SetConfig(cfg)
    Config = cfg
end

return Webhook
