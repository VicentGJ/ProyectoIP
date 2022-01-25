extends KinematicBody2D

export (int) var gravity = 500
export (int) var linealVelocity = 150
onready var player = get_parent().get_parent().get_node("player")
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

var win = false

signal damage_player(damage)

func _ready():
	stateMachine = $AnimationTree.get("parameters/playback")
	$attackRaycast.enabled=false
	
func _physics_process(delta):
	var current_anim = stateMachine.get_current_node()
	velocity.y+=gravity*delta
	if player.inmunity:
		$detectAttack.set_collision_mask(2)
		$vision.set_collision_mask(2)
		$visionBack.set_collision_mask(2)
	else:
		$detectAttack.set_collision_mask(1)
		$vision.set_collision_mask(1)
		$visionBack.set_collision_mask(1)
	if health > 0: #si esta vivo
		#ataque
		if state!=State.Hit and not player.dead:
			if $detectAttack.get_collider()==player:
					state=State.Attack
			elif $vision.get_collider()==player:
				state=State.Walking
			elif $visionBack.get_collider()==player:
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
			if current_anim == "attack":
				velocity.x=0
		
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
				if $attackRaycast.get_collider() == player:
					player.changeStats(0, -damage)
			state=State.Idle
		
		if health!=0:
			velocity = move_and_slide(velocity,Vector2(0,-1))


	#c muere
	else:
		if !win:
			get_parent().add_child(load("res://scenes/props/coin.tscn").instance())
			health=0;
			stateMachine.travel("death")
			$CollisionShape2D.set_disabled(true)
			win = true
			player.win()

func turnDir(right):
	if right:
		dir=Direction.Right
		sprite.set_flip_h(false)
		$detectAttack.cast_to=Vector2(40,0)
		$attackRaycast.cast_to=Vector2(40,0)
		$vision.cast_to=Vector2(200,0)
		$visionBack.cast_to=Vector2(-150,0)
	else:
		dir=Direction.Left
		sprite.set_flip_h(true)
		$detectAttack.cast_to=Vector2(-40,0)
		$attackRaycast.cast_to=Vector2(-40,0)
		$vision.cast_to=Vector2(-200,0)
		$visionBack.cast_to=Vector2(150,0)

func recieveDamage(value):
	health -= value
	state=State.Hit
