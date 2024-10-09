extends Control

@export var _digits : Array[Texture2D]
@onready var _ones : TextureRect = $Ones
@onready var _tens : TextureRect = $Tens

func set_value(value : int ):
	value = clamp (value, 0, 99)
	_ones.texture = _digits[value % 10]
	@warning_ignore("integer_division")
	_tens.texture = _digits[value / 10]
