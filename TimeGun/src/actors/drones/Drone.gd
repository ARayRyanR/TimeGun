extends KinematicBody2D

# @@@ PROJECTILE SCENE @@@
var Zap = preload("res://src/objects/Zap.tscn")

# @@@ ENEMY ATTRIBUTES @@@
export var dodge_speed = 100.0     # speed at which the drone dodges
export var move_speed  = 50.0      # regular movement speed
export var distancing  = 150.0     # average distance the drone will try to keep
export var distancing_space = 30.0 # distance threshold
export var dodge_chance = 5.0      # out of 1000 per state process (prob. of triggering a dodge)

# @@@ ENEMY PROPERTIES @@@
export var health = 100.0          # initial enemy health
export var fire_rate = 0.33         # zaps / second

# @@@ STATE MACHINE @@@
enum {
	IDLE,
	ATTACK,
	DODGE
}
var state = IDLE    # holds current object state

var dodging = false # used for dodge state
var timer = 0.0      

# ENEMY VARS
var velocity = Vector2.ZERO
onready var target = global_position
var cooldown = 1 / fire_rate

func _init():
	randomize()

func _process(delta: float) -> void:
	# decrease zappin cooldown
	cooldown = clamp(cooldown - delta, 0.0, 1 / fire_rate)
	
	# process state
	match state:
		IDLE:
			idle()
		ATTACK:
			attack()
		DODGE:
			dodge(delta)
	
	# check if enemy is dead
	if health <= 0.0:
		death()
	
	# apply velocity
	velocity = move_and_slide(velocity)

func death():
	queue_free()

# @@@ STATE METODS @@@
func idle():
	# reset velocity
	velocity = Vector2.ZERO

func attack():
	# calculate current distance to target
	var difference = (target - global_position).length()
	# approach if too far away
	if difference > distancing + distancing_space:
		velocity = (target - global_position).normalized() * move_speed
	# get away if too close
	elif difference < distancing - distancing_space:
		velocity = -(target - global_position).normalized() * move_speed
	# dont move if in threshold
	else:
		velocity = Vector2.ZERO
	
	# attemp to shoot
	if cooldown <= 0.0:
		var angle_to_player = get_angle_to(target)
		shoot_zap(angle_to_player)

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
			state = ATTACK
			return

# @@@ UTILITY METHODS @@@
func update_health_bar():
	$HealthBar/GreenBar.scale.x = health / 100.0

func shoot_zap(angle: float):
	# reset cooldown
	cooldown = 1 / fire_rate
	
	# create zap
	var zap = Zap.instance()
	zap.global_position = global_position
	zap.linear_velocity = Vector2(zap.zap_speed, 0).rotated(angle)
	zap.rotation = PI + randi()%6
	get_tree().current_scene.add_child(zap)

# @@@ SIGNAL METHODS @@@
# triggers when a bullet touches enemy body
func _on_BulletDetector_body_entered(body: Node) -> void:
	# take damage
	health -= body.damage
	update_health_bar()
	# delete bullet
	body.queue_free()

# when dodge animation ends, reset idle animation
func _on_BodySprite_animation_finished() -> void:
	$BodySprite.stop()
	$BodySprite.frame = 0
