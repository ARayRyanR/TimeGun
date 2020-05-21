extends Node2D
class_name MapGenerator

var Layer = preload("res://src/mapgen/Layer.tscn")

# creates a layer with the given name and using the rule set given
func create_layer(name: String, ruleset: String) -> Node:
	# create new layer
	var layer = Layer.instance()
	layer.name = name
	add_child(layer)
	
	# call ruleset on layer
	layer.apply_ruleset(ruleset)
	# check if layer was valid
	if layer.layer_valid:
		# add and break
		return layer
	else:
		layer.queue_free()
		return create_layer(name, ruleset)
