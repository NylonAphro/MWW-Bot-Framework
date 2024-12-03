require("scripts/game/util/path_aux")

--Pahting is not complete at all, have fun!

local Pathing = {}

function Pathing:cane_mesh_valid_pos(position)
	local cane = assert(GLOBAL_CANE_NAVMESHQUERY)
	return CaneNavmeshQuery.valid_position(cane, position)
end

return Pathing