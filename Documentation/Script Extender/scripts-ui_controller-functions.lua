---@meta

UIFunc = {
}


UIProperties = {
	texture = {
		image = "image",
		pos = "pos",
		size = "size",
		center = "center",
		color = "color",
		fade_in = "fade_in",
		fade_out = "fade_out",
		visible = "visible",
		destroy = "destroy",
		wanted_color = "wanted_color",
		velocity = "velocity",
		speed = "speed",
		age = "age",
		max_age = "max_age",
		fade_on_target = "fade_on_target",
		gravity = "gravity",
		scale_speed = "scale_speed",
		stretch_to_velocity = "stretch_to_velocity",
		clicked = "clicked",
		hover = "hover",
		mouse_leaves = "mouse_leaves",
		mouse_enters = "mouse_mouse_entersleaves",
		destroy_if_mouse_leaves = "destroy_if_mouse_leaves",
		rotation = "rotation",
		wanted_pos = "wanted_pos",
	},
	text = {
		string = "string",
		pos = "pos",
		size = "size",
		scale = "scale",
		center = "center",
		color = "color",
		alpha = "alpha",
		fade_in = "fade_in",
		fade_out = "fade_out",
		visible = "visible",
		destroy = "destroy",
		wanted_color = "wanted_color",
		velocity = "velocity",
		speed = "speed",
		age = "age",
		max_age = "max_age",
		fade_on_target = "fade_on_target",
		font = "font",
		rotation = "rotation",
		wanted_pos = "wanted_pos",
		move_type = "move_type",
	},
	font = {
		liberation_sans = "liberation_sans",
		liberation_sans_outline = "liberation_sans_outline",
		linux_libertine_regular = "linux_libertine_regular",
		linux_libertine_semibold = "linux_libertine_semibold",
		linux_libertine_bold = "linux_libertine_bold",
		linux_biolinum_bold_outline = "linux_biolinum_bold_outline",
		philosopher_bold = "philosopher_bold",
		philosopher_bold_clean = "philosopher_bold_clean", 
	},
	quaternion_color = {
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
	},
	color = {
		black = function ()
			return {255, 0, 0, 0}
		end,
		white = function ()
			return {255, 255, 255, 255}
		end,
		burgundy = function ()
			return {255, 108, 18, 52}
		end,
		teal = function ()
			return {255, 100, 193, 200}
		end,
		blue = function ()
			return {255, 20, 40, 255}
		end,
		red = function ()
			return {255, 255, 40, 40}
		end
	},
	move_type = 
	{
		slerp = "slerp",
		decelerate = "decelerate",
	}
}


---some comment stuff here
UIFunc.slide_in_from_left = function(condition_args) end

---MWWSE
---@param markup_table table|markup
---kills a child element in a markup table
UIFunc.kill_child = function(markup_table) end

---MWWSE
---@param markup_table table|markup
---@param depth number|nil
---kills all child elements in a markup table
UIFunc.kill_children = function(markup_table, depth) end

---MWWSE
---@param markup_table table|markup
---@param depth number
---kills all child elements in a markup table and the markup table itself
UIFunc.kill_element_and_children = function(markup_table, depth) end

---MWWSE
---@param parent table|markup
---@param child table|markup
---@return table
---adds a child element to a parent element
UIFunc.add_child = function (parent, child) end

---MWWSE
---@param text string
---@param pos table
---@param size number
---@param color table|color
---@param center boolean
---@param condition_args table|nil
---@return table|markup
---creates a new text markup element
UIFunc.new_text_markup = function (text, pos, size, color, center, condition_args) end

---MWWSE
---@param center table|vector3
---@param radius number
---@param angle number angle in degrees
---@return table
UIFunc.polar_to_cartesian = function(center, radius, angle) end

---MWWSE
---@param text string
---@param pos table
---@param size table
---@param color table|table
---@param is_centered boolean
---@param radius number
---@param circle_angle_multiplier number|nil
---@return table
---creates a new text markup element that is placed in a circle around a center point
UIFunc.new_text_circle_markup = function(text, pos, size, color, is_centered, radius, circle_angle_multiplier) end

---MWWSE
---@param text string
---@param pos table
---@param size number
---@param target_length number
---@param line_spacing number
---@return table|markup
---creates a new text markup element that wraps text to a specific length
UIFunc.new_text_body = function(text, pos, size, target_length, line_spacing) end

---MWWSE
---@param text string
---@param pos table
---@param size number
---@param line_spacing number
---@return table|markup
---creates a new text markup element that does not wrap text to a specific length
---but can have multiple lines defined by the \n char
UIFunc.new_text_body_no_line_wrap = function(text, pos, size, line_spacing) end

---MWWSE
---@param height number
---@param width number
---@return table
UIFunc.new_texture_size = function(height, width) end

---MWWSE
---DEPRECATED
UIFunc.destroy_markup = function(markup) end

UIFunc.ui_button_mouse_enters = function(condition_args) end

UIFunc.ui_button_mouse_clicked = function(condition_args) end

UIFunc.ui_button_mouse_hovers = function(condition_args) end

UIFunc.ui_button_mouse_leaves = function(condition_args) end

---MWWSE
---@param parent table|markup
---@return table|position
---returns the global position of an element
---eg if parent is at {100,100} and child is at {10,10} then the child is at global pos {110,110}
UIFunc.get_global_pos = function(parent) end

---MWWSE
---@param pos table
---@param text string
---@param text_offset_x number
---@param text_offset_y number
---@param mouse_clicked function|nil
---@param mouse_enters function|nil
---@param mouse_leaves function|nil
---@return table|markup
---creates a new button that is not automatically added to the UI drawing tables
UIFunc.new_button_unattached = function(pos, text, text_offset_x, text_offset_y, mouse_clicked, mouse_enters, mouse_leaves) end

---MWWSE
---@param pos table
---@param text string
---@param text_offset_x number
---@param text_offset_y number
---@param mouse_clicked function|nil
---@param mouse_enters function|nil
---@param mouse_leaves function|nil
---@return table
---creates a new button that is automatically added to the UI drawing tables
UIFunc.new_button = function(pos, text, text_offset_x, text_offset_y, mouse_clicked, mouse_enters, mouse_leaves) end

---MWWSE
---@param texture any
---@param pos vector3|table
---@param size table|vector3
---@param center boolean
---@param tint any|nil
---@return table
---creates a new texture that is not added to the UI drawing tables
UIFunc.new_texture_markup = function (texture, pos, size, center, tint, condition_args) end

---MWWSE
---@param pos vector3|table
---@param size table|vector3
---@param color table|nil
---@param condition_args table|nil
---@return table
---creates a new texture that is not added to the UI drawing tables
UIFunc.new_rectangle_2d_markup = function (pos, size, color, condition_args) end

---MWWSE
---@param pos vector3|table
---@param size table|vector3
---@param color table|nil
---@param condition_args table|nil
---@return table
---creates a new texture that is not added to the UI drawing tables
UIFunc.new_rectangle_3d_markup = function (pos, facing, size, color, condition_args) end

---MWWSE
---@param pos vector3|table
---@param size table|vector3
---@param color table|nil
---@param condition_args table|nil
---@return table
---creates a new texture that is not added to the UI drawing tables
UIFunc.new_cube_3d_markup = function (pos, facing, size, color, condition_args) end

---MWWSE
---@param pos vector3|table
---@param size table|vector3
---@param color table|nil
---@param condition_args table|nil
---@return table
---creates a new texture that is not added to the UI drawing tables
UIFunc.new_cube_object_markup = function (pos, facing, size, color, condition_args) end

---MWWSE
---@param texture any
---@param pos vector3|table
---@param size table|vector3
---@param center boolean
---@param tint any|nil
---@return table
---creates a new texture that is not added to the UI drawing tables
UIFunc.new_rotated_texture_markup = function (texture, pos, size, center, tint, rotation, condition_args) end

---MWWSE
---@param title any
---@param message any
---@param button_function function
---@return table
UIFunc.new_popup_message = function(title, message, button_function, size) end

---MWWSE
---@param title any
---@param message any
---@param button_function_yes function
---@param button_function_no function
---@return table
UIFunc.new_popup_yes_no = function(title, message, button_function_yes, button_function_no, size) end

---MWWSE
---returns SHOW_MOD_MENU_PARENT
UIFunc.get_mod_menu_parent = function() end

UIFunc.mod_tab_list = {}
UIFunc.active_tab = ""

---MWWSE
---@param mod_name string
---@param mod_button_name string
---@param mod_function function
---@return table
---adds a new tab to the mod menu
---mod_function is called when the tab is clicked end

---mod_function is called when the tab is clicked
UIFunc.new_mod_tab = function(mod_name, mod_button_name, mod_function) end

---MWWSE
---@param mod_tab table|mod_tab
---@param element table|markup
---adds an element to a mod tab
UIFunc.add_element_to_tab = function(mod_tab, element) end

---MWWSE
---@param mod_tab_name string
---@param element string
---adds an element to a mod tab given the name of the mod
---may cause issues if a single mod has multiple tabs
UIFunc.add_element_to_tab_by_name = function(mod_tab_name, element) end

---MWWSE
---@param element string
---adds an element to the active mod tab
UIFunc.add_element_to_current_tab = function(element) end

---MWWSE
---destroys the markup of the active tab
UIFunc.clear_mod_tab_markup = function() end

---MWWSE
---@param name string
---@param value number
---@param color table|color
---@return table
UIFunc.new_grid_point = function(name, value, color) end

---MWWSE
---@param grid_points table
---sorts the grid points based on their values from high to low
UIFunc.sort_grid_points = function(grid_points) end

---MWWSE
---comment
---@param grid table
---@param pos table
---@param size table
---@param title string
---@param background_colour table|color
---@param condition_args table
---@return table
UIFunc.new_graph_markup = function(grid, pos, size, title, background_colour, condition_args) end

---MWWSE
---@param particle markup|table
---@param velocity number
UIFunc.set_velocity = function(particle, velocity) end

---MWWSE
---@param element markup|table
---@param wanted_pos table
---sets a markup element wanted_pos to a specific position
---will slide/animate the element to the position
UIFunc.slide_element_to_point = function(element, wanted_pos) end

---MWWSE
---@param element table|markup
---@param key string
---@param value any
---sets a property of a markup element
---will set the property of the texture *AND* text
---elements can have a text and texture property
UIFunc.set_element_property = function(element, key, value) end

---MWWSE
---@param element table|markup
---@param key string
---@return any
---gets a property of a markup element
---will get the property of the texture
UIFunc.get_texture_property = function(element, key) end

---MWWSE
---@param element table|markup
---@param key string
---@param value any
---sets a property of a markup element
---will set the property of the texture
UIFunc.set_texture_property = function(element, key, value) end

---MWWSE
---@param element table|markup
---@param key string
---@param value any
---sets a property of a markup element
---will set the property of the text
UIFunc.set_text_property = function(element, key, value) end

---MWWSE
---@param element table|markup
---@param key string
---@return any
---gets a property of a markup element
---will get the property of the text
UIFunc.get_text_property = function(element, key) end

---MMWSE
---@param condition_args table
---returns the element that is calling the update function end

---returns the element that is calling the update function
UIFunc.get_self_element = function(condition_args) end

---MWWSE
---@param element table
---@param key string
---@return table|nil
---returns the first available element property of given key
---if there are multiple properties it may cause unexpected results
---EG if element has text and texture property and both have a key of "pos"
UIFunc.get_element_property = function(element, key) end

---MWWSE
---Creates particles with specified properties
---@param texture string The texture of the particles
---@param count number The number of particles to create
---@param start_pos table The starting position of the particles
---@param start_size table The starting size of the particles
---@param wanted_size table The desired size of the particles
---@param tint table|color The color tint of the particles
---@param velocity number|nil The velocity of the particles
---@param gravity table The gravity affecting the particles
---@param lifetime number The lifetime of the particles
---does not return anything
---particles are created and added to the UI drawing tables 
---and will be destroyed after their lifetime has expired
---the user does not have access to the particles after creation
UIFunc.create_particles = function(texture, count, start_pos, start_size, wanted_size, tint, velocity, gravity, lifetime) end

--- Checks if a given point is within a 3D shape defined by a bottom center point and facing.
---@param point Vector3 The point to check.
---@param bottom_center Vector3 The bottom center point of the 3D shape.
---@param facing Vector3 The facing direction of the 3D shape.
---@param size Vector3 The size of the 3D shape.
---@return boolean result Returns true if the point is within the shape, false otherwise.
UIFunc.point_within_region = function(point, bottom_center, facing_normal, size) end

    -- Check if the point is within the region's boundaries
