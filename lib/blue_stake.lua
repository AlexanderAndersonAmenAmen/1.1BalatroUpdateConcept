SMODS.Stake:take_ownership("blue", {
    no_mod_badges = true,
    modifiers = function(self)
        G.GAME.modifiers.buc11_blue_stake = true
    end,
}, true)

local function ante()
    return G.GAME.round_resets.ante
end

local function is_showdown(center)
    return G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.buc11_blue_stake
        and center and center.boss and center.boss.showdown
end

local function compatible(effects, candidate, base)
    local combo = {}
    if base == "bl_final_vessel" and candidate == "bl_needle" then return false end
    for _, key in ipairs(effects) do combo[#combo + 1] = key end
    for _, key in ipairs(combo) do if key == candidate then return false end end
    return not BUC11.boss_combo_invalid(combo, candidate)
end

BUC11.blue_stack_compatible = compatible

function BUC11.blue_stack_record(center)
    if not is_showdown(center) then return nil end
    local record = G.GAME.buc11_blue_stack
    if record and record.ante == ante() and record.key == center.key then return record end
    local pool = {}
    for key in pairs(BUC11.BOSS_COMPONENTS) do
        local candidate = G.P_BLINDS[key]
        if key ~= "bl_ox" and key ~= "bl_arm" and key ~= "bl_tooth"
            and candidate and candidate.boss and not candidate.boss.showdown
            and (not candidate.boss.min or candidate.boss.min <= ante())
            and (not candidate.boss.max or candidate.boss.max >= ante())
            and (not G.GAME.banned_keys or not G.GAME.banned_keys[key])
            and (not candidate.in_pool or candidate:in_pool()) then
            pool[#pool + 1] = key
        end
    end
    table.sort(pool)
    record = { ante = ante(), key = center.key, effects = {}, states = {} }
    for slot = 1, 1 do
        local eligible = {}
        for _, key in ipairs(pool) do
            if compatible(record.effects, key, center.key) then eligible[#eligible + 1] = key end
        end
        if #eligible == 0 then break end
        local key = pseudorandom_element(eligible, pseudoseed("buc11_blue_" .. ante() .. "_" .. center.key .. "_" .. slot))
        record.effects[#record.effects + 1] = key
        record.states[key] = {}
    end
    G.GAME.buc11_blue_stack = record
    return record
end

local function active_effects(record)
    local effects = {}
    for _, key in ipairs(record.effects) do
        if not (record.disabled_effects and record.disabled_effects[key]) then
            effects[#effects + 1] = key
        end
    end
    return effects
end

function BUC11.blue_base_disabled(blind)
    local record = G and G.GAME and G.GAME.buc11_blue_stack
    return record and record.active and record.base_disabled
        and blind.config and blind.config.blind and blind.config.blind.key == record.key
end

local function live_record(blind)
    local record = G and G.GAME and G.GAME.buc11_blue_stack
    local center = blind and blind.config and blind.config.blind
    if record and record.active and not blind.disabled and center and center.key == record.key
        and record.ante == ante() then return record end
end

function BUC11.verdant_leaf_cleared(blind)
    local record = live_record(blind)
    return record and record.key == "bl_final_leaf" and (record.leaf_disabled or record.base_disabled) == true
end

function BUC11.disable_verdant_leaf_after_sale(blind, sold_card)
    local record = live_record(blind)
    if not record or record.key ~= "bl_final_leaf" then return false end
    if sold_card and sold_card.ability.name == "Luchador" then return true end
    if record.leaf_disabled or record.base_disabled then return true end
    record.leaf_disabled = true
    record.base_disabled = true
    for _, card in ipairs(G.playing_cards or {}) do blind:debuff_card(card) end
    blind:wiggle()
    return true
end

local function restore_debuff(blind, record)
    if record.debuff_snapshot then
        blind.debuff = blind.debuff or {}
        for _, field in ipairs({ "h_size_ge", "h_size_le", "hand" }) do
            local old = record.debuff_snapshot[field]
            blind.debuff[field] = old and old.value or nil
        end
    end
end

local function apply_debuff(blind, record)
    blind.debuff = blind.debuff or {}
    if not record.debuff_snapshot then
        record.debuff_snapshot = {}
        for _, field in ipairs({ "h_size_ge", "h_size_le", "hand" }) do
            record.debuff_snapshot[field] = { value = blind.debuff[field] }
        end
    end
    for _, key in ipairs(active_effects(record)) do
        local debuff = BUC11.BOSS_COMPONENTS[key].debuff
        for _, field in ipairs({ "h_size_ge", "h_size_le", "hand" }) do
            if debuff and debuff[field] ~= nil then blind.debuff[field] = debuff[field] end
        end
    end
end

function BUC11.stop_blue_stack(blind, disabled)
    if not (G and G.GAME and blind == G.GAME.blind) then return end
    local record = G and G.GAME and G.GAME.buc11_blue_stack
    if not (record and record.active) then return end
    record.active = false
    restore_debuff(blind, record)
    for _, key in ipairs(active_effects(record)) do
        local component = BUC11.BOSS_COMPONENTS[key]
        if component.calculate then
            component.calculate(record.states[key], blind, disabled and { blind_disabled = true } or { blind_defeated = true })
        end
    end
    if record.draw_override and SMODS.Blinds and SMODS.Blinds.modifies_draw then
        SMODS.Blinds.modifies_draw[record.key] = record.original_modifies_draw
    end
    record.draw_override = nil
end

local function install_draw_override(record)
    for _, key in ipairs(active_effects(record)) do
        if (key == "bl_fish" or key == "bl_serpent") and SMODS.Blinds and SMODS.Blinds.modifies_draw then
            if not record.draw_override then
                record.original_modifies_draw = SMODS.Blinds.modifies_draw[record.key]
                record.draw_override = true
            end
            SMODS.Blinds.modifies_draw[record.key] = true
        end
    end
end

function BUC11.start_blue_stack(blind, refresh)
    local center = blind.config and blind.config.blind
    local record = BUC11.blue_stack_record(center)
    if not record or blind.disabled then return end
    if center.key == "bl_final_vessel" and (not record.score_unit or refresh) then
        record.score_unit = blind.chips / 6
    end
    local already_active = record.active
    record.active = true
    install_draw_override(record)
    if not already_active then
        record.states = {}
        for _, key in ipairs(active_effects(record)) do
            local component = BUC11.BOSS_COMPONENTS[key]
            record.states[key] = {}
            if component.set_blind then component.set_blind(record.states[key]) end
            if component.calculate then component.calculate(record.states[key], blind, { setting_blind = true }) end
            if key == "bl_wall" then
                local added = blind.chips * (record.key == "bl_final_vessel" and 2 / 3 or 1)
                record.states[key].wall_added = added
                blind.chips = blind.chips + added
                blind.chip_text = number_format(blind.chips)
            end
        end
    elseif refresh then
        for _, key in ipairs(active_effects(record)) do
            if key == "bl_wall" then
                local added = blind.chips * (record.key == "bl_final_vessel" and 2 / 3 or 1)
                record.states[key].wall_added = added
                blind.chips = blind.chips + added
                blind.chip_text = number_format(blind.chips)
            end
        end
    end
    if record.base_disabled and record.key == "bl_final_vessel" and record.score_unit then
        local wall_active = false
        for _, key in ipairs(active_effects(record)) do
            if key == "bl_wall" then wall_active = true end
        end
        blind.chips = record.score_unit * (wall_active and 4 or 2)
        blind.chip_text = number_format(blind.chips)
    end
    apply_debuff(blind, record)
    for _, card in ipairs(G.playing_cards or {}) do blind:debuff_card(card) end
    blind.loc_name = BUC11.blue_stack_name(center, blind.loc_name)
    if blind.children and blind.children.animatedSprite then
        BUC11.attach_blue_stack_tooltip(blind.children.animatedSprite, center)
    end
    BUC11.attach_blue_stack_tooltip(blind, center, true)
end

function BUC11.calculate_blue_stack(context)
    local blind = G and G.GAME and G.GAME.blind
    local record = blind and live_record(blind)
    if not record or context.debuff_card or context.setting_blind
        or context.blind_disabled or context.blind_defeated then return end
    local combined
    for _, key in ipairs(active_effects(record)) do
        local component = BUC11.BOSS_COMPONENTS[key]
        if component.calculate then
            local result = component.calculate(record.states[key], blind, context)
            if result then
                combined = combined or {}
                for k, value in pairs(result) do combined[k] = value end
                if result.debuff then
                    combined.debuff_text = localize { type = "name_text", key = key, set = "Blind" }
                end
            end
        end
    end
    return combined
end

local debuff_ref = Blind.debuff_card
function Blind:debuff_card(card, ...)
    local result = debuff_ref(self, card, ...)
    local record = live_record(self)
    if record and card.area ~= G.jokers then
        for _, key in ipairs(active_effects(record)) do
            local component = BUC11.BOSS_COMPONENTS[key]
            local debuff = component.debuff
            local blocked = debuff and debuff.suit and card:is_suit(debuff.suit, true)
            if component.calculate then
                local effect = component.calculate(record.states[key], self, { debuff_card = card })
                blocked = blocked or effect and effect.debuff
            end
            if blocked then card:set_debuff(true) end
        end
    end
    return result
end

function BUC11.blue_stack_name(center, name)
    if is_showdown(center) and type(name) == "string" and not name:match("%+%d+$") then
        local record = BUC11.blue_stack_record(center)
        return name .. " +" .. tostring(record and #record.effects or 1)
    end
    return name
end

function BUC11.blue_stack_preview_amount(center, amount)
    local record = BUC11.blue_stack_record(center)
    for _, key in ipairs(record and record.effects or {}) do
        if key == "bl_wall" then return amount * (center.key == "bl_final_vessel" and 10 / 6 or 2) end
    end
    return amount
end

local function effect_box(key, disabled)
    local center = G.P_BLINDS[key]
    if not center then return end
    local vars = {}
    if key == "bl_wheel" then
        local n, d = SMODS.get_probability_vars(G.GAME.blind or center, 1, 7, "buc11_blue_wheel")
        vars = { n, d }
    elseif key == "bl_ox" then
        vars = { localize(G.GAME.current_round.most_played_poker_hand or "High Card", "poker_hands") }
    elseif center.loc_vars then
        local result = center:loc_vars()
        vars = result and result.vars or {}
    end
    local names = localize { type = "name", key = key, set = "Blind" }
    local description = {}
    localize { type = "descriptions", key = key, set = "Blind", nodes = description, vars = vars }
    local colour = disabled and G.C.JOKER_GREY or center.boss_colour or G.C.RED
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.025 },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm", minw = 3.45, maxw = 3.45,
                    padding = 0.055, r = 0.1,
                    colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.05,
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm", minw = 3.3, maxw = 3.3,
                            padding = 0.07, r = 0.08,
                            colour = adjust_alpha(darken(colour, 0.2), 0.96),
                        },
                        nodes = {
                            name_from_rows(names),
                            desc_from_rows(description),
                        },
                    },
                },
            },
        },
    }
end

function BUC11.blue_stack_tooltip(center)
    local record = BUC11.blue_stack_record(center)
    if not record then return end
    local nodes = {}
    nodes[#nodes + 1] = effect_box(center.key, record.base_disabled)
    for _, key in ipairs(record.effects) do nodes[#nodes + 1] = effect_box(key, record.disabled_effects and record.disabled_effects[key]) end
    return { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR, padding = 0.04 }, nodes = nodes }
end

function BUC11.clear_blue_stack_tooltip(sprite)
    if not sprite then return end
    if sprite.buc11_stack_hover then
        sprite.hover = sprite.buc11_stack_native_hover
        sprite.stop_hover = sprite.buc11_stack_native_stop
        sprite.buc11_stack_hover = nil
        sprite.buc11_stack_native_hover = nil
        sprite.buc11_stack_native_stop = nil
        sprite.hovering = false
        if sprite.config then
            sprite.config.h_popup = nil
            sprite.config.h_popup_config = nil
        end
    end
    if sprite.children and sprite.children.buc11_stack_badge then
        sprite.children.buc11_stack_badge:remove()
        sprite.children.buc11_stack_badge = nil
    end
end

function BUC11.attach_blue_stack_tooltip(sprite, center, no_badge)
    if not sprite then return end
    local record = BUC11.blue_stack_record(center)
    if not record then BUC11.clear_blue_stack_tooltip(sprite); return end
    if not sprite.buc11_stack_hover then
        sprite.buc11_stack_native_hover = sprite.hover
        sprite.buc11_stack_native_stop = sprite.stop_hover
        sprite.buc11_stack_hover = true
    end
    sprite.config = sprite.config or {}
    sprite.config.buc11_stack_key = center.key
    sprite.config.buc11_stack_ante = record.ante
    sprite.states.hover.can = true
    sprite.states.collide.can = true
    sprite.config.force_focus = true
    sprite.hover = function(self)
        if self.config.buc11_stack_ante ~= ante() then BUC11.clear_blue_stack_tooltip(self); return end
        if (not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch)
            and not self.hovering and self.states.visible then
            self.hovering = true
            self.hover_tilt = 3
            self.config.h_popup = BUC11.blue_stack_tooltip(G.P_BLINDS[self.config.buc11_stack_key])
            self.config.h_popup_config = { align = "cr", offset = { x = 0.1, y = 0 }, parent = self }
            Node.hover(self)
        end
    end
    sprite.stop_hover = function(self)
        self.hovering = false
        self.hover_tilt = 0
        Node.stop_hover(self)
        self.config.h_popup = nil
    end

end

local set_blind_ref = Blind.set_blind
function Blind:set_blind(center, reset, silent, ...)
    if not (G and G.GAME and self == G.GAME.blind) then return set_blind_ref(self, center, reset, silent, ...) end
    local record = G and G.GAME and G.GAME.buc11_blue_stack
    local incoming = center or self.config and self.config.blind
    if record and record.active and (record.ante ~= ante() or not incoming or incoming.key ~= record.key) then
        BUC11.stop_blue_stack(self, false)
    end
    BUC11.clear_blue_stack_tooltip(self)
    if self.children and self.children.animatedSprite then BUC11.clear_blue_stack_tooltip(self.children.animatedSprite) end
    local result = set_blind_ref(self, center, reset, silent, ...)
    if is_showdown(self.config and self.config.blind) then BUC11.start_blue_stack(self, center == nil or reset) end
    return result
end

local set_text_ref = Blind.set_text
function Blind:set_text(...)
    local result = set_text_ref(self, ...)
    self.loc_name = BUC11.blue_stack_name(self.config and self.config.blind, self.loc_name)
    return result
end

local disable_ref = Blind.disable
function Blind:disable(...)
    local record = live_record(self)
    BUC11.stop_blue_stack(self, true)
    local result = disable_ref(self, ...)
    if record and record.key == "bl_final_vessel" and record.score_unit then
        self.chips = record.score_unit * 2
        self.chip_text = number_format(self.chips)
    end
    return result
end

function BUC11.luchador_disable_one(blind)
    local record = live_record(blind)
    if not record then return false end
    local options = active_effects(record)
    if not record.base_disabled and not record.leaf_disabled then
        options[#options + 1] = record.key
    end
    if #options == 0 then return true end
    local selected = pseudorandom_element(options, pseudoseed("buc11_luchador"))
    if selected == record.key then
        record.base_disabled = true
        disable_ref(blind)
        blind.disabled = false
        if record.key == "bl_final_vessel" and record.score_unit then
            local wall_active = false
            for _, key in ipairs(active_effects(record)) do
                if key == "bl_wall" then wall_active = true end
            end
            blind.chips = record.score_unit * (wall_active and 4 or 2)
            blind.chip_text = number_format(blind.chips)
        end
    else
        local component = BUC11.BOSS_COMPONENTS[selected]
        if component.calculate then
            component.calculate(record.states[selected], blind, { blind_disabled = true })
        end
        record.disabled_effects = record.disabled_effects or {}
        record.disabled_effects[selected] = true
        restore_debuff(blind, record)
        apply_debuff(blind, record)
        if record.draw_override and SMODS.Blinds and SMODS.Blinds.modifies_draw then
            SMODS.Blinds.modifies_draw[record.key] = record.original_modifies_draw
            record.draw_override = nil
        end
        install_draw_override(record)
    end
    if record.base_disabled and #active_effects(record) == 0 then
        blind:disable()
    else
        for _, card in ipairs(G.playing_cards or {}) do blind:debuff_card(card) end
        for _, card in ipairs(G.jokers.cards or {}) do blind:debuff_card(card) end
        blind:set_text()
        blind:wiggle()
    end
    return true
end

local defeat_ref = Blind.defeat
function Blind:defeat(...)
    BUC11.stop_blue_stack(self, false)
    return defeat_ref(self, ...)
end

local load_ref = Blind.load
function Blind:load(...)
    local result = load_ref(self, ...)
    local record = live_record(self)
    if record then
        install_draw_override(record)
        apply_debuff(self, record)
        self.loc_name = BUC11.blue_stack_name(self.config.blind, self.loc_name)
        BUC11.attach_blue_stack_tooltip(self, self.config.blind, true)
        if self.children and self.children.animatedSprite then
            BUC11.attach_blue_stack_tooltip(self.children.animatedSprite, self.config.blind)
        end
    end
    return result
end
