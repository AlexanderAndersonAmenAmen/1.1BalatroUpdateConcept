SMODS.Voucher({
    weight = 20,
    no_mod_badges = true,
    key = "lunker",
    atlas = "Vouchers",
    pos = { x = 1, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = false,
    requires = { "v_buc11_catch_of_the_day" },
    calculate = function(self, card, context)
        BUC11.multiply_rarity_weight(context, 3)
    end,
})
