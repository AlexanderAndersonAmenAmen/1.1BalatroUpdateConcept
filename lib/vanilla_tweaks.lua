local MOD = SMODS.current_mod

local function is_wild_card(card)
    if not card then return false end
    local center = card.config and card.config.center
    if center and center.key == "m_wild" then return true end
    if SMODS and type(SMODS.has_enhancement) == "function" then
        local ok, result = pcall(SMODS.has_enhancement, card, "m_wild")
        if ok and result then return true end
    end
    return false
end

local previous_set_debuff = MOD.set_debuff
MOD.set_debuff = function(card)
    if previous_set_debuff then
        local result = previous_set_debuff(card)
        if result ~= nil then return result end
    end
    local set = card and card.ability and card.ability.set
    if (set == "Default" or set == "Enhanced") and is_wild_card(card) then
        return "prevent_debuff"
    end
end

SMODS.Enhancement:take_ownership("wild", {
    no_mod_badges = true,
    any_suit = true,
    calculate = function(self, card, context)
        if context.stay_flipped and context.other_card == card then
            return { prevent_stay_flipped = true }
        end
    end,
}, true)

local rank_ids = {
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["10"] = 10,
    Jack = 11,
    Queen = 12,
    King = 13,
    Ace = 14,
}

local function boss_blind_active()
    return G and G.GAME and G.GAME.blind and G.GAME.blind.get_type and G.GAME.blind:get_type() == "Boss"
end

local function blind_score_met()
    if not (G and G.GAME and G.GAME.blind) then return false end
    local chips = G.GAME.chips
    local blind_chips = G.GAME.blind.chips
    if chips == nil or blind_chips == nil then return false end
    if type(to_big) == "function" then
        local ok, result = pcall(function()
            return to_big(chips) >= to_big(blind_chips)
        end)
        if ok then return result == true end
    end
    local ok, result = pcall(function()
        return chips >= blind_chips
    end)
    return ok and result == true
end

local function matador_active()
    local cards = G and G.jokers and G.jokers.cards
    if type(cards) ~= "table" then return false end
    for _, joker in ipairs(cards) do
        local center = joker and joker.config and joker.config.center
        if joker and not joker.debuff and center and center.key == "j_matador" then
            return true
        end
    end
    return false
end

function BUC11.matador_should_continue()
    if not (G and G.GAME and G.GAME.current_round and G.GAME.blind) then return false end
    if not G.GAME.blind.in_blind then return false end
    if not boss_blind_active() or not matador_active() or not blind_score_met() then return false end
    if (tonumber(G.GAME.current_round.hands_left) or 0) < 1 then return false end
    local hand_cards = G.hand and G.hand.cards or {}
    local deck_cards = G.deck and G.deck.cards or {}
    return #hand_cards > 0 or #deck_cards > 0
end

SMODS.Joker:take_ownership("matador", {
    no_mod_badges = true,
    blueprint_compat = false,
    config = { extra = 4 },
    loc_vars = function(self, info_queue, card)
        local dollars = card and card.ability and tonumber(card.ability.extra) or tonumber(self.config.extra) or 4
        return { vars = { dollars } }
    end,
    calculate = function(self, card, context)
        local dollars = tonumber(card.ability.extra) or 4
        if context.before and not context.blueprint then
            card.ability.buc11_matador_reward_this_hand = boss_blind_active() and blind_score_met()
        end
        if context.after and not context.blueprint then
            local reward = card.ability.buc11_matador_reward_this_hand
            card.ability.buc11_matador_reward_this_hand = false
            if reward then
                return BUC11.payout_dollars(dollars)
            end
        end
        if (context.setting_blind or context.end_of_round) and not context.blueprint then
            card.ability.buc11_matador_reward_this_hand = false
        end
    end,
}, true)

SMODS.Joker:take_ownership("idol", {
    no_mod_badges = true,
    blueprint_compat = true,
    config = { extra = { gain = 0.25, xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        local idol = G and G.GAME and G.GAME.current_round and G.GAME.current_round.idol_card or { rank = "Ace", suit = "Spades", id = 14 }
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local colour = G and G.C and G.C.SUITS and G.C.SUITS[idol.suit]
        return { vars = { extra.gain, localize(idol.rank, "ranks"), localize(idol.suit, "suits_plural"), extra.xmult, colours = { colour } } }
    end,
    calculate = function(self, card, context)
        local idol = G and G.GAME and G.GAME.current_round and G.GAME.current_round.idol_card
        if context.individual and context.cardarea == G.play and not context.blueprint and idol and context.other_card then
            local other = context.other_card
            local id = idol.id or rank_ids[idol.rank]
            if type(other.get_id) == "function" and type(other.is_suit) == "function" and other:get_id() == id and other:is_suit(idol.suit) then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
                return { message = localize("k_upgrade_ex"), colour = G.C.MULT }
            end
        end
        if context.joker_main and card.ability.extra.xmult > 1 then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}, true)

SMODS.Blind:take_ownership("serpent", {
    no_mod_badges = true,
    modifies_draw = true,
    calculate = function(self, blind, context)
        if context.drawing_cards and not (G and G.GAME and G.GAME.buc11_forced_bonus_draw) and G and G.GAME and G.GAME.current_round and G.hand and G.hand.config and ((G.GAME.current_round.hands_played or 0) ~= 0 or (G.GAME.current_round.discards_used or 0) ~= 0) then
            local hand_limit = tonumber(G.hand.config.card_limit) or 0
            local cards_in_hand = G.hand.cards and #G.hand.cards or 0
            local empty_slots = math.max(0, hand_limit - cards_in_hand)
            return { cards_to_draw = math.min(3, empty_slots, tonumber(context.amount) or 3) }
        end
    end,
}, true)

local function used_voucher(key)
    return G and G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers[key]
end

local function is_playing_card(card)
    local set = card and card.ability and card.ability.set
    return set == "Default" or set == "Enhanced"
end

local ILLUSION_EDITION_WEIGHTS = {
    { key = "e_foil", weight = 25 },
    { key = "e_holo", weight = 25 },
    { key = "e_polychrome", weight = 15 },
    { key = "e_negative", weight = 15 },
}

local function poll_illusion_edition()
    local available = {}
    local total_weight = 0
    for _, entry in ipairs(ILLUSION_EDITION_WEIGHTS) do
        if G and G.P_CENTERS and G.P_CENTERS[entry.key] then
            available[#available + 1] = entry
            total_weight = total_weight + entry.weight
        end
    end
    if total_weight <= 0 then return nil end
    local roll = pseudorandom("buc11_illusion_edition_type") * total_weight
    local cumulative = 0
    for _, entry in ipairs(available) do
        cumulative = cumulative + entry.weight
        if roll < cumulative then return entry.key end
    end
    return available[#available] and available[#available].key or nil
end

local function repair_shop_playing_card_ui(card, has_illusion)
    if not (card and G and G.E_MANAGER and Event) then return end
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0,
        blockable = false,
        func = function()
            if not (card.area == G.shop_jokers and is_playing_card(card)) then return true end
            if has_illusion and not card.buc11_illusion_edition_repolled then
                card.buc11_illusion_edition_repolled = true
                card:set_edition(nil, true, true)
                if SMODS and type(SMODS.pseudorandom_probability) == "function" and SMODS.pseudorandom_probability(card, "buc11_illusion_edition", 2, 5) then
                    local edition = poll_illusion_edition()
                    if edition then card:set_edition(edition, true, true) end
                end
            end
            if card.set_cost then card:set_cost() end
            if card.children and not card.children.buy_button and type(create_shop_card_ui) == "function" then
                if card.children.price and card.children.price.remove then
                    card.children.price:remove()
                    card.children.price = nil
                end
                local shop_type = card.ability and card.ability.set == "Enhanced" and "Enhanced" or "Base"
                create_shop_card_ui(card, shop_type, G.shop_jokers)
            end
            return true
        end,
    }))
end

function BUC11.modify_voucher_shop_playing_card(card)
    if not card or card.buc11_voucher_shop_processed or not is_playing_card(card) then return end
    if not used_voucher("v_magic_trick") then return end
    card.buc11_voucher_shop_processed = true
    local has_illusion = used_voucher("v_illusion")
    if card.config and card.config.center and card.config.center.key == "c_base" then
        local enhancement = SMODS.poll_enhancement({ key = "buc11_magic_trick_enhancement", guaranteed = true })
        if enhancement then
            local center = type(enhancement) == "string" and G.P_CENTERS and G.P_CENTERS[enhancement] or enhancement
            if center then card:set_ability(center, nil, false) end
        end
    end
    if has_illusion and not card.seal and SMODS and type(SMODS.pseudorandom_probability) == "function" and SMODS.pseudorandom_probability(card, "buc11_illusion_seal", 2, 5) then
        local seal = SMODS.poll_seal({ key = "buc11_illusion_seal_type", guaranteed = true })
        if seal then card:set_seal(seal, true, true) end
    end
    repair_shop_playing_card_ui(card, has_illusion)
end

local function is_glass_card(card)
    if not card then return false end
    if card.config and card.config.center and card.config.center.key == "m_glass" then return true end
    if SMODS and type(SMODS.has_enhancement) == "function" then
        local ok, result = pcall(SMODS.has_enhancement, card, "m_glass")
        if ok and result then return true end
    end
    return false
end

if Card and type(Card.calculate_joker) == "function" and not BUC11.glass_joker_removal_hooked then
    BUC11.glass_joker_removal_hooked = true
    local calculate_joker_ref = Card.calculate_joker
    Card.calculate_joker = function(self, context, ...)
        local temporarily_shattered = {}
        local center = self and self.config and self.config.center
        local matador_name
        if center and center.key == "j_matador" and self.ability then
            matador_name = self.ability.name
            self.ability.name = "BUC11 Matador"
        end
        if center and center.key == "j_glass" and context and context.remove_playing_cards and type(context.removed) == "table" then
            for _, removed in ipairs(context.removed) do
                if is_glass_card(removed) and not removed.shattered then
                    temporarily_shattered[#temporarily_shattered + 1] = { card = removed, value = removed.shattered }
                    removed.shattered = true
                end
            end
        end
        local result = calculate_joker_ref(self, context, ...)
        if matador_name then self.ability.name = matador_name end
        for _, entry in ipairs(temporarily_shattered) do entry.card.shattered = entry.value end
        return result
    end
end
