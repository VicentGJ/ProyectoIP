extends StaticBody2D

func _process(delta):
	if Input.is_action_pressed("ui_down") and Input.is_action_pressed("jump"):
		$CollisionShape2D.set_disabled(true)
		$restoreCollision.start()
	
func _on_restoreCollision_timeout():
	$CollisionShape2D.set_disabled(false)
