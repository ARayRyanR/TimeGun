extends MapGenerator

var layer = null
var player = null

func _ready() -> void:
	create_map()

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_select"):
		create_map()

func create_map():
	randomize()
	
	if layer:
		layer.queue_free()
	
	layer = create_layer("main_layer", "world")
