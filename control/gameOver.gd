extends Control

func _ready():
	$AnimationPlayer.play("fade")


func _on_Jugar_pressed():
	get_tree().reload_current_scene()





func _on_exit_pressed():
	get_tree().change_scene("res://control/mainMenu.tscn")
