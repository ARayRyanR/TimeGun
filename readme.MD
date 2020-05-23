# PLAYER

The player spawns in, he only has one gun and infinite ammo. The player has base attributes
(defined in the Data.gd file) that are loaded to the player when he spawns, there can be
global modifiers (also stored in the Data.gd file) that can be applied to the base values
when the player spawns, this effectively gives the player stats based on current modifiers.
There is the possibility of adding temporary mods to the player, that affect his attributes,
such as damage debuff while in radiaiton zone, etc. these are not yet decided.  

# PROGRESSION

When the player spawns in a map, there will be soome objectives, this can be randomly generated
or chosen by the player before starting the level (yet to decide), as well as a time limit,
then the player will have to complete this objectives under the time limit to progress to the next level.  

Once a level is completed succesfully, the player could be rewarded with money (or possible upgrades),
based on the amount of time left, objectives completet, etc. and he will enter the store,
here he could use his money to buy global upgrades, consumables(yet to be decided), etc.  

Once the player is finished in the store, he can start the next level.

# ENEMIES

## Drone swarm

The drone swarm is a group of drones that move as a group, when the player is in line of sight,
it will follow thep player, and the drones will shoot at the player.  

The drones have a dodge mechanic that currently is triggered randomly.  

Important attributes are loaded from the Data.gd file for easy modification.  This allows
for the possibility of also applying global modifiers to drones.

# MAP GENERATION

The map generation system is performed using the Layer class, this includes all the rules used for manipulating
the layer generation process.  

A layer contains a layer_grid (an array) that can be manipulated via rules, then you can use especial
methods to generate tilemaps or getting positions, etc, using the current layer grid.  

The Game node uses a layer to generate some tilemaps for the world, and then to get empty tiles in the map
to spawn different entities in the world, such as the player or enemies.

# OBJECTIVES

The objective system is managed via the Data singleton, a dictionary contains all posible objectives,
such as "enemies", "pickups", etc. the Game node updates this data to keep objectives updated,
we can then use this data to determine if the level is complete, to give according rewards, etc.

# SOUND EFFECTS

To create quick sound effects, the current approach is to create a new AudioStreamPlayer in the tree root,
and connect its finished signal to queue_free so that it deletes itself.

# TODO

## ASSETS

### Sprites

- ammo/mag sprite
- ui elements (money sprite)
- upgrades sprites
- store sprites
- ground tile variations

### Animations

- walking animation
- death animation
- drone death animation

### Sounds

- shooting sfx
- empty mag sfx
- reload sfx
- drone death sfx

### Music

- background music
- store music
- title screen music

## IMPLEMENTATIONS

### Map generation

- add decoration layers
- add objective generation (maybe)

## DESIGN

### Objectives

- design objectives
- decide on objective rewards

### Upgrades

- create different upgrades
