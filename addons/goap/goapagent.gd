extends Node
class_name GOAPAgent

@export var agent: Node = null

var current_planner: GOAPPlanner = null
var current_goal: Dictionary = {}
var current_plan: GOAPPlan = null
var current_state: Dictionary = {}
var available_actions: Array[GOAPAction] = []
var current_action: GOAPAction = null
var action_valid: bool = false

var existing_action_names: Array[String] = []

func _ready() -> void:
	if agent == null: # Automatically set the agent if not set yet
		agent = get_parent()
		if agent == null:
			push_error("GOAPAgent failed to acquire parent node")
			return
	
	current_planner = GOAPPlanner.new()
	current_plan = GOAPPlan.new()
	setup_initial_state()

# Override this function to specify initial state
func setup_initial_state() -> void:
	pass

# Replaces current states with those in the function
func set_states(states: Dictionary) -> void:
	current_state = states

# Applies states from the function to the current set
func set_state(state: Dictionary) -> void:
	for key in state.keys():
		current_state[key] = state[key]

# Removes the specified state from the set
func remove_state(key: Variant) -> bool:
	return current_state.erase(key)

# Replaces current goals with those in the function
func set_goals(goals: Dictionary) -> void:
	current_goal = goals

# Applies goals from the function to the current set
func set_goal(goal: Dictionary) -> void:
	for key in goal.keys():
		current_goal[key] = goal[key]

# Removes the specified goal from the set
func remove_goal(key: Variant) -> bool:
	return current_goal.erase(key)

# Sets the actions set to the one in the function
func set_actions(actions: Array[GOAPAction]) -> void:
	available_actions = actions
	reload_action_names()

# Retrieves all actions
func get_actions() -> Array[GOAPAction]:
	return available_actions

# Fully reloads list of loaded action names
func reload_action_names() -> void:
	existing_action_names = []
	for action in available_actions:
		existing_action_names.append(action.name)

# Adds the action to the set if it doesn't exist
func add_action(action: GOAPAction) -> void:
	if action.name not in existing_action_names:
		available_actions.append(action)
		existing_action_names.append(action.name)
	else:
		push_warning("Action ", action.name, " already exists")

# Removed action with specified name from the set
func remove_action(name: String) -> void:
	var index = existing_action_names.find(name)
	if index >= 0:
		available_actions.remove_at(index)
		existing_action_names.remove_at(index)
	else:
		push_warning("Action ", name, " doesn't exist")

# Runs the action
func perform_action(delta: float) -> bool:
	if action_valid:
		return current_action.perform(agent, delta)
	else:
		push_warning("GOAPAgent: Action is not valid")
		return false

# Triggers replanning according to current internal state
func replan() -> void:
	current_plan = current_planner.plan(current_state, current_goal, available_actions)
	if current_plan.is_empty():
		print("GOAPAgent: No plan found for goal ", current_goal)

# Retrieves next action
func get_next_action() -> GOAPAction:
	if current_plan:
		current_action = current_plan.next()
		action_valid = true
		return current_action
	else:
		return null

# Retrieves current action
func get_current_action() -> GOAPAction:
	if action_valid:
		return current_action
	else:
		return null

# Modifies states according to current function
func update_states() -> void:
	current_state = current_action.apply_effects(current_state)

# Clears current plan
func clear_current_plan() -> void:
	current_plan = null
	action_valid = false # update_states() still needs reference

# Changes current planner
func change_planner(planner: GOAPPlanner) -> void:
	current_planner = planner
