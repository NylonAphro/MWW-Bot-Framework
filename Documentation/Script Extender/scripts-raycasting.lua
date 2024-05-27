---@meta

---MWWSE
---@param self table
---@param origin_point any
---@param aim_point any
---@param hit_function function
---This function creates a raycast from the origin point to the aim point and executes the hit function when the raycast hits an object. end

---This function creates a raycast from the origin point to the aim point and executes the hit function when the raycast hits an object.
---the hit function will receive a table/list of actors hit end

---the hit function will receive a table/list of actors hit
function Raycaster:cast_ray(origin_point, aim_point, hit_function) end

---MWWSE
---@param origin_point any
---@param target_point any
---@param width any
---@param hit_function any
---This function creates a raycast from the origin point to the target point and executes the hit function when the raycast hits an object. end

---This function creates a raycast from the origin point to the target point and executes the hit function when the raycast hits an object.
---the hit function will receive a table/list of actors hit end

---the hit function will receive a table/list of actors hit
function Raycaster:cast_sphere_ray(origin_point, target_point, width, hit_function) end

function Raycaster:setup_game_world() end

