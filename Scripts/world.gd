extends Node

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var speed : float
const START_SPEED : float = 5
const MAX_SPEED : int = 100
var screen_size : Vector2i

func _ready():
	screen_size = get_window().size


func _process(delta):
	speed = START_SPEED
	
	$Node2D/CharacterBody2D.position.x += speed 
	$Node2D/Camera2D.position.x += speed
	
	if $Node2D/Camera2D.position.x - $Node2D/StaticBody2D.position.x > screen_size.x * 1.5:
		$Node2D/StaticBody2D.position.x += screen_size.x
