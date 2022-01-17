extends KinematicBody2D
var movementLimit
var handLife = 21 #7 full combos of the player
onready var handMove = $StandartMove
onready var horizontalAttack = $HorizontalAttack
func _ready():
	pass

#func damage

func damaged():
	handLife -= 1

func horizontalAttack():
	horizontalAttack.interpolate_property(self,"position:x",position.x,position.x + 200, 1,Tween.TRANS_BACK,Tween.EASE_IN)
	
func _process(delta):
	pass
