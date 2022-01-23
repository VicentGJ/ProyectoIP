extends Sprite

onready var player = get_parent().get_node("player")
onready var leftRay = $left
onready var rightRay = $right
onready var particles = $Particles2D
onready var tween = $Tween
onready var label = $Label
var collected = false


func _process(delta):
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		label.set_modulate(Color(1,1,1,1))
		if Input.is_action_just_pressed("interact"):
			label.set_modulate(Color(1,1,1,0))
			particles.set_emitting(false)
			player.changeDimension()
			collected = true

