---@meta



---MWWSE
---@param ability any
---@return table
---Converts storm ability to one-dimmensional array
function STORM_TO_SPELL(ability) end

-- Convert elemental table to one-dimmensional array
function CONVERT_TO_SPELL(elements) end

---MWWSE
---@return table
---returns new table based spell 
--- {ice = 0, steam = 0, poison = 0, water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0}
function NEW_SIMPLE_SPELL() end

---MWWSE
---@param elements any
---@return table
---converts a table of elements to a simple spell table
--- EG: {ice = 0, steam = 0, poison = 0, water = 0, life = 0, shield = 0, cold = 0, lightning = 0, arcane = 0, earth = 0, fire = 0, empty = 0}
function CONVERT_TO_SIMPLE_SPELL(elements)  end

---MWWSE
---@param elementsA any
---@param elementB any
---@return boolean
---returns true if elementB is in elementsA
function SPELL_CONTAINS(elementsA, elementB) end

---MWWSE
---@param elementsA any
---@param elementB any
---@return integer|nil
---returns index of elementB in elementsA
function SPELL_INDEX_OF(elementsA, elementB) end

---MWWSE
---@param elements table
---@param element table
---@return integer
---returns number of times element is in elements
function SPELL_ELEMENT_COUNT(elements, element) end

---MWWSE
---@param elementsA any
---@param elementB any
---@return integer|nil
---returns index of elementB in elementsA but starts at #elementsA and iterates backwards
---this is useful for finding the last element in a spell
function SPELL_INDEX_INVERSE(elementsA, elementB) end

---MWWSE
---@param elementsA any
---@param elementsB any
---@return boolean
---returns true if elementsA and elementsB are the same
function SPELL_EQUALS(elementsA, elementsB) end

---MWWSE
---@param elements any
---@return boolean
---returns true if elements is a valid spell
---eg: cannot contain both lightning and water
function VALID_SPELL(elements) end

---MWWSE
---@param possible_elements_ table|nil
---@return table
---returns a random spell using all elements by default, or given possible_elements_ table
function RANDOM_SPELL(possible_elements_) end

ELEMENT_TEXTURES = {
	shield = "hud_element_shield",--_small",
	water = "hud_element_water",--_small",
	fire = "hud_element_fire",--_small",
	earth = "hud_element_earth",--_small",
	steam = "hud_element_steam",--_small",
	lightning = "hud_element_lightning",--_small",
	cold = "hud_element_cold",--_small",
	arcane = "hud_element_arcane",--_small",
	life = "hud_element_life",--_small",
	ice = "hud_element_ice",--_small",
	--weapon
	Weapon = "icon_weapon_ability",
	
	--selfcast
	LightningAoe = "hud_icon_mouse_effect_mmb",
	SelfShield = "hud_icon_mouse_effect_mmb",
	Aoe = "hud_icon_mouse_effect_mmb",
	Shield = "hud_icon_mouse_effect_mmb",
	Heal = "hud_icon_mouse_effect_mmb",
	
	--forward cast
	Lightning = "hud_icon_mouse_effect_rmb",
	Projectile = "hud_icon_mouse_effect_rmb",
	Spray = "hud_icon_mouse_effect_rmb",
	Beam = "hud_icon_mouse_effect_rmb",
	Storm = "hud_icon_mouse_effect_rmb",
	Barrier = "hud_icon_mouse_effect_rmb",
	Mine = "hud_icon_mouse_effect_rmb",
	--Shield = "hud_icon_mouse_effect_rmb",
	
}




function GET_COUNTER_ELEMENTS(element) end

SE = SE or {}
SE.spell_utilities = SE.spell_utilities or {}
SE.spell_utilities.storm_to_spell = STORM_TO_SPELL
SE.spell_utilities.new_element_table = NEW_SIMPLE_SPELL
SE.spell_utilities.spell_to_elements = CONVERT_TO_SIMPLE_SPELL
SE.spell_utilities.elements_to_spell = CONVERT_TO_SPELL
SE.spell_utilities.spell_contains = SPELL_CONTAINS
SE.spell_utilities.spell_index_of_first_element = SPELL_INDEX_OF
SE.spell_utilities.spell_index_of_last_element = SPELL_INDEX_INVERSE
SE.spell_utilities.spell_equals = SPELL_EQUALS
SE.spell_utilities.spell_is_valid = VALID_SPELL
SE.spell_utilities.random_spell = RANDOM_SPELL
