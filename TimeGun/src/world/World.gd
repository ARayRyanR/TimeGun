extends Node2D


func _ready() -> void:
	# generate map
	$MapGen.create_map()

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_select"):		
		# generate map
		$MapGen.create_map()
