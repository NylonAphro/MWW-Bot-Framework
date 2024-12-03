require("ai/helper_library")
require("ai/abilities")

---All bot edits should be done in this file or new files you create
local Bot = {}

Bot.input_controller = require("scripts/input_controller")
Bot.stop_watch = require("scripts/stopwatch_controller")

local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities
local math_utilities = SE.math_utilities

local helper = HelperLibrary
local spells = HelperLibrary.spells
local available_magicks = HelperLibrary.available_magicks
local action = ActionController
local activation_conditions = action.activation_conditions
local on_update = action.on_update
local abilities = BotAbilities

-- Define elements for ease of use
local q = "water"
local w = "life"
local e = "shield"
local r = "cold"
local a = "lightning"
local s = "arcane"
local d = "earth"
local f = "fire"

---add targeting logic here
---@param self table
function Bot:init()
    local ai_data = self.ai_data
end

---add targeting logic here
---@param self table
function Bot:select_target()
    local ai_data = self.ai_data

    -- Default target is any enemy ai unit, the closest enemy, or the bot unit itself
    ai_data.target_unit = ai_data.enemy_ai_units[1] or ai_data.closest_enemy.unit or ai_data.bot_unit
end

--- General bot update stuff like pathing should be added here
---@param self table
function Bot:update()
    local ai_data = self.ai_data
    local dt = self.dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
end

--- Bot general logic and actions/routines should be placed here
--- This function is called every frame unless the bot is disabled (e.g., round resetting)
--- and only when the queue is empty
---@param self table
function Bot:update_logic()
    local ai_data = self.ai_data
    local dt = self.dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    
    --add actions/combos here
    if ai_data.target_unit and ai_data.target_unit ~= ai_data.bot_unit and ai_data.self_data.health_p >= 90 then
        if unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit) < 4 then
            queue:new_action(abilities.weapon.charge)
        else
            queue:new_combo(combos.water_beam_cold_shatter(ai_data))
        end
    elseif ai_data.self_data.health_p < 90 then
        queue:new_combo(combos.heal_turtle(ai_data))
    end

end

return Bot
