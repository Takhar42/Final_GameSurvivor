extends CharacterBody2D

# Variables
@export var speed: float = 200.0
@export var gravity: float = 500.0
@export var jump_force: float = -300.0

# Called every frame
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Horizontal movement
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed

	# Jumping
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	# Move and slide
	move_and_slide()
