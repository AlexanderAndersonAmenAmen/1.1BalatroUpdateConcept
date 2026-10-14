BUC11 = BUC11 or {}

local function reveal_one_punchline_card(card)
    card.facing = 'front'
    card.sprite_facing = 'front'
    card.flipping = nil
    if card.pinch then card.pinch.x = false end
    if card.ability then card.ability.wheel_flipped = nil end
end

function BUC11.install_one_punchline_face_hook()
    if BUC11._one_punchline_face_hook_version == 3 then return true end
    if not (Card and type(Card.update) == 'function' and CardArea
        and type(CardArea.emplace) == 'function') then return false end
    local emplace_ref = CardArea.emplace
    CardArea.emplace = function(self, card, location, stay_flipped)
        if card and G and self == G.discard and G.GAME
            and card == G.GAME.buc11_one_punchline_pending
            and BUC11.finish_one_punchline_return(card) then
            return
        end
        if card and card.buc11_one_punchline_returned and G
            and self == G.discard and (card.area == G.deck or card.area == G.hand) then
            return
        end
        local result = emplace_ref(self, card, location, stay_flipped)
        if card and G and G.GAME and self == G.hand
            and G.GAME.buc11_one_punchline_next_draw == card then
            G.GAME.buc11_one_punchline_next_draw = nil
        end
        if card and card.buc11_one_punchline_needs_reveal and G and self == G.hand then
            card.buc11_one_punchline_needs_reveal = nil
            if not stay_flipped then
                card.buc11_one_punchline_reveal_time = 1.5
                reveal_one_punchline_card(card)
            end
        end
        return result
    end
    local update_ref = Card.update
    Card.update = function(self, dt, ...)
        local result = update_ref(self, dt, ...)
        if self.buc11_one_punchline_needs_reveal and G and self.area == G.hand then
            self.buc11_one_punchline_needs_reveal = nil
            if not (self.ability and self.ability.wheel_flipped) then
                self.buc11_one_punchline_reveal_time = 1.5
            end
        end
        if self.buc11_one_punchline_reveal_time then
            if G and self.area == G.hand then
                reveal_one_punchline_card(self)
                self.buc11_one_punchline_reveal_time = self.buc11_one_punchline_reveal_time - (dt or 0)
                if self.buc11_one_punchline_reveal_time <= 0 then
                    self.buc11_one_punchline_reveal_time = nil
                end
            else
                self.buc11_one_punchline_reveal_time = nil
            end
        end
        return result
    end
    BUC11._one_punchline_face_hook_installed = true
    BUC11._one_punchline_face_hook_version = 3
    return true
end

function BUC11.install_one_punchline_draw_hook()
    if BUC11._one_punchline_draw_hook_version == 2 then return true end
    if not (G and G.FUNCS and type(G.FUNCS.draw_from_deck_to_hand) == 'function') then
        return false
    end
    local draw_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(...)
        BUC11.finish_one_punchline_return(nil, true)
        return draw_ref(...)
    end
    BUC11._one_punchline_draw_hook_installed = true
    BUC11._one_punchline_draw_hook_version = 2
    return true
end

function BUC11.finish_one_punchline_return(detached_card, before_refill)
    if not (G and G.GAME and G.deck) then return false end
    local target = G.GAME.buc11_one_punchline_pending
    if not target then return false end
    if target.removed or target.REMOVED or target.shattered or target.buc11_mined then
        G.GAME.buc11_one_punchline_pending = nil
        return false
    end
    if detached_card ~= target and not before_refill then return false end

    local from = target.area
    if from and from ~= G.play and from ~= G.discard then return false end
    local in_area = false
    if from then
        for _, other in ipairs(from.cards or {}) do
            if other == target then in_area = true; break end
        end
    end
    if in_area then
        if from:remove_card(target) ~= target then return false end
    elseif detached_card ~= target then
        return false
    end

    G.GAME.buc11_one_punchline_pending = nil
    target.buc11_one_punchline_returning = nil
    target.buc11_one_punchline_reveal_time = nil

    if target.ability then target.ability.wheel_flipped = nil end
    if target.facing == 'front' then target:flip() end
    target.buc11_one_punchline_returned = true
    G.GAME.buc11_one_punchline_next_draw = target
    G.deck:emplace(target)

    if G.deck.cards[1] == target and #G.deck.cards > 1 then
        table.remove(G.deck.cards, 1)
        table.insert(G.deck.cards, target)
        G.deck:set_ranks()
        G.deck:align_cards()
    end

    if target.states and target.states.collide then
        target.states.collide.can = false
    end
    target.buc11_one_punchline_needs_reveal = true
    return true
end

SMODS.Joker({
    weight = 20,
    no_mod_badges = true,
    key = "one_punchline_man",
    atlas = "Jokers",
    pos = { x = 3, y = 1 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        BUC11.install_one_punchline_face_hook()
        BUC11.install_one_punchline_draw_hook()
        if context.after and not context.blueprint and context.scoring_hand and context.scoring_hand[1] then
            local target = context.scoring_hand[1]
            if target.area == G.play and not target.buc11_one_punchline_returning
                and not G.GAME.buc11_one_punchline_pending then
                target.buc11_one_punchline_returning = true
                G.GAME.buc11_one_punchline_pending = target
            end
        end
        if context.drawing_cards and not context.blueprint then
            BUC11.finish_one_punchline_return(nil, true)
        end
    end,
    attributes = { "hands", "deck_manipulation" }
})

BUC11.install_one_punchline_face_hook()
BUC11.install_one_punchline_draw_hook()
