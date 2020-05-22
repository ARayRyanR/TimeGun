extends Area2D

var heal = 0.0

func _init() -> void:
	heal = Data.pickups.heal

# when player picks up the item
func _on_Pickup_body_entered(body: Node) -> void:
	body.heal(heal)
	queue_free()
