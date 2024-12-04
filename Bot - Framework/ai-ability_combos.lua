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
local condition_groups = action.condition_groups

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
        if not ai_data.target_unit or ai_data.target_unit == ai_data.bot_unit then print("No target unit, cannot queue water_beam_cold_shatter") return {} end

        --if we are not in range first move closer to the target
        if unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit) > 9 then
            local move_target = math_utilities.offset_point_towards_point(target_pos, self_position, 5)
            table.insert(return_combo, action.move_to_point(VEC_TO_TABLE(move_target), {wanted_range = 8}, {}, {on_update.path_to_ability_wanted_range}))
        end

        -- Add abilities to the combo table
        table.insert(return_combo, action.face_point(VEC_TO_TABLE(target_pos)))
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 6}, {}, {on_update.path_to_ability_wanted_range}))
        table.insert(return_combo, action.beam(nil, {q,s,s}, 5, {wanted_range = 6}, 
        {
            activation_conditions.target_not_shielded, 
            activation_conditions.target_is_valid,
        }, 
        {
            on_update.cancel_if_target_wet,
            on_update.face_target_unit, 
            on_update.path_to_ability_wanted_range, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_target_frozen, 
            on_update.cancel_if_target_shielded
        }))
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 6}, {}, {on_update.path_to_ability_wanted_range}))
        table.insert(return_combo, action.projectile(nil, {r,r,d}, 0.9, {minumum_range = 0.5, maximum_range = 12, wanted_range = 6},  condition_groups.activation_conditions.default, condition_groups.on_update.projectile))
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 6}, {}, {on_update.path_to_ability_wanted_range}))
        table.insert(return_combo, abilities.spray.cold())
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 6}, {}, {on_update.path_to_ability_wanted_range}))
        table.insert(return_combo, abilities.projectile.earth_shatter())
        table.insert(return_combo, action.set_move_target(nil, {wanted_range = 6}, {}, {on_update.path_to_ability_wanted_range}))

        --create a new instance of the each of the actions in the queue and return the list
        --it is important to make a new instance of the table every time as lua passes by reference
        --and if you use the same ability table multiple times it will cause undefined bahaviour
        return return_combo
    end,
    arcane_mine = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 3, minimum_range = 0, maximum_range = 6, max_duration = 1}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos}),
            action.face_point(nil, {minimum_range = 0, maximum_range = 5}, {activation_conditions.within_range}, on_update.face_target_unit),
            action.spell(nil, {e,s,s}, false, 0, {minimum_range = 0, maximum_range = 5}, {activation_conditions.within_range}, {}),
            action.move_backward(1.75, {minimum_range = 0, max_duration = 2}, {activation_conditions.within_range}),
        }

        if target_unit_data.ward.fire >= 1 and target_unit_data.ward.water >= 1 then
            table.insert(return_combo, action.spray(nil, {r,r,r}, 0.1, {maximum_range = 8}, {activation_conditions.within_range}, {}))
        elseif target_unit_data.ward.water <= 0 then
            table.insert(return_combo, action.spray(nil, {q,f,q}, 0.1, {maximum_range = 6}, {activation_conditions.within_range}, {}))
        else
            table.insert(return_combo, action.spray(nil, {f,f,f}, 0.1, {maximum_range = 8}, {activation_conditions.within_range}, {}))
        end
 
        return return_combo
    end,

    --below are a bunch of random ones I have made 
    --but are untested
    charge_forward_and_use_ability = function(ai_data, new_action, charge_range)
        charge_range = charge_range or ai_data.wanted_range
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 2, minimum_range = 0, maximum_range = 100, max_duration = 2}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos}),
            new_action,
        }

 
        return return_combo
    end,
    arcane_mine_lightning_combo = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 3, minimum_range = 0, maximum_range = 6, max_duration = 1}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos}),
            action.face_point(nil, {minimum_range = 0, maximum_range = 5}, {activation_conditions.within_range}, on_update.face_target_unit),
            action.spell(nil, {e,s,s}, false, 0, {minimum_range = 0, maximum_range = 5}, {activation_conditions.within_range}, {}),
            action.set_move_target(nil, {distance = 1.75, minimum_range = 0, max_duration = 2}, {activation_conditions.within_range}, on_update.move_backward),
        }

        table.insert(return_combo, action.projectile(nil, {d,q,q}, 0.36, {minimum_range = 0, maximum_range = 7}, {activation_conditions.within_range}, {on_update.face_target_unit}))
        table.insert(return_combo, action.spell(nil, {a,s,a}, false, 0, {minimum_range = 0, maximum_range = 7}, {activation_conditions.bot_is_not_wet, activation_conditions.within_range}, {on_update.face_target_unit, on_update.cancel_if_wet}))
 
        return return_combo
    end,
    charge_forward_rock_qer = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.projectile(nil, spells.ddd(), 0.9, {minimum_range = 0, maximum_range = 12, wanted_range = 3}, {activation_conditions.within_range}, {on_update.face_target_unit, on_update.path_to_ability_wanted_range, on_update.cancel_to_ward, on_update.cancel_if_no_target}),
            action.spell(nil, {q,e,r}, false, 0, {minimum_range = 0, maximum_range = 4}, {activation_conditions.within_range}, {on_update.face_target_unit, on_update.cancel_if_no_target}),
        }

 
        return return_combo
    end,
    charge_forward_steam_lightning = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.projectile(nil, spells.ddd(), 0.9, {minimum_range = 0, maximum_range = 12, wanted_range = 3}, {activation_conditions.within_range}, {on_update.face_target_unit, on_update.path_to_ability_wanted_range, on_update.cancel_to_ward, on_update.cancel_if_no_target}),
            action.spray(nil, {q,f,q}, 5, {minimum_range = 0, maximum_range = 12, wanted_range = 6}, {activation_conditions.within_range}, {on_update.face_target_unit, on_update.path_to_ability_wanted_range, on_update.cancel_to_ward, on_update.cancel_if_no_target}),
            action.spell(nil, {a,s,a}, false, 0, {minimum_range = 0, maximum_range = 7}, {activation_conditions.bot_is_not_wet, activation_conditions.within_range}, {on_update.face_target_unit, on_update.cancel_if_no_target, on_update.cancel_if_wet})
        }

        return return_combo
    end,
    charge_forward_quake_wet_lightning = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 2, minimum_range = 0, maximum_range = 6, max_duration = 2}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos}),
            action.self_cast({d,q,d}, {minimum_range = 0, maximum_range = 4, wanted_range = 4}, {activation_conditions.within_range}, {on_update.cancel_if_out_of_range}),
            action.self_cast({a,s,r}, {minimum_range = 0, maximum_range = 6, wanted_range = 4}, {activation_conditions.within_range, activation_conditions.bot_is_not_wet}, {on_update.cancel_if_wet}),
        }

        return return_combo
    end,
    charge_forward_quake_lightning = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 2, minimum_range = 0, maximum_range = 6, max_duration = 2}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos}),
            action.self_cast({d,f,d}, {minimum_range = 0, maximum_range = 4, wanted_range = 4}, {activation_conditions.within_range}),
            action.self_cast({a,s,f}, {minimum_range = 0, maximum_range = 4, wanted_range = 4}, {activation_conditions.within_range, activation_conditions.bot_is_not_wet}, {on_update.cancel_if_wet}),
        }

        return return_combo
    end,
    charge_forward_quake_mines = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 2.5, minimum_range = 0, maximum_range = 6, max_duration = 2}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos, on_update.cancel_to_ward}),
            action.self_cast({d,f,d}, {minimum_range = 0, maximum_range = 4, wanted_range = 4}, {activation_conditions.within_range, activation_conditions.target_not_warded}),
            --action.face_point(nil, {minimum_range = 0, maximum_range = 7}, {activation_conditions.within_range}, on_update.face_target_unit),
            action.spell(nil, {e,s,s}, false, 0, {minimum_range = 0, maximum_range = 5}, {activation_conditions.within_range, activation_conditions.target_not_warded}, {on_update.face_target_unit}),
            action.ward({e,s,s}, {minimum_range = 0, maximum_range = 3, wanted_range = 4}, {activation_conditions.within_range} ),
            action.self_cast({d,f,d}, {minimum_range = 0, maximum_range = 3, wanted_range = 2}, {activation_conditions.within_range}),
        }

        return return_combo
    end,
    charge_forward_steam_storm_quake = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 2.5, minimum_range = 0, maximum_range = 10, max_duration = 8}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos, on_update.cancel_to_ward}),
            --action.face_point(nil, {minimum_range = 0, maximum_range = 10}, {activation_conditions.within_range}, on_update.face_target_unit),
            action.spell(nil, {e,f,q}, false, 0, {minimum_range = 1.5, maximum_range = 2.75}, {activation_conditions.within_range, activation_conditions.target_not_warded}, {on_update.face_target_unit}),
            action.self_cast({d,f,d}, {minimum_range = 0, maximum_range = 3, wanted_range = 1}, {activation_conditions.within_range, activation_conditions.target_not_warded}),
            action.beam(nil, {f,s,s}, 5, {wanted_range = 6, minimum_range = 0.5, maximum_range = 20}, {activation_conditions.target_not_shielded, activation_conditions.target_not_warded},
            {
                on_update.face_target_unit, 
                on_update.path_to_ability_wanted_range, 
                on_update.cancel_if_no_target, 
                on_update.cancel_if_target_frozen, 
                on_update.cancel_if_target_shielded,
                on_update.cancel_if_shield_in_line_of_sight,
            }),
        }

        return return_combo
    end,
    charge_forward_cold_storm_quake = function(ai_data)
        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local return_combo = {
            action.move_to_point(nil, {wanted_range = 2.5, minimum_range = 0, maximum_range = 10, max_duration = 4}, condition_groups.activation_conditions.default, {on_update.path_to_ability_wanted_range, on_update.face_move_pos, on_update.cancel_to_ward}),
            action.face_point(nil, {minimum_range = 0, maximum_range = 3}, {activation_conditions.within_range}, (on_update.face_target_unit)),
            action.spell(nil, {e,r,r}, false, 0, {minimum_range = 1.5, maximum_range = 3}, {activation_conditions.within_range, activation_conditions.target_not_warded}, {}),
            action.self_cast({d,r,d}, {minimum_range = 0, maximum_range = 2, wanted_range = 2}, {activation_conditions.within_range, activation_conditions.target_not_warded}),
            action.beam(nil, {r,s,s}, 5, {wanted_range = 6, minimum_range = 0.5, maximum_range = 20}, {activation_conditions.target_not_shielded, activation_conditions.target_not_warded},
            {
                on_update.face_target_unit, 
                on_update.path_to_ability_wanted_range, 
                on_update.cancel_if_no_target, 
                on_update.cancel_if_target_frozen, 
                on_update.cancel_if_target_shielded,
            }),
        }

        return return_combo
    end,
}
