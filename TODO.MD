# map gen system

Main node is called game, extends mapgen class. It has Node2D's to contain tilemaps objects etc, then we generate the map, which creates the tile maps, and we
can add them to the node that we want, we also store the walls grid to now how the map is arranged, then we can create a player, using the wall grid we saved,
and add him to the player node, same process to generate enemies.

When we create the player we can set the game current_player to be the player, this
way other entities have access to the current player, when theres not a player,
it should be null

The tilemap creation rule should only build the tilemap and return the node, not add it.

# data saving / loading

There should be a Data script autoloaded, that attempts to load data from the file
on its init, this would store all the data in the dictionaries the Data script will define
like player.score payer.name, etc

Now, when a player is created, it'll look in the data members to find his initial values.
