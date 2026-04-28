# Goal-Oriented Action Planning plugin for Godot 4.3
## Usage
### Creating new action
1. Create a new `GOAPAction` resource in Godot filesystem.
2. Choose the name, preconditions, effects and cost for the action in the Inspector. Preconditions and effects use `String` key and `bool` value.
3. Create a new GDScript in the Godot filesystem that inherits from `GOAPActionExecutor`.
4. In the created script, implement `_init()` and `perform(agent, delta)`. Use the `is_running` property and the `start()`, `success()`, `fail()` functions to properly communicate the action's state.
### Using an agent
1. Add a `GOAPAgent` as a child node to the one that's supposed to be the agent in game's world.
2. Extend the script from the `GOAPAgent` node - ensure the script inherits from that type.
3. In the extended script, override `setup_initial_state()`; define the start state, load actions (through `set_actions([preload("res://path/to/action/resource.tres").duplicate(), ...])` and change the default heuristic if desired (ex. `current_planner.set_max_heuristic()`).
4. Make a reference to `GOAPAgent` node in your agent (ex. `@onready var goap_agent: GOAPAgent = $GOAPAgent`).
5. Make a function in your agent that decides upon the current state(s) and plan generation:
```
func goap() -> void:
  if is_hungry:
    goap_agent.set_goals({"hungry": false})
    goap_agent.set_state({"hungry": true})
  else:
    goap_agent.set_goals({"store_fruit": true})
    goap_agent.set_state({"holding_fruit": false, "store_fruit": false})
  goap_agent.replan()
```
6. Trigger the GOAP from your agent (ex. in `_physics_process(delta)`):
```
func _physics_process(delta: float) -> void:
	if goap_agent.current_plan == null or goap_agent.current_plan.size() == 0:
		goap()
	if goap_agent.current_plan != null and goap_agent.current_plan.size() > 0:
		if goap_agent.get_current_action() == null:
			goap_agent.get_next_action()
			action_changed.emit(goap_agent.get_current_action())
		else:
			var done = goap_agent.perform_action(delta)
			if done:
				goap_agent.update_states()
				goap_agent.get_next_action()
				action_changed.emit(goap_agent.get_current_action())
	reduce_health(delta)
```
