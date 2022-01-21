extends Node2D

var canTrigger = true
var trapDamage = 25

signal trapTriggered(damage)

func _on_Area2D_body_entered(body):
	if canTrigger:
		emit_signal("trapTriggered", trapDamage)
		$trap/reactivate.start()
		canTrigger = false

func _on_reactivate_timeout():
	$trap/CollisionShape2D.set_disabled(false)
	canTrigger = true
