require("ai/helper_library")
local InputController = require("scripts/input_controller")
local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities
local bot = require("ai/bot_logic")
bot:init()

QueueController = {}

QueueController.action_queue = {}
QueueController.queue_busy = false
QueueController.max_queue_size = 20

---queue_controller
---Gets the current action from the action queue.
---@return any 
---The current action or nil if the queue is empty.
function QueueController:get_current_action()
    return self.action_queue[1]
end

---queue_controller
---Removes the first action from the action queue.
function QueueController:finish_action()
    if #self.action_queue > 0 then
        print("Removing action: " .. PAIRS_TO_STRING(self.action_queue[1], 0))
        table.remove(self.action_queue, 1)
    end
end

---queue_controller
---Adds an action to the action queue.
---@param action any|function
function QueueController:new_action(action)
    if #self.action_queue >= self.max_queue_size then
        printf("Action queue is full, cannot add more than %s actions!", tostring(self.max_queue_size))
        return
    end

    if type(action) == "function" then
        action = action()
    end

    table.insert(self.action_queue, action)
end

---queue_controller
---Adds a combo of actions to the action queue.
---@param combo function|table The combo function or table of actions to be added.
function QueueController:new_combo(combo)
    if type(combo) == "function" then
        combo = combo()
    end

    if type(combo) == "table" then
        for _, action in ipairs(combo) do
            self:new_action(action)
        end
    else
        print("Invalid combo type, expected function or table.")
    end
end

---queue_controller
---Cancels the current action in the queue.
function QueueController:cancel_current_action()
    local current_action = self:get_current_action()
    if current_action then
        current_action.stop_ability = true
    end
end

---queue_controller
---Removes all actions in the action queue.
function QueueController:clear()
    self:cancel_current_action()
    self.action_queue = {}
end

---queue_controller
---Evaluates abilities and updates bot state every frame.
---@param ai_data any
---@param dt any
function QueueController:evaluate_abilities(ai_data, dt)
    self.ai_data = ai_data
    self.dt = dt

    bot.queue = self
    bot.ai_data = ai_data
    bot.action = ActionController
    bot.combo = BotCombos

    if ai_data.bot_disabled then
        self:clear()
    end

    bot:select_target()
    bot:update()

    if ai_data.self_data.state == "onground" and #self.action_queue == 0 and not self.queue_busy and not ai_data.bot_disabled then
        bot:update_logic(self)
    end

    if InputController:input_pressed_once("x") then
        print("Manually cancelling first action")
        self:cancel_current_action()
    end
end

---queue_controller
---Updates the current action every frame.
---@param ai_data any
---@param dt any
function QueueController:update_active_ability(ai_data, dt)
    local current_action = self:get_current_action()
    if current_action then
        if current_action.stop_ability then
            if current_action.deactivate then
                current_action.deactivate(current_action, ai_data, dt)
            end
            self:finish_action()
            self.queue_busy = false
            return
        end

        if not self.queue_busy then
            bot.action.run_activation_conditions(current_action, ai_data, dt)
            if not current_action.can_use_ability then
                self:finish_action()

                --recursively call update until there is either no action, or a valid action
                --to prevent multiple frames between spells that couldn't be cast
                self:update_active_ability(ai_data, dt)
                return
            end
        end

        if current_action.update and not current_action.stop_ability then
            self.queue_busy = true
            current_action.update(current_action, ai_data, dt)
            return
        end
    else
        self.queue_busy = false
    end
end

return QueueController
