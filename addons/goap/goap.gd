@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("GOAPPlanner", "RefCounted", preload("res://addons/goap/goapplanner.gd"), null)
	add_custom_type("GOAPPlan", "RefCounted", preload("res://addons/goap/goapplan.gd"), null)
	add_custom_type("GOAPAction", "Resource", preload("res://addons/goap/goapaction.gd"), null)
	add_custom_type("GOAPActionExecutor", "RefCounted", preload("res://addons/goap/goapactionexecutor.gd"), null)
	add_custom_type("GOAPAgent", "Node", preload("res://addons/goap/goapagent.gd"), null)
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("GOAPPlanner")
	remove_custom_type("GOAPPlan")
	remove_custom_type("GOAPAction")
	remove_custom_type("GOAPActionExecutor")
	remove_custom_type("GOAPAgent")
	pass
