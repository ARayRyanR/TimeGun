extends Layer

# @@@ CURRENT PLAYER NODE @@@
var player = null
var playing = false

var Store = preload("res://src/Store.tscn")

func _ready() -> void:
	create_map("regular")
	update_objectives()

func _process(delta: float) -> void:
	if playing:
		update_objectives()
		
		if Data.objectives.enemies <= 0:
			advance_level()

func advance_level():
	# exit map
	player  = null
	playing = false

	# enter store
	get_tree().change_scene("res://src/Store.tscn")

# Creates a valid map
func create_map(ruleset: String):
	randomize()
	
	# resets map
	_clear_map()
	# creates new map
	_use_ruleset(ruleset)
	# makes sure is valid
	if layer_valid:
		playing = true
		return
	# if not, reset and try again
	else:
		layer_valid = true
		create_map(ruleset)

func _clear_map():
	for l in get_children():
		for n in l.get_children():
			n.queue_free()

func _use_ruleset(ruleset: String):
	call("ruleset_" + ruleset)

func update_objectives():
	# update enemies objective
	Data.objectives.enemies = 0
	for enemy in $Enemies.get_children():
		Data.objectives.enemies += 1

################################################################################
#                    MAP RULESET
################################################################################
# map size
var MAP_WIDTH  = 48
var MAP_HEIGHT = 48

# map resources
var grass_tiles = preload("res://assets/tilesets/grass.tres")
var wall_tiles  = preload("res://assets/tilesets/wall.tres")
var shadow_tiles= preload("res://assets/tilesets/occlusion.tres")
var Player      = preload("res://src/actors/player/Player.tscn")
var Swarm       = preload("res://src/actors/drones/DroneSwarm.tscn")
var Pickup      = preload("res://src/objects/Pickup.tscn")

# @@@ RULE SETS DEFINITIONS @@@
# the default map
func ruleset_regular():
	# Create map grid
	rule_grid_size(MAP_WIDTH, MAP_HEIGHT)
	
	# Create floor tilemap
	rule_ones_grid()
	rule_set_tilesize(64, 64)
	rule_set_variations([])
	var floor_map = rule_build_tilemap_from_ones(grass_tiles)
	floor_map.name = "Grass"
	$Floor.add_child(floor_map)
	
	# Create walls tilemap
	rule_zero_grid()
	rule_random_ones(450)
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_smooth_corners()
	rule_flood_ones()
	rule_check_area(450)
	rule_set_variations([[1, 50]])
	var walls_map = rule_build_tilemap_from_ones(wall_tiles)
	walls_map.name = "Walls"
	$Walls.add_child(walls_map)
	
	# Spawn player
	var pos = rule_get_empty_position()
	player = Player.instance()
	player.global_position = pos
	# set player camera limits
	player.get_node("Camera2D").limit_right = layer_gridx*layer_cellx
	player.get_node("Camera2D").limit_bottom = layer_gridy*layer_celly
	$Player.add_child(player)
	
	# Spawn a swarm
	pos = rule_get_empty_position()
	var swarm = Swarm.instance()
	swarm.global_position = pos
	$Enemies.add_child(swarm)
	
	# Spawn some pickups
	var p = Pickup.instance()
	p.global_position = rule_get_empty_position()
	$Walls.add_child(p)
	p = Pickup.instance()
	p.global_position = rule_get_empty_position()
	$Walls.add_child(p)
	
	# Create wall shadows
	var shadow_maps = rule_create_occlusion(shadow_tiles) # get grid of shadows
	for map in shadow_maps:
		$Floor.add_child(map)

# an empty arena
func ruleset_arena():
	# Create map grid
	rule_grid_size(MAP_WIDTH, MAP_HEIGHT)
	
	# Create floor tilemap
	rule_ones_grid()
	rule_set_tilesize(64, 64)
	rule_set_variations([])
	var floor_map = rule_build_tilemap_from_ones(grass_tiles)
	floor_map.name = "Grass"
	$Floor.add_child(floor_map)
	
	# Create walls tilemap
	rule_zero_grid()
	rule_border_ones()
	rule_set_variations([[1, 50]])
	var walls_map = rule_build_tilemap_from_ones(wall_tiles)
	walls_map.name = "Walls"
	$Walls.add_child(walls_map)
	
	# Spawn player
	var pos = rule_get_empty_position()
	player = Player.instance()
	player.global_position = pos
	# set player camera limits
	player.get_node("Camera2D").limit_right = layer_gridx*layer_cellx
	player.get_node("Camera2D").limit_bottom = layer_gridy*layer_celly
	$Player.add_child(player)
	
	# Spawn a swarm
	#pos = rule_get_empty_position()
	#var swarm = Swarm.instance()
	#swarm.global_position = pos
	#$Enemies.add_child(swarm)
	
	# Create wall shadows
	var shadow_maps = rule_create_occlusion(shadow_tiles) # get grid of shadows
	for map in shadow_maps:
		$Floor.add_child(map)
