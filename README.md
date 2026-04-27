# Goal-Oriented Action Planning plugin for Godot 4.3
## Usage
### Creating new action
1. Create a new `GOAPAction` resource in Godot filesystem.
2. Choose the name, preconditions, effects and cost for the action in the Inspector. Preconditions and effects use `String` key and `bool` value.
3. Create a new GDScript in the Godot filesystem that inherits from `GOAPActionExecutor`.
4. In the created script, implement `_init()` and `perform(agent, delta)`. Use the `is_running` property and the `start()`, `success()`, `fail()` functions to properly communicate the action's state.
