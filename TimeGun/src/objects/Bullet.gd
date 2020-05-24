extends RigidBody2D

export (AudioStream)var shot_sfx
export var volume_fix = -20.0
var damage

func _ready() -> void:
	# create shot soundfx
	var sfx = AudioStreamPlayer.new()
	sfx.stream = shot_sfx
	sfx.volume_db = volume_fix
	sfx.playing = true
	sfx.connect("finished", sfx, "queue_free")
	get_tree().current_scene.get_node("Sounds").add_child(sfx)

# area detects world bodies and destroys bullet
func _on_WorldDetector_body_entered(body: Node) -> void:
	queue_free()

# triggers when bullet enters an enemy
func _on_BulletArea_area_entered(area: Area2D) -> void:
	queue_free()
