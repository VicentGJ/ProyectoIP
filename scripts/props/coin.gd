extends Area2D
onready var tween = $Tween
onready var coin = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")
export var coinValue = 10

var collected = false

func _physics_process(delta):
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
		tween.start()
		tween.interpolate_property(coin, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
		tween.start()
		collected = true
		toQueueFree.start()

func _on_queueFree_Timer_timeout():
	self.addMoneyToPlayer(coinValue)
	queue_free()

func addMoneyToPlayer(value):
	get_parent().get_node("player").add_money(value)
