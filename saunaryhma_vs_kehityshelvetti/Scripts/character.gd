class_name Character extends CharacterBody2D

var _is_bound : bool
var _min : Vector2
var _max : Vector2

@export_category("Locomotion")
@export var _speed : float = 8
@export var _acceleration : float = 16
@export var _deceleration : float = 32

@export_category("Jump")
@export var _jump_height : float = 2.5
@export var _air_control : float = 0.5
var _jump_velocity : float

@export_category("Sprite")
@export var _is_facing_left: bool
@export var _flipped : bool
@onready var _sprite : Sprite2D = $Sprite2D
var _was_on_floor : bool

# SIGNALS
signal died
signal changed_direction(is_facing_left : bool)
signal landed(floor_height : float)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _direction : float

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	_jump_velocity = sqrt(_jump_height * gravity * 2) * -1
	face_left() if _is_facing_left else face_right()
	
#region Public Methods

func set_bounds(min_boundary : Vector2, max_boundary : Vector2):
	_is_bound = true
	_min = min_boundary
	_max = max_boundary
	var sprite_size : Vector2 = _sprite.get_rect().size
	_min.x += sprite_size.x / 2
	_max.x -= sprite_size.x / 2
	_min.y += sprite_size.y / 2

func face_left():
	_is_facing_left = true
	if _flipped == true:
		_sprite.flip_h = false
	else:
		_sprite.flip_h = true
	changed_direction.emit(_is_facing_left)
	
func face_right():
	_is_facing_left = false
	if _flipped == true:
		_sprite.flip_h = true
	else:
		_sprite.flip_h = false
	changed_direction.emit(_is_facing_left)
	
func run(direction : float):
	_direction = direction

func jump():
	if is_on_floor():
		velocity.y = _jump_velocity

	
func stop_jump():
	if velocity.y < 0:
		velocity.y = 0

#endregion

func _physics_process(delta: float) -> void:
	if not _is_facing_left && sign(_direction) == -1:
		face_left()
	elif _is_facing_left && sign(_direction) == 1:
		face_right()
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	_was_on_floor = is_on_floor()
	move_and_slide()
	if not _was_on_floor && is_on_floor():
		_landed()
	if _is_bound:
		position.x = clamp(position.x, _min.x, _max.x)
		position.y = clamp(position.y, _min.y, _max.y)

		
func _ground_physics(delta : float):
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)
	elif velocity.x == 0 || sign(_direction) == sign(velocity.x) :
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _deceleration * delta)
	
func _air_physics(delta : float):
	velocity.y += gravity * delta
	if _direction != 0:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _air_control * delta) 
		
func _landed():
	landed.emit(position.y)

func _spawn_dust(dust : PackedScene):
	var _dust = dust.instantiate()
	_dust.position = position
	_dust.flip_h = _sprite.flip_h
	get_parent().add_child(_dust)
