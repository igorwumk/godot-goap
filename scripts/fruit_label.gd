extends Label

var basetext = "Fruit stored: "

func _init() -> void:
	text = basetext + str(0)

func _on_basket_count_changed(count: int) -> void:
	text = basetext + str(count)
