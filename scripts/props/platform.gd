extends StaticBody2D
onready var player = get_parent().get_parent().get_node("player")

func _process(delta):
	if (Input.is_action_pressed("ui_down") and Input.is_action_pressed("jump"))\
	or $RayCast2D.get_collider() == player:
		print("lol")
		set_collision_layer(4)
		set_collision_mask(4)
		$restoreCollision.start()
	
func _on_restoreCollision_timeout():
	set_collision_layer(3)
	set_collision_mask(3)
