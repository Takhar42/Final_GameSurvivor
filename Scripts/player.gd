extends CharacterBody2D

@export var MOVE_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * MOVE_SPEED
	else:
		velocity.x = 0
	
	move_and_slide()
