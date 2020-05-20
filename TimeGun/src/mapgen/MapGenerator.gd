extends Node2D

var Layer = preload("res://src/mapgen/Layer.tscn")

func _ready() -> void:
	create_layer("test_layer", "test")

# creates a layer with the given name and using the rule set given
func create_layer(name: String, ruleset: String):
	# create new layer
	var layer = Layer.instance()
	layer.name = name
	# call ruleset on layer
	layer.apply_ruleset(ruleset)
	# add layer to layers node
	$Layers.add_child(layer)
