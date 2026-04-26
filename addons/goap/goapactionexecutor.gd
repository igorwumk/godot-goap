extends RefCounted
class_name GOAPActionExecutor

enum State {IDLE, RUNNING, COMPLETED, FAILED}

signal action_started(agent: Node)
signal action_updated(agent: Node, delta: float)
signal action_completed(agent: Node)
signal action_failed(agent: Node)

var is_running: bool = false
var current_state: State = State.IDLE

@export var required_properties: Array = []
@export var required_methods: Array = []

# Override this function to implement custom logic
# Returns true if completed - false if running or failed
func perform(agent: Node, delta: float) -> bool:
	action_started.emit(agent) if not is_running else null
	is_running = true
	current_state = State.RUNNING
	action_updated.emit(agent, delta)
	is_running = false
	current_state = State.COMPLETED
	action_completed.emit(agent)
	return true

# Returns true if agent has properties/methods required by perform()
func can_execute(agent: Node, properties: Array = required_properties, methods: Array = required_methods) -> bool:
	var failed = false
	if properties != required_properties and methods == required_methods:
		methods = [] # Reset methods so that the function doesn't read required_methods when only properties passed
	elif properties == required_properties and methods != required_methods:
		properties = [] # Same for reverse situation
	if properties == null:
		properties = []
	if methods == null:
		methods = []
	for property in properties:
		if not agent.get(property):
			push_warning("Property ", property, " not found in node ", agent)
			failed = true
	for method in methods:
		if not agent.has_method(method):
			push_warning("Method ", method, " not found in node ", agent)
			failed = true
	return not failed

# Override this function to calculate action cost based on current world state
func calculate_action_cost(base_cost: float, agent: Node = null) -> float:
	return base_cost

# Helper function to start the action
func start(agent: Node) -> void:
	if not is_running:
		is_running = true
		current_state = State.RUNNING
		action_started.emit(agent)
	else:
		push_warning("Action already started")

# Helper function to indicate success
func success(agent: Node) -> bool:
	is_running = false
	current_state = State.COMPLETED
	action_completed.emit(agent)
	return true

# Helper function to indicate fail
func fail(agent: Node) -> bool:
	is_running = false
	current_state = State.FAILED
	action_failed.emit(agent)
	return false

# Returns current state
func state() -> State:
	return current_state
