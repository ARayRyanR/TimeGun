extends Layer

# @@@ CURRENT PLAYER NODE @@@
var player = null

func _ready() -> void:
	create_map()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		player = null
		create_map()

# Creates a valid map
func create_map():
	randomize()
	
	# resets map
	clear_map()
	# creates new map
	ruleset_world()
	# makes sure is valid
	if layer_valid:
		return
	# if not, reset and try again
	else:
		layer_valid = true
		create_map()

func clear_map():
	for l in get_children():
		for n in l.get_children():
			n.queue_free()

################################################################################
#                    MAP RULESET
################################################################################
var MAP_WIDTH  = 48
var MAP_HEIGHT = 48

var grass_tiles = preload("res://assets/tilesets/grass.tres")
var wall_tiles  = preload("res://assets/tilesets/wall.tres")
var Player      = preload("res://src/actors/player/Player.tscn")
var Swarm       = preload("res://src/actors/drones/DroneSwarm.tscn")

# @@@ RULE SETS DEFINITIONS @@@
# creates the walls, player, enemies, etc
func ruleset_world():
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
