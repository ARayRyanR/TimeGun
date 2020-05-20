extends RigidBody2D

var damage

# area detects world bodies and destroys bullet
func _on_WorldDetector_body_entered(body: Node) -> void:
	queue_free()

# triggers when bullet enters an enemy
func _on_BulletArea_area_entered(area: Area2D) -> void:
	queue_free()
