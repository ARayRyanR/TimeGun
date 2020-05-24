extends KinematicBody2D

# @@@ VALUES LOADED FROM DATA FILE @@@
var max_health
var mov_speed

# @@@ PLAYER ATTRIBUTES @@@
var current_health

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
	mov_speed  = Data.player.mov_speed

	# init player values
	current_health = max_health

func _input(event: InputEvent) -> void:
	# zoom controls
	if event.is_action_released("zoom_out"):
		$Camera2D.zoom += Vector2(0.5, 0.5)
	if event.is_action_released("zoom_in"):
		if $Camera2D.zoom.x > 0.5:
			$Camera2D.zoom -= Vector2(0.5, 0.5)
	
	# attempt to reload gun
	if event.is_action_pressed("reload"):
		if state == FREE:
			reload()
	
	# Sprite rotation
	var current_angle = get_angle_to(get_global_mouse_position())
	$GunPivot.rotation = current_angle
	$Body.rotation = current_angle
	
	# for debugging
	if event.is_action_pressed("ui_cancel"):
		current_health -= 20.0

func _process(delta: float) -> void:
	# death check
	if current_health <= 0.0:
		death()
	
	# movement
	movement()
	
	velocity = move_and_slide(velocity)
	
	# attempt to shoot gun
	if Input.is_action_pressed("shoot"):
		if state == FREE:
			shoot()
	
	# update hud
	update_HUD_objectives()

func movement():
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	velocity = direction.normalized() * mov_speed

func heal(amount: float):
	current_health = clamp(current_health + amount, 0.0, max_health)
	update_health_bar()

func death():
	# notify game that player is dead
	get_tree().current_scene.player = null
	queue_free()

func update_health_bar():
	$HealthBar/GreenBar.scale.x = current_health / max_health

func update_HUD_objectives():
	$HUD/List/Enemies.text = "Enemies : " + str(Data.objectives.enemies)
	$HUD/List/Clocks.text = "Clocks : " + str(Data.objectives.clocks)

# triggers when something hurts the player
func _on_HurtBox_area_entered(area: Area2D) -> void:
	print("player damaged")
	current_health -= area.get_parent()._player_damage
	update_health_bar()

# @@@ GUN METHODS @@@
func reload():
	# attempt to reload gun
	$GunPivot/Gun.reload()

func shoot():
	# attempt to shoot in player direction
	var shot_angle = get_angle_to(get_global_mouse_position())
	$GunPivot/Gun.shoot(shot_angle)

func _on_Gun_reload_finished() -> void:
	$Body/Arms.play("idle")

func _on_Gun_reload_started() -> void:
	$Body/Arms.play("reloading")

func _on_Gun_shot_fired() -> void:
	$Body/Arms.play("shooting")
	$Body/Arms.frame = 0

func _on_Gun_mag_changed(amount: int) -> void:
	# update player hud
	$HUD/List/Mag.text = "mag : " + str(amount)
