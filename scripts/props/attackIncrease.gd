extends KinematicBody2D
onready var tween = $Tween
onready var powerUp = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")
onready var material_increaseAttack = preload("res://effects/powerUP_increaseAttack.tres")
onready var material_increaseMaxHp = preload("res://effects/powerUP_increaseMaxHp.tres")
onready var material_heal = preload("res://effects/powerUP_heal.tres")

export var value = 20
export var price = 0

var collected = false
var gravity = 200
var velocity = Vector2()

enum TYPE { random, heal, maxHP, maxAP }
export (TYPE) var type = TYPE.random

signal increaseAttack(amount)

func _ready():
	randomize()
	if price > 0:
		$price.text =str(round(price))
	
func _process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		if Input.is_action_just_pressed("interact") and player.money >= price:
			tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
			tween.start()
			tween.interpolate_property(powerUp, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
			tween.start()
			player.changeStats()
			collected = true
			toQueueFree.start()



func _on_queueFreeTimer_timeout():
	player.add_money(-price)
	queue_free()
