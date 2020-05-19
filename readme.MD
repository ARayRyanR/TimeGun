# CODE DOCUMENTATION

# Player

The player has a gun_pivot node to rotate the gun around, any child node of this pivot will rotate towards the mouse.

## Health

The current health value of the player, if this gets below 0 it triggers the death() method
TODO: Add animation / sounds on death

## Damage

To damage the player, an object should have a child node in the layer hurt_player, and have a variable called _player_damage, this is the damage the player will take

# Drones

The basic drone enemy, has 3 possible states IDLE, ATTACK, and DODGE:

## IDLE

While the drone is in idle, it will do absolutely nothing.
TODO: maybe add some random small movement

## ATTACK

While in attack mode, the drone will move towards its current target (target member), and shoot towards it whenrver his cooldown gets to 0.
It will try to stay within a region from the target given by ditancing and distancing_space members
There is a chance the drone will change to DODGE mode given by the dodge_chance member

## DODGE

When the dodge mode is triggered, the drone will start a dodge in a random direction, and when the timer is over it will return to ATTACK mode.

