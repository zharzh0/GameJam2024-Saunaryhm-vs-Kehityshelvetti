extends Node2D

const SPEED = 60

var direction = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
#@onready var animated_sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		#animated_sprite.flip_h = true
	if ray_cast_2d_left.is_colliding():
		direction = 1
		#animated_sprite.flip_h = false
		
	position.x += direction * SPEED * delta

func _on_body_entered(body):
	if body.name == "Player":
		print("Player killed!")
		get_tree().reload_current_scene()
