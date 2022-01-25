extends RigidBody2D
var damaging=true
var count=0

export var damage=20
onready var player=get_parent().get_parent().get_node("player")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_finish_timeout():
	queue_free()

func _on_enemyDetector_body_entered(body):
	count+=1
	if count==5:
		damaging=false
	if body==get_parent().get_parent().get_node("player") and damaging:
		#daño de flecha aqui
		player.changeStats(0, -damage)
		queue_free()


#func _on_damaging_timeout():
#	damaging=false
