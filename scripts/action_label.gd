extends Label

var basetext = "Current action: "

func _init() -> void:
	text = basetext

func _on_agent_action_changed(action: GOAPAction) -> void:
	text = basetext + str(action)
