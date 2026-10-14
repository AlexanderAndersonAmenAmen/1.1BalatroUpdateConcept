local function survey_extra(card)
    if type(card.ability.extra) ~= "table" then card.ability.extra = {} end
    local extra = card.ability.extra
    extra.odds = extra.odds or 2
    extra.dollars = extra.dollars or 1
    return extra
end

SMODS.Joker({
    weight = 20,
    no_mod_badges = true,
    key = "survey",
    atlas = "Jokers",
    pos = { x = 3, y = 0 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 2, dollars = 1 } },
    loc_vars = function(self, info_queue, card)
        local extra = survey_extra(card)
        local n, d = SMODS.get_probability_vars(card, 1, extra.odds, "buc11_survey")
        return { vars = { n, d, extra.dollars } }
    end,
    calculate = function(self, card, context)
        local extra = survey_extra(card)
        if type(context.hand_drawn) == "table" then
            local dollars = 0
            for _, drawn in ipairs(context.hand_drawn) do
                if drawn:is_face() and SMODS.pseudorandom_probability(card, "buc11_survey", 1,
                    extra.odds) then
                    dollars = dollars + extra.dollars
                end
            end
            if dollars > 0 then return { dollars = dollars } end
        end
    end,
})
