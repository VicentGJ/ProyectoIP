extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_exit_pressed():
	get_tree().change_scene("res://control/mainMenu.tscn")
	get_tree().set_pause(false)


func _on_Jugar_pressed():
	get_tree().set_pause(false)
	queue_free()


func _on_options_pressed():
	var menu=load("res://control/optionsPause.tscn").instance()
	get_parent().add_child(menu)
	queue_free()
