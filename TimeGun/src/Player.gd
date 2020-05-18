extends KinematicBody2D

export var mov_speed = 300.0

func _process(delta: float) -> void:
	# movement
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	var velocity = direction.normalized() * mov_speed
	
	velocity = move_and_slide(velocity)

	# gun rotation
	$GunPivot.rotation = get_angle_to(get_global_mouse_position())

	# shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	var shot_angle = get_angle_to(get_global_mouse_position()) 
	$GunPivot/Gun.shoot(shot_angle)
