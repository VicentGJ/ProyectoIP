extends Area2D

onready var tween = $Tween
onready var key = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")

signal collected()

func _physics_process(delta):
	if leftRay.get_collider() == player or leftRay.get_collider() == player:
		if Input.is_action_just_pressed("collect"):
			tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
			tween.start()
			tween.interpolate_property(key, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
			tween.start()
			toQueueFree.start()
		
		
func _on_queueFreeTimer_timeout():
	emit_signal("collected")
	queue_free()
