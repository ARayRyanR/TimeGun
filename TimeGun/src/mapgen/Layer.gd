extends Node2D
class_name Layer

# @@@ VARIABLES USED FOR LAYER PROCESSING @@@
# used to check if layer was valid
var layer_valid = true

# used to store player in layer
var layer_player_tile = null

# grid size
var layer_gridx = 32
var layer_gridy = 32
# array used for layer construction
var layer_grid = []

# layer positions (top left corner)
var layer_posx = 0
var layer_posy = 0

# collision mask used for tilemaps created
var layer_collisionmask = 1

# tileset cell size
var layer_cellx = 32
var layer_celly = 32
# dictionary used for variation selection
var layer_tile_variations = []

################################################################################
# @@@ UTILITY METHODS @@@
# returns a list of the values of the neighbours of a cell in the grid (8 neighbours)
func _get_8neighbours(x: int, y: int):
	var values = []
	
	if x > 0:
		values.append(layer_grid[x-1][y])
		if y > 0:
			values.append(layer_grid[x-1][y-1])
		if y < layer_gridy-1:
			values.append(layer_grid[x-1][y+1])
	if x < layer_gridx-1:
		values.append(layer_grid[x+1][y])
		if y > 0:
			values.append(layer_grid[x+1][y-1])
		if y < layer_gridy-1:
			values.append(layer_grid[x+1][y+1])
	if y > 0:
		values.append(layer_grid[x][y-1])
	if y < layer_gridy-1:
		values.append(layer_grid[x][y+1])
	return values

# recursively floods neighbours, by setting their cell to 2
func _flood_neighbours(x: int, y: int):
	# check horizontally
	if x > 0 && layer_grid[x-1][y] == 0:
		# flood cell
		layer_grid[x-1][y] = 2
		# recurse
		_flood_neighbours(x-1, y)
	if x < layer_gridx-1 && layer_grid[x+1][y] == 0:
		# flood cell
		layer_grid[x+1][y] = 2
		# recurse
		_flood_neighbours(x+1, y)
	
	# check vertically
	if y > 0 && layer_grid[x][y-1] == 0:
		# flood cell
		layer_grid[x][y-1] = 2
		# recurse
		_flood_neighbours(x, y-1)
	if y < layer_gridy-1 && layer_grid[x][y+1] == 0:
		# flood cell
		layer_grid[x][y+1] = 2
		# recurse
		_flood_neighbours(x, y+1)

# returns global position based on tile coords (middle of tile)
func _get_tile_position(x: int, y: int) -> Vector2:
	var pos = Vector2.ZERO
	pos.x = layer_posx + (x + 1.0/2.0) * layer_cellx
	pos.y = layer_posy + (y + 1.0/2.0) * layer_celly
	return pos

# returns tile at given global_pos
func _get_tile(position: Vector2) -> Array:
	var x = (position.x - layer_posx) / layer_cellx
	var y = (position.y - layer_posy) / layer_celly
	return [x, y]

################################################################################
# @@@ RULE DEFINITIONS @@@
# @@@ GRID RELATED RULES @@@
# returns a random global position that has a 0 on current grid
func rule_get_empty_position() -> Vector2:
	var x = 0
	var y = 0
	while true:
		x = randi()%layer_gridx
		y = randi()%layer_gridy
		if layer_grid[x][y] == 0:
			break
	
	var pos = _get_tile_position(x, y)
	return pos

# returns a random tile thas has a 0 in current grid
func rule_get_empty_tile():
	var x = 0
	var y = 0
	while true:
		x = randi()%layer_gridx
		y = randi()%layer_gridy
		if layer_grid[x][y] == 0:
			break
	
	return [x, y]

# sets layer map size
func rule_grid_size(x: int, y :int):
	layer_gridx = x
	layer_gridy = y

# sets grid to given array
func rule_set_grid(grid: Array):
	layer_grid = grid

# sets grid to zeros
func rule_zero_grid():
	var new_grid = []
	for x in range(layer_gridx):
		var col = []
		for y in range(layer_gridy):
			col.append(0)
		new_grid.append(col)
	# return generated grid
	layer_grid = new_grid

# sets grid to ones
func rule_ones_grid():
	var new_grid = []
	for x in range(layer_gridx):
		var col = []
		for y in range(layer_gridy):
			col.append(1)
		new_grid.append(col)
	# return generated grid
	layer_grid = new_grid

# adds a border of 1's to current grid
func rule_border_ones():
	for x in range(layer_gridx):
		layer_grid[x][0] = 1
		layer_grid[x][layer_gridy-1] = 1
	for y in range(layer_gridy):
		layer_grid[0][y] = 1
		layer_grid[layer_gridx-1][y] = 1

# uses bias to generate random 1's in grid (more bias = more 1's)
func rule_random_ones(bias: int):
	# loop through grid
	for x in range(layer_gridx):
		for y in range(layer_gridy):
			if randi()%1000 < bias:
				layer_grid[x][y] = 1

# uses B678/S345678 to smooth current grid one step (DOESN'T GENERATE BORDERS)
func rule_smooth():
	var copy = layer_grid

	# loop through all cells
	for x in range(layer_gridx):
		for y in range(layer_gridy):
			var current = layer_grid[x][y]
			var ones_count  = 0
			var zeros_count = 0
			
			# start count of neighbours
			for value in _get_8neighbours(x, y):
				match value:
					1:
						ones_count += 1
					0:
						zeros_count += 1
			
			# apply B678/S345678
			if current == 1 && ones_count >= 3: # survival
				copy[x][y] = 1
			elif current == 0 && ones_count >= 6: # born
				copy[x][y] = 1
			else:
				copy[x][y] = 0
	
	# once done, set new grid
	layer_grid = copy

# fills little corners
func rule_smooth_corners():
	var copy = layer_grid
	
	# loop through all 2 x 2 sections
	for x in range(layer_gridx-1):
		for y in range(layer_gridy-1):
			var t1 = layer_grid[x  ][y]
			var t2 = layer_grid[x+1][y]
			var t3 = layer_grid[x  ][y+1]
			var t4 = layer_grid[x+1][y+1]
			if t1+t2+t3+t4 == 2:
				if t1 == t4:
					copy[x  ][y]   = 1
					copy[x+1][y]   = 1
					copy[x  ][y+1] = 1
					copy[x+1][y+1] = 1
	
	# set new grid
	layer_grid = copy

# fills are disconnected areas with ones
func rule_flood_ones():
	# find random zero cell
	var x = 0
	var y = 0
	while true:
		x = randi()%layer_gridx
		y = randi()%layer_gridy
		if layer_grid[x][y] == 0:
			break
	
	# values of 2 in grid indicate a flooded cell
	layer_grid[x][y] = 2 # flood starting point
	_flood_neighbours(x, y)   # recursively flood empty neighbours
	
	# set final grid
	for x in range(layer_gridx):
		for y in range(layer_gridy):
			if layer_grid[x][y] != 2:
				# fill non-flooded cells
				layer_grid[x][y] = 1
			else:
				# unflood flooded cells
				layer_grid[x][y] = 0


# @@@ POSITION RELATED RULES @@@
# sets layer position attributes
func rule_set_pos(posx: int, posy: int):
	layer_posx = posx
	layer_posy = posy

# centers layer according to current grid size and cell size
func rule_center_layer():
	# map size in pixels
	var map_width  = layer_gridx * layer_cellx
	var map_height = layer_gridy * layer_celly
	
	layer_posx = - map_width  / 2
	layer_posy = - map_height / 2

# @@@ TILESET RELATED RULES @@@
func rule_set_tilesize(sizex: int, sizey: int):
	layer_cellx = sizex
	layer_celly = sizey

func rule_set_variations(variations: Array):
	layer_tile_variations = variations

# @@@ TILEMAP CREATION RULES @@@
# creates a tilemap and adds it to the layer
# adds tiles for each one in layer_grid
func rule_build_tilemap_from_ones(tileset: Resource) -> TileMap:
	# setup tilemap
	var map = TileMap.new()
	map.tile_set = tileset
	map.global_position = Vector2(layer_posx, layer_posy)
	map.cell_size = Vector2(layer_cellx, layer_celly)
	map.collision_mask = layer_collisionmask
	
	
	# draw tiles
	var tile_variations = layer_tile_variations
	for x in range(layer_gridx):
		for y in range(layer_gridy):
			if layer_grid[x][y] == 1:
				
				var tile = 0 # default tile
				# apply random tile variation
				for i in tile_variations:
					if randi()%1000<i[1]:
						tile = i[0]
				# add resulting tile to map
				map.set_cell(x, y, tile)
	
	# add map to layer
	return map

# @@@ MAP CHECKS @@@
# ensures a given amount of area is 0's
func rule_check_area(bias: int):
	var area  = layer_gridx * layer_gridy
	
	# count 0's
	var zeros = 0
	for x in range(layer_gridx):
		for y in range(layer_gridy):
			if layer_grid[x][y] == 0:
				zeros += 1
	
	# make check
	var percentage = 1000 * zeros/area
	if percentage < bias:
		print("failed area check : " + str(percentage) + "/" + str(bias))
		layer_valid = false
	else:
		print("passed area check : " + str(percentage) + "/" + str(bias))