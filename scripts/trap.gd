extends Area2D

var canTrigger = true
var trapDamage = 25

signal trapTriggered(damage)

func _on_trap_body_entered(body):
	if canTrigger:
		emit_signal("trapTriggered", trapDamage)
		$reactivate.start()
		canTrigger = false

func _on_reactivate_timeout():
	canTrigger = true

