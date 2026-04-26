extends ProgressBar

func _on_agent_health_changed(health: float) -> void:
	value = health
