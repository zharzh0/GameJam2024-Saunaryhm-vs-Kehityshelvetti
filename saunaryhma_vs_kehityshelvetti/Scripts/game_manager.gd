extends Node2D

@onready var _camera : Camera2D = $Camera2D
@onready var _player_character : CharacterBody2D = $Player1
@onready var _level : Area2D = $Level1
@onready var _kivi_counter : Control = $UserInterface/KiviCounter
@onready var _lives_counter : Control = $UserInterface/LivesCounter
@onready var _collectibles_label : Label = $CollectiblesLabel  # Updated path
@onready var background_music : AudioStreamPlayer2D = $Music

func _ready():
	_init_boundaries()
	_init_ui()
	# Connect the health_changed signal using Callable
	_player_character.connect("health_changed", Callable(self, "_on_health_changed"))
	# Connect the died signal to reset collectibles
	_player_character.connect("died", Callable(self, "_on_player_died"))
	background_music.play()

func _init_boundaries():
	# get the level boundaries from the level
	var min_boundary : Vector2 = _level.get_min()
	var max_boundary : Vector2 = _level.get_max()
	# and tell them to the camera and player character
	_camera.set_bounds(min_boundary, max_boundary)
	_player_character.set_bounds(min_boundary, max_boundary)

func _init_ui():
	#initialize the UI
	File.data.kiuaskivet = 0  # Ensure the collectible counter starts at 0
	_kivi_counter.set_value(File.data.kiuaskivet)
	_lives_counter.set_value(_player_character._health)  # Set initial health
	_update_collectibles_label()

func _on_health_changed(new_health: int):
	_lives_counter.set_value(new_health)  # Update health display

func _on_player_died():
	File.data.kiuaskivet = 0  # Reset the collectible counter
	_kivi_counter.set_value(File.data.kiuaskivet)  # Update the UI
	_update_collectibles_label()

func collect_kivi(value : int):
	File.data.kiuaskivet += value
	if File.data.kiuaskivet >= 100:
		File.data.kiuaskivet -= 100
		_player_character.take_damage(-10)  # Increase health by 10
	_kivi_counter.set_value(File.data.kiuaskivet)
	_update_collectibles_label()

func collect_lives():
	_player_character.take_damage(-10)  # Increase health by 10

func _update_collectibles_label():
	_collectibles_label.text = "You've collected: %d stones. You need 10 stones to fix the sauna!" % File.data.kiuaskivet
