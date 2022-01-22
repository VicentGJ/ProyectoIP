extends Node2D

func _ready():
	$vignet1.set_modulate(Color(1,1,1,0))
	$vignet2.set_modulate(Color(1,1,1,0))
	$AnimationPlayer.play("transicion1")
