require("ai/helper_library")

local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities

local helper = HelperLibrary
local spells = HelperLibrary.spells
local available_magicks = HelperLibrary.available_magicks

ActionController = {}

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
end

--not used for anything
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

--not really used for anything
ActionController.create_visual_at_point = function(world_point)
    local particle_position = WORLD_TO_SCREEN(world_point)
    UIFunc.create_particles("item_icon_weapon_snowball", math.random(10,50), {particle_position[1], particle_position[2], 999}, {0,0}, {10,10}, {255,255,255,255}, nil, {0, -3000}, 0.1)
    UIFunc.create_particles("item_icon_weapon_snowball", math.random(3,10), {particle_position[1], particle_position[2], 999}, {0,0}, {50,50}, {255,255,255,255}, nil, {0, -3000}, 0.01)
end

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
    move_target = move_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.move_to_point,
        move_target = {move_target[1] or 0, move_target[2] or 0, move_target[3] or 0},
        activation_conditions = activation_conditions,
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
    move_target = move_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.set_move_target,
        move_target = {move_target[1] or 0, move_target[2] or 0, move_target[3] or 0},
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
---this action will free the queue immediately
ActionController.face_point = function(facing_target, condition_args, activation_conditions, on_update)
    facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.face_target,
        facing_target = {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.face_point,
        on_update = on_update,
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
    facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.weapon_swing,
        facing_target = {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
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
    facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
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
    facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
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
    facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
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
    facing_target = facing_target or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        facing_target = {facing_target[1] or 0, facing_target[2] or 0, facing_target[3] or 0},
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
ActionController.self_cast = function(elements, condition_args, activation_conditions)
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.cast_spell,
        elements = type(elements) == "function" and table.deep_clone(elements()) or table.deep_clone(elements),
        self_cast = true,
        activation_conditions = activation_conditions,
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
ActionController.magick = function(target_pos, magick,condition_args, activation_conditions, on_update)
    target_pos = target_pos or {}
    return {
        condition_args = table.deep_clone(condition_args or {}), 
        action = ActionController.available_actions.magick,
        target_pos = {target_pos[1] or 0, target_pos[2] or 0, target_pos[3] or 0},
        activation_conditions = activation_conditions,
        update = ActionController.update_functions.cast_magick,
        on_update = on_update,
        deactivate = ActionController.deactivate_functions.default,
        magick = magick,
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
    target_not_shielded = function(queued_ability, ai_data, dt)
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then return true end

        local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

        if helper.player_blocked_by_shield(ai_data, target_data.peer_id) then
            print("Oh wow there is a shield blocking this player, we should skip this spell: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))
            return false
        end
        print("target is not blocked by shield!")
        return true
    end,
    no_shield_shield_in_line_of_sight = function(queued_ability, ai_data, dt)
        return not helper.shield_in_line_of_sight(ai_data)
    end,
    within_range = function(queued_ability, ai_data, dt)
        --target can't be shielded if there isn't a target
        if not ai_data.target_unit then return true end

        local distance_to_target = unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit)

        if not queued_ability.condition_args.minumum_range or not queued_ability.condition_args.maximum_range then
            print("within_range error, condition_args.minumum_range or condition_args.maximum_range is nil\n".. PAIRS_TO_STRING(queued_ability))
        end

        if distance_to_target < queued_ability.condition_args.minumum_range or distance_to_target > queued_ability.condition_args.maximum_range then
            print("unable to cast spell as target is outside of minumum_range/maximum_range\n".. PAIRS_TO_STRING(queued_ability))
            return false
        end
        print("target is within range!")
        return true
    end,
    target_is_valid = function(queued_ability, ai_data, dt)
        if not ai_data.target_unit or not unit_utilities.unit_is_valid(ai_data.target_unit) or ai_data.target_unit == ai_data.bot_unit then
            print("target is not valid or is targeting self!")
            return false
        end
        print("target is valid!")
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
    end
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
		
        if ai_data.self_data.state == "onground" then
            ai_data.melee = true
            ai_data.channel = true
            queued_ability.stop_ability = false
            queued_ability.ability_started = true
            printf("weapon melee swing started charge_time: %s update %s duration: %s weapon_ability_cooldown_time: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration), tostring(ai_data.self_data.weapon_ability_cooldown_time))
        else
            printf("weapon delay due to state change charge_time: %s update %s duration: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration))
        end

        if queued_ability.ability_started then
            printf("weapon charge_time: %s update %s duration: %s", tostring(queued_ability.charge_time), tostring(queued_ability.action), tostring(queued_ability.duration))
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

        if distance_to_target <= 0.2 then
            queued_ability.stop_ability = true
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
        
        local target_to_rotate_to = TO_VECTOR(queued_ability.facing_target)
        local bot_pos = unit_utilities.get_unit_position(ai_data.bot_unit)
        local bot_forward = unit_utilities.get_unit_forward(ai_data.bot_unit)
        local bot_forward_position = bot_pos + bot_forward

        if DISTANCE_POINT_OR_VECTOR(target_to_rotate_to, ai_data.self_data.position_table) <= 0.2 then
            queued_ability.stop_ability = true
            print("can't rotate to point that is less than 0.2 units away")
        end
        
        local angle_between = CALCULATE_ANGLE_BETWEEN_POINTS(bot_pos, bot_forward_position, target_to_rotate_to)

        if angle_between <= 5 then
            queued_ability.stop_ability = true
        end

        printf("face_point update %s duration: %s angle_between: %s", queued_ability.action, tostring(queued_ability.duration), tostring(angle_between))
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
                ai_data.spell_cast = true
            end
            
            --set the spell queue
            ai_data.spell_index = 1
            ai_data.spell_queue_n = #queued_ability.elements
            ai_data.spell_queue = queued_ability.elements

            --set the channeling state to trigger
            ai_data.channel = true

            printf("spell queue started %s", PAIRS_TO_STRING(queued_ability, 0))
        end

        --printf ("we should be expectinge a casting state soon... %s %s %s ", tostring(queued_ability.spell_queue_started ), tostring(not queued_ability.casting_started), tostring((ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling")))

        --the bot has sent the spell to be cast we need to wait until it actually starts casting before we calculate the duration
        if queued_ability.spell_queue_started 
        and not queued_ability.casting_started
        and (ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling" or ai_data.self_data.state == "chargeup") 
        then
            queued_ability.casting_started = true
            printf("spell casting started %s", PAIRS_TO_STRING(queued_ability, 0))
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
                ai_data.spell_cast = true
            end
            
            --set the spell queue
            ai_data.spell_index = 1
            ai_data.spell_queue_n = #queued_ability.elements
            ai_data.spell_queue = queued_ability.elements

            --set the channeling state to trigger
            ai_data.channel = true

            printf("spell queue started %s", PAIRS_TO_STRING(queued_ability, 0))
        end

        --printf ("we should be expectinge a casting state soon... %s %s %s ", tostring(queued_ability.spell_queue_started ), tostring(not queued_ability.casting_started), tostring((ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling")))

        --the bot has sent the spell to be cast we need to wait until it actually starts casting before we calculate the duration
        if queued_ability.spell_queue_started 
        and not queued_ability.casting_started
        and (ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling" or ai_data.self_data.state == "chargeup") 
        then
            queued_ability.casting_started = true
            printf("spell casting started %s", PAIRS_TO_STRING(queued_ability, 0))
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
                ai_data.spell_cast = true
            end
            
            --set the spell queue
            ai_data.spell_index = 1
            ai_data.spell_queue_n = #queued_ability.elements
            ai_data.spell_queue = queued_ability.elements

            --set the channeling state to trigger
            ai_data.channel = true

            printf("spell queue started %s", PAIRS_TO_STRING(queued_ability, 0))
        end

        --printf ("we should be expectinge a casting state soon... %s %s %s ", tostring(queued_ability.spell_queue_started ), tostring(not queued_ability.casting_started), tostring((ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling")))

        --the bot has sent the spell to be cast we need to wait until it actually starts casting before we calculate the duration
        if queued_ability.spell_queue_started 
        and not queued_ability.casting_started
        and (ai_data.self_data.state == "casting" or ai_data.self_data.state == "channeling" or ai_data.self_data.state == "chargeup") 
        then
            queued_ability.casting_started = true
            printf("spell casting started %s", PAIRS_TO_STRING(queued_ability, 0))
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
        --activation_conditions will remove current queued action and delete queued ability_system_settings
        if not queued_ability then 
            --queued_ability.stop_ability = true
            return 
        end

        if ai_data.self_data.state == "knocked_down" or char_ext.input.pushed then
            printf("spell cancelled to cast due to state: %s or pushed: %s - %s", tostring(ai_data.self_data.state), tostring(char_ext.input.pushed), PAIRS_TO_STRING(queued_ability, 0))
            ai_data.channel = false
            queued_ability.stop_ability = true
        end
        
        queued_ability.duration = (queued_ability.duration or 0)
        queued_ability.waiting_time = (queued_ability.waiting_time or 0)
        queued_ability.charge_time = queued_ability.charge_time or 0
        queued_ability.casting_frames = queued_ability.casting_frames or 0
        queued_ability.casting_stage = queued_ability.casting_stage or 0

        local char_ext = EntityAux.extension(ai_data.bot_unit, "character")
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

---you can make changes here!
---list of functions that are called every update when using an ability
---can be used to cancel an ability when conditions changed or change
---where a spell is aimed
ActionController.on_update = {
    face_target_unit = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end

        queued_ability.facing_target = VEC_TO_TABLE(unit_utilities.get_unit_position(ai_data.target_unit) or helper.get_unit_pos_and_facing(ai_data.bot_unit))
        return queued_ability.facing_target
    end,
    face_realitive_angle_to_target = function(queued_ability, ai_data, dt)
        --don't run the update if there isn't a target
        if not ai_data.target_unit then return end
        if not queued_ability.condition_args.realitive_angle then print("error no realitive_angle!: ") PRINT_TABLE(queued_ability) return end

        queued_ability.facing_target = calculate_look_at_point(unit_utilities.get_unit_position(ai_data.bot_unit), unit_utilities.get_unit_position(ai_data.target_unit), queued_ability.condition_args.realitive_angle)
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
        local move_target = MOVE_TOWARDS_POINT(target_pos, self_position, ai_data.wanted_range)

        queued_ability.move_target = VEC_TO_TABLE(move_target)
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

        if helper.player_blocked_by_shield(ai_data, target_data.peer_id) then
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
}

local activation_conditions = ActionController.activation_conditions
local on_update = ActionController.on_update

---the number of conditions an ability has might grow to quite a few
---you are able to pass groups of premade ones in insteadof making a list every time for
---common actions
ActionController.condition_groups = {
    activation_conditions = {
        beam = {
            activation_conditions.target_not_shielded, 
            activation_conditions.target_is_valid,
            activation_conditions.no_shield_shield_in_line_of_sight,
        },
        spray = {
            activation_conditions.target_not_shielded, 
            activation_conditions.target_is_valid,
            activation_conditions.no_shield_shield_in_line_of_sight,
        }
    },
    on_update = {
        beam = {
            on_update.face_target_unit, 
            on_update.cancel_if_target_shielded, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_shield_in_line_of_sight,
            on_update.cancel_if_target_frozen,
        },
        spray = {
            on_update.face_target_unit, 
            on_update.cancel_if_target_shielded, 
            on_update.cancel_if_no_target, 
            on_update.cancel_if_shield_in_line_of_sight,
            on_update.cancel_if_target_frozen,
        }
    },
}

return ActionController