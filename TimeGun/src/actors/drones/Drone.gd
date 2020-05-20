extends KinematicBody2D

# @@@ PROJECTILE SCENE @@@
var Zap = preload("res://src/objects/Zap.tscn")

# @@@ NODES @@@
onready var swarm = get_parent().get_parent()

# @@@ ENEMY ATTRIBUTES @@@
export var dodge_speed = 100.0     # speed at which the drone dodges
export var move_speed  = 200.0      # regular movement speed
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
var target
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
	return_to_swarm()

func attack():
	return_to_swarm()
	
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
func return_to_swarm():
	if (swarm.get_node("SwarmBody").global_position - global_position).length() > swarm.swarm_range:
		# return to swarm
		velocity += (swarm.get_node("SwarmBody").global_position - global_position).normalized() * move_speed
	else:
		# todo: add random movement
		velocity += Vector2.ZERO

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
func _on_BulletDetector_area_entered(area: Area2D) -> void:
	# take damage
	health -= area.get_parent().damage
	update_health_bar()

# when dodge animation ends, reset idle animation
func _on_BodySprite_animation_finished() -> void:
	$BodySprite.stop()
	$BodySprite.frame = 0

func _on_WorldDetector_body_entered(body: Node) -> void:
	queue_free()
