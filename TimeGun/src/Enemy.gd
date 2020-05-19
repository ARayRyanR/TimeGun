extends KinematicBody2D

# @@@ ENEMY ATTRIBUTES @@@
export var dodge_speed = 100.0     # speed at which the drone dodges
export var move_speed  = 50.0      # regular movement speed
export var distancing  = 150.0     # average distance the drone will try to keep
export var distancing_space = 30.0 # distance threshold
export var dodge_chance = 5.0      # out of 1000 per state process (prob. of triggering a dodge)

# @@@ STATE MACHINE @@@
enum {
	IDLE,
	ATTACK,
	DODGE
}
var state = IDLE    # holds current object state

var dodging = false # used for dodge state
var timer = 0.0      

# NODES USED
onready var playerNode = get_tree().current_scene.find_node("Player", false, true)

# ENEMY VARS
var velocity = Vector2.ZERO
onready var target = global_position

func _init():
	randomize()

func _physics_process(delta: float) -> void:
	# process state
	match state:
		IDLE:
			idle()
		ATTACK:
			attack()
		DODGE:
			dodge(delta)

func _process(delta: float) -> void:
	# apply velocity
	velocity = move_and_slide(velocity)

# @@@ STATE METODS @@@
func idle():
	# reset velocity
	velocity = Vector2.ZERO
	# look for player to trigger attack state
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, playerNode.global_position, [self])
	if result:
		if result.collider == playerNode:
			state = ATTACK

func attack():
	# go back to idle state
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, playerNode.global_position, [self])
	if result:
		if result.collider != playerNode:
			state = IDLE
			return
	
	# calculate current distance to player
	var difference = playerNode.global_position - global_position
	# approach if too far away
	if difference.length() > distancing + distancing_space:
		velocity = (playerNode.global_position - global_position).normalized() * move_speed
	# get away if too close
	elif difference.length() < distancing - distancing_space:
		velocity = -(playerNode.global_position - global_position).normalized() * move_speed
	# dont move if in threshold
	else:
		velocity = Vector2.ZERO

	# trigger a dodge randomly based in prob
	if randi()%1000+1 <= dodge_chance && dodging == false:
		state = DODGE

func dodge(delta: float):
	if !dodging:
		# if not dodging, start dodge
		timer = 1.5
		dodging = true
		$BodySprite.play() # dodge animation
		# decide random direction
		if randi()%2 == 0:
			# dodge right
			$BodySprite.scale.x = 1
			yield(get_tree().create_timer(0.5), "timeout")
			velocity = Vector2(dodge_speed, 0)
		else:
			# dodge left
			$BodySprite.scale.x = -1
			yield(get_tree().create_timer(0.5), "timeout")
			velocity = Vector2(-dodge_speed, 0)
	
	else:
		# continue dodge
		timer = timer - delta
		# end dodge if timer runs out
		if timer <= 0:
			dodging = false
			state = IDLE
			return


# triggers when a bullet touches enemy body
func _on_BulletDetector_body_entered(body: Node) -> void:
	# delete both
	body.queue_free()
	queue_free()

# when dodge animation ends, reset idle animation
func _on_BodySprite_animation_finished() -> void:
	$BodySprite.stop()
	$BodySprite.frame = 0
