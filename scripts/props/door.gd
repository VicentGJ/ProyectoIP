extends StaticBody2D

onready var leftRay = $left
onready var rightRay = $right
onready var tween = $Tween
onready var particles = $Particles2D
onready var door = $Sprite
onready var player = get_parent().get_node("player")

export var isDoorRare = false

func _ready():
	if isDoorRare:
		$Sprite.set_animation("door2")
	else:
		$Sprite.set_animation("door1")

func open():
	if isDoorRare:
		$AnimationPlayer.play("openRare")
	else:
		$AnimationPlayer.play("openRegular")

func _process(delta):
	if Input.is_action_just_pressed("interact") and (leftRay.get_collider() == player \
	or rightRay.get_collider() == player):
		open()
