SMODS.Joker({
    weight = 20,
    no_mod_badges = true,
    key = "berries",
    atlas = "Jokers",
    pos = { x = 2, y = 2 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    config = { extra = { chips = 250, berries = 3, total = 3 } },
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return { vars = { extra.chips, extra.berries, extra.total } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and (context.blueprint_card or card) == G.jokers.cards[1]
            and card.ability.extra.berries > 0 then
            if not context.blueprint then card.ability.buc11_eat_berry = true end
            return { chips = card.ability.extra.chips }
        end
        if context.after and not context.blueprint and card.ability.buc11_eat_berry then
            card.ability.buc11_eat_berry = nil
            card.ability.extra.berries = math.max(0, card.ability.extra.berries - 1)
            if card.ability.extra.berries == 0 then
                SMODS.destroy_cards({ card }, { pinch_anim = true })
            end
            return { message = localize("k_buc11_destroyed"), colour = G.C.CHIPS }
        end
    end,
})
