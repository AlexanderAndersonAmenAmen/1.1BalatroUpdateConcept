local MOD = SMODS.current_mod
BUC11 = BUC11 or {}

MOD.optional_features = function()
    return { object_weights = true, retrigger_joker = true }
end

SMODS.Atlas({ key = "Jokers", path = "Jokers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Vouchers", path = "Vouchers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Consumables", path = "Consumables.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Enhancers", path = "Enhancers.png", px = 71, py = 95 })

local files = {
    seals = {
        list = { "green_seal", "blue_seal" },
        directory = "seals/",
    },
    jokers = {
        list = {
            "formosana",
            "munched_homework",
            "dark_idol",
            "survey",
            "sunny_side",

            "grim_jester",
            "pot_of_greed",
            "one_punchline_man",
            "jokestone",
            "miner_joker",
            "berries",
            "loaded_die",
            "coffee_break",

        },
        directory = "jokers/",
    },
    spectrals = {
        list = { "cycle", "rebirth" },
        directory = "consumables/spectral/",
    },
    vouchers = {
        list = { "catch_of_the_day", "lunker" },
        directory = "vouchers/",
    },
    decks = {
        list = { "circus" },
        directory = "decks/",
    },
}

assert(SMODS.load_file("lib/utils.lua"))()
assert(SMODS.load_file("lib/vanilla_tweaks.lua"))()

local load_order = { "seals", "jokers", "spectrals", "vouchers", "decks" }
for _, set_key in ipairs(load_order) do
    local set = files[set_key]
    for _, name in ipairs(set.list) do
        assert(SMODS.load_file(set.directory .. name .. ".lua"))()
    end
end

assert(SMODS.load_file("lib/boss_components.lua"))()
assert(SMODS.load_file("lib/blue_stake.lua"))()
assert(SMODS.load_file("lib/hooks.lua"))()

assert(SMODS.load_file("lib/vanilla_menu.lua"))()
