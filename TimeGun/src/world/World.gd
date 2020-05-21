extends MapGenerator

var layer = null
var player = null

func _ready() -> void:
	create_map()

func advance_level():
	player = null
	create_map()

func create_map():
	randomize()
	
	if layer:
		layer.queue_free()
	
	layer = create_layer("main_layer", "world")
