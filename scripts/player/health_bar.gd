extends Control

onready var health_over = $health_under/health_over
onready var health_under = $health_under
onready var update_tween = $update_hp_bar
onready var hp_pulse = $low_hp_pulse
onready var animPlay = $AnimationPlayer

var will_pulse = false

signal damaged(currentHP)

func _on_player_healthChange(value):
	if value > 0: #damage
		update_tween.interpolate_property(health_under, "value", health_over.value,health_over.value - value, 0.4,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
		update_tween.start()
		health_over.value -= value
		$numeric_hp_update.interpolate_method(self, "numeric_hpCount",health_under.value, health_over.value,0.4,Tween.TRANS_EXPO,Tween.EASE_IN)
		$numeric_hp_update.start()
		animPlay.play("shake")
		emit_signal("damaged",health_over.value)
	if value < 0: #healing
		health_under.value -= value
		update_tween.interpolate_property(health_over, "value", health_over.value,health_under.value, 0.4,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
		update_tween.start()
		$health_under/Particles2D.set_emitting(true)
		$numeric_hp_update.interpolate_method(self, "numeric_hpCount",health_over.value, health_under.value,0.4,Tween.TRANS_LINEAR,Tween.EASE_IN)
		$numeric_hp_update.start()
	set_hpColor(health_over.value)
	
func set_hpColor(health):
	if health <= health_over.max_value * 0.2:
		health_over.tint_progress = Color.red
		hp_pulse.interpolate_property(health_over, "tint_progress", Color.darkred, Color.red, 0.4, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		hp_pulse.start()

	elif health <= health_over.max_value * 0.4:
		health_over.tint_progress = Color.orangered
		hp_pulse.set_active(false)

	elif health <= health_over.max_value * 0.5:
		health_over.tint_progress = Color.orange
		hp_pulse.set_active(false)

	elif health <= health_over.max_value * 0.6:
		health_over.tint_progress = Color.yellow
		hp_pulse.set_active(false)

	else:
		health_over.tint_progress = Color.green
		hp_pulse.set_active(false)
func numeric_hpCount(value):
	$health_under/current_hp.text = "HP " + str(round(value)) + " / " + str(health_over.max_value)


func _on_player_maxHPincrease(amount):
	health_over.max_value += amount
	health_under.max_value += amount
