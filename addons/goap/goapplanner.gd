extends RefCounted
class_name GOAPPlanner

var _heuristic_func: Callable = _default_heuristic

var h_consistent: bool = true # if heuristic is consistent

func plan(state, goal, actions):
	return a_star(state, goal, actions)

func set_h_consistency(value: bool) -> void:
	h_consistent = value

func set_heuristic(heuristic: Callable) -> void:
	_heuristic_func = heuristic

func set_null_heuristic() -> void:
	_heuristic_func = _null_heuristic
	set_h_consistency(true)

func set_default_heuristic() -> void:
	_heuristic_func = _default_heuristic
	set_h_consistency(true)

func set_sum_heuristic() -> void:
	_heuristic_func = _sum_heuristic
	set_h_consistency(true)

func set_max_heuristic() -> void:
	_heuristic_func = _max_heuristic
	set_h_consistency(true)

func _call_heuristic(state: Dictionary, goal_state: Dictionary, actions: Array) -> float:
	if _heuristic_func.is_valid():
		return _heuristic_func.call(state, goal_state, actions)
	return _default_heuristic(state, goal_state, actions)

func _default_heuristic(state: Dictionary, goal_state: Dictionary, actions: Array) -> float:
	var total_cost = 0
	for key in goal_state.keys():
		if not state.get(key, false) != goal_state[key]:
			total_cost += 1  # Increase cost by 1 for each non-fulfilled state
	return total_cost

func _null_heuristic(state: Dictionary, goal_state: Dictionary, actions: Array) -> float:
	return 0

func _sum_heuristic(state: Dictionary, goal_state: Dictionary, actions: Array) -> float:
	var total_cost = 0
	var used_actions = []
	for key in goal_state.keys():
		if not state.get(key, false) != goal_state[key]:
			var min_cost_action = get_cheapest_fulfilling_action({key: goal_state[key]}, actions)
			if not used_actions.has(min_cost_action):
				used_actions.append(min_cost_action)
				total_cost += min_cost_action.cost
	return total_cost

func _max_heuristic(state: Dictionary, goal_state: Dictionary, actions: Array) -> float:
	var max_cost = 0
	for key in goal_state.keys():
		if not state.get(key, false) != goal_state[key]:
			var min_state_cost = get_cheapest_fulfilling_action({key: goal_state[key]}, actions).cost
			if min_state_cost > max_cost:
				max_cost = min_state_cost
	return max_cost

func get_cheapest_fulfilling_action(state: Dictionary, actions: Array) -> GOAPAction:
	assert(state.size() == 1)
	var min_cost_action = actions[0]
	for action in actions:
		for effect in action.effects:
			if effect.hash() == state.hash() and action.cost < min_cost_action.cost:
				min_cost_action = action
	return min_cost_action

func get_lowest_f_score(open_set: Array, f_score: Dictionary) -> Dictionary:
	var lowest = open_set[0]
	for state in open_set:
		if f_score[state] < f_score[lowest]:
			lowest = state
	return lowest

func is_goal_state(state: Dictionary, goal_state: Dictionary) -> bool:
	for key in goal_state.keys():
		if state.get(key, false) != goal_state[key]:
			return false
	return true

func reconstruct_path(came_from: Dictionary, current: Dictionary, actions: Dictionary) -> Array:
	var total_path = []
	while current in actions:
		var action = actions[current]
		total_path.append(action)
		current = came_from[current]
	total_path.reverse()
	return total_path

func can_perform_action(action: GOAPAction, state: Dictionary) -> bool:
	for key in action.preconditions.keys():
		if state.get(key, false) != action.preconditions[key]:
			return false
	return true

func apply_action(state: Dictionary, action: GOAPAction) -> Dictionary:
	var new_state = state.duplicate()
	for key in action.effects.keys():
		new_state[key] = action.effects[key]
	return new_state

func a_star(start_state: Dictionary, goal_state: Dictionary, actions: Array) -> GOAPPlan:
	var open_set = []
	var closed_set = []
	var came_from = {}
	var action_taken = {}
	
	var g_score = {start_state: 0}
	var f_score = {start_state: _call_heuristic(start_state, goal_state, actions)}
	
	open_set.append(start_state)
	
	while open_set.size() > 0:
		var current = get_lowest_f_score(open_set, f_score)
		
		if is_goal_state(current, goal_state):
			return GOAPPlan.new(reconstruct_path(came_from, current, action_taken))
		
		open_set.erase(current)
		if not closed_set.has(current) and h_consistent:
			closed_set.append(current)
		
		for action in actions:
			if not can_perform_action(action, current):
				continue
			
			var new_state = apply_action(current, action)
			
			if closed_set.has(new_state) and h_consistent:
				continue
			
			var tentative_g_score = g_score[current] + action.cost
			if tentative_g_score >= g_score.get(new_state, INF):
				continue
			
			if not open_set.has(new_state):
				open_set.append(new_state)
			
			came_from[new_state] = current
			action_taken[new_state] = action
			g_score[new_state] = tentative_g_score
			f_score[new_state] = g_score[new_state] + _call_heuristic(new_state, goal_state, actions)
	
	return GOAPPlan.new([])  # Return an empty path if no path is found
