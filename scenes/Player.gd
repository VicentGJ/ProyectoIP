extends KinematicBody2D

export (int) var speed = 200
export (int) var jump_speed = -450
export (int) var gravity = 900
var velocity = Vector2()
var attack_counter = 1
var state_machine
var sliding = false
var crouching = false
var attacking = false
var falling = false

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
func restore_playerProperty():
	$Player_area.shape.set_extents(Vector2(20,35)) #restaurar tamaño de la collision shape
	$Player_area.set_position(Vector2(0, 5))       #restaurar posicion de la collision shape
	$Player_area.disabled = false                  #reactivar collision shape
	speed = 200                                    #restaurar velocidad 
	gravity = 900                                  #restaurar la gravedad
func player_movement(right, left):
	if right:
		velocity.x += speed
	elif left:
		velocity.x -= speed
func run_animation():
	$Sprite.flip_h = velocity.x < 0
	if velocity.x < 0:         #cuando corre el sprte se pone un poco por delante de la colision, fixed
		$Player_area.set_position(Vector2(-4, 5))
	elif velocity.x > 0:
		$Player_area.set_position(Vector2(4, 5))
	state_machine.travel("run")
func idle_animation():
	state_machine.travel("idle")
func crouch_animation():
	crouching = true
	state_machine.travel("crouch")
	$Player_area.shape.set_extents(Vector2(20,25))
	$Player_area.set_position(Vector2(0, 15))
func attack_animation():
	attacking = true
	if attack_counter == 1 and $attack_delay.get_time_left() == 0:
		if $Sprite.flip_h == false:
			$Area2D/attack_area1.shape.set_extents(Vector2(16.5,38.5))
			$Area2D/attack_area2.shape.set_extents(Vector2(13,7))
			$Area2D/attack_area1.set_position(Vector2(36.5,-5.5)) 
			$Area2D/attack_area2.set_position(Vector2(7,-37))
		else:
			$Area2D/attack_area1.shape.set_extents(Vector2(17,38.5))
			$Area2D/attack_area2.shape.set_extents(Vector2(14.5,7))
			$Area2D/attack_area1.set_position(Vector2(-36,-5.75)) 
			$Area2D/attack_area2.set_position(Vector2(-4.5,-37))
		state_machine.travel("attack_1")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_1.start()
	elif attack_counter == 2 and $attack_delay.get_time_left() < 0.5:
		if $Sprite.flip_h == false:
			$Area2D/attack_area1.shape.set_extents(Vector2(15.5,35))
			$Area2D/attack_area2.shape.set_extents(Vector2(16,12))
			$Area2D/attack_area1.set_position(Vector2(35.5,7)) 
			$Area2D/attack_area2.set_position(Vector2(-35,25))
		else:
			$Area2D/attack_area1.shape.set_extents(Vector2(16,35))
			$Area2D/attack_area2.shape.set_extents(Vector2(15.5,11.5))
			$Area2D/attack_area1.set_position(Vector2(-35,7)) 
			$Area2D/attack_area2.set_position(Vector2(35.5,24.5))
		state_machine.travel("attack_2")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_2.start()
	elif attack_counter == 3 and $attack_delay.get_time_left() < 0.65:
		if $Sprite.flip_h == false:
			$Area2D/attack_area1.shape.set_extents(Vector2(17.5,20.5))
			$Area2D/attack_area2.shape.set_extents(Vector2(18,14.5))
			$Area2D/attack_area1.set_position(Vector2(37.5,15.5)) 
			$Area2D/attack_area2.set_position(Vector2(-37,18.5))
		else:
			$Area2D/attack_area1.shape.set_extents(Vector2(18,21.5))
			$Area2D/attack_area2.shape.set_extents(Vector2(18,16.5))
			$Area2D/attack_area1.set_position(Vector2(-37,14.5)) 
			$Area2D/attack_area2.set_position(Vector2(38,20.75))
		state_machine.travel("attack_3")
		attack_counter += 1
		$Area2D/attacking_3.start()
func do_jump():
	velocity.y = jump_speed 
	state_machine.travel("fall")
func fall_animation():
	state_machine.travel("fall")
	falling = true
func slide_animation():
	sliding = true
	$sliding.start()
	$Player_area.disabled = true
	speed += 200
	gravity = 0
	state_machine.travel("slide")
	$Player_area.shape.set_extents(Vector2(20,20))
	$Player_area.set_position(Vector2(0, 20))
func get_input():
	velocity.x = 0
	var current_anim = state_machine.get_current_node()
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var crouch = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_just_pressed("jump")
	var slide = Input.is_action_just_pressed("slide")
	var attack = Input.is_action_just_pressed("attack")
	
	$Area2D/attack_area1.disabled = not attacking
	$Area2D/attack_area2.disabled = not attacking
	
	if not crouch and attack_counter == 1:
		player_movement(right, left)
		if velocity.length() == 0:
			idle_animation()
		elif velocity.x != 0 and sliding == false and attacking == false: 
			run_animation()
		
	if not crouching and not sliding and attacking == false:
		restore_playerProperty()
	
	if is_on_floor():
		if crouch:
			crouch_animation()
		else:
			crouching = false
			falling = false
			if attack_counter == 4:
				attack_counter = 1
			if attack:
				attack_animation()
			elif jump:
				do_jump()
			elif (slide) and (right or left) and (not crouch):
				slide_animation()
		
	elif  sliding == false:
		fall_animation()
	
func _physics_process(delta):
	
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_attack_delay_timeout():
	attack_counter = 1

func _on_sliding_timeout():
	sliding = false
	restore_playerProperty()

func _on_attacking_1_timeout():
	attacking = false

func _on_attacking_2_timeout():
	attacking = false

func _on_attacking_3_timeout():
	attacking = false
