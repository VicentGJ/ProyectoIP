extends KinematicBody2D

export (int) var speed = 200
var limit
var velocity = Vector2()

func _ready():
	limit = get_viewport_rect().size #take the game-window size, takes a vector2() value.

func keep_in_screen():
	position.x = clamp(position.x, 30, limit.x - 30) #make sure trash bucket doesnt go off the screen left and right sides

func get_input(): #move the trash bucket only to the sides
	velocity = Vector2() #restart velocity value to x = 0 and y = 0
	
	if Input.is_key_pressed(KEY_RIGHT):
		velocity.x += 1
	elif Input.is_key_pressed(KEY_LEFT):
		velocity.x -= 1
	
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	keep_in_screen()
	get_input()
	velocity = move_and_slide(velocity)
