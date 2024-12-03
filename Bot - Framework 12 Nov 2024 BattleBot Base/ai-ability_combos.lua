require("ai/helper_library")
require("ai/abilities")

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

--define elements for ease of use
local q = "water"
local w = "life"
local e = "shield"
local r = "cold"
local a = "lightning"
local s = "arcane"
local d = "earth"
local f = "fire"

--add your combos here
BotCombos = {
    heal_turtle = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local return_combo = {}
 
        -- Add abilities to the combo table
        table.insert(return_combo, abilities.heal.wall_facing_target())
        table.insert(return_combo, abilities.heal.mines_facing_away_from_target())
        table.insert(return_combo, abilities.ward.earth())

        if helper.unit_is_chilled(ai_data.bot_unit) or helper.unit_is_wet(ai_data.bot_unit) then
            table.insert(return_combo, abilities.aoe.sfs)
        else
            table.insert(return_combo, abilities.aoe.water())
        end

        --create a new instance of the each of the actions in the queue and return the list
        --it is important to make a new instance of the table every time as lua passes by reference
        --and if you use the same ability table multiple times it will cause undefined bahaviour
        return return_combo
    end,
    ---test_combo
    ---@param ai_data any
    ---@return table
    ---returns a new table of ipairs actions
    water_beam_cold_shatter = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit)
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local self_facing = unit_utilities.get_unit_forward(ai_data.bot_unit)

        local return_combo = {}

        --return if there is no target!
        if not target_pos then print("No target unit, cannot queue water_beam_cold_shatter") return {} end

        --if we are not in range first move closer to the target
        if unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit) > 9 then
            local move_target = math_utilities.offset_point_towards_point(target_pos, self_position, 5)
            table.insert(return_combo, action.move_to_point(move_target, {wanted_range = 8}, {}, {on_update.move_to_wanted_range_of_target}))
        end

        -- Add abilities to the combo table
        table.insert(return_combo, action.face_point(target_pos))
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 7}, {}, {on_update.move_to_wanted_range_of_target}))
        table.insert(return_combo, action.beam(nil, {q,s,s}, 5, {wanted_range = 7}, 
        {
            activation_conditions.target_not_shielded, 
            activation_conditions.target_is_valid,
        }, 
        {
            on_update.cancel_if_target_wet,
            on_update.face_target_unit, 
            on_update.move_to_wanted_range_of_target, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_target_frozen, 
            on_update.cancel_if_target_shielded
        }))
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 7}, {}, {on_update.move_to_wanted_range_of_target}))
        table.insert(return_combo, abilities.projectile.cold())
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 7}, {}, {on_update.move_to_wanted_range_of_target}))
        table.insert(return_combo, abilities.spray.cold())
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 7}, {}, {on_update.move_to_wanted_range_of_target}))
        table.insert(return_combo, abilities.projectile.earth_shatter())
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 7}, {}, {on_update.move_to_wanted_range_of_target}))

        --create a new instance of the each of the actions in the queue and return the list
        --it is important to make a new instance of the table every time as lua passes by reference
        --and if you use the same ability table multiple times it will cause undefined bahaviour
        return return_combo
    end,
}
