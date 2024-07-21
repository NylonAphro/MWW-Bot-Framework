# Bot Framework

I expect this to be riddled with bugs so please let me know if any issues come up.


_To use download and extract the project folder into your MWW Modding project folder, or drag and drop it into the mod builder screen to create a new project._


*Make sure you already have downloaded and installed the Bot - Base*

## Files
 `ai-bot_logic.lua`
The main file of interest. Add or link the bulk of your code into the provided update loops there.

`ai-abilities.lua` 
Define your ability presets in here, a bunch of basic samples are already included.

`ai-ability_combos.lua`
Combos are available to define more complex behaviour. 

`ai-action_controller`
This file does the bulk of the heavy lifted to control the bot. I suggest not editing too much in this file unless you really know what you are doing. The only things you should be editing here are  
```lua
ActionController.activation_conditions
ActionController.on_update
ActionController.condition_groups
```

`ai-helper_library.lua`
Has a bunch of usefull functions for grabbing info on the fly, like player postions or getting the list of obstructions between the player.

`ai-queue_controller.lua`
I would suggest also not editing this file. It handles the basic queue system for the bot.

## Getting started

To get started try adding some lines of code to the `Bot:update_logic()` function.
The bot operates on a *queue* system. You queue a number of actions and the bot performs those actions or abilities in the order of the *queue*. An action is one of the possible abilities, including turning, moving, casting a spell, using a weapon or using a magick.

 *make the bot wait*
```lua
--this will make the bot wait the given time before moving onto the next item in the queue
--wait time is given in seconds, here will pause the bot for 5 seconds
queue:new_action(action.wait(5))
```

### *make the bot face a point*
```lua
--this will make the bot face a given point or vector
queue:new_action(action.face_point({0,0,0}))
```

### *make the bot move to a point*
```lua
--this will make the bot move to a given point or vector
--the bot will not move onto the next action in the queue until it reaches the given point
queue:new_action(action.move_to_point({0,0,0}))
```

### *set the bot's move target*
```lua
--this will make the bot move to a given point or vector
--the bot will continue onto the next action in the queue right away
queue:new_action(action.set_move_target({0,0,0}))
```

### *cast a spell*
```lua
--this will make the bot cast a spell at the given target
--the spell is defined as a table of elements
--you can define the elements by using {a,a,a}, spells.aaa, or {"lightning","lightning","lightning"}
--the third arg, here entered as false is if the spell is to be a selfcast or not
--the last arg is the duration of the spell, but a selfcast doesn't have a charge or channel time
queue:new_action(action.spell({0,0,0}, {a,a,a}, false, 0))
```

### *cast a beam*
```lua
--this will make the bot cast a beam at the given target for the duration of 5 seconds
queue:new_action(action.beam({0,0,0}, spells.sss, 5))
```

### *cast a projectile*
```lua
--projectiles are mostly the same as other spells, but instead of the duration being 
--based off of a elapsed time in seconds it is based off of the charge value between
--0 and 1, this means that a value of 1 will be overcharged and 0 is not charged at all
--this prevents players with different gear timings from getting knocked over from 
--overcharging a spell - side not 0.9 is enough to shatter a target
queue:new_action(action.projectile({0,0,0}, spells.ddd, 0.9))
```

This is a lot to take in already but it gets way better!
Actions can also receive input conditions so they won't execute unless all the conditions are true

### *cast a ward*
```lua
--cast a ward but only if the bot isn't already in that ward
queue:new_action(action.ward(
    {e,d,d}, 
    {}, --condition args is a table unused here but can be used to pass in info to activation_conditions
    activation_condition.bot_not_already_warded
    ))
```

### *weapon swing*
```lua
--swing the weapon facing a given point
queue:new_action(action.weapon({0,0,0}))
```

### *weapon charged attack*
```lua
--you can also pass in on_update functions that affect the ability every frame
--in this sample we make sure the ability is always facing the target unit 
--here we pass in a table instead of just one activation condition, you can do the same
--for on_update functions.
--this sample will only use the weapon if the target is frozen, and will turn to face them every frame
queue:new_action(action.weapon({0,0,0}, helper.get_weapon_charge_time(), {}, {activation_condition.target_is_frozen, activation_condition.target_is_valid}, on_update.face_target_unit))
```

### *using a magick*
```lua
--casts a magick at a given target (side note may have issues right now with magicks that take more than one target input)
queue:new_action(action.magick({0,0,0}, available_magicks.frost_bomb))
```

### *there are also a number of premade abilities*
```lua
queue:new_action(abilities.aoe.sfs)
queue:new_action(abilities.beam.water)
queue:new_action(abilities.heal.mines_facing_away_from_target)
```

## Combos
And finally there are also combos, which provide the ability to define more complex behaviours
and combinations of different spells/logic
```lua
--take note a combo must always recieve the ai_data table as an argument 
--this will complete the full heal wall, mines and ward cycle with an aoe in 
--just one line of code!
queue:new_combo(combos.heal_turtle(ai_data))
```

I am still working on stuff so a lot may change, and I plan on making a better video or tutorial at a later point but I hope this is enough to get you peeps started!
