extends Node2D

@export var _scroll_speed : float = -100
@export var _width : float = 448

func _process(delta: float) -> void:
	pass

func _scroll(cloud : Node2D, distance : float):
	cloud.position.x += distance
	if cloud.position.x < _width * -1:
		cloud.position.x += _width * 2
