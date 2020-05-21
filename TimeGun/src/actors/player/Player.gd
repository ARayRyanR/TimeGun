extends KinematicBody2D

# @@@ VALUES LOADED FROM DATA FILE @@@
var max_health
var fire_rate
var mov_speed

# @@@ PLAYER ATTRIBUTES @@@
var current_health
var shoot_cooldown

# @@@ MOVEMENT VARS @@@
var velocity = Vector2.ZERO
# used for sprite animation
var angle_draft = PI/4

func _init() -> void:
	# Load values data object into object
	max_health = Data.player.max_health
	fire_rate  = Data.player.fire_rate
	mov_speed  = Data.player.mov_speed

	# init player values
	current_health = max_health
	shoot_cooldown = 1.0 / fire_rate

func _input(event: InputEvent) -> void:
	if event.is_action_released("zoom_out"):
		$Camera2D.zoom += Vector2(0.5, 0.5)
	if event.is_action_released("zoom_in"):
		$Camera2D.zoom -= Vector2(0.5, 0.5)

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
		shoot()

	# Sprite rotation
	var current_angle = get_angle_to(get_global_mouse_position())
	$GunPivot.rotation = current_angle
	$HeadSprite.rotation = current_angle
	var min_angle = current_angle - angle_draft
	var max_angle = current_angle + angle_draft
	if ($Body.rotation - max_angle) > 0 || (min_angle - $Body.rotation) > 0:
		$Body.rotation = current_angle

func movement():
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	velocity = direction.normalized() * mov_speed

func shoot():
	if shoot_cooldown <= 0.0:
		shoot_cooldown = (1.0/fire_rate)
		var shot_angle = get_angle_to(get_global_mouse_position()) 
		$GunPivot/Gun.shoot(shot_angle)

func death():
	# notify game that player is dead
	get_tree().current_scene.player = null
	queue_free()

func update_health_bar():
	$HealthBar/GreenBar.scale.x = current_health / max_health

# triggers when something hurts the player
func _on_HurtBox_area_entered(area: Area2D) -> void:
	print("player damaged")
	current_health -= area.get_parent()._player_damage
	update_health_bar()
