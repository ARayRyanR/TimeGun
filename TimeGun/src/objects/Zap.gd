extends RigidBody2D

export var zap_speed = 100.0
export var _player_damage = 25.0

# when we hit the player
func _on_HitBox_area_entered(area: Area2D) -> void:
	queue_free()
