extends RigidBody2D

export var zap_speed = 250.0
export var _player_damage = 25.0

func _ready() -> void:
	$ZapSFX.play()

func death():
	$zap.play("death")
	yield($zap, "animation_finished")
	queue_free()

# when we hit the player
func _on_HitBox_area_entered(area: Area2D) -> void:
	death()

func _on_WorldDetector_body_entered(body: Node) -> void:
	death()
