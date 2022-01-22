extends Node2D

export var flip: bool

func _ready():
	if flip:
		$AnimatedSprite.flip_h = true
	
