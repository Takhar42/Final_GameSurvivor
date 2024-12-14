# world.gd
extends Node

@export var boss_scene = preload("res://Scenes/boss.tscn")
var tree_scene = preload("res://scenes/tree.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var sack_scene = preload("res://scenes/sack.tscn")
var anvil_scene = preload("res://scenes/anvil.tscn")

const PLAYER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
const GND_START_POS := Vector2i(0, 585)
const START_SPEED : float = 10
const MAX_SPEED : int = 100
enum CutsceneType { INTRO, BOSS }  # Add enum for cutscene types

@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
@onready var boss = $Boss
@onready var displays = $Displays
@onready var cutscene = $Cutscene

var score : int
var max_score : int
var ground_height : int
var speed : float
var screen_size : Vector2i
var game_live : bool
var obstacle_types := [tree_scene, rock_scene, sack_scene, anvil_scene]
var obstacles : Array
var last_obs  # To track the last spawned obstacle
var boss_spawned = false
var intro_cutscene_shown = false

func _ready():
	
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()

	# Setup cutscene
	cutscene.connect("cutscene_finished", _on_cutscene_finished)
	
	# Start with cutscene
	displays.get_node("Start").hide()  # Hide start display initially
	if not intro_cutscene_shown:
		cutscene.show_cutscene(5.0, CutsceneType.INTRO)  # Modified to include type
	else:
		init_game()

func init_game():
	score = 0
	game_live = false
	get_tree().paused = false
	
	$Player.position = PLAYER_START_POS
	$Camera2D.position = CAM_START_POS
	$Ground.position = GND_START_POS
	displays.get_node("Start").show()

func _process(delta):
	if not game_live:
		if Input.is_action_just_pressed("ui_accept"):
			if cutscene.visible:
				cutscene.skip_cutscene()  # Skip cutscene if it's playing
			else:
				displays.get_node("Start").hide()
				game_live = true
	
	if game_live:
		speed = START_SPEED
		player.position.x += speed
		camera.position.x += speed
		score += speed
		show_score()
		
		generate_obs()

		if score/15 == 500:
			game_live = false
			cutscene.show_cutscene(4.0, CutsceneType.BOSS)  # Modified to include type
			
		if camera.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x

func _on_cutscene_finished():
	intro_cutscene_shown = true
	if score/15 == 500:
		# Boss setup after cutscene
		boss.position.x = camera.position.x + 300
		boss.position.y = camera.position.y + 60
		# Add delay before boss can act
		await get_tree().create_timer(1.0).timeout
		boss.enable_actions()  # Enable boss actions after delay
	else:
		# Show start screen after intro cutscene
		displays.get_node("Start").show()

func generate_obs():
	# Only spawn if we have no obstacles or last one is far enough
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = 3
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 50)
			last_obs = obs
			add_obs(obs, obs_x, 585)

func add_obs(obs, x, y):
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func hit_obs(body):
	if body.name == "Player":
		game_over()


func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)


func game_over():
	print("Game Over!")
	get_tree().paused = true
	game_live = false
	init_game()

func show_score():
	displays.get_node("Score").text = "Score: " + str(score/15)
#func show_high_score():
	#displays.get_node("High Score").text = "High Score: " + str(score/15)
