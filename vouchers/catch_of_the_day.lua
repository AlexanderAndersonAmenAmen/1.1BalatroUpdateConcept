SMODS.Voucher({
    weight = 20,
    no_mod_badges = true,
    key = "catch_of_the_day",
    atlas = "Vouchers",
    pos = { x = 0, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = false,
    calculate = function(self, card, context)
        BUC11.multiply_rarity_weight(context, 2)
    end,
})
