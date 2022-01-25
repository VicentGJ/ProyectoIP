extends KinematicBody2D


onready var player = get_parent().get_parent().get_node("player")
onready var leftRay = $left
onready var rightRay = $right
onready var particles = $Particles2D
onready var label = $Label
var collected = false

func dropPowerUP():
	var droped = false
	var powerUPdrop = load("res://scenes/props/powerUP.tscn").instance()
	if not droped:
		get_parent().add_child(powerUPdrop)
		powerUPdrop.set_position(Vector2(position.x,position.y))
		powerUPdrop.velocity.y -= 30
		droped = true

func _process(delta):
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		label.set_modulate(Color(1,1,1,1))
		if Input.is_action_just_pressed("interact"):
			label.set_modulate(Color(1,1,1,0))
			particles.set_emitting(false)
			collected = true
			dropPowerUP()
			$AnimationPlayer.play("openChest")
	else:
		label.set_modulate(Color(1,1,1,0))
