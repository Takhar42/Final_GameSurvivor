# cutscene.gd
extends CanvasLayer

@export var cutscene_size: Vector2 = Vector2(1, 1)
@onready var texture_rect = $Control/TextureRect
@onready var timer = $Control/TextureRect/Timer
@onready var control = $Control

signal cutscene_finished

var cutscene_frames = []     # Array to hold all frames
var frame_durations = []     # Array to hold durations for each frame
var current_frame = 0        # Track current frame
var current_type = 0        # Track which type of cutscene is playing
enum CutsceneType { INTRO, BOSS }

func _ready():
	hide()  # Hide by default
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	var window_size = get_window().size
	# Make the control smaller than the window
	control.custom_minimum_size = window_size * 0.9  # 20% smaller
	control.size = window_size * 0.9
	
	# Center the control
	control.position = window_size * 0.05 # Offset to center
	
	get_tree().root.size_changed.connect(_on_window_resize)

func _on_window_resize():
	var new_size = get_window().size
	control.custom_minimum_size = new_size * 0.9
	control.size = new_size * 0.9
	control.position = new_size * 0.05

func load_cutscene_frames(type: int):
	cutscene_frames.clear()
	frame_durations.clear()
	
	match type:
		CutsceneType.INTRO:
			cutscene_frames.append(preload("res://assets/Cutscenes/titlescreen.png"))
			frame_durations.append(3.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene1.png"))
			frame_durations.append(2.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene2.png"))
			frame_durations.append(2.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene3.png"))
			frame_durations.append(3.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene4.png"))
			frame_durations.append(2.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene5.png"))
			frame_durations.append(2.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene6.png"))
			frame_durations.append(2.0)
			cutscene_frames.append(preload("res://assets/Cutscenes/cutscene7.png"))
			frame_durations.append(4.0)
			
		CutsceneType.BOSS:
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs1.png"))
			frame_durations.append(2.5)
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs2.png"))
			frame_durations.append(2.5)
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs3.png"))
			frame_durations.append(2.5)
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs4.png"))
			frame_durations.append(2.5)
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs5.png"))
			frame_durations.append(2.5)
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs6.png"))
			frame_durations.append(2.5)
			cutscene_frames.append(preload("res://assets/Cutscenes/bosscs7.png"))
			frame_durations.append(2.5)
			

func show_cutscene(duration: float = 5.0, type: int = CutsceneType.INTRO):
	current_type = type
	load_cutscene_frames(type)
	current_frame = 0
	show()
	show_frame()
	timer.wait_time = frame_durations[current_frame]
	timer.start()

func show_frame():
	if current_frame < cutscene_frames.size():
		texture_rect.texture = cutscene_frames[current_frame]

func _on_timer_timeout():
	current_frame += 1
	if current_frame < cutscene_frames.size():
		show_frame()
		timer.wait_time = frame_durations[current_frame]
		timer.start()
	else:
		hide()
		cutscene_finished.emit()

func skip_cutscene():
	if visible:
		timer.stop()
		hide()
		cutscene_finished.emit()
