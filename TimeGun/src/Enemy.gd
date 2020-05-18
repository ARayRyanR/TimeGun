extends KinematicBody2D

export var dodge_speed = 100.0

var velocity = Vector2.ZERO
onready var target = global_position

func _process(delta: float) -> void:
	# trigger dodge
	if Input.is_action_just_pressed("ui_select"):
		dodge_right()

	# set velocity towards current target
	if (target - global_position).length() > 10.0:
		velocity = (target - global_position).normalized() * dodge_speed
	else:
		velocity = Vector2.ZERO
		
	# move drone
	velocity = move_and_collide(velocity * delta)

func dodge_right():
	# sets animation
	$AnimationPlayer.play("dodge_right")
	# small 'charging' cooldown
	yield(get_tree().create_timer(0.2), "timeout")
	# set target
	target = global_position + Vector2(50.0, 0.0)
	# return to idle animation
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")