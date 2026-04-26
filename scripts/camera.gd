extends Camera3D

@export var target: Node3D
var offset: Vector3 = position

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	if target:
		var desired_position = target.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(desired_position, 0.1)
