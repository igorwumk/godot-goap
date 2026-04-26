extends MeshInstance3D

@export var prefab: PackedScene
@export var spawn_y_offset: float = 0.0

@onready var fruit_spawn_timer: Timer = $"../FruitSpawnTimer"

func _ready() -> void:
	randomize()
	fruit_spawn_timer.timeout.connect(_on_FruitSpawnTimer_timeout)

func _on_FruitSpawnTimer_timeout() -> void:
	_spawn_instance()

func _spawn_instance():
	if prefab == null:
		push_error("Spawner.prefab is not set!")
		return
	
	var plane = mesh as PlaneMesh
	if plane == null:
		push_error("Spawner.mesh must be a PlaneMesh!")
		return
	
	# Get half-extents of the PlaneMesh
	var half_width = plane.size.x * 0.5
	var half_depth = plane.size.y * 0.5
	
	# Pick a random point on the plane
	var local_x = randf_range(-half_width, half_width)
	var local_z = randf_range(-half_depth, half_depth)
	
	# Compute world position
	var world_y = global_transform.origin.y + spawn_y_offset
	var world_pos = global_transform.origin + Vector3(local_x, 0.0, local_z).rotated(Vector3(1, 0, 0), 0) # change if plane rotated
	world_pos.y = world_y
	
	# Instantiate prefab
	var instance = prefab.instantiate()
	get_parent().add_child(instance)
	instance.global_transform = Transform3D(instance.global_transform.basis, world_pos)
