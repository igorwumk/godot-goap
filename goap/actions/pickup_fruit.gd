extends GOAPActionExecutor

func _init() -> void:
	required_methods = ["get_closest_node_in_group", "move_to", "pick_up"]

func perform(agent: Node, delta: float) -> bool:
	if not is_running:
		start(agent)
	var target = agent.get_closest_node_in_group("fruit")
	if target:
		agent.move_to(target)
		if agent.global_transform.origin.distance_to(target.global_transform.origin) < agent.pickup_range:
			agent.pick_up(target)
			return success(agent)
	else:
		return fail(agent)
	return false
