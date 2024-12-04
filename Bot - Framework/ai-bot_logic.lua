require("ai/helper_library")
require("ai/abilities")
BotPathing = require("scripts/pathing")

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

DEBUG_MAKRUP_GET_PATH_WEIGHT_COLOR = function(point) return {255, CLAMP_BETWEEN(0, 255, BotPathing:get_map_weight(point) * 10), 255 - CLAMP_BETWEEN(0, 255, BotPathing:get_map_weight(point) * 10), 20} end

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
    ai_data.target_unit = ai_data.enemy_ai_units[1] or ai_data.target_aggressor or ai_data.closest_enemy.unit or ai_data.closest_enemy.unit or ai_data.bot_unit
    --ai_data.target_unit = ai_data.closest_enemy.unit or ai_data.bot_unit
end

function Bot:update_wanted_ward(dt)
    local ai_data = self.ai_data
    local dt = dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    ai_data.queue = queue

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

    --set ward stuff
    ai_data.wanted_ward = helper.get_wanted_ward(ai_data)
    ai_data.target_blocked = helper.target_blocked_by_terrain(ai_data)

    --ward is not needed if already has ward applied
    if spell_utilities.spell_equals(ai_data.wanted_ward, ai_data.self_data.ward_elements) then
        ai_data.ward_needed = false
    elseif ai_data.timers["apply_ward_cooldown"] then
        ai_data.ward_needed = true
    else
        ai_data.ward_needed = true
    end
end

function Bot:update_mode(dt)
    local ai_data = self.ai_data
    local dt = dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    ai_data.queue = queue

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

    --set mode stuff
    ai_data.mode = ai_data.mode or helper.bot_modes.heal
    local current_mode = ai_data.mode

    --set the bot mode based off of hp
    if ai_data.self_data.health_p >= (target_data.health_p - 30) then
        ai_data.mode = helper.bot_modes.attack
    else
        ai_data.mode = helper.bot_modes.heal
    end

    --clear the queue if the mode has changed
    --eg if the bot was attacking and now needs to heal
    if current_mode ~= ai_data.mode then
        queue:cancel_current_action()
        queue:clear_all_but_active_ability()
    end
end

function Bot:update_pathing(dt)
    local ai_data = self.ai_data
    local dt = dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    ai_data.queue = queue

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
    local prev_wanted_pos = table.deep_clone(ai_data.wanted_position or ai_data.self_data.position_table)

    --some random poop to calculate wanted range
    --range should be adjusted based on number of team members and enemy players (larger range if more enemies vs team members)
    --1.5 range min set to prevent bot from clipping through enemies
    ai_data.wanted_range = CLAMP_BETWEEN(1.5, 20, ((((100 - ai_data.self_data.health_p) * 0.05) * 4)) + (((#ai_data.enemy_players) - (#ai_data.team_players))))

    --handle wanted range/position stuff
    local wanted_target_pos = VEC_TO_TABLE(MOVE_TOWARDS_POINT(target_data.position_table, ai_data.self_data.position_table, ai_data.wanted_range))
    ai_data.wanted_position = BotPathing:find_closest_valid_position(wanted_target_pos, 10) or ai_data.self_data.position_table

    --check if bot is in a storm! 
    ai_data.storm_count = helper.count_storms(ai_data)
    if ai_data.storm_count >= 1 then
        ai_data.wanted_position = BotPathing:find_closest_valid_position(ai_data.self_data.position_table, 10) or ai_data.self_data.position_table
    end

    --someone implement slerp, oh wait I did do that, SLERP_TOWARDS_POINT... also LERP is a PDX function
    ai_data.wanted_position = SMOOTH_TABLE(ai_data.wanted_position, prev_wanted_pos, 0.03 / dt)

end

--- General bot update stuff like pathing should be added here
---@param self table
function Bot:update_debug(dt)
    local ai_data = self.ai_data
    local dt = dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    ai_data.queue = queue

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

    pdDebug.text("-----------------Target Blocked?: %s",                    PAIRS_TO_STRING(ai_data.target_blocked))
    pdDebug.text("-----------------Wanted Range: %s Wanted Position: %s",   tostring(ai_data.wanted_range or 0), PAIRS_TO_STRING(ai_data.wanted_position))
    pdDebug.text("-----------------Wanted Ward: %s",                        PAIRS_TO_STRING(ai_data.wanted_ward))
    pdDebug.text("-----------------NEEDED WARD: %s",                        PAIRS_TO_STRING(ai_data.wanted_ward))
    pdDebug.text("-----------------WARD ON COOLDOWN: %s",                   PAIRS_TO_STRING(ai_data.wanted_ward))
    pdDebug.text("-----------------current_high_score: %s",                 ai_data.current_high_score)
    pdDebug.text("-----------------mode: %s mode: %s",                      ai_data.mode, tostring(helper.bot_modes[ai_data.mode]))
    pdDebug.text("-----------------close heal mines  : %s",                 helper.count_healing_mines(ai_data))
    pdDebug.text("-----------------close arcane mines: %s",                 helper.count_arcane_mines(ai_data))
    pdDebug.text("-----------------close storms      : %s",                 helper.count_storms(ai_data))
    pdDebug.text("-----------------target shielded   : %s",                 helper.player_blocked_by_shield(ai_data, ai_data.target_data.peer_id) )
    pdDebug.text("-----------------target_distance   : %s",                 tostring(ai_data.target_distance))
    pdDebug.text("-----------------target spell_type : %s",                 tostring(ai_data.target_unit_data.spell_type))
    pdDebug.text("-----------------ai_data.enemy_ai_units   : %s",          PAIRS_TO_STRING_ONE_LINE(ai_data.enemy_ai_units))
    pdDebug.text("-----------------ai_data.enemy_ai_units   : %s",          PAIRS_TO_STRING_ONE_LINE(ai_data.team_ai_units))

    --draw debug stuff
    local debug_markup = {}
    --draw path to move target
    for index, value in ipairs(ai_data.current_path or {}) do
        debug_markup[#debug_markup+1] = UIFunc.new_text_markup(tostring(index), WORLD_TO_SCREEN(TO_VECTOR(value)), 50, DEBUG_MAKRUP_GET_PATH_WEIGHT_COLOR(value), true)
        debug_markup[#debug_markup+1] = UIFunc.new_text_markup(BotPathing:get_map_weight(value), WORLD_TO_SCREEN(TO_VECTOR(value)), 10, DEBUG_MAKRUP_GET_PATH_WEIGHT_COLOR(value), true)
    end

    --draw forward facing vector
    debug_markup[#debug_markup+1] = UIFunc.new_text_markup("X", WORLD_TO_SCREEN(MOVE_TOWARDS_POINT(TO_VECTOR(ai_data.self_data.position_table), helper.get_unit_pos_and_facing(ai_data.bot_unit), 8.25)), 20, UIProperties.color.teal(), true)
    
    --draw ability wanted pos 
    local queued_ability = queue:get_current_action() or {"no runnin ability"}
    if queued_ability then
        if queued_ability.move_target then
            debug_markup[#debug_markup+1] = UIFunc.new_text_markup(tostring(math.round(ai_data.distance_to_move_target or 0)), WORLD_TO_SCREEN(queued_ability.move_target), 30, UIProperties.color.blue(), true)
        end
    end
    debug_markup[#debug_markup+1] = UIFunc.new_text_markup("G", WORLD_TO_SCREEN(ai_data.wanted_position), 30, UIProperties.color.red(), true)

    if type(ai_data.target_blocked) ~= "boolean" then
        debug_markup[#debug_markup+1] = UIFunc.new_text_markup("BLOCKED", WORLD_TO_SCREEN(ai_data.target_blocked), 30, UIProperties.color.red(), true)
    end

    --manually send the markup to be drawn (without using UIFunc to manage)
    DRAW_MARKUP(dt, debug_markup)
    
    --draw pathing map (disable to save screen space)
    --BotPathing:draw_debug_map_area(ROUND_POINT_OR_VECTOR(GET_UNIT_DATA(Network.peer_id()).position_table or {0,0,0}), 10)

    pdDebug.text("                        Name: " .. ai_data.target_unit_data.name .. " unit: " .. tostring(ai_data.target_unit))

	local action_queue = queue.action_queue

	pdDebug.text("            current action: " .. tostring(queued_ability.action) .. " " .. tostring(queued_ability.ability_name) .. " info: " .. PAIRS_TO_STRING_ONE_LINE(queued_ability))

	for index, action in ipairs(action_queue) do
        if index ~= 1 then
		    pdDebug.text("                    action: " .. tostring(action.action) .. " " .. tostring(action.ability_name) .. " info: " .. PAIRS_TO_STRING_ONE_LINE(action))
        end
	end

    --print timers
    for key, value in pairs(ai_data.timers) do
        pdDebug.text("                        timer: " .. tostring(key) .. ": " .. tostring(ai_data.timers[key]))
	end
end

--- General bot update stuff like pathing should be added here
---@param self table
function Bot:update(dt)
    local ai_data = self.ai_data
    local dt = dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    ai_data.bot_pathing = BotPathing
    ai_data.queue = queue

    --absolute_position is a variable that controls if the bot moves directly to a set point, or instead moves a set distance towards a point
    --suggested to leave disabled (false) as it can cause the bot to get stuck on terrain or cause issues with pathing
    ai_data.absolute_position = false

    --obstructions table stores walls/mines/storms
    ai_data.obstructions = ai_data.obstructions or {}
    
    --update some common data for the target unit
    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
    ai_data.target_data = target_data
    ai_data.target_unit_data = target_data
    ai_data.target_distance = unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit or ai_data.bot_unit)

    --add control to manually cancel the current ability
    --disabled as another method is used in queue_controller.lua
    -- if self.input_controller:input_pressed_once("x") then
    --     ai_data.cancel_ability = true
    --     ai_data.clear_queue = true
    -- end

    --cancel the current ability if the target is the bot unit
    if ai_data.target_unit == ai_data.bot_unit then
        ai_data.cancel_ability = true
        ai_data.clear_queue = true
    end

    --clear queue if the player has died
    --not currently used
    if helper.player_killed then 
        helper.player_killed = false
        print("A player has died! Clear the bot action queue!")
        queue:clear_all_but_active_ability()
        queue:cancel_current_action()
    end

    --watches may be used to test performance of certain functions
    --currently disabled

    --ai_data.stop_watch:start_watch("update_wanted_ward")
    self:update_wanted_ward(dt)
    --ai_data.stop_watch:stop_watch("update_wanted_ward")
    
    --ai_data.stop_watch:start_watch("update_mode")
    self:update_mode(dt)
    --ai_data.stop_watch:stop_watch("update_mode")

    --ai_data.stop_watch:start_watch("update_pathing")
    self:update_pathing(dt)
    --ai_data.stop_watch:stop_watch("update_pathing")

    --ai_data.stop_watch:start_watch("update_debug")
    self:update_debug(dt)
    --ai_data.stop_watch:stop_watch("update_debug")
end

--- loops through available abilities
--- and selects the highest scoring ability
function Bot:select_ability()
    local ai_data = self.ai_data
    local dt = self.dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)

    local highest_score = 0
    local highest_scoring_ability = nil
    local highest_scoring_ability_key = "missing ability"

    --loop through all abilities and evaluate them
    for key, evaluation_function in pairs(abilities.evaluation_functions) do
        local temp_score, suggested_ability = evaluation_function(ai_data, dt, key)

        printf("Ability: %s score: %s", key, tostring(temp_score))

        if highest_score < temp_score then 
            highest_score = temp_score
            highest_scoring_ability = suggested_ability
            highest_scoring_ability_key = key
            --printf("Ability: %s high score: %s", highest_scoring_ability_key, tostring(highest_score))
        end
    end

    printf("Ability: %s best high score: %s", highest_scoring_ability_key, tostring(highest_score))
    ai_data.current_high_score = "Ability: " .. highest_scoring_ability_key .. " best high score: " .. tostring(highest_score)
    
    if highest_score > 0 then 
        if type(highest_scoring_ability) == "table" then
            queue:new_combo(highest_scoring_ability, highest_scoring_ability_key)
        else
            queue:new_action(highest_scoring_ability, highest_scoring_ability_key)
        end
    else
        --print("No abilities scored more than 0!")
        pdDebug.text("-----------------No abilities scored more than 0!")
    end
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

    --previously all logic was put in here, but now it has been migrated to select_ability()
    --sample below may be uncommented and used as a template for adding new logic
    --or may use the select_ability() function to evaluate a list of abilities and select the highest scoring one
    --add actions/combos here
    -- if ai_data.target_unit and ai_data.target_unit ~= ai_data.bot_unit and ai_data.self_data.health_p >= 90 then
    --     if unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit) < 4 then
    --         queue:new_action(abilities.weapon.charge)
    --     else
    --         queue:new_combo(combos.water_beam_cold_shatter(ai_data))
    --     end
    -- elseif ai_data.self_data.health_p < 90 then
    --     queue:new_combo(combos.heal_turtle(ai_data))
    -- end
    
    self:select_ability()
end

--- Saves the map once generated to prevent having to rebuild map grid again in the future
--- activates on when players are initialized
local function players_initialized(context)
	BotPathing:build_map()
    BotPathing:save_json_map(GET_GAME_DATA("hud_manager").level_settings.minimap.texture)
    print("Bot initialized, map saved!")
end

SE.event_handler.register_event("ingame", "players_initialized", "BotNecromancerBoss", players_initialized)

return Bot
