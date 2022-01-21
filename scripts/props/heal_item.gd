extends Area2D
onready var tween = $Tween
onready var healItem = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right

export var healAmount = -10

signal heal(healAmount)

func _process(delta):
	if leftRay.is_colliding() or rightRay.is_colliding():
		if Input.is_action_just_pressed("collect"):
			tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
			tween.start()
			tween.interpolate_property(healItem, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
			tween.start()
			emit_signal("heal",healAmount)
			toQueueFree.start()



func _on_queueFreeTimer_timeout():
	queue_free()
