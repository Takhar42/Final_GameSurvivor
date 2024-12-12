extends CharacterBody2D

@export var MOVE_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -600.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump_audio: AudioStreamPlayer2D
func _ready():
	jump_audio = $JumpAudio # Initialize jump_audio properly here

func _physics_process(delta):

	velocity.y += gravity * delta
	if is_on_floor():
		$CollisionShape2D.disabled = false
		if Input.is_action_pressed("ui_accept"):
			$AnimatedSprite2D.play("run")
			
		elif Input.is_action_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("jump")
			jump_audio.play()

			
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("slide")
			$CollisionShape2D.disabled = true
			
		elif Input.is_action_pressed("sword"):
			$AnimatedSprite2D.play("sword")
			
		else:
			$AnimatedSprite2D.play("run")
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
