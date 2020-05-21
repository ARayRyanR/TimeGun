extends Node2D

signal finished

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		emit_signal("finished")
