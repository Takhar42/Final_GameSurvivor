extends CharacterBody2D

@export var speed: float = 200.0
@export var gravity: float = 500.0
@export var jump_force: float = -300.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
