extends KinematicBody2D

export var mov_speed = 300.0
export var angle_draft = PI/4

func _process(delta: float) -> void:
	# movement
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	var velocity = direction.normalized() * mov_speed
	
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

func shoot():
	var shot_angle = get_angle_to(get_global_mouse_position()) 
	$GunPivot/Gun.shoot(shot_angle)
