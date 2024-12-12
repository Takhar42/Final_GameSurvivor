extends CharacterBody2D

@export var MOVE_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_audio: AudioStreamPlayer2D

func _ready():
	jump_audio = $JumpAudio  # Initialize jump_audio properly here

func _physics_process(delta):
	
	velocity.y += gravity * delta
	if is_on_floor():
		$CollisionShape2D.disabled = false
		if Input.is_action_pressed("ui_accept"):
			$AnimatedSprite2D.play("run")
			# $JumpSound.play()
			
		elif Input.is_action_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("jump")
			
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("slide")
			$CollisionShape2D.disabled = true
			
		elif Input.is_action_pressed("attack"):
			$AnimatedSprite2D.play("attack")
			
		else:
			$AnimatedSprite2D.play("run")


	move_and_slide()
