extends MapGenerator

var current_player = null

func _ready() -> void:
	create_map()

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_select"):
		create_map()

func create_map():
	randomize()
	delete_layers()
	
	create_layer("floor_layer", "floor")
	var walls = create_layer("main_layer", "world")
	#create_layer("overlay", "pipes")
