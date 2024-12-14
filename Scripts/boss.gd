class_name Boss
extends CharacterBody2D

enum BossState { IDLE, WALK, ATTACK, STOP, DAMAGED, DEATH }
var state = BossState.IDLE
@export var health = 200
@export var move_speed = 100.0
@export var attack_range = 200.0
@export var attack_cooldown = 2.0
@export var action_sequence = ["attack","walk"]  # Preset sequence of moves
@export var action_duration = 3 # Time per action in seconds

@onready var sprite = $AnimatedSprite2D
@onready var cleaver = $cleaver
@onready var collision_shape = $CollisionShape2D
@onready var player = null
@onready var action_timer = Timer.new()
@onready var attack_timer = Timer.new()
@onready var world = null  # Reference to world node

var current_action_index = 0  # Track the current action in the sequence
var can_act = false  # Flag to control when boss can act

func _ready():
	# Add timers to the scene
	add_child(action_timer)
	add_child(attack_timer)
	action_timer.wait_time = action_duration
	action_timer.one_shot = true
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	# Connect the action timer to progress through the sequence
	action_timer.timeout.connect(self._on_action_timeout)
	action_timer.start()
	player = get_parent().get_node("Player")  # Locate the player in the scene tree
	world = get_parent()  # Get reference to world node
	sprite.play("idle")

func _physics_process(delta):
	if not can_act:  # Don't do anything if not allowed to act
		state = BossState.IDLE
		return
	match state:
		BossState.IDLE:
			pass  # Do nothing
		BossState.WALK:
			move_horizontally(delta)
		BossState.ATTACK:
			perform_attack()
		BossState.STOP:
			stop_movement()
		BossState.DAMAGED:
			sprite.play("damaged")
		BossState.DEATH:
			die()

func move_horizontally(delta):
	if not player:
		return  # Ensure the player node is valid
	# Move towards the player's x-position
	var distance = player.global_position.x - global_position.x + 100
	var direction = sign(distance)
	if (distance < 0 and distance > -150) or (distance > 0 and distance < 360):
		sprite.play("idle")
		return
	velocity.x = direction * move_speed
	if direction > 0:
		sprite.flip_h = true  # Face right
		cleaver.scale.x = -1
	else:
		sprite.flip_h = false   # Face left
		cleaver.scale.x = 1
	move_and_slide()
	sprite.play("walk")
	
func perform_attack():
	if not attack_timer.is_stopped():
		return
	sprite.play("attack")
	attack_timer.start()
	# Check for player in range and apply damage
	if player and position.distance_to(player.position) <= attack_range:
		player.take_damage(100)
	state = BossState.IDLE

func stop_movement():
	velocity = Vector2(0, 0)  # Stop horizontal movement
	sprite.play("idle")

func _on_action_timeout():
	if not can_act:  # Don't change state if not allowed to act
		return
		
	# Progress through the action sequence
	current_action_index = (current_action_index + 1) % action_sequence.size()
	var next_action = action_sequence[current_action_index]
	match next_action:
		"walk":
			state = BossState.WALK
		"attack":
			state = BossState.ATTACK
		"stop":
			state = BossState.STOP
	# Restart the action timer
	action_timer.start()

func take_damage(amount):
	print("damage")
	health -= amount
	sprite.play("damaged")
	if health <= 0:
		state = BossState.DEATH
		if world.has_method("show_victory_cutscene"):  # Added this check
			world.show_victory_cutscene()
	else:
		state = BossState.IDLE

func die():
	sprite.play("death")
	queue_free()

func enable_actions():
	can_act = true
	action_timer.start()

func disable_actions():
	can_act = false
	state = BossState.IDLE
	velocity = Vector2.ZERO
