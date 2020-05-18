extends KinematicBody2D

export var mov_speed = 300.0
export var shot_vel = 500.0

onready var Bullet = load("res://src/Bullet.tscn")

func _process(delta: float) -> void:
	# movement
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	var velocity = direction.normalized() * mov_speed
	
	velocity = move_and_slide(velocity)

	# gun
	$Gun.rotation = get_angle_to(get_global_mouse_position())

	# shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	var bullet = Bullet.instance()
	bullet.global_position = $Gun/gun_sprite.global_position
	var bullet_angle = get_angle_to(get_global_mouse_position())
	var bullet_vel = Vector2(shot_vel, 0).rotated(bullet_angle)
	bullet.linear_velocity = bullet_vel
	get_tree().current_scene.add_child(bullet)
