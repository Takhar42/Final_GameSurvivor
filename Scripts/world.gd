class_name World
extends Node


@export var boss_scene = preload("res://Scenes/boss.tscn")
@export var ghost_scene = preload("res://Scenes/ghost.tscn")
@export var tree_scene = preload("res://scenes/tree.tscn")
@export var rock_scene = preload("res://scenes/rock.tscn")
@export var sack_scene = preload("res://scenes/sack.tscn")
@export var anvil_scene = preload("res://scenes/anvil.tscn")

const PLAYER_START_POS := Vector2i(150, 510)
const CAM_START_POS := Vector2i(576, 324)
const GND_START_POS := Vector2i(0, 585)
#const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 10
const MAX_SPEED : int = 30
const SPEED_MODIFIER : int = 2500
const MAX_DIFFICULTY : int = 2
enum CutsceneType { INTRO, BOSS, VICTORY }

@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
@onready var boss = $Boss
@onready var displays = $Displays
@onready var restart = $GameOver
@onready var cutscene = $Cutscene
@onready var starting_audio : AudioStreamPlayer2D = $StartingAudio
@onready var running_audio : AudioStreamPlayer2D = $RunningAudio
@onready var boss_audio : AudioStreamPlayer2D = $BossAudio

var score : int
var max_score : int
var ground_height : int
var speed : float
var screen_size : Vector2i
var game_live : bool
var obstacle_types := [tree_scene, rock_scene, sack_scene, anvil_scene]
var ghost_heights := [335]
var obstacles: Array = []
var last_obs  # To track the last spawned obstacle
var boss_spawned = false
var difficulty : int
var intro_cutscene_shown = false


func _ready():
	screen_size = get_window().size
	ground_height = ground.get_node("Sprite2D").texture.get_height()

	cutscene.connect("cutscene_finished", _on_cutscene_finished)
	restart.get_node("Button").pressed.connect(init_game)
	if not intro_cutscene_shown:
		starting_audio.play()
		cutscene.show_cutscene(5.0, CutsceneType.INTRO)  # Modified to include type
		restart.hide()
	else:
		init_game()

func init_game():
	clear_all()
	get_tree().paused = false 
	score = 0
	game_live = false
	show_score()
	
	player.position = PLAYER_START_POS
	camera.position = CAM_START_POS
	ground.position = GND_START_POS
	
	restart.hide()
	displays.get_node("Start").show()
	if running_audio.playing:
		running_audio.stop()
	if boss_audio.playing:
		boss_audio.stop()
	starting_audio.play()

func _process(delta):
	if game_live and not boss_spawned:
		if not running_audio.playing:
			starting_audio.stop()
			running_audio.play()
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed >= MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		player.position.x += speed
		camera.position.x += speed
	
		score += speed
		show_score()
		
		# Generate and manage obstacles
		generate_obs()

		if score/15 == 1000:
			boss_spawned = true
			if not boss_audio.playing:
				running_audio.stop()
				boss_audio.play()
			cutscene.show_cutscene(4.0, CutsceneType.BOSS)
			clear_all()
			if player.is_alive == false:
				game_over()
			
		if camera.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x
	elif game_live == false:
		if Input.is_action_just_pressed("start"):
			if cutscene.visible:
				cutscene.skip_cutscene() 
			else:
				displays.get_node("Start").hide()
				game_live = true

func _on_cutscene_finished():
	intro_cutscene_shown = true
	if score / 15 == 1000:
		if is_instance_valid(boss):  # Check if boss still exists
			# Boss setup after cutscene
			boss.position.x = camera.position.x + 300
			boss.position.y = camera.position.y + 60
			# Add delay before boss can act
			await get_tree().create_timer(1.0).timeout
			boss.enable_actions()
	elif cutscene.current_type == CutsceneType.VICTORY:
		game_over()
	else:
		# Show start screen after intro cutscene
		displays.get_node("Start").show()

func generate_obs():
	# Only spawn if we have no obstacles or last one is far enough
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 50)
			last_obs = obs
			add_obs(obs, obs_x, 585)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = ghost_scene.instantiate()
				var obs_x = screen_size.x + score + 100
				var obs_y = ghost_heights[randi() % ghost_heights.size()]
				add_obs(obs, obs_x, obs_y)

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

func clear_all():
	for i in range (obstacles.size()):
		remove_obs(obstacles[obstacles.size() - 1])
		
func game_over():
	print("Game Over!")
	game_live = false
	boss_spawned = false
	get_tree().paused = true
	restart.show()

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func show_score():
	displays.get_node("Score").text = "Score: " + str(score/15)
	
func show_victory_cutscene():
	cutscene.show_cutscene(7.5, CutsceneType.VICTORY)
