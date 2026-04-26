extends CharacterBody3D

@export var gravity_strength: float = 981

var gravity_enabled: bool = true

func _physics_process(delta: float) -> void:
	if is_on_floor() or not gravity_enabled:
		velocity.y = 0
	else:
		velocity.y = -gravity_strength * delta
		move_and_slide()

func set_gravity_enabled(enable: bool) -> void:
	gravity_enabled = enable
