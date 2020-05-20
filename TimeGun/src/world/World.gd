extends Node2D

# holds current player
var current_player = null

# creates map on startup
func _ready() -> void:
	# generate map
	$MapGenerator.create_map()

# re create a map with space
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_select"):
		# generate map
		$MapGenerator.create_map()
