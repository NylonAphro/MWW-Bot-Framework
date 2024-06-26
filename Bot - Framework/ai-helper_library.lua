local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities
local pathing = require("ai/pathing")

HelperLibrary = {}

--define elements for ease of use
local q = "water"
local w = "life"
local e = "shield"
local r = "cold"
local a = "lightning"
local s = "arcane"
local d = "earth"
local f = "fire"

---returns a new table of the given spell keys combo
---names are defined by the default keys to press 
---in order of qwer asdf eg: qfq will be qqf in the lookup table
HelperLibrary.spells = {
    ---@return table 
    qqq = function() return {q,q,q} end,
    www = function() return {w,w,w} end,
    e = function() return {e} end,
    rrr = function() return {r,r,r} end,
    aaa = function() return {a,a,a} end,
    sss = function() return {s,s,s} end,
    ddd = function() return {d,d,d} end,
    fff = function() return {f,f,f} end,

    --healing
    qwe = function() return {q,w,e} end,
    we = function() return {w,e} end,
    wwe = function() return {w,w,e} end,
    wed = function() return {w,e,d} end,
    wea = function() return {w,e,a} end,
    wef = function() return {w,e,f} end,

    --aoe
    ssf = function() return {s,s,f} end,
}

---Not really made use of
HelperLibrary.elements = {
    q = "water",
    w = "life",
    e = "shield",
    r = "cold",
    a = "lightning",
    s = "arcane",
    d = "earth",
    f = "fire"
}

---all available_magicks and their costs, used to pass into a new magick
HelperLibrary.available_magicks = {
    flame_tornado = {name = "magick_flame_tornado", slot = 1},
    charm = {name = "magick_charm", slot = 2},
    displace = {name = "magick_random_teleport", slot = 3},
    frost_bomb = {name = "magick_frost_bomb", slot = 2},
    natures_call = {name = "magick_natures_call", slot = 2},
    magick_conflagration = {name = "magick_conflagration", slot = 2},
    meteor_shower = {name = "magick_meteor_shower", slot = 4},
    stasis = {name = "magick_stasis", slot = 1},
    revive = {name = "magick_revive_target_area", slot = 3},
    stone_prison = {name = "magick_stone_prison", slot = 1},
    teleport = {name = "magick_teleport", slot = 1},
    tornado = {name = "magick_tornado", slot = 2},
    summon_death = {name = "magick_summon_death", slot = 3},
    midsummers_blessing = {name = "magick_heal_totem", slot = 1},
    thunderstorm = {name = "magick_thunderstorm", slot = 4},
    nullify = {name = "magick_nullify", slot = 3},
    mighty_hail = {name = "magick_mighty_hail", slot = 4},
    geyser = {name = "magick_geyser", slot = 1},
    haste = {name = "magick_haste", slot = 1},
    yellowstone = {name = "magick_yellowstone", slot = 3},
    raise_dead = {name = "magick_raise_dead", slot = 4},
    dragonstrike = {name = "magick_napalm", slot = 3},
    tidal_wave = {name = "magick_tidal_wave", slot = 2},
}

--unit helpers
HelperLibrary.unit_is_wet = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.status.wet
end
HelperLibrary.unit_is_burning = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.status.burning
end
HelperLibrary.unit_is_chilled = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.status.chilled
end
HelperLibrary.get_unit_chill_level = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.status.chill_level
end
HelperLibrary.unit_is_frozen = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.status.frozen
end
HelperLibrary.unit_is_knocked_down = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.state == "knocked_down"
end
HelperLibrary.unit_is_pushed = function(unit)
    local char_ext = EntityAux.extension(unit, "character")
    return char_ext.input.pushed
end

--target unit stuff
HelperLibrary.get_target_unit_pos = function(ai_data)
    return VEC_TO_TABLE(unit_utilities.get_unit_position(ai_data.target_unit)) or ai_data.self_data.position_table
end
HelperLibrary.get_unit_pos_and_facing = function(input_unit)
    return unit_utilities.get_unit_position(input_unit) + unit_utilities.get_unit_forward(input_unit)
end

--facing manipulation
HelperLibrary.face_away_from_target = function(ai_data)
    local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
    --local self_facing = unit_utilities.get_unit_forward(ai_data.bot_unit)
    local target_unit_position = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
    return VEC_TO_TABLE(MOVE_AWAY_FROM_POINT(self_position, target_unit_position, 2))
end

--pathing
HelperLibrary.map_point_is_valid = function(point)
    return pathing:cane_mesh_valid_pos(point)
end

--raycasting stuff
HelperLibrary.get_player_obstructions = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return end
    return ai_data.player_data[player_id].obstructions
end
HelperLibrary.player_is_obstructed = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return false end
    return next(ai_data.player_data[player_id].obstructions) ~= nil
end
HelperLibrary.get_player_shield_obstructions = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return end
    return ai_data.player_data[player_id].shield_obstructions
end
HelperLibrary.player_is_obstructed_by_shield = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return end
    return next(ai_data.player_data[player_id].shield_obstructions) ~= nil
end
HelperLibrary.player_blocked_by_shield = function(ai_data, player_id)
    local shield_obstructions = HelperLibrary.get_player_shield_obstructions(ai_data, player_id)
    if not shield_obstructions then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return false end
    if not shield_obstructions.shield then return false end
    return shield_obstructions.shield
end
HelperLibrary.shield_in_line_of_sight = function(ai_data)
    if ai_data.forward_shield_obstructions then
        if ai_data.forward_shield_obstructions.shield then
            return ai_data.forward_shield_obstructions.shield
        end
    end
    return false
end

--bot stuff
HelperLibrary.bot_is_pushed = function(ai_data)
    return HelperLibrary.unit_is_pushed(ai_data.bot_unit)
end
HelperLibrary.bot_is_knocked_down = function(ai_data)
    return HelperLibrary.unit_is_knocked_down(ai_data.bot_unit)
end
HelperLibrary.get_weapon_charge_time = function(unit)
    local unit_data = unit_utilities.get_unit_data_from_unit(unit)
    return unit_data.weapon_chargeup_time + 0.1
end
HelperLibrary.get_bot_focus = function(ai_data)
    return ai_data.self_data.focus
end

return HelperLibrary