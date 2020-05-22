extends Node2D

# exit store
func _on_PlayerDetector_body_entered(body: Node) -> void:
	get_tree().change_scene("res://src/Game.tscn")
