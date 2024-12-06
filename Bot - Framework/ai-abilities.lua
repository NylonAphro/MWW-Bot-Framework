require("ai/helper_library")
require("ai/action_controller")

local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities

local helper = HelperLibrary
local spells = HelperLibrary.spells
local available_magicks = HelperLibrary.available_magicks
local action = ActionController
local activation_conditions = action.activation_conditions
local on_update = action.on_update
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

---abilities must be a function that returns a new table
---otherwise lua table references will be reused and
---cause undefined behaviour
BotAbilities = {
    --healing turtle stuff
    heal = {
        wall_facing_target = function() return action.spell({0,0,0}, {w,e,d}, false, 0, {cooldown = 1}, action.on_update.face_target_unit) end,
        mines_facing_target = function() return action.spell({0,0,0}, {e,w,w}, false, 0, {cooldown = 3}, action.on_update.face_target_unit) end,
        mines_facing_wanted_pos = function() return action.spell({0,0,0}, {e,w,w}, false, 0, {cooldown = 3}, action.on_update.face_wanted_position) end,
        mines_facing_away_from_target = function() return action.spell({0,0,0}, {e,w,w}, false, 0, {cooldown = 1}, action.on_update.face_away_from_target_unit) end,
        mines_facing_move_pos = function() return action.spell({0,0,0}, {e,w,w}, false, 0, {cooldown = 1}, action.on_update.face_move_pos) end,
        self_channel = function() return action.self_channel({w,w,w}, 5, {minimum_duration = 1.1, cooldown = 1}, condition_groups.activation_conditions.self_heal, condition_groups.on_update.self_heal) end,
    },

    --aoe
    aoe = {
        water = function() return action.self_cast(spells.qqq, {cooldown = 0.1}, condition_groups.activation_conditions.default) end,
        sfs = function() return action.self_cast(spells.ssf, {cooldown = 0.1}, condition_groups.activation_conditions.default) end,
        fire = function() return action.self_cast(spells.fff, {cooldown = 0.1}, condition_groups.activation_conditions.default) end,
        cold = function() return action.self_cast(spells.rrr, {cooldown = 0.1}, condition_groups.activation_conditions.default) end,
    },
    
    --wards
    ward = {
        shield = function() return action.ward({e}, {cooldown = 2}, {}) end,
        water = function() return action.ward({q,q,e}, {}, {activation_conditions.bot_already_warded}) end,
        life = function() return action.ward({w,w,e}, {}, {activation_conditions.bot_already_warded}) end,
        cold = function() return action.ward({e,r,r}, {}, {activation_conditions.bot_already_warded}) end,
        lightning = function() return action.ward({e,a,a}, {}, {activation_conditions.bot_already_warded}) end,
        arcane = function() return action.ward({e,s,s}, {}, {activation_conditions.bot_already_warded}) end,
        earth = function() return action.ward({e,d,d}, {}, {activation_conditions.bot_already_warded}) end,
        fire = function() return action.ward({e,f,f}, {}, {activation_conditions.bot_already_warded}) end,
        input_spell = function(spell_to_ward) 
            if spell_utilities.spell_contains(spell_to_ward) and #spell_to_ward > 1 then
                return action.ward(table.deep_clone(spell_to_ward), {cooldown = 1}, {activation_conditions.bot_already_warded})
            else
                return action.ward({e, spell_to_ward[1], spell_to_ward[2] or spell_to_ward[1]}, {cooldown = 0.2}, {activation_conditions.bot_already_warded})
            end
        end,
    },

    --projectiles
    --charge time is based off of charge value from 0 to 1 where 1 will be overcharged
    projectile = {
        earth = function() return               action.projectile(nil, spells.ddd, 0.9, {minimum_duration = 1.1, wanted_range = 8, minimum_range = 0.5, maximum_range = 12},  condition_groups.activation_conditions.default, condition_groups.on_update.projectile) end,
        earth_shatter = function() return       action.projectile(nil, spells.ddd, 0.9, {minimum_duration = 1.1, minimum_range = 0.5, maximum_range = 12}, condition_groups.activation_conditions.projectile_shatter, condition_groups.on_update.projectile_shatter) end,
        cold = function() return                action.projectile(nil, {r,r,d}, 0.9, {minimum_duration = 1.1, wanted_range = 8, minimum_range = 0.5, maximum_range = 12},  condition_groups.activation_conditions.default, condition_groups.on_update.projectile) end,
        fire = function() return                action.projectile(nil, {d,f,f}, 0.9, {minimum_duration = 1.1, wanted_range = 8, minimum_range = 0.5, maximum_range = 12},  condition_groups.activation_conditions.default, condition_groups.on_update.projectile) end,
        arcane = function() return              action.projectile(nil, {d,s,s}, 0.9, {minimum_duration = 1.1, wanted_range = 8, minimum_range = 0.5, maximum_range = 12},  condition_groups.activation_conditions.default, condition_groups.on_update.projectile) end,
        arcane_fire = function() return         action.projectile(nil, {d,s,f}, 0.9, {minimum_duration = 1.1, wanted_range = 8, minimum_range = 0.5, maximum_range = 12},  condition_groups.activation_conditions.default, condition_groups.on_update.projectile) end,
        status_cold_rock = function() return    action.projectile(nil, {w,d,r}, 0, {cooldown = 3}, {}, {on_update.cancel_immediately}) end,
        status_fire_rock = function() return    action.projectile(nil, {w,d,f}, 0, {cooldown = 3}, {}, {on_update.cancel_immediately}) end,
    },

    --sprays
    --charge time is based off of time in seconds
    spray = {
        cold = function() return            action.spray(nil, spells.rrr, 4, {minimum_duration = 0.5, wanted_range = 6, minimum_range = 0.5, maximum_range = 8}, condition_groups.activation_conditions.spray, condition_groups.on_update.spray) end,
        water = function() return           action.spray(nil, spells.qqq, 4, {minimum_duration = 0.5, wanted_range = 10, minimum_range = 0.5, maximum_range = 6}, condition_groups.activation_conditions.spray, condition_groups.on_update.spray) end,
        fire = function() return            action.spray(nil, {f,f,f}, 4, {minimum_duration = 0.5, wanted_range = 6, minimum_range = 0.5, maximum_range = 8}, condition_groups.activation_conditions.spray, condition_groups.on_update.spray) end,
        steam_qfq = function() return            action.spray(nil, {f,q,q}, 4, {minimum_duration = 0.5, wanted_range = 6, minimum_range = 0.5, maximum_range = 8}, condition_groups.activation_conditions.spray, condition_groups.on_update.spray) end,
        fire_burst = function() return      action.spray(nil, {f,f,f}, 0.1, {}, {}, {}) end,
        cold_burst = function() return      action.spray(nil, {r,r,r}, 0.1, {}, {}, {}) end,
        steam_burst = function() return     action.spray(nil, {q,f,q}, 0.1, {}, {}, {}) end,
        water_burst = function() return     action.spray(nil, {q,q,q}, 0.1, {}, {}, {}) end,
    },
    --beams
    --charge time is based off of time in seconds
    beam = {
        arcane = function() 
            return action.beam({0,0,0}, {s,s,s}, 4, {}, condition_groups.activation_conditions.beam, condition_groups.on_update.beam) 
        end,
        water = function() 
            return action.beam({0,0,0}, {q,s,s}, 4, {}, condition_groups.activation_conditions.beam, condition_groups.on_update.beam) 
        end,
    },

    lightning = {
        aaa = function() return            action.spell(nil, {a,a,a}, false, 0, {minimum_range = 1, maximum_range = 7}, condition_groups.activation_conditions.lightning, condition_groups.on_update.lightning) end,
        asa = function() return            action.spell(nil, {a,s,a}, false, 0, {minimum_range = 1, maximum_range = 6}, condition_groups.activation_conditions.lightning, condition_groups.on_update.lightning) end,
    },

    --weapon
    weapon = {
        swing = function() return action.weapon(nil, 0, {}, {}, on_update.face_target_unit) end,
        charge = function() return action.weapon(nil, 0, {}, {}, {on_update.face_target_unit, on_update.set_default_weapon_charge_time}) end,
    },

    mines = {
        arcane = function() return action.spell(nil, {e,s,s}, false, 0, {}, {}, {}) end,
    },

    --magicks
    magicks = {
        haste = function() return action.magick(nil, helper.available_magicks.haste, {cooldown = 10, minimum_duration = helper.minimum_duration.magick, minimum_range = 0, maximum_range = 1000}, {}, condition_groups.on_update.self_cast_magick) end,
        teleport = function() return action.magick(nil, helper.available_magicks.teleport, {wanted_range = 8.25, cooldown = 0,minimum_duration =  helper.minimum_duration.magick, minimum_range = 0, maximum_range = 1000}, {activation_conditions.teleport_towards_target_is_valid}, condition_groups.on_update.magick_teleport_in) end,
        geyser = function() return action.magick(nil, helper.available_magicks.geyser, {cooldown = 5, minimum_range = 2, maximum_range = 1000, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        stasis = function() return action.magick(nil, helper.available_magicks.stasis, {cooldown = 10, minimum_range = 0, maximum_range = 1000, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        midsummers_blessing = function() return action.magick(nil, helper.available_magicks.midsummers_blessing, {cooldown = 7, minimum_range = 0, maximum_range = 1000, minimum_duration = helper.minimum_duration.magick}, condition_groups.activation_conditions.magick, condition_groups.on_update.self_cast_magick) end,
        flame_tornado = function() return action.magick(nil, helper.available_magicks.flame_tornado, {cooldown = 7, minimum_range = 0, maximum_range = 1000, minimum_duration = helper.minimum_duration.magick}, condition_groups.activation_conditions.magick, condition_groups.on_update.magick) end,

        conflag = function() return action.magick(nil, helper.available_magicks.conflagration, {cooldown = 2, minimum_range = 0, maximum_range = 1000, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        tornado = function() return action.magick(nil, helper.available_magicks.tornado, {cooldown = 20, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        tidal_wave = function() return action.magick(nil, helper.available_magicks.tidal_wave, {cooldown = 5, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        natures_call = function() return action.magick(nil, helper.available_magicks.natures_call, {cooldown = 5, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        frost_bomb = function() return action.magick(nil, helper.available_magicks.frost_bomb, {cooldown = 5, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        charm = function() return action.magick(nil, helper.available_magicks.charm, {cooldown = 2, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        
        summon_death = function() return action.magick(nil, helper.available_magicks.summon_death, {cooldown = 10, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        nullify = function() return action.magick(nil, helper.available_magicks.nullify, {cooldown = 5, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        displace = function() return action.magick(nil, helper.available_magicks.displace, {cooldown = 10, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        
        raise_dead = function() return action.magick(nil, helper.available_magicks.raise_dead, {wanted_range = 20, cooldown = 25, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        meteor_shower = function() return action.magick(nil, helper.available_magicks.meteor_shower, {wanted_range = 20,cooldown = 25, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        mighty_hail = function() return action.magick(nil, helper.available_magicks.mighty_hail, {wanted_range = 20, cooldown = 25, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
        thunderstorm = function() return action.magick(nil, helper.available_magicks.thunderstorm, {wanted_range = 20, cooldown = 25, minimum_duration = helper.minimum_duration.magick}, {}, condition_groups.on_update.magick) end,
    },
}

-- helper function to track cooldowns of all used abilities/combos
-- timers use their key from the BotAbilities.evaluation_functions
-- to track cooldowns, not specific ability names
-- eg if a combo uses a projectile ddd, the cooldown will be tracked
-- only for that combo, not for the individual abilities ddd may still be used
-- by itself or in other combos
local function ability_is_on_cooldown(ai_data, dt, ability_name)
    if ai_data.timers[ability_name .. "_cooldown"] then 
        print("Ability is on cooldown: " .. tostring(ability_name))
        PRINT_TABLE(ai_data.timers)
        return true 
    end
end

--used to add variation in the weights of abilities
local function random_modifier()
    return CLAMP_BETWEEN(0, 1000, math.random(0, 1900) / 1000)
end

--set default weight for select_ability logic
local default_weights = {
    --defense
    self_heal = 200,
    water_push = 20000,
    ward = 20000,
    shield_beam = 20001,
    clear_storm = 20001,
    clear_status = 20001,
    block_lightning_with_storm = 20002,
    move_out_of_storm = 3000,
    heal_mine_agressive = 220,

    path_to_wanted_range = 1,

    basic_attack = 10,
    shatter = 19000,
    basic_combo = 10,

    haste = 200,
    teleport = 150,
    geyser = 150,
    flame_tornado = 100,
    midsummers_blessing = 201,
    natures_call = 150,
    conflag = 190,
    tornado = 150,
    tidal_wave = 199,
    frost_bomb = 150,

    summon_death = 300,
    displace = 300,

    mighty_hail = 250,
    meteor_shower = 250,
    thunderstorm = 250,

    raise_dead = 160,

    charm = 2000,
    nullify = 2000,
}

-- evaluation_functions that are looped through in select_ability
BotAbilities.evaluation_functions = {
    path_to_wanted_range = function (ai_data, dt, ability_name)
        --if (ai_data.mode ~= helper.bot_modes.attack) then return 0, nil end
        if (not ai_data.target_blocked) then return 0, nil end
        
        --(not ai_data.target_blocked) and (ai_data.storm_count <= 0)
        local weight = default_weights.path_to_wanted_range
        
        if ai_data.target_distance > 10 then weight = weight + 1 end
        if ai_data.target_blocked then weight = weight + 1 end

        return weight, {action.move_to_point(nil, {charge_time = 2, max_duration = 1}, {}, {on_update.path_to_wanted_position, on_update.face_move_pos, on_update.cancel_to_ward, on_update.cancel_to_shield, on_update.cancel_if_move_target_reached})}
    end,
    move_out_of_storm = function (ai_data, dt, ability_name)
        local weight = 0
        
        if ai_data.storm_count >= 1   
        --and ai_data.mode == helper.bot_modes.heal
        then

            weight = default_weights.move_out_of_storm
        end

        return weight, {action.move_to_point(nil, {charge_time = 1, max_duration = 1}, {}, {on_update.path_to_wanted_position, on_update.face_move_pos, on_update.cancel_to_shield, on_update.cancel_if_move_target_reached})}
    end,

    --healing
    self_heal = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 1

        if ai_data.mode == helper.bot_modes.heal
            and not helper.player_needs_shield(ai_data)
            and not ai_data.ward_needed
        then
            weight = default_weights.self_heal
        end
        
        if ai_data.self_data.health_p == 100 then weight = 0 end

        -- return 101, BotAbilities.heal.self_channel
        return weight * random_modifier(), {ActionController.move_to_point(nil, {max_duration = 0.5}, {}, {on_update.cancel_to_ward, on_update.cancel_to_shield, on_update.path_to_wanted_position, on_update.face_move_pos, on_update.cancel_if_move_target_reached}), BotAbilities.heal.self_channel()}
    end,
    self_heal_combo = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.heal
        and helper.count_healing_mines(ai_data) <= 0
        then
            weight = 100
        end

        return weight * random_modifier(), BotCombos.heal_turtle(ai_data)
    end,
    heal_mine_defend = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.heal
        and helper.count_healing_mines(ai_data) <= 0
        then
            weight = 101
        end

        return weight * random_modifier(), {
            BotAbilities.heal.mines_facing_move_pos(), 
            BotAbilities.ward.earth(), 
            ActionController.projectile(nil, {w,d,r}, 0, {}, {}, {on_update.cancel_immediately}),
            ActionController.move_forward(5, 0.75), 
        }
    end,
    heal_mine_override = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode ~= helper.bot_modes.attack
        and helper.count_healing_mines(ai_data) <= 3
        then
            weight = default_weights.self_heal
        end

        return weight * random_modifier(), {
            BotAbilities.heal.mines_facing_wanted_pos(), 
        }
    end,
    heal_mine_agressive = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode ~= helper.bot_modes.heal
        and helper.count_healing_mines(ai_data) <= 0
        and b_hp < 80
        and ai_data.target_distance > 4
        then
            weight = default_weights.heal_mine_agressive
        end

        return weight * random_modifier(), {
            BotAbilities.heal.mines_facing_target(), 
            BotAbilities.ward.earth(), 
            ActionController.projectile(nil, {w,d,r}, 0, {}, {}, {on_update.cancel_immediately}), 
            ActionController.move_forward(5,  0.2)}
    end,

    --clear status
    

    --magicks
    midsummers_blessing = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        if b_hp <= 40 --ai_data.mode ~= helper.bot_modes.attack
        and ai_data.self_data.focus >= helper.magick_mana_cost.midsummers_blessing --magick focus for the tiers are 25, 50, 75, 100
        then
            weight = default_weights.midsummers_blessing
        end

        return weight * random_modifier(), --BotAbilities.magicks.midsummers_blessing
        {
            action.magick(
                    nil, 
                    helper.available_magicks.midsummers_blessing, 
                    {cooldown = 5, wanted_range = 2}, 
                    {}, 
                    {
                        on_update.target_away_from_enemy
                    }
                ),
            action.set_facing_point(nil, {}, {}, {on_update.face_target_unit}),
            action.ward(ai_data.wanted_ward, {cooldown = 1}),
            BotAbilities.heal.self_channel,
        }
    end,

    --defence
    apply_ward = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0

        if ai_data.wanted_ward and ai_data.ward_needed then
            weight = default_weights.ward
        end

        return weight, {action.ward(ai_data.wanted_ward, {cooldown = 1.5})}
    end,
    shield_beam = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        
        if not target_unit_data then return 0 end
        
        local weight = 0
        local b_hp = ai_data.self_data.health_p

        if helper.player_needs_shield(ai_data) then
            weight = default_weights.shield_beam
        end

        return weight * random_modifier(), {BotAbilities.ward.shield()}
    end,
    defence_water_push = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.target_distance <= 8
        and target_unit_data.ward.water <= 1
        --and ai_data.mode ~= helper.bot_modes.attack
        and ai_data.wanted_range > ai_data.target_distance
        and ai_data.mode == helper.bot_modes.heal
        and not helper.player_blocked_by_shield(ai_data, ai_data.target_data.peer_id)
        and not ai_data.target_blocked
        then
            weight = default_weights.water_push
        end

        return weight * random_modifier(), function() return action.spray(nil, spells.qqq, 4, {minimum_duration = 0.5, wanted_range = 10, minimum_range = 0.5, maximum_range = 6, cooldown = 4}, condition_groups.activation_conditions.spray, condition_groups.on_update.spray) end
    end,
    defence_clear_storm = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.storm_count >= 1   
        and ai_data.mode == helper.bot_modes.heal
        then

            weight = default_weights.clear_storm
        end

        local storm_elements = spell_utilities.spell_to_elements(ai_data.obstructions.storm_elements or {})

        if storm_elements.lightning >= 1 then
            return weight * random_modifier(), BotAbilities.aoe.water
        elseif storm_elements.water >= 1 and storm_elements.fire <= 0 then
            return weight * random_modifier(), BotAbilities.aoe.sfs
        elseif storm_elements.fire >= 1 then
            return weight * random_modifier(), BotAbilities.aoe.cold
        elseif storm_elements.cold >= 1 then
            return weight * random_modifier(), BotAbilities.aoe.sfs
        end
        return 0, nil
    end,
    block_lightning_with_storm = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if (ai_data.target_unit_data.spell_type == helper.spell_types.lightning_aoe or ai_data.target_unit_data.spell_type == helper.spell_types.lightning)
        and not helper.player_is_obstructed_by_storm(ai_data, ai_data.target_data.peer_id)
        and (ai_data.self_data.ward.lightning <= 0)
        then
            weight = default_weights.block_lightning_with_storm
        end

        local wanted_storm = {e,q,q}
        if spell_utilities.spell_contains(ai_data.target_data.spell, "fire") then
            wanted_storm = {e,f,f}
        elseif spell_utilities.spell_contains(ai_data.target_data.spell, "cold") then
            wanted_storm = {e,r,r}
        end

        return weight * random_modifier(), {
            action.spell(nil, wanted_storm, false, 0, {cooldown = 1}, {}, {on_update.face_target_unit}), 
        }
    end,

    --clear status
    clear_status_with_cold = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        if helper.unit_is_wet(ai_data.bot_unit) or helper.unit_is_burning(ai_data.bot_unit) then
            weight = default_weights.clear_status
        end

        return weight * random_modifier(), {
            BotAbilities.projectile.status_cold_rock, 
            ActionController.move_forward(5,  0.25)}
    end,
    --clear status
    clear_status_with_fire = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        if helper.unit_is_chilled(ai_data.bot_unit) then
            weight = default_weights.clear_status
        end

        return weight * random_modifier(), {
            BotAbilities.projectile.status_cold_rock, 
            ActionController.move_forward(5,  0.25)}
    end,

    -- --offence
    weapon_swing = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local elements = GET_WEAPON_DAMAGE_TYPE(ai_data.self_data.weapon)
		local max_range = GET_WEAPON_RANGE(ai_data.self_data.weapon)
        local similar_elements = helper.similar_elements(elements, ai_data.target_data.ward_elements)
        print("weapon similar elements: " .. tostring(similar_elements) .. " elements: ".. PAIRS_TO_STRING_ONE_LINE(elements) .. " vs: " .. PAIRS_TO_STRING_ONE_LINE(ai_data.target_data.ward_elements))

        local weight = 0
        --local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        if similar_elements <= 0
           and ai_data.mode == helper.bot_modes.attack
           and ai_data.target_distance <= 4
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.weapon.swing, 1.5)
    end,
    weapon_charge = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local elements = GET_WEAPON_DAMAGE_TYPE(ai_data.self_data.weapon)
		local max_range = GET_WEAPON_RANGE(ai_data.self_data.weapon)
        local similar_elements = helper.similar_elements(elements, ai_data.target_data.ward_elements)
        print("weapon similar elements: " .. tostring(similar_elements))

        local weight = 0
        if similar_elements <= 0
           and ai_data.mode == helper.bot_modes.attack
           and ai_data.target_distance <= max_range
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.weapon.charge, max_range - 1)
    end,

    rock = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        --and ai_data.target_distance < 12
        then
            weight = default_weights.basic_attack
        end

        if helper.target_is_frozen then
            weight = default_weights.shatter
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.projectile.earth, 6)
    end,
    rock_sdf = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.fire <= 0
        --and ai_data.target_distance < 12
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.projectile.arcane_fire, 6)
    end,

    lightning_aaa = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.lightning <= 0
        and not (helper.player_is_obstructed_by_storm(ai_data, ai_data.target_data.peer_id))
        and not helper.unit_is_wet(ai_data.self_data.unit)
        --and ai_data.target_distance < 12
        then
            weight = default_weights.basic_attack
            if helper.unit_is_wet(ai_data.target_unit_data.unit) then
                weight = weight * 2
            end
        end
        

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.lightning.aaa, 6)
    end,
    lightning_asa = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.lightning <= 0
        and not (helper.player_is_obstructed_by_storm(ai_data, ai_data.target_data.peer_id))
        and not helper.unit_is_wet(ai_data.self_data.unit)
        --and ai_data.target_distance < 12
        then
            weight = default_weights.basic_attack
            if helper.unit_is_wet(ai_data.target_unit_data.unit) then
                weight = weight * 2
            end
        end
        

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.lightning.asa, 6)
    end,

    aoe_sfs = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.arcane <= 0
        --and not (helper.player(ai_data, ai_data.target_data.peer_id))
        and not helper.unit_is_wet(ai_data.self_data.unit)
        then
            weight = default_weights.basic_attack
            if not helper.unit_is_wet(ai_data.target_unit_data.unit) then
                weight = weight * 2
            end
        end
        

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.aoe.sfs, 2)
    end,

    spray_steam_qfq = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.water <= 0
        --and ai_data.target_distance < 30
        and not helper.target_blocked_by_shield(ai_data)
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.spray.steam_qfq, 6)
    end,
    spray_fire = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.fire <= 0
        --and ai_data.target_distance < 12
        and not helper.target_blocked_by_shield(ai_data)
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.spray.fire, 7)
    end,
    spray_cold = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.cold <= 0
        --and ai_data.target_distance < 12
        and not helper.target_blocked_by_shield(ai_data)
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), BotCombos.charge_to_range_and_use_ability(ai_data, BotAbilities.spray.cold, 7)
    end,
    spray_water_burst = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.water <= 0
        --and ai_data.target_distance < 12
        and not helper.target_blocked_by_shield(ai_data)
        then
            weight = default_weights.basic_attack
        end

        return weight * random_modifier(), ai_data, BotAbilities.spray.water_burst
    end,

    --combos
    charge_forward_quake_wet_lightning = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        and ai_data.target_distance < 8
        then
            weight = default_weights.basic_combo
        end

        return weight * random_modifier(), BotCombos.charge_forward_quake_wet_lightning(ai_data)
    end,
    charge_forward_steam_storm_quake = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        and ai_data.target_distance < 8
        then
            weight = default_weights.basic_combo
        end

        return weight * random_modifier(), BotCombos.charge_forward_steam_storm_quake(ai_data)
    end,
    charge_forward_quake_mines = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        and ai_data.target_distance < 8
        then
            weight = default_weights.basic_combo
        end

        return weight * random_modifier(), BotCombos.charge_forward_quake_mines(ai_data)
    end,
    charge_forward_quake_lightning = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        and ai_data.target_distance < 8
        then
            weight = default_weights.basic_combo
        end

        return weight * random_modifier(), BotCombos.charge_forward_quake_lightning(ai_data)
    end,
    charge_forward_rock_qer = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        and ai_data.target_distance < 8
        then
            weight = default_weights.basic_combo
        end

        if helper.target_is_frozen then
            weight = default_weights.shatter
        end

        return weight * random_modifier(), BotCombos.charge_forward_rock_qer(ai_data)
    end,
    water_beam_cold_shatter = function (ai_data, dt, ability_name)

        if ability_is_on_cooldown(ai_data, dt, ability_name) then return 0, nil end

        local weight = 0
        local target_unit_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
        local b_hp = ai_data.self_data.health_p
        local t_hp = target_unit_data.health_p
        if ai_data.mode == helper.bot_modes.attack
        and ai_data.target_data.ward.earth <= 0
        and ai_data.target_distance < 13
        then
            weight = default_weights.basic_combo
        end

        return weight * random_modifier(), BotCombos.water_beam_cold_shatter(ai_data)
    end,
}