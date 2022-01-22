extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#
#	#pause
	if Input.is_action_just_pressed("menu"):
		get_tree().set_pause(true)
		var menu=load("res://control/pause.tscn").instance()
		get_node("CanvasLayer").add_child(menu)
