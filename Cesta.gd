extends KinematicBody2D

export (int) var speed = 200
var limit
var velocity = Vector2()

func _ready():
	limit = get_viewport_rect().size #take the game-window size

func keep_in_screen():
	position.x = clamp(position.x, 30, limit.x - 30) #make shure trash can doesnt go off the screen

func get_input():
	velocity = Vector2.ZERO
	if Input.is_key_pressed(KEY_RIGHT):
		velocity.x += 1
	if Input.is_key_pressed(KEY_LEFT):
		velocity.x -= 1

	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	keep_in_screen()
	velocity = move_and_slide(velocity)
