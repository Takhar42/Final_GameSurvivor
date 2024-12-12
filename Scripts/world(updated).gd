extends Node

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

const START_SPEED : float = 5.0
const MAX_SPEED : int = 100
const SCORE_DIVISOR : float = 15.0

var score : int  
var speed : float
var screen_size : Vector2i
var game_live : bool


func _ready():
	screen_size = get_window().size
	init_game()
	
func init_game():
	score = 0
	speed = START_SPEED
	game_live = false
	$Node2D/CanvasLayer.get_node("Start").show()
	$Node2D/CharacterBody2D.position = DINO_START_POS
	$Node2D/Camera2D.position = CAM_START_POS


func _process(delta):
	if game_live:
		if speed < MAX_SPEED:
			speed += 0.01 * delta 

		$Node2D/CharacterBody2D.position.x += speed 
		$Node2D/Camera2D.position.x += speed

		score += int(speed)  
		show_score()

		if $Node2D/Camera2D.position.x - $Node2D/StaticBody2D.position.x > screen_size.x * 1.5:
			$Node2D/StaticBody2D.position.x += screen_size.x
	else:
		if Input.is_action_just_pressed("ui_accept"):
			$Node2D/CanvasLayer.get_node("Start").hide()
			game_live = true


func show_score():
	$Node2D/CanvasLayer.get_node("Score").text = "Score: " + str(score / SCORE_DIVISOR)
