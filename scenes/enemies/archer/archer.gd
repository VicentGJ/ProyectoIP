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
onready var player=get_parent().get_node("player")
var dir=Direction.Right

export var health = 40
var state=State.Walking
export var damage = 20

signal damage_player(damage)

func _ready():
	stateMachine = $AnimationTree.get("parameters/playback")
	
	
	
func _physics_process(delta):
	velocity.y += gravity * delta
	if health > 0: #si esta vivo
		#ataque
		if state!=State.Hit:
			if $vision.get_collider() == player:
				state=State.Attack
			elif $visionBack.get_collider() == player:
				if dir == Direction.Right:
					turnDir(false)
				else:
					turnDir(true)
				state=State.Attack
			
			
		#caminando
		if state==State.Walking:
			stateMachine.travel("walking")
			
			#chocando un muro
			if is_on_wall():
				if dir==Direction.Right:
					turnDir(false)
				else:
					turnDir(true)
			#borde del precipicio
			if dir==Direction.Left:
				if derecha.is_colliding() and !izquierda.is_colliding():
					turnDir(true)
				else:
					velocity.x=-linealVelocity
			elif dir==Direction.Right:
				if !derecha.is_colliding() and izquierda.is_colliding():
					turnDir(false)
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
		
		elif state == State.Attack and $TimerAttack.get_time_left() == 0:
			velocity.x=0
			stateMachine.travel("attack")
			$TimerAttack.start()
			
#			yield(get_tree().create_timer(0.7),"timeout")
			state=State.Idle
		
		if health!=0:
			velocity = move_and_slide(velocity,Vector2(0,-1))

	else:
		health=0;
		stateMachine.travel("death")

		$CollisionShape2D.set_disabled(true)
		
func turnDir(right):
	if right:
		dir=Direction.Right
		sprite.set_flip_h(false)
		$vision.cast_to=Vector2(400,0)
		$visionBack.cast_to=Vector2(-250,0)
	else:
		dir=Direction.Left
		sprite.set_flip_h(true)
		$vision.cast_to=Vector2(-400,0)
		$visionBack.cast_to=Vector2(250,0)





func recieveDamage(value):
	health -= value
	state=State.Hit


func _on_Timer_timeout():
	if state==State.Idle:
		state=State.Walking
	elif state==State.Walking:
		state=State.Idle
		
func launchArrow():
	var newArrow=load("res://scenes/enemies/archer/arrow.tscn").instance()
	get_parent().add_child(newArrow)
	
	if dir==Direction.Right:
		newArrow.position=Vector2(position.x,position.y-8.5)
		newArrow.linear_velocity=Vector2(1000,0)
	else:
		newArrow.position=Vector2(position.x-13,position.y-13.5)
		newArrow.linear_velocity=Vector2(-1000,0)
		newArrow.get_node("Projectile").set_flip_h(true)
		
