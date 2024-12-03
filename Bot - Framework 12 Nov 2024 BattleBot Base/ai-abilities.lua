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
        wall_facing_target = function() return action.spell({0,0,0}, {w,e,d}, false, 0, {}, action.on_update.face_target_unit) end,
        mines_facing_target = function() return action.spell({0,0,0}, {e,w,w}, false, 0, {}, action.on_update.face_target_unit) end,
        mines_facing_away_from_target = function() return action.spell({0,0,0}, {e,w,w}, false, 0, {}, action.on_update.face_away_from_target_unit) end,
        self_channel = function() return action.self_channel({w,w,w}, 5, {}, {}, {action.on_update.cancel_if_bot_full_hp}) end,
    },

    --aoe
    aoe = {
        water = function() return action.self_cast(spells.qqq) end,
        sfs = function() return action.self_cast(spells.ssf) end,
    },
    
    --wards
    ward = {
        water = function() return action.ward({q,q,e}, {}, {activation_conditions.bot_already_warded}) end,
        life = function() return action.ward({w,w,e}, {}, {activation_conditions.bot_already_warded}) end,
        cold = function() return action.ward({e,r,r}, {}, {activation_conditions.bot_already_warded}) end,
        lightning = function() return action.ward({e,a,a}, {}, {activation_conditions.bot_already_warded}) end,
        arcane = function() return action.ward({e,s,s}, {}, {activation_conditions.bot_already_warded}) end,
        earth = function() return action.ward({e,d,d}, {}, {activation_conditions.bot_already_warded}) end,
        fire = function() return action.ward({e,f,f}, {}, {activation_conditions.bot_already_warded}) end,
        input_spell = function(spell_to_ward) 
            if spell_utilities.spell_contains(spell_to_ward) and #spell_to_ward > 1 then
                return action.ward(table.deep_clone(spell_to_ward), {}, {activation_conditions.bot_already_warded})
            else
                return action.ward({e, spell_to_ward[1], spell_to_ward[2] or spell_to_ward[1]}, {}, {activation_conditions.bot_already_warded})
            end
        end,
    },

    --projectiles
    --charge time is based off of charge value from 0 to 1 where 1 will be overcharged
    projectile = {
        earth = function() return action.projectile({0,0,0}, spells.ddd, 0.9, {}, {activation_conditions.target_is_valid}, {on_update.face_target_unit, on_update.cancel_if_no_target}) end,
        earth_shatter = function() return action.projectile({0,0,0}, spells.ddd, 0.9, {}, {activation_conditions.target_is_valid}, {on_update.face_target_unit, on_update.cancel_if_no_target}) end,
        cold = function() return action.projectile({0,0,0}, {r,r,d}, 0.9, {}, {activation_conditions.target_is_valid}, {on_update.face_target_unit, on_update.cancel_if_no_target}) end,
        fire = function() return action.projectile({0,0,0}, {d,f,f}, 0.9, {}, {activation_conditions.target_is_valid}, {on_update.face_target_unit, on_update.cancel_if_no_target}) end,
        arcane = function() return action.projectile({0,0,0}, {d,s,s}, 0.9, {}, {activation_conditions.target_is_valid}, {on_update.face_target_unit, on_update.cancel_if_no_target}) end,
    },

    --sprays
    --charge time is based off of time in seconds
    spray = {
        cold = function() return action.spray({0,0,0}, spells.rrr, 4, {}, action.condition_groups.activation_conditions.spray, action.condition_groups.on_update.spray) end,
        water = function() return action.spray({0,0,0}, spells.qqq, 4, {}, action.condition_groups.activation_conditions.spray, action.condition_groups.on_update.spray) end,
    },
    --beams
    --charge time is based off of time in seconds
    beam = {
        arcane = function() 
            return action.beam({0,0,0}, {s,s,s}, 4, {}, action.condition_groups.activation_conditions.beam, action.condition_groups.on_update.beam) 
        end,
        water = function() 
            return action.beam({0,0,0}, {q,s,s}, 4, {}, action.condition_groups.activation_conditions.beam, action.condition_groups.on_update.beam) 
        end,
    },

    --weapon
    weapon = {
        swing = function() return action.weapon(nil, 0, {}, {}, on_update.face_target_unit) end,
        charge = function() return action.weapon(nil, 0, {}, {}, {on_update.face_target_unit, on_update.set_default_weapon_charge_time}) end,
    },
}