extends Sprite

onready var player = get_parent().get_node("player")
onready var leftRay = $left
onready var rightRay = $right
onready var particles = $Particles2D
var collected = false

signal varjCollected()

func _process(delta):
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		if Input.is_action_just_pressed("interact"):
			particles.set_emitting(false)
			emit_signal("varjCollected")
