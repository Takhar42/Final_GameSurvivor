extends CharacterBody2D

enum BossState { IDLE, WALK, ATTACK, STOP, DAMAGED, DEATH }
var state = BossState.IDLE
@export var health = 100
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

var current_action_index = 0  # Track the current action in the sequence

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
	sprite.play("idle")

func _physics_process(delta):
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
	var direction = sign(player.position.x - position.x + 100)
	if abs(player.position.x - position.x + 100) < 80:
		sprite.play("idle")
		return
	velocity.x = direction * move_speed
	if direction > 0:
		sprite.flip_h = true  # Face right
		cleaver.scale.x = -1;
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
		player.take_damage(100)  # Assuming the player has a `take_damage` function
	state = BossState.IDLE

func stop_movement():
	velocity = Vector2(0, 0)  # Stop horizontal movement
	sprite.play("idle")

func _on_action_timeout():
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
	health -= amount
	sprite.play("damaged")
	if health <= 0:
		state = BossState.DEATH
	else:
		state = BossState.IDLE

func die():
	sprite.play("death")
	queue_free()
