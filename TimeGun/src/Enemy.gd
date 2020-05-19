extends KinematicBody2D

# @@@ ENEMY ATTRIBUTES @@@
export var dodge_speed = 100.0
export var move_speed  = 50.0
export var distancing  = 150.0
export var distancing_space = 30.0
export var dodge_chance = 5.0 # 1 / 1000 per state process

# @@@ STATE MACHINE @@@
enum {
	IDLE,
	ATTACK,
	DODGE
}
var state = IDLE
var dodging = false

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
	
	var difference = playerNode.global_position - global_position
	# approach if too far away
	if difference.length() > distancing + distancing_space:
		velocity = (playerNode.global_position - global_position).normalized() * move_speed
	# get away if too close
	elif difference.length() < distancing - distancing_space:
		velocity = -(playerNode.global_position - global_position).normalized() * move_speed
	# dont move
	else:
		velocity = Vector2.ZERO

	# trigger a dodge randomly
	if randi()%1000+1 <= dodge_chance && dodging == false:
		state = DODGE

func dodge(delta: float):
	if !dodging:
		# if not dodging, start dodge
		timer = 1.5
		dodging = true
		$BodySprite.play()
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
