extends RigidBody2D

export var zap_speed = 250.0
export var _player_damage = 25.0

func _ready() -> void:
	# create zap sfx
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/sfx/Laser_Shoot2.wav")
	sfx.playing = true
	sfx.volume_db = -15
	sfx.connect("finished", sfx, "queue_free")
	get_tree().current_scene.get_node("Sounds").add_child(sfx)

func death():
	$zap.play("death")
	yield($zap, "animation_finished")
	queue_free()

# when we hit the player
func _on_HitBox_area_entered(area: Area2D) -> void:
	death()

func _on_WorldDetector_body_entered(body: Node) -> void:
	death()
