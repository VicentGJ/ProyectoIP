extends Area2D

onready var player = get_parent().get_node("player")

var canTrigger = false

export var trapDamage = -15


func _on_trap_body_entered(body):
	if canTrigger:
		player.changeStats(0, trapDamage)
		$reactivate.start()
		canTrigger = false


func _on_reactivate_timeout():
	canTrigger = true

