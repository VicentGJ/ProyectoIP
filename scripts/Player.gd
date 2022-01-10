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
var looking_up = false
var climbing = false
var dead = false
var inmunity = false


onready var playerSprite = $Sprite
onready var climb_ray1 = $ray_to_climb
onready var climb_ray2 = $ray_to_climb_2
onready var climb_ray3 = $ray_to_climb_3
onready var climb_ray4 = $ray_to_climb_4
onready var playerCollision = $Player_area
onready var attackArea_1 = $Area2D/attack_area1
onready var attackArea_2 = $Area2D/attack_area2
onready var particles_slide = $slide_particles
onready var particles_death = $death_particles

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
func restore_playerProperty():
	playerCollision.shape.set_extents(Vector2(19.5,36)) #restaurar tamaño de la collision shape
	playerCollision.set_position(Vector2(0.5, 6))       #restaurar posicion de la collision shape
	playerCollision.disabled = false                  #reactivar collision shape
	speed = 200                                    #restaurar velocidad 
	gravity = 900
	
	$Camera2D.set_v_offset(0)                         #restaurar camara en Y
	
	set_collision_layer(1)                         #restaurar capa de collision del personaje
	set_collision_mask(1)                          #restaurar mascara de collision del personaje
	
	climb_ray1.set_collision_mask(1)            #restaurar mascara de collision de los raycast
	climb_ray2.set_collision_mask(1)
	climb_ray3.set_collision_mask(1)
	
	if not playerSprite.flip_h:                    #ajustar los raycast para el climb
		climb_ray1.set_cast_to(Vector2(21.5,-34.5))
		climb_ray2.set_cast_to(Vector2(22,-25))
		climb_ray3.set_cast_to(Vector2(30,-90))
		$Camera2D.set_h_offset(300)                    #restaurar camara en X
		particles_slide.set_position(Vector2(-12,39))
	else:
		climb_ray1.set_cast_to(Vector2(-21.5,-34.5))
		climb_ray2.set_cast_to(Vector2(-22,-25))
		climb_ray3.set_cast_to(Vector2(-30,-90))
		$Camera2D.set_h_offset(-300) 
		particles_slide.set_position(Vector2(6,39)) 
func player_movement(right, left):
	if not sliding:
		if right:
			velocity.x += speed
		elif left:
			velocity.x -= speed
	else:
		if not playerSprite.flip_h:
			velocity.x += speed+200
		else:
			velocity.x -= speed+200
		if is_on_wall():
			if  playerSprite.flip_h:
				$Tween.interpolate_property(self,"position", position,Vector2(position.x+1, position.y),$sliding.get_time_left(),Tween.TRANS_LINEAR)
			else:
				$Tween.interpolate_property(self,"position", position,Vector2(position.x-1, position.y),$sliding.get_time_left(),Tween.TRANS_LINEAR)
			$Tween.start()
func run_animation():
	playerSprite.flip_h = velocity.x < 0
	state_machine.travel("run")
func idle_animation():
	state_machine.travel("idle")
func crouch_animation():
	crouching = true
	state_machine.travel("crouch")
	playerCollision.shape.set_extents(Vector2(19.5,26.5))
	playerCollision.set_position(Vector2(0.5, 15.5))
	if $Camera2D/camera_timer.get_time_left() == 0 and $Camera2D.offset_v == 0:
		$Camera2D/camera_timer.start()
func attack_animation():
	attacking = true
	if attack_counter == 1 and $attack_delay.get_time_left() == 0:
		if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(16.5,38.5))
			attackArea_2.shape.set_extents(Vector2(13,7))
			attackArea_1.set_position(Vector2(36.5,-5.5)) 
			attackArea_2.set_position(Vector2(7,-37))
		else:
			attackArea_1.shape.set_extents(Vector2(17,38.5))
			attackArea_2.shape.set_extents(Vector2(14.5,7))
			attackArea_1.set_position(Vector2(-36,-5.75)) 
			attackArea_2.set_position(Vector2(-4.5,-37))
		state_machine.travel("attack_1")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_1.start()
	elif attack_counter == 2 and $attack_delay.get_time_left() < 0.5:
		if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(15.5,35))
			attackArea_2.shape.set_extents(Vector2(16,12))
			attackArea_1.set_position(Vector2(35.5,7)) 
			attackArea_2.set_position(Vector2(-35,25))
		else:
			attackArea_1.shape.set_extents(Vector2(16,35))
			attackArea_2.shape.set_extents(Vector2(15.5,11.5))
			attackArea_1.set_position(Vector2(-35,7)) 
			attackArea_2.set_position(Vector2(35.5,24.5))
		state_machine.travel("attack_2")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_2.start()
	elif attack_counter == 3 and $attack_delay.get_time_left() < 0.65:
		if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(17.5,20.5))
			attackArea_2.shape.set_extents(Vector2(18,14.5))
			attackArea_1.set_position(Vector2(37.5,15.5)) 
			attackArea_2.set_position(Vector2(-37,18.5))
		else:
			attackArea_1.shape.set_extents(Vector2(18,21.5))
			attackArea_2.shape.set_extents(Vector2(18,16.5))
			attackArea_1.set_position(Vector2(-37,14.5)) 
			attackArea_2.set_position(Vector2(38,20.75))
		state_machine.travel("attack_3")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_3.start()
func air_attack_animation():
	state_machine.travel("air_attack")
	if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(15.5,35))
			attackArea_2.shape.set_extents(Vector2(16,12))
			attackArea_1.set_position(Vector2(35.5,7)) 
			attackArea_2.set_position(Vector2(-35,25))
	else:
			attackArea_1.shape.set_extents(Vector2(16,35))
			attackArea_2.shape.set_extents(Vector2(15.5,11.5))
			attackArea_1.set_position(Vector2(-35,7)) 
			attackArea_2.set_position(Vector2(35.5,24.5))
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
		climb_ray1.set_collision_mask(3) #cambiar la capa y mascara de colision de los ray
		climb_ray2.set_collision_mask(3)
		climb_ray3.set_collision_mask(3)
		state_machine.travel("slide")
		playerCollision.shape.set_extents(Vector2(20,22))
		playerCollision.set_position(Vector2(0, 19))
		particles_slide.set_emitting(true)
func climb_animation():
	climbing = true
	state_machine.travel("climb")
	if not playerSprite.flip_h:
		$Tween.interpolate_property(self,"position", position, Vector2(position.x + 20, position.y - 60), 0.299)
	else:
		$Tween.interpolate_property(self,"position", position, Vector2(position.x - 20, position.y - 60), 0.299)
	$Tween.start()
	$Tween/climbing_timer.start()

func hurt_animation():
	state_machine.travel("hurt")
	$Tween.interpolate_property(playerSprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.5,Tween.TRANS_BOUNCE,Tween.EASE_OUT_IN)
	$Tween.start()
	$Tween/inmunity_timer.start()
	inmunity = true
	set_collision_layer(2) #cambiar la capa y mascara de colision del player( inmunidad)
	set_collision_mask(2)

func death_animation():
	state_machine.travel("die")
	particles_death.set_emitting(true)
	dead = true
	if not is_on_floor():
		move_and_collide(Vector2(0,10)) #para si muere en el aire no se quede flotando

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
		$HealthBar.hp_change(10) #cambiar por la señal de colision de daño o curacion [ > 0 damage, < 0 heal ]t
	
	if not crouching and not sliding and not attacking and not looking_up and not climbing and not inmunity:
		restore_playerProperty()
		

	if current_anim == "attack_1" or current_anim == "attack_2" or current_anim == "attack_3" or current_anim == "air_attack":
		attackArea_1.disabled = false
		attackArea_2.disabled = false
	else:
		attackArea_1.disabled = true
		attackArea_2.disabled = true
		
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
	if  not climb_ray4.is_colliding() and not climb_ray3.is_colliding() and climb_ray2.is_colliding() and not climb_ray1.is_colliding() and (right or left) and not sliding:
		climb_animation()
	
func _physics_process(delta):
	
	if not dead:
		get_input()
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		
#		respawn etc
#		dead = false ( maybe after a timer so the animations can happen...or maybe when user press a button)
		pass

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

func _on_climbing_timer_timeout():
		climbing = false

func _on_health_under_value_changed(value):
	if value == 0:

		death_animation() 
func _on_health_over_value_changed(value):
	if value > 0: 
		hurt_animation()
	elif value < 0:
#		maybe add healing particles
		pass
func _on_inmunity_timer_timeout():
	inmunity = false
	set_collision_layer(1) #cambiar la capa y mascara de colision del player( inmunidad)
	set_collision_mask(1)
