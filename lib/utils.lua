BUC11 = BUC11 or {}

function BUC11.payout_dollars(amount)
    if not (G and G.GAME) then return end
    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + amount
    return {
        dollars = amount,
        func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.dollar_buffer = 0
                    return true
                end,
            }))
        end,
    }
end

function BUC11.count_drawn_suit(cards, suit)
    if type(cards) ~= "table" then return 0 end
    local count = 0
    for _, playing_card in ipairs(cards) do
        if playing_card and not playing_card.debuff and type(playing_card.is_suit) == "function" and playing_card:is_suit(suit) then
            count = count + 1
        end
    end
    return count
end

function BUC11.threshold_gains(extra, amount)
    local threshold = tonumber(extra.cards_per_gain) or 1
    local before = tonumber(extra.cards_drawn) or 0
    local after = before + math.max(0, tonumber(amount) or 0)
    extra.cards_drawn = after
    return math.floor(after / threshold) - math.floor(before / threshold)
end

function BUC11.threshold_remaining(extra)
    local threshold = tonumber(extra.cards_per_gain) or 1
    local progress = (tonumber(extra.cards_drawn) or 0) % threshold
    return progress == 0 and threshold or threshold - progress
end

function BUC11.multiply_rarity_weight(context, rarity)
    if not (context and context.modify_weights and type(context.pool) == "table") then return end
    for _, entry in ipairs(context.pool) do
        local center = entry and entry.key and G and G.P_CENTERS and G.P_CENTERS[entry.key]
        if center and center.set == "Joker" and center.rarity == rarity then
            entry.weight = (tonumber(entry.weight) or 1) * 2
        end
    end
end
