class_name Damageable
extends Node

@export var health : float = 100

func hit(damage : int): 
	health -= damage
	
	if health <= 0:
		print(get_parent())
