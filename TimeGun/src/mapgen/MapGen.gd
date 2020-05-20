extends Node2D

# Tileset used in the map generated
var tileset = preload("res://assets/tilesets/tileset.tres")
# Size of tiles (must be square tiles)
var tilesize = 64

# amount of tiles for map generated
export var map_height = 64
export var map_width  = 64

# node of current map in use
var current_map = null
# position at which map is generated
var map_pos     = Vector2(-(map_width*tilesize)/2, -(map_height*tilesize)/2)

# used for the map gen, holds numbers from the next enum
var grid = []
# posible tiles for tilemap
enum {
	WALL = 1, # indices for tileset
	FLOOR = 0
}

# holds node of current player
var current_player = null

func _process(delta: float) -> void:
	if $PlayerHolder.get_child_count() > 0:
		current_player = $PlayerHolder.get_child(0)
	else:
		current_player = null

# function used for the map generation
func gen_map() -> void:
	randomize()
	# generation proces
	reset_tilemap()
	# after reseting we can apply as much rules as we want
	apply_rule("reset")
	apply_rule("horizontal")
	apply_rule("smooth")
	apply_rule("smooth")
	apply_rule("smooth")
	apply_rule("smooth")
	apply_rule("swarm_room")
	apply_rule("player_room")
	# once finisehd we generate the tilemap
	gen_tilemap()

# generates random initial grid
func init_grid():
	for _x in range(map_width):
		gen_column()
	
	gen_borders()

# genereates random column
func gen_column():
	var col = []
	for _y in range(map_height):
		var bias = randi()%1000 # bias is the probability of a wall spawning
		if bias <= 450:
			col.append(WALL)
		else:
			col.append(FLOOR)
	grid.append(col)

# generates border walls
func gen_borders():
	for x in range(map_width):
		grid[x][0] = WALL
		grid[x][map_height-1] = WALL
	for y in range(map_height):
		grid[0][y] = WALL
		grid[map_width-1][y] = WALL

# generates tilemap based on grid
func gen_tilemap():
	var map = TileMap.new()
	map.tile_set = tileset
	map.cell_size = Vector2(tilesize, tilesize)
	map.global_position = map_pos
	for x in range(map_width):
		for y in range(map_height):
			map.set_cell(x, y, grid[x][y])
	current_map = map
	$Map.add_child(map)

# destroys current tilemap
func reset_tilemap():
	# clear all objects
	for n in $Objects.get_children():
		n.dead = true
		n.queue_free()
	# clear player
	if $PlayerHolder.get_child_count() > 0:
		$PlayerHolder.get_child(0).visible = false
	# clear tilemap
	if current_map:
		current_map.queue_free()

# returns neighbour values for a given cell in grid
func get_neighbours(x: int, y: int):
	var n = []
	if x > 0:
		n.append(grid[x-1][y])
		if y > 0:
			n.append(grid[x-1][y-1])
		if y < map_height-1:
			n.append(grid[x-1][y+1])
	if x < map_width-1:
		n.append(grid[x+1][y])
		if y > 0:
			n.append(grid[x+1][y-1])
		if y < map_height-1:
			n.append(grid[x+1][y+1])
	if y > 0:
		n.append(grid[x][y-1])
	if y < map_height-1:
		n.append(grid[x][y+1])
	return n

# utility func
func spawn_object_at_tile(x: int, y: int, res: String):
	var Res = load(res)
	var o = Res.instance()
	o.global_position = map_pos + Vector2(x * tilesize, y * tilesize) + Vector2(tilesize/2, tilesize/2)
	$Objects.add_child(o)

func spawn_player_at_tile(x: int, y: int):
	if current_player == null:
		var Res = load("res://src/actors/player/Player.tscn")
		var o = Res.instance()
		o.global_position = map_pos + Vector2(x * tilesize, y * tilesize) + Vector2(tilesize/2, tilesize/2)
		$PlayerHolder.add_child(o)
	else:
		current_player.global_position = map_pos + Vector2(x * tilesize, y * tilesize) + Vector2(tilesize/2, tilesize/2)
		current_player.visible = true

# takes current grid and applies a given rule to it (only one time)
func apply_rule(rule: String):
	call("rule_" + rule)

# @@@ RULE DEFINITIONS @@@
# creates new grid
func rule_reset():
	grid = []
	init_grid()

# S345678/B678 rule
func rule_smooth():
	var copy = grid
	# loop through all cells
	for x in range(map_width):
		for y in range(map_height):
			
			var current = grid[x][y]
			var wall_count  = 0
			var floor_count = 0
			
			# start count of neighbours
			for n in get_neighbours(x, y):
				match n:
					WALL:
						wall_count += 1
					FLOOR:
						floor_count += 1
			
			# apply rule
			if current == WALL && wall_count >= 3: # survival
				copy[x][y] = WALL
			elif current == FLOOR && wall_count >= 6: # born
				copy[x][y] = WALL
			else:
				copy[x][y] = FLOOR
	
	# once done, set new grid
	grid = copy
	# add borders just in case
	gen_borders()

# open horizontal path randomly
func rule_horizontal():
	var path_width = randi()%8

	var y_pos      = randi()%(map_height - path_width)
	
	for y in range(path_width):
		for x in range(map_width):
			grid[x][y_pos + y] = FLOOR
	
	# regen borders
	gen_borders()

# open vertical path randomly
func rule_vertical():
	var path_width = randi()%8

	var x_pos      = randi()%(map_width - path_width)
	
	for x in range(path_width):
		for y in range(map_height):
			grid[x_pos + x][y] = FLOOR
	
	# regen borders
	gen_borders()

# generate open rectangle randomly
func rule_rectangle():
	var size_x = randi()%8
	var size_y = randi()%8

	var pos_x = randi()%(map_width - size_x)
	var pos_y = randi()%(map_height - size_y)

	for x in range(size_x):
		for y in range(size_y):
			grid[pos_x + x][pos_y + y] = FLOOR
	
	# regen borders
	gen_borders()

# creates a room for a drone swarm and spawns it
func rule_swarm_room():
	var size_x = 8 # room size
	var size_y = 8

	var pos_x = randi()%(map_width - size_x)
	var pos_y = randi()%(map_height - size_y)

	for x in range(size_x):
		for y in range(size_y):
			grid[pos_x + x][pos_y + y] = FLOOR
	
	# regen borders
	gen_borders()
	
	# spawn swarm
	spawn_object_at_tile(pos_x + size_x/2, pos_y + size_y/2, "res://src/actors/drones/DroneSwarm.tscn")

# creates a room for the player and spawns him
func rule_player_room():
	var size_x = 8 # room size
	var size_y = 8

	var pos_x = randi()%(map_width - size_x)
	var pos_y = randi()%(map_height - size_y)

	for x in range(size_x):
		for y in range(size_y):
			grid[pos_x + x][pos_y + y] = FLOOR
	
	# regen borders
	gen_borders()
	
	# spawn swarm
	spawn_player_at_tile(pos_x + size_x/2, pos_y + size_y/2)
