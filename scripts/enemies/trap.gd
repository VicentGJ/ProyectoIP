extends Area2D

var canTrigger = true
export var trapDamage = 15

signal trapTriggered(damage)

func _on_trap_body_entered(body):
	if canTrigger:
		emit_signal("trapTriggered", trapDamage)
		$reactivate.start()
		canTrigger = false
		$Tween.interpolate_property(self,"position:y", position.y, position.y + 14,0.5, Tween.TRANS_LINEAR)
		$Tween.start()

func _on_reactivate_timeout():
	$Tween.interpolate_property(self,"position:y", position.y, position.y - 14,0.5, Tween.TRANS_LINEAR)
	$Tween.start()
	canTrigger = true

