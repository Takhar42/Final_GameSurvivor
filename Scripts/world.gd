class_name World
extends Node


@export var boss_scene = preload("res://Scenes/boss.tscn")
@export var ghost_scene = preload("res://Scenes/ghost.tscn")

const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 10
const MAX_SPEED : int = 30
const SPEED_MODIFIER : int = 2500
const MAX_DIFFICULTY : int = 2
enum CutsceneType { INTRO, BOSS }  # Add enum for cutscene types

@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
@onready var boss = $Boss
@onready var displays = $Displays
@onready var restart = $GameOver
@onready var obstacles = $Obstacles
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
var obstacle_types := []
var ghost_heights := [350]
var obstacles_arr : Array = []
var last_obs  # To track the last spawned obstacle
var boss_spawned = false
var difficulty : int
var intro_cutscene_shown = false


func _ready():
	screen_size = get_window().size
		
	for sprite in obstacles.get_children():
		if sprite is Sprite2D:
			var template = obstacles.duplicate()
			for child in template.get_children():
				if child is Sprite2D and child.name != sprite.name:
					child.queue_free()
			obstacle_types.append(template)
			print("Added obstacle template: ", sprite.name)
	cutscene.connect("cutscene_finished", _on_cutscene_finished)
	restart.get_node("Button").pressed.connect(init_game)
	if not intro_cutscene_shown:
		starting_audio.play()
		cutscene.show_cutscene(5.0, CutsceneType.INTRO)  # Modified to include type
	else:
		init_game()

func init_game():
	get_tree().paused = false 
	score = 0
	game_live = false
	show_score()
	clear_all()
	
	player.position.x = camera.position.x - 400
	player.position.y = camera.position.y + 200
	
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
		cleanup_obstacles()

		if score/15 == 200:
			boss_spawned = true
			if not boss_audio.playing:
				running_audio.stop()
				boss_audio.play()
			clear_all()
			cutscene.show_cutscene(4.0, CutsceneType.BOSS)  # Modified to include type
			
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
	restart.hide()
	if score/15 == 200:
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
	# Check if we already have max obstacles
	var max_obstacles = randi() % 4 + 1  # This gives us 1-4
	if obstacles_arr.size() >= max_obstacles:
		return

	# Spawn condition - either no obstacles or last one is far enough behind
	if obstacles_arr.is_empty() or (last_obs != null and last_obs.position.x < camera.position.x + randi_range(400, 600)):
		var obs = obstacle_types[0].duplicate()
		var obs_y : int = 600
		var obs_x : int = camera.position.x + screen_size.x
		
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = ghost_scene.instantiate()
				obs_x = screen_size.x + score + 100
				obs_y = ghost_heights[randi() % ghost_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	
	# Set collision layer (layer 3) and mask (layer 1) for obstacles
	obs.collision_layer = 0b100  # Binary 100 = layer 3
	obs.collision_mask = 0b001   # Binary 001 = layer 1 (player)
	
	if obs.has_signal("area_entered"):
		#print("Connecting area collision signal")
		obs.area_entered.connect(_on_obstacle_collision)
	if obs.has_signal("body_entered"):
		#print("Connecting body collision signal")
		obs.body_entered.connect(_on_obstacle_collision)
	
	add_child(obs)
	obstacles_arr.append(obs)

func _on_obstacle_collision(area):
	#print("Collision detected!")
	#print("Collided with: ", area.name)
	#print("Player position: ", player.position)
	game_over()

func cleanup_obstacles():
	for obs in obstacles_arr:
		if obs.position.x < (camera.position.x - screen_size.x):
			remove_obs(obs)

func clear_all():
	for obs in obstacles_arr:
		obs.queue_free()
	obstacles_arr.clear()
		
func remove_obs(obs):
	if obs.has_signal("area_entered"):
		if obs.area_entered.is_connected(_on_obstacle_collision):
			obs.area_entered.disconnect(_on_obstacle_collision)
	obs.queue_free()
	obstacles_arr.erase(obs)

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
#func show_high_score():
	#displays.get_node("High Score").text = "High Score: " + str(score/15)
