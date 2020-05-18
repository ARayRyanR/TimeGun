extends Sprite

export (PackedScene) var Bullet
export var shot_speed = 500.0

# creates bullet at gun position with given angle
func shoot(shot_angle: float):
	var bullet = Bullet.instance()
	bullet.global_position = global_position
	bullet.linear_velocity = Vector2(shot_speed, 0).rotated(shot_angle)
	get_tree().current_scene.add_child(bullet)
