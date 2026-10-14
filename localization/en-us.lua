return {
    descriptions = {
        Enhanced = {
            m_wild = {
                name = "Wild Card",
                text = {
                    "Can't be flipped",
                    "or debuffed",
                    "Can be used",
                    "as any suit",
                },
            },
        },
        Other = {
            buc11_green_seal = {
                name = "Green Seal",
                text = {
                    "After played or",
                    "discarded, draw",
                    "{C:attention}3{} extra cards",
                },
            },
            blue_seal = {
                name = "Blue Seal",
                text = {
                    "After scoring",
                    "this card, {C:attention}return{}",
                    "it to your hand",
                },
            },
        },
        Spectral = {
            c_buc11_rebirth = {
                name = "Rebirth",
                text = {
                    "Replace your {C:attention}Jokers{}",
                    "with new ones of",
                    "the {C:attention}same rarity{}",
                },
            },

            c_buc11_cycle = {
                name = "Cycle",
                text = {
                    "Add a {V:1}Green Seal{}",
                    "to {C:attention}#1#{} selected",
                    "card in your hand",
                },
            },
        },
        Joker = {
            j_buc11_coffee_break = {
                name = "Cup of Joe",
                text = {
                    "Retrigger {C:attention}Joker{} to",
                    "the right and take",
                    "one sip of Coffee",
                    "{C:inactive}({C:attention}#1#{}{C:inactive}/#2# sips left)",
                },
            },
            j_luchador = {
                name = "Luchador",
                text = {
                    "Sell this card to disable",
                    "{C:attention}1{} random {C:attention}Boss Blind{}",
                    "ability",
                },
            },
            j_buc11_miner_joker = {
                name = "Miner",
                text = {
                    "Each played {C:attention}Stone card{}",
                    "gets destroyed and creates",
                    "a {C:attention}Joker{} with random {C:dark_edition}Edition{}",
                    "{C:inactive}(Must have room)",
                },
            },
            j_buc11_berries = {
                name = "Berries",
                text = {
                    "If this is {C:attention}leftmost{}",
                    "Joker, add {C:chips}+#1#{} Chips",
                    "to played hand's score",
                    "and eat one Berry",
                    "{C:inactive}({C:attention}#2#{}{C:inactive}/#3# Berries left){}",
                },
            },
            j_buc11_loaded_die = {
                name = "Loaded Die",
                text = {
                    "Each scoring {C:attention}7{}",
                    "increases all {C:attention}listed{}",
                    "{C:green}probabilities{} by {C:attention}1{}",
                    "for played hand",
                },
            },
            j_buc11_one_punchline_man = {
                name = "Pluck of the Draw",
                text = {
                    "After hand is played,",
                    "put {C:attention}first{} scored card",
                    "on top of your deck",
                },
            },
            j_buc11_jokestone = {
                name = "Laugh Preserver",
                text = {
                    "At the start of round,",
                    "draw up to {C:attention}#1#{} Enhanced",
                    "cards from your deck",
                },
            },

            j_matador = {
                name = "Matador",
                text = {
                    "Keep playing {C:blue}hands{}",
                    "after {C:attention}Boss Blind{} score",
                    "was met and gain {C:money}$#1#{}",
                    "for each played",
                },
            },
            j_idol = {
                name = "The Idol",
                text = {
                    "This Joker gains {X:mult,C:white}X#1#{}",
                    "Mult when each played",
                    "{C:attention}#2#{} of {V:1}#3#{} is scored",
                    "{s:0.8}Card changes every round",
                    "{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult)",
                },
            },
            j_buc11_formosana = {
                name = "Plantain",
                text = {
                    "This Joker gains {X:mult,C:white}X#1#{} Mult",
                    "per {C:attention}Joker{} card destroyed",
                    "{C:inactive}(This can't be destroyed)",
                    "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
                },
            },
            j_buc11_munched_homework = {
                name = "Dog ate my Homework",
                text = {
                    "Destroy a random card",
                    "in hand when you use",
                    "a {C:attention}consumable card"
                },
            },
            j_buc11_dark_idol = {
                name = "Effigy",
                text = {
                    "When you draw",
                    "#1# {C:attention}#2#{}, gain {C:mult}+#3#{} Mult",
                    "{s:0.8}Rank changes every round{}",
                    "{C:inactive}(Currently {C:mult}+#4#{C:inactive} Mult)",
                },
            },
            j_buc11_survey = {
                name = "Survey",
                text = {
                    "{C:green}#1# in #2#{} chance to",
                    "gain {C:money}$#3#{} when you",
                    "draw a {C:attention}face{} card",
                },
            },
            j_buc11_sunny_side = {
                name = "Sunny Side",
                text = {
                    "{C:mult}+#1#{} Mult",
                    "Each played {C:attention}face card{}",
                    "steals {C:mult}+#2#{} Mult from this",
                    "Joker when scored",
                },
            },
            j_buc11_grim_jester = {
                name = "Wild Order",
                text = {
                    "Cards with",
                    "{V:1}#1#{} suit are",
                    "always drawn first",
                    "{s:0.8}Suit changes every round",
                },
            },
            j_buc11_pot_of_greed = {
                name = "Joke Recycler",
                text = {
                    "When you use a",
                    "{C:attention}consumable card{},",
                    "draw {C:attention}#1#{} cards",
                },
            },
        },
        Stake = {
            stake_blue = {
                name = "Blue Stake",
                text = {
                    "{C:attention}Showdown Blind{} has an extra",
                    "ability of a random {C:attention}Boss Blind{}",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
        },
        Voucher = {
            v_magic_trick = {
                name = "Magic Trick",
                text = {
                    "{C:attention}Enhanced{}",
                    "{C:attention}playing cards{}",
                    "can be purchased",
                    "from the shop",
                },
            },
            v_illusion = {
                name = "Illusion",
                text = {
                    "{C:attention}Playing cards{} in",
                    "shop may have an",
                    "{C:dark_edition}Edition{} and/or {C:attention}Seal{}",
                },
            },
            v_buc11_catch_of_the_day = {
                name = "Catch of the Day",
                text = {
                    "{C:green}Uncommon{} Jokers",
                    "appear {C:attention}2X{} more often",
                },
            },
            v_buc11_lunker = {
                name = "Lunker",
                text = {
                    "{C:red}Rare{} Jokers",
                    "appear {C:attention}2X{} more often",
                },
            },
        },
        Back = {
            b_buc11_circus = {
                name = "Circus Deck",
                text = {
                    "After defeating {C:attention}first{}",
                    "{C:attention}Boss Blind{}, create",
                    "{C:attention}3{} random {C:attention}Tags{}",
                },
            },
        },
        Blind = {
            bl_serpent = {
                name = "The Serpent",
                text = {
                    "After Play or Discard,",
                    "draw up to 3 cards",
                },
            },
        },
    },
    misc = {
        dictionary = {
            k_buc11_tag = "+1 Tag",
            k_buc11_consumed = "Eaten!",
            k_buc11_goldfish = "Saved!",
            k_buc11_boom = "BOOM!",
            k_buc11_boom_timer = "!!!",
            k_buc11_pot_of_greed = "Recycled!",
            k_buc11_rank_up = "Rank Up!",
            k_buc11_destroyed = "Eaten!",
        },
        labels = {
            buc11_green_seal = "Green Seal",
        },
    },
}
