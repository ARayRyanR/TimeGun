extends Node2D

export var detection_range = 750.0

var Drone = preload("res://src/actors/drones/Drone.tscn")

onready var pos = global_position

var player

func _ready() -> void:
	# spawn 5 drones
	for i in range(5):
		create_drone()

func _physics_process(delta: float) -> void:
	update_swarm()
	if find_player():
		drones_attack(player.global_position)
	else:
		drones_idle()

# creates drone and adds it to the list
func create_drone():
	# give some randomness to initial drone positions
	var x_offset = 15 * (randi()%20 - 10)
	var y_offset = 15 * (randi()%20 - 10)
	var drone = Drone.instance()
	drone.global_position = pos + Vector2(x_offset, y_offset)
	# add drone
	$Drones.add_child(drone)

# sets all drones to attack state
func drones_attack(target: Vector2):
	for d in $Drones.get_children():
		if d.state != d.DODGE:
			d.state = d.ATTACK
			d.target = target

# sets all drones to idle
func drones_idle():
	for d in $Drones.get_children():
		if d.state != d.DODGE:
			d.state = d.IDLE

# @@@ UTILITY METHODS @@@
func find_player():
	# get player node
	player = get_tree().current_scene.find_node("Player", true, false)
	if player:
		# cast detector ray to player
		$WorldDetector.global_position = pos
		$WorldDetector.cast_to = (player.global_position - pos)
		# check if the world is in between
		if $WorldDetector.is_colliding():
			return false
		else:
			# check if player is within range
			if (player.global_position - pos).length() < detection_range:
				return true
			else:
				return false
	else:
		return false

# updates swarm position based on drones
func update_swarm():
	var new = Vector2.ZERO
	for d in $Drones.get_children():
		new += d.global_position
	new /= $Drones.get_children().size()
	pos = new
