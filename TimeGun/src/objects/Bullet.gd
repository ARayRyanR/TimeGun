extends RigidBody2D

var damage

func _ready() -> void:
	# create shot soundfx
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://assets/sfx/shot.wav")
	sfx.playing = true
	get_tree().current_scene.get_node("Sounds").add_child(sfx)

# area detects world bodies and destroys bullet
func _on_WorldDetector_body_entered(body: Node) -> void:
	queue_free()

# triggers when bullet enters an enemy
func _on_BulletArea_area_entered(area: Area2D) -> void:
	queue_free()
