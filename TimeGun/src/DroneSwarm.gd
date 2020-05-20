extends Node2D

var drones = []
var Drone = preload("res://src/Enemy.tscn")

func create_drone():
	var drone = Drone.instance()
	drone.global_position = global_position
	drones.append(drone)
	add_child(drone)
