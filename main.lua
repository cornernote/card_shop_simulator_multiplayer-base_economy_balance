local M = {
    id          = "BaseEconomyBalance",
    name        = "Base Economy Balance",
    version     = "0.5.0",
    author      = "Codex",
    description = "Smooths base-game card value and premium trait multipliers while preserving card names, art, stats, and rarity.",
}

local function log(message)
    if MOD and MOD.Logger then
        MOD.Logger.LogScreen("[BaseEconomyBalance] " .. tostring(message), 6, 1, 1, 0, 1)
    end
end

local function safe(call, fallback)
    local ok, value = pcall(call)
    if ok then return value end
    return fallback
end

local function clamp(value, low, high)
    if value < low then return low end
    if value > high then return high end
    return value
end

local function round2(value)
    return math.floor((value * 100) + 0.5) / 100
end

local function scale_clamped(value, in_low, in_high, out_low, out_high)
    local t = 0
    if in_high > in_low then
        t = (value - in_low) / (in_high - in_low)
    end
    t = clamp(t, 0, 1)
    return out_low + ((out_high - out_low) * t)
end

local function generation_index(card_id)
    if card_id >= 1000 and card_id < 8000 then
        return clamp(math.floor(card_id / 1000) - 1, 0, 6)
    end
    return 0
end

local function rarity_index(rarity)
    if UE and UE.ECardRarity then
        if rarity == UE.ECardRarity.Common then return 0 end
        if rarity == UE.ECardRarity.UnCommon then return 1 end
        if rarity == UE.ECardRarity.Rare then return 2 end
        if rarity == UE.ECardRarity.SuperRare then return 3 end
        if rarity == UE.ECardRarity.God then return 4 end
    end

    local n = tonumber(tostring(rarity))
    if n then return math.floor(n) end

    local s = tostring(rarity):lower()
    if s:find("common") and not s:find("un") then return 0 end
    if s:find("uncommon") then return 1 end
    if s:find("super") then return 3 end
    if s:find("rare") then return 2 end
    if s:find("god") then return 4 end
    return nil
end

local function get_card(registry, card_id)
    local data = safe(function() return UE.FCardDataAll() end, nil)
    if not data then return nil end

    local ok = safe(function()
        return registry:GetCardData(card_id, data)
    end, false)

    if ok == false then return nil end
    return data
end

local function add_id(ids, seen, id)
    local n = tonumber(tostring(id))
    if not n then return end
    n = math.floor(n)
    if seen[n] then return end
    seen[n] = true
    ids[#ids + 1] = n
end

local function collect_ids(registry)
    local ids = {}
    local seen = {}
    local raw = safe(function()
        if registry.GetCardDataAllID then
            return registry:GetCardDataAllID()
        end
        return nil
    end, nil)

    if raw then
        safe(function()
            for _, value in pairs(raw) do add_id(ids, seen, value) end
        end, nil)
        safe(function()
            for i = 1, #raw do add_id(ids, seen, raw[i]) end
        end, nil)
        safe(function()
            local count = raw:Num()
            for i = 0, count - 1 do add_id(ids, seen, raw:Get(i)) end
        end, nil)
    end

    table.sort(ids)
    return ids
end

local function apply_trait_values(registry)
    if not registry.RegisterTraitValueData or not UE or not UE.ETrait then
        return 0
    end

    -- These values smooth premium frame variance. The sample mod in
    -- _sample/3639546917 uses 1, 2, 5, 10, 20, 35; this gentler curve keeps
    -- premium cards exciting without letting the top frame dominate pack EV.
    local trait_values = {
        { UE.ETrait.Basic, 1.00 },
        { UE.ETrait.Silver, 1.50 },
        { UE.ETrait.Gold, 3.00 },
        { UE.ETrait.Holographic, 6.00 },
        { UE.ETrait.Shiny, 10.00 },
        { UE.ETrait.Legendary, 18.00 },
    }

    local changed = 0
    for _, item in ipairs(trait_values) do
        local ok = safe(function()
            registry:RegisterTraitValueData(item[1], item[2])
            return true
        end, false)
        if ok then
            changed = changed + 1
        end
    end

    return changed
end

local function balanced_value(card_id, rarity, current)
    if not current or current <= 0 then return nil end

    -- Holiday cards were extreme outliers at roughly 48-65. Keep them premium,
    -- but below divine/god cards and low enough not to dominate the economy.
    if card_id >= 1314 and card_id <= 1323 then
        if rarity == 3 then return 14.00 end
        local t = clamp((card_id - 1314) / 7, 0, 1)
        return round2(8.00 + (4.00 * t))
    end

    -- Souvenir/commemorative cards are special, but most were worth only 1.0.
    if card_id >= 9000 and card_id < 10000 then
        if current >= 6 then return 6.00 end
        return 3.00
    end

    -- Divine/god cards should remain clear chase pulls without making hidden
    -- premium multipliers completely dominate the economy.
    if rarity == 4 or card_id >= 100000 then
        return 24.00
    end

    local gen = generation_index(card_id)

    if rarity == 0 then
        return round2(scale_clamped(current, 0.85, 1.40, 0.45 + (0.30 * gen), 0.85 + (0.42 * gen)))
    end

    if rarity == 1 then
        return round2(scale_clamped(current, 0.84, 1.60, 0.90 + (0.52 * gen), 1.55 + (0.65 * gen)))
    end

    if rarity == 2 then
        return round2(scale_clamped(current, 0.94, 2.30, 3.25 + (0.85 * gen), 5.75 + (1.05 * gen)))
    end

    if rarity == 3 then
        return round2(scale_clamped(current, 1.00, 1.90, 8.50 + (1.15 * gen), 14.00 + (1.45 * gen)))
    end

    return round2(current)
end

local function apply_balance()
    local registry = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not registry then
        log("card registry not found")
        return
    end

    local changed = 0
    local skipped = 0
    local traits_changed = apply_trait_values(registry)
    local ids = collect_ids(registry)

    for _, card_id in ipairs(ids) do
        local data = get_card(registry, card_id)
        if data then
            local current = tonumber(tostring(data.CardValueMulti))
            local rarity = rarity_index(data.Rarity)
            local target = balanced_value(card_id, rarity, current)
            if target and math.abs(target - current) > 0.001 then
                data.CardValueMulti = target
                registry:RegisterCardData(card_id, data)
                changed = changed + 1
            else
                skipped = skipped + 1
            end
        else
            skipped = skipped + 1
        end
    end

    log(("balanced %d cards, skipped %d, traits %d"):format(changed, skipped, traits_changed))
end

function M.OnInit()
    apply_balance()

    -- Re-apply shortly after load so this also works when another card mod
    -- registers its cards during the same initialization window.
    if MOD and MOD.GAA and MOD.GAA.TimerManager then
        MOD.GAA.TimerManager:AddTimer(5, M, function() apply_balance() end)
    end
end

return M
