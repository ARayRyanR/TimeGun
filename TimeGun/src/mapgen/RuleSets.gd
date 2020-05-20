extends Rules
class_name RuleSets


# This function applies a ruleset to the calling layer
func apply_ruleset(ruleset: String):
	call("ruleset_" + ruleset)

# @@@ RULE SETS DEFINITIONS @@@
# creates the main layer (walls, player, enemies)
func ruleset_world():
	# init values
	rule_grid_size(48, 48) # map size
	rule_load_tileset("res://assets/tilesets/wall.tres")
	rule_set_variations([[1, 50]]) # tile 1 has 50% prob
	rule_set_tilesize(64, 64)
	rule_center_layer()
	# create grid
	rule_zero_grid()       # init zero grid
	rule_random_ones(450)     # initial wall gen
	rule_border_ones()
	rule_spawn_player()
	rule_spawn_swarm()
	rule_smooth()
	rule_smooth()
	rule_smooth()
	rule_border_ones()
	rule_flood_ones()
	rule_check_area(450)
	# build tilemap from grid
	if self.layer_valid:
		# only if layer was valid (save time)
		rule_build_tilemap_from_ones()

# simply creates the floor
func ruleset_floor():
	# init values
	rule_grid_size(48, 48) # map size
	rule_load_tileset("res://assets/tilesets/grass.tres")
	rule_set_tilesize(64, 64)
	rule_center_layer()
	 # create grid
	rule_ones_grid()
	# build tilemap
	rule_build_tilemap_from_ones()

# creates the "web" overlay
func ruleset_webs():
	# init values
	rule_grid_size(48*4, 48*4)
	rule_load_tileset("res://assets/tilesets/pipe_straight.tres")
	rule_set_tilesize(16, 16)
	rule_center_layer()
	# grid
	rule_ones_grid()
	# build
	rule_build_tilemap_from_ones()
