extends Area2D

var canTrigger = true
export var trapDamage = 15

signal trapTriggered(damage)

func _on_trap_body_entered(body):
	if canTrigger:
		emit_signal("trapTriggered", trapDamage)
		$reactivate.start()
		canTrigger = false

func _on_reactivate_timeout():
	canTrigger = true

