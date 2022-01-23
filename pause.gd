extends Control

var fullScreen
var volumen


# Called when the node enters the scene tree for the first time.
func _ready():
	fullScreen=OS.window_fullscreen
	volumen=AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$VBoxContainer/HBoxContainer/CheckBox.pressed=fullScreen
	$VBoxContainer/HBoxContainer2/HSlider.value=volumen
	
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Back_pressed():
	var menu=load("res://control/pause.tscn").instance()
	get_parent().add_child(menu)
	queue_free()


func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)



func _on_CheckBox_pressed():
	if $VBoxContainer/HBoxContainer/CheckBox.pressed:
		print("Full Screen on")
		OS.window_fullscreen=true
	else:
		print("Full Screen off")
		OS.window_fullscreen=false
