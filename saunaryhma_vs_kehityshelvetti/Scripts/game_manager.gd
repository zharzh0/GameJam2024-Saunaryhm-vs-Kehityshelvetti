extends Node2D

@onready var _camera : Camera2D = $Camera2D
@onready var _player_character : CharacterBody2D = $Player1
@onready var _level : Area2D = $Level1
#@onready var _kivi_counter : Control = $UserInterface/KiviCounter
#@onready var _lives_counter : Control = $UserInterface/LivesCounter


func _ready():
	_init_boundaries()	

#	_init_ui()

func _init_boundaries():
	# get the level boundaries from the level
	var min_boundary : Vector2 = _level.get_min()
	var max_boundary : Vector2 = _level.get_max()
	# and tell them to the camera and player character
	_camera.set_bounds(min_boundary, max_boundary)
	_player_character.set_bounds(min_boundary, max_boundary)

#func _init_ui():
	#initialize the UI
#	_kivi_counter.set_value(File.data.kiuaskivet)
#	_lives_counter.set_value(File.data.lives)

func collect_kivi(value : int):
	File.data.kiuaskivet += value
	if File.data.kiuaskivet>= 100:
		File.data.kiuaskivet -= 100
		File.data.lives += 1
#		_lives_counter.set_value(File.data.lives)
#	_kivi_counter.set_value(File.data.kiuaskivet)

func collect_skull():
	File.data.lives += 1
#	_lives_counter.set_value(File.data.lives)
