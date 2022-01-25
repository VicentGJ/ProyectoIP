extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Jugar_pressed():
	get_tree().change_scene("res://scenes/world/final/GameWorld.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Creditos_pressed():	
	get_tree().change_scene("res://control/credits.tscn")


func _on_Opciones_pressed():
	get_tree().change_scene("res://control/options.tscn")


func _on_Controls_pressed():
	get_tree().change_scene("res://control/tutorial.tscn")
