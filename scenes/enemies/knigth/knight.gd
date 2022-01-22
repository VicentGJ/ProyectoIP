extends KinematicBody2D

export (int) var gravity = 500
export (int) var linealVelocity = 200
onready var sprite = $Sprite
export var velocity = Vector2.ZERO
var stateMachine

enum Direction{Left, Right}
enum State{Walking, Idle, Attack, Death, Hit}

onready var derecha=get_node("Derecha")
onready var izquierda=get_node("Izquierda")
var dir=Direction.Right

var health = 100
var state=State.Walking
var damage = 25

signal damage_player(damage)

func _ready():
	stateMachine = $AnimationTree.get("parameters/playback")
	$attackRaycast.enabled=false
	
	
	
func _physics_process(delta):
	velocity.y+=gravity*delta
	if health > 0: #si esta vivo
		#ataque
		if state!=State.Hit:
			if $detectAttack.get_collider()==get_parent().get_node("player"):
					state=State.Attack
			elif $vision.get_collider()==get_parent().get_node("player"):
				state=State.Walking
			elif $visionBack.get_collider()==get_parent().get_node("player"):
				if dir==Direction.Right:
					turnDir(false)
				else:
					turnDir(true)
				state=State.Walking
			else:
				state=State.Idle
			
		#caminando
		if state==State.Walking:
			stateMachine.travel("walking")
			
			#chocando un muro
#			if is_on_wall():
#				if dir==Direction.Right:
#					turnDir(false)
#				else:
#					turnDir(true)
			#borde del precipicio
			if dir==Direction.Left:
				if derecha.is_colliding() and !izquierda.is_colliding():
					velocity.x=0
					state = State.Idle
				else:
					velocity.x=-linealVelocity
			elif dir==Direction.Right:
				if !derecha.is_colliding() and izquierda.is_colliding():
					velocity.x=0
					state = State.Idle
				else:
					velocity.x=linealVelocity
			
			
		
		elif state==State.Idle:
			 velocity.x=0
			 stateMachine.travel("Idle")
			
		elif state==State.Hit:
			velocity.x=0
			stateMachine.travel("hit")
			$Tween.interpolate_property(sprite,"modulate",Color(1, 0, 0),Color(1, 1, 1),0.5,Tween.TRANS_BOUNCE)
			$Tween.start()
			yield(get_tree().create_timer(0.6),"timeout")
			state=State.Idle
		
		elif state==State.Attack:
			velocity.x=0
			stateMachine.travel("attack")
			if $attackRaycast.enabled:
				if $attackRaycast.get_collider() == get_parent().get_node("player"):
					emit_signal("damage_player", damage)
#			yield(get_tree().create_timer(0.7),"timeout")
			state=State.Idle
		
		if health!=0:
			velocity = move_and_slide(velocity,Vector2(0,-1))


	#c muere
	else:
#		sprite.stop()
		health=0;
		stateMachine.travel("death")

		$CollisionShape2D.set_disabled(true)
		
func turnDir(right):
	if right:
		dir=Direction.Right
		sprite.set_flip_h(false)
		$detectAttack.cast_to=Vector2(30,0)
		$attackRaycast.cast_to=Vector2(30,0)
		$vision.cast_to=Vector2(200,0)
		$visionBack.cast_to=Vector2(-150,0)
	else:
		dir=Direction.Left
		sprite.set_flip_h(true)
		$detectAttack.cast_to=Vector2(-30,0)
		$attackRaycast.cast_to=Vector2(-30,0)
		$vision.cast_to=Vector2(-200,0)
		$visionBack.cast_to=Vector2(150,0)





func _on_player_damage(damage,enemy):
	
	if enemy==self:
		print(enemy)
		health -=damage
		state=State.Hit
