function BUC11.replace_jokers_keep_rarity(jokers, sticker_removal_chance)
	if not jokers or #jokers == 0 then return end

	local replacements = {}


	for i, card in ipairs(jokers) do
		local rarity = card.config.center.rarity
		local pool = {}
		local src = G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[rarity] or G.P_CENTER_POOLS['Joker']


		for _, center in ipairs(src) do
			if center.key ~= card.config.center.key then
				pool[#pool + 1] = center
			end
		end

		local new_center = nil
		if #pool > 0 then
			new_center = pseudorandom_element(pool, pseudoseed('replace_joker' .. i))
		end


		local remove_stickers = pseudorandom('replace_sticker' .. i) < sticker_removal_chance



		replacements[i] = {
			card = card,
			center = new_center,
			remove_stickers = remove_stickers,
		}
	end


	for i, rep in ipairs(replacements) do
		if rep.center then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = i == 1 and 0 or 0.45,
				func = function()
					local card = rep.card


					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = i == 1 and 0.2 or 0.4,
						func = function()

							if card.remove_from_deck and type(card.remove_from_deck) == 'function' then
								pcall(card.remove_from_deck, card)
							end


							card:set_ability(rep.center, true)


							card:add_to_deck()


							if rep.remove_stickers then

								if card.ability then
									card.ability.perishable = nil
									card.ability.rental = nil
								end

								if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
									for _, k in ipairs(SMODS.Sticker.obj_buffer) do
										if card.ability and card.ability[k] then
											card.ability[k] = nil
										end
									end
								end
							end


							card:start_materialize()
							card:juice_up(0.5, 0.3)
							play_sound('card1', 1 + (i - 1) * 0.05, 0.6)
							return true
						end
					}))
					return true
				end
			}))
		end
	end
end

SMODS.Consumable({
    weight = 20,
    no_mod_badges = true,
    key = "rebirth",
    name = "Rebirth",
    set = "Spectral",
    discovered = false,
    atlas = "Consumables",
    pos = { x = 1, y = 0 },
    cost = 4,
    use = function(self, card, area, copier)
        BUC11.replace_jokers_keep_rarity(G.jokers.cards, 0.5)
    end,
    can_use = function(self, card)
        return G and G.jokers and #G.jokers.cards > 0
    end,
    demicoloncompat = true,
})
