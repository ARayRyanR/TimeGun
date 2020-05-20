extends Node2D
class_name Rules





# @@@ RULE DEFINITIONS @@@
# sets layer map size
func rule_grid_size(x: int, y :int):
	self.layer_mapx = x
	self.layer_mapy = y

# sets grid to zeros
func rule_zero_grid():
	var new_grid = []
	for x in range(self.layer_mapx):
		var col = []
		for y in range(self.layer_mapy):
			col.append(0)
		new_grid.append(col)
	# return generated grid
	self.layer_grid = new_grid

# sets grid to ones
func rule_ones_grid():
	var new_grid = []
	for x in range(self.layer_mapx):
		var col = []
		for y in range(self.layer_mapy):
			col.append(1)
		new_grid.append(col)
	# return generated grid
	self.layer_grid = new_grid

# sets layer position attributes
func rule_set_pos(posx: int, posy: int):
	self.layer_posx = posx
	self.layer_posy = posy

# centers layer according to current grid size and cell size
func rule_center_layer():
	var x = self.layer_grid.size()    * self.layer_cellx
	var y = self.layer_grid[0].size() * self.layer_celly
	
	self.layer_posx = - x / 2
	self.layer_posy = - y / 2

# sets layer tileset attribute
func rule_load_tileset(tileset: String):
	self.layer_tileset = load(tileset)

func rule_set_tilesize(sizex: int, sizey: int):
	self.layer_cellx = sizex
	self.layer_celly = sizey

# builds layer using grid data and tileset set in layer
func rule_build_tilemap():
	# setup tilemap
	var map = TileMap.new()
	map.tile_set = self.layer_tileset
	map.global_position = Vector2(self.layer_posx, self.layer_posy)
	map.cell_size = Vector2(self.layer_cellx, self.layer_celly)
	
	# draw tiles
	for x in range(self.layer_mapx):
		for y in range(self.layer_mapy):
			map.set_cell(x, y, self.layer_grid[x][y])
	
	# add map to layer
	self.add_child(map)
