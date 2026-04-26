extends GOAPActionExecutor

var dropoff_zone: Node3D = null

func _init() -> void:
	required_properties = ["drop_distance", "held_object"]
	required_methods = ["get_closest_node_in_group", "move_to"]

func perform(agent: Node, delta: float) -> bool:
	if not is_running:
		start(agent)
		dropoff_zone = null
	if not dropoff_zone:
		dropoff_zone = agent.get_closest_node_in_group("basket")
	if dropoff_zone:
		agent.move_to(dropoff_zone)
		if agent.global_transform.origin.distance_to(dropoff_zone.global_transform.origin) < agent.drop_distance:
			dropoff_zone.store_fruit(agent.held_object)
			agent.held_object = null
			return success(agent)
	else:
		return fail(agent)
	return false
