local rank_ids = { ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["10"] = 10, Jack = 11, Queen = 12, King = 13, Ace = 14 }
local rank_pool = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace" }

local function card_matches_rank(card, rank)
    return card and type(card.get_id) == "function" and card:get_id() == rank_ids[rank]
end

local function article_for_rank(rank)
    if rank == "Ace" or rank == "8" then return "an" end
    return "a"
end

local function current_dark_idol_rank()
    if G and G.GAME and G.GAME.current_round and G.GAME.current_round.buc11_dark_idol_rank then return G.GAME.current_round.buc11_dark_idol_rank end
    return "Ace"
end

local function set_dark_idol_rank()
    if not (G and G.GAME and G.GAME.current_round) then return end
    local ante = G.GAME.round_resets and G.GAME.round_resets.ante or 0
    local round = G.GAME.round or 0
    local token = tostring(ante) .. ":" .. tostring(round)
    if G.GAME.current_round.buc11_dark_idol_rank_token == token then return end
    G.GAME.current_round.buc11_dark_idol_rank_token = token
    G.GAME.current_round.buc11_dark_idol_rank = pseudorandom_element(rank_pool, pseudoseed("buc11_dark_idol_" .. token))
end

SMODS.Joker({
    weight = 20,
    no_mod_badges = true,
    key = "dark_idol",
    atlas = "Jokers",
    pos = { x = 2, y = 0 },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { gain = 2, mult = 0 } },
    loc_vars = function(self, info_queue, card)
        local rank = current_dark_idol_rank()
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { article_for_rank(rank), localize(rank, "ranks"), extra.gain, extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and context.main_eval and not context.blueprint then set_dark_idol_rank() end
        if context.hand_drawn and type(context.hand_drawn) == "table" and not context.blueprint then
            local rank = current_dark_idol_rank()
            local count = 0
            for _, drawn in ipairs(context.hand_drawn) do if card_matches_rank(drawn, rank) then count = count + 1 end end
            if count > 0 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain * count
                return { message = localize("k_upgrade_ex"), colour = G.C.MULT }
            end
        end
        if context.joker_main and card.ability.extra.mult > 0 then return { mult = card.ability.extra.mult } end
    end,
})
