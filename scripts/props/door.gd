extends Area2D

onready var leftRay = $left
onready var rightRay = $right
onready var tween = $Tween
onready var particles = $Particles2D
onready var door = $Sprite
onready var player = get_parent().get_node("player")

export var isDoorRare = false

func _ready():
	if isDoorRare:
		$Sprite.frame = 2
	else:
		$Sprite.frame = 0

func open():
	if isDoorRare:
		$AnimationPlayer.play("open")

func _process(delta):
	if Input.is_action_just_pressed("interact") and (leftRay.get_collider() == player \
	or rightRay.get_collider() == player):
		open()
