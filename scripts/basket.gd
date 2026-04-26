extends CSGBox3D

@onready var stored_fruit: int = 0:
	set(value):
		stored_fruit = value
		count_changed.emit(stored_fruit)

signal count_changed(count: int)

func store_fruit(fruit: Node3D) -> void:
	if fruit.is_in_group("fruit"):
		fruit.queue_free()
		stored_fruit += 1
	else:
		push_warning("Can't store things in basket that aren't fruit")
