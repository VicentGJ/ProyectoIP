extends Area2D
onready var tween = $Tween
onready var healItem = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")

export var healAmount = -10
export var price = 0

signal heal(healAmount)

func _process(delta):
	if leftRay.get_collider() == player or leftRay.get_collider() == player:
		if Input.is_action_just_pressed("collect") and player.money >= price:
			tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
			tween.start()
			tween.interpolate_property(healItem, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
			tween.start()
			emit_signal("heal",healAmount)
			toQueueFree.start()



func _on_queueFreeTimer_timeout():
	player.add_money(-price)
	queue_free()
