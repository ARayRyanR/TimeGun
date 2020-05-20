extends Rules
class_name RuleSets

# This function applies a ruleset to the calling layer
func apply_ruleset(ruleset: String):
	call("ruleset_" + ruleset)

# @@@ RULE SETS DEFINITIONS @@@
func ruleset_test():
	rule_grid_size(32, 32)
	rule_ones_grid()
	rule_load_tileset("res://assets/tilesets/tileset.tres")
	rule_set_tilesize(64, 64)
	rule_center_layer()
	rule_build_tilemap()
