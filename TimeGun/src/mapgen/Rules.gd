extends Node2D
class_name Rules
 
# @@@ UTILITY METHODS @@@
# returns a list of the values of the neighbours of a cell in the grid (8 neighbours)
func _get_8neighbours(x: int, y: int):
	var values = []
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	
	if x > 0:
		values.append(self.layer_grid[x-1][y])
		if y > 0:
			values.append(self.layer_grid[x-1][y-1])
		if y < gridy-1:
			values.append(self.layer_grid[x-1][y+1])
	if x < gridx-1:
		values.append(self.layer_grid[x+1][y])
		if y > 0:
			values.append(self.layer_grid[x+1][y-1])
		if y < gridy-1:
			values.append(self.layer_grid[x+1][y+1])
	if y > 0:
		values.append(self.layer_grid[x][y-1])
	if y < gridy-1:
		values.append(self.layer_grid[x][y+1])
	return values

# recursively floods neighbours, by setting their cell to 2
func _flood_neighbours(x: int, y: int):
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	
	# check horizontally
	if x > 0 && self.layer_grid[x-1][y] == 0:
		# flood cell
		self.layer_grid[x-1][y] = 2
		# recurse
		_flood_neighbours(x-1, y)
	if x < gridx-1 && self.layer_grid[x+1][y] == 0:
		# flood cell
		self.layer_grid[x+1][y] = 2
		# recurse
		_flood_neighbours(x+1, y)
	
	# check vertically
	if y > 0 && self.layer_grid[x][y-1] == 0:
		# flood cell
		self.layer_grid[x][y-1] = 2
		# recurse
		_flood_neighbours(x, y-1)
	if y < gridy-1 && self.layer_grid[x][y+1] == 0:
		# flood cell
		self.layer_grid[x][y+1] = 2
		# recurse
		_flood_neighbours(x, y+1)

# returns global position based on tile coords (middle of tile)
func _get_tile_position(x: int, y: int):
	var pos = Vector2.ZERO
	pos.x = self.layer_posx + (x + 1/2) * self.layer_cellx
	pos.y = self.layer_posy + (y + 1/2) * self.layer_celly
	return pos

# @@@ RULE DEFINITIONS @@@
# @@@ GRID RELATED RULES @@@
# sets layer map size
func rule_grid_size(x: int, y :int):
	self.layer_gridx = x
	self.layer_gridy = y

# sets grid to zeros
func rule_zero_grid():
	var new_grid = []
	for x in range(self.layer_gridx):
		var col = []
		for y in range(self.layer_gridy):
			col.append(0)
		new_grid.append(col)
	# return generated grid
	self.layer_grid = new_grid

# sets grid to ones
func rule_ones_grid():
	var new_grid = []
	for x in range(self.layer_gridx):
		var col = []
		for y in range(self.layer_gridy):
			col.append(1)
		new_grid.append(col)
	# return generated grid
	self.layer_grid = new_grid

# adds a border of 1's to current grid
func rule_border_ones():
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	for x in range(gridx):
		self.layer_grid[x][0] = 1
		self.layer_grid[x][gridy-1] = 1
	for y in range(gridy):
		self.layer_grid[0][y] = 1
		self.layer_grid[gridx-1][y] = 1

# simply sets the bias aux var
func rule_set_bias(bias: int):
	self.layer_bias = bias

# uses bias to generate random 1's in grid (more bias = more 1's)
func rule_random_ones(bias: int):
	# loop through grid
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	for x in range(gridx):
		for y in range(gridy):
			if randi()%1000 < bias:
				self.layer_grid[x][y] = 1

# uses B678/S345678 to smooth current grid one step (DOESN'T GENERATE BORDERS)
func rule_smooth():
	var copy = self.layer_grid
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	
	# loop through all cells
	for x in range(gridx):
		for y in range(gridy):
			var current = self.layer_grid[x][y]
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
	self.layer_grid = copy

# fills are disconnected areas with ones
func rule_flood_ones():
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	
	# find random zero cell
	var x = 0
	var y = 0
	while true:
		x = randi()%gridx
		y = randi()%gridy
		if self.layer_grid[x][y] == 0:
			break
	
	# values of 2 in grid indicate a flooded cell
	self.layer_grid[x][y] = 2 # flood starting point
	_flood_neighbours(x, y)   # recursively flood empty neighbours
	
	# set final grid
	for x in range(gridx):
		for y in range(gridy):
			if self.layer_grid[x][y] != 2:
				# fill non-flooded cells
				self.layer_grid[x][y] = 1
			else:
				# unflood flooded cells
				self.layer_grid[x][y] = 0

# @@@ POSITION RELATED RULES @@@
# sets layer position attributes
func rule_set_pos(posx: int, posy: int):
	self.layer_posx = posx
	self.layer_posy = posy

# centers layer according to current grid size and cell size
func rule_center_layer():
	var map_width  = self.layer_gridx * self.layer_cellx
	var map_height = self.layer_gridy * self.layer_celly
	
	self.layer_posx = - map_width  / 2
	self.layer_posy = - map_height / 2

# @@@ TILESET RELATED RULES @@@
# sets layer tileset attribute
func rule_load_tileset(tileset: String):
	self.layer_tileset = load(tileset)

func rule_set_tilesize(sizex: int, sizey: int):
	self.layer_cellx = sizex
	self.layer_celly = sizey

func rule_set_variations(variations: Array):
	self.layer_tile_variations = variations

# @@@ TILEMAP CREATION RULES @@@
# creates a tilemap and adds it to the layer
# adds tiles for each one in layer_grid
func rule_build_tilemap_from_ones():
	# setup tilemap
	var map = TileMap.new()
	map.tile_set = self.layer_tileset
	map.global_position = Vector2(self.layer_posx, self.layer_posy)
	map.cell_size = Vector2(self.layer_cellx, self.layer_celly)
	map.collision_mask = self.layer_collisionmask
	
	
	# draw tiles
	var tile_variations = self.layer_tile_variations
	for x in range(self.layer_gridx):
		for y in range(self.layer_gridy):
			if self.layer_grid[x][y] == 1:
				var tile = 0 # default tile
				# apply random tile variation
				for i in tile_variations:
					if randi()%1000<i[1]:
						tile = i[0]
				# add resulting tile to map
				map.set_cell(x, y, tile)
	
	# add map to layer
	self.add_child(map)

# @@@ MAP CHECKS @@@
# ensures a given amount of area is 0's (using bias aux var)
func rule_check_area(bias: int):
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	var area  = gridx * gridy
	
	# count 0's
	var zeros = 0
	for x in range(gridx):
		for y in range(gridy):
			if self.layer_grid[x][y] == 0:
				zeros += 1
	
	# make check
	if 1000 * zeros/area < bias:
		print("failed check")
		self.layer_valid = false
	else:
		print("passed check")

# @@@ OBJECT CREATION RULES @@@
func rule_spawn_player():
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	
	# create random room
	var sizex = 8
	var sizey = 8
	var posx = randi()%(gridx - sizex)
	var posy = randi()%(gridy - sizey)
	
	# empty room
	for x in range(sizex):
		for y in range(sizey):
			self.layer_grid[posx + x][posy + y] = 0
	
	# create player
	var player = load("res://src/actors/player/Player.tscn").instance()
	player.global_position = _get_tile_position(posx + sizex/2, posy + sizey/2)
	self.add_child(player)

# spawns a swarm at random rect
func rule_spawn_swarm():
	var gridx = self.layer_gridx
	var gridy = self.layer_gridy
	
	# create random room
	var sizex = 8
	var sizey = 8
	var posx = randi()%(gridx - sizex)
	var posy = randi()%(gridy - sizey)
	
	# empty room
	for x in range(sizex):
		for y in range(sizey):
			self.layer_grid[posx + x][posy + y] = 0
	
	# create player
	var swarm = load("res://src/actors/drones/DroneSwarm.tscn").instance()
	swarm.global_position = _get_tile_position(posx + sizex/2, posy + sizey/2)
	self.add_child(swarm)
