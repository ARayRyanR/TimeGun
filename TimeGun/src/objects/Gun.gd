extends Sprite

export (PackedScene) var Bullet

# @@@ BASE GUN ATTRIBUTES @@@
export var shot_speed = 1000.0 # bullet speed
export var base_damage = 10.0
export var spread     = PI / 32

# creates bullet at gun position with given angle
func shoot(shot_angle: float):
	# play sound fx
	$ShotSound.play()
	
	# calculate spread
	var angle = shot_angle + spread * (randi()%200 - 100) / 100
	
	# create bullet instance
	var bullet = Bullet.instance()
	bullet.damage = base_damage
	bullet.global_position = global_position
	bullet.linear_velocity = Vector2(shot_speed, 0).rotated(angle)
	bullet.rotation = angle
	get_tree().current_scene.add_child(bullet)
