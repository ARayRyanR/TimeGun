extends Rules
class_name RuleSets

var MAP_WIDTH  = 48
var MAP_HEIGHT = 48

var grass_tiles = preload("res://assets/tilesets/grass.tres")
var wall_tiles  = preload("res://assets/tilesets/wall.tres")

# This function applies a ruleset to the calling layer
func apply_ruleset(ruleset: String):
	call("ruleset_" + ruleset)

# @@@ RULE SETS DEFINITIONS @@@
# creates the main layer (walls, player, enemies)
func ruleset_world():
	# Create map grid
	rule_grid_size(MAP_WIDTH, MAP_HEIGHT)
	
	# Create floor tilemap
	rule_ones_grid()
	rule_set_tilesize(64, 64)
	rule_build_tilemap_from_ones(grass_tiles)
	
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
	rule_build_tilemap_from_ones(wall_tiles)

	# Spawn one swarm
	rule_spawn_swarm()

	# Spawn the player
	rule_spawn_player()
