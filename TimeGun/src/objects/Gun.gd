extends AnimatedSprite

# @@@ PLAYER COMMUNICATION SIGNALS @@@
signal shot_fired
signal reload_started
signal reload_finished
signal mag_changed

# @@@ VALUES STORED IN DATA FILE @@@
var shot_speed
var base_damage
var spread
var mag_size
var fire_rate
var Bullet

# @@@ ATTRIBUTES @@@
var current_mag
var cooldown

# @@@ STATES @@@
enum {
	FREE,
	RELOADING
}
var state = FREE

func _init() -> void:
	# fetch values from data file
	shot_speed = Data.gun.shot_speed
	base_damage = Data.gun.base_damage
	spread = Data.gun.spread
	mag_size = Data.gun.mag_size
	fire_rate = Data.gun.fire_rate
	Bullet = Data.gun.bullet
	
	cooldown = 1.0 / fire_rate
	current_mag = mag_size

func _ready() -> void:
	emit_signal("mag_changed", current_mag)

func _process(delta: float) -> void:
	# decreases gun cooldown
	cooldown = clamp(cooldown - delta, 0.0, 1.0 / fire_rate)

func reload():
	# check if reload is valid
	if state == FREE:
		if current_mag < mag_size:
			state = RELOADING
			
			# send reload signal to player
			emit_signal("reload_started")
			
			# --- reload logic for gun ---
			# sfx
			$ReloadSFX.play()
			# animation
			play("reloading")
			frame = 0
			# wait for animation
			yield(self, "animation_finished")
			# set ammo
			current_mag = mag_size
			
			# send signal to player
			emit_signal("reload_finished")
			# notify player of new bullets
			emit_signal("mag_changed", current_mag) # update player mag value
			
			state = FREE

# creates bullet at gun position with given angle
func shoot(shot_angle: float):
	# ccheck if shot is valid
	if current_mag > 0 && cooldown <= 0.0 && state == FREE:
		# notify player of shot
		emit_signal("shot_fired")
		
		# --- gun shot logic ---
		# reset cooldown
		cooldown =1.0 / fire_rate
		# delete bullet
		current_mag -= 1
		# play sfx
		# reset shot animation
		play("shooting")
		frame = 0
		$Flash.frame = 0
		
		# calculate spread
		var angle = shot_angle + spread * (randi()%200 - 100) / 100
		
		# create bullet instance
		var bullet = Bullet.instance()
		bullet.damage = base_damage
		bullet.global_position = $Barrel.global_position
		bullet.linear_velocity = Vector2(shot_speed, 0).rotated(angle)
		bullet.rotation = angle
		get_tree().current_scene.get_node("Bullets").add_child(bullet)
		
		# notify player of dercreased bullets
		emit_signal("mag_changed", current_mag) # update player mag value
	
	# click mechanism
	if current_mag <= 0 && cooldown <= 0.0 && state == FREE:
		# reset cooldown
		cooldown = 0.5
		
		# play sfx
		$ClickSFX.play()
