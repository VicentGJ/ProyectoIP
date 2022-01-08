extends Control

onready var health_over = $health_over
onready var health_under = $health_under
onready var tween = $Tween

func damaged(damage):
	tween.interpolate_property(health_under, "value", health_over.value,health_over.value - damage, 0.4,Tween.TRANS_LINEAR,Tween.EASE_IN,0.1)
	tween.start()
	health_over.value -= damage

#func _physics_process(delta):
#	if Input.is_action_just_pressed("attack"):
#		damaged(10)
	
