extends Position2D

# @@@ SWARM ATTRIBUTES @@@
export var detection_range = 750.0
export var swarm_speed = 125.0
export var swarm_range = 64.0

# @@@ DRONE OBJECT @@@
var Drone = preload("res://src/actors/drones/Drone.tscn")

# @@@ NODES @@@
var player = null


func _ready() -> void:
	# spawn 5 drones
	for i in range(3):
		create_drone()

func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if $Drones.get_child_count() > 0:
		if find_player():
			velocity = (player.global_position - $SwarmBody.global_position).normalized() * swarm_speed
			drones_attack(player.global_position)
		else:
			velocity = Vector2.ZERO
			drones_idle()
		
		velocity = $SwarmBody.move_and_slide(velocity)
	else:
		queue_free()

# creates drone and adds it to the list
func create_drone():
	# give some randomness to initial drone positions
	var x_offset = 8 * (randi()%16 - 8)
	var y_offset = 8 * (randi()%16 - 8)
	var drone = Drone.instance()
	drone.position += Vector2(x_offset, y_offset)
	# add drone
	$Drones.add_child(drone)

# sets all drones to attack state
func drones_attack(target: Vector2):
	for d in $Drones.get_children():
		if d.state != d.DODGE:
			d.velocity = (player.global_position - $SwarmBody.global_position).normalized() * swarm_speed
			d.state = d.ATTACK
			d.target = target

# sets all drones to idle
func drones_idle():
	for d in $Drones.get_children():
		if d.state != d.DODGE:
			d.velocity = Vector2.ZERO
			d.state = d.IDLE

# @@@ UTILITY METHODS @@@
func find_player():
	# get player node
	player = get_tree().current_scene.current_player
	if player:
		# cast detector ray to player
		$SwarmBody/WorldDetector.cast_to = (player.global_position - $SwarmBody.global_position)
		# check if the world is in between
		if $SwarmBody/WorldDetector.is_colliding():
			return false
		else:
			# check if player is within range
			if (player.global_position - $SwarmBody.global_position).length() < detection_range:
				return true
			else:
				return false
	else:
		return false
