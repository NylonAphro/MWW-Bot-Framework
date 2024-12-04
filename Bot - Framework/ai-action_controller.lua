require("ai/helper_library")
require("scripts/game/util/path_aux")

local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities

local helper = HelperLibrary
local spells = HelperLibrary.spells
local available_magicks = HelperLibrary.available_magicks

ActionController = {}

--define elements for ease of use
local q = "water"
local w = "life"
local e = "shield"
local r = "cold"
local a = "lightning"
local s = "arcane"
local d = "earth"
local f = "fire"

---comment
---@param queued_ability any
---@param ai_data any
---@param dt any
---loops over all of the update functions
local function run_on_updates(queued_ability, ai_data, dt)
    if queued_ability.on_update then
        if type(queued_ability.on_update) == "table" then
            for function_name, on_update_function in pairs(queued_ability.on_update) do
                on_update_function(queued_ability, ai_data, dt)
            end
        else
            queued_ability.on_update(queued_ability, ai_data, dt)
        end
    end
end

---comment
---@param queued_ability any
---@param ai_data any
---@param dt any
---loops over all of the activation_condition functions
---and sets the ability to end if they are not all met
ActionController.run_activation_conditions = function(queued_ability, ai_data, dt)
    queued_ability.can_use_ability = true

    print("queued ability run_activation_conditions: ")
    PRINT_TABLE(queued_ability)

    local ability_used = false

    if queued_ability.activation_conditions then
        if type(queued_ability.activation_conditions) == "table" then
            for function_name, activation_conditions_function in pairs(queued_ability.activation_conditions) do
                queued_ability.can_use_ability = activation_conditions_function(queued_ability, ai_data, dt)

                if not queued_ability.can_use_ability then
                    printf("unable to use ability: %s due to activation_condition: %s", tostring(queued_ability.action), tostring(function_name))
                    return
                end
            end
        else
            queued_ability.can_use_ability = queued_ability.activation_conditions(queued_ability, ai_data, dt)

            if not queued_ability.can_use_ability then
                printf("unable to use ability: %s due to activation_condition: %s", tostring(queued_ability.action), tostring(queued_ability.activation_conditions))
                return
            end
        end
    end

    if queued_ability.condition_args then
        if queued_ability.condition_args.cooldown then
            if queued_ability.condition_args.cooldown > (ai_data.timers[queued_ability.ability_name .. "_cooldown"] or 0) then
                print("setting cooldown for ability: " .. queued_ability.ability_name .. "_cooldown")
                ai_data.timers[queued_ability.ability_name .. "_cooldown"] = queued_ability.condition_args.cooldown
            end
        end
    end
end

--not currently used
ActionController.available_actions = {
    --wait
    wait = "wait",

    --sets a move target and does not free the queue until it reaches that point
    move_to_point = "move_to_point",

    --sets a move target and immediately frees the queue
    set_move_target = "set_move_target",

    --face target
    face_target = "face_target",

    -- swing weapon
    weapon_swing = "weapon_swing",

    --cast spell
    cast_spell = "cast_spell",

    spell = "spell",
    magick = "magick",
}

---ability_action
---@return string
ActionController.action_type = function(action)
    if not action then
        return "no action"
    end
    return action.action
end

---ability_action
---@param move_target any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will not free the queue until it reaches the point
ActionController.move_to_point = function(move_target, condition_args, activation_conditions, on_update)
    --move_target = move_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.move_to_point,
        move_target = move_target, --move_target = {move_target[1] or 0, move_target[2] or 0, move_target[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.move_to_point,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param move_target any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a distance to move to forward
---this action will not free the queue until it reaches the point
ActionController.move_forward = function(distance, max_duration)
    --move_target = move_target or {}
    local condition_args = {distance = distance, max_duration = max_duration or 100}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.move_to_point,
        move_target = nil, --move_target = {move_target[1] or 0, move_target[2] or 0, move_target[3] or 0},
        activation_conditions = {},
        update = ActionController.update_functions.move_to_point,
        on_update = ActionController.on_update.move_forward,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param move_target any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a distance to move to backward
---this action will not free the queue until it reaches the point
ActionController.move_backward = function(distance, condition_args, activation_conditions, on_update)
    --move_target = move_target or {}
    local condition_args = condition_args or {}
    condition_args.distance = distance

    on_update = on_update or {}
    on_update[#on_update+1] = ActionController.on_update.move_backward

    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.move_to_point,
        move_target = nil, --move_target = {move_target[1] or 0, move_target[2] or 0, move_target[3] or 0},
        activation_conditions = activation_conditions or {},
        update = ActionController.update_functions.move_to_point,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param duration any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will not free the queue until it reaches the point
ActionController.wait = function(duration, condition_args, activation_conditions, on_update)
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.wait,
        charge_time = duration,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.default,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param move_target any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will free the queue immediately
ActionController.set_move_target = function(move_target, condition_args, activation_conditions, on_update)
    --move_target = move_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.set_move_target,
        move_target = move_target, --move_target = {move_target[1] or 0, move_target[2] or 0, move_target[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.set_move_target,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param facing_target any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will wait until the bot is facing the correct position before freeing the queue
ActionController.face_point = function(facing_target, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.face_target,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.face_point,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param facing_target any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will wait until the bot is facing the correct position before freeing the queue
ActionController.set_facing_point = function(facing_target, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.face_target,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.set_facing_point,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@return table
---forces the bot to turn 180 degrees
---this action will free the queue immediately
ActionController.turn_around = function()
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.face_target,
        --facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.face_point,
        on_update = ActionController.on_update.turn_around,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param facing_target any
---@param charge_time any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will free the queue immediately
ActionController.weapon = function(facing_target, charge_time, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.weapon_swing,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        charge_time = charge_time or 0,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.weapon,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.weapon,
    }
end

---ability_action
---@param facing_target any
---@param elements any|function
---@param self_cast any
---@param charge_time any
---@param condition_args any|nil
---@param activation_conditions any|nil
---@param on_update any|nil
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will free the queue immediately
ActionController.spell = function(facing_target, elements, self_cast, charge_time, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        charge_time = charge_time or 0,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = self_cast,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_spell,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param facing_target any
---@param elements any
---@param charge_time any
---@param condition_args any|nil
---@param activation_conditions any|nil
---@param on_update any|nil
---@return table
---similar to cast_spell but charge time is a value between 0 and 1 where 1 is the maximum charge time, above 1 is overcharged
---the value is not in seconds but a percentage of the maximum charge time
---this action will free the queue immediately
ActionController.projectile = function(facing_target, elements, charge_time, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        charge_time = charge_time or 0,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = false,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_projectile_spell, --here we use a different update function
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param facing_target any
---@param elements any
---@param charge_time any
---@param condition_args any|nil
---@param activation_conditions any|nil
---@param on_update any|nil
---@return table
---similar to cast_spell but charge time is a value between 0 and 1 where 1 is the maximum charge time, above 1 is overcharged
---the value is not in seconds but a percentage of the maximum charge time
---this action will free the queue immediately
ActionController.beam = function(facing_target, elements, charge_time, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        charge_time = charge_time or 0,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = false,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_spell, --here we use a different update function
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param facing_target any
---@param elements any
---@param charge_time any
---@param condition_args any|nil
---@param activation_conditions any|nil
---@param on_update any|nil
---@return table
---similar to cast_spell but charge time is a value between 0 and 1 where 1 is the maximum charge time, above 1 is overcharged
---the value is not in seconds but a percentage of the maximum charge time
---this action will free the queue immediately
ActionController.spray = function(facing_target, elements, charge_time, condition_args, activation_conditions, on_update)
    --facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = facing_target, -- {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        charge_time = charge_time or 0,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = false,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_spell, --here we use a different update function
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param elements any
---@param condition_args any
---@param activation_conditions any
---@return table
---similar to cast_spell but with only elements as args
ActionController.self_cast = function(elements, condition_args, activation_conditions, on_update)
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = true,
        activation_conditions = activation_conditions,
        on_update = on_update,
        update = ActionController.update_functions.cast_spell, --here we use a different update function
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param elements any
---@param charge_time any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will free the queue immediately
ActionController.self_channel = function(elements, charge_time, condition_args, activation_conditions, on_update)
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        charge_time = charge_time or 0,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = true,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_spell,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param elements any
---@param condition_args any
---@param activation_conditions any
---@return table
---similar to self_cast_spell but will only activate the ward if the bot is not already warded with the same elements
---this action will free the queue immediately
ActionController.ward = function(elements, condition_args, activation_conditions)
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = true,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_ward_spell, --here we use a different update function
        deactivate = ActionController.deactivate_functions.default,
    }
end

---ability_action
---@param target_pos any
---@param magick any
---@param condition_args any
---@param activation_conditions any
---@param on_update any
---@return table
---recieves a point to move to and returns a table with the action type and the point
---this action will free the queue immediately
ActionController.magick = function(target_pos, magick, condition_args, activation_conditions, on_update)
    --target_pos = target_pos or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.magick,
        target_pos = target_pos,
        facing_target = target_pos,
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_magick,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
        magick = magick,
        elements = {}
    }
end

---ability_action
---@param action any
---@param condition_args any
---@return any
ActionController.new_action = function(action, condition_args)
    action.condition_args = action.condition_args  or (condition_args or {})
    return action
end

---ability_action
---list of available conditions that can be put into a spell 
ActionController.activation_conditions = {
    bot_is_wet = function(queued_ability, ai_data, dt)

        if ai_data.self_data.status.wet then
            return true
        end
        return true
    end,
    bot_is_not_wet = function(queued_ability, ai_data, dt)

        if ai_data.self_data.status.wet then
            return false
        end
        return true
    end,
    target_not_shielded = function(queued_ability, ai_data, dt)
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then return true end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if helper.target_blocked_by_shield(ai_data) then
            print("Oh wow there is a shield blocking this player, we should skip this spell: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            return false
        end
        print("target is not blocked by shield!")
        return true
    end,
    target_not_warded = function(queued_ability, ai_data, dt)
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then return true end

        local similar_elements = helper.similar_elements(queued_ability.elements, ai_data.target_data.ward_elements, e)
        printf("similar elements to wanted spell %s vs target ward %s is: %s", TABLE_TO_STRING_ONE_LINE(queued_ability.elements), TABLE_TO_STRING_ONE_LINE(ai_data.target_data.ward_elements), tostring(similar_elements))
        if similar_elements >= 1 then
            return false
        end
        return true
    end,
    teleport_towards_target_is_valid = function(queued_ability, ai_data, dt)
        local temp_target = MOVE_TOWARDS_POINT(ai_data.self_data.position_table, ai_data.target_unit_data.position_table, queued_ability.condition_args.wanted_range or 5)
        local is_valid = helper.map_point_is_valid(temp_target) and HelperLibrary.teleport_towards_target_is_valid(ai_data)
        return is_valid
    end,
    no_shield_shield_in_line_of_sight = function(queued_ability, ai_data, dt)
        return not helper.shield_in_line_of_sight(ai_data)
    end,
    within_range = function(queued_ability, ai_data, dt)
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then return true end

        local distance_to_target = ai_data.target_distance

        queued_ability.condition_args.minimum_range = queued_ability.condition_args.minimum_range or 0
        queued_ability.condition_args.maximum_range = queued_ability.condition_args.maximum_range or 1000000

        if not queued_ability.condition_args.minimum_range or not queued_ability.condition_args.maximum_range then
            print("within_range error, condition_args.minimum_range or condition_args.maximum_range is nil\n".. PAIRS_TO_STRING(queued_ability))
        end

        if distance_to_target < queued_ability.condition_args.minimum_range or distance_to_target > queued_ability.condition_args.maximum_range then
            print("unable to cast spell as target is outside of minimum_range/maximum_range: " .. tostring(distance_to_target) .. "\n" .. PAIRS_TO_STRING(queued_ability))
            return false
        end

        print("target is within range! ".. tostring(distance_to_target))
        return true
    end,
    target_is_valid = function(queued_ability, ai_data, dt)
        if not ai_data.target_unit or not unit_utilities.unit_is_valid(ai_data.target_unit) or ai_data.target_unit == ai_data.bot_unit then
            print("target is not valid or is targeting self!")
            return false
        end
        --print("target is valid!")
        return true
    end,
    target_is_frozen = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if not target_data.status.frozen then
            return false
        end
        return true
    end,
    target_is_chilled = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if not target_data.status.chilled then
            return false
        end
        return true
    end,
    target_is_wet = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if not target_data.status.wet then
            return false
        end
        return true
    end,
    target_is_burning = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if not target_data.status.burning then
            return false
        end
        return true
    end,
    target_has_no_status = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if target_data.status.burning or target_data.status.wet or target_data.status.chilled or target_data.status.frozen then
            return false
        end
        return true
    end,
    bot_already_warded = function(queued_ability, ai_data, dt)
        if spell_utilities.spell_equals(ai_data.self_data.ward_elements, queued_ability.elements) then
            return false
        end
        return true
    end,
    bot_needs_ward = function(queued_ability, ai_data, dt)
        if ai_data.wanted_ward and ai_data.ward_needed and (not ai_data.timers["apply_ward_cooldown"]) then
            return false
        end
        return true
    end,
    bot_needs_shield = function(queued_ability, ai_data, dt)
        return not helper.player_needs_shield(ai_data)
    end,

}

--Do not make changes unless you really know what you are doing!
ActionController.update_functions = {
    default = function(queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        --call on_update if it exists
        run_on_updates(queued_ability, ai_data, dt)

        queued_ability.duration = (queued_ability.duration or 0)
		--printf("charge_time: %s update %s duration: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration))

        if queued_ability.duration > (queued_ability.charge_time or 0) then
            queued_ability.stop_ability = true
            return
        end

        --set max duration so that if bot is stuck if will cancel the ability and move on
        if queued_ability.condition_args.max_duration then
            if queued_ability.condition_args.max_duration <= queued_ability.duration then
                print("Ability cancelled due to maximum duration!: " .. tostring(queued_ability.duration))
                queued_ability.stop_ability = true
            end
        end

        queued_ability.stop_ability = false
        queued_ability.duration = queued_ability.duration + dt
    end,
    weapon = function(queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        --call on_update if it exists
        run_on_updates(queued_ability, ai_data, dt)

		--calculate duration
		queued_ability.duration = (queued_ability.duration or 0)
		queued_ability.waiting_time = (queued_ability.waiting_time or 0)

        --if there is no charge time, set it to 0.05 as a default so the 
        --bot doesn't just skip the animation timing
        --if queued_ability.charge_time == 0 then queued_ability.charge_time = 0.1 end
        local char_ext = EntityAux.extension(ai_data.bot_unit, "character")
        if ai_data.self_data.state == "knocked_down" or char_ext.input.pushed then
            printf("spell cancelled to cast due to state: %s or pushed: %s - %s", tostring(ai_data.self_data.state), tostring(char_ext.input.pushed), PAIRS_TO_STRING(queued_ability, 0))
            ai_data.channel = false
            queued_ability.stop_ability = true
        end

        --set max duration so that if bot is stuck if will cancel the ability and move on
        if queued_ability.condition_args.max_duration then
            if queued_ability.condition_args.max_duration <= queued_ability.duration then
                print("Ability cancelled due to maximum duration!: " .. tostring(queued_ability.duration))
                queued_ability.stop_ability = true
            end
        end

		--cancel if knockdown or charged time reached
        -- catch if the bot gets pushed or something
		if (queued_ability.duration > queued_ability.charge_time and (ai_data.self_data.state == "melee"))
        or (ai_data.self_data.state ~= "melee" and queued_ability.duration > 1)
        then
            printf("stop_ability weapon charge_time: %s update %s duration: %s current_state: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration), tostring(ai_data.self_data.state))
			ai_data.melee = false
			ai_data.channel = false
            queued_ability.stop_ability = true
			return
		end
		
        if ai_data.self_data.state == "onground" or ai_data.self_data.state == "melee" then
            ai_data.melee = true
            ai_data.channel = true
            queued_ability.stop_ability = false
            queued_ability.ability_started = true
            printf("weapon melee swing started charge_time: %s update %s duration: %s weapon_ability_cooldown_time: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration), tostring(ai_data.self_data.weapon_ability_cooldown_time))
        else
            printf("weapon delay due to state change charge_time: %s update %s duration: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration))
        end

        if queued_ability.ability_started then
            printf("weapon charge_time: %s update %s duration: %s waiting_time: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration), tostring(queued_ability.waiting_time))
            queued_ability.duration = queued_ability.duration + dt
        end
        queued_ability.waiting_time = queued_ability.waiting_time + dt
	end,
    move_to_point = function (queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end

        --call on_update if it exists
        run_on_updates(queued_ability, ai_data, dt)

        queued_ability.duration = (queued_ability.duration or 0)
        
        local distance_to_target = DISTANCE(queued_ability.move_target, ai_data.self_data.position_table)

        if distance_to_target <= 0.1 then
            queued_ability.stop_ability = true
        end

        if queued_ability.condition_args.max_duration then
            if queued_ability.condition_args.max_duration <= queued_ability.duration then
                print("Ability cancelled due to maximum duration!: " .. tostring(queued_ability.duration))
                queued_ability.stop_ability = true
            end
        end

        --printf("move_to_point update %s duration: %s distance_to_target: %s", queued_ability.action, tostring(queued_ability.duration), tostring(distance_to_target))
        queued_ability.duration = queued_ability.duration + dt
    end,
    set_move_target = function (queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        --call on_update if it exists
        run_on_updates(queued_ability, ai_data, dt)
        
        queued_ability.duration = (queued_ability.duration or 0)
        
        local distance_to_target = DISTANCE(queued_ability.move_target, ai_data.self_data.position_table)
        queued_ability.stop_ability = true

        --printf("move_to_point update %s duration: %s distance_to_target: %s", queued_ability.action, tostring(queued_ability.duration), tostring(distance_to_target))
        queued_ability.duration = queued_ability.duration + dt
    end,
    face_point = function (queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        --call on_update if it exists
        run_on_updates(queued_ability, ai_data, dt)

        queued_ability.duration = (queued_ability.duration or 0)
        queued_ability.max_duration = queued_ability.condition_args.max_duration or 1
        
        local target_to_rotate_to = TO_VECTOR(queued_ability.facing_target)
        local bot_pos = unit_utilities.get_unit_position(ai_data.bot_unit)
        local bot_forward = unit_utilities.get_unit_forward(ai_data.bot_unit)
        local bot_forward_position = bot_pos + bot_forward

        if DISTANCE_POINT_OR_VECTOR(target_to_rotate_to, ai_data.self_data.position_table) <= 0.2 then
            queued_ability.stop_ability = true
            print("can't rotate to point that is less than 0.2 units away")
        end
        
        local angle_between = CALCULATE_ANGLE_BETWEEN_POINTS(bot_pos, bot_forward_position, target_to_rotate_to)

        if angle_between <= 5 or queued_ability.duration > queued_ability.max_duration then
            queued_ability.stop_ability = true
        end

        printf("face_point update %s duration: %s angle_between: %s", queued_ability.action, tostring(queued_ability.duration), tostring(angle_between))
        queued_ability.duration = queued_ability.duration + dt
    end,
    set_facing_point = function (queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        --call on_update if it exists
        run_on_updates(queued_ability, ai_data, dt)

        queued_ability.duration = (queued_ability.duration or 0)
        
        local target_to_rotate_to = TO_VECTOR(queued_ability.facing_target)
        local bot_pos = unit_utilities.get_unit_position(ai_data.bot_unit)
        local bot_forward = unit_utilities.get_unit_forward(ai_data.bot_unit)
        local bot_forward_position = bot_pos + bot_forward

        if DISTANCE_POINT_OR_VECTOR(target_to_rotate_to, ai_data.self_data.position_table) <= 0.2 then
            queued_ability.stop_ability = true
            print("can't rotate to point that is less than 0.2 units away")
        end
        
        local angle_between = CALCULATE_ANGLE_BETWEEN_POINTS(bot_pos, bot_forward_position, target_to_rotate_to)

        if true then
            queued_ability.stop_ability = true
        end

        printf("set_face_point update %s duration: %s angle_between: %s", queued_ability.action, tostring(queued_ability.duration), tostring(angle_between))
        queued_ability.duration = queued_ability.duration + dt
    end,
    cast_spell = function (queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        queued_ability.duration = (queued_ability.duration or 0)
        queued_ability.waiting_time = (queued_ability.waiting_time or 0) + dt
        queued_ability.charge_time = queued_ability.charge_time or 0
        queued_ability.elements = queued_ability.elements or {}

        local char_ext = EntityAux.extension(ai_data.bot_unit, "character")

        run_on_updates(queued_ability, ai_data, dt)

        --printf("spell update state: %s %s", tostring(ai_data.self_data.state), PAIRS_TO_STRING(queued_ability, 0))

        if ai_data.self_data.state == "knocked_down" or char_ext.input.pushed and queued_ability.spell_queue_started then
            printf("spell cancelled to cast due to state: %s or pushed: %s - %s", tostring(ai_data.self_data.state), tostring(char_ext.input.pushed), PAIRS_TO_STRING(queued_ability, 0))
            ai_data.channel = false
            queued_ability.stop_ability = true
        end

        --set max duration so that if bot is stuck if will cancel the ability and move on
        if queued_ability.condition_args.max_duration then
            if queued_ability.condition_args.max_duration <= queued_ability.duration then
                print("Ability cancelled due to maximum duration!: " .. tostring(queued_ability.duration))
                queued_ability.stop_ability = true
            end
        end

        --first if the bot is in a state that can't start casting, wait until it can
        if ai_data.self_data.state ~= "onground" and not queued_ability.spell_queue_started then
            printf("spell waiting to cast due to state: %s %s", tostring(ai_data.self_data.state), PAIRS_TO_STRING(queued_ability, 0))
            
            return
        elseif ai_data.self_data.state == "onground" and not queued_ability.spell_queue_started then
            queued_ability.spell_queue_started = true

            --send spell to be queued
            if queued_ability.self_cast then
                ai_data.self_cast = true
            else
                ai_data.self_cast = false
                ai_data.spell_cast = true
            end
            
            --set the spell queue
            ai_data.spell_index = 1
            ai_data.spell_queue_n = #queued_ability.elements
            ai_data.spell_queue = queued_ability.elements

            --set the channeling state to trigger
            ai_data.channel = true

            printf("spell queue started %s", PAIRS_TO_STRING(queued_ability, 2))
        end

        --printf ("we should be expectinge a casting state soon... %s %s %s ", tostring(queued_ability.spell_queue_started ), tostring(not queued_ability.casting_started), tostring((ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling")))

        --the bot has sent the spell to be cast we need to wait until it actually starts casting before we calculate the duration
        if queued_ability.spell_queue_started 
        and not queued_ability.casting_started
        and (ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling" or ai_data.self_data.state == "chargeup") 
        then
            queued_ability.casting_started = true
            printf("spell casting started %s", PAIRS_TO_STRING(queued_ability, 2))
            return
        end

        --the bot is now channeling update the duration 
        if queued_ability.casting_started and not queued_ability.casting_ended then
            queued_ability.duration = (queued_ability.duration or 0) + dt
            --printf("spell channeling %s", PAIRS_TO_STRING(queued_ability, 0))

            --check if the bot is still channeling
            if (ai_data.self_data.state ~= "casting" and ai_data.self_data.state ~= "channeling" and ai_data.self_data.state ~= "chargeup")
            or queued_ability.duration > queued_ability.charge_time
            then
                queued_ability.casting_ended = true

                --update the channeling state to stop the active ability
                ai_data.melee = false
                ai_data.channel = false
                printf("spell casting ended %s", PAIRS_TO_STRING(queued_ability, 0))
                return
            end
        end

        --the bot has stopped casting, we need to wait until the animation has finished
        if queued_ability.casting_ended and not queued_ability.casting_animation_ended and ai_data.self_data.state == "onground" then
            queued_ability.casting_animation_ended = true
            queued_ability.stop_ability = true

            printf("spell casting animation ended %s", PAIRS_TO_STRING(queued_ability, 0))
        end
    end,
    cast_ward_spell = function (queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        queued_ability.duration = (queued_ability.duration or 0) --+ dt
        queued_ability.waiting_time = (queued_ability.waiting_time or 0) + dt
        queued_ability.charge_time = queued_ability.charge_time or 0
        queued_ability.elements = queued_ability.elements or {}
        local char_ext = EntityAux.extension(ai_data.bot_unit, "character")

        run_on_updates(queued_ability, ai_data, dt)

        if queued_ability.on_update then
            --print("on_update: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.on_update(queued_ability, ai_data, dt)
        end

        --printf("spell update state: %s %s", tostring(ai_data.self_data.state), PAIRS_TO_STRING(queued_ability, 0))

        if ai_data.self_data.state == "knocked_down" or char_ext.input.pushed and queued_ability.spell_queue_started then
            printf("spell cancelled to cast due to state: %s or pushed: %s - %s", tostring(ai_data.self_data.state), tostring(char_ext.input.pushed), PAIRS_TO_STRING(queued_ability, 0))
            ai_data.channel = false
            queued_ability.stop_ability = true
        end

        --first if the bot is in a state that can't start casting, wait until it can
        if ai_data.self_data.state ~= "onground" and not queued_ability.spell_queue_started then
            printf("spell waiting to cast due to state: %s %s", tostring(ai_data.self_data.state), PAIRS_TO_STRING(queued_ability, 0))
            return
        elseif ai_data.self_data.state == "onground" and not queued_ability.spell_queue_started then
            queued_ability.spell_queue_started = true

            --send spell to be queued
            if queued_ability.self_cast then
                ai_data.self_cast = true
            else
                ai_data.self_cast = false
                ai_data.spell_cast = true
            end
            
            --set the spell queue
            ai_data.spell_index = 1
            ai_data.spell_queue_n = #queued_ability.elements
            ai_data.spell_queue = queued_ability.elements

            --set the channeling state to trigger
            ai_data.channel = true

            printf("spell queue started %s", PAIRS_TO_STRING(queued_ability, 2))
        end

        --printf ("we should be expectinge a casting state soon... %s %s %s ", tostring(queued_ability.spell_queue_started ), tostring(not queued_ability.casting_started), tostring((ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling")))

        --the bot has sent the spell to be cast we need to wait until it actually starts casting before we calculate the duration
        if queued_ability.spell_queue_started 
        and not queued_ability.casting_started
        and (ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling" or ai_data.self_data.state == "chargeup") 
        then
            queued_ability.casting_started = true
            printf("spell casting started %s", PAIRS_TO_STRING(queued_ability, 2))
            return
        end

        --the bot is now channeling update the duration 
        if queued_ability.casting_started and not queued_ability.casting_ended then
            queued_ability.duration = (queued_ability.duration or 0) + dt
            --printf("spell channeling %s", PAIRS_TO_STRING(queued_ability, 0))

            --check if the bot is still channeling
            if (ai_data.self_data.state ~= "casting" and ai_data.self_data.state ~= "channeling" and ai_data.self_data.state ~= "chargeup")
            or queued_ability.duration > queued_ability.charge_time
            then
                queued_ability.casting_ended = true

                --update the channeling state to stop the active ability
                ai_data.melee = false
                ai_data.channel = false
                printf("spell casting ended %s", PAIRS_TO_STRING(queued_ability, 0))
                return
            end
        end

        --the bot has stopped casting, we need to wait until the animation has finished
        if queued_ability.casting_ended and not queued_ability.casting_animation_ended and ai_data.self_data.state == "onground" then
            queued_ability.casting_animation_ended = true
            queued_ability.stop_ability = true

            printf("spell casting animation ended %s", PAIRS_TO_STRING(queued_ability, 0))
        end
    end,
    cast_projectile_spell = function(queued_ability, ai_data, dt)
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end
        
        queued_ability.duration = (queued_ability.duration or 0) --+ dt
        queued_ability.waiting_time = (queued_ability.waiting_time or 0) + dt
        queued_ability.elements = queued_ability.elements or {}
        queued_ability.charge_time = queued_ability.charge_time or 0
        local char_ext = EntityAux.extension(ai_data.bot_unit, "character")

        run_on_updates(queued_ability, ai_data, dt)

        --printf("spell update state: %s %s", tostring(ai_data.self_data.state), PAIRS_TO_STRING(queued_ability, 0))

        if ai_data.self_data.state == "knocked_down" or char_ext.input.pushed and queued_ability.spell_queue_started then
            printf("spell cancelled to cast due to state: %s or pushed: %s - %s", tostring(ai_data.self_data.state), tostring(char_ext.input.pushed), PAIRS_TO_STRING(queued_ability, 0))
            ai_data.channel = false
            queued_ability.stop_ability = true
        end

        --set max duration so that if bot is stuck if will cancel the ability and move on
        if queued_ability.condition_args.max_duration then
            if queued_ability.condition_args.max_duration <= queued_ability.duration then
                print("Ability cancelled due to maximum duration!: " .. tostring(queued_ability.duration))
                queued_ability.stop_ability = true
            end
        end

        --the bot is now channeling update the duration 
        if queued_ability.casting_started and not queued_ability.casting_ended then
            queued_ability.duration = (queued_ability.duration or 0) + dt
            --printf("spell channeling %s", PAIRS_TO_STRING(queued_ability, 0))

            --check if the bot is still channeling
            if (ai_data.self_data.state ~= "casting" and ai_data.self_data.state ~= "channeling" and ai_data.self_data.state ~= "chargeup")
            or ai_data.self_data.charge_time > queued_ability.charge_time
            then
                queued_ability.casting_ended = true

                --update the channeling state to stop the active ability
                ai_data.melee = false
                ai_data.channel = false
                printf("spell casting ended %s", PAIRS_TO_STRING(queued_ability, 0))
                return
            end
        end

        --first if the bot is in a state that can't start casting, wait until it can
        if ai_data.self_data.state ~= "onground" and not queued_ability.spell_queue_started then
            printf("spell waiting to cast due to state: %s %s", tostring(ai_data.self_data.state), PAIRS_TO_STRING(queued_ability, 0))
            return
        elseif ai_data.self_data.state == "onground" and not queued_ability.spell_queue_started then
            queued_ability.spell_queue_started = true

            --send spell to be queued
            if queued_ability.self_cast then
                ai_data.self_cast = true
            else
                ai_data.self_cast = false
                ai_data.spell_cast = true
            end
            
            --set the spell queue
            ai_data.spell_index = 1
            ai_data.spell_queue_n = #queued_ability.elements
            ai_data.spell_queue = queued_ability.elements

            --set the channeling state to trigger
            ai_data.channel = true

            printf("spell queue started %s", PAIRS_TO_STRING(queued_ability, 2))
        end

        --printf ("we should be expectinge a casting state soon... %s %s %s ", tostring(queued_ability.spell_queue_started ), tostring(not queued_ability.casting_started), tostring((ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling")))

        --the bot has sent the spell to be cast we need to wait until it actually starts casting before we calculate the duration
        if queued_ability.spell_queue_started 
        and not queued_ability.casting_started
        and (ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling" or ai_data.self_data.state == "chargeup") 
        then
            queued_ability.casting_started = true
            printf("spell casting started %s", PAIRS_TO_STRING(queued_ability, 2))
            return
        end

        --the bot is now channeling update the duration 
        if queued_ability.casting_started and not queued_ability.casting_ended then
            queued_ability.duration = (queued_ability.duration or 0) + dt
            --printf("spell channeling %s", PAIRS_TO_STRING(queued_ability, 0))

            --check if the bot is still channeling
            if (ai_data.self_data.state ~= "casting" and ai_data.self_data.state ~= "channeling" and ai_data.self_data.state ~= "chargeup")
            or ai_data.self_data.charge_time > queued_ability.charge_time
            then
                queued_ability.casting_ended = true

                --update the channeling state to stop the active ability
                ai_data.melee = false
                ai_data.channel = false
                printf("spell casting ended %s", PAIRS_TO_STRING(queued_ability, 0))
                return
            end
        end

        --the bot has stopped casting, we need to wait until the animation has finished
        if queued_ability.casting_ended and not queued_ability.casting_animation_ended and ai_data.self_data.state == "onground" then
            queued_ability.casting_animation_ended = true
            queued_ability.stop_ability = true

            printf("spell casting animation ended %s", PAIRS_TO_STRING(queued_ability, 0))
        end
    end,
    cast_magick = function(queued_ability, ai_data, dt)
        print("update cast_magick 1")
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end

        print("update cast_magick")

        run_on_updates(queued_ability, ai_data, dt)

        local char_ext = EntityAux.extension(ai_data.bot_unit, "character")

        if ai_data.self_data.state == "knocked_down" or char_ext.input.pushed then
            printf("spell cancelled to cast due to state: %s or pushed: %s - %s", tostring(ai_data.self_data.state), tostring(char_ext.input.pushed), PAIRS_TO_STRING(queued_ability, 0))
            ai_data.channel = false
            queued_ability.stop_ability = true
        end

        --set max duration so that if bot is stuck if will cancel the ability and move on
        if queued_ability.condition_args.max_duration then
            if queued_ability.condition_args.max_duration <= queued_ability.duration then
                print("Ability cancelled due to maximum duration!: " .. tostring(queued_ability.duration))
                queued_ability.stop_ability = true
            end
        end
        
        queued_ability.duration = (queued_ability.duration or 0)
        queued_ability.waiting_time = (queued_ability.waiting_time or 0)
        queued_ability.charge_time = queued_ability.charge_time or 0
        queued_ability.casting_frames = queued_ability.casting_frames or 0
        queued_ability.casting_stage = queued_ability.casting_stage or 0

        local magick_completed_frames = 10
        --print("cast magick update:\n" .. PAIRS_TO_STRING(queued_ability))
		
        MagickUserExtension.update_pending_magick(queued_ability, ai_data)

        if queued_ability.casting_frames >= magick_completed_frames and ai_data.self_data.state == "onground" and queued_ability.casting_stage == 3 then
            queued_ability.magick_completed = true
        end
        
		if (queued_ability.waiting_time > 0.1 and queued_ability.casting_frames >= magick_completed_frames and queued_ability.magick_completed) 
        or (ai_data.self_data.state == "knocked_down" or char_ext.input.pushed)
        then
			queued_ability.stop_ability = true	
		end

        queued_ability.waiting_time = (queued_ability.waiting_time or 0) + dt
        queued_ability.casting_frames = queued_ability.casting_frames + 1
    end,
}

--Do not make changes unless you really know what you are doing!
ActionController.deactivate_functions = {
    default = function(queued_ability, ai_data, dt)			
        ai_data.melee = false
        ai_data.channel = false
        queued_ability.stop_ability = true
        printf("deactivate %s total duration: %s total time spent: %s", queued_ability.action, tostring(queued_ability.duration), tostring(queued_ability.waiting_time))
    end,
    weapon = function(queued_ability, ai_data, dt)			
        ai_data.melee = false
        ai_data.channel = false
        queued_ability.stop_ability = true
        printf("weapon deactivate %s total duration: %s total time spent: %s", queued_ability.action, tostring(queued_ability.duration), tostring(queued_ability.waiting_time))
    end
}

--used to calculate a realitive wanted angle
--eg if an ability wants to face towards the target plus 25 degrees
--this function may be used
--do not ask why this isn't in the pathing file
local function calculate_look_at_point(point_a, point_b, angle)
    -- Convert angle to radians
    local angle_rad = math.rad(angle)

    -- Calculate the vector from point_a to point_b
    local vector_x = point_b.x - point_a.x
    local vector_y = point_b.y - point_a.y

    -- Calculate the distance between the two points
    local distance = math.sqrt(vector_x^2 + vector_y^2)
    if distance == 0 then distance = distance + 0.001 end

    -- Normalize the vector
    local norm_vector_x = vector_x / distance
    local norm_vector_y = vector_y / distance

    -- Calculate the rotated vector using the angle
    local rotated_x = norm_vector_x * math.cos(angle_rad) - norm_vector_y * math.sin(angle_rad)
    local rotated_y = norm_vector_x * math.sin(angle_rad) + norm_vector_y * math.cos(angle_rad)

    -- Calculate the new point
    local look_at_point = {
        point_a.x + rotated_x * distance,
        point_a.y + rotated_y * distance,
        point_a.z -- Assuming z remains unchanged
    }

    return look_at_point
end

--do not ask why this isn't in the pathing file
local function calculate_pdx_pathing(queued_ability, ai_data, dt)
    queued_ability.move_target = queued_ability.move_target or table.deep_clone(ai_data.self_data.position_table or {0,0,0})

    if (GLOBAL_CANE_NAVMESH_QUERRY and not ai_data.timers.navmesh_timer) and not ai_data.using_neon_pathing then
        --pdDebug.text("-----------------path_waiting...")
        ai_data.timers.navmesh_timer = 0.1
        local path, path_n = PathAux_get_path(GLOBAL_CANE_NAVMESH_QUERRY, GET_UNIT_POS(ai_data.bot_unit), TO_VECTOR(queued_ability.pathing_target or ai_data.wanted_position))

        if path_n > 0 then
            if path_n >= 2 then table.remove(path, 1) end
            ai_data.current_path = path
        else
            ai_data.current_path = nil
        end
        
    elseif not GLOBAL_CANE_NAVMESH_QUERRY then
        --pdDebug.text("-----------------GLOBAL_CANE_NAVMESH_QUERRY does not exist yet!")
    end

    ai_data.temp_move_target = nil
    if ai_data.current_path and #ai_data.current_path >= 1 then

        local dist_to_path_point = DISTANCE_POINT_OR_VECTOR(ai_data.current_path[1], ai_data.self_data.position_table)

        --pdDebug.text("---------------------Distance to path point: " .. tostring(dist_to_path_point))

        ai_data.temp_move_target = table.deep_clone(ai_data.current_path[1])

        if dist_to_path_point < 0.2 then
            table.remove(ai_data.current_path, 1)
        end
    else
        ai_data.temp_move_target = table.deep_clone(queued_ability.pathing_target or ai_data.self_data.position_table)
    end

    -- pdDebug.text("-----------------Move Pos: %s", PAIRS_TO_STRING(queued_ability.move_target))
    -- pdDebug.text("-----------------Self Pos: %s", PAIRS_TO_STRING(ai_data.self_data.position_table))
    -- pdDebug.text("-----------------#Path: %s", tostring(#(ai_data.current_path or {})))

    queued_ability.move_target = VEC_TO_TABLE(ai_data.temp_move_target or queued_ability.pathing_target or ai_data.self_data.position_table)
end

--the pathing system in MWW is broken garbage, and mine is also awful
--to get around limitations of both a hybrid system is used to swap between
--the two systems when needed
--may cause hair loss, cancer, and other side effects if used
--do not ask why this isn't in the pathing file
local function calculate_pathing_target(queued_ability, ai_data, dt)
    ai_data.self_position = unit_utilities.get_unit_position(ai_data.bot_unit)

    if ai_data.use_pathing_aux then
        calculate_pdx_pathing(queued_ability, ai_data, dt)
    else
        --pdDebug.text("-----------------Wanted Pos: %s", PAIRS_TO_STRING(ai_data.wanted_position))

        ai_data.current_path = ai_data.current_path or {}
        ai_data.temp_move_target = ai_data.temp_move_target or VEC_TO_TABLE(ai_data.self_data.position_table)

        if not BotPathing:path_waiting() then
            BotPathing:astar(VEC_TO_TABLE(ai_data.self_data.position_table), queued_ability.pathing_target or VEC_TO_TABLE(ai_data.self_data.position_table))
            --pdDebug.text("-----------------path_waiting...")
        end

        --run the update functions to get the next paths
        local new_path = BotPathing:update()

        --if the path is finished process it & remove points that are too close
        if new_path then
            --ai_data.using_neon_pathing = true
            --loop over new path to make sure closest point is next point
            local closest_path_point = new_path[#new_path]
            local closest_path_index = #new_path
            for i = 1, #new_path, 1 do
                if DISTANCE_POINT_OR_VECTOR(ai_data.self_data.position_table, new_path[i]) < DISTANCE_POINT_OR_VECTOR(ai_data.self_data.position_table, closest_path_point) then
                    --print("path found point closer! ")
                    closest_path_index = i
                end
            end

            --remake the path but exclude all points before the closest point
            if closest_path_index ~= #new_path then
                --print("trimming path as was poop when doing the thing")
                local temp_path = {}
                for i = 1, closest_path_index, 1 do
                    table.insert(temp_path, new_path[i])
                end
                new_path = temp_path
            end

            --pdDebug.text("-----------------new path...")
            --print("found new path: ")
        end

        --set the current_path to a new path if there is one
        ai_data.current_path = new_path or ai_data.current_path

        --check to see if the bot is within range of the next path position
        local next_pathing_pos = ai_data.current_path[#ai_data.current_path]
        if next_pathing_pos then

            --check to see if the point has been reached and remove it
            local _dist = DISTANCE_POINT_OR_VECTOR(ai_data.self_data.position_table, next_pathing_pos)
            if _dist < 1.5 then
                table.remove(ai_data.current_path, #ai_data.current_path)
            end

            next_pathing_pos = ai_data.current_path[#ai_data.current_path]

            if next_pathing_pos then
                --check if bot is facing target
                local bot_forward = UnitAux.forward(ai_data.bot_unit, 0)
                local bot_wanted_forward = Vector3.normalize(TO_VECTOR(next_pathing_pos) - GET_UNIT_POS(ai_data.bot_unit))
                local window = UA_forward_angle(bot_forward, bot_wanted_forward)
                if window < 20 then
                    ai_data.can_move_towards_target = true
                end

                if #ai_data.current_path >= 2 then
                    ai_data.temp_move_target = VEC_TO_TABLE(MOVE_TOWARDS_TABLE(ai_data.self_data.position_table, next_pathing_pos, ai_data.move_distance or 10))
                else
                    --pdDebug.text("-------------------------------bot has reached target point!")
                    ai_data.temp_move_target = next_pathing_pos or table.deep_clone(BotPathing:find_closest_valid_position(ai_data.self_data.position_table, 8) or ai_data.self_data.position_table) --pathing_pos or table.deep_clone(ai_data.self_data.position_table)
                end
            end
        else
            --pdDebug.text("-----------------missing path!")
            ai_data.temp_move_target = table.deep_clone(queued_ability.pathing_target or ai_data.self_data.position_table)
        end

        if #ai_data.current_path <= 0 then ai_data.using_neon_pathing = false end

        -- pdDebug.text("-----------------Move Pos: %s", PAIRS_TO_STRING(queued_ability.move_target))
        -- pdDebug.text("-----------------Self Pos: %s", PAIRS_TO_STRING(ai_data.self_data.position_table))
        -- pdDebug.text("-----------------#Path: %s", tostring(#ai_data.current_path))

        queued_ability.move_target = VEC_TO_TABLE(ai_data.temp_move_target)
    end

    ai_data.distance_to_move_target = DISTANCE_POINT_OR_VECTOR(queued_ability.move_target, ai_data.self_data.position_table)
    return queued_ability.move_target
end

---you can make changes here!
---list of functions that are called every update when using an ability
---can be used to cancel an ability when conditions changed or change
---where a spell is aimed
ActionController.on_update = {
    cancel_immediately = function(queued_ability, ai_data, dt)
        queued_ability.stop_ability = true
        ai_data.channel = false
    end,
    cancel_if_move_target_reached = function(queued_ability, ai_data, dt)
        if ai_data.distance_to_move_target <= 0.4 then
            print("cancel_if_move_target_reached: true dist: " .. tostring(ai_data.distance_to_move_target))
            queued_ability.stop_ability = true
            ai_data.channel = false
        else
            print("cancel_if_move_target_reached: false dist: " .. tostring(ai_data.distance_to_move_target))
        end
    end,
    face_target_unit = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.facing_target = VEC_TO_TABLE(unit_utilities.get_unit_position(ai_data.target_unit) or helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.facing_target
    end,
    face_move_pos = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.facing_target = VEC_TO_TABLE(queued_ability.move_target or helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.facing_target
    end,
    face_wanted_position = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.facing_target = VEC_TO_TABLE(ai_data.wanted_position or helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.facing_target
    end,
    face_magick_target = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.target_pos = VEC_TO_TABLE(unit_utilities.get_unit_position(ai_data.target_unit) or helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.target_pos
    end,
    target_self = function(queued_ability, ai_data, dt)
        queued_ability.facing_target = VEC_TO_TABLE(helper.get_unit_pos_and_facing(ai_data.bot_unit))
        queued_ability.target_pos = VEC_TO_TABLE(helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.facing_target
    end,
    target_away_from_enemy_or_zero_vector = function(queued_ability, ai_data, dt)
        if not ai_data.target_unit_data then return end
        local temp_target = MOVE_AWAY_FROM_POINT(ai_data.self_data.position_table, ai_data.target_unit_data.position_table, queued_ability.condition_args.wanted_range or 5)
        local is_valid = helper.map_point_is_valid(temp_target)
        if not is_valid then temp_target = {0,0,0} end
        queued_ability.facing_target = VEC_TO_TABLE(temp_target)
        queued_ability.target_pos = VEC_TO_TABLE(temp_target)
        return queued_ability.facing_target
    end,
    target_enemy_if_valid_pos = function(queued_ability, ai_data, dt)
        if not ai_data.target_unit_data then return end
        local temp_target = MOVE_TOWARDS_POINT(ai_data.self_data.position_table, ai_data.target_unit_data.position_table, queued_ability.condition_args.wanted_range or 5)
        local is_valid = helper.map_point_is_valid(temp_target) and HelperLibrary.teleport_towards_target_is_valid(ai_data)
        if not is_valid then temp_target = {0,0,0} end
        queued_ability.facing_target = VEC_TO_TABLE(temp_target)
        queued_ability.target_pos = VEC_TO_TABLE(temp_target)
        return queued_ability.facing_target
    end,
    target_away_from_enemy = function(queued_ability, ai_data, dt)
        --if not ai_data.target_unit_data then return end
        local temp_target = MOVE_AWAY_FROM_POINT(ai_data.self_data.position_table, ai_data.target_unit_data.position_table or ai_data.self_data.position_table, queued_ability.condition_args.wanted_range or 5)

        queued_ability.facing_target = VEC_TO_TABLE(temp_target)
        queued_ability.target_pos = VEC_TO_TABLE(temp_target)
        return queued_ability.facing_target
    end,
    target_towards_enemy = function(queued_ability, ai_data, dt)
        if not ai_data.target_unit_data then return end
        local temp_target = MOVE_TOWARDS_POINT(ai_data.self_data.position_table, ai_data.target_unit_data.position_table, 5)
        queued_ability.facing_target = VEC_TO_TABLE(temp_target)
        queued_ability.target_pos = VEC_TO_TABLE(temp_target)
        return queued_ability.facing_targett
    end,
    face_realitive_angle_to_target = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end
        if not queued_ability.condition_args.realitive_angle then print("error no realitive_angle!: ") PRINT_TABLE(queued_ability) return end

        queued_ability.facing_target = calculate_look_at_point(unit_utilities.get_unit_position(ai_data.bot_unit), unit_utilities.get_unit_position(ai_data.target_unit), queued_ability.condition_args.realitive_angle)
        return queued_ability.facing_target
    end,
    move_forward = function(queued_ability, ai_data, dt)
        queued_ability.pathing_target = queued_ability.pathing_target or VEC_TO_TABLE(MOVE_TOWARDS_POINT(ai_data.self_data.position_table, helper.get_unit_pos_and_facing(ai_data.bot_unit), queued_ability.condition_args.distance or 2))
        queued_ability.move_target = queued_ability.pathing_target
        return queued_ability.move_target
    end,
    move_backward = function(queued_ability, ai_data, dt)
        queued_ability.pathing_target = queued_ability.pathing_target or VEC_TO_TABLE(MOVE_AWAY_FROM_POINT(ai_data.self_data.position_table, helper.get_unit_pos_and_facing(ai_data.bot_unit), queued_ability.condition_args.distance or 2))
        queued_ability.move_target = queued_ability.pathing_target
        return queued_ability.move_target
    end,
    turn_around = function(queued_ability, ai_data, dt)
        queued_ability.turning_target = queued_ability.turning_target or VEC_TO_TABLE(MOVE_AWAY_FROM_POINT(ai_data.self_data.position_table, helper.get_unit_pos_and_facing(ai_data.bot_unit), queued_ability.condition_args.distance or 2))
        queued_ability.facing_target = queued_ability.turning_target
        return queued_ability.facing_target
    end,
    use_facing_data = function(queued_ability, ai_data, dt)
        queued_ability.duration = queued_ability.duration or 0
        --don't run the update if there isn't a target
        if not queued_ability.condition_args.facing_data then print("error no realitive_angle!: ") PRINT_TABLE(queued_ability) return end

        --get facing data current angle
        local facing_data = queued_ability.condition_args.facing_data
        queued_ability.current_facing_index = queued_ability.current_facing_index or 1

        local dt_step_multiplier = 2
        
        while facing_data[queued_ability.current_facing_index].duration <= (queued_ability.duration + (dt*dt_step_multiplier)) and queued_ability.current_facing_index < #facing_data do
            queued_ability.current_facing_index = queued_ability.current_facing_index + 1
        end
        
        local wanted_facing = facing_data[queued_ability.current_facing_index].self_window
        queued_ability.facing_target = calculate_look_at_point(unit_utilities.get_unit_position(ai_data.bot_unit), unit_utilities.get_unit_position(ai_data.target_unit), wanted_facing)
        return queued_ability.facing_target
    end,
    use_movement_data = function(queued_ability, ai_data, dt)
        queued_ability.duration = queued_ability.duration or 0
        --don't run the update if there isn't a target
        if not queued_ability.condition_args.movement_data then print("error no realitive_angle!: ") PRINT_TABLE(queued_ability) return end

        --get move data current angle
        local movement_data = queued_ability.condition_args.movement_data
        queued_ability.current_movement_index = queued_ability.current_movement_index or 1

        local dt_step_multiplier = 0
        
        while movement_data[queued_ability.current_movement_index].duration <= (queued_ability.duration + (dt*dt_step_multiplier)) and queued_ability.current_movement_index < #movement_data do
            queued_ability.current_movement_index = queued_ability.current_movement_index + 1
        end
        local wanted_facing = movement_data[queued_ability.current_movement_index].travel_angle
        if movement_data[queued_ability.current_movement_index].speed > 0.5 then
            queued_ability.move_target = calculate_look_at_point(unit_utilities.get_unit_position(ai_data.bot_unit), unit_utilities.get_unit_position(ai_data.target_unit), wanted_facing + 180)
        else
            queued_ability.move_target = table.deep_clone(ai_data.self_data.position_table)
        end

        return queued_ability.move_target
    end,
    path_to_wanted_position = function(queued_ability, ai_data, dt)
        ai_data.self_position = GET_UNIT_POS(ai_data.bot_unit)
        queued_ability.pathing_target = table.deep_clone(ai_data.wanted_position)

        calculate_pathing_target(queued_ability, ai_data, dt)
    end,
    path_to_move_target = function(queued_ability, ai_data, dt)

        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        --pathing
        ai_data.self_position = GET_UNIT_POS(ai_data.bot_unit)
        queued_ability.pathing_target = queued_ability.pathing_target or table.deep_clone(queued_ability.move_target)

        calculate_pathing_target(queued_ability, ai_data, dt)
    end,
    path_to_target = function(queued_ability, ai_data, dt)

        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        --pathing
        ai_data.self_position = GET_UNIT_POS(ai_data.bot_unit)
        queued_ability.pathing_target = helper.get_target_unit_pos(ai_data)

        calculate_pathing_target(queued_ability, ai_data, dt)
    end,
    path_to_ability_wanted_range = function(queued_ability, ai_data, dt)

        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        --pathing
        local counter_thing = 1
        ai_data.self_position = GET_UNIT_POS(ai_data.bot_unit)

        queued_ability.condition_args.wanted_range = queued_ability.condition_args.wanted_range or 5
        local move_target = VEC_TO_TABLE(MOVE_TOWARDS_POINT(unit_utilities.get_unit_position(ai_data.target_unit), ai_data.self_position, queued_ability.condition_args.wanted_range))

        queued_ability.pathing_target = move_target --queued_ability.pathing_target or table.deep_clone(move_target)

        calculate_pathing_target(queued_ability, ai_data, dt)
    end,
    move_to_target_unit_pos = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.move_target = VEC_TO_TABLE(unit_utilities.get_unit_position(ai_data.target_unit) or helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.move_target
    end,
    move_to_wanted_range_of_target = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit)
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        ai_data.wanted_range = queued_ability.condition_args.wanted_range or 5
        --local move_target = BotPathing:find_closest_valid_position(MOVE_TOWARDS_POINT(target_pos, self_position, ai_data.wanted_range), 10, {" "})
        local move_target = MOVE_TOWARDS_POINT(target_pos, self_position, ai_data.wanted_range)

        queued_ability.move_target = VEC_TO_TABLE(move_target)
        return queued_ability.move_target
    end,
    path_to_ability_wanted_range_of_target = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_pos = unit_utilities.get_unit_position(ai_data.target_unit)
        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        ai_data.wanted_range = queued_ability.condition_args.wanted_range or 5
        --local move_target = BotPathing:find_closest_valid_position(MOVE_TOWARDS_POINT(target_pos, self_position, ai_data.wanted_range), 10, {" "})
        local move_target = MOVE_TOWARDS_POINT(target_pos, self_position, ai_data.wanted_range)

        queued_ability.move_target = VEC_TO_TABLE(move_target)

        calculate_pathing_target(queued_ability, ai_data, dt)

        return queued_ability.move_target
    end,
    face_away_from_target_unit = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local self_position = unit_utilities.get_unit_position(ai_data.bot_unit)
        --local self_facing = unit_utilities.get_unit_forward(ai_data.bot_unit)
        local target_unit_position = unit_utilities.get_unit_position(ai_data.target_unit) or ai_data.self_data.position_table
        queued_ability.facing_target = VEC_TO_TABLE(MOVE_AWAY_FROM_POINT(self_position, target_unit_position, 2))
        return queued_ability.facing_target
    end,
    cancel_if_target_shielded = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if helper.target_blocked_by_shield(ai_data) then
            print("Oh wow there is a shield blocking this player, we should cancel this spell: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_shield_in_line_of_sight = function(queued_ability, ai_data, dt)
        if helper.shield_in_line_of_sight(ai_data) then
            print("Oh wow there is a shield blocking bot's line of sight, we should cancel this spell: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_storm_blocking = function(queued_ability, ai_data, dt)
        if helper.player_is_obstructed_by_storm(ai_data, ai_data.target_unit_data.peer_id) then
            print("Oh wow there is a storm blocking bot's line of sight, we should cancel this spell: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_target_changed = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.previous_target = queued_ability.previous_target or ai_data.target_unit

        if ai_data.target_unit ~= queued_ability.previous_target then
            print("Cancel ability as target has changed: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_no_target = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit or not unit_utilities.unit_is_valid(ai_data.target_unit) or ai_data.target_unit == ai_data.bot_unit then
            print("Cancel ability as there is no target: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
            return 
        end
    end,
    cancel_if_target_frozen = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if target_data.status.frozen then
            print("Cancel ability as target is frozen: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_target_wet = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if target_data.status.wet then
            print("Cancel ability as target is wet: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    set_default_weapon_charge_time = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.charge_time = helper.get_weapon_charge_time(ai_data.bot_unit)
    end,
    cancel_if_bot_full_hp = function(queued_ability, ai_data, dt)
        if ai_data.self_data.health_p >= 100 then
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_wet = function(queued_ability, ai_data, dt)
        if ai_data.self_data.status.wet then
            print("Cancel ability as bot is wet: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_burning = function(queued_ability, ai_data, dt)
        if ai_data.self_data.status.burning then
            print("Cancel ability as bot is burning: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    cancel_if_chilled = function(queued_ability, ai_data, dt)
        if ai_data.self_data.status.chilled then
            print("Cancel ability as bot is chilled: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            queued_ability.stop_ability = true
            ai_data.channel = false
        end
    end,
    force_cancel = function(queued_ability, ai_data, dt)
        if ai_data.cancel_ability then
            ai_data.cancel_ability = false
            ai_data.queue:cancel_current_action()
        end
        if ai_data.clear_queue then
            ai_data.clear_queue = false
            ai_data.queue:clear_all_but_active_ability()
        end
    end,
    cancel_to_ward = function(queued_ability, ai_data, dt)
        if ai_data.wanted_ward and ai_data.ward_needed then
            if queued_ability.condition_args then
                if queued_ability.condition_args.minimum_duration then
                    if (queued_ability.duration or 0) < queued_ability.condition_args.minimum_duration then
                        printf("ward - wanted to cancel but minimum_duration not yet exceeded %s ", tostring(queued_ability.ability_name))
                        return
                    end
                end    
            end
            ai_data.queue:cancel_current_action()
        end
    end,
    cancel_to_shield = function(queued_ability, ai_data, dt)
        if helper.player_needs_shield(ai_data) then
            if queued_ability.condition_args then
                if queued_ability.condition_args.minimum_duration then
                    if (queued_ability.duration or 0) < queued_ability.condition_args.minimum_duration then
                        printf("shield - wanted to cancel but minimum_duration not yet exceeded")
                        return
                    end
                end    
            end
            ai_data.queue:cancel_current_action()
        end
        return 
    end,
    cancel_if_out_of_range = function(queued_ability, ai_data, dt)
        local force_cancel = false
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then force_cancel = true end

        local distance_to_target = unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit)

        if not queued_ability.condition_args.minimum_range or not queued_ability.condition_args.maximum_range then
            print("within_range error, condition_args.minimum_range or condition_args.maximum_range is nil\n".. PAIRS_TO_STRING(queued_ability))
        end

        if distance_to_target < (queued_ability.condition_args.minimum_range or 0) or distance_to_target > (queued_ability.condition_args.maximum_range or 9000) then
            force_cancel = true
            print("cancel spell as target is outside of minimum_range/maximum_range: " .. tostring(distance_to_target) .. "\n" .. PAIRS_TO_STRING(queued_ability))
        end
        print("target is within range! ".. tostring(distance_to_target))

        if force_cancel then
            ai_data.cancel_ability = false
            ai_data.queue:cancel_current_action()
        end
    end,
    cancel_if_activation_pos_out_of_range = function(queued_ability, ai_data, dt)
        local force_cancel = false
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then force_cancel = true end

        local distance_to_target = DISTANCE_POINT_OR_VECTOR(ai_data.self_data.position_table, queued_ability.target_pos)

        if not queued_ability.condition_args.minimum_range or not queued_ability.condition_args.maximum_range then
            printf("within_range error, condition_args.minimum_range or condition_args.maximum_range is nil, distance_to_target: %s\n".. PAIRS_TO_STRING(queued_ability), tostring(distance_to_target))
        end

        if distance_to_target < (queued_ability.condition_args.minimum_range or 0) or distance_to_target > (queued_ability.condition_args.maximum_range or 9000) then
            force_cancel = true
            print("cancel spell as target is outside of minimum_range/maximum_range: " .. tostring(distance_to_target) .. "\n" .. PAIRS_TO_STRING(queued_ability))
        end
        print("target is within range! ".. tostring(distance_to_target))

        if force_cancel then
            ai_data.cancel_ability = false
            ai_data.queue:cancel_current_action()
        end
    end,
}

local activation_conditions = ActionController.activation_conditions
local on_update = ActionController.on_update

---the number of conditions an ability has might grow to quite a few
---you are able to pass groups of premade ones in insteadof making a list every time for
---common actions
ActionController.condition_groups = {
    activation_conditions = {
        default = {
            activation_conditions.bot_needs_ward,
            activation_conditions.target_is_valid,
            activation_conditions.within_range,
            activation_conditions.target_not_warded,
        },
        projectile_shatter = {
            activation_conditions.bot_needs_ward,
            activation_conditions.target_is_valid,
            activation_conditions.within_range,
            activation_conditions.target_is_frozen,
        },
        self_heal = {
            activation_conditions.bot_needs_ward,
            activation_conditions.bot_needs_shield,
        },
        beam = {
            activation_conditions.bot_needs_ward,
            activation_conditions.target_not_shielded, 
            activation_conditions.target_is_valid,
            activation_conditions.no_shield_shield_in_line_of_sight,
            activation_conditions.within_range,
        },
        spray = {
            activation_conditions.bot_needs_ward,
            activation_conditions.target_not_shielded, 
            activation_conditions.target_is_valid,
            activation_conditions.no_shield_shield_in_line_of_sight,
            activation_conditions.within_range,
        },
        lightning = {
            activation_conditions.bot_needs_ward,
            activation_conditions.bot_is_not_wet, 
            activation_conditions.target_is_valid,
            activation_conditions.within_range,
        },
    },
    on_update = {
        default = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_wanted_position,
            on_update.cancel_to_shield,
        },
        default_ignore_ward = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.move_to_wanted_range_of_target,
            on_update.cancel_to_shield,
        },
        self_heal = {
            on_update.face_target_unit, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.cancel_if_bot_full_hp,
            on_update.cancel_to_shield,
        },
        target_self = {
            on_update.target_self, 
            on_update.force_cancel,
        },
        move_to_wanted_range = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_ability_wanted_range_of_target,
            on_update.cancel_to_shield,
            --on_update.path_to_wanted_position,
        },
        move_to_wanted_range_ignore_ward = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.path_to_ability_wanted_range_of_target,
            on_update.cancel_to_shield,
            --on_update.path_to_wanted_position,
        },
        beam = {
            on_update.face_target_unit, 
            on_update.cancel_if_target_shielded, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_shield_in_line_of_sight,
            on_update.cancel_if_target_frozen,
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_ability_wanted_range_of_target,
            on_update.cancel_to_shield,
            --on_update.path_to_wanted_position,
        },
        spray = {
            on_update.face_target_unit, 
            on_update.cancel_if_target_shielded, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_shield_in_line_of_sight,
            on_update.cancel_if_target_frozen,
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_ability_wanted_range_of_target,
            on_update.cancel_to_shield,
            on_update.cancel_if_out_of_range,
            --on_update.path_to_wanted_position,
        },
        lightning = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_storm_blocking,
            on_update.cancel_if_target_frozen,
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.cancel_to_shield,
            on_update.cancel_if_out_of_range,
            on_update.cancel_if_wet
            --on_update.path_to_wanted_position,
        },
        projectile = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_wanted_position,
            on_update.cancel_to_shield,
            --on_update.path_to_wanted_position,
        },
        projectile_shatter = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_wanted_position,
            on_update.cancel_to_shield,
            --on_update.path_to_wanted_position,
        },
        magick = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_ability_wanted_range_of_target,
            --on_update.path_to_wanted_position,
            on_update.face_magick_target,
            on_update.cancel_if_out_of_range,
            on_update.cancel_if_activation_pos_out_of_range,

        },
        magick_teleport_in = {
            on_update.face_target_unit, 
            on_update.cancel_if_no_target, 
            on_update.force_cancel,
            --on_update.cancel_to_ward,
            --on_update.move_to_wanted_range_of_target,
            --on_update.path_to_wanted_position,
            --on_update.face_magick_target,
            --on_update.cancel_if_out_of_range,
            --on_update.cancel_if_activation_pos_out_of_range,
            on_update.target_enemy_if_valid_pos,

        },
        self_cast_magick = {
            on_update.face_target_unit, 
            --on_update.cancel_if_no_target, 
            on_update.force_cancel,
            on_update.cancel_to_ward,
            on_update.path_to_ability_wanted_range_of_target,
            --on_update.path_to_wanted_position,
            on_update.target_self,
            on_update.cancel_if_out_of_range,
            on_update.cancel_if_activation_pos_out_of_range,
        }
    },
}

return ActionController