local CIRCUS_TAG_EXCLUSIONS = {
    tag_boss = true,
    tag_juggle = true,
    tag_handy = true,
    tag_garbage = true,
    tag_speed = true,
    tag_investment = true,
}

local function poll_circus_tag(seed)
    local source_pool = get_current_pool("Tag") or {}
    local pool = {}
    for _, key in ipairs(type(source_pool) == "table" and source_pool or {}) do
        if key ~= "UNAVAILABLE" and not CIRCUS_TAG_EXCLUSIONS[key] and G and G.P_TAGS and G.P_TAGS[key] then
            pool[#pool + 1] = key
        end
    end
    if #pool == 0 then return Tag("tag_double") end
    local tag_key = pseudorandom_element(pool, pseudoseed(seed))
    if not tag_key then return Tag("tag_double") end
    local tag = Tag(tag_key)
    if tag_key == "tag_orbital" and tag and tag.ability then
        local available_hands = {}
        for key, hand in pairs(G and G.GAME and G.GAME.hands or {}) do
            if hand and hand.visible then available_hands[#available_hands + 1] = key end
        end
        if #available_hands > 0 then
            tag.ability.orbital_hand = pseudorandom_element(available_hands, pseudoseed(seed .. "_orbital"))
        end
    end
    return tag
end

SMODS.Back({
    no_mod_badges = true,
    key = "circus",
    atlas = "Enhancers",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = false,
    apply = function(self, back)
        G.GAME.buc11_circus_tags_created = false
    end,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and context.beat_boss and not G.GAME.buc11_circus_tags_created then
            G.GAME.buc11_circus_tags_created = true
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function()
                    for i = 1, 3 do
                        local tag = poll_circus_tag("buc11_circus_" .. tostring(i))
                        if tag then add_tag(tag) end
                    end
                    return true
                end,
            }))
        end
    end,
})
