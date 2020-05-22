extends Area2D

# when player picks it up
func _on_Clock_body_entered(body: Node) -> void:
	# trigger objective
	Data.objectives.clocks -= 1
	queue_free()
