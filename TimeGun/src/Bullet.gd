extends RigidBody2D

var damage

# area detects world bodies and destroys bullet
func _on_WorldDetector_body_entered(body: Node) -> void:
	queue_free()
