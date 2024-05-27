---@meta

--Player/peer data
function GET_PLAYER_MAGICK(player_data) end

function PRINT_UNIT_DATA() end

---MWWSE
---@param unit unit
---@return string
---returns peer_id given unit
function GET_UNIT_OWNER(unit) end

---MWWSE
---@param unit unit
---@return boolean
---returns true if given unit is valid (not nil)
function VALID_UNIT(unit) end

---MWWSE
---@param unit unit
---@return boolean
---returns true if given unit has health_extension & health > 0
function UNIT_IS_ALIVE(unit) end

---MWWSE
---@param unit unit|nil
---@return Vector3
---returns position of given unit
function GET_UNIT_POS(unit) end

---MWWSE
---@param unit_a unit
---@param unit_b unit
---@return integer
---returns distance between two units
function DISTANCE_UNIT(unit_a, unit_b) end

---MWWSE
---@param unit unit
---@return string
---returns unit state (eg onground, knocked_down, etc...)
function GET_UNIT_STATE(unit) end

---MWWSE
---@param unit unit
---@return table
---returns table of player status (eg status_.burning, status_.wet etc...)
function GET_UNIT_STATUS(unit) end

--get window
---MWWSE
---unit a is (usually the bot's perspective)
---unit b is the unit in question
---window is the bot window to the target unit in 360 degrees
---self_window is the target
---@param unit_a any
---@param unit_b any
---@return table
function GET_UNIT_WINDOW(unit_a, unit_b) end

    -- Calculate the speed (distance per second)
---MWWSE
---@param input_unit unit
---@return table
---returns data table of all units dat
--data.name (steam name)
--data.owner_peer_id peer id
--data.position (position as Vector3)
--data.position_table (position eg: {0,0,0})
--data.status
--data.state
--data.health
--data.max_health
--data.health_p (health %)
--data.team
--data.forward (forward facing Vector)
--data.simple_spell (eg: {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0})
--data.spell_type (eg: Beam, Spray, etc)
--data.spell (table eg: {"fire","fire","fire"})
--data.charge_time
--data.overcharged_time
--data.ward (eg: {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0})
--data.ward_elements (table eg: {"shield","fire","fire"})
--data.new_cast = nil or true
--data.focus
--data.inventory
--data.robe_unit
--data.angle (forward facing angle in degrees)
--data.unit = unit self reference
--data.extension_data = units character extension table
--data.selected_elements = simple_spell version of queued_elements (eg: {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0})
--data.queued_elements = regular tablew version of queued_elements (table eg: {"shield","fire","fire"})
function DECODE_UNIT(owner_peer_id, input_unit, dt) end

-- returns a players name given player id
function ID_TO_NAME(id_) end

-- returns a players name given player id
function ID_TO_UNIT(id_) end

-- returns a players name given player id
function NAME_TO_ID(name_) end

---MWWSE
---@return table
---Returns list of peers in current game session
function GET_PEER_LIST() end

---MWWSE
---@return table
---returns list of steam names of peers in current game session
function GET_PLAYER_LIST() end

---MWWSE
---@return table
---returns list of steam names of peers in current game session
function GET_PLAYER_UNIT_LIST() end

---MWWSE
---@param input_unit unit
---@return table
---returns data table of all units dat
--data.name (steam name)
--data.owner_peer_id peer id
--data.position (position as Vector3)
--data.position_table (position eg: {0,0,0})
--data.status
--data.state
--data.health
--data.max_health
--data.health_p (health %)
--data.team
--data.forward (forward facing Vector)
--data.simple_spell (eg: {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0})
--data.spell_type (eg: Beam, Spray, etc)
--data.spell (table eg: {"fire","fire","fire"})
--data.charge_time
--data.overcharged_time
--data.ward (eg: {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0})
--data.ward_elements (table eg: {"shield","fire","fire"})
--data.new_cast = nil or true
--data.focus
--data.angle (forward facing angle in degrees)
--data.unit = unit self reference
--data.extension_data = units character extension table
--data.selected_elements = simple_spell version of queued_elements (eg: {water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0})
--data.queued_elements = regular tablew version of queued_elements (table eg: {"shield","fire","fire"})
function GET_UNIT_DATA(peer_id) end

function GET_UNIT_DATA_FROM_UNIT(unit) end

function GET_UNIT_EXTENSION(peer_id) end



function GET_WEAPON_DAMAGE_TYPE(unit) end

function GET_WEAPON_RANGE(unit) end



--MWWSE
SE = SE or {}
SE.unit_utilities = SE.unit_utilities or {}
SE.unit_utilities.get_player_magick = GET_PLAYER_MAGICK
SE.unit_utilities.print_unit_data = PRINT_UNIT_DATA
SE.unit_utilities.get_unit_owner = GET_UNIT_OWNER
SE.unit_utilities.get_unit_status = GET_UNIT_STATUS
SE.unit_utilities.unit_is_valid = VALID_UNIT
SE.unit_utilities.unit_is_alive = UNIT_IS_ALIVE
SE.unit_utilities.distance_between_units = DISTANCE_UNIT
SE.unit_utilities.get_unit_position = GET_UNIT_POS
SE.unit_utilities.get_unit_state = GET_UNIT_STATE
SE.unit_utilities.get_unit_window = GET_UNIT_WINDOW
SE.unit_utilities.decode_unit = DECODE_UNIT
SE.unit_utilities.peer_id_to_player_name = ID_TO_NAME
SE.unit_utilities.peer_id_to_player_unit = ID_TO_UNIT
SE.unit_utilities.player_name_to_peer_id = NAME_TO_ID
SE.unit_utilities.get_peer_id_list = GET_PEER_LIST
SE.unit_utilities.get_player_list = GET_PLAYER_LIST
SE.unit_utilities.get_player_unit_list = GET_PLAYER_UNIT_LIST
SE.unit_utilities.get_unit_data = GET_UNIT_DATA
SE.unit_utilities.get_unit_data_from_unit = GET_UNIT_DATA_FROM_UNIT
SE.unit_utilities.get_weapon_damage_type = GET_WEAPON_DAMAGE_TYPE
SE.unit_utilities.get_weapon_range = GET_WEAPON_RANGE
---MWWSE
---@param unit any
---@return unknown
SE.unit_utilities.get_weapon_charge_time = function(unit) end

---MWWSE
---@param input_unit any
---@return Vector3
SE.unit_utilities.get_unit_forward = function(input_unit) end

