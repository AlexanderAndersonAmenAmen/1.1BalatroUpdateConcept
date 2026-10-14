

BUC11 = BUC11 or {}

BUC11.BOSS_COMPONENTS = {}

BUC11.BOSS_COMPONENT_POOL = {

    "bl_house",
    "bl_wall",
    "bl_wheel",

    "bl_club",
    "bl_fish",

    "bl_psychic",
    "bl_goad",
    "bl_window",

    "bl_manacle",

    "bl_eye",
    "bl_mouth",

    "bl_plant",
    "bl_serpent",

    "bl_pillar",

    "bl_needle",

    "bl_head",

    "bl_mark",

    "bl_flint",

    "bl_water",

}

local card_debuffers = {

    bl_plant = true,
    bl_club = true,
    bl_goad = true,
    bl_window = true,
    bl_head = true,
    bl_mark = true,
    bl_psychic = true,
    bl_pillar = true,

}

local card_flippers = {
    bl_house = true,
    bl_wheel = true,
    bl_fish = true,
    bl_mark = true,
}

local forbidden = {

    {
        "bl_plant",
        "bl_mark"
    },

    {
        "bl_needle",
        "bl_wall"
    },

    {
        "bl_needle",
        "bl_water"
    },

    {
        "bl_eye",
        "bl_mouth"
    },

}

local function contains(tbl, value)

    for _,v in ipairs(tbl) do

        if v == value then
            return true
        end

    end

    return false

end

local function invalid_combo(result, candidate)

    local test = {}

    for _,v in ipairs(result) do
        test[#test+1] = v
    end

    test[#test+1] = candidate

    local debuffs = 0

    for _,v in ipairs(test) do

        if card_debuffers[v] then

            debuffs = debuffs + 1

        end

    end

    if debuffs > 1 then

        return true

    end

    local flippers = 0

    for _,v in ipairs(test) do
        if card_flippers[v] then
            flippers = flippers + 1
        end
    end

    if flippers > 1 then
        return true
    end

    for _,pair in ipairs(forbidden) do

        if contains(test,pair[1])
        and contains(test,pair[2])
        then

            return true

        end

    end

    return false

end

BUC11.boss_combo_invalid = invalid_combo
BUC11.BOSS_CARD_DEBUFFERS = card_debuffers
BUC11.BOSS_CARD_FLIPPERS = card_flippers

BUC11.BOSS_COMPONENTS.bl_hook = {
    loc_name = "The Hook",

    calculate = function(self, blind, context)
        if not context.press_play then return end
        G.E_MANAGER:add_event(Event({ func = function()
            local available = {}
            for _, card in ipairs((G.hand and G.hand.cards) or {}) do
                available[#available + 1] = card
            end
            local selected = false
            for _ = 1, math.min(2, #available) do
                local card, index = pseudorandom_element(available, pseudoseed("buc11_platinum_hook"))
                if not card then break end
                G.hand:add_to_highlighted(card, true)
                table.remove(available, index)
                selected = true
                play_sound("card1", 1)
            end
            if selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
            return true
        end }))
        blind.triggered = true
        delay(0.7)
    end,
}

BUC11.BOSS_COMPONENTS.bl_ox = {
    loc_name = "The Ox",

    calculate = function(self, blind, context)
        if context.debuff_hand
            and context.scoring_name == G.GAME.current_round.most_played_poker_hand
        then
            blind.triggered = true
            if not context.check then
                ease_dollars(-G.GAME.dollars, true)
                blind:wiggle()
            end
        end
    end,
}

BUC11.BOSS_COMPONENTS.bl_arm = {
    loc_name = "The Arm",

    calculate = function(self, blind, context)
        local hand = context.debuff_hand and context.scoring_name
        if hand and G.GAME.hands[hand] and G.GAME.hands[hand].level > 1 then
            blind.triggered = true
            if not context.check then
                level_up_hand(blind.children.animatedSprite, hand, nil, -1)
                blind:wiggle()
            end
        end
    end,
}

BUC11.BOSS_COMPONENTS.bl_house = {

    loc_name = "The House",

    set_blind = function(self)

        self.active = true

    end,

    calculate = function(self, blind, context)

        if context.blind_disabled or context.blind_defeated then

            for _,card in ipairs(G.hand.cards) do

                if card.facing == "back" then

                    card:flip()

                end

            end

            for _,card in ipairs(G.playing_cards) do

                card.ability.wheel_flipped = nil
            end

        end

        if context.stay_flipped
        and context.to_area == G.hand
        and G.GAME.current_round.hands_played == 0
        and G.GAME.current_round.discards_used == 0
        then

            return {

                stay_flipped = true

            }

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_wall = {

    loc_name = "The Wall",

    calculate = function(self, blind, context)

        if context.blind_disabled then

            G.GAME.blind.chips =
                G.GAME.blind.chips - (self.wall_added or G.GAME.blind.chips / 2)

            G.GAME.blind.chip_text =
                number_format(
                    G.GAME.blind.chips
                )

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_wheel = {

    loc_name = "The Wheel",

    calculate = function(self, blind, context)

        if context.stay_flipped
        and context.to_area == G.hand
        and SMODS.pseudorandom_probability(
            blind,
            "devil_wheel",
            1,
            7
        )
        then

            return {

                stay_flipped = true

            }

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_club = {

    loc_name = "The Club",

    debuff = {

        suit = "Clubs"

    }

}

BUC11.BOSS_COMPONENTS.bl_fish = {

    loc_name = "The Fish",

    set_blind = function(self)
        self.prepped = false
        self.cards_to_flip = 0
    end,

    calculate = function(self, blind, context)

        if context.press_play then
            self.prepped = true
            self.cards_to_flip = 0
        end

        if context.drawing_cards and self.prepped then
            self.cards_to_flip = context.amount or 0
            self.prepped = false
        end

        if context.stay_flipped
            and context.to_area == G.hand
            and (self.cards_to_flip or 0) > 0
        then
            self.cards_to_flip = self.cards_to_flip - 1
            return { stay_flipped = true }
        end

        if context.blind_disabled or context.blind_defeated then
            self.prepped = false
            self.cards_to_flip = 0
        end
    end,
}

BUC11.BOSS_COMPONENTS.bl_psychic = {

    loc_name = "The Psychic",

    debuff = {

        h_size_ge = 5

    }

}

BUC11.BOSS_COMPONENTS.bl_goad = {

    loc_name = "The Goad",

    debuff = {

        suit = "Spades"

    }

}

BUC11.BOSS_COMPONENTS.bl_window = {

    loc_name = "The Window",

    debuff = {
        suit = "Diamonds"
    },

    calculate = function(self, blind, context)
        if context.debuff_card
        and context.debuff_card:is_suit("Diamonds")
        then
            return {
                debuff = true
            }
        end
    end

}

BUC11.BOSS_COMPONENTS.bl_manacle = {

    loc_name = "The Manacle",

    set_blind = function(self)

        if not self.handsize_penalty_applied then
            G.hand:change_size(-1)
            self.handsize_penalty_applied = true
        end
    end,

    calculate = function(self, blind, context)
        if (context.blind_disabled or context.blind_defeated)
            and self.handsize_penalty_applied
        then
            G.hand:change_size(1)
            self.handsize_penalty_applied = false
        end
    end

}

BUC11.BOSS_COMPONENTS.bl_eye = {

    loc_name = "The Eye",

    set_blind = function(self)

        self.hands = {}

        for _,hand in ipairs(G.handlist) do

            self.hands[hand] = false

        end

    end,

    calculate = function(self, blind, context)

        if context.debuff_hand then

            if self.hands[context.scoring_name] then

                return {

                    debuff = true

                }

            end

            if not context.check then

                self.hands[context.scoring_name] = true

            end

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_mouth = {

    loc_name = "The Mouth",

    set_blind = function(self)

        self.only_hand = nil

    end,

    calculate = function(self, blind, context)

        if context.debuff_hand then

            if self.only_hand
            and self.only_hand ~= context.scoring_name
            then

                return {

                    debuff = true

                }

            end

            if not context.check then

                self.only_hand =
                    context.scoring_name

            end

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_plant = {

    loc_name = "The Plant",

    set_blind = function(self)

        self.active = true

    end,

    calculate = function(self, blind, context)

        if context.debuff_card
        and context.debuff_card:is_face(true)
        then

            return {

                debuff = true

            }

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_serpent = {

    loc_name = "The Serpent",

    calculate = function(self, blind, context)

        if context.drawing_cards and not G.GAME.buc11_forced_bonus_draw
        and (
            G.GAME.current_round.hands_played ~= 0
            or
            G.GAME.current_round.discards_used ~= 0
        )
        then

            return {

                cards_to_draw = math.min(3, math.max(0, G.hand.config.card_limit - #G.hand.cards), context.amount or 3)

            }

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_pillar = {

    loc_name = "The Pillar",

    calculate = function(self, blind, context)

        if context.debuff_card
        and context.debuff_card.area ~= G.jokers
        and context.debuff_card.ability.played_this_ante
        then

            return {

                debuff = true

            }

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_needle = {

    loc_name = "The Needle",

    calculate = function(self, blind, context)

        if context.setting_blind then
            local hands_left = G.GAME.current_round.hands_left
                or G.GAME.round_resets.hands
                or 1

            self.hands_sub = math.max(0, hands_left - 1)
            self.hands_restored = false

            if self.hands_sub > 0 then
                ease_hands_played(-self.hands_sub)
            end
        end

        if (context.blind_disabled or context.blind_defeated)
            and not self.hands_restored
        then
            if (self.hands_sub or 0) > 0 then
                ease_hands_played(self.hands_sub)
            end
            self.hands_restored = true
        end
    end,
}

BUC11.BOSS_COMPONENTS.bl_head = {

    loc_name = "The Head",

    debuff = {

        suit = "Hearts"

    }

}

BUC11.BOSS_COMPONENTS.bl_mark = {

    loc_name = "The Mark",

    calculate = function(self, blind, context)

        if context.stay_flipped
        and context.to_area == G.hand
        and context.other_card
        and context.other_card:is_face(true)
        then

            return {

                stay_flipped = true

            }

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_flint = {

    loc_name = "The Flint",

    calculate = function(self, blind, context)

        if context.modify_hand then

            blind.triggered = true

            mult =
                mod_mult(
                    math.max(
                        math.floor(
                            mult * 0.5 + 0.5
                        ),
                        1
                    )
                )

            hand_chips =
                mod_chips(
                    math.max(
                        math.floor(
                            hand_chips * 0.5 + 0.5
                        ),
                        0
                    )
                )

            update_hand_text(

                {
                    sound = 'chips2',
                    modded = true
                },

                {
                    chips = hand_chips,
                    mult = mult
                }

            )

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_water = {

    loc_name = "The Water",

    set_blind = function(self)

        self.discards_sub =
            G.GAME.current_round.discards_left

        ease_discard(
            -self.discards_sub
        )

    end,

    calculate = function(self, blind, context)

        if context.blind_disabled or context.blind_defeated then

            ease_discard(
                self.discards_sub
            )

        end

    end

}

BUC11.BOSS_COMPONENTS.bl_tooth = {
    loc_name = "The Tooth",

    calculate = function(self, blind, context)
        if context.press_play then
            local count = G.hand and G.hand.highlighted and #G.hand.highlighted or 0
            if count > 0 then
                blind.triggered = true
                ease_dollars(-count)
            end
        end
    end,
}

