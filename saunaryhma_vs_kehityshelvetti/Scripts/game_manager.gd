extends Node2D

@onready var _camera : Camera2D = $Camera2D
@onready var _player_character : CharacterBody2D = $Player1
@onready var _level : Area2D = $Level1
#@onready var _coin_counter : Control = $UserInterface/CoinCounter
#@onready var _lives_counter : Control = $UserInterface/LivesCounter


func _ready():
	pass
#	_init_boundaries()	
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
#	_coin_counter.set_value(File.data.coins)
#	_lives_counter.set_value(File.data.lives)

func collect_coin(value : int):
	File.data.coins += value
	if File.data.coins >= 100:
		File.data.coins -= 100
		File.data.lives += 1
#		_lives_counter.set_value(File.data.lives)
#	_coin_counter.set_value(File.data.coins)

func collect_skull():
	File.data.lives += 1
#	_lives_counter.set_value(File.data.lives)
