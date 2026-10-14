local menu_builder = create_UIBox_main_menu_buttons
if type(menu_builder) == "function" then
    local index = 1
    while true do
        local name, value = debug.getupvalue(menu_builder, index)
        if not name then break end
        if name == "create_UIBox_main_menu_buttonsRef" and type(value) == "function" then
            create_UIBox_main_menu_buttons = value
            break
        end
        index = index + 1
    end
end

local function steamodded_text(value)
    if type(value) == "string" then
        local text = value:lower():gsub("%s+", "")
        return text:find("steamodded", 1, true) ~= nil
            or text:find("steammodded", 1, true) ~= nil
    end
    if type(value) == "table" then
        for _, part in ipairs(value) do
            if steamodded_text(part) then return true end
        end
        return steamodded_text(value.string)
    end
    return false
end

local function contains_version(node, seen)
    if type(node) ~= "table" or seen[node] then return false end
    seen[node] = true
    local config = node.config or {}
    if steamodded_text(config.text) then return true end
    if config.ref_table and config.ref_value
        and steamodded_text(config.ref_table[config.ref_value]) then
        return true
    end
    local object = config.object
    if object and object.config and steamodded_text(object.config.string) then
        return true
    end
    for _, child in pairs(node.nodes or {}) do
        if contains_version(child, seen) then return true end
    end
    for _, child in pairs(node.children or {}) do
        if contains_version(child, seen) then return true end
    end
    return false
end

local function is_version_box(box)
    if not (G and G.STAGES and G.STAGE == G.STAGES.MAIN_MENU) then return false end
    local align = box.config and box.config.align
        or box.alignment and box.alignment.type
    if align ~= "tri" then return false end
    return contains_version(box.definition, {}) or contains_version(box.UIRoot, {})
end

local ui_box_draw = UIBox.draw
function UIBox:draw(...)
    if is_version_box(self) then return end
    return ui_box_draw(self, ...)
end

local game_draw = Game.draw
function Game:draw(...)
    if G and G.STAGES and G.STAGE == G.STAGES.MAIN_MENU and G.I and G.I.UIBOX then
        for index = #G.I.UIBOX, 1, -1 do
            local box = G.I.UIBOX[index]
            if box and is_version_box(box) then box:remove() end
        end
    end
    return game_draw(self, ...)
end
