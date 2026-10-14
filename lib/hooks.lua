local MOD = SMODS.current_mod

MOD.calculate = function(self, context)
    if type(context) ~= "table" then return end
    if context.before then G.GAME.buc11_scoring_sevens = BUC11.count_scoring_sevens(context.scoring_hand) end
    if context.hand_drawn or context.setting_blind or context.end_of_round then G.GAME.buc11_scoring_sevens = nil end
    if context.end_of_round and context.main_eval and not context.individual and not context.repetition and not context.game_over then
        BUC11.reset_joke_template_suit()
    end
    if BUC11.install_post_refill_hook then BUC11.install_post_refill_hook() end
    if BUC11.install_blue_eor_hook then BUC11.install_blue_eor_hook() end
    if context.modify_shop_card and context.card and BUC11.modify_voucher_shop_playing_card then BUC11.modify_voucher_shop_playing_card(context.card) end
    if context.before and context.full_hand and BUC11.clear_blue_hand_state then BUC11.clear_blue_hand_state() end
    if context.individual and context.cardarea == G.play then
        local scored = context.other_card
        if scored and scored.seal == "Blue" and not scored.debuff and BUC11.queue_blue_return then BUC11.queue_blue_return(scored) end
    end
    if BUC11.install_green_seal_draw_hook then BUC11.install_green_seal_draw_hook() end
    if context.setting_blind and G and G.GAME then G.GAME.buc11_green_seal_pending = 0 end
    if context.end_of_round and G and G.GAME then G.GAME.buc11_green_seal_pending = 0 end
    if context.before and context.full_hand then BUC11.queue_green_seal_cards(context.full_hand, false) end
    if context.pre_discard and context.full_hand then BUC11.queue_green_seal_cards(context.full_hand, false) end
    if (context.setting_blind or context.end_of_round) and BUC11.clear_blue_hand_state then BUC11.clear_blue_hand_state() end
    return BUC11.calculate_blue_stack(context)
end

if BUC11.install_post_refill_hook then BUC11.install_post_refill_hook() end
if BUC11.install_blue_eor_hook then BUC11.install_blue_eor_hook() end
