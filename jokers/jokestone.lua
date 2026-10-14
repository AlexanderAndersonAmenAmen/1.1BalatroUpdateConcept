local jokestone_draw = function(self, card, context)
	if not (G and G.E_MANAGER and G.deck and G.deck.cards and G.hand) then return false end
	G.E_MANAGER:add_event(Event({
		trigger = "before",
		func = function()
			if not (G and G.deck and G.deck.cards and G.hand) then return true end
			local _cards = {}
			for i = 1, #G.deck.cards do
				local _card = G.deck.cards[i]
				if _card.ability.set == "Enhanced" and not _card.ability.buc11_drawing then
					_cards[#_cards + 1] = _card
				end
			end
			if #_cards > 0 then
				local cards_to_draw = {}
				for i = 1, card.ability.extra.draw do
					if _cards[i] then
						cards_to_draw[i] = _cards[i]
						cards_to_draw[i].ability.buc11_drawing = true
					end
				end
				card_eval_status_text(context and context.blueprint_card or card, "extra", nil, nil, nil, {
					message = localize("k_buc11_goldfish"),
					colour = G.C.PURPLE,
					instant = true,
				})
				for i = 1, #cards_to_draw do
					draw_card(G.deck, G.hand, nil, "up", true, cards_to_draw[i])
				end
				G.E_MANAGER:add_event(Event({
					trigger = "before",
					delay = 0.1,
					func = function()
						for i = 1, #cards_to_draw do
							cards_to_draw[i].ability.buc11_drawing = nil
						end


						if not (context and context.forcetrigger) and type(save_run) == "function" then save_run() end
						return true
					end,
				}))
			end
			return true
		end,
	}))
	return true
end

SMODS.Joker({
    weight = 20,
    no_mod_badges = true,
	key = "jokestone",
	atlas = "Jokers",
	pos = { x = 0, y = 2 },
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = {
		draw = 3,
	} },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw } }
	end,
	calculate = function(self, card, context)
		if (context.first_hand_drawn or context.forcetrigger)
			and G and G.deck and G.deck.cards and #G.deck.cards > 0
			and jokestone_draw(self, card, context)
		then
			return nil, true
		end
	end,
	attributes = { "enhancements" }
})
