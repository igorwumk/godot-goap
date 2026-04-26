@tool
extends Resource
class_name GOAPAction

@export var name: String
@export var preconditions: Dictionary
@export var effects: Dictionary
@export var base_cost: float
var cost
@export var behavior_script: Script:
	set(value):
		behavior_script = value
		_update_executor()
		notify_property_list_changed()

var executor: RefCounted = null

func _update_executor():
	executor = null
	if behavior_script and behavior_script.can_instantiate():
		var instance = behavior_script.new()
		if instance is GOAPActionExecutor:
			executor = instance
			update_cost() # update real cost
		else:
			push_warning("GOAPAction: behavior_script must have perform() method")

func _init(name: String = "", preconditions: Dictionary = {}, effects: Dictionary = {}, base_cost: float = 0):
	self.name = name
	self.preconditions = preconditions
	self.effects = effects
	self.base_cost = base_cost

func _to_string() -> String:
	var string = name
	return string

# Override this function to implement custom logic
# Returns true if completed - false if running or failed
func perform(agent: Node, delta: float) -> bool:
	if executor:
		return executor.perform(agent, delta)
	else:
		push_error("No valid executor for action: %s" % name)
		return false

# Returns true if agent has properties/methods required by perform()
func can_execute(agent: Node) -> bool:
	return executor.can_execute(agent)

func state() -> GOAPActionExecutor.State:
	return executor.state()

func update_cost(agent: Node = null) -> void:
	self.cost = executor.calculate_action_cost(base_cost, agent)

# Check if preconditions match the current state
func check_preconditions(state: Dictionary) -> bool:
	for key in preconditions.keys():
		if state.get(key) != preconditions[key]:
			return false
	return true

# Apply effects to a simulated state
func apply_effects(state: Dictionary) -> Dictionary:
	var new_state = state.duplicate()
	for key in effects.keys():
		new_state[key] = effects[key]
	return new_state
