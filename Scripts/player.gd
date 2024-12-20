class_name Player
extends CharacterBody2D

@export var MOVE_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -900.0
@export var HEALTH: float = 100
@export var ATTACK_RANGE: float = 200.0


const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800 

@onready var sword = $sword
@onready var sword_collision = $sword/SwordCollisionShape2D

var jump_audio: AudioStreamPlayer2D
var is_attacking = false
var is_alive = true

func _ready():
	jump_audio = $JumpAudio # Initialize jump_audio properly here
	$AnimatedSprite2D.play("idle")  # Default to idle animation
	sword_collision.disabled = true

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if not get_parent().boss_spawned:
		if not get_parent().game_live:
			$AnimatedSprite2D.play("idle")
		else:
			$CollisionShape2D.disabled = false
			movement_logic("run")
	else:
		movement_logic("idle")

func movement_logic(animation : String):
	if is_on_floor():
		if Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("slide")
			$CollisionShape2D.disabled = true
		elif Input.is_action_pressed("sword"):
			perform_attack()
		elif Input.is_action_just_pressed("jump"):
			$AnimatedSprite2D.play("jump")
			jump_audio.play()
			velocity.y = JUMP_VELOCITY
		elif velocity.x != 0:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play(animation)
	sprite_state()
	
func sprite_state():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		$AnimatedSprite2D.flip_h = direction < 0
		if direction < 0:
			sword.scale.x = -1;
		else:
			sword.scale.x = 1;
		velocity.x = direction * MOVE_SPEED
	else:
		velocity.x = 0
	
	move_and_slide()
	
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
	is_alive = false;
