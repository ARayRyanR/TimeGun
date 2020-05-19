extends Node2D

var map_grid = []

func _ready() -> void:
	# generate map
	$MapGen.gen_map()
	map_grid = $MapGen.grid

	# player
	spawn_player()

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_select"):
		# generate map
		$MapGen.gen_map()
		map_grid = $MapGen.grid
	
		# player
		spawn_player()

func spawn_player():
	$Player.global_position = $MapGen.get_spawn_point()
