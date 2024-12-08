extends Camera2D

@export var follow_speed = 5.0
@onready var target = $"../CharacterBody2D"

func _process(delta):
	position.x = lerp(position.x, target.position.x, follow_speed * delta)
	position.y = lerp(position.y, target.position.y, follow_speed * delta)
