---@meta

COLORS = {
	black = function ()
		return Color(255, 0, 0, 0)
	end,
	white = function ()
		return Color(255, 255, 255, 255)
	end,
	burgundy = function ()
		return Color(255, 108, 18, 52)
	end,
	teal = function ()
		return Color(255, 100, 193, 200)
	end,
	blue = function ()
		return Color(255, 20, 40, 255)
	end,
	red = function ()
		return Color(255, 255, 40, 40)
	end
}




function GET_RESOLUTION() end

function GET_WINDOW_WIDTH_SCALER() end

function GET_WINDOW_HEIGHT_SCALER() end

function GET_SCALED_SCREEN_OFFSET_X() end

function GET_SCALED_SCREEN_OFFSET_Y() end

function SCALE_POINT_TO_RESOLUTION(input_point) end

---MWWSE
---@return unknown
function GET_UI() end

---MWWSE
---@param sound any
---Plays global sound
function PLAY_UI_SOUND(sound) end

---MWWSE
---@return table
---returns default icon color {
---}
function GET_DEFAULT_ICON_COLOR() end

---MWWSE
---@return table
---returns default icon color {
---}
function GET_DEFAULT_TEXTURE_COLOR() end

---MWWSE
---@return table
--returns center x point of screen that is not scaled to resolution
function GET_CENTER_SCREEN_X() end

---MWWSE
---@return table
--returns center y point of screen that is not scaled to resolution
function GET_CENTER_SCREEN_Y() end

--returns center x point of screen
function GET_CENTER_SCREEN_X_SCALED() end

--returns center y point of screen
function GET_CENTER_SCREEN_Y_SCALED() end

--returns center of screen as Vector3
function GET_CENTER_SCREEN_VEC() end

--returns center point of screen as table
function GET_CENTER_SCREEN() end

--returns max size of screen
function GET_SCREEN_SIZE_X() end

--returns max size of screen
function GET_SCREEN_SIZE_Y() end

--returns max size of screen as Vector2
function GET_SCREEN_SIZE_VEC() end

--returns max size of screen as Vector2
function GET_SCREEN_SIZE() end

---MWWSE
---@param point Vector3|table
---@return Vector3
---returns Vector3 point relative to flat screen coords given world position
function WORLD_TO_SCREEN(point) end

---MWWSE
---@param point Vector3|table
---@return Vector3
---returns Vector3 point relative to flat screen coords given world position
function LOBBY_WORLD_TO_SCREEN(point) end

function DEBUG_DRAW_RECT(state, pos, size, color) end

function DEBUG_DRAW_RECT_3D (gui_manager, tm, size, filled, color, layer) end

--this is possibly the WORST way to draw a cube ever made
--what the fuck
function DEBUG_DRAW_CUBE(pos, size, color, layer, facing) end

--this is possibly the WORST way to draw a 3d rect prism ever made
--what the fuck
function DEBUG_DRAW_CUBE_3D(pos, size, color, layer, facing, input_element) end

---MWWSE
---@param mode state|string
---@return unknown
---given state (eg "ingame") returns list of all damage_receiver entities
function GET_UNITS(mode) end

function GET_TEXT_WIDTH_OFFSET(text, size, scale) end

---@param text string
---@param size font_size
---@param pos Vector2
---@return Vector2
---returns center pos of text
function CENTER_TEXT_WIDTH(text, size, scale, pos) end

---@param text string
---@param size font_size
---@param pos Vector2
---@return Vector2
---returns center pos of text
---UNTESTED
function CENTER_TEXT_HEIGHT(text, size, pos) end

---MWWSE
---@param pos Vector3
---@param effect string
---creates particles on screen given world pos
function CREATE_WORLD_PARTICLES(pos, effect) end

--fix this
function CREATE_WORLD_PARTICLES_LINKED(pos, effect) end

--helper function for text rotation end

---MWWSE
---@param input any
---@return returns any
---if type is function returns value produced by function end

---if type is function returns value produced by function
---if type is value returns input
function FUNC_OR_VAR(input, args) end

    -- print(string.format("update_markup elapsed time: %.2f\n", endTime - start))
---MWWSE
---@param dt integer
---@param markup_table table
---draws a full markup table and all child elements
function DRAW_MARKUP(dt, markup_table) end

---MWWSE
---@param mode string
---@param element_markup table
---given mode eg ("menu", or "ingame")
function NEW_UI_ELEMENT(mode, element_markup) end

---MWWSE
---@param name string
---@return table
---returns UI element given string for ingame UI (not secondary modded ui markup)
function GET_UI_ELEMENT(name) end

---MWWSE
---@param name string
---@return table
---returns UI element markup given string for ingame UI (not secondary modded ui markup)
function GET_ELEMENT_MARKUP(name) end

---MWWSE
---@param name string
---@return table
---returns UI element style given string for ingame UI (not secondary modded ui markup)
function GET_ELEMENT_STYLE(name) end

---MWWSE
---@param peer_id string
---@return table|nil
---returns ingame player portrait UI element style given string for ingame UI (not secondary modded ui markup)
function GET_PLAYER_PORTRAIT_UI_ELEMENT(peer_id) end

---MWWSE
---@param element string
---@return table|nil
---returns ingame player portrait UI element style given string for ingame UI (not secondary modded ui markup)
function GET_INGAME_UI_ELEMENT_POS(element) end

---MWWSE
---@param name string
---disables (does not hide) ui element given string for ingame UI (not secondary modded ui markup)
function DISABLE_UI_ELEMENT(name) end

---MWWSE
---@param name string
---hides ui element given string for ingame UI (not secondary modded ui markup)
function HIDE_UI_ELEMENT(name) end

-- adds an element as child to parent
function NEW_GAME_UI_ELEMENT(parent_, markup_, style_) end

--subscribe to mod interface stuff
