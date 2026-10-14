SMODS.Consumable({
    weight = 20,
    no_mod_badges = true,
    key = "cycle",
    set = "Spectral",
    atlas = "Consumables",
    pos = { x = 0, y = 0 },
    order = 15,
    cost = 4,
    unlocked = true,
    discovered = false,
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        if info_queue and G and G.P_SEALS and G.P_SEALS["buc11_green"] then info_queue[#info_queue + 1] = G.P_SEALS["buc11_green"] end
        local max_highlighted = card and card.ability and card.ability.max_highlighted or self.config.max_highlighted
        return { vars = { max_highlighted, colours = { HEX("55a383") } } }
    end,
    can_use = function(self, card)
        return G and G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local highlighted = G and G.hand and G.hand.highlighted and G.hand.highlighted[1]
        if not highlighted then return end
        G.E_MANAGER:add_event(Event({ func = function() play_sound("tarot1"); highlighted:juice_up(0.3, 0.5); return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.1,
            func = function()
                if highlighted and highlighted.set_seal then highlighted:set_seal("buc11_green", nil, true) end
                return true
            end,
        }))
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                if G.hand then G.hand:unhighlight_all() end
                return true
            end,
        }))
    end,
})

if SMODS.ConsumableTypes and SMODS.ConsumableTypes.Spectral then SMODS.ConsumableTypes.Spectral.collection_rows = { 5, 5 } end

local collection_pool_ref = SMODS.collection_pool
SMODS.collection_pool = function(base_pool)
    local pool = collection_pool_ref(base_pool)
    if G and G.P_CENTER_POOLS and base_pool == G.P_CENTER_POOLS.Spectral then
        local ordered, moved = {}, {}
        for _, center in ipairs(pool) do
            if center.key == "c_buc11_cycle" or center.key == "c_buc11_rebirth" then
                moved[center.key] = center
            else
                ordered[#ordered + 1] = center
            end
        end
        local index = #ordered + 1
        for i, center in ipairs(ordered) do
            if center.key == "c_soul" or center.key == "c_black_hole" then
                index = i
                break
            end
        end
        for _, key in ipairs({ "c_buc11_cycle", "c_buc11_rebirth" }) do
            if moved[key] then
                table.insert(ordered, index, moved[key])
                index = index + 1
            end
        end
        pool = ordered
    end
    return pool
end
