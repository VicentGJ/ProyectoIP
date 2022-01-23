extends KinematicBody2D

export (int) var speed = 200
export (int) var jump_speed = -450
export (int) var gravity = 900
export (int) var attack_mov = 8
export (int) var attackDamage = 20

var velocity = Vector2()
var state_machine
var attack_counter = 1
var sliding = false
var crouching = false
var attacking = false
var falling = false
var climbing = false
var dead = false
var inmunity = false
var dimension = 1
var money  = 0
var keys = [0,0]

onready var animationPlayer = $AnimationPlayer
onready var playerSprite = $Sprite
onready var climb_ray1 = $ray_to_climb
onready var climb_ray2 = $ray_to_climb_2
onready var climb_ray3 = $ray_to_climb_3
onready var climb_ray4 = $ray_to_climb_4
onready var slide_ray1 = $ray_to_slide
onready var slide_ray2 = $ray_to_slide_2
onready var slide_ray3 = $ray_to_slide_3
onready var playerCollision = $Player_area
onready var attackArea_1 = $Area2D/attack_area1
onready var attackArea_2 = $Area2D/attack_area2
onready var particles_slide = $slide_particles
onready var particles_death = $death_particles
onready var flash = $flash
onready var dimension1: Node2D = get_parent().get_node("Dimension1")
onready var dimension2: Node2D = get_parent().get_node("Dimension2")

signal healthChange(value)
signal dead()
signal damage(attackDamage,enemy)
signal maxHPincrease(amount)
signal getMoney(amount)
signal getKey(keyType, keyAmount)

func _ready():
	dimension2.set_position(Vector2(0, 1000))
	
	state_machine = $AnimationTree.get("parameters/playback")
	
func changeDimension():
	$Camera2D.set_enable_follow_smoothing(false)
	$Tween.interpolate_property(flash, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.5,Tween.TRANS_BOUNCE)
	$Tween.start()
	
	if dimension == 1:
		dimension = 2
		dimension1.set_position(Vector2(0, 1000))
		dimension2.set_position(Vector2(0, 0))
	elif dimension == 2:
		dimension = 1
		dimension2.set_position(Vector2(0, 1000))
		dimension1.set_position(Vector2(0, 0))
		get_parent().add_child_below_node(get_parent().get_node("GUI") , dimension1)
		
		
	$Tween.interpolate_property(flash, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 0.5,Tween.TRANS_BOUNCE)
	$Tween.start()
func restore_playerProperty():
	if not slide_ray1.is_colliding() and not slide_ray2.is_colliding() and not slide_ray3.is_colliding():
		playerCollision.shape.set_extents(Vector2(19.5,36)) #restaurar tamaño de la collision shape
		playerCollision.set_position(Vector2(0.5, 6))       #restaurar posicion de la collision shape
	elif is_on_floor():
		if not playerSprite.flip_h:
			position.x += 10
		else:
			position.x -= 10
	playerCollision.disabled = false                  #reactivar collision shape
	speed = 200                                    #restaurar velocidad 
	gravity = 900
	
	$Camera2D.set_v_offset(0)                         #restaurar camara en Y
	
	set_collision_layer(1)                         #restaurar capa de collision del personaje
	set_collision_mask(1)                          #restaurar mascara de collision del personaje
	
	climb_ray1.set_collision_mask(1)            #restaurar mascara de collision de los raycast
	climb_ray2.set_collision_mask(1)
	climb_ray3.set_collision_mask(1)
	climb_ray4.set_collision_mask(1)

	if not playerSprite.flip_h:                    #ajustar los raycast para el climb
		climb_ray1.set_cast_to(Vector2(22,0))
		climb_ray2.set_cast_to(Vector2(22,0))
		climb_ray3.set_cast_to(Vector2(30,-90))
		$Camera2D.set_h_offset(300)                    #restaurar camara en X
		particles_slide.set_position(Vector2(-12,39))
	else:
		climb_ray1.set_cast_to(Vector2(-22,0))
		climb_ray2.set_cast_to(Vector2(-22,0))
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
func attack_animation():
	attacking = true
	if attack_counter == 1 and $attack_delay.get_time_left() == 0:
		if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(16.5,38.5))
			attackArea_2.shape.set_extents(Vector2(13,7))
			attackArea_1.set_position(Vector2(36.5,-5.5)) 
			attackArea_2.set_position(Vector2(7,-37))
			position.x += attack_mov
		else:
			attackArea_1.shape.set_extents(Vector2(17,38.5))
			attackArea_2.shape.set_extents(Vector2(14.5,7))
			attackArea_1.set_position(Vector2(-36,-5.75)) 
			attackArea_2.set_position(Vector2(-4.5,-37))
			position.x -= attack_mov
		state_machine.travel("attack_1")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_1.start()
		emit_signal("damage",attackDamage)
	elif attack_counter == 2 and $attack_delay.get_time_left() < 0.5:
		if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(15.5,35))
			attackArea_2.shape.set_extents(Vector2(16,12))
			attackArea_1.set_position(Vector2(35.5,7)) 
			attackArea_2.set_position(Vector2(-35,25))
			position.x += attack_mov
		else:
			attackArea_1.shape.set_extents(Vector2(16,35))
			attackArea_2.shape.set_extents(Vector2(15.5,11.5))
			attackArea_1.set_position(Vector2(-35,7)) 
			attackArea_2.set_position(Vector2(35.5,24.5))
			position.x -= attack_mov
		state_machine.travel("attack_2")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_2.start()
		emit_signal("damage",attackDamage)
	elif attack_counter == 3 and $attack_delay.get_time_left() < 0.65:
		if playerSprite.flip_h == false:
			attackArea_1.shape.set_extents(Vector2(17.5,20.5))
			attackArea_2.shape.set_extents(Vector2(18,14.5))
			attackArea_1.set_position(Vector2(37.5,15.5)) 
			attackArea_2.set_position(Vector2(-37,18.5))
			position.x += attack_mov
		else:
			attackArea_1.shape.set_extents(Vector2(18,21.5))
			attackArea_2.shape.set_extents(Vector2(18,16.5))
			attackArea_1.set_position(Vector2(-37,14.5)) 
			attackArea_2.set_position(Vector2(38,20.75))
			position.x -= attack_mov
		state_machine.travel("attack_3")
		attack_counter += 1
		$attack_delay.start()
		$Area2D/attacking_3.start()
		emit_signal("damage",attackDamage)
func air_attack_animation():
	state_machine.travel("air_attack")
	if not playerSprite.flip_h:
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
	animationPlayer.play("jump")
func fall_animation():
	state_machine.travel("fall")
func slide_animation():
	if $slide_delay.get_time_left() == 0 and $attack_delay.get_time_left() == 0:
		sliding = true
		$sliding.start()
		$slide_delay.start()
		set_collision_layer(2) #cambiar la capa y mascara de colision del player
		set_collision_mask(2)
		climb_ray1.set_collision_mask(2) #cambiar la capa y mascara de colision de los ray
		climb_ray2.set_collision_mask(2)
		climb_ray3.set_collision_mask(2)
		state_machine.travel("slide")
		playerCollision.shape.set_extents(Vector2(20,22))
		playerCollision.set_position(Vector2(0, 19))
		particles_slide.set_emitting(true)
func climb_animation():
	climbing = true
	state_machine.travel("climb")
	$Tween.interpolate_property(self,"position", position, Vector2(position.x, position.y - 50), 0.2)
	$Tween.start()
	$Tween/climbing_timer.start()
func hurt_animation():
	state_machine.travel("hurt")
	$Tween.interpolate_property(playerSprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.5,Tween.TRANS_BOUNCE)
	$Tween.start()
	$Tween/inmunity_timer.start()
	inmunity = true
	set_collision_layer(2) #cambiar la capa y mascara de colision del player( inmunidad)
	set_collision_mask(2)
func death_animation():
	state_machine.travel("die")
	particles_death.set_emitting(true)
	dead = true
	emit_signal("dead")
	#menu
	var menu=load("res://control/gameOver.tscn").instance()
	get_parent().get_node("GUI").add_child(menu)
func add_money(addedMoney):
	money += addedMoney
	emit_signal("getMoney", money)
	animationPlayer.play("collectCoin")
func changeKeys(keyType, amount):
	if keyType == 0:
		keys[0] += amount
		emit_signal("getKey",0,amount)
	else:
		keys[1] += amount
		emit_signal("getKey",1,amount)
func changeStats(item, value):
	if item == 0:
		emit_signal("healthChange", -value)
	elif item == 1:
		emit_signal("maxHPincrease", value)
	else:
		attackDamage += value
	
func get_input():
	
	#pause
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().set_pause(true)
		var menu=load("res://control/pause.tscn").instance()
		get_parent().get_node("GUI").add_child(menu)
		
		
	velocity.x = 0
	
	var current_anim = state_machine.get_current_node()
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var crouch = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_just_pressed("jump")
	var slide = Input.is_action_just_pressed("slide")
	var attack = Input.is_action_just_pressed("attack")
	var change_dimension = Input.is_action_just_pressed("flash")

	if change_dimension and not climbing and not sliding and not $Tween.is_active():
		changeDimension()
	
	if not crouching and not sliding and not attacking and not climbing and not inmunity:
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
		if ($enemyCheck.get_collider() in get_tree().get_nodes_in_group("enemies") or $enemyCheck2.get_collider() in get_tree().get_nodes_in_group("enemies")) and not sliding:
			if not playerSprite.flip_h:
				position.x += 10
			else:
				position.x -= 10
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

	elif  not sliding and not climbing:
		if falling:
			fall_animation()
			
		falling = true
		if falling and attack:
			air_attack_animation()
	
	if  not climb_ray4.is_colliding() and not climb_ray3.is_colliding() and climb_ray2.is_colliding() \
	and not climb_ray1.is_colliding() and not (climb_ray2.get_collider() in get_tree().get_nodes_in_group("enemies"))\
	and (right or left) and not sliding:
		climb_animation()
		
func _physics_process(delta):
	if not dead:
		get_input()
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		move_and_collide(Vector2(0,10))

#------------------------------------------------------------conections
#movements
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

func _on_climbing_timer_timeout():
	if not playerSprite.flip_h:
		$Tween.interpolate_property(self,"position", position, Vector2(position.x + 20, position.y), 0.1)
	else:
		$Tween.interpolate_property(self,"position", position, Vector2(position.x - 20, position.y), 0.1)
	$Tween.start()
	climbing = false

func _on_inmunity_timer_timeout():
	inmunity = false
	set_collision_layer(1) #reset la capa y mascara de colision del player(quitar inmunidad)
	set_collision_mask(1)
	
func _on_DimensionChange_tween_completed(_object, _key):
	$Camera2D.set_enable_follow_smoothing(true)

#damage to player
func _on_HealthBar_damaged(currentHP):
	if currentHP != 0:
		hurt_animation()
	if currentHP == 0:
		death_animation() 

func _on_trap_trapTriggered(damage):
	emit_signal("healthChange",damage)

#pickups
func _on_heal_item_heal(healAmount):
	emit_signal("healthChange",healAmount)
func _on_maxHP_powerUP_increaseMaxHP(amount):
	emit_signal("maxHPincrease", amount)
	emit_signal("healthChange",-amount)
func _on_attackIncrease_increaseAttack(amount):
	attackDamage += amount
	
func _on_keyRegular_collected():
	keys[0] += 1
	emit_signal("getKey", 0, 1)
func _on_keyRare_collected():
	keys[1] += 1
	emit_signal("getKey", 1, 1)
	
func _on_Area2D_body_entered(body):
	if body in get_tree().get_nodes_in_group("enemies"):
		body.recieveDamage(attackDamage)


func _on_HUD_damaged(currentHP):
	if currentHP != 0:
		hurt_animation()
	if currentHP == 0:
		death_animation() 
