extends RuleSets

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
