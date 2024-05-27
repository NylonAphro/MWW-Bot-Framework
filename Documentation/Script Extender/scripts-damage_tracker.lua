---@meta

---MWWSE
---@param id_ peer_id|string
---@param current_round integer|string|nil
---@return integer
---returns damage delt by a player, either on all or x round
function GET_DAMAGE_DEALT(id_, current_round) end

---@param id_ peer_id|string
---@param current_round integer|string|nil
---@return integer
---returns healing given by a player, either on all or x round
function GET_HEALING_GIVEN(id_, current_round) end

---returns damage delt by a player to xx player, either on all or x round
function GET_DAMAGE_DEALT_TO(id_, target) end

-- returns damage from xx to a player, either on all or x round
function GET_DAMAGE_FROM(id_, target) end

-- returns healing from a player to xx, either on all or x round
function GET_HEALING_GIVEN_TO(id_, target) end

-- returns damage from xx to a player, either on all or x round
function GET_HEALING_FROM(id_, target) end

--adds +1 assist to the player assist table
function ADD_PLAYER_ASSIST(peer_id) end

--returns the number of assists a player has
function GET_PLAYER_ASSISTS(peer_id) end

---MWWSE
---@param peer_id string
---@return table
---returns table of all players that dealt damage to peer_id within 1 second
function KILL_IS_ASSIST(peer_id) end

--this should maybe be private?
function UPDATE_DAMAGE_NUMBERS(extension_data) end

