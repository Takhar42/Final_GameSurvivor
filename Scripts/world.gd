extends Node


@export var boss_scene = preload("res://Scenes/boss.tscn")
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 5
const MAX_SPEED : int = 100
var score : int
var max_score : int
var ground_height : int
var speed : float
var screen_size : Vector2i
var game_live : bool
var obstacle_types := []
var obstacles : Array = []
var last_obs  # To track the last spawned obstacle
var boss_spawned = false


func _ready():
	screen_size = get_window().size
	
	# Set up collision layers
	$Node2D/Player.collision_layer = 0b001  # Player on layer 1
	$Node2D/Player.collision_mask = 0b110   # Collide with layers 2 and 3 (ground and obstacles)
	
	$Node2D/StaticBody2D.collision_layer = 0b010     # Ground on layer 2
	$Node2D/StaticBody2D.collision_mask = 0b001      # Only collide with player
	
	# Get individual obstacle templates
	var obstacles_parent = $Node2D/Area2D
	
	# Create separate Area2D templates for each sprite
	for sprite in obstacles_parent.get_children():
		if sprite is Sprite2D:
			var template = obstacles_parent.duplicate()  # Duplicate the Area2D
			# Remove all sprites except the current one
			for child in template.get_children():
				if child is Sprite2D and child.name != sprite.name:
					child.queue_free()
			obstacle_types.append(template)
			print("Added obstacle template: ", sprite.name)
	init_game()

func init_game():
	score = 0
	game_live = false
	
	# Clear any existing obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Node2D/CanvasLayer.get_node("Start").show()

func _process(delta):
	if game_live:
		speed = START_SPEED
		$Node2D/Player.position.x += speed 
		$Node2D/Camera2D.position.x += speed
		score += speed
		show_score()
		
		# Generate and manage obstacles
		generate_obs()
		cleanup_obstacles()

		if score/15 == 30:
			game_live = false
			$Node2D/Boss.position.x = $Node2D/Camera2D.position.x + 480
			$Node2D/Boss.position.y = $Node2D/Camera2D.position.y + 250
			
		if $Node2D/Camera2D.position.x - $Node2D/StaticBody2D.position.x > screen_size.x * 1.5:
			$Node2D/StaticBody2D.position.x += screen_size.x
	else:
		if Input.is_action_just_pressed("ui_accept"):
			$Node2D/CanvasLayer.get_node("Start").hide()
			game_live = true
	
func generate_obs():
	# Check if we already have max obstacles
	var max_obstacles = randi() % 4 + 1  # This gives us 1-4
	if obstacles.size() >= max_obstacles:
		return

	# Spawn condition - either no obstacles or last one is far enough behind
	if obstacles.is_empty() or (last_obs != null and last_obs.position.x < $Node2D/Camera2D.position.x + randi_range(400, 600)):
		var obs = obstacle_types[0].duplicate()
		var obs_y : int = 600
		var obs_x : int = $Node2D/Camera2D.position.x + screen_size.x
		
		last_obs = obs
		add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	
	# Set collision layer (layer 3) and mask (layer 1) for obstacles
	obs.collision_layer = 0b100  # Binary 100 = layer 3
	obs.collision_mask = 0b001   # Binary 001 = layer 1 (player)
	
	if obs.has_signal("area_entered"):
		print("Connecting area collision signal")
		obs.area_entered.connect(_on_obstacle_collision)
	if obs.has_signal("body_entered"):
		print("Connecting body collision signal")
		obs.body_entered.connect(_on_obstacle_collision)
	
	$Node2D.add_child(obs)
	obstacles.append(obs)

func _on_obstacle_collision(area):
	print("Collision detected!")
	print("Collided with: ", area.name)
	print("Player position: ", $Node2D/Player.position)
	game_over()

func cleanup_obstacles():
	for obs in obstacles:
		if obs.position.x < ($Node2D/Camera2D.position.x - screen_size.x):
			remove_obs(obs)

func remove_obs(obs):
	if obs.has_signal("area_entered"):
		if obs.area_entered.is_connected(_on_obstacle_collision):
			obs.area_entered.disconnect(_on_obstacle_collision)
	obs.queue_free()
	obstacles.erase(obs)

func game_over():
	print("Game Over!")
	game_live = false
	$Node2D/CanvasLayer.get_node("End").show()
	init_game()

func show_score():
	$Node2D/CanvasLayer.get_node("Score").text = "Score: " + str(score/15)
func show_high_score():
	$Node2D/CanvasLayer.get_node("High Score").text = "High Score: " + str(score/15)
