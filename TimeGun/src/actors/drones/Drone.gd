extends KinematicBody2D

# @@@ VALUES LOADED FROM DATA FILE @@@
var move_speed
var dodge_speed
var dodge_chance
var fire_rate
var shoot_bias
var max_health
var Zap

# @@@ NODES @@@
onready var swarm = get_parent().get_parent()

# @@@ ENEMY PROPERTIES @@@
var velocity = Vector2.ZERO
var target
var cooldown
var health
enum {
	NORMAL,
	TOUCHED,
	DAMAGED
}
var condition = NORMAL

# @@@ STATE MACHINE @@@
enum {
	IDLE,
	ATTACK,
	DODGE
}
var state = IDLE    # holds current object state

var dodging = false # used for dodge state
var timer = 0.0      

func _init():
	randomize()
	
	# fetch values from Data
	move_speed = Data.drones.move_speed
	dodge_speed = Data.drones.dodge_speed
	dodge_chance = Data.drones.dodge_chance
	fire_rate = Data.drones.fire_rate
	shoot_bias = Data.drones.shoot_bias
	max_health = Data.drones.max_health
	Zap = Data.drones.projectile
	
	# init values
	health = max_health
	cooldown = 1.0 / fire_rate

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
		zap_barrage(angle_to_player)

	# trigger a dodge randomly based in prob
	if randi()%1000+1 <= dodge_chance && dodging == false:
		state = DODGE

func dodge(delta: float):
	if !dodging:
		# if not dodging, start dodge
		timer = 1.5
		dodging = true
		# start appropiate animation
		match condition:
			NORMAL:
				$BodySprite.play("dodge") # dodge animation
			TOUCHED:
				$BodySprite.play("dodge_touched")
			DAMAGED	:
				$BodySprite.play("dodge_damaged")
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

func zap_barrage(angle: float):
	if randi()%1000 < shoot_bias:
		cooldown = 1.0 / fire_rate
		
		shoot_zap(angle)
		yield(get_tree().create_timer(0.2), "timeout")
		shoot_zap(angle)
		yield(get_tree().create_timer(0.2), "timeout")
		shoot_zap(angle)

func shoot_zap(angle: float):
	# create zap
	var zap = Zap.instance()
	zap.global_position = global_position
	zap.linear_velocity = Vector2(zap.zap_speed, 0).rotated(angle)
	zap.rotation = PI + randi()%6
	get_tree().current_scene.add_child(zap)

func update_condition():
	if health < max_health:
		condition = TOUCHED
	if health < max_health * 0.4:
		condition = DAMAGED
	
	if state != DODGE:
		match condition:
			NORMAL:
				$BodySprite.play("idle")
			TOUCHED:
				$BodySprite.play("idle_touched")
			DAMAGED	:
				$BodySprite.play("idle_damaged")
	if state == DODGE:
		match condition:
			NORMAL:
				$BodySprite.play("dodge")
			TOUCHED:
				$BodySprite.play("dodge_touched")
			DAMAGED	:
				$BodySprite.play("dodge_damaged")

# @@@ SIGNAL METHODS @@@
# triggers when a bullet touches enemy body
func _on_BulletDetector_area_entered(area: Area2D) -> void:
	# take damage
	health -= area.get_parent().damage
	update_health_bar()
	update_condition()

# when dodge animation ends, reset idle animation
func _on_BodySprite_animation_finished() -> void:
	$BodySprite.frame = 0
	# start appropiate animation
	match condition:
		NORMAL:
			$BodySprite.play("idle")
		TOUCHED:
			$BodySprite.play("idle_touched")
		DAMAGED	:
			$BodySprite.play("idle_damaged")

func _on_WorldDetector_body_entered(body: Node) -> void:
	death()
