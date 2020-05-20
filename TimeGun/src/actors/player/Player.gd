extends KinematicBody2D

# @@@ PLAYER ATTRIBUTES @@@
export var health = 100.0 # initial health

# @@@ MOVEMENT VARS @@@
var velocity = Vector2.ZERO
export var mov_speed = 300.0
export var angle_draft = PI/4

func _input(event: InputEvent) -> void:
	if event.is_action_released("zoom_out"):
		$Camera2D.zoom *= 2
	if event.is_action_released("zoom_in"):
		$Camera2D.zoom /= 2

func _ready() -> void:
	# set this player as current player
	get_tree().current_scene.current_player = self

func _process(delta: float) -> void:
	# death check
	if health <= 0.0:
		death()
	
	# movement
	movement()
	
	velocity = move_and_slide(velocity)

	# Sprite rotation
	var current_angle = get_angle_to(get_global_mouse_position())
	$GunPivot.rotation = current_angle
	$HeadSprite.rotation = current_angle
	var min_angle = current_angle - angle_draft
	var max_angle = current_angle + angle_draft
	if ($Body.rotation - max_angle) > 0 || (min_angle - $Body.rotation) > 0:
		$Body.rotation = current_angle

	# shooting (pressed makes it automatic)
	if Input.is_action_pressed("shoot"):
		shoot()

func movement():
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	velocity = direction.normalized() * mov_speed

func shoot():
	var shot_angle = get_angle_to(get_global_mouse_position()) 
	$GunPivot/Gun.shoot(shot_angle)

func death():
	get_tree().current_scene.current_player = null
	queue_free()

func update_health_bar():
	$HealthBar/GreenBar.scale.x = health / 100.0

# triggers when something hurts the player
func _on_HurtBox_area_entered(area: Area2D) -> void:
	print("player damaged")
	health -= area.get_parent()._player_damage
	update_health_bar()
