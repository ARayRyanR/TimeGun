extends AnimatedSprite

# @@@ VALUES STORED IN DATA FILE @@@
var shot_speed
var base_damage
var spread
var Bullet

func _init() -> void:
	# fetch values from data file
	shot_speed = Data.gun.shot_speed
	base_damage = Data.gun.base_damage
	spread = Data.gun.spread
	Bullet = Data.gun.bullet

func reload():
	# trigger reload anomation
	play("reloading")

# creates bullet at gun position with given angle
func shoot(shot_angle: float):
	# reset shot animation
	play("shooting")
	frame = 0
	$Flash.frame = 0
	
	# calculate spread
	var angle = shot_angle + spread * (randi()%200 - 100) / 100
	
	# create bullet instance
	var bullet = Bullet.instance()
	bullet.damage = base_damage
	bullet.global_position = $Barrel.global_position
	bullet.linear_velocity = Vector2(shot_speed, 0).rotated(angle)
	bullet.rotation = angle
	get_tree().current_scene.get_node("Bullets").add_child(bullet)
