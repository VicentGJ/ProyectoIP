extends Area2D
onready var tween = $Tween
onready var coin = $Sprite
onready var toQueueFree = $queueFreeTimer

var coinValue = 10

signal collected(coinValue)


func _on_player_collect():
	tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
	tween.start()
	tween.interpolate_property(coin, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
	tween.start()
	emit_signal("collected",coinValue)
	toQueueFree.start()

func _on_queueFree_Timer_timeout():
	queue_free()
