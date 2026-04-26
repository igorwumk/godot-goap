extends GOAPAgent

func setup_initial_state() -> void:
	set_actions([
		preload("res://goap/actions/eat_fruit.tres").duplicate(),
		preload("res://goap/actions/pickup_fruit.tres").duplicate(),
		preload("res://goap/actions/store_fruit.tres").duplicate()
	])
	current_planner.set_max_heuristic()
