extends KinematicBody2D

# Variables
var velocity = Vector2(0, 0)
var speed = 200
var gravity = 500
var jump_force = -300
var is_jumping = false

# Called every frame
func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	
	# Horizontal movement
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	else:
		velocity.x = 0

	# Jumping
	if Input.is_action_just_pressed("ui_up") and not is_jumping:
		velocity.y = jump_force
		is_jumping = true

	# Check for ground
	if is_on_floor():
		is_jumping = false
	
	# Move and slide
	velocity = move_and_slide(velocity, Vector2.UP)
