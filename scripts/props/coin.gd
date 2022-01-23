extends Area2D
onready var tween = $Tween
onready var coin = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")
export var coinValue = 10
onready var particles = $Particles2D
onready var materialGold = preload("res://effects/coinGoldParticles.tres")
onready var materialSapphire = preload("res://effects/coinSapphireParticles.tres")
onready var materialRuppies = preload("res://effects/coinRupiesParticles.tres")

var random

var collected = false
func _ready():
	randomize()
	random = randi() % 11
	if random < 6:
		coin.set_modulate(Color.gold)
		coinValue = 10
		particles.set_process_material(materialGold)
	elif random < 9:
		coin.set_modulate(Color.royalblue)
		coinValue = 20
		particles.set_process_material(materialSapphire)
	else:
		coin.set_modulate(Color.crimson)
		coinValue = 30
		particles.set_process_material(materialRuppies)
func _physics_process(delta):
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
		tween.start()
		tween.interpolate_property(coin, "modulate", coin.get_modulate(), Color(1, 1, 1, 0), 0.5,Tween.TRANS_LINEAR)
		tween.start()
		collected = true
		$AnimationPlayer.play("coinCollected")
		toQueueFree.start()

func _on_queueFree_Timer_timeout():
	self.addMoneyToPlayer(coinValue)
	queue_free()

func addMoneyToPlayer(value):
	get_parent().get_node("player").add_money(value)
