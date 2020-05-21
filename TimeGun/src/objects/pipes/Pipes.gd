extends Node2D

func _ready() -> void:
	# choose random prefab
	var n = randi()%2 + 1
	var prefab = load("res://src/objects/pipes/PreFab" + str(n) + ".tscn").instance()
	add_child(prefab)
