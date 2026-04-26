extends CharacterBody3D

@export var speed: float = 10
@export var health: float = 50:
	set(value):
		var temp = health
		health = value
		if health < health_threshold and temp >= health_threshold: # Dropped below health threshold
			goap_agent.clear_current_plan()
			is_hungry = true
		if health > satiation_threshold and temp <= satiation_threshold: # No longer hungry
			goap_agent.clear_current_plan()
			is_hungry = false
		health_changed.emit(health)
@export var health_drop: float = 2
@export var pickup_range: float = 1.5
@export var drop_distance: float = 1.5
@export var health_threshold: float = 50
@export var satiation_threshold: float = 85

@onready var goap_agent: GOAPAgent = $GOAPAgent
@onready var hold_position: Node3D = $HoldPosition
@onready var dropoff_zone: Node3D = $"../NavigationRegion3D/Floor/Basket"
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

signal health_changed(health: float)
signal action_changed(action: GOAPAction)

var held_object = null
var is_hungry = true

func _ready() -> void:
	health_changed.emit(health) # Properly set health value at UI

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

func reduce_health(delta: float) -> void:
	health -= health_drop * delta
	if health <= 0:
		queue_free()

func goap() -> void:
	if is_hungry:
		goap_agent.set_goals({"hungry": false})
		goap_agent.set_state({"hungry": true})
	else:
		goap_agent.set_goals({"store_fruit": true})
		goap_agent.set_state({"holding_fruit": false, "store_fruit": false})
	goap_agent.replan()

func pick_up(object: Node3D) -> void:
	held_object = object
	
	object.set_physics_process(false)
	
	object.get_parent().remove_child(object)
	hold_position.add_child(object)
	
	object.position = Vector3.ZERO

func get_closest_node_in_group(group: String) -> Node:
	var array = get_tree().get_nodes_in_group(group)
	var closest = null
	for el in array:
		if closest == null:
			closest = el
		else:
			if global_position.distance_to(el.global_position) < global_position.distance_to(closest.global_position):
				closest = el
	return closest

func move_to(destination: Node3D) -> void:
	navigation_agent_3d.target_position = destination.global_position
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()
	var flat_target = next_position
	flat_target.y = global_position.y
	look_at(flat_target, Vector3.UP)
	velocity = direction * speed
	move_and_slide()
