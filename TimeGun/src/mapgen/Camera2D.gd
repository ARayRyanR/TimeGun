extends Camera2D


func _input(event: InputEvent) -> void:
	if event.is_action_released("zoom_in"):
		zoom /= 2
	if event.is_action_released("zoom_out"):
		zoom *= 2
