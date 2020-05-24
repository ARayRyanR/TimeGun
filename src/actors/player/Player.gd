extends KinematicBody2D

# @@@ VALUES LOADED FROM DATA FILE @@@
var max_health
var fire_rate
var mov_speed
var mag_size

# @@@ PLAYER ATTRIBUTES @@@
var current_health
var shoot_cooldown
var current_mag

# @@@ MOVEMENT VARS @@@
var velocity = Vector2.ZERO

# @@@ PLAYER STATES @@@
enum {
	FREE,
	RELOADING
}
var state = FREE

func _init() -> void:
	# Load values data object into object
	max_health = Data.player.max_health
	fire_rate  = Data.player.fire_rate
	mov_speed  = Data.player.mov_speed
	mag_size   = Data.player.mag_size

	# init player values
	current_health = max_health
	shoot_cooldown = 1.0 / fire_rate
	current_mag = mag_size

func _ready() -> void:
	# update hud
	update_HUD_mag()

func _input(event: InputEvent) -> void:
	# zoom controls
	if event.is_action_released("zoom_out"):
		$Camera2D.zoom += Vector2(0.5, 0.5)
	if event.is_action_released("zoom_in"):
		if $Camera2D.zoom.x > 0.5:
			$Camera2D.zoom -= Vector2(0.5, 0.5)
	
	# reloading
	if event.is_action_pressed("reload"):
		if state == FREE:
			reload()
	
	# for debugging
	if event.is_action_pressed("ui_cancel"):
		current_health -= 20.0

func _process(delta: float) -> void:
	# death check
	if current_health <= 0.0:
		death()
	
	# decrease cooldown
	shoot_cooldown -= delta
	
	# movement
	movement()
	
	velocity = move_and_slide(velocity)
	
	# shooting (pressed makes it automatic)
	if Input.is_action_pressed("shoot"):
		if state == FREE:
			shoot()

	# Sprite rotation
	var current_angle = get_angle_to(get_global_mouse_position())
	$GunPivot.rotation = current_angle
	$Body.rotation = current_angle

	# update hud
	update_HUD_objectives()

func movement():
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	velocity = direction.normalized() * mov_speed

func reload():
	state = RELOADING
	
	# reload logic
	# play reload sfx
	$ReloadSFX.play()
	# play reload animation
	# wait for animation to finish
	yield(get_tree().create_timer(1.0), "timeout")
	
	# reset mag
	current_mag = mag_size
	# update hud
	update_HUD_mag()
	
	state = FREE

func heal(amount: float):
	current_health = clamp(current_health + amount, 0.0, max_health)
	update_health_bar()

func shoot():
	if shoot_cooldown <= 0.0 && current_mag > 0:
		# arms animation
		$Body/Arms.frame = 0
		
		# reset cooldown
		shoot_cooldown = (1.0/fire_rate)
		# decrease magazine
		current_mag -= 1
		# update hud
		update_HUD_mag()
		
		var shot_angle = get_angle_to(get_global_mouse_position()) 
		$GunPivot/Gun.shoot(shot_angle)
	
	if shoot_cooldown <= 0.0 && current_mag <= 0:
		shoot_cooldown = 0.2
		# play empty mag sfx
		$EmptySFX.play()

func death():
	# notify game that player is dead
	get_tree().current_scene.player = null
	queue_free()

func update_health_bar():
	$HealthBar/GreenBar.scale.x = current_health / max_health

func update_HUD_mag():
	$HUD/List/Magazine.text = str(current_mag) + " / " + str(mag_size)

func update_HUD_objectives():
	$HUD/List/Enemies.text = "Enemies : " + str(Data.objectives.enemies)
	$HUD/List/Clocks.text = "Clocks : " + str(Data.objectives.clocks)

# triggers when something hurts the player
func _on_HurtBox_area_entered(area: Area2D) -> void:
	print("player damaged")
	current_health -= area.get_parent()._player_damage
	update_health_bar()
