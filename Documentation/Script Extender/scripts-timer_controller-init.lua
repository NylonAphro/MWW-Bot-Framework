---@meta

---MWWSE
---@param context table
--- context should be defined as 
---{
-----duration = 1 -- (in seconds, declimal allowed)
-----func = function (that will be triggered when )
-----condition_args = (variables that get passed into function when triggered)
---}
--- context will not be persistant, cloned when added to timer list
function NEW_TIMER(context) end

---MWWSE
---@param duration any
---@param func any
---@param args any
---creates a timer without need of context table
function SIMPLE_TIMER(duration, func, args) end

---MWWSE
---@param duration any
---@param func any
---@param args any
---creates a timer without need of context table
function SIMPLE_DEBUG_TIMER(duration, func, args) end

---MWWSE
---returns a string value of time in format hours:minutes:seconds
---@return string|osdate
function GET_TIME() end

---MWWSE
---deletes the timer from the list of active timers
---@param name string
function REMOVE_TIMER(name) end

---MWWSE
---@param name string
---@return boolean
---returns true if time of given name is in list of active timers
function HAS_TIMER(name) end

