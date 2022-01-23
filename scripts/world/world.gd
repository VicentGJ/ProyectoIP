extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#
#	#pause
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().set_pause(true)
		var menu=load("res://control/pause.tscn").instance()
		get_node("CanvasLayer").add_child(menu)
