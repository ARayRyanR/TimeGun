extends Node

# @@@ DATA @@@
var objectives = {
	"enemies": 0,
	"clocks": 0
}

var pickups = {
	"heal": 50.0
}

var player = {
	# Main player attributes
	"max_health": 100.0,
	"mov_speed":  300.0,
}

var gun = {
	# Main gun attributes
	"shot_speed":  1000.0,
	"base_damage": 10.0,
	"fire_rate":   8.0,
	"mag_size":    30,
	"spread":      PI/32,
	
	# projectile shot
	"bullet": preload("res://src/objects/Bullet.tscn")
}

var drones = {
	# Main swarm attributes
	"detection_range": 750.0,
	"swarm_speed": 150.0,
	"swarm_range": 64.0,
	# Drones for the swarm
	"drone": preload("res://src/actors/drones/Drone.tscn"),
	
	# Main drone attributes
	"move_speed": 200.0,
	"dodge_speed": 150.0,
	"dodge_chance": 5.0,
	"fire_rate": 0.3,
	"shoot_bias": 400,
	"max_health": 100.0,
	
	# Projectile that the drone shoots
	"projectile": preload("res://src/objects/Zap.tscn")
}
