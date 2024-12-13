extends Camera2D

@export var follow_speed = 5.0
@onready var target = $"../CharacterBody2D"

var boss = null
var in_boss_fight = false

func lock_to_boss(boss_node):
	boss = boss_node
	in_boss_fight = true

func _process(delta):
	if in_boss_fight and boss:
		position = lerp(position, boss.position, follow_speed * delta)
	else:
		# Normal player tracking
		position.x = lerp(position.x, target.position.x, follow_speed * delta)
		position.y = lerp(position.y, target.position.y, follow_speed * delta)
