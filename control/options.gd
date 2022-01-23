extends Control

var fullScreen
var volumen


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	fullScreen=OS.window_fullscreen
	volumen=AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$VBoxContainer/HBoxContainer/fullOrNot.pressed=fullScreen
	$VBoxContainer/HBoxContainer2/controlVolume.value=volumen
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CheckBox_pressed():
	if $VBoxContainer/HBoxContainer/fullOrNot.pressed:
		print("Full Screen on")
		OS.window_fullscreen=true
	else:
		print("Full Screen off")
		OS.window_fullscreen=false
		


func _on_Button_pressed():
	get_tree().change_scene("res://control/mainMenu.tscn")




func _on_controlVolume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
