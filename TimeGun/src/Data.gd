extends Node

# @@@ DATA @@@
var player = {
	# Main player attributes
	"max_health": 100.0,
	"fire_rate":  7.0,
	"mov_speed":  300.0
}

var drones = {
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
