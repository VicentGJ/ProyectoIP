extends Control

onready var health_over = $health_over
onready var health_under = $health_under
onready var update_tween = $update_hp_bar
onready var hp_pulse = $low_hp_pulse

var will_pulse = false

func hp_change(change):
	if change > 0: #damage
		update_tween.interpolate_property(health_under, "value", health_over.value,health_over.value - change, 0.4,Tween.TRANS_LINEAR,Tween.EASE_IN,0.2)
		update_tween.start()
		health_over.value -= change
	elif change < 0: #healing
		health_under.value -= change
		update_tween.interpolate_property(health_over, "value", health_over.value,health_under.value, 0.4,Tween.TRANS_LINEAR,Tween.EASE_IN,0.2)
		update_tween.start()

	set_hpColor(health_over.value)
	
func set_hpColor(health):
	if health < health_over.max_value * 0.2:
		health_over.tint_progress = Color.red
		hp_pulse.interpolate_property(health_over, "tint_progress", Color.darkred, Color.red, 0.4, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		hp_pulse.start()
	elif health < health_over.max_value * 0.4:
		health_over.tint_progress = Color.orangered
		hp_pulse.set_active(false)
	elif health < health_over.max_value * 0.5:
		health_over.tint_progress = Color.orange
		hp_pulse.set_active(false)
	elif health < health_over.max_value * 0.6:
		health_over.tint_progress = Color.yellow
		hp_pulse.set_active(false)
	elif health > health_over.max_value * 0.6:
		health_over.tint_progress = Color.green
		hp_pulse.set_active(false)
