extends Sprite

export (PackedScene) var Bullet

# @@@ BASE GUN ATTRIBUTES @@@
export var shot_speed = 500.0 # bullet speed
export var fire_rate  = 0.5   # seconds between shots
export var base_damage = 10.0

var shot_cooldown = fire_rate

func _process(delta: float) -> void:
	# decrease fire rate cooldown
	if shot_cooldown > 0.0:
		shot_cooldown = clamp(shot_cooldown - delta, 0.0, fire_rate)

# creates bullet at gun position with given angle
func shoot(shot_angle: float):
	# only shoot if cooldown is 0
	if shot_cooldown <= 0.0:
		# reset cooldown
		shot_cooldown = fire_rate
		
		# play sound fx
		$ShotSound.play()
		
		# create bullet instance
		var bullet = Bullet.instance()
		bullet.damage = base_damage
		bullet.global_position = global_position
		bullet.linear_velocity = Vector2(shot_speed, 0).rotated(shot_angle)
		get_tree().current_scene.add_child(bullet)
