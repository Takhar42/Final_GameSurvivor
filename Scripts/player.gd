# player.gd 
extends CharacterBody2D

@export var MOVE_SPEED: float = 250.0
@export var JUMP_VELOCITY: float = -500.0
@export var HEALTH: float = 100
@export var ATTACK_RANGE: float = 200.0  # Add attack range like boss has
@onready var sword = $sword
@onready var sword_collision = $sword/SwordCollisionShape2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_audio: AudioStreamPlayer2D
var is_attacking = false

func _ready():
	jump_audio = $JumpAudio
	$AnimatedSprite2D.play("idle")
	sword_collision.disabled = true

func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		$CollisionShape2D.disabled = false
		if Input.is_action_pressed("ui_accept"):
			$AnimatedSprite2D.play("idle")
			
		elif Input.is_action_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("jump")
			jump_audio.play()
			
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("slide")
			$CollisionShape2D.disabled = true
			
		elif Input.is_action_pressed("sword"):
			perform_attack()
			
		else:
			$AnimatedSprite2D.play("run")
			is_attacking = false

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		$AnimatedSprite2D.flip_h = direction < 0
		if direction < 0:
			sword.scale.x = -1
		else:
			sword.scale.x = 1
		velocity.x = direction * MOVE_SPEED
	else:
		velocity.x = 0
	
	move_and_slide()

# Add perform_attack function similar to boss
func perform_attack():
	$AnimatedSprite2D.play("attack")
	is_attacking = true
	
	# Get reference to boss
	var boss = get_parent().get_node("Boss")
	if boss and position.distance_to(boss.position) <= ATTACK_RANGE:
		boss.take_damage(25)

func take_damage(amount):
	HEALTH -= amount
	if HEALTH <= 0:
		die()

func die():
	print("Player defeated!")
