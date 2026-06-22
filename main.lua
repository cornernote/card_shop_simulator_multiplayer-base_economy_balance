local M = {
    id          = "BaseEconomyBalance",
    name        = "Base Economy Balance",
    version     = "0.8.8",
    author      = "Codex",
    description = "Smooths base-game card values, pack rarity odds, and premium traits while preserving card names, art, stats, and rarity.",
}

local CONFIG = {
    trait_values = {
        Basic = 1.00,
        Silver = 1.35,
        Gold = 2.20,
        Holographic = 3.60,
        Shiny = 5.50,
        Legendary = 9.00,
    },

    rarity_values = {
        Common = 0.30,
        UnCommon = 0.45,
        Rare = 1.70,
        SuperRare = 7.50,
        God = 35.00,
    },

    pack_rates = {
        -- Booster indexes are sample-proven in _sample/3681574688:
        -- 0 = standard, 1 = deluxe/luxury, 2 = luxury/rare luxury.
        [0] = { Common = 0.9583, UnCommon = 0.0372, Rare = 0.0045, SuperRare = 0.0, God = 0.0 },
        [1] = { Common = 0.10, UnCommon = 0.34, Rare = 0.50, SuperRare = 0.06, God = 0.0 },
        [2] = { Common = 0.0, UnCommon = 0.01, Rare = 0.14, SuperRare = 0.85, God = 0.0 },
    },

    trait_rates = {
        Common = { Basic = 0.82, Silver = 0.14, Gold = 0.035, Holographic = 0.005, Shiny = 0.0, Legendary = 0.0 },
        UnCommon = { Basic = 0.68, Silver = 0.22, Gold = 0.08, Holographic = 0.018, Shiny = 0.002, Legendary = 0.0 },
        Rare = { Basic = 0.45, Silver = 0.30, Gold = 0.17, Holographic = 0.06, Shiny = 0.018, Legendary = 0.002 },
        SuperRare = { Basic = 0.30, Silver = 0.28, Gold = 0.22, Holographic = 0.14, Shiny = 0.05, Legendary = 0.01 },
        God = { Basic = 0.16, Silver = 0.20, Gold = 0.27, Holographic = 0.22, Shiny = 0.11, Legendary = 0.04 },
    },

    card_values = {
        holiday_rare = { min = 378.00, step = 225.00 },
        holiday_super = 810.00,
        souvenir_low = 3.00,
        souvenir_high = 6.00,
        god = 41.40,
        gen_scales = {
            Common = { 0.824, 0.714, 0.599, 0.861, 0.775, 0.774, 0.734 },
            UnCommon = { 0.824, 0.714, 0.599, 0.861, 0.775, 0.774, 0.734 },
            Rare = { 2.301, 2.086, 1.889, 1.824, 1.656, 1.514, 1.362 },
            SuperRare = { 0.974, 1.028, 0.837, 0.788, 0.814, 1.002, 0.829 },
        },
        curves = {
            Common = {
                low_gen_max = 2,
                low = { in_low = 0.85, in_high = 1.40, out_low = 1.80, out_low_gen = 0.38, out_high = 2.63, out_high_gen = 0.47 },
                base = { in_low = 0.85, in_high = 1.40, out_low = 0.98, out_low_gen = 0.17, out_high = 1.84, out_high_gen = 0.26 },
            },
            UnCommon = {
                low_gen_max = 2,
                low = { in_low = 0.84, in_high = 1.60, out_low = 2.44, out_low_gen = 0.53, out_high = 3.75, out_high_gen = 0.66 },
                base = { in_low = 0.84, in_high = 1.60, out_low = 1.69, out_low_gen = 0.26, out_high = 2.91, out_high_gen = 0.34 },
            },
            Rare = {
                base = { in_low = 0.94, in_high = 2.30, out_low = 4.68, out_low_gen = 0.40, out_high = 8.28, out_high_gen = 0.50 },
            },
            SuperRare = {
                base = { in_low = 1.00, in_high = 1.90, out_low = 20.00, out_low_gen = 0.00, out_high = 54.00, out_high_gen = 0.00 },
            },
        },
    },
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

local function rarity_name(rarity)
    if rarity == 0 then return "Common" end
    if rarity == 1 then return "UnCommon" end
    if rarity == 2 then return "Rare" end
    if rarity == 3 then return "SuperRare" end
    if rarity == 4 then return "God" end
    return nil
end

local function rarity_enum(name)
    if not UE or not UE.ECardRarity then return nil end
    return UE.ECardRarity[name]
end

local function trait_enum(name)
    if not UE or not UE.ETrait then return nil end
    return UE.ETrait[name]
end

local function build_rarity_rate_table(rates)
    local out = {}
    for name, value in pairs(rates) do
        local enum = rarity_enum(name)
        if enum ~= nil then
            out[enum] = value
        end
    end
    return out
end

local function build_trait_rate_table(rates)
    local out = {}
    for name, value in pairs(rates) do
        local enum = trait_enum(name)
        if enum ~= nil then
            out[enum] = value
        end
    end
    return out
end

local function apply_curve(current, gen, curve)
    return round2(scale_clamped(
        current,
        curve.in_low,
        curve.in_high,
        curve.out_low + (curve.out_low_gen * gen),
        curve.out_high + (curve.out_high_gen * gen)
    ))
end

local function apply_gen_scale(value, rarity_name_value, gen)
    local scales = CONFIG.card_values.gen_scales
    local by_rarity = scales and scales[rarity_name_value] or nil
    local scale = by_rarity and by_rarity[gen + 1] or 1
    return round2(value * scale)
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

    local changed = 0
    for name, value in pairs(CONFIG.trait_values) do
        local enum = trait_enum(name)
        if enum ~= nil then
            local ok = safe(function()
                registry:RegisterTraitValueData(enum, value)
                return true
            end, false)
            if ok then
                changed = changed + 1
            end
        end
    end

    return changed
end

local function apply_rarity_values(registry)
    if not registry.RegisterRarityValueData or not UE or not UE.ECardRarity then
        return 0
    end

    local changed = 0
    for name, value in pairs(CONFIG.rarity_values) do
        local enum = rarity_enum(name)
        if enum ~= nil then
            local ok = safe(function()
                registry:RegisterRarityValueData(enum, value)
                return true
            end, false)
            if ok then
                changed = changed + 1
            end
        end
    end

    return changed
end

local function apply_pack_rarity_rates(registry)
    if not registry.RegisterRarityData or not UE or not UE.ECardRarity then
        return 0
    end

    local changed = 0
    for booster_index, rates in pairs(CONFIG.pack_rates) do
        local rate_table = build_rarity_rate_table(rates)
        local ok = safe(function()
            registry:RegisterRarityData(booster_index, rate_table)
            return true
        end, false)
        if ok then
            changed = changed + 1
        end
    end

    return changed
end

local function apply_trait_rates(registry)
    if not registry.RegisterTraitData or not UE or not UE.ECardRarity or not UE.ETrait then
        return 0
    end

    local changed = 0
    for rarity, rates in pairs(CONFIG.trait_rates) do
        local enum = rarity_enum(rarity)
        if enum ~= nil then
            local rate_table = build_trait_rate_table(rates)
            local ok = safe(function()
                registry:RegisterTraitData(enum, rate_table)
                return true
            end, false)
            if ok then
                changed = changed + 1
            end
        end
    end

    return changed
end

local function balanced_value(card_id, rarity, current)
    if not current or current <= 0 then return nil end
    local values = CONFIG.card_values

    -- Holiday cards come from premium event drops rather than buyable packs.
    -- Keep them above Gen 7 rare-luxury EV, but below divine/god cards.
    if card_id >= 1314 and card_id <= 1323 then
        if rarity == 3 then return values.holiday_super end
        local t = clamp((card_id - 1314) / 7, 0, 1)
        return round2(values.holiday_rare.min + (values.holiday_rare.step * t))
    end

    -- Souvenir/commemorative cards are special, but most were worth only 1.0.
    if card_id >= 9000 and card_id < 10000 then
        if current >= 6 then return values.souvenir_high end
        return values.souvenir_low
    end

    -- Divine/god cards should remain clear chase pulls without making hidden
    -- premium multipliers completely dominate the economy.
    if rarity == 4 or card_id >= 100000 then
        return values.god
    end

    local gen = generation_index(card_id)
    local name = rarity_name(rarity)
    local config = name and values.curves[name] or nil

    if config then
        if config.low and config.low_gen_max and gen <= config.low_gen_max then
            return apply_gen_scale(apply_curve(current, gen, config.low), name, gen)
        end
        if config.base then
            return apply_gen_scale(apply_curve(current, gen, config.base), name, gen)
        end
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
    local rarities_changed = apply_rarity_values(registry)
    local traits_changed = apply_trait_values(registry)
    local pack_rates_changed = apply_pack_rarity_rates(registry)
    local trait_rates_changed = apply_trait_rates(registry)
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

    log(("balanced %d cards, skipped %d, rarity values %d, trait values %d, pack rates %d, trait rates %d"):format(changed, skipped, rarities_changed, traits_changed, pack_rates_changed, trait_rates_changed))
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
