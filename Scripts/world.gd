# world.gd
extends Node

@export var boss_scene = preload("res://Scenes/boss.tscn")

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 10
const MAX_SPEED : int = 100
enum CutsceneType { INTRO, BOSS }  # Add enum for cutscene types

@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
@onready var boss = $Boss
@onready var displays = $Displays
@onready var obstacles = $Obstacles
@onready var cutscene = $Cutscene

var score : int
var max_score : int
var ground_height : int
var speed : float
var screen_size : Vector2i
var game_live : bool
var obstacle_types := []
var obstacles_arr : Array = []
var last_obs  # To track the last spawned obstacle
var boss_spawned = false
var intro_cutscene_shown = false

func _ready():
	screen_size = get_window().size
	
	# Set up collision layers
	player.collision_layer = 0b001  # Player on layer 1
	player.collision_mask = 0b110   # Collide with layers 2 and 3 (ground and obstacles)
	
	ground.collision_layer = 0b010     # Ground on layer 2
	ground.collision_mask = 0b001      # Only collide with player
	
	# Get individual obstacle templates
	for sprite in obstacles.get_children():
		if sprite is Sprite2D:
			var template = obstacles.duplicate()  # Duplicate the Area2D
			# Remove all sprites except the current one
			for child in template.get_children():
				if child is Sprite2D and child.name != sprite.name:
					child.queue_free()
			obstacle_types.append(template)
			print("Added obstacle template: ", sprite.name)
			
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
	clear_all()
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
		cleanup_obstacles()

		if score/15 == 200:
			game_live = false
			clear_all()
			cutscene.show_cutscene(4.0, CutsceneType.BOSS)  # Modified to include type
			
		if camera.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x

func _on_cutscene_finished():
	intro_cutscene_shown = true
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
	var max_obstacles = randi() % 4 + 1
	if obstacles_arr.size() >= max_obstacles:
		return

	if obstacles_arr.is_empty() or (last_obs != null and last_obs.position.x < camera.position.x + randi_range(400, 600)):
		var obs = obstacle_types[0].duplicate()
		var obs_y : int = 600
		var obs_x : int = camera.position.x + screen_size.x
		
		last_obs = obs
		add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.collision_layer = 0b100
	obs.collision_mask = 0b001
	
	if obs.has_signal("area_entered"):
		print("Connecting area collision signal")
		obs.area_entered.connect(_on_obstacle_collision)
	if obs.has_signal("body_entered"):
		print("Connecting body collision signal")
		obs.body_entered.connect(_on_obstacle_collision)
	
	add_child(obs)
	obstacles_arr.append(obs)

func _on_obstacle_collision(area):
	print("Collision detected!")
	print("Collided with: ", area.name)
	print("Player position: ", player.position)
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
	init_game()

func show_score():
	displays.get_node("Score").text = "Score: " + str(score/15)
