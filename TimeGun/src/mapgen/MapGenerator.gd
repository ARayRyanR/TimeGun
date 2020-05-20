extends Node2D

var Layer = preload("res://src/mapgen/Layer.tscn")


func create_map():
	randomize()
	delete_layers()
	create_layer("floor_layer", "floor")
	create_layer("main_layer", "world")
	create_layer("overlay", "webs")

# creates a layer with the given name and using the rule set given
func create_layer(name: String, ruleset: String):
	# create new layer
	var layer = Layer.instance()
	layer.name = name
	# call ruleset on layer
	layer.apply_ruleset(ruleset)
	# check if layer was valid
	if layer.layer_valid:
		# add and break
		$Layers.add_child(layer)
		return
	else:
		create_layer(name, ruleset)

func delete_layers():
	for n in $Layers.get_children():
		n.queue_free()
