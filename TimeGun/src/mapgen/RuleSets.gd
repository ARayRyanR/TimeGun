extends Rules
class_name RuleSets

var MAP_WIDTH  = 48
var MAP_HEIGHT = 48

# This function applies a ruleset to the calling layer
func apply_ruleset(ruleset: String):
	call("ruleset_" + ruleset)

# @@@ RULE SETS DEFINITIONS @@@
# creates the main layer (walls, player, enemies)
func ruleset_world():
	# init values
	rule_grid_size(MAP_WIDTH, MAP_HEIGHT) # map size
	rule_set_variations([[1, 10]]) # tile 1 has 1% prob
	rule_set_tilesize(64, 64)
	# create grid
	rule_zero_grid()       # init zero grid
	rule_random_ones(450)     # initial wall gen
	rule_border_ones()
	rule_spawn_player()
	rule_spawn_swarm()
	rule_smooth()
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_smooth()
	rule_border_ones()
	rule_flood_ones()
	rule_smooth_corners()
	rule_check_area(450)
	# build tilemap from grid
	if self.layer_valid:
		# only if layer was valid (save time)
		rule_build_tilemap_from_ones("res://assets/tilesets/wall.tres")

# simply creates the floor
func ruleset_floor():
	# init values
	rule_grid_size(MAP_WIDTH, MAP_HEIGHT) # map size
	rule_set_tilesize(64, 64)
	
	 # create grid
	rule_ones_grid()
	# build tilemap
	rule_build_tilemap_from_ones("res://assets/tilesets/grass.tres")

func ruleset_pipes():
	# init
	rule_grid_size(MAP_WIDTH, MAP_HEIGHT) # map size
	rule_set_tilesize(64, 64)
	
	rule_zero_grid()
	rule_random_ones(5) # chance of pipe prefab spawning
	
	rule_build_objects_from_ones("res://src/objects/pipes/Pipes.tscn")
