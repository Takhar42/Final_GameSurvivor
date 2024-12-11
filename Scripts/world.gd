extends Node

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var score : int
var speed : float
const START_SPEED : float = 5
const MAX_SPEED : int = 100
var screen_size : Vector2i
var game_live : bool


func _ready():
	screen_size = get_window().size
	init_game()
	
func init_game():
	score = 0
	game_live = false
	$Node2D/CanvasLayer.get_node("Start").show()


func _process(delta):
	if game_live:
		speed = START_SPEED

		$Node2D/CharacterBody2D.position.x += speed 
		$Node2D/Camera2D.position.x += speed

		score += speed
		show_score()
		$Node2D/CanvasLayer.get_node("Score").text

		if $Node2D/Camera2D.position.x - $Node2D/StaticBody2D.position.x > screen_size.x * 1.5:
			$Node2D/StaticBody2D.position.x += screen_size.x
	else:
		if Input.is_action_just_pressed("ui_accept"):
			$Node2D/CanvasLayer.get_node("Start").hide()
			game_live = true


func show_score():
	$Node2D/CanvasLayer.get_node("Score").text = "Score: " + str(score/15)
