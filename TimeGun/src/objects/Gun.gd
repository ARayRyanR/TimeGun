extends Sprite

export (PackedScene) var Bullet

# @@@ VALUES STORED IN DATA FILE @@@
var shot_speed
var base_damage
var spread

func _init() -> void:
	# fetch values from data file
	shot_speed = Data.gun.shot_speed
	base_damage = Data.gun.base_damage
	spread = Data.gun.spread

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
