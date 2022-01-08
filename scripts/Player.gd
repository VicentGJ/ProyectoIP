extends KinematicBody2D

export (int) var speed = 200
export (int) var jump_speed = -450
export (int) var gravity = 900
var velocity = Vector2()
var state_machine
var attack_counter = 1
var sliding = false
var crouching = false
var attacking = false
var falling = false
var running = false
var looking_up = false
var climbing = false

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
func restore_playerProperty():
	$Player_area.shape.set_extents(Vector2(19.5,36)) #restaurar tamaño de la collision shape
	$Player_area.set_position(Vector2(0.5, 6))       #restaurar posicion de la collision shape
	$Player_area.disabled = false                  #reactivar collision shape
	
	speed = 200                                    #restaurar velocidad 
	gravity = 900
	
	$Camera2D.set_v_offset(0)                         #restaurar camara en Y
	
	set_collision_layer(1)                         #restaurar capa de collision del personaje
	set_collision_mask(1)                          #restaurar mascara de collision del personaje
	
	$ray_to_climb.set_collision_mask(1)            #restaurar mascara de collision de los raycast
	$ray_to_climb_2.set_collision_mask(1)
	$ray_to_climb_3.set_collision_mask(1)
	
	if not $Sprite.flip_h:                    #ajustar los raycast para el climb
		$ray_to_climb.set_cast_to(Vector2(22,-33))
		$ray_to_climb_2.set_cast_to(Vector2(22,-25))
		$ray_to_climb_3.set_cast_to(Vector2(25,-70))
		$Camera2D.set_h_offset(300)                    #restaurar camara en X
	else:
		$ray_to_climb.set_cast_to(Vector2(-22,-33))
		$ray_to_climb_2.set_cast_to(Vector2(-22,-25))
		$ray_to_climb_3.set_cast_to(Vector2(-25,-70))
		$Camera2D.set_h_offset(-300)  
func player_movement(right, left):
	if not sliding:
		if right:
			velocity.x += speed
		elif left:
			velocity.x -= speed
	else:
		if not $Sprite.flip_h:
			velocity.x += speed
		else:
			velocity.x -= speed
		if is_on_wall():
			if  $Sprite.flip_h:
				$Tween.interpolate_property(self,"position", position,Vector2(position.x+1, position.y),$sliding.get_time_left(),Tween.TRANS_LINEAR)
			else:
				$Tween.interpolate_property(self,"position", position,Vector2(position.x-1, position.y),$sliding.get_time_left(),Tween.TRANS_LINEAR)
			$Tween.start()
func run_animation():
	$Sprite.flip_h = velocity.x < 0
	state_machine.travel("run")
	running = true
func idle_animation():
	state_machine.travel("idle")
	running = false
func crouch_animation():
	crouching = true
	state_machine.travel("crouch")
	$Player_area.shape.set_extents(Vector2(19.5,26.5))
	$Player_area.set_position(Vector2(0.5, 15.5))
	if $Camera2D/camera_timer.get_time_left() == 0 and $Camera2D.offset_v == 0:
		$Camera2D/camera_timer.start()
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
		$attack_delay.start()
		$Area2D/attacking_3.start()
func air_attack_animation():
	state_machine.travel("air_attack")
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
func do_jump():
	velocity.y = jump_speed 
	state_machine.travel("fall")
func fall_animation():
	state_machine.travel("fall")
	falling = true
func slide_animation():
	if $slide_delay.get_time_left() == 0 and $attack_delay.get_time_left() == 0:
		sliding = true
		$sliding.start()
		$slide_delay.start()
		set_collision_layer(2) #cambiar la capa y mascara de colision del player
		set_collision_mask(2)
		$ray_to_climb.set_collision_mask(3) #cambiar la capa y mascara de colision de los ray
		$ray_to_climb_2.set_collision_mask(3)
		$ray_to_climb_3.set_collision_mask(3)
		speed += 200
		state_machine.travel("slide")
		$Player_area.shape.set_extents(Vector2(20,22))
		$Player_area.set_position(Vector2(0, 19))
func climb_animation():
	climbing = true
	state_machine.travel("climb")
	if not $Sprite.flip_h:
		$Tween.interpolate_property(self,"position", position, Vector2(position.x + 20, position.y - 60), 0.299)
	else:
		$Tween.interpolate_property(self,"position", position, Vector2(position.x - 20, position.y - 60), 0.299)
	$Tween.start()
	$Tween/Timer.start()

func hurt_animation():
	state_machine.travel("hurt")
#	if not $Sprite.flip_h:
#		$Tween.interpolate_property(self,"position", position, Vector2(position.x - 30, position.y), 0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
#	else:
#		$Tween.interpolate_property(self,"position", position, Vector2(position.x + 30, position.y), 0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
#	$Tween.start()
	#	add: tween para cambiar el color del player a rojo con la transicion bouncy, o atransparente para inmunidad
	$HealthBar.hp_change(10) #cambiar parametro por el daño del enemigo(valores positivos hacen daño, y viceversa para curar)
func death_animation():
	state_machine.travel("die")
	#endgame and respawn to an especific location (tween can do it...or tweentoo ...i think)
	pass


func get_input():
	velocity.x = 0

	var current_anim = state_machine.get_current_node()
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var crouch = Input.is_action_pressed("ui_down")
	var up = Input.is_action_pressed("ui_up")
	var jump = Input.is_action_just_pressed("jump")
	var slide = Input.is_action_just_pressed("slide")
	var attack = Input.is_action_just_pressed("attack")
	
	if Input.is_action_just_pressed("test_action"): #t to test the animation
		hurt_animation()
	
	if not crouching and not sliding and not attacking and not looking_up and not climbing:
		restore_playerProperty()

	if current_anim == "attack_1" or current_anim == "attack_2" or current_anim == "attack_3" or current_anim == "air_attack":
		$Area2D/attack_area1.disabled = false
		$Area2D/attack_area2.disabled = false
	else:
		$Area2D/attack_area1.disabled = true
		$Area2D/attack_area2.disabled = true
		
	if not crouch and attack_counter == 1 and $attack_delay.get_time_left() == 0 and not $Tween.is_active():
		player_movement(right, left)
		if velocity.length() == 0:
			idle_animation()
		elif velocity.x != 0 and not sliding and not attacking and not $Tween.is_active() and not climbing: 
			run_animation()
		
	if is_on_floor():
		if crouch:
			crouch_animation()

		else:
			crouching = false
			falling = false
			looking_up = false
			if attack_counter == 4:
				attack_counter = 1
			if attack:
				attack_animation()
			elif jump:
				do_jump()
			elif (slide) and (right or left) and (not crouch):
				slide_animation()
			elif up:
				looking_up = true
				if looking_up and $Camera2D/camera_timer.get_time_left() == 0 and $Camera2D.offset_v == 0:
					$Camera2D/camera_timer.start()
	elif  not sliding and not climbing:
		fall_animation()
		if falling and attack:
			air_attack_animation()
	if  not $ray_to_climb_3.is_colliding() and $ray_to_climb_2.is_colliding() and not $ray_to_climb.is_colliding() and (right or left) and not sliding:
		climb_animation()
	
func _physics_process(delta):

	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))

#------------------------------------------------------------conecctions
func _on_sliding_timeout():
	sliding = false
	restore_playerProperty()
func _on_slide_delay_timeout():
	pass

func _on_attack_delay_timeout():
	attack_counter = 1
func _on_attacking_1_timeout():
	attacking = false
func _on_attacking_2_timeout():
	attacking = false
func _on_attacking_3_timeout():
	attacking = false

func _on_camera_timer_timeout():
	if crouching:
		$Camera2D.offset_v = 0.5
	elif looking_up:
		$Camera2D.offset_v = -0.5

func _on_climb_timeout():
	climbing = false
