extends Area2D

@onready var _area : CollisionShape2D = $CollisionShape2D
@onready var _half_size : Vector2 = _area.shape.get_rect().size / 2

func get_min() -> Vector2:
	return _area.position - _half_size
	
func get_max() -> Vector2:
	return _area.position + _half_size
