extends StaticBody2D

onready var leftRay = $left
onready var rightRay = $right
onready var tween = $Tween
onready var particles = $Particles2D
onready var door = $Sprite
onready var player = get_parent().get_parent().get_node("player")

export var isDoorRare = false
var opened = false
var neededKey


func _ready():
	if isDoorRare:
		$Sprite.set_animation("door2")
		neededKey = 1
	else:
		$Sprite.set_animation("door1")
		neededKey = 0
		
func open():
	if isDoorRare:
		$AnimationPlayer.play("openRare")
	else:
		$AnimationPlayer.play("openRegular")

func _process(delta):
	if not opened and (Input.is_action_just_pressed("interact") and (leftRay.get_collider() == player \
	or rightRay.get_collider() == player)):
		if neededKey == 0 and player.keys[0] >= 1:
			player.changeKeys(neededKey, -1)
			open()
			opened = true
		elif neededKey == 1 and player.keys[0] >= 1:
			player.changeKeys(neededKey, -1)
			open()
			opened = true
