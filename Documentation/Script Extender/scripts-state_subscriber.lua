---@meta

---MWWSE
---@param state_type string
---@return self_state
function GET_STATE(state_type) end

---MWWSE
---@param state class|table|self
---@param state_type string
---@param event_ string|function|nil
function SETUP_STATE(state, state_type, event_) end

---MWWSE
---@param state_type string
---@param dt number|nil
---not used
function REMOVE_STATE(state_type, dt) end

---MWWSE
---@param state_type string
---@param dt number
---calls all subscribed mods in a registerd event hook
function UPDATE_STATE(state_type, dt, state) end

---MWWSE
---@param var_name string
---@param data table|any
function HOOK_GAME_DATA(var_name, data) end

---MWWSE
---@param var_name string
---returns value of hooked variable/table
function GET_GAME_DATA(var_name) end

---MWWSE
---@param state string
---@param event string
---@param mod_name string
---@param event_function function
---adds mod to the event call list by name (string)
function SUBSCRIBE_TO_STATE(state, event, mod_name, event_function, _self_reference) end

SE = SE or {}
SE.event_handler = {
	get_gamestate = GET_STATE,
	register_new_event = SETUP_STATE,
	remove_event = REMOVE_STATE,
	update_event = UPDATE_STATE,
	hook_variable = HOOK_GAME_DATA,
	get_variable = GET_GAME_DATA,
	register_event = SUBSCRIBE_TO_STATE,
}


