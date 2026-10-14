BUC11 = BUC11 or {}

local blue_return_pending = {}
local blue_return_seen = {}
local post_refill_hook_installed = false
local blue_eor_hook_installed = false

function BUC11.queue_blue_return(card)
    if not card or blue_return_seen[card] then return end
    blue_return_seen[card] = true
    blue_return_pending[#blue_return_pending + 1] = card
end

function BUC11.clear_blue_hand_state()
    blue_return_pending = {}
    blue_return_seen = {}
end

function BUC11.install_post_refill_hook()
    if post_refill_hook_installed then return true end
    if not (G and G.FUNCS and type(G.FUNCS.draw_from_deck_to_hand) == "function") then return false end
    local draw_from_deck_to_hand_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        local returning = {}
        if G and G.STATE == G.STATES.DRAW_TO_HAND and #blue_return_pending > 0 then
            returning = blue_return_pending
            blue_return_pending = {}
        end
        local result = draw_from_deck_to_hand_ref(e)
        if #returning > 0 and G and G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.05,
                func = function()
                    if not G.hand then return true end
                    local valid = {}
                    for _, card in ipairs(returning) do
                        if card and card.seal == "Blue" and not card.shattered and card.area and card.area ~= G.hand then valid[#valid + 1] = card end
                    end
                    for i, card in ipairs(valid) do
                        local from = card.area
                        if from and from.cards then draw_card(from, G.hand, i * 100 / #valid, "up", true, card) end
                    end
                    return true
                end,
            }))
        end
        return result
    end
    post_refill_hook_installed = true
    return true
end

function BUC11.install_blue_eor_hook()
    if blue_eor_hook_installed then return true end
    if not (Card and type(Card.get_end_of_round_effect) == "function") then return false end
    local get_end_of_round_effect_ref = Card.get_end_of_round_effect
    Card.get_end_of_round_effect = function(self, ...)
        if self and self.seal == "Blue" then
            local seal = self.seal
            self.seal = nil
            local result = get_end_of_round_effect_ref(self, ...)
            self.seal = seal
            return result
        end
        return get_end_of_round_effect_ref(self, ...)
    end
    blue_eor_hook_installed = true
    return true
end
