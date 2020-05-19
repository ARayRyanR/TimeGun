extends Node2D

var tileset = preload("res://assets/tilesets/tileset.tres")

export var map_height = 64
export var map_width  = 64

var current_map = null
var grid = []

enum {
	WALL = 1,
	FLOOR = 0
}

func gen_map() -> void:
	randomize()
	# generation proces
	reset_tilemap()
	apply_rule(0)
	apply_rule(2)
	apply_rule(1)
	apply_rule(1)
	apply_rule(1)
	apply_rule(1)
	gen_tilemap()

# generates random initial grid with borders
func init_grid():
	for _x in range(map_width):
		gen_column()
	
	gen_borders()

# genereates random column
func gen_column():
	var col = []
	for _y in range(map_height):
		var bias = randi()%1000
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
	map.cell_size = Vector2(64, 64)
	map.global_position = Vector2(-(map_width*64)/2, -(map_height*64)/2)
	for x in range(map_width):
		for y in range(map_height):
			map.set_cell(x, y, grid[x][y])
	current_map = map
	add_child(map)

# destroys current tilemap
func reset_tilemap():
	if current_map:
		current_map.queue_free()

# generates random spawn point for player
func get_spawn_point():
	while true:
		var x = randi()%map_width
		var y = randi()%map_height
		if grid[x][y] == FLOOR:
			return current_map.global_position + Vector2(x * current_map.cell_size.x, y * current_map.cell_size.y)

# takes current grid and applies a given rule to it (only one time)
func apply_rule(rule: int):
	call("rule_" + str(rule))

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

# @@@ RULE DEFINITIONS @@@
# creates new grid
func rule_0():
	grid = []
	init_grid()

# S345678/B678 rule
func rule_1():
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
func rule_2():
	var path_width = randi()%8

	var y_pos      = randi()%(map_height - path_width)
	
	for y in range(path_width):
		for x in range(map_width):
			grid[x][y_pos + y] = FLOOR
	
	# regen borders
	gen_borders()

# open vertical path randomly
func rule_3():
	var path_width = randi()%8

	var x_pos      = randi()%(map_width - path_width)
	
	for x in range(path_width):
		for y in range(map_height):
			grid[x_pos + x][y] = FLOOR
	
	# regen borders
	gen_borders()

# generate open rectangle randomly
func rule_4():
	var size_x = randi()%8
	var size_y = randi()%8

	var pos_x = randi()%(map_width - size_x)
	var pos_y = randi()%(map_height - size_y)

	for x in range(size_x):
		for y in range(size_y):
			grid[pos_x + x][pos_y + y] = FLOOR
	
	# regen borders
	gen_borders()