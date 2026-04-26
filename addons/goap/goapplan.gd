extends RefCounted
class_name GOAPPlan

var data: Array = []

func _init(initial_items: Array = []) -> void:
	data = initial_items.duplicate()

func is_empty() -> bool:
	return data.is_empty()

func size() -> int:
	return data.size()

func enqueue(item: RefCounted) -> void:
	data.append(item)

func dequeue() -> RefCounted:
	if data.is_empty():
		return null
	return data.pop_front()

func peek() -> RefCounted:
	if data.is_empty():
		return null
	return data[0]

func clear() -> void:
	data.clear()

func get_items() -> Array:
	return data.duplicate()

func next() -> GOAPAction:
	if data.is_empty():
		return null
	var now = data[0]
	data.pop_front()
	return now
