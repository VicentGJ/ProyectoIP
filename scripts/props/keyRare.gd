extends KinematicBody2D

onready var tween = $Tween
onready var key = $Sprite
onready var toQueueFree = $queueFreeTimer
onready var leftRay = $left
onready var rightRay = $right
onready var player = get_parent().get_node("player")
onready var particles = $Particles2D
export var price = 0
var collected = false
var goToFloor = 200
var velocity = Vector2()
signal collected()

func _physics_process(delta):
	velocity.y += goToFloor * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if not collected and (leftRay.get_collider() == player or leftRay.get_collider() == player):
		if Input.is_action_just_pressed("interact") and player.money >= price:
			particles.set_emitting(false)
			tween.interpolate_property(self, "position", position,Vector2(position.x , position.y - 30),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN) 
			tween.start()
			tween.interpolate_property(key, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5,Tween.TRANS_BOUNCE)
			tween.start()
			collected = true
			$AnimationPlayer.play("keyCollected")
			toQueueFree.start()
			
		
func _on_queueFreeTimer_timeout():
	emit_signal("collected")
	player.add_money(-price)
	queue_free()
