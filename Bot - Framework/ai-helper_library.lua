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

HelperLibrary.enemy_magick = nil

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

HelperLibrary.spell_types = {
    barrier = "Barrier",
    mine = "Mine",
    beam = "Beam",
    shield = "Shield", -- may includes storms
    spray = "Spray",
    magick = "Magick",
    weapon = "Weapon",
    aoe = "Aoe",
    lightning = "Lightning",
    lightning_aoe = "LightningAoe",
    ward = "SelfShield",
}

---all available_magicks and their costs, used to pass into a new magick
HelperLibrary.available_magicks = {
    flame_tornado = {name = "magick_flame_tornado", slot = 1},
    charm = {name = "magick_charm", slot = 2},
    displace = {name = "magick_random_teleport", slot = 3},
    frost_bomb = {name = "magick_frost_bomb", slot = 2},
    natures_call = {name = "magick_natures_call", slot = 2},
    conflagration = {name = "magick_conflagration", slot = 2},
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

HelperLibrary.magick_mana_cost = {
    flame_tornado = 25,
    stone_prison = 25,
    teleport = 25,
    stasis = 25,
    midsummers_blessing = 25,
    haste = 25,
    charm = 50,
    frost_bomb = 50,
    tidal_wave = 50,
    natures_call = 50,
    conflagration = 50,
    tornado = 50,
    displace = 75,
    revive = 75,
    summon_death = 75,
    nullify = 75,
    geyser = 25,
    yellowstone = 75,
    dragonstrike = 75,
    mighty_hail = 100,
    thunderstorm = 100,
    raise_dead = 100,
    meteor_shower = 100,
}

HelperLibrary.bot_modes = {
    heal = "1",
    defend = "2",
    attack = "3",
    ["1"] = "heal",
    ["2"] = "defend",
    ["3"] = "attack",
}

HelperLibrary.minimum_duration = {
    magick = 0.02,
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
---This function is not tested, and may not work as intended
---@param ai_data any
---@return boolean
HelperLibrary.teleport_towards_target_is_valid = function(ai_data)
    local temp_target = MOVE_TOWARDS_POINT(ai_data.self_data.position_table, ai_data.target_unit_data.position_table, 8.25)
    local is_valid = HelperLibrary.map_point_is_valid(temp_target) and ai_data.bot_pathing:get_obstruction(temp_target) == " "
    return is_valid
end

--raycasting stuff
---returns a table of all the units obstructing the bot from the target player_id
---@param ai_data any
---@param player_id any
---@return table
HelperLibrary.get_player_obstructions = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return end
    return ai_data.player_data[player_id].obstructions
end
---returns true if there is something obstructing the bot from the target player_id
---does not scan for map objects/terrain
---@param ai_data any
---@param player_id any
---@return boolean
HelperLibrary.player_is_obstructed = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return false end
    return next(ai_data.player_data[player_id].obstructions) ~= nil
end
---returns a table of all the shield units obstructing the bot from the target player_id
---does not scan for map objects/terrain
---@param ai_data any
---@param player_id any
---@return table
HelperLibrary.get_player_shield_obstructions = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return end
    return ai_data.player_data[player_id].shield_obstructions
end
---returns true if there is a storm unit obstructing the bot from the target player_id
---does not scan for map objects/terrain
---@param ai_data any
---@param player_id any
---@return table
HelperLibrary.player_is_obstructed_by_storm = function(ai_data, player_id)
    if not ai_data.player_data then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return end
    if not ai_data.player_data[player_id] then printf("error, player data does not exist for player_id: %s", tostring(player_id)); return end
    return ai_data.player_data[player_id].obstructions.storm
end
---returns true if there is a shield unit obstructing the bot from the target player_id
---does not scan for map objects/terrain
---@param ai_data any
---@param player_id any
---@return boolean
HelperLibrary.player_blocked_by_shield = function(ai_data, player_id)
    local shield_obstructions = HelperLibrary.get_player_shield_obstructions(ai_data, player_id)
    if not shield_obstructions then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return false end
    if not shield_obstructions.shield then return false end
    return true
end
---returns true if there is a shield unit obstructing the bot from the target player_id
---does not scan for map objects/terrain
---@param ai_data any
---@param player_id any
---@return boolean
HelperLibrary.target_blocked_by_shield = function(ai_data)
    local player_id = ai_data.target_data.peer_id
    local shield_obstructions = HelperLibrary.get_player_shield_obstructions(ai_data, player_id)
    if not shield_obstructions then printf("NO PLAYERS - error, player data does not exist for player_id: %s", tostring(player_id)); return false end
    if not shield_obstructions.shield then return false end
    return true
end
---returns true if there is no shield between the target and the bot, and if the target is using a beam
HelperLibrary.player_needs_shield = function(ai_data)
    return ((not HelperLibrary.player_blocked_by_shield(ai_data, ai_data.target_unit_data.peer_id)) and ai_data.target_unit_data.spell_type == "Beam")
end

---returns the shield unit if the bot is obstructed by a shield unit in the direction it is facing
---does not consider any other units
HelperLibrary.shield_in_line_of_sight = function(ai_data)
    if ai_data.forward_shield_obstructions then
        if ai_data.forward_shield_obstructions.shield then
            return ai_data.forward_shield_obstructions.shield
        end
    end
    return false
end
--returns the ai_data.obstructions table
HelperLibrary.get_obstructions = function(ai_data)
    return ai_data.obstructions or {}
end
---returns the number of healing mines within a distance of 3 (dist <= 3) from the bot
HelperLibrary.count_healing_mines = function(ai_data)
    local obstructions = ai_data.obstructions or {}
    local healing_mine_count = 0

    if obstructions.mine then
        for key, mine in pairs(obstructions.mines) do
            --print("data for mine: " .. tostring(mine))
            if unit_utilities.unit_is_valid(mine) then
                local elements = Unit.get_data(mine, "mine_elements")
                --print("data for mine: " .. PAIRS_TO_STRING_ONE_LINE(elements))
                
                if elements.life >= 1 and unit_utilities.distance_between_units(mine, ai_data.bot_unit) <= 3 then
                    --print("data for mine has life!: " .. PAIRS_TO_STRING_ONE_LINE(elements))
                    healing_mine_count = healing_mine_count + 1
                end
            end
        end
    end

    return healing_mine_count
end
---returns the number of arcane mines within a distance of 3 (dist <= 3) from the bot
HelperLibrary.count_arcane_mines = function(ai_data)
    local obstructions = ai_data.obstructions or {}
    local arcane_mine_count = 0

    if obstructions.mine then
        for key, mine in pairs(obstructions.mines) do
            if unit_utilities.unit_is_valid(mine) then
                local elements = Unit.get_data(mine, "mine_elements")

                if elements.arcane >= 1 and unit_utilities.distance_between_units(mine, ai_data.bot_unit) <= 3 then
                    arcane_mine_count = arcane_mine_count + 1
                end
            end
        end
    end

    return arcane_mine_count
end
---returns the number of storms within a distance of 3 (dist <= 3) from the bot
HelperLibrary.count_storms = function(ai_data)
    local obstructions = ai_data.obstructions or {}
    local storm_count = 0

    if obstructions.storm then
        for key, storm in pairs(obstructions.storms) do
            if unit_utilities.unit_is_valid(storm) then
                --local elements = Unit.get_data(storm, "mine_elements")

                --if elements.life >= 1 and unit_utilities.distance_between_units(storm, ai_data.bot_unit) <= 2 then
                if unit_utilities.distance_between_units(storm, ai_data.bot_unit) <= 1.5 then
                    storm_count = storm_count + 1
                end
            end
        end
    end

    return storm_count
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

--ward stuff

---returns the ward the bot should use based on the target unit's spell
---may be configured for different
---includes basic warding, currently prioritizes earth ward
---@param ai_data any
---@return table
HelperLibrary.get_wanted_ward = function (ai_data)
    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
    local simple_spell = spell_utilities.spell_to_elements(target_data.spell) -- {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 3, empty = 0}
    local spell = spell_utilities.elements_to_spell(simple_spell) -- (table eg: {"fire","fire","fire"})
    local default_ward = {e,d,d}
    local wanted_ward = nil
    local current_ward = ai_data.self_data.ward
    local obstructions = HelperLibrary.get_obstructions(ai_data)
    local healing_mine_count = HelperLibrary.count_healing_mines(ai_data)
    local arcane_mine_count = HelperLibrary.count_arcane_mines(ai_data)

    -- if there are 3 or more healing mines stay in an earth ward
    if healing_mine_count >= 3 then
        return default_ward
    end

    -- if there are more arcane mines than healing mines change to eds/ses
    if arcane_mine_count > healing_mine_count then
        if ai_data.target_distance <= 5 then 
            return {s,e,d} 
        else
            return {s,e,s}
        end
    end

    -- check if the enemy spell is empty
    if #spell <= 0 then return default_ward end
    if #spell <= 1 then return default_ward end

    --ignore lightning if there is a storm already
    if HelperLibrary.player_is_obstructed_by_storm(ai_data, ai_data.target_data.peer_id) and (ai_data.target_unit_data.spell_type == HelperLibrary.spell_types.lightning_aoe or ai_data.target_unit_data.spell_type == HelperLibrary.spell_types.lightning) then
        return default_ward
    end

    -- steam ward if enemy is not in view
    if ai_data.target_blocked and ai_data.target_distance > 7 then return {e,f,q} end

    -- ignore if enemy is using a ward
    if target_data.spell_type == "SelfShield" then return default_ward end

    -- ignore if the spell is healing
    if simple_spell.life >= 1 then return default_ward end

    -- ignore if target using shield
    if simple_spell.shield == 1 and #spell <= 1 then return default_ward end

    -- check if target spell has shield and elements
    if simple_spell.shield == 1 and #spell >= 3 then wanted_ward = spell end

    -- ward a weapon
    if target_data.spell_type == "Weapon" then wanted_ward = GET_WEAPON_DAMAGE_TYPE(ai_data.target_unit_data.weapon); wanted_ward[1] = e end

    -- regular ward
    if simple_spell.shield <= 0 and #spell >= 1 then 
        table.insert(spell, 1, e)
        if spell[4] then spell[4] = nil end
        wanted_ward = spell
    end

    -- adjust ward if it is close to target (needs earth ward) and does not contain lightning
    if ai_data.target_distance <= 5 and (not spell_utilities.spell_contains(wanted_ward, a)) then
        spell[1] = d
    end

    --adjust other bad pairings of elements or if the enemy is using a spell with fewer than 3 elements
    while #spell <= 1 do
        for key, value in pairs(simple_spell) do
            if key ~= "shield" then
                value = value + 1
            end
        end
        wanted_ward = spell_utilities.elements_to_spell(simple_spell)
        print("enemy spell low element count adjusted: " .. PAIRS_TO_STRING_ONE_LINE(spell))
    end

    --make sure ward always has as least one shield element so it is valid
    if wanted_ward and (not spell_utilities.spell_contains(wanted_ward, e)) then wanted_ward[3] = e end

    return wanted_ward or default_ward  
end

--spell stuff
---returns number of similar elements between two spells
---allows you to ignore one element type
---@param elements_a any
---@param elements_b any
---@param ignore any
---@return integer
HelperLibrary.similar_elements = function(elements_a, elements_b, ignore)
    local simple_elements_a = CONVERT_TO_SIMPLE_SPELL(elements_a)
    local simple_elements_b = CONVERT_TO_SIMPLE_SPELL(elements_b)
    local similar_elements = 0
    ignore = ignore or "none"
    --water
    for element, element_count in pairs(simple_elements_a) do
        if ignore ~= element then
            if element_count > 0 and simple_elements_b[element] > 0 then
                local min_count = math.min(element_count, simple_elements_b[element])
                similar_elements = similar_elements + min_count
                --print_var(element .. " similar element difference count: " .. tostring(min_count))
            end
        end
    end
    --print_var("similar_elements %s a: %s b: %s ignoring: %s", tostring(similar_elements), TABLE_TO_STRING_ONE_LINE(elements_a), TABLE_TO_STRING_ONE_LINE(elements_b), ignore)
    return similar_elements
end

local get_closest_polygon_info = CaneNavmeshQuery.get_closest_polygon_info
local find_straight_path = CaneNavmeshQuery.find_straight_path
local raycast_closest_position = CaneNavmeshQuery.raycast_closest_position
local points_connected = CaneNavmeshQuery.points_connected
local box = Vector3Aux.box

--override poop throwing by paradox
--this may not work as intended
--please do not ask why this isn't in the pathing file
function _PathAux_get_closest_unobstructed_point(cane_navmeshquery, start_position, end_position)
	local search_extents = Vector3(0.5, 0.5, DISTANCE_POINT_OR_VECTOR(start_position, end_position) - 0.1)
	local nm_start_position, nm_start_height, nm_start_polyref = get_closest_polygon_info(cane_navmeshquery, start_position, search_extents)
	local nm_end_position, nm_end_height, nm_end_polyref = get_closest_polygon_info(cane_navmeshquery, end_position, search_extents)

	if nm_start_position and nm_end_position then
		local result, nm_closest_end_position, nm_closest_end_polyref = raycast_closest_position(cane_navmeshquery, nm_start_polyref, nm_start_position, nm_end_position)
        --print("Result: " .. tostring(result))
        if DISTANCE_POINT_OR_VECTOR(end_position, nm_closest_end_position) > 0.1 then
            return nm_closest_end_position
        else
            return nil
        end
	elseif nm_start_position ~= nil then
		local result, nm_closest_end_position, nm_closest_end_polyref = raycast_closest_position(cane_navmeshquery, nm_start_polyref, nm_start_position, end_position)
        --print("Result: " .. tostring(result))
        if DISTANCE_POINT_OR_VECTOR(end_position, nm_closest_end_position) > 0.1 then
            return nm_closest_end_position
        else
            return nil
        end
	else
		return nil
	end
end

---may not work as intended
---returns true if the target point is blocked by terrain
HelperLibrary.point_blocked_by_terrain = function(origin, target_point)
    origin[3] = 1
    target_point[3] = 1
    local closest_valid_point = _PathAux_get_closest_unobstructed_point(GLOBAL_CANE_NAVMESHQUERY, TO_VECTOR(origin), TO_VECTOR(target_point))

    if not closest_valid_point then return false end

    local distance_from_origin_to_valid_point = DISTANCE_POINT_OR_VECTOR(closest_valid_point, origin)
    local distance_from_target_to_valid_point = DISTANCE_POINT_OR_VECTOR(target_point, origin)

    if distance_from_origin_to_valid_point < distance_from_target_to_valid_point then
        return closest_valid_point
    end
    return false
end

---may not work as intended
---returns true if the target_unit point is blocked by terrain
HelperLibrary.target_blocked_by_terrain = function(ai_data)
    --queued_ability.move_target = VEC_TO_TABLE() or queued_ability.move_target
    local blocked = HelperLibrary.point_blocked_by_terrain(ai_data.self_data.position_table, HelperLibrary.get_target_unit_pos(ai_data))
    return blocked
end

---returns true if the target_unit is an ai unit
---@param ai_data any
---@return boolean
HelperLibrary.target_is_ai = function(ai_data)
    return ai_data.enemy_ai_units[1] == ai_data.target_unit
end

--yet another lerp implementation that I don't use
HelperLibrary.lerp = function(a, b, t)
    return a + (b - a) * t
end


local function player_killed()
    HelperLibrary.player_killed = true
end

local function player_death()
end

local function player_assist()
end

local function player_suicide()
end

local function team_kill()
end

local function unit_using_magick(context)
	local dt = context.dt
	local data = context.data
	local self_id = Network.peer_id()
	
	if not data then return end
	
	if data.owner_peer_id ~= self_id then 
        HelperLibrary.enemy_magick = data.last_magick
    end
	
	print(data.name .. " using magick: " .. data.last_magick)
end

local function player_sends_message(inc_stanza)
    local bot_unit_data = unit_utilities.get_unit_data(Network.peer_id())
    if inc_stanza.data.name ~= bot_unit_data.name then
    end
end

local function player_casts_magick(content)
    --"spell_magick", "player_casts_magick")
    print("hook found, player is casting magick:")
    --     data = { --table: 1BBF7BC0
    --     magick = magick_raise_dead,
    --     caster = [Unit '#ID[8564f3e856b50a2e]'],
    --     context_magick_activate_position table: 1BC29320 = {TABLE SELF REFERENCE, SKIPPING},
    --     caster_name = The Wizard of Oz,
    --     mtable table: 18FCE840 = {TABLE SELF REFERENCE, SKIPPING},
    --     player_extension table: 1901B6E0 = {TABLE SELF REFERENCE, SKIPPING},
    
    -- },
    local magick_data = content.data
    PRINT_TABLE(magick_data)
    if magick_data.player_extension.owner_peer_id ~= Network.peer_id() then
    end
end

--this is not tested
local function player_exits_magick(content)
    --"spell_magick", "player_casts_magick")
    print("hook found, player is exiting magick:")
    --     data = { --table: 1BBF7BC0
    --     magick = magick_raise_dead,
    --     caster = [Unit '#ID[8564f3e856b50a2e]'],
    --     context_magick_activate_position table: 1BC29320 = {TABLE SELF REFERENCE, SKIPPING},
    --     caster_name = The Wizard of Oz,
    --     mtable table: 18FCE840 = {TABLE SELF REFERENCE, SKIPPING},
    --     player_extension table: 1901B6E0 = {TABLE SELF REFERENCE, SKIPPING},
    
    -- },
    local magick_data = content.data
    PRINT_TABLE(magick_data)
    if magick_data.player_extension.owner_peer_id ~= Network.peer_id() then
        SIMPLE_DEBUG_TIMER(1, function() HelperLibrary.enemy_magick = magick_data end, {})
        SIMPLE_DEBUG_TIMER(3, function() HelperLibrary.enemy_magick = nil end, {})
    end
end

SE.event_handler.register_event("spell_magick", "player_casts_magick", "BotNecromancerBoss", player_casts_magick)
SE.event_handler.register_event("spell_magick", "player_exit_magick", "BotNecromancerBoss", player_exits_magick)

SE.event_handler.register_event("player_death", "kill", "BotNecromancerBoss", player_killed)
SE.event_handler.register_event("player_death", "assist", "BotNecromancerBoss", player_assist)
SE.event_handler.register_event("player_death", "suicide", "BotNecromancerBoss", player_suicide)
SE.event_handler.register_event("player_death", "team_kill", "BotNecromancerBoss", team_kill)
SE.event_handler.register_event("player_death", "death", "BotNecromancerBoss", player_death)
SE.event_handler.register_event("unit_functions", "unit_using_magick", "BotNecromancerBoss", unit_using_magick)
SE.event_handler.register_event("chat_system", "on_message", "BotNecromancerBoss", player_sends_message)

return HelperLibrary