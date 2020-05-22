extends Area2D


# when player picks up the item
func _on_Pickup_body_entered(body: Node) -> void:
	body.heal(50)
	queue_free()
