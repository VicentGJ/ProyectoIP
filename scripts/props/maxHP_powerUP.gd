extends Area2D
onready var tween = $Tween
onready var powerUp = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")

export var amount = 10
export var price = 0

var collected = false

signal increaseMaxHP(amount)

func _process(delta):
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		if Input.is_action_just_pressed("interact") and player.money >= price:
			tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
			tween.start()
			tween.interpolate_property(powerUp, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_LINEAR)
			tween.start()
			emit_signal("increaseMaxHP",amount)
			collected = true
			toQueueFree.start()

func _on_queueFreeTimer_timeout():
	player.add_money(-price)
	queue_free()
